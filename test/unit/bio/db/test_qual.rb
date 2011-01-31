#
# test/unit/bio/db/test_qual.rb - Unit test for Bio::FastaNumericFormat
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/fasta/qual'

module Bio
  class TestFastaNumericFormat < Test::Unit::TestCase

    DATA = [24, 15, 23, 29, 20, 13, 20, 21, 21, 23, 22, 25, 13, 22, 17, 15, 25, 27, 32, 26, 32, 29, 29, 25].freeze

    def setup
      text =<<END
>CRA3575282.F 
24 15 23 29 20 13 20 21 21 23 22 25 13 22 17 15 25 27 32 26  
32 29 29 25
END
      @obj = Bio::FastaNumericFormat.new(text)
    end

    def test_entry
      assert_equal(">CRA3575282.F\n24 15 23 29 20 13 20 21 21 23 22 25 13 22 17 15 25 27 32 26  \n32 29 29 25\n", @obj.entry)
    end

    def test_entry_id
      assert_equal('CRA3575282.F', @obj.entry_id) 
    end

    def test_definition
      assert_equal('CRA3575282.F', @obj.definition)
    end

    def test_data
      assert_equal(DATA, @obj.data)
    end

    def test_length
      assert_equal(24, @obj.length)
    end

    def test_each
      assert(@obj.each {|x| })
    end

    def test_arg
      assert(@obj[0], '')
      assert(@obj[-1], '')
    end

    def test_to_biosequence
      assert_instance_of(Bio::Sequence, s = @obj.to_biosequence)
      assert_equal(Bio::Sequence::Generic.new(''), s.seq)
      assert_equal(DATA, s.quality_scores)
      assert_equal(nil, s.quality_score_type)
    end

  end #class TestFastaNumericFormat
end #module Bio
