#
# test/unit/bio/util/restriction_enzyme/test_double_stranded.rb - Unit test for Bio::RestrictionEnzyme::DoubleStranded
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: test_double_stranded.rb,v 1.6 2007/07/16 19:29:32 k Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme/double_stranded'
require 'bio/sequence'

module Bio #:nodoc:

class TestDoubleStranded < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::DoubleStranded
    @cl = Bio::RestrictionEnzyme::DoubleStranded::CutLocationPairInEnzymeNotation
    @s = String


    @obj_1 = @t.new(@s.new('gata'), [1,2])
    @obj_2 = @t.new('gata', [1,2])
    @obj_3 = @t.new('garraxt', [1,2])
    @obj_4 = @t.new('nnnnnnngarraxtnn', [1,2])

    @obj_5 = @t.new('garraxt', @cl.new(3,2), @cl.new(-2,-1), @cl.new(9,11))
    @obj_6 = @t.new('garraxt', @cl.new(3,2))
    @obj_7 = @t.new('garraxt', @cl.new(3,2), @cl.new(9,11))

#    @obj_8 = @t.new('garraxt', 3..2, 9..11)
    @obj_9 = @t.new('garraxt', [3,2], [9,11])

    @obj_10 = @t.new('garraxt', [3,2], [9,11])

    @obj_11 = @t.new('n^ngar^raxtnn^n')
    @obj_12 = @t.new('nnnn^ngar^raxtnn^nnnn')

    @obj_13 = @t.new(Bio::RestrictionEnzyme.rebase['EcoRII'])
    @obj_14 = @t.new('EcoRII')
    @obj_15 = @t.new('ecorii')
  end

  def test_primary
    assert_equal('nngarraxtnnn', @obj_5.primary)
  end

  def test_primary_with_cut_symbols
    assert_equal('n^ngar^raxtnn^n', @obj_5.primary.with_cut_symbols)
    assert_equal('gar^raxt', @obj_6.primary.with_cut_symbols)
    assert_equal('gar^raxtnn^n', @obj_7.primary.with_cut_symbols)

#    assert_equal('gar^raxtnn^n', @obj_8.primary.with_cut_symbols)
    assert_equal('gar^raxtnn^n', @obj_9.primary.with_cut_symbols)

    assert_equal('gar^raxtnn^n', @obj_10.primary.with_cut_symbols)
    
    assert_equal('n^ngar^raxtnn^n', @obj_11.primary.with_cut_symbols)
    assert_equal('n^ngar^raxtnn^n', @obj_12.primary.with_cut_symbols)

    assert_equal('n^ccwgg', @obj_13.primary.with_cut_symbols)
    assert_equal('n^ccwgg', @obj_14.primary.with_cut_symbols)
    assert_equal('n^ccwgg', @obj_15.primary.with_cut_symbols)
  end

  def test_complement_with_cut_symbols
    assert_equal('n^ct^yytxannnn^n', @obj_5.complement.with_cut_symbols)
    assert_equal('ct^yytxa', @obj_6.complement.with_cut_symbols)
    assert_equal('ct^yytxannnn^n', @obj_7.complement.with_cut_symbols)

#    assert_equal('ct^yytxannnn^n', @obj_8.complement.with_cut_symbols)
    assert_equal('ct^yytxannnn^n', @obj_9.complement.with_cut_symbols)

    assert_equal('ct^yytxannnn^n', @obj_10.complement.with_cut_symbols)

    assert_equal('n^nnctyy^txan^n', @obj_11.complement.with_cut_symbols)
    assert_equal('n^nnctyy^txan^n', @obj_12.complement.with_cut_symbols)

    assert_equal('ggwcc^n', @obj_13.complement.with_cut_symbols)
    assert_equal('ggwcc^n', @obj_14.complement.with_cut_symbols)
    assert_equal('ggwcc^n', @obj_15.complement.with_cut_symbols)
  end

  def test_complement
    assert_equal('nctyytxannnnn', @obj_5.complement)
  end

  def test_cut_locations
    assert_equal([[4, 3], [0, 1], [10, 12]], @obj_5.cut_locations)
  end

  def test_cut_locations_in_enzyme_notation
    assert_equal([[3, 2], [-2, -1], [9, 11]], @obj_5.cut_locations_in_enzyme_notation)
  end

  def test_argument_error
    assert_raise(ArgumentError) { @t.new('garraxt', [3,2,9,11]) }
    assert_raise(ArgumentError) { @t.new(Bio::RestrictionEnzyme.rebase['ecorii'] )}
    assert_raise(ArgumentError) { @t.new(Bio::RestrictionEnzyme.rebase['EzzRII']) }
  end

  # NOTE
  def test_to_re
  end

end

end
