#
# test/unit/bio/util/restriction_enzyme/double_stranded/test_aligned_strands.rb - Unit test for Bio::RestrictionEnzyme::DoubleStranded::AlignedStrands
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: test_aligned_strands.rb,v 1.4 2008/06/13 11:37:25 ngoto Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 6, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/sequence'
require 'bio/util/restriction_enzyme/double_stranded/aligned_strands'
require 'bio/util/restriction_enzyme/double_stranded'

module Bio #:nodoc:

class TestDoubleStrandedAlignedStrands < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::DoubleStranded::AlignedStrands
    @s = Bio::Sequence::NA

    @ds = Bio::RestrictionEnzyme::DoubleStranded

    @s_1 = @s.new('gattaca')
    @s_2 = @s_1.forward_complement

    @s_3 = @s.new('tttttttnnn')
    @s_4 = @s.new('nnnaaaaaaa')

    @ds_1 = @ds.new('nnnn^ngattacann^nn^n')

    @obj_1 = @t.align(@s_1, @s_2)
    @obj_2 = @t.align(@s_1, @s_3)
    @obj_3 = @t.align(@s_1, @s_4)
    @obj_4 = @t.align(@s_3, @s_4)

    @obj_5 = @t.align(@ds_1.primary, @ds_1.complement)

    @obj_8 = @t.align_with_cuts(@ds_1.primary, @ds_1.complement, @ds_1.primary.cut_locations, @ds_1.complement.cut_locations)

    @obj_6 = @t.align_with_cuts(@s_1, @s_2, [1,2], [3,4])
    @obj_7 = @t.align_with_cuts(@s_3, @s_4, [1,2], [3,4])

  end

  def test_ds
    assert_equal('nngattacannnnn', @ds_1.primary)
    assert_equal('nnnnnctaatgtnn', @ds_1.complement)
    assert_equal(    'n^ngattacann^nn^n', @ds_1.primary.with_cut_symbols)
    assert_equal('n^nn^nnctaatgtn^n'    , @ds_1.complement.with_cut_symbols)

    assert_equal([0, 10, 12], @ds_1.primary.cut_locations)
    assert_equal([0, 2, 12], @ds_1.complement.cut_locations)
  end

  def test_align
    assert_equal('gattaca', @obj_1.primary)
    assert_equal('ctaatgt', @obj_1.complement)

    assert_equal('gattacannn', @obj_2.primary)
    assert_equal('tttttttnnn', @obj_2.complement)

    assert_equal('nnngattaca', @obj_3.primary)
    assert_equal('nnnaaaaaaa', @obj_3.complement)

    assert_equal('nnntttttttnnn', @obj_4.primary)
    assert_equal('nnnaaaaaaannn', @obj_4.complement)

    assert_equal('nnnnngattacannnnn', @obj_5.primary)
    assert_equal('nnnnnctaatgtnnnnn', @obj_5.complement)
  end

  def test_align_with_cuts
    assert_equal('g a^t^t a c a', @obj_6.primary)
    assert_equal('c t a a^t^g t', @obj_6.complement)

    # Looks incorrect at first, but this is deliberate.
    # The correct cuts need to be supplied by the user.
    assert_equal('n n n t t^t^t t t t n n n', @obj_7.primary)
    assert_equal('n n n a^a^a a a a a n n n', @obj_7.complement)

    assert_equal('n n n n^n g a t t a c a n n^n n^n', @obj_8.primary)
    assert_equal('n^n n^n n c t a a t g t n^n n n n', @obj_8.complement)
  end

  def test_argument_error
    assert_raise(ArgumentError) { @t.new('arg', 'agg') }
    assert_raise(ArgumentError) { @t.new(@s.new('arg'), 'agg') }
    assert_raise(ArgumentError) { @t.new('arg', @s.new('agg')) }
    assert_raise(ArgumentError) { @t.new(@s.new('argg'), @s.new('agg')) }
  end

end

end
