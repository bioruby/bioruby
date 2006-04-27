#
# = bio/command.rb - general methods for external command execution
#
# Copyright::	Copyright (C) 2003-2006
# 		Naohisa Goto <ng@bioruby.org>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	Ruby's
#
#  $Id: command.rb,v 1.7 2006/04/27 02:33:43 ngoto Exp $
#

require 'open3'
require 'uri'
require 'open-uri'
require 'net/http'

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

  # Same as OpenURI.open_uri(uri).read.
  def self.read_uri(uri)
    OpenURI.open_uri(uri).read
  end

  # Same as:
  #   Net::HTTP.start(address, port)
  # and 
  # it uses proxy if an environment variable (same as OpenURI.open_uri)
  # is set.
  #
  def self.net_http_start(address, port = 80, &block)
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
end #module NetTools

end # module Command
end # module Bio

