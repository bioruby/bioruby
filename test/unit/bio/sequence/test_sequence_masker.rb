#
# = test/unit/bio/sequence/test_sequence_masker.rb - Unit test for Bio::Sequence::SequenceMasker
#
# Copyright::   Copyright (C) 2010
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/sequence/sequence_masker'  

module Bio

class TestSequenceMasker < Test::Unit::TestCase

  def setup
    s = "aaacgcattagcaccaccattaccaccacc"
    @raw = s.dup.freeze
    @seq = Bio::Sequence.new(s)
    @seq.quality_scores =
      (0...30).collect { |i| i * 3 }
    @seq.error_probabilities = 
      (0...30).collect { |i| 10 ** -(i * 3 / 10.0) }
  end

  # Very simple enumerator for testing.
  class SimpleEnum
    include Enumerable

    def initialize(ary)
      @ary = ary
    end

    def each(&block)
      @ary.each(&block)
    end
  end #class SimpleEnum

  def test_mask_with_enumerator
    enum = SimpleEnum.new((0..29).to_a)
    newseq = @seq.mask_with_enumerator(enum, 'n') do |item|
      i = item % 10
      i == 9 || i == 0
    end
    expected = "naacgcattnncaccaccannaccaccacn"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
  end

  def test_mask_with_enumerator_longer_mask_char
    enum = SimpleEnum.new((0..29).to_a)
    newseq = @seq.mask_with_enumerator(enum, '-*-') do |item|
      i = item % 10
      i == 9 || i == 0
    end
    expected = "-*-aacgcatt-*--*-caccacca-*--*-accaccac-*-"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
  end

  def test_mask_with_enumerator_empty_mask_char
    enum = SimpleEnum.new((0..29).to_a)
    newseq = @seq.mask_with_enumerator(enum, '') do |item|
      i = item % 10
      i == 9 || i == 0
    end
    expected = "aacgcattcaccaccaaccaccac"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
  end

  def test_mask_with_enumerator_shorter
    enum = SimpleEnum.new((0..10).to_a.freeze)
    enum.freeze
    # normal mask char
    newseq = @seq.mask_with_enumerator(enum, 'n') do |item|
      item > 5
    end
    expected = "aaacgcnnnnncaccaccattaccaccacc"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
    # empty mask char
    newseq = @seq.mask_with_enumerator(enum, '') do |item|
      item > 5
    end
    expected = "aaacgccaccaccattaccaccacc"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
    # longer mask char
    newseq = @seq.mask_with_enumerator(enum, '-*-') do |item|
      item > 5
    end
    expected = "aaacgc-*--*--*--*--*-caccaccattaccaccacc"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
  end

  def test_mask_with_enumerator_excess
    enum = SimpleEnum.new((0..200).to_a.freeze)
    enum.freeze
    # normal mask char
    newseq = @seq.mask_with_enumerator(enum, 'n') do |item|
      i = item % 10
      i == 9 || i == 0
    end
    expected = "naacgcattnncaccaccannaccaccacn"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
    # empty mask char
    newseq = @seq.mask_with_enumerator(enum, '') do |item|
      i = item % 10
      i == 9 || i == 0
    end
    expected = "aacgcattcaccaccaaccaccac"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
    # longer mask char
    newseq = @seq.mask_with_enumerator(enum, '-*-') do |item|
      i = item % 10
      i == 9 || i == 0
    end
    expected = "-*-aacgcatt-*--*-caccacca-*--*-accaccac-*-"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
  end

  def test_mask_with_quality_score
    newseq = @seq.mask_with_quality_score(30, 'n')
    expected = "nnnnnnnnnngcaccaccattaccaccacc"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
  end

  def test_mask
    newseq = @seq.mask_with_quality_score(30, 'n')
    expected = "nnnnnnnnnngcaccaccattaccaccacc"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
  end

  def test_mask_with_error_probability
    newseq = @seq.mask_with_error_probability(0.001, 'n')
    expected = "nnnnnnnnnngcaccaccattaccaccacc"
    assert_equal(expected, newseq.seq)
    # not breaking original sequence
    assert_equal(@raw, @seq.seq)
  end

end #class TestSequenceMasker

end #module Bio
