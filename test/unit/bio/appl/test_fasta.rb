#
# test/unit/bio/appl/test_fasta.rb - Unit test for Bio::Fasta
#
# Copyright::   Copyright (C) 2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'rbconfig'
require 'bio/appl/fasta'

module Bio
  class TestFastaInitialize < Test::Unit::TestCase
    def test_new_1
      program = 'string'
      db = 'string'
      option = ['-e', '0.001']
      server = 'local'
      assert_raise(ArgumentError) { Bio::Fasta.new }
      assert_raise(ArgumentError) { Bio::Fasta.new(program) }
      assert(Bio::Fasta.new(program, db))
      assert(Bio::Fasta.new(program, db, option))
      assert(Bio::Fasta.new(program, db, option, server))
      assert_raise(ArgumentError) {  Bio::Fasta.new(program, db, option, server, nil) }
    end

    def test_option_backward_compatibility
      fasta = Bio::Fasta.new('program', 'db', '-e 10')
      assert_equal(['-Q', '-H', '-m', '10', '-e', '10'], fasta.options)
    end

    def test_option
      fasta = Bio::Fasta.new('program', 'db', ['-e', '10'])
      assert_equal(['-Q', '-H', '-m', '10', '-e', '10'], fasta.options)
    end
  end

  class TestFasta < Test::Unit::TestCase
    def setup
      program = 'ssearch'
      db = 'nr'
      option = ['-e', '10']
      @obj = Bio::Fasta.new(program, db, option)
    end

    def test_program
      assert_equal('ssearch', @obj.program)
      @obj.program = 'lalign'
      assert_equal('lalign', @obj.program)
    end

    def test_db
      assert_equal('nr', @obj.db)
      @obj.db = 'refseq'
      assert_equal('refseq', @obj.db)
    end

    def test_options
      assert_equal(['-Q', '-H', '-m', '10', '-e', '10'], @obj.options)
      @obj.options = ['-Q', '-H', '-m', '8']
      assert_equal(['-Q', '-H', '-m', '8'], @obj.options)
    end

    def test_server
      assert_equal('local', @obj.server)
      @obj.server = 'genomenet'
      assert_equal('genomenet', @obj.server)
    end

    def test_ktup
      assert_equal(nil, @obj.ktup)
      @obj.ktup = 6
      assert_equal(6, @obj.ktup)
    end

    def test_matrix
      assert_equal(nil, @obj.matrix)
      @obj.matrix = 'PAM120'
      assert_equal('PAM120', @obj.matrix)
    end

    def test_output
      assert_equal('', @obj.output)
      #      assert_raise(NoMethodError) { @obj.output = "" }
    end

    def test_option
      option = ['-M'].join(' ')
      assert(@obj.option = option)
      assert_equal(option, @obj.option)
    end

    def test_format
      assert_equal(10, @obj.format)
    end

    def test_format_arg_str
      assert(@obj.format = '1')
      assert_equal(1, @obj.format)
    end

    def test_format_arg_integer
      assert(@obj.format = 2)
      assert_equal(2, @obj.format)
    end
  end

  class TestFastaQuery < Test::Unit::TestCase
    def test_self_parser; end

    def test_self_local
      # test/functional/bio/test_fasta.rb
    end

    def test_self_remote
      # test/functional/bio/test_fasta.rb
    end

    def test_query; end
  end

  class TestFastaClassMethods < Test::Unit::TestCase
    def test_self_local
      fasta = Bio::Fasta.local('ssearch', 'nr')
      assert_equal('local', fasta.server)
    end

    def test_self_remote
      fasta = Bio::Fasta.remote('ssearch', 'nr')
      assert_equal('genomenet', fasta.server)
    end

    def test_self_remote_with_server
      fasta = Bio::Fasta.remote('ssearch', 'nr', '', 'other')
      assert_equal('other', fasta.server)
    end

    def test_self_parser
      assert_nil(Bio::Fasta.parser(:format10))
    end
  end # class TestFastaClassMethods

  class TestFastaFormatSet < Test::Unit::TestCase
    def test_format_with_existing_m_option
      fasta = Bio::Fasta.new('ssearch', 'nr')
      fasta.format = 7
      assert_equal(['-Q', '-H', '-m', '7'], fasta.options)
    end

    def test_format_without_m_option
      fasta = Bio::Fasta.new('ssearch', 'nr')
      fasta.options = ['-Q']
      fasta.format = 7
      assert_equal(['-Q', '-m', '7'], fasta.options)
    end
  end # class TestFastaFormatSet

  class TestFastaQueryDispatch < Test::Unit::TestCase
    def test_query_local
      fasta = Bio::Fasta.new('ssearch', 'nr')
      fasta.define_singleton_method(:exec_local) { |q| "local:#{q}" }
      assert_equal('local:abc', fasta.query('abc'))
    end

    def test_query_remote
      fasta = Bio::Fasta.new('ssearch', 'nr', [], 'genomenet')
      fasta.define_singleton_method(:exec_genomenet) { |q| "remote:#{q}" }
      assert_equal('remote:abc', fasta.query('abc'))
    end
  end # class TestFastaQueryDispatch

  class TestFastaParseResult < Test::Unit::TestCase
    def test_parse_result
      fasta = Bio::Fasta.new('ssearch', 'nr')
      data = "program\n>>hit1\n<\n"
      assert_instance_of(Bio::Fasta::Report, fasta.send(:parse_result, data))
    end
  end # class TestFastaParseResult

  class TestFastaExecLocal < Test::Unit::TestCase
    def setup
      @fasta = Bio::Fasta.new(RbConfig.ruby, 'db')
      @fasta.options = ['-e', 'print $stdin.read']
      @fasta.define_singleton_method(:parse_result) { |data| data }
    end

    def test_exec_local_output
      @fasta.send(:exec_local, 'hello')
      assert_equal('hello', @fasta.output)
    end

    def test_exec_local_report
      assert_equal('hello', @fasta.send(:exec_local, 'hello'))
    end
  end # class TestFastaExecLocal
end
