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

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 2,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/command'

module Bio
  class TestCommand < Test::Unit::TestCase

    def windows_platform?
      Bio::Command.module_eval { windows_platform? }
    end
    private :windows_platform?
    
    def test_command_constants
      assert(Bio::Command::UNSAFE_CHARS_UNIX)
      assert(Bio::Command::QUOTE_CHARS_WINDOWS)
      assert(Bio::Command::UNESCAPABLE_CHARS)
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
      if windows_platform?
        # mswin32, bccwin32, mingw32, etc.
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
      if windows_platform?
        # mswin32, bccwin32, mingw32, etc.
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
             "submit=Continue+%3E%3E",
             "ab%3Dcd%26ef%3Dgh%23ij=pq%3D12%26rs%3D34%23tu",
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
        :"ab=cd&ef=gh#ij" => 'pq=12&rs=34#tu',
      }
      result = Bio::Command.make_cgi_params(hash)
      ary.each do |str|
        assert_match(Regexp.new(Regexp.escape(str)), result)
      end

      # round-trip test
      result_hash = {}
      CGI.parse(result).each do |k, v|
        v = case v.size
            when 0
              ''
            when 1
              v[0]
            else
              v
            end
        result_hash[k.intern] = v
      end
      assert_equal(hash, result_hash)
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
             "submit=Continue+%3E%3E",
             "ab%3Dcd%26ef%3Dgh%23ij=pq%3D12%26rs%3D34%23tu",
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
        'ab=cd&ef=gh#ij' => 'pq=12&rs=34#tu',
      }
      result = Bio::Command.make_cgi_params(hash)
      ary.each do |str|
        assert_match(Regexp.new(Regexp.escape(str)), result)
      end

      # round-trip test
      result_hash = {}
      CGI.parse(result).each do |k, v|
        v = case v.size
            when 0
              ''
            when 1
              v[0]
            else
              v
            end
        result_hash[k] = v
      end
      assert_equal(hash, result_hash)
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
             "submit=Continue+%3E%3E",
             "ab%3Dcd%26ef%3Dgh%23ij=pq%3D12%26rs%3D34%23tu",
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
        [ 'ab=cd&ef=gh#ij', 'pq=12&rs=34#tu' ],
      ]
      result = Bio::Command.make_cgi_params(array_of_array)
      # When array of array, order is guaranteed.
      assert_equal(ary.join('&'), result)

      # round-trip test
      result_array = []
      CGI.parse(result).each do |k, v|
        v = case v.size
            when 0
              ''
            when 1
              v[0]
            else
              v
            end
        result_array.push([ k, v ])
      end
      assert_equal(array_of_array.sort, result_array.sort)
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
             "submit=Continue+%3E%3E",
             "ab%3Dcd%26ef%3Dgh%23ij=pq%3D12%26rs%3D34%23tu",
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
                       {'ab=cd&ef=gh#ij' => 'pq=12&rs=34#tu'},
                      ]
      result = Bio::Command.make_cgi_params(array_of_hash)
      # When array of hash, order is guaranteed.
      assert_equal(ary.join('&'), result)

      # round-trip test
      result_array = []
      CGI.parse(result).each do |k, v|
        v = case v.size
            when 0
              ''
            when 1
              v[0]
            else
              v
            end
        result_array.push({ k => v })
      end
      assert_equal(array_of_hash.sort { |x,y| x.keys[0] <=> y.keys[0] },
                   result_array.sort { |x,y| x.keys[0] <=> y.keys[0] })
    end

    def test_make_cgi_params_by_array_of_string
      str = "type1=bp&type2=bp&downstream=&upstream=&format=fasta&options=similarity&options=gene&action=export&_format=Text&output=txt&submit=Continue+%3E%3E&ab=cd%26ef%3Dgh%23ij%3Dpq%3D12%26rs%3D34%23tu"
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
                         # In the following case, 'ab' is regarded as
                         # the form key, and rest of the string is
                         # regarded as the value.
                         'ab=cd&ef=gh#ij=pq=12&rs=34#tu',
                        ]
      result = Bio::Command.make_cgi_params(array_of_string)
      assert_equal(str, result)
    end

    def test_make_cgi_params_by_string
      ##Before BioRuby 1.4.3.0001, only URI escaping was performed.
      #string = "type1=bp&type2=bp&downstream=&upstream=&format=fasta&options=similarity&options=gene&action=export&_format=Text&output=txt&submit=Continue%20%3E%3E"
      query = " type1=bp&type2=bp&downstream=&upstream=&format=fasta&options=similarity&options=gene&action=export&_format=Text&output=txt&submit=Continue >> "
      assert_raise(TypeError) {
        Bio::Command.make_cgi_params(query)
      }
    end

  end
end
