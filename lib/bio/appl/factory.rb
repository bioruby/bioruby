#
# bio/appl/factory.rb - template class for process execution
#
#   Copyright (C) 2003, 2004 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#   Copyright (C) 2004 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: factory.rb,v 1.1 2005/03/04 04:48:41 k Exp $
#

require 'open3'

module Bio
class ApplicationFactory

  def initialize(program, options)
    @program = program
    @options = options
    @output = nil
    @error_log = nil
    @command = nil
  end
  attr_accessor :program, :options
  attr_reader :output, :error_log, :command
  
  UNSAFE_CHARS = /[^A-Za-z0-9_\\-.,:\/@]/n

  def shell_escape(str)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      '"' + str.gsub(/"/, '""') + '"'
    else
      str.gsub(UNSAFE_CHARS) { |x| "\\#{x}" }
    end
  end

  def make_command_line
    @command.collect { |str| shell_escape(str) }.join(" ")
  end

  def exec_local(query = nil)
    case RUBY_PLATFORM
    when /mswin32|bccwin32/
      exec_local_popen(query)
    else
      exec_local_open3(query)
    end
  end

  def exec_local_popen(query = nil)
    cmd = make_command_line
    IO.popen(cmd, "w+") do |io|
      io.sync = true
      io.print query if query
      io.close_write
      @output = io.read
    end
  end

  def exec_local_open3(query = nil)
    Open3.popen3(*@command) do |pin, pout, perr|
      pin.print query if query
      pin.close
      perr.sync = true
      t = Thread.start { @error_log = perr.read }
      begin
        @output = pout.read
      ensure
        t.join
      end
    end
  end

#  def exec_parallel
#  end

end

end # module Bio


=begin

= Bio::ApplicationFactory

 Bio::ApplicationFactory is a template class for execution of external
 softwares.  Any wrapper class for applications shall inherit this class.

--- Bio::ApplicationFactory.new(program, options)

      Creates new application factory.

--- Bio::ApplicationFactory#program
--- Bio::ApplicationFactory#options

      Accessors to the variables specified in initialize.

--- Bio::ApplicationFactory#command

      Shows the latest command-line executed by this factory.

--- Bio::ApplicationFactory#error_log

      Shows the latest stderr of the program execution.

--- Bio::ApplicationFactory#output

      Shows the latest sdtout of the program execution.

--- Bio::ApplicationFactory#shell_escape(str)

      Escape special characters in command line string.

--- Bio::ApplicationFactory#make_command_line

      Generate command line string with special characters escaped.

--- Bio::ApplicationFactory#exec_local(query = nil)

      Executes the program.  Automatically select popen for Windows
      environment and open3 for the others.

--- Bio::ApplicationFactory#exec_local_popen(query = nil)

      Executes the program via IO.popen for OS which doesn't support
      fork.

--- Bio::ApplicationFactory#exec_local_open3(query = nil)

      Executes the program via Open3.popen3

      From the view point of security, this method is recommended
      rather than exec_local_popen.

=end
