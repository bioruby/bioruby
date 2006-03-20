#
# = bio/command.rb - general methods for external command execution
#
# Copyright::	Copyright (C) 2003-2006
# 		Naohisa Goto <ng@bioruby.org>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	Ruby's
#
#  $Id: command.rb,v 1.4 2006/03/20 10:34:57 ngoto Exp $
#

require 'open3'
require 'uri'

module Bio
module Command

# = Bio::Command::Tools
#
# Bio::Command::Tools is a collection of useful methods for execution
# of external commands or web applications. Any wrapper class for
# applications shall include this class. Note that all methods below
# are private except for some methods.
module Tools

  UNSAFE_CHARS_UNIX   = /[^A-Za-z0-9\_\-\.\:\,\/\@\x1b\x80-\xfe]/n
  QUOTE_CHARS_WINDOWS = /[^A-Za-z0-9\_\-\.\:\,\/\@\\]/n
  UNESCAPABLE_CHARS   = /[\x00-\x08\x10-\x1a\x1c-\x1f\x7f\xff]/n

  #module_function
  private

  # Escape special characters in command line string for cmd.exe on Windows.
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
  def escape_shell_unix(str)
    str = str.to_s
    raise 'cannot escape control characters' if UNESCAPABLE_CHARS =~ str
    str.gsub(UNSAFE_CHARS_UNIX) { |x| "\\#{x}" }
  end

  # Escape special characters in command line string.
  def escape_shell(str)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      escape_shell_windows(str)
    else
      escape_shell_unix(str)
    end
  end

  # Generate command line string with special characters escaped.
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
  def make_command_line_windows(ary)
    ary.collect { |str| escape_shell_windows(str) }.join(" ")
  end

  # Generate command line string with special characters escaped
  # for UNIX shells.
  def make_command_line_unix(ary)
    ary.collect { |str| escape_shell_unix(str) }.join(" ")
  end

  # Executes the program.  Automatically select popen for Windows
  # environment and open3 for the others.
  #
  # If block is given, yield the block with input and output IO objects.
  # Note that in some platform, inn and out are the same object.
  # Please be careful to do inn.close and out.close.
  def call_command_local(cmd, query = nil, &block)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      call_command_local_popen(cmd, query, &block)
    else
      call_command_local_open3(cmd, query, &block)
    end
  end

  # Executes the program via IO.popen for OS which doesn't support fork.
  # If block is given, yield the block with IO objects.
  # The two objects are the same because of limitation of IO.popen.
  def call_command_local_popen(cmd, query = nil)
    str = make_command_line(cmd)
    IO.popen(str, "w+") do |io|
      if block_given? then
        io.sync = true
        yield io, io
      else
        io.sync = true
        io.print query if query
        io.close_write
        io.read
      end
    end
  end

  # Executes the program via Open3.popen3
  # If block is given, yield the block with input and output IO objects.
  #
  # From the view point of security, this method is recommended
  # rather than exec_local_popen.
  def call_command_local_open3(cmd, query = nil)
    cmd = cmd.collect { |x| x.to_s }
    Open3.popen3(*cmd) do |pin, pout, perr|
      perr.sync = true
      t = Thread.start { @errorlog = perr.read }
      if block_given? then
        yield pin, pout
      else
        begin
          pin.print query if query
          pin.close
          output = pout.read
        ensure
          t.join
        end
        output
      end
    end
  end

  # Shows the latest stderr of the program execution.
  # Note that this method may be thread unsafe.
  attr_reader :errorlog
  public :errorlog

end # module Tools


