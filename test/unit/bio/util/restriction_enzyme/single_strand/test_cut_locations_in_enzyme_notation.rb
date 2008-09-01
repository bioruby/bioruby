#
# test/unit/bio/util/restriction_enzyme/single_strand/test_cut_locations_in_enzyme_notation.rb - Unit test for Bio::RestrictionEnzyme::SingleStrand::CutLocationsInEnzymeNotation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id:$
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 6, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme/single_strand/cut_locations_in_enzyme_notation'

module Bio; module TestRestrictionEnzyme #:nodoc:

class TestSingleStrandCutLocationsInEnzymeNotation < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::SingleStrand::CutLocationsInEnzymeNotation
    @obj_1 = @t.new([-2,1,3])
    @obj_2 = @t.new(-2,1,3)
    @obj_3 = @t.new(7,1,3)

    @obj_4 = @t.new(-7,-8,-2,1,3)
  end

  def test_max
    assert_equal(3, @obj_1.max)
    assert_equal(3, @obj_2.max)
    assert_equal(7, @obj_3.max)
  end

  def test_min
    assert_equal(-2, @obj_1.min)
    assert_equal(-2, @obj_2.min)
    assert_equal(1, @obj_3.min)
  end

  def test_to_array_index
    assert_equal([0,2,4], @obj_1.to_array_index)
    assert_equal([0,2,4], @obj_2.to_array_index)
    assert_equal([0,2,6], @obj_3.to_array_index)

    assert_equal([0, 1, 6, 8, 10], @obj_4.to_array_index)
  end

  def test_initialize_with_pattern
    @obj_5 = @t.new('n^ng^arraxt^n')
    @obj_6 = @t.new('g^arraxt^n')
    @obj_7 = @t.new('nnn^nn^nga^rraxt^nn')
    @obj_8 = @t.new('^g^arraxt^n')

    assert_equal([-2,1,7], @obj_5)
    assert_equal([0,2,8], @obj_5.to_array_index)

    assert_equal([1,7], @obj_6)
    assert_equal([0,6], @obj_6.to_array_index)

    assert_equal([-4, -2, 2, 7], @obj_7)
    assert_equal([0, 2, 5, 10], @obj_7.to_array_index)
    
    assert_equal([-1,1,7], @obj_8)
    assert_equal([0,1,7], @obj_8.to_array_index)
  end

  def test_argument_error
    assert_raise(ArgumentError) { @t.new([0,1,2]) }
    assert_raise(ArgumentError) { @t.new(0,1,2,0) }

    assert_raise(ArgumentError) { @t.new([nil,1,2]) }
    assert_raise(ArgumentError) { @t.new(nil,1,2,nil) }

    assert_raise(ArgumentError) { @t.new([1,1,2]) }
    assert_raise(ArgumentError) { @t.new(1,1,2,2) }
  end

end

end; end
