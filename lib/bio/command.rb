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
require 'cgi'
require 'net/http'
require 'tmpdir'
require 'fileutils'

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
  #
  # Available options:
  #   :chdir => "path" : changes working directory to the specified path.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _options_: Hash
  # *Returns*:: (undefined)
  def call_command(cmd, options = {}, &block) #:yields: io
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      call_command_popen(cmd, options, &block)
    else
      call_command_fork(cmd, options, &block)
    end
  end

  # Executes the program via IO.popen for OS which doesn't support fork.
  # A block must be given. An IO object is passed to the block.
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _options_: Hash
  # *Returns*:: (undefined)
  def call_command_popen(cmd, options = {})
    str = make_command_line(cmd)
    # processing options
    if dir = options[:chdir] then
      case RUBY_PLATFORM
      when /mswin32|bccwin32/
        # Unix-like dir separator is changed to Windows dir separator
        # by using String#gsub.
        dirstr = dir.gsub(/\//, "\\")
        chdirstr = make_command_line([ 'cd', '/D', dirstr ])
        str = chdirstr + ' && ' + str
      else
        # UNIX shell
        chdirstr = make_command_line([ 'cd', dir ])
        str = chdirstr + ' && ' + str
      end
    end
    # call command by using IO.popen
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
  # * (optional) _options_: Hash
  # *Returns*:: (undefined)
  def call_command_fork(cmd, options = {})
    dir = options[:chdir]
    cmd = safe_command_line_array(cmd)
    IO.popen("-", "r+") do |io|
      if io then
        # parent
        yield io
      else
        # child
        # chdir to options[:chdir] if available
        begin
          Dir.chdir(dir) if dir
        rescue Exception
          Process.exit!(1)
        end
        # executing the command
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
  # Available options:
  #   :chdir => "path" : changes working directory to the specified path.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _query_: String
  # * (optional) _options_: Hash
  # *Returns*:: String or nil
  def query_command(cmd, query = nil, options = {})
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      query_command_popen(cmd, query, options)
    else
      query_command_fork(cmd, query, options)
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
  # * (optional) _options_: Hash
  # *Returns*:: String or nil
  def query_command_popen(cmd, query = nil, options = {})
    ret = nil
    call_command_popen(cmd, options) do |io|
      io.sync = true
      io.print query if query
      io.close_write
      ret = io.read
    end
    ret
  end

  # Executes the program with the query (String) given to the standard input,
  # waits the program termination, and returns the output data printed to the
  # standard output as a string.
  #
  # Fork (by using IO.popen("-")) and exec is used to execute the program.
  #
  # From the view point of security, this method is recommended
  # rather than query_command_popen.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _query_: String
  # * (optional) _options_: Hash
  # *Returns*:: String or nil
  def query_command_fork(cmd, query = nil, options = {})
    ret = nil
    call_command_fork(cmd, options) do |io|
      io.sync = true
      io.print query if query
      io.close_write
      ret = io.read
    end
    ret
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

  # Same as FileUtils.remove_entry_secure after Ruby 1.8.3.
  # In Ruby 1.8.2 or previous version, it only shows warning message
  # and does nothing.
  #
  # It is strongly recommended using Ruby 1.8.5 or later.
  # ---
  # *Arguments*:
  # * (required) _path_: String
  # * (optional) _force_: boolean
  def remove_entry_secure(path, force = false)
    begin
      FileUtils.remove_entry_secure(path, force)
    rescue NoMethodError
      warn "The temporary file or directory is not removed because of the lack of FileUtils.remove_entry_secure. Use Ruby 1.8.3 or later (1.8.5 or later is strongly recommended): #{path}"
      nil
    end
  end

  # Backport of Dir.mktmpdir in Ruby 1.9.
  #
  # Same as Dir.mktmpdir(prefix_suffix) in Ruby 1.9 except that
  # prefix must be a String, nil, or omitted.
  #
  # ---
  # *Arguments*:
  # * (optional) _prefix_: String
  # 
  def mktmpdir(prefix = 'd', tmpdir = nil, &block)
    prefix = prefix.to_str
    begin
      Dir.mktmpdir(prefix, tmpdir, &block)
    rescue NoMethodError
      suffix = ''
      # backported from Ruby 1.9.0.
      # ***** Below is excerpted from Ruby 1.9.0's lib/tmpdir.rb ****
      # ***** Be careful about copyright. ****
      tmpdir ||= Dir.tmpdir
      t = Time.now.strftime("%Y%m%d")
      n = nil
      begin
        path = "#{tmpdir}/#{prefix}#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
        path << "-#{n}" if n
        path << suffix
        Dir.mkdir(path, 0700)
      rescue Errno::EEXIST
        n ||= 0
        n += 1
        retry
      end

      if block_given?
        begin
          yield path
        ensure
          remove_entry_secure path
        end
      else
        path
      end
      # ***** Above is excerpted from Ruby 1.9.0's lib/tmpdir.rb ****
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
  #  http = Net::HTTP.new(...); http.post_form(path, params)
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
  # * (required) _http_: Net::HTTP object or compatible object
  # * (required) _path_: String
  # * (optional) _params_: Hash containing parameters
  # * (optional) _header_: Hash containing header strings
  # *Returns*:: (same as Net::HTTP::post_form)
  def http_post_form(http, path, params = nil, header = {})
    data = make_cgi_params(params)

    hash = {
      'Content-Type'   => 'application/x-www-form-urlencoded',
      'Content-Length' => data.length.to_s
    }
    hash.update(header)

    http.post(path, data, hash)
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
  # * (optional) _header_: Hash containing header strings
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
          key, val = str.split(/\=/, 2)
          if val then
            make_cgi_params_key_value(key, val)
          else
            CGI.escape(str)
          end
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
        result << [key, val].map {|x| CGI.escape(x.to_s) }.join('=')
      end
    else
      result << [key, value].map {|x| CGI.escape(x.to_s) }.join('=')
    end
    return result
  end

end # module Command
end # module Bio

