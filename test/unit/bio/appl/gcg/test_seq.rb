# frozen_string_literal: true

#
# test/unit/bio/appl/gcg/test_seq.rb - Unit test for Bio::GCG::Seq
#
# Copyright::  Copyright (C) 2026
#               The BioRuby developers
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/appl/gcg/seq'

module Bio
  module TestGCGSeqData
    AA = <<~__END_OF_AA__
      !!AA_SEQUENCE 1.0
      P1;TESTID
      TESTID  Length: 10  January 1, 2000 00:00  Type: P  Check: 4052  ..
      M K L V T A G G H I
    __END_OF_AA__

    NA = <<~__END_OF_NA__
      !!NA_SEQUENCE 1.0
      P1;TESTID
      TESTID  Length: 10  January 1, 2000 00:00  Type: N  Check: 1  ..
      a t g c a t g c a t
    __END_OF_NA__
  end # module TestGCGSeqData

  class TestGCGSeq < Test::Unit::TestCase
    def setup
      @aa = Bio::GCG::Seq.new(TestGCGSeqData::AA)
    end

    def test_heading
      assert_equal('!!AA_SEQUENCE 1.0', @aa.heading)
    end

    def test_definition
      assert_equal('P1;TESTID', @aa.definition)
    end

    def test_entry_id
      assert_equal('TESTID', @aa.entry_id)
    end

    def test_length
      assert_equal(10, @aa.length)
    end

    def test_date
      assert_equal('January 1, 2000 00:00', @aa.date)
    end

    def test_seq_type
      assert_equal('P', @aa.seq_type)
    end

    def test_checksum
      assert_equal(4052, @aa.checksum)
    end

    def test_seq_class
      assert_instance_of(Bio::Sequence::AA, @aa.seq)
    end

    def test_seq
      assert_equal('MKLVTAGGHI', @aa.seq)
    end

    def test_aaseq
      assert_instance_of(Bio::Sequence::AA, @aa.aaseq)
    end

    def test_naseq_raises
      assert_raise(RuntimeError) { @aa.naseq }
    end

    def test_validate_checksum
      assert_equal(true, @aa.validate_checksum)
    end
  end # class TestGCGSeq

  class TestGCGSeqNA < Test::Unit::TestCase
    def setup
      @na = Bio::GCG::Seq.new(TestGCGSeqData::NA)
    end

    def test_seq_class
      assert_instance_of(Bio::Sequence::NA, @na.seq)
    end

    def test_naseq
      assert_instance_of(Bio::Sequence::NA, @na.naseq)
    end

    def test_aaseq_raises
      assert_raise(RuntimeError) { @na.aaseq }
    end
  end # class TestGCGSeqNA

  class TestGCGSeqGeneric < Test::Unit::TestCase
    def setup
      text = "!!SEQUENCE 1.0\nP1;X\nX  Length: 4  Type: X  Check: 0  ..\nMKLV\n"
      @generic = Bio::GCG::Seq.new(text)
    end

    def test_seq_class
      assert_instance_of(Bio::Sequence, @generic.seq)
    end
  end # class TestGCGSeqGeneric

  class TestGCGSeqCalcChecksum < Test::Unit::TestCase
    def test_calc_checksum
      assert_equal(4052, Bio::GCG::Seq.calc_checksum('MKLVTAGGHI'))
    end

    def test_calc_checksum_ignores_non_letters
      assert_equal(4052, Bio::GCG::Seq.calc_checksum('MKLV TAGGHI 123'))
    end
  end # class TestGCGSeqCalcChecksum

  class TestGCGSeqToGcg < Test::Unit::TestCase
    def test_to_gcg_aa
      seq = Bio::Sequence::AA.new('MKLVTAGGHI')
      text = Bio::GCG::Seq.to_gcg(seq: seq, entry_id: 'TESTID',
                                  definition: 'test',
                                  date: 'January 1, 2000 00:00')
      obj = Bio::GCG::Seq.new(text)
      assert_equal('!!AA_SEQUENCE 1.0', obj.heading)
      assert_equal('P', obj.seq_type)
      assert_equal('TESTID', obj.entry_id)
      assert_equal('MKLVTAGGHI', obj.seq)
      assert_equal(true, obj.validate_checksum)
    end

    def test_to_gcg_na
      seq = Bio::Sequence::NA.new('atgcatgcat')
      text = Bio::GCG::Seq.to_gcg(seq: seq, entry_id: 'TESTID')
      obj = Bio::GCG::Seq.new(text)
      assert_equal('!!NA_SEQUENCE 1.0', obj.heading)
      assert_equal('N', obj.seq_type)
    end

    def test_to_gcg_generic_with_seq_type
      seq = Bio::Sequence::Generic.new('MKLV')
      text = Bio::GCG::Seq.to_gcg(seq: seq, seq_type: 'N',
                                  entry_id: 'TESTID')
      assert_equal('N', Bio::GCG::Seq.new(text).seq_type)
    end

    def test_to_gcg_generic_defaults_to_protein
      seq = Bio::Sequence::Generic.new('MKLV')
      text = Bio::GCG::Seq.to_gcg(seq: seq, entry_id: 'TESTID')
      assert_equal('P', Bio::GCG::Seq.new(text).seq_type)
    end

    def test_to_gcg_default_date
      seq = Bio::Sequence::AA.new('MKLV')
      text = Bio::GCG::Seq.to_gcg(seq: seq)
      assert_match(/Length: 4/, text)
    end
  end # class TestGCGSeqToGcg
end # module Bio
