#
# test/unit/bio/util/restriction_enzyme/analysis/test_sequence_range.rb - Unit test for Bio::RestrictionEnzyme::Analysis::SequenceRange
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: test_sequence_range.rb,v 1.4 2007/04/05 23:35:44 trevor Exp $
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

module Bio #:nodoc:

class TestAnalysisSequenceRange < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme::Range::SequenceRange
    @fs = Bio::RestrictionEnzyme::Range::SequenceRange::Fragments
    #a.add_cut_range(p_cut_left, p_cut_right, c_cut_left, c_cut_right )

    @vcr = Bio::RestrictionEnzyme::Range::VerticalCutRange
    @crs = Bio::RestrictionEnzyme::Range::CutRanges
    @hcr = Bio::RestrictionEnzyme::Range::HorizontalCutRange

    @obj_1 = @t.new(0,5)
    @obj_1.add_cut_range(0,nil,nil,3)
    @obj_1.add_cut_range(nil,2,nil,nil)

    @obj_2 = @t.new(0,5)
    @obj_2.add_cut_ranges( @crs.new( [@vcr.new(0,2,nil,nil), @vcr.new(3,nil,4,nil)] ))

    @obj_3 = @t.new(0,5)
    @obj_3.add_cut_ranges( @crs.new( [@vcr.new(0,2,nil,nil), @vcr.new(3,nil,4,nil)] ))
    @obj_3.add_cut_ranges( @crs.new( [@hcr.new(0), @hcr.new(5)] ))

    @obj_4 = @t.new(0,5)
    @obj_4.add_cut_ranges( @crs.new( [@vcr.new(0,2,1,3)] ))

    @obj_5 = @t.new(0,5)
    @obj_5.add_cut_ranges( @crs.new( [@vcr.new(0,nil,nil,nil), @vcr.new(nil,4,3,nil), @hcr.new(1,2)] ))

    @obj_6 = @t.new(0,5)
    @obj_6.add_cut_ranges( @crs.new( [@vcr.new(nil,nil,0,nil), @hcr.new(1,2), @vcr.new(nil,4,3,nil)] ))

    @obj_7 = @t.new(0,5)
    @obj_7.add_cut_ranges( @crs.new( [@vcr.new(nil,2,nil,nil), @hcr.new(0,2)] ))

    @obj_8 = @t.new(0,11)
    @obj_8.add_cut_ranges( @crs.new( [@hcr.new(0,1), @vcr.new(nil,nil,nil,5), @hcr.new(7,8), @hcr.new(10), @vcr.new(nil,10,nil,nil)] ))

    @obj_9 = @t.new(0,5)
    @obj_9.add_cut_ranges( @crs.new( [@vcr.new(nil,3,nil,3)] ))

    @obj_10 = @t.new(0,5)
    @obj_10.add_cut_ranges( @crs.new( [@vcr.new(0,nil,nil,3), @vcr.new(nil,2,nil,2)] ))
  end

  def test_fragments
    assert_equal(@fs, @obj_1.fragments.class)
  end

  # '0|1 2|3 4 5'
  # ' +---+-+   '
  # '0 1 2 3|4 5'
  def test_fragments_for_display_1
    x = @obj_1
    assert_equal(3, x.fragments.for_display.size)

    assert_equal('0   ', x.fragments.for_display[0].primary)
    assert_equal('0123', x.fragments.for_display[0].complement)

    assert_equal('12', x.fragments.for_display[1].primary)
    assert_equal('  ', x.fragments.for_display[1].complement)

    assert_equal('345', x.fragments.for_display[2].primary)
    assert_equal(' 45', x.fragments.for_display[2].complement)
  end

  # '0|1 2|3|4 5'
  # ' +---+ +-+ '
  # '0 1 2 3 4|5'
  def test_fragments_for_display_2
    x = @obj_2
    assert_equal(3, x.fragments.for_display.size)

    assert_equal('0  3 ', x.fragments.for_display[0].primary)
    assert_equal('01234', x.fragments.for_display[0].complement)

    assert_equal('12', x.fragments.for_display[1].primary)
    assert_equal('  ', x.fragments.for_display[1].complement)

    assert_equal('45', x.fragments.for_display[2].primary)
    assert_equal(' 5', x.fragments.for_display[2].complement)
  end

  # '0|1 2|3|4 5'
  # '-+---+ +-+-'
  # '0 1 2 3 4|5'
  def test_fragments_for_display_3
    x = @obj_3
    assert_equal(5, x.fragments.for_display.size)

    assert_equal('0', x.fragments.for_display[0].primary)
    assert_equal(' ', x.fragments.for_display[0].complement)

    assert_equal('   3 ', x.fragments.for_display[1].primary)
    assert_equal('01234', x.fragments.for_display[1].complement)

    assert_equal('12', x.fragments.for_display[2].primary)
    assert_equal('  ', x.fragments.for_display[2].complement)

    assert_equal('45', x.fragments.for_display[3].primary)
    assert_equal('  ', x.fragments.for_display[3].complement)

    assert_equal(' ', x.fragments.for_display[4].primary)
    assert_equal('5', x.fragments.for_display[4].complement)
  end

  # '0|1 2|3 4 5'
  # ' +-+-+-+   '
  # '0 1|2 3|4 5'
  def test_fragments_for_display_4
    x = @obj_4
    assert_equal(4, x.fragments.for_display.size)

    assert_equal('0 ', x.fragments.for_display[0].primary)
    assert_equal('01', x.fragments.for_display[0].complement)

    assert_equal('12', x.fragments.for_display[1].primary)
    assert_equal('  ', x.fragments.for_display[1].complement)

    assert_equal('  ', x.fragments.for_display[2].primary)
    assert_equal('23', x.fragments.for_display[2].complement)

    assert_equal('345', x.fragments.for_display[3].primary)
    assert_equal(' 45', x.fragments.for_display[3].complement)
  end

  # '0 1 2 3 4|5'
  # '       +-+ '
  # '0 1 2 3|4 5'
  def test_fragments_for_display_5
    x = @obj_5
    assert_equal(2, x.fragments.for_display.size)

    assert_equal('01234', x.fragments.for_display[0].primary)
    assert_equal('0123 ', x.fragments.for_display[0].complement)

    assert_equal(' 5', x.fragments.for_display[1].primary)
    assert_equal('45', x.fragments.for_display[1].complement)
  end

  # '0 1 2 3 4|5'
  # '       +-+ '
  # '0 1 2 3|4 5'
  def test_fragments_for_display_6
    x = @obj_6
    assert_equal(2, x.fragments.for_display.size)

    assert_equal('01234', x.fragments.for_display[0].primary)
    assert_equal('0123 ', x.fragments.for_display[0].complement)

    assert_equal(' 5', x.fragments.for_display[1].primary)
    assert_equal('45', x.fragments.for_display[1].complement)
  end

  # '0 1 2|3 4 5'
  # '-----+     '
  # '0 1 2 3 4 5'
  def test_fragments_for_display_7
    x = @obj_7
    assert_equal(2, x.fragments.for_display.size)

    assert_equal('012', x.fragments.for_display[0].primary)
    assert_equal('   ', x.fragments.for_display[0].complement)

    assert_equal('   345', x.fragments.for_display[1].primary)
    assert_equal('012345', x.fragments.for_display[1].complement)
  end


  # '0 1 2 3 4 5 6 7 8 9 0 1'
  # '                       '
  # '0 1 2 3 4 5 6 7 8 9 0 1'
  def test_fragments_for_display_8
    x = @obj_8
    assert_equal(1, x.fragments.for_display.size)

    assert_equal('012345678901', x.fragments.for_display[0].primary)
    assert_equal('012345678901', x.fragments.for_display[0].complement)
  end

  # '0 1 2 3|4 5'
  # '       +   '
  # '0 1 2 3|4 5'
  def test_fragments_for_display_9
    x = @obj_9
    assert_equal(2, x.fragments.for_display.size)

    assert_equal('0123', x.fragments.for_display[0].primary)
    assert_equal('0123', x.fragments.for_display[0].complement)

    assert_equal('45', x.fragments.for_display[1].primary)
    assert_equal('45', x.fragments.for_display[1].complement)
  end

  # '0|1 2|3 4 5'
  # ' +---+-+   '
  # '0 1 2|3|4 5'
  def test_fragments_for_display_10
    x = @obj_10
    assert_equal(4, x.fragments.for_display.size)

    assert_equal('0  ', x.fragments.for_display[0].primary)
    assert_equal('012', x.fragments.for_display[0].complement)

    assert_equal('12', x.fragments.for_display[1].primary)
    assert_equal('  ', x.fragments.for_display[1].complement)

    assert_equal('345', x.fragments.for_display[2].primary)
    assert_equal(' 45', x.fragments.for_display[2].complement)

    assert_equal(' ', x.fragments.for_display[3].primary)
    assert_equal('3', x.fragments.for_display[3].complement)
  end

end
end
