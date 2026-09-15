# frozen_string_literal: true

# test/functional/bio/appl/test_fasta.rb - Unit test for Bio::Fasta
#
# Copyright::   Copyright (C) 2006
#               The BioRuby developers
# License::     The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/fasta'

module Bio
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
end
