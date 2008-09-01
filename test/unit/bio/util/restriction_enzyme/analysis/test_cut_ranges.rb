#
# test/unit/bio/util/restriction_enzyme/analysis/test_cut_ranges.rb - Unit test for Bio::RestrictionEnzyme::Analysis::SequenceRange
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
require 'bio/util/restriction_enzyme/range/sequence_range'
require 'bio/util/restriction_enzyme/range/sequence_range/fragments'

require 'bio/util/restriction_enzyme/range/cut_range'
require 'bio/util/restriction_enzyme/range/horizontal_cut_range'
require 'bio/util/restriction_enzyme/range/vertical_cut_range'
require 'bio/util/restriction_enzyme/range/cut_ranges'

module Bio; module TestRestrictionEnzyme #:nodoc:

class TestCutRanges < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::Range::SequenceRange
    @fs = Bio::RestrictionEnzyme::Range::SequenceRange::Fragments
    #a.add_cut_range(p_cut_left, p_cut_right, c_cut_left, c_cut_right )

    @vcr = Bio::RestrictionEnzyme::Range::VerticalCutRange
    @crs = Bio::RestrictionEnzyme::Range::CutRanges
    @hcr = Bio::RestrictionEnzyme::Range::HorizontalCutRange
    
    @obj_2 = @crs.new( [@vcr.new(0,2,nil,nil), @vcr.new(3,nil,4,nil)] )
    @obj_3 = @crs.new( [@vcr.new(0,2,nil,nil), @vcr.new(3,nil,4,nil), @hcr.new(0), @hcr.new(5)] )
    @obj_7 = @crs.new( [@vcr.new(nil,2,nil,nil), @hcr.new(0,2)] )
    @obj_z = @crs.new( [@vcr.new(nil,2,nil,5), @hcr.new(1,6)] )
  end
  
  def test_obj_z
    assert_equal(6, @obj_z.max)
    assert_equal(1, @obj_z.min)

    assert_equal(2, @obj_z.min_vertical)
    assert_equal(5, @obj_z.max_vertical)
    
    assert_equal(true, @obj_z.include?(6))
    assert_equal(true, @obj_z.include?(4))
    assert_equal(true, @obj_z.include?(2))
    assert_equal(false, @obj_z.include?(-1))
    assert_equal(false, @obj_z.include?(0))
    assert_equal(false, @obj_z.include?(7))  
  end
  
  def test_obj_7
    assert_equal(2, @obj_7.max)
    assert_equal(0, @obj_7.min)

    assert_equal(2, @obj_7.min_vertical)
    assert_equal(2, @obj_7.max_vertical)
    
    assert_equal(true, @obj_7.include?(0))
    assert_equal(true, @obj_7.include?(1))
    assert_equal(true, @obj_7.include?(2))
    assert_equal(false, @obj_7.include?(-1))
    assert_equal(false, @obj_7.include?(3))  
  end
  
  def test_obj_2
    assert_equal(4, @obj_2.max)
    assert_equal(0, @obj_2.min)
    
    assert_equal(0, @obj_2.min_vertical)
    assert_equal(4, @obj_2.max_vertical)
    
    assert_equal(true, @obj_2.include?(0))
    assert_equal(true, @obj_2.include?(1))
    assert_equal(true, @obj_2.include?(3))
    assert_equal(true, @obj_2.include?(4))
    assert_equal(false, @obj_2.include?(-1))
    assert_equal(false, @obj_2.include?(5))  
  end
  
  def test_obj_3
    assert_equal(5, @obj_3.max)
    assert_equal(0, @obj_3.min)
    
    assert_equal(0, @obj_3.min_vertical)
    assert_equal(4, @obj_3.max_vertical)
    
    assert_equal(true, @obj_3.include?(0))
    assert_equal(true, @obj_3.include?(1))
    assert_equal(true, @obj_3.include?(3))
    assert_equal(true, @obj_3.include?(4))
    assert_equal(true, @obj_3.include?(5))  
    assert_equal(false, @obj_3.include?(-1))
    assert_equal(false, @obj_3.include?(6))  
  end
end
end; end
