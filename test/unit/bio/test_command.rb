#
# test/unit/bio/test_command.rb - Unit test for Bio::Command
#
# Copyright::	Copyright (C) 2005-2008
#               Mitsuteru Nakao <n@bioruby.org>,
# 		Naohisa Goto <ng@bioruby.org>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#  $Id:$
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

    def test_safe_command_line_array
      ary1 = [ 'test' ]
      assert_equal([ [ 'test', 'test' ] ],
                   Bio::Command.safe_command_line_array(ary1))
      ary1a = [ [ 'test/test1a', 'test' ] ]
      assert_equal(ary1a,
                   Bio::Command.safe_command_line_array(ary1a))
    end

    def test_safe_command_line_array_passthrough
      ary0 = []
      assert_equal(ary0,
                   Bio::Command.safe_command_line_array(ary0))
      ary2 = [ 'cmd', 'arg0' ]
      assert_equal(ary2,
                   Bio::Command.safe_command_line_array(ary2))
      ary2a = [ [ 'cmd', 'display name' ], 'arg0' ]
      assert_equal(ary2a,
                   Bio::Command.safe_command_line_array(ary2a))
      ary3 = [ 'cmd', 'arg0', 'arg1' ]
      assert_equal(ary3,
                   Bio::Command.safe_command_line_array(ary3))
    end

    def test_make_cgi_params_by_hash_in_symbol
      ary = [
             "type1=bp",
             "type2=bp",
             "downstream=",
             "upstream=",
             "format=fasta",
             "options=similarity",
             "options=gene",
             "action=export",
             "_format=Text",
             "output=txt",
             "submit=Continue%20%3E%3E",
            ]
      hash = {
        :type1 => 'bp',
        :type2 => 'bp',
        :downstream => '',
        :upstream => '',
        :format => 'fasta',
        :options => ['similarity', 'gene'],
        :action => 'export',
        :_format => 'Text',
        :output => 'txt',
        :submit => 'Continue >>',
      }
      result = Bio::Command.make_cgi_params(hash)
      ary.each do |str|
        assert_match(str, result)
      end
    end

    def test_make_cgi_params_by_hash_in_string
      ary = [
             "type1=bp",
             "type2=bp",
             "downstream=",
             "upstream=",
             "format=fasta",
             "options=similarity",
             "options=gene",
             "action=export",
             "_format=Text",
             "output=txt",
             "submit=Continue%20%3E%3E",
            ]
      hash = {
        "type1" => 'bp',
        "type2" => 'bp',
        "downstream" => '',
        "upstream" => '',
        "format" => 'fasta',
        "options" => ['similarity', 'gene'],
        "action" => 'export',
        "_format" => 'Text',
        "output" => 'txt',
        "submit" => 'Continue >>',
      }
      result = Bio::Command.make_cgi_params(hash)
      ary.each do |str|
        assert_match(str, result)
      end
    end

    def test_make_cgi_params_by_array_of_array
      ary = [
             "type1=bp",
             "type2=bp",
             "downstream=",
             "upstream=",
             "format=fasta",
             "options=similarity",
             "options=gene",
             "action=export",
             "_format=Text",
             "output=txt",
             "submit=Continue%20%3E%3E",
            ]
      array_of_array = [
        ["type1", 'bp'],
        ["type2", 'bp'], 
        ["downstream", ''],
        ["upstream", ''],
        ["format", 'fasta'],
        ["options", ['similarity', 'gene']],
        ["action", 'export'],
        ["_format", 'Text'],
        ["output", 'txt'],
        ["submit", 'Continue >>'],
      ]
      result = Bio::Command.make_cgi_params(array_of_array)
      ary.each do |str|
        assert_match(str, result)
      end
    end

    def test_make_cgi_params_by_array_of_hash
      ary = [
             "type1=bp",
             "type2=bp",
             "downstream=",
             "upstream=",
             "format=fasta",
             "options=similarity",
             "options=gene",
             "action=export",
             "_format=Text",
             "output=txt",
             "submit=Continue%20%3E%3E",
            ]
      array_of_hash = [
                       {"type1" => 'bp'},
                       {"type2" => 'bp'},
                       {"downstream" => ''},
                       {"upstream" => ''},
                       {"format" => 'fasta'},
                       {"options" => ['similarity', 'gene']},
                       {"action" => 'export'},
                       {"_format" => 'Text'},
                       {"output" => 'txt'},
                       {"submit" => 'Continue >>'},
                      ]
      result = Bio::Command.make_cgi_params(array_of_hash)
      ary.each do |str|
        assert_match(str, result)
      end
    end

    def test_make_cgi_params_by_array_of_string
      str = "type1=bp&type2=bp&downstream=&upstream=&format=fasta&options=similarity&options=gene&action=export&_format=Text&output=txt&submit=Continue%20%3E%3E"
      array_of_string = [
                         "type1=bp",
                         "type2=bp",
                         "downstream=",
                         "upstream=",
                         "format=fasta",
                         "options=similarity",
                         "options=gene",
                         "action=export",
                         "_format=Text",
                         "output=txt",
                         "submit=Continue >>",
                        ]
      result = Bio::Command.make_cgi_params(array_of_string)
      assert_equal(str, result)
    end

    def test_make_cgi_params_by_string
      string = "type1=bp&type2=bp&downstream=&upstream=&format=fasta&options=similarity&options=gene&action=export&_format=Text&output=txt&submit=Continue%20%3E%3E"
      query = " type1=bp&type2=bp&downstream=&upstream=&format=fasta&options=similarity&options=gene&action=export&_format=Text&output=txt&submit=Continue >> "
      result = Bio::Command.make_cgi_params(query)
      assert_equal(string, result)
    end

  end
end
