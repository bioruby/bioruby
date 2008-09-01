#
# test/unit/bio/util/restriction_enzyme/double_stranded/test_cut_locations_in_enzyme_notation.rb - Unit test for Bio::RestrictionEnzyme::DoubleStranded::CutLocationsInEnzymeNotation
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
require 'bio/util/restriction_enzyme/double_stranded/cut_locations_in_enzyme_notation'

module Bio; module TestRestrictionEnzyme #:nodoc:

class TestDoubleStrandedCutLocationsInEnzymeNotation < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::DoubleStranded::CutLocationPairInEnzymeNotation
    @tt = Bio::RestrictionEnzyme::DoubleStranded::CutLocationsInEnzymeNotation

    @obj_1 = @t.new([3,5])
    @obj_2 = @t.new(3, 5)
    @obj_3 = @t.new((3..5))
    @obj_4 = @t.new(-3..5)
    @obj_5 = @t.new(3)
    @obj_6 = @t.new(nil,3)
    @obj_7 = @t.new(3,nil)
    @obj_8 = @t.new(-8, -7)

    @locations = @tt.new(@obj_1, @obj_2, @obj_3, @obj_4, @obj_5, @obj_6, @obj_7, @obj_8)
    @loc_2 = @tt.new(@t.new(-2,-2), @t.new(1,1))
    @loc_3 = @tt.new(@t.new(1,2))
  end

  def test_contents
    assert_equal([3,5], @locations[0])
    assert_equal([3,nil], @locations[-2])
  end

  def test_primary
    assert_equal([3, 3, 3, -3, 3, nil, 3, -8], @locations.primary)
  end

  def test_complement
    assert_equal([5, 5, 5, 5, nil, 3, nil, -7], @locations.complement)
  end

  def test_primary_to_array_index
    assert_equal([10, 10, 10, 5, 10, nil, 10, 0], @locations.primary_to_array_index)
    assert_equal([0,2], @loc_2.primary_to_array_index)
    assert_equal([0], @loc_3.primary_to_array_index)
  end

  def test_primary_to_array_index_class
    assert_equal(Array, @locations.primary_to_array_index.class)
    assert_equal(Array, @loc_2.primary_to_array_index.class)
  end

  def test_complement_to_array_index
    assert_equal([12, 12, 12, 12, nil, 10, nil, 1], @locations.complement_to_array_index)
    assert_equal([0,2], @loc_2.complement_to_array_index)
    assert_equal([1], @loc_3.complement_to_array_index)
  end

  def test_complement_to_array_index_class
    assert_equal(Array, @locations.complement_to_array_index.class)
    assert_equal(Array, @loc_2.complement_to_array_index.class)
  end

  def test_to_array_index
    assert_equal(
      [
        [10, 12],
        [10, 12],
        [10, 12],
        [5, 12],
        [10, nil],
        [nil, 10],
        [10, nil],
        [0, 1]
      ], @locations.to_array_index)

    assert_equal(
      [
        [0, 0],
        [2, 2],
      ], @loc_2.to_array_index)

    assert_equal([[0,1]], @loc_3.to_array_index)
  end

  def test_to_array_index_class
    assert_equal(Bio::RestrictionEnzyme::DoubleStranded::CutLocations, @locations.to_array_index.class)
    assert_equal(Bio::RestrictionEnzyme::DoubleStranded::CutLocations, @loc_2.to_array_index.class)
  end

end

end; end
