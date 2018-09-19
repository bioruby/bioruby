#
# = bio/command.rb - general methods for external command execution
#
# Copyright::	Copyright (C) 2003-2010
# 		Naohisa Goto <ng@bioruby.org>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#

require 'open3'
require 'uri'
require 'open-uri'
require 'cgi'
require 'net/http'
require 'net/https'
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

  # *CAUTION* Bio::Command INTERNAL USE ONLY.
  # Users must NOT use the method.
  # The method will be removed when it is not needed.
  #
  # Checks if the program is running on Microsoft Windows.
  # If Windows, returns true. Otherwise, returns false.
  # Note that Cygwin is not treated as Windows.
  #
  # Known issues:
  # * It might make a mistake in minor platforms/architectures/interpreters.
  # * When running JRuby on Cygwin, the result is unknown.
  # ---
  # *Returns*:: true or false
  def windows_platform?
    case RUBY_PLATFORM
    when /(?:mswin|bccwin|mingw)(?:32|64)/i
      true
    when /java/i
      # Reference: Redmine's platform.rb
      # http://www.redmine.org/projects/redmine/repository/revisions/1753/entry/trunk/lib/redmine/platform.rb
      if /windows/i =~ (ENV['OS'] || ENV['os']).to_s then
        true
      else
        false
      end
    else
      false
    end
  end
  private_class_method :windows_platform?

  # *CAUTION* Bio::Command INTERNAL USE ONLY.
  # Users must NOT use the method.
  # The method will be removed when it is not needed.
  #
  # Checks if the OS does not support fork(2) system call.
  # When not supported, it returns true.
  # When supported or unknown, it returns false or nil.
  #
  # Known issues:
  # * It might make a mistake in minor platforms/architectures/interpreters.
  # ---
  # *Returns*:: true, false or nil.
  def no_fork?
    if (defined?(@@no_fork) && @@no_fork) or
        windows_platform? or /java/i =~ RUBY_PLATFORM then
      true
    else
      false
    end
  end
  private_class_method :no_fork?

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
    if windows_platform? then
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
    if windows_platform? then
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

  # Executes the program. Automatically select popen for Ruby 1.9 or
  # Windows environment and fork for the others.
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
    if RUBY_VERSION >= "1.9.0" then
      return call_command_popen(cmd, options, &block)
    elsif no_fork? then
      call_command_popen(cmd, options, &block)
    else
      begin
        call_command_fork(cmd, options, &block)
      rescue NotImplementedError
        # fork(2) not implemented
        @@no_fork = true
        call_command_popen(cmd, options, &block)
      end
    end
  end

  # This method is internally called from the call_command method.
  # In normal case, use call_command, and do not call this method directly.
  #
  # Executes the program via IO.popen for OS which doesn't support fork.
  # A block must be given. An IO object is passed to the block.
  #
  # See the document of call_command for available options.
  #
  # Note for Ruby 1.8:
  # In Ruby 1.8, although shell unsafe characters are escaped.
  # If inescapable characters exists, it raises RuntimeError.
  # So, call_command_fork is normally recommended.
  #
  # Note for Ruby 1.9:
  # In Ruby 1.9, call_command_popen is safe and robust enough, and is the
  # recommended way, because IO.popen is improved to get a command-line
  # as an array without calling shell.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _options_: Hash
  # *Returns*:: (undefined)
  def call_command_popen(cmd, options = {}, &block)
    if RUBY_VERSION >= "1.9.0" then
      if RUBY_ENGINE == 'jruby' then
        _call_command_popen_jruby19(cmd, options, &block)
      else
        _call_command_popen_ruby19(cmd, options, &block)
      end
    else
      _call_command_popen_ruby18(cmd, options, &block)
    end
  end

  # This method is internally called from the call_command method.
  # In normal case, use call_command, and do not call this method directly.
  #
  # Executes the program via IO.popen.
  # A block must be given. An IO object is passed to the block.
  #
  # See the document of call_command for available options.
  #
  # The method is written for Ruby 1.8.
  #
  # In Ruby 1.8, although shell unsafe characters are escaped,
  # if inescapable characters exists, it raises RuntimeError.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _options_: Hash
  # *Returns*:: (undefined)
  def _call_command_popen_ruby18(cmd, options = {})
    # For Ruby 1.8, using command line string.
    str = make_command_line(cmd)
    # processing options
    if dir = options[:chdir] then
      if windows_platform?
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
  private :_call_command_popen_ruby18

  # This method is internally called from the call_command method.
  # In normal case, use call_command, and do not call this method directly.
  #
  # Executes the program via IO.popen.
  # A block must be given. An IO object is passed to the block.
  #
  # See the document of call_command for available options.
  #
  # The method can be run only on Ruby (MRI) 1.9 or later versions.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _options_: Hash
  # *Returns*:: (undefined)
  def _call_command_popen_ruby19(cmd, options = {})
    # For Ruby 1.9 or later, using command line array with options.
    dir = options[:chdir]
    cmd = safe_command_line_array(cmd)
    if dir then
      cmd = cmd + [ { :chdir => dir } ]
    end
    r = IO.popen(cmd, "r+") do |io|
      yield io
    end
    return r
  end
  private :_call_command_popen_ruby19

  # This method is internally called from the call_command method.
  # In normal case, use call_command, and do not call this method directly.
  #
  # Executes the program via IO.popen.
  # A block must be given. An IO object is passed to the block.
  #
  # See the document of call_command for available options.
  #
  # The method is written for the workaround of the JRuby bugs:
  # * {JRUBY-6195}[http://jira.codehaus.org/browse/JRUBY-6195] Process.spawn
  #   (and related methods) ignore option hash
  # * {JRUBY-6818}[http://jira.codehaus.org/browse/JRUBY-6818] Kernel.exec,
  #   Process.spawn (and IO.popen etc.) raise error when program is an array
  #   containing two strings
  # This method may be removed after the bugs are resolved.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _options_: Hash
  # *Returns*:: (undefined)
  def _call_command_popen_jruby19(cmd, options = {}, &block)
    if !options.empty? or cmd.size == 1 then
      _call_command_popen_ruby18(cmd, options, &block)
    else
      _call_command_popen_ruby19(cmd, options, &block)
    end
  end
  private :_call_command_popen_jruby19

  # This method is internally called from the call_command method.
  # In normal case, use call_command, and do not call this method directly.
  #
  # Executes the program via fork (by using IO.popen("-")) and exec.
  # A block must be given. An IO object is passed to the block.
  #
  # See the document of call_command for available options.
  #
  # Note for Ruby 1.8:
  # In Ruby 1.8, from the view point of security, this method is recommended
  # rather than call_command_popen. However, this method might have problems
  # with multi-threads.
  #
  # Note for Ruby 1.9:
  # In Ruby 1.9, this method can not be used, because Thread.critical is
  # removed. In Ruby 1.9, call_command_popen is safe and robust enough, and
  # is the recommended way, because IO.popen is improved to get a
  # command-line as an array without calling shell.
  #
  # ---
  # *Arguments*:
  # * (required) _cmd_: Array containing String objects
  # * (optional) _options_: Hash
  # *Returns*:: (undefined)
  def call_command_fork(cmd, options = {})
    dir = options[:chdir]
    cmd = safe_command_line_array(cmd)
    begin
    tc, Thread.critical, flag0, flag1 = Thread.critical, true, true, true
    IO.popen("-", "r+") do |io|
      if io then
        # parent
        flag0, Thread.critical, flag1 = false, tc, false
        yield io
      else
        # child
        Thread.critical = true # for safety, though already true
        GC.disable
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
    ensure
      # When IO.popen("-") raises error, Thread.critical will be set here.
      Thread.critical = tc if flag0 or flag1
      #warn 'Thread.critical might have wrong value.' if flag0 != flag1
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
  # Automatically select popen for Ruby 1.9 or Windows environment and
  # fork for the others.
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
    if RUBY_VERSION >= "1.9.0" then
      return query_command_popen(cmd, query, options)
    elsif no_fork? then
      query_command_popen(cmd, query, options)
    else
      begin
        query_command_fork(cmd, query, options)
      rescue NotImplementedError
        # fork(2) not implemented
        @@no_fork = true
        query_command_fork(cmd, query, options)
      end
    end
  end

  # This method is internally called from the query_command method.
  # In normal case, use query_command, and do not call this method directly.
  #
  # Executes the program with the query (String) given to the standard input,
  # waits the program termination, and returns the output data printed to the
  # standard output as a string.
  #
  # See the document of query_command for available options.
  #
  # See the document of call_command_popen for the security and Ruby
  # version specific issues.
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

  # This method is internally called from the query_command method.
  # In normal case, use query_command, and do not call this method directly.
  #
  # Executes the program with the query (String) given to the standard input,
  # waits the program termination, and returns the output data printed to the
  # standard output as a string.
  #
  # Fork (by using IO.popen("-")) and exec is used to execute the program.
  #
  # See the document of query_command for available options.
  #
  # See the document of call_command_fork for the security and Ruby
  # version specific issues.
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
  # Same as Dir.mktmpdir(prefix_suffix) in Ruby 1.9.
  #
  # ---
  # *Arguments*:
  # * (optional) <em>prefix_suffix</em>: String (or Array, etc.)
  # * (optional) <em>tmpdir</em>: String: temporary directory's path
  # 
  def mktmpdir(prefix_suffix = nil, tmpdir = nil, &block)
    begin
      Dir.mktmpdir(prefix_suffix, tmpdir, &block)
    rescue NoMethodError
      # backported from Ruby 1.9.2-preview1.
      # ***** Below is excerpted from Ruby 1.9.2-preview1's lib/tmpdir.rb ****
      # ***** Be careful about copyright. ****
      case prefix_suffix
      when nil
        prefix = "d"
        suffix = ""
      when String
        prefix = prefix_suffix
        suffix = ""
      when Array
        prefix = prefix_suffix[0]
        suffix = prefix_suffix[1]
      else
        raise ArgumentError, "unexpected prefix_suffix: #{prefix_suffix.inspect}"
      end
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
      # ***** Above is excerpted from Ruby 1.9.2-preview1's lib/tmpdir.rb ****
    end
  end

  # Bio::Command::Tmpdir is a wrapper class to handle temporary directory
  # like Tempfile class. A temporary directory is created when the object
  # of the class is created, and automatically removed when the object
  # is destroyed by GC.
  #
  # BioRuby library internal use only.
  class Tmpdir

    # Internal use only. Users should not use this class directly.
    #
    # Bio::Command::Tmpdir::Remover is a class to remove temporary
    # directory.
    #
    # Acknowledgement: The essense of the code is taken from tempfile.rb
    # in Ruby trunk (svn 34413) and in Ruby 1.8.7.
    class Remover
      # Internal use only. Users should not call this method.
      def initialize(data)
        @pid = $$
        @data = data
      end

      # Internal use only. Users should not call this method.
      def call(*args)
        return if @pid != $$

        path, = *@data

        STDERR.print "removing ", path, "..." if $DEBUG
        if path and !path.empty? and
            File.directory?(path) and
            !File.symlink?(path) then
          Bio::Command.remove_entry_secure(path)
          $stderr.print "done\n" if $DEBUG
        else
          $stderr.print "skipped\n" if $DEBUG
        end
      end
    end #class Remover

    # Creates a new Tmpdir object.
    # The arguments are the same as Bio::Command.mktmpdir.
    #
    # ---
    # *Arguments*:
    # * (optional) <em>prefix_suffix</em>: String (or Array)
    # * (optional) <em>tmpdir</em>: String: temporary directory's path
    # *Returns*:: Tmpdir object
    def initialize(prefix_suffix = nil, tmpdir = nil)
      @data = []
      @clean_proc = Remover.new(@data)
      ObjectSpace.define_finalizer(self, @clean_proc)
      @data.push(@path = Bio::Command.mktmpdir(prefix_suffix, tmpdir).freeze)
    end

    # Path to the temporay directory
    #
    # *Returns*:: String
    def path
      @path || raise(IOError, 'removed temporary directory')
    end

    # Removes the temporary directory.
    #
    # *Returns*:: nil
    def close!
      # raise error if path is nil
      self.path
      # finilizer object is called to remove the directory
      @clean_proc.call
      # unregister finalizer
      ObjectSpace.undefine_finalizer(self)
      # @data and @path is removed
      @data = @path = nil
    end
  end #class Tmpdir

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
  #   Net::HTTP.start(uri.address, uri.port)
  # and
  # it uses proxy if an environment variable (same as OpenURI.open_uri)
  # is set.
  # It supports https.
  #
  # Note: This method ignores uri.path.
  # It only uses uri.address and uri.port.
  #
  # ---
  # *Arguments*:
  # * (required) _uri_: URI object or String containing URI
  # *Returns*:: (same as Net::HTTP::start except for proxy and https support)
  def start_http_uri(uri, &block)
    unless uri.is_a?(URI)
      uri = URI.parse(uri)
    end

    # Note: URI#find_proxy is an unofficial method defined in open-uri.rb.
    # If the spec of open-uri.rb would be changed, we should change below.
    if proxyuri = uri.find_proxy then
      raise 'Non-HTTP proxy' if proxyuri.class != URI::HTTP
      klass = Net::HTTP.Proxy(proxyuri.host, proxyuri.port)
    else
      klass = Net::HTTP
    end

    http = klass.new(uri.host, uri.port)
    case uri.scheme
    when 'https'
      http.use_ssl = true
    end

    http.start(&block)
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
  #   h = Bio::Command.new_http(address, port)
  #   h.use_ssl = true
  #   h
  def new_https(address, port = 443)
    connection = new_http(address, port)
    connection.use_ssl = true
    connection
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

    start_http_uri(uri) do |http|
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
      raise TypeError, 'Bio::Command.make_cgi_params no longer accepts a single String as a form'
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

  # Same as:
  #  http = Net::HTTP.new(...); http.post(path, data, header)
  # and 
  # it uses proxy if an environment variable (same as OpenURI.open_uri)
  # is set.
  # In addition, +header+ can be set.
  # (Default Content-Type is application/octet-stream.
  # Content-Length is automatically set by default.)
  # +uri+ must be a URI object, +params+ must be a hash, and
  # +header+ must be a hash.
  #
  # ---
  # *Arguments*:
  # * (required) _http_: Net::HTTP object or compatible object
  # * (required) _path_: String
  # * (required) _data_: String containing data
  # * (optional) _header_: Hash containing header strings
  # *Returns*:: (same as Net::HTTP::post)
  def http_post(http, path, data, header = {})
    hash = {
      'Content-Type'   => 'application/octet-stream',
      'Content-Length' => data.length.to_s
    }
    hash.update(header)

    http.post(path, data, hash)
  end

  # Same as:
  # Net::HTTP.post(uri, params)
  # and 
  # it uses proxy if an environment variable (same as OpenURI.open_uri)
  # is set.
  # In addition, +header+ can be set.
  # (Default Content-Type is application/octet-stream.
  # Content-Length is automatically set by default.)
  # +uri+ must be a URI object, +data+ must be a String, and
  # +header+ must be a hash.
  #
  # ---
  # *Arguments*:
  # * (required) _uri_: URI object or String
  # * (optional) _data_: String containing data
  # * (optional) _header_: Hash containing header strings
  # *Returns*:: (same as Net::HTTP::post)
  def post(uri, data, header = {})
    unless uri.is_a?(URI)
      uri = URI.parse(uri)
    end

    hash = {
      'Content-Type'   => 'application/octet-stream',
      'Content-Length' => data.length.to_s
    }
    hash.update(header)

    start_http_uri(uri) do |http|
      http.post(uri.path, data, hash)
    end
  end

end # module Command
end # module Bio

