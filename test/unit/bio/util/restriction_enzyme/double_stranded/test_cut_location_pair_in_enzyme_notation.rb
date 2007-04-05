#
# test/unit/bio/util/restriction_enzyme/double_stranded/test_cut_location_pair_in_enzyme_notation.rb - Unit test for Bio::RestrictionEnzyme::DoubleStranded::CutLocationPairInEnzymeNotation
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: test_cut_location_pair_in_enzyme_notation.rb,v 1.3 2007/04/05 23:35:44 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 6, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation'

module Bio #:nodoc:

class TestDoubleStrandedCutLocationPairInEnzymeNotation < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::DoubleStranded::CutLocationPairInEnzymeNotation

    @obj_1 = @t.new([3,5])
    @obj_2 = @t.new(3, 5)
    @obj_3 = @t.new((3..5))
    @obj_4 = @t.new(-3..5)
    @obj_5 = @t.new(3)
    @obj_6 = @t.new(nil,3)
    @obj_7 = @t.new(3,nil)
  end

  def test_contents
    assert_equal([3,5], @obj_1)
    assert_equal([3,5], @obj_2)
    assert_equal([3,5], @obj_3)
    assert_equal([-3,5], @obj_4)
    assert_equal([3,nil], @obj_5)
    assert_equal([nil,3], @obj_6)
    assert_equal([3,nil], @obj_7)
  end

  def test_primary
    assert_equal(3, @obj_1.primary)
    assert_equal(3, @obj_2.primary)
    assert_equal(3, @obj_3.primary)
    assert_equal(-3, @obj_4.primary)
    assert_equal(3, @obj_5.primary)
    assert_equal(nil, @obj_6.primary)
    assert_equal(3, @obj_7.primary)
  end

  def test_complement
    assert_equal(5, @obj_1.complement)
    assert_equal(5, @obj_2.complement)
    assert_equal(5, @obj_3.complement)
    assert_equal(5, @obj_4.complement)
    assert_equal(nil, @obj_5.complement)
    assert_equal(3, @obj_6.complement)
    assert_equal(nil, @obj_7.complement)
  end

  def test_argument_error
    assert_raise(ArgumentError) { @t.new([3,5,6]) }
    assert_raise(ArgumentError) { @t.new(0,1) }
    assert_raise(ArgumentError) { @t.new(0,0) }
    assert_raise(ArgumentError) { @t.new('3',5) }
  end

end

end
