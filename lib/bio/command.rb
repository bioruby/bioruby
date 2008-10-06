#
# = bio/command.rb - general methods for external command execution
#
# Copyright::	Copyright (C) 2003-2008
# 		Naohisa Goto <ng@bioruby.org>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#  $Id:$
#

require 'open3'
require 'uri'
require 'open-uri'
require 'net/http'

module Bio

# = Bio::Command
#
# Bio::Command is a collection of useful methods for execution
# of external commands or web applications.
# Any wrapper class for applications shall use this class.
#
# Library internal use only. Users should not directly use it.
module Command

  UNSAFE_CHARS_UNIX   = /[^A-Za-z0-9\_\-\.\:\,\/\@\x1b\x80-\xfe]/n
  QUOTE_CHARS_WINDOWS = /[^A-Za-z0-9\_\-\.\:\,\/\@\\]/n
  UNESCAPABLE_CHARS   = /[\x00-\x08\x10-\x1a\x1c-\x1f\x7f\xff]/n

  module_function

  # Escape special characters in command line string for cmd.exe on Windows.
  # ---
  # *Arguments*:
  # * (required) _str_: String
  # *Returns*:: String object
  def escape_shell_windows(str)
    str = str.to_s
    raise 'cannot escape control characters' if UNESCAPABLE_CHARS =~ str
    if QUOTE_CHARS_WINDOWS =~ str then
      '"' + str.gsub(/\"/, '""') + '"'
    else
      String.new(str)
    end
  end

  # Escape special characters in command line string for UNIX shells.
  # ---
  # *Arguments*:
  # * (required) _str_: String
  # *Returns*:: String object
  def escape_shell_unix(str)
    str = str.to_s
    raise 'cannot escape control characters' if UNESCAPABLE_CHARS =~ str
    str.gsub(UNSAFE_CHARS_UNIX) { |x| "\\#{x}" }
  end

  # Escape special characters in command line string.
  # ---
  # *Arguments*:
  # * (required) _str_: String
  # *Returns*:: String object
  def escape_shell(str)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      escape_shell_windows(str)
    else
      escape_shell_unix(str)
    end
  end

  # Generate command line string with special characters escaped.
  # ---
  # *Arguments*:
  # * (required) _ary_: Array containing String objects
  # *Returns*:: String object
  def make_command_line(ary)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      make_command_line_windows(ary)
    else
      make_command_line_unix(ary)
    end
  end

  # Generate command line string with special characters escaped
  # for cmd.exe on Windows.
  # ---
  # *Arguments*:
  # * (required) _ary_: Array containing String objects
  # *Returns*:: String object
  def make_command_line_windows(ary)
    ary.collect { |str| escape_shell_windows(str) }.join(" ")
  end

  # Generate command line string with special characters escaped
  # for UNIX shells.
  # ---
  # *Arguments*:
  # * (required) _ary_: Array containing String objects
  # *Returns*:: String object
  def make_command_line_unix(ary)
    ary.collect { |str| escape_shell_unix(str) }.join(" ")
  end

  # Returns an Array of command-line command and arguments
  # that can be safely passed to Kernel.exec etc.
  # If the given array is already safe (or empty), returns the given array.
  # ---
  # *Arguments*:
  # * (required) _ary_: Array
  # *Returns*:: Array
  def safe_command_line_array(ary)
    ary = ary.to_ary
    return ary if ary.size >= 2 or ary.empty?
    if ary.size != 1 then
      raise 'Bug: assersion of ary.size == 1 failed'
    end
    arg0 = ary[0]
    begin
      arg0 = arg0.to_ary
    rescue NoMethodError
      arg0 = [ arg0, arg0 ]
    end
    [ arg0 ]
  end

  # Executes the program.  Automatically select popen for Windows
  # environment and fork for the others.
  # A block must be given. An IO object is passed to the block.
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # *Returns*:: (undefined)
  def call_command(cmd, &block) #:yields: io
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      call_command_popen(cmd, &block)
    else
      call_command_fork(cmd, &block)
    end
  end

  # Executes the program via IO.popen for OS which doesn't support fork.
  # A block must be given. An IO object is passed to the block.
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # *Returns*:: (undefined)
  def call_command_popen(cmd)
    str = make_command_line(cmd)
    IO.popen(str, "w+") do |io|
      io.sync = true
      yield io
    end
  end

  # Executes the program via fork (by using IO.popen("-")) and exec.
  # A block must be given. An IO object is passed to the block.
  #
  # From the view point of security, this method is recommended
  # rather than call_command_popen.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # *Returns*:: (undefined)
  def call_command_fork(cmd)
    cmd = safe_command_line_array(cmd)
    IO.popen("-", "r+") do |io|
      if io then
        # parent
        yield io
      else
        # child
        begin
          Kernel.exec(*cmd)
        rescue Errno::ENOENT, Errno::EACCES
          Process.exit!(127)
        rescue Exception
        end
        Process.exit!(1)
      end
    end
  end

  # Executes the program via Open3.popen3
  # A block must be given. IO objects are passed to the block.
  #
  # You would use this method only when you really need to get stderr.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # *Returns*:: (undefined)
  def call_command_open3(cmd)
    cmd = safe_command_line_array(cmd)
    Open3.popen3(*cmd) do |pin, pout, perr|
      yield pin, pout, perr
    end
  end

  # Executes the program with the query (String) given to the standard input,
  # waits the program termination, and returns the output data printed to the
  # standard output as a string.
  # 
  # Automatically select popen for Windows environment and fork for the others.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _query_: String
  # *Returns*:: String or nil
  def query_command(cmd, query = nil)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      query_command_popen(cmd, query)
    else
      query_command_fork(cmd, query)
    end
  end

  # Executes the program with the query (String) given to the standard input,
  # waits the program termination, and returns the output data printed to the
  # standard output as a string.
  #
  # IO.popen is used for OS which doesn't support fork.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _query_: String
  # *Returns*:: String or nil
  def query_command_popen(cmd, query = nil)
    str = make_command_line(cmd)
    IO.popen(str, "w+") do |io|
      io.sync = true
      io.print query if query
      io.close_write
      io.read
    end
  end

  # Executes the program with the query (String) given to the standard input,
  # waits the program termination, and returns the output data printed to the
  # standard output as a string.
  #
  # Fork (by using IO.popen("-")) and exec is used to execute the program.
  #
  # From the view point of security, this method is recommended
  # rather than query_popen.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _query_: String
  # *Returns*:: String or nil
  def query_command_fork(cmd, query = nil)
    cmd = safe_command_line_array(cmd)
    IO.popen("-", "r+") do |io|
      if io then
        # parent
        io.sync = true
        io.print query if query
        io.close_write
        io.read
      else
        # child
        begin
          Kernel.exec(*cmd)
        rescue Errno::ENOENT, Errno::EACCES
          Process.exit!(127)
        rescue Exception
        end
        Process.exit!(1)
      end
    end
  end

  # Executes the program via Open3.popen3 with the query (String) given
  # to the stain, waits the program termination, and
  # returns the data from stdout and stderr as an array of the strings.
  #
  # You would use this method only when you really need to get stderr.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _query_: String
  # *Returns*:: Array containing 2 objects: output string (or nil) and stderr string (or nil)
  def query_command_open3(cmd, query = nil)
    errorlog = nil
    cmd = safe_command_line_array(cmd)
    Open3.popen3(*cmd) do |pin, pout, perr|
      perr.sync = true
      t = Thread.start { errorlog = perr.read }
      begin
        pin.print query if query
        pin.close
        output = pout.read
      ensure
        t.join
      end
      [ output, errorlog ]
    end
  end

  # Same as OpenURI.open_uri(uri).read
  # and 
  # it uses proxy if an environment variable (same as OpenURI.open_uri)
  # is set.
  #
  # ---
  # *Arguments*:
  # * (required) _uri_: URI object or String
  # *Returns*:: String
  def read_uri(uri)
    OpenURI.open_uri(uri).read
  end

  # Same as:
  #   Net::HTTP.start(address, port)
  # and 
  # it uses proxy if an environment variable (same as OpenURI.open_uri)
  # is set.
  #
  # ---
  # *Arguments*:
  # * (required) _address_: String containing host name or IP address
  # * (optional) _port_: port (sanme as Net::HTTP::start)
  # *Returns*:: (same as Net::HTTP::start except for proxy support)
  def start_http(address, port = 80, &block)
    uri = URI.parse("http://#{address}:#{port}")
    # Note: URI#find_proxy is an unofficial method defined in open-uri.rb.
    # If the spec of open-uri.rb would be changed, we should change below.
    if proxyuri = uri.find_proxy then
      raise 'Non-HTTP proxy' if proxyuri.class != URI::HTTP
      http = Net::HTTP.Proxy(proxyuri.host, proxyuri.port)
    else
      http = Net::HTTP
    end
    http.start(address, port, &block)
  end

  # Same as:
  #   Net::HTTP.new(address, port)
  # and 
  # it uses proxy if an environment variable (same as OpenURI.open_uri)
  # is set.
  #
  # ---
  # *Arguments*:
  # * (required) _address_: String containing host name or IP address
  # * (optional) _port_: port (sanme as Net::HTTP::start)
  # *Returns*:: (same as Net::HTTP.new except for proxy support)
  def new_http(address, port = 80)
    uri = URI.parse("http://#{address}:#{port}")
    # Note: URI#find_proxy is an unofficial method defined in open-uri.rb.
    # If the spec of open-uri.rb would be changed, we should change below.
    if proxyuri = uri.find_proxy then
      raise 'Non-HTTP proxy' if proxyuri.class != URI::HTTP
      Net::HTTP.new(address, port, proxyuri.host, proxyuri.port)
    else
      Net::HTTP.new(address, port)
    end
  end

  # Same as:
  # Net::HTTP.post_form(uri, params)
  # and 
  # it uses proxy if an environment variable (same as OpenURI.open_uri)
  # is set.
  # In addition, +header+ can be set.
  # (Note that Content-Type and Content-Length are automatically
  # set by default.)
  # +uri+ must be a URI object, +params+ must be a hash, and
  # +header+ must be a hash.
  #
  # ---
  # *Arguments*:
  # * (required) _uri_: URI object or String
  # * (optional) _params_: Hash containing parameters
  # * (optional) _hrader_: Hash containing header strings
  # *Returns*:: (same as Net::HTTP::post_form)
  def post_form(uri, params = nil, header = {})
    unless uri.is_a?(URI)
      uri = URI.parse(uri)
    end

    data = make_cgi_params(params)

    hash = {
      'Content-Type'   => 'application/x-www-form-urlencoded',
      'Content-Length' => data.length.to_s
    }
    hash.update(header)

    start_http(uri.host, uri.port) do |http|
      http.post(uri.path, data, hash)
    end
  end

  # Builds parameter string for from Hash of parameters for
  # application/x-www-form-urlencoded.
  #
  # ---
  # *Arguments*:
  # * (required) _params_: Hash containing parameters
  # *Returns*:: String
  def make_cgi_params(params)
    data = ""
    case params
    when Hash
      data = params.map do |key, val|
        make_cgi_params_key_value(key, val)
      end.join('&')
    when Array
      case params.first
      when Hash
        data = params.map do |hash|
          hash.map do |key, val|
            make_cgi_params_key_value(key, val)
          end
        end.join('&')
      when Array
        data = params.map do |key, val|
          make_cgi_params_key_value(key, val)
        end.join('&')
      when String
        data = params.map do |str|
          URI.escape(str.strip)
        end.join('&')
      end
    when String
      data = URI.escape(params.strip)
    end
    return data
  end

  # Builds parameter string for from a key string and a value (or values)
  # for application/x-www-form-urlencoded.
  #
  # ---
  # *Arguments*:
  # * (required) _key_: String
  # * (required) _value_: String or Array containing String
  # *Returns*:: String
  def make_cgi_params_key_value(key, value)
    result = []
    case value
    when Array
      value.each do |val|
        result << [key, val].map {|x| URI.escape(x.to_s) }.join('=')
      end
    else
      result << [key, value].map {|x| URI.escape(x.to_s) }.join('=')
    end
    return result
  end

end # module Command
end # module Bio

