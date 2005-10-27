#
# test/unit/bio/test_command.rb - Unit test for external command execution methods
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
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
#  $Id: test_command.rb,v 1.1 2005/10/27 15:11:51 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/command'

module Bio
  class TestCommandTools < Test::Unit::TestCase
    
    def test_command_tools_constants
      Bio::Command::Tools::UNSAFE_CHARS_UNIX
      Bio::Command::Tools::QUOTE_CHARS_WINDOWS
      Bio::Command::Tools::UNESCAPABLE_CHARS
    end

    def test_escape_shell_windows
    end

    def test_escape_shell_unix
    end

    def test_escape_shell
    end

    def test_make_command_line
    end

    def test_make_command_line_windows
    end

    def test_make_command_line_unix
    end

    def test_call_commandline_local
    end

    def test_call_commandline_local_popen
    end

    def test_call_commandline_local_open3
    end

    def test_errorlog
    end

  end
end
