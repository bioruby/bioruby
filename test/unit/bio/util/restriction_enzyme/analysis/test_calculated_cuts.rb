#
# test/unit/bio/util/restriction_enzyme/analysis/test_calculated_cuts.rb - Unit test for Bio::RestrictionEnzyme::Analysis::CalculatedCuts
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
require 'bio/util/restriction_enzyme/range/sequence_range/calculated_cuts'
require 'bio/util/restriction_enzyme/range/cut_range'
require 'bio/util/restriction_enzyme/range/cut_ranges'
require 'bio/util/restriction_enzyme/range/horizontal_cut_range'
require 'bio/util/restriction_enzyme/range/vertical_cut_range'

module Bio; module TestRestrictionEnzyme #:nodoc:

class TestAnalysisCalculatedCuts < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::Range::SequenceRange::CalculatedCuts
    @vcr = Bio::RestrictionEnzyme::Range::VerticalCutRange
    @crs = Bio::RestrictionEnzyme::Range::CutRanges
    @hcr = Bio::RestrictionEnzyme::Range::HorizontalCutRange

    #a.add_cut_range(p_cut_left, p_cut_right, c_cut_left, c_cut_right )

    @obj_1 = @t.new(6)
    @obj_1.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(0,nil,nil,3), @vcr.new(nil,2,nil,nil)] ))
    @obj_1b = @obj_1.dup
    @obj_1b.remove_incomplete_cuts

    @obj_2 = @t.new(6)
    @obj_2.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(0,2,nil,nil), @vcr.new(3,nil,4,nil)] ))
    @obj_2b = @obj_2.dup
    @obj_2b.remove_incomplete_cuts

    @obj_3 = @t.new(6)
    @obj_3.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(0,2,nil,nil), @vcr.new(3,nil,4,nil)] ))
    @obj_3.add_cuts_from_cut_ranges( @crs.new( [@hcr.new(0), @hcr.new(5)] ))
    @obj_3b = @obj_3.dup
    @obj_3b.remove_incomplete_cuts

    @obj_4 = @t.new(6)
    @obj_4.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(0,2,1,3)] ))
    @obj_4b = @obj_4.dup
    @obj_4b.remove_incomplete_cuts

    # Same thing, declared a different way
    @obj_4_c1 = @t.new(6)
    @obj_4_c1.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(nil,nil,1,3), @vcr.new(0,2,nil,nil)] ))
    @obj_4b_c1 = @obj_4_c1.dup
    @obj_4b_c1.remove_incomplete_cuts

    # Same thing, declared a different way
    @obj_4_c2 = @t.new(6)
    @obj_4_c2.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(0,nil,nil,3), @vcr.new(nil,2,1,nil)] ))
    @obj_4b_c2 = @obj_4_c2.dup
    @obj_4b_c2.remove_incomplete_cuts

    @obj_5 = @t.new(6)
    @obj_5.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(0,nil,nil,nil), @vcr.new(nil,4,3,nil), @hcr.new(1,2)] ))
    @obj_5b = @obj_5.dup
    @obj_5b.remove_incomplete_cuts

    @obj_6 = @t.new(6)
    @obj_6.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(nil,nil,0,nil), @hcr.new(1,2), @vcr.new(nil,4,3,nil)] ))
    @obj_6b = @obj_6.dup
    @obj_6b.remove_incomplete_cuts

    @obj_7 = @t.new(6)
    @obj_7.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(nil,2,nil,nil), @hcr.new(0,2)] ))
    @obj_7b = @obj_7.dup
    @obj_7b.remove_incomplete_cuts

    @obj_8 = @t.new(12)
    @obj_8.add_cuts_from_cut_ranges( @crs.new( [@hcr.new(0,1), @vcr.new(nil,nil,nil,5), @hcr.new(7,8), @hcr.new(10), @vcr.new(nil,10,nil,nil)] ))
    @obj_8b = @obj_8.dup
    @obj_8b.remove_incomplete_cuts

    @obj_9 = @t.new(6)
    @obj_9.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(nil,3,nil,3)] ))
    @obj_9b = @obj_9.dup
    @obj_9b.remove_incomplete_cuts

    @obj_10 = @t.new(6)
    @obj_10.add_cuts_from_cut_ranges( @crs.new( [@vcr.new(0,nil,nil,3), @vcr.new(nil,2,nil,2)] ))
    @obj_10b = @obj_10.dup
    @obj_10b.remove_incomplete_cuts


  end

  def test_cuts
    x = @obj_1
    assert_equal([0,2], x.vc_primary)
    assert_equal([3], x.vc_complement)
    assert_equal([1,2,3], x.hc_between_strands)

    x = @obj_2
    assert_equal([0,2,3], x.vc_primary)
    assert_equal([4], x.vc_complement)
    assert_equal([1,2,4], x.hc_between_strands)

    x = @obj_3
    assert_equal([0,2,3], x.vc_primary)
    assert_equal([4], x.vc_complement)
    assert_equal([0,1,2,4,5], x.hc_between_strands)

    x = @obj_4
    assert_equal([0,2], x.vc_primary)
    assert_equal([1,3], x.vc_complement)
    assert_equal([1,2,3], x.hc_between_strands)

    x = @obj_4_c1
    assert_equal([0,2], x.vc_primary)
    assert_equal([1,3], x.vc_complement)
    assert_equal([1,2,3], x.hc_between_strands)

    x = @obj_4_c2
    assert_equal([0,2], x.vc_primary)
    assert_equal([1,3], x.vc_complement)
    assert_equal([1,2,3], x.hc_between_strands)

    x = @obj_5
    assert_equal([0,4], x.vc_primary)
    assert_equal([3], x.vc_complement)
    assert_equal([1,2,4], x.hc_between_strands)

    x = @obj_6
    assert_equal([4], x.vc_primary)
    assert_equal([0,3], x.vc_complement)
    assert_equal([1,2,4], x.hc_between_strands)

    x = @obj_7
    assert_equal([2], x.vc_primary)
    assert_equal([], x.vc_complement)
    assert_equal([0,1,2], x.hc_between_strands)

    x = @obj_8
    assert_equal([10], x.vc_primary)
    assert_equal([5], x.vc_complement)
    assert_equal([0,1,7,8,10], x.hc_between_strands)

    x = @obj_9
    assert_equal([3], x.vc_primary)
    assert_equal([3], x.vc_complement)
    assert_equal([], x.hc_between_strands)

    x = @obj_10
    assert_equal([0,2], x.vc_primary)
    assert_equal([2,3], x.vc_complement)
    assert_equal([1,2,3], x.hc_between_strands)
  end

  def test_cuts_after_remove_incomplete_cuts
    x = @obj_1b
    assert_equal([0,2], x.vc_primary)
    assert_equal([3], x.vc_complement)
    assert_equal([1,2,3], x.hc_between_strands)
  end

  def test_strands_for_display_current
  #check object_id
  end

  def test_strands_for_display
    x = @obj_1
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +---+-+   ', x.strands_for_display[1])
    assert_equal('0 1 2 3|4 5', x.strands_for_display[2])

    x = @obj_1b
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +---+-+   ', x.strands_for_display[1])
    assert_equal('0 1 2 3|4 5', x.strands_for_display[2])

    x = @obj_2
    assert_equal('0|1 2|3|4 5', x.strands_for_display[0])
    assert_equal(' +---+ +-+ ', x.strands_for_display[1])
    assert_equal('0 1 2 3 4|5', x.strands_for_display[2])

    x = @obj_2b
    assert_equal('0|1 2|3|4 5', x.strands_for_display[0])
    assert_equal(' +---+ +-+ ', x.strands_for_display[1])
    assert_equal('0 1 2 3 4|5', x.strands_for_display[2])

    x = @obj_3
    assert_equal('0|1 2|3|4 5', x.strands_for_display[0])
    assert_equal('-+---+ +-+-', x.strands_for_display[1])
    assert_equal('0 1 2 3 4|5', x.strands_for_display[2])

    x = @obj_3b
    assert_equal('0|1 2|3|4 5', x.strands_for_display[0])
    assert_equal('-+---+ +-+-', x.strands_for_display[1])
    assert_equal('0 1 2 3 4|5', x.strands_for_display[2])

    x = @obj_4
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +-+-+-+   ', x.strands_for_display[1])
    assert_equal('0 1|2 3|4 5', x.strands_for_display[2])

    x = @obj_4b
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +-+-+-+   ', x.strands_for_display[1])
    assert_equal('0 1|2 3|4 5', x.strands_for_display[2])

    x = @obj_4_c1
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +-+-+-+   ', x.strands_for_display[1])
    assert_equal('0 1|2 3|4 5', x.strands_for_display[2])

    x = @obj_4b_c1
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +-+-+-+   ', x.strands_for_display[1])
    assert_equal('0 1|2 3|4 5', x.strands_for_display[2])

    x = @obj_4_c2
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +-+-+-+   ', x.strands_for_display[1])
    assert_equal('0 1|2 3|4 5', x.strands_for_display[2])

    x = @obj_4b_c2
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +-+-+-+   ', x.strands_for_display[1])
    assert_equal('0 1|2 3|4 5', x.strands_for_display[2])

    x = @obj_5
    assert_equal('0|1 2 3 4|5', x.strands_for_display[0])
    assert_equal(' +---  +-+ ', x.strands_for_display[1])
    assert_equal('0 1 2 3|4 5', x.strands_for_display[2])

    x = @obj_5b
    assert_equal('0 1 2 3 4|5', x.strands_for_display[0])
    assert_equal('       +-+ ', x.strands_for_display[1])
    assert_equal('0 1 2 3|4 5', x.strands_for_display[2])

    x = @obj_6
    assert_equal('0 1 2 3 4|5', x.strands_for_display[0])
    assert_equal(' +---  +-+ ', x.strands_for_display[1])
    assert_equal('0|1 2 3|4 5', x.strands_for_display[2])

    x = @obj_6b
    assert_equal('0 1 2 3 4|5', x.strands_for_display[0])
    assert_equal('       +-+ ', x.strands_for_display[1])
    assert_equal('0 1 2 3|4 5', x.strands_for_display[2])

    x = @obj_7
    assert_equal('0 1 2|3 4 5', x.strands_for_display[0])
    assert_equal('-----+     ', x.strands_for_display[1])
    assert_equal('0 1 2 3 4 5', x.strands_for_display[2])

    x = @obj_7b
    assert_equal('0 1 2|3 4 5', x.strands_for_display[0])
    assert_equal('-----+     ', x.strands_for_display[1])
    assert_equal('0 1 2 3 4 5', x.strands_for_display[2])

    x = @obj_8
    assert_equal('0 1 2 3 4 5 6 7 8 9 0|1', x.strands_for_display[0])
    assert_equal('---        +  ---   -+ ', x.strands_for_display[1])
    assert_equal('0 1 2 3 4 5|6 7 8 9 0 1', x.strands_for_display[2])

    x = @obj_8b
    assert_equal('0 1 2 3 4 5 6 7 8 9 0 1', x.strands_for_display[0])
    assert_equal('                       ', x.strands_for_display[1])
    assert_equal('0 1 2 3 4 5 6 7 8 9 0 1', x.strands_for_display[2])

    x = @obj_9
    assert_equal('0 1 2 3|4 5', x.strands_for_display[0])
    assert_equal('       +   ', x.strands_for_display[1])
    assert_equal('0 1 2 3|4 5', x.strands_for_display[2])

    x = @obj_9b
    assert_equal('0 1 2 3|4 5', x.strands_for_display[0])
    assert_equal('       +   ', x.strands_for_display[1])
    assert_equal('0 1 2 3|4 5', x.strands_for_display[2])

    x = @obj_10
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +---+-+   ', x.strands_for_display[1])
    assert_equal('0 1 2|3|4 5', x.strands_for_display[2])

    x = @obj_10b
    assert_equal('0|1 2|3 4 5', x.strands_for_display[0])
    assert_equal(' +---+-+   ', x.strands_for_display[1])
    assert_equal('0 1 2|3|4 5', x.strands_for_display[2])

  end


end

end; end
