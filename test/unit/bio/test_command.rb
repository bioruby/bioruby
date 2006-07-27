#
# test/unit/bio/test_command.rb - Unit test for external command execution methods
#
# Copyright::	Copyright (C) 2005-2006
#               Mitsuteru Nakao <n@bioruby.org>,
# 		Naohisa Goto <ng@bioruby.org>
# License::	Ruby's
#
#  $Id: test_command.rb,v 1.3 2006/07/27 03:50:36 ngoto Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/command'

module Bio
  class TestCommand < Test::Unit::TestCase
    
    def test_command_constants
      Bio::Command::UNSAFE_CHARS_UNIX
      Bio::Command::QUOTE_CHARS_WINDOWS
      Bio::Command::UNESCAPABLE_CHARS
    end

    def test_escape_shell_windows
      str = "bio_ruby.123@456:789"
      assert_equal("bio_ruby.123@456:789",
                   Bio::Command.escape_shell_windows(str))
      str = "bio\'\"r u\"b\\y123@456:789"
      assert_equal("\"bio'\"\"r u\"\"b\\y123@456:789\"",
                   Bio::Command.escape_shell_windows(str))
    end

    def test_escape_shell_unix
      str = "bio_ruby.123@456:789"
      assert_equal("bio_ruby.123@456:789",
                   Bio::Command.escape_shell_unix(str))
      str = "bio\'\"r u\"b\\y123@456:789"
      assert_equal("bio\\'\\\"r\\ u\\\"b\\\\y123@456:789",
                   Bio::Command.escape_shell_unix(str))
    end

    def test_escape_shell
      str = "bio_ruby.123@456:789"
      assert_equal("bio_ruby.123@456:789",
                   Bio::Command.escape_shell(str))
      str = "bio\'\"r u\"b\\y123@456:789"
      case RUBY_PLATFORM
      when /mswin32|bccwin32/
        assert_equal("\"bio'\"\"r u\"\"b\\y123@456:789\"",
                     Bio::Command.escape_shell(str))
      else
        assert_equal("bio\\'\\\"r\\ u\\\"b\\\\y123@456:789",
                     Bio::Command.escape_shell(str))
      end
    end

    def test_make_command_line
      ary = [ "ruby", 
        "test.rb", "atgcatgc", "bio\'\"r u\"b\\y123@456:789" ]
      case RUBY_PLATFORM
      when /mswin32|bccwin32/
        assert_equal("ruby" + 
                       " test.rb atgcatgc" + 
                       " \"bio'\"\"r u\"\"b\\y123@456:789\"",
                     Bio::Command.make_command_line(ary))
      else
        assert_equal("ruby" + 
                       " test.rb atgcatgc" + 
                       " bio\\'\\\"r\\ u\\\"b\\\\y123@456:789",
                     Bio::Command.make_command_line(ary))
      end
    end

    def test_make_command_line_windows
      ary = [ "C:\\Program Files\\Ruby\\bin\\ruby.exe", 
        "test.rb", "atgcatgc", "bio\'\"r u\"b\\y123@456:789" ]
      assert_equal("\"C:\\Program Files\\Ruby\\bin\\ruby.exe\"" + 
                     " test.rb atgcatgc" + 
                     " \"bio'\"\"r u\"\"b\\y123@456:789\"",
                   Bio::Command.make_command_line_windows(ary))
    end

    def test_make_command_line_unix
      ary = [ "/usr/local/bin/ruby", 
        "test.rb", "atgcatgc", "bio\'\"r u\"b\\y123@456:789" ]
      assert_equal("/usr/local/bin/ruby" + 
                     " test.rb atgcatgc" +
                     " bio\\'\\\"r\\ u\\\"b\\\\y123@456:789",
                   Bio::Command.make_command_line_unix(ary))
    end

    def test_call_command
    end

    def test_call_command_popen
    end

    def test_call_command_fork
    end

    def test_call_command_open3
    end

    def test_query_command
    end

    def test_query_command_popen
    end

    def test_query_command_fork
    end

    def test_query_command_open3
    end

    def test_read_uri
    end

    def test_start_http
    end

    def test_new_http
    end

    def test_post_form
    end

  end
end