# = Bio::Command::NetTools
#
# Bio::Command::NetTools is a collection of miscellaneous methods
# for data transport through network.
#
# Library internal use only. Users should not directly use it.
#
# Note that it is under construction.
module NetTools

  # Same as OpenURI.open_uri(*arg).
  # If open-uri.rb is already loaded, ::OpenURI is used.
  # Otherwise, internal OpenURI in sandbox is used because
  # open-uri.rb redefines Kernel.open.
  def self.open_uri(uri, *arg)
    if defined? ::OpenURI
      ::OpenURI.open_uri(uri, *arg)
    else
      SandBox.load_openuri_in_sandbox
      uri = uri.to_s if ::URI::Generic === uri
      SandBox::OpenURI.open_uri(uri, *arg)
    end
  end

  # Same as OpenURI.open_uri(uri).read.
  # If open-uri.rb is already loaded, ::OpenURI is used.
  # Otherwise, internal OpenURI in sandbox is used becase
  # open-uri.rb redefines Kernel.open.
  def self.read_uri(uri)
    self.open_uri(uri).read
  end

  # Sandbox to load open-uri.rb.
  # Internal use only.
  module SandBox #:nodoc:

    # Dummy module definition.
    module Kernel #:nodoc:
      # dummy method
      def open(*arg); end #:nodoc:
    end #module Kernel
    
    # a method to find proxy. dummy definition
    module FindProxy; end #:nodoc:
    
    # dummy module definition
    module OpenURI #:nodoc:
      module OpenRead; end #:nodoc:
    end #module OpenURI
    
    # Dummy module definition.
    module URI #:nodoc:
      class Generic < ::URI::Generic #:nodoc:
        include SandBox::FindProxy
      end
      
      class HTTPS < ::URI::HTTPS #:nodoc:
        include SandBox::FindProxy
        include SandBox::OpenURI::OpenRead
      end
      
      class HTTP  < ::URI::HTTP  #:nodoc:
        include SandBox::FindProxy
        include SandBox::OpenURI::OpenRead
      end
      
      class FTP  < ::URI::FTP    #:nodoc:
        include SandBox::FindProxy
        include SandBox::OpenURI::OpenRead
      end
      
      # parse and new. internal use only.
      def self.__parse_and_new__(klass, uri) #:nodoc:
        scheme, userinfo, host, port,
        registry, path, opaque, query, fragment = ::URI.split(uri)
        klass.new(scheme, userinfo, host, port,
                  registry, path, opaque, query,
                  fragment)
      end
      private_class_method :__parse_and_new__
      
      # same as ::URI.parse. internal use only.
      def self.parse(uri) #:nodoc:
        r = ::URI.parse(uri)
        case r
        when ::URI::HTTPS
          __parse_and_new__(HTTPS, uri)
        when ::URI::HTTP
          __parse_and_new__(HTTP, uri)
        when ::URI::FTP
          __parse_and_new__(FTP, uri)
        else
          r
        end
      end
    end #module URI
    
    @load_openuri = nil
    # load open-uri.rb in SandBox module.
    def self.load_openuri_in_sandbox #:nodoc:
      return if @load_openuri
      fn = nil
      unless $:.find do |x|
          fn = File.join(x, 'open-uri.rb')
          FileTest.exist?(fn)
        end then
        warn('Warning: cannot find open-uri.rb in $LOAD_PATH')
      else
        # reading open-uri.rb
        str = File.read(fn)
        # eval open-uri.rb contents in SandBox module
        module_eval(str)
        
        # finds 'find_proxy' method
        find_proxy_lines = nil
        flag = nil
        endstr = nil
        str.each do |line|
          if flag then
            find_proxy_lines << line
            if endstr == line[0, endstr.length] and
                /^\s+end(\s+.*)?$/ =~ line then
              break
            end
          elsif /^(\s+)def\s+find_proxy(\s+.*)?$/ =~ line then
            flag = true
            endstr = "#{$1}end"
            find_proxy_lines = line 
          end
        end
        if find_proxy_lines
          module_eval("module FindProxy;\n#{find_proxy_lines}\n;end\n")
        else
          warn('Warning: cannot find find_proxy method in open-uri.rb.')
        end
        @load_openuri = true
      end
    end
  end #module SandBox
end #module NetTools

end # module Command
end # module Bio

