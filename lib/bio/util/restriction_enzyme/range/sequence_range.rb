#
# bio/util/restrction_enzyme/range/sequence_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: sequence_range.rb,v 1.2 2007/01/05 06:03:22 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/range/cut_ranges'
require 'bio/util/restriction_enzyme/range/horizontal_cut_range'
require 'bio/util/restriction_enzyme/range/vertical_cut_range'
require 'bio/util/restriction_enzyme/range/sequence_range/calculated_cuts'
require 'bio/util/restriction_enzyme/range/sequence_range/fragments'
require 'bio/util/restriction_enzyme/range/sequence_range/fragment'
require 'bio'

module Bio; end
class Bio::RestrictionEnzyme
class Range
#
# bio/util/restrction_enzyme/range/sequence_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
# FIXME algorithm heavy, needs better docs
class SequenceRange

  attr_reader :p_left, :p_right
  attr_reader :c_left, :c_right

  attr_reader :left, :right
  attr_reader :size
  attr_reader :cut_ranges

  def initialize( p_left = nil, p_right = nil, c_left = nil, c_right = nil )
    @__fragments_current = false
    raise ArgumentError if p_left == nil and c_left == nil
    raise ArgumentError if p_right == nil and c_right == nil
    (raise ArgumentError unless p_left <= p_right) unless p_left == nil or p_right == nil
    (raise ArgumentError unless c_left <= c_right) unless c_left == nil or c_right == nil

    @p_left  = p_left
    @p_right = p_right
    @c_left  = c_left
    @c_right = c_right

    tmp = [p_left, c_left]
    tmp.delete(nil)
    @left = tmp.sort.first

    tmp = [p_right, c_right]
    tmp.delete(nil)
    @right = tmp.sort.last

    @size = (@right - @left) + 1 unless @left == nil or @right == nil

    @cut_ranges = CutRanges.new
  end

  # NOTE Special Case: Horizontal cuts at beginning or end of strand

  Bin = Struct.new(:c, :p)

  def fragments
    return @__fragments if @__fragments_current == true
    @__fragments_current = true

    cc = Bio::RestrictionEnzyme::Range::SequenceRange::CalculatedCuts.new(@size)
    cc.add_cuts_from_cut_ranges(@cut_ranges)
    cc.remove_incomplete_cuts

    p_cut = cc.vc_primary
    c_cut = cc.vc_complement
    h = cc.hc_between_strands 

    if @circular
    # NOTE
    # if it's circular we should start at the beginning of a cut for orientation
    # scan for it, hack off the first set of hcuts and move them to the back
    else
      p_cut.unshift(-1) unless p_cut.include?(-1)
      c_cut.unshift(-1) unless c_cut.include?(-1)
    end

    if @circular
      largest_bin = 0
    else
      largest_bin = -1
    end
    p_bin = largest_bin
    c_bin = largest_bin
    bins = { largest_bin => Bin.new }  # bin_id, bin
    bins[ largest_bin ].p = []
    bins[ largest_bin ].c = []

    x = lambda do |bin_id|
      largest_bin += 1
      bins[ bin_id ] = Bin.new
      bins[ bin_id ].p = []
      bins[ bin_id ].c = []
    end

    -1.upto(@size-1) do |idx|
      # if bins are out of sync but the strands are attached
      if p_bin != c_bin and h.include?(idx) == false
        bins.delete( [p_bin, c_bin].sort.last )
        p_bin = c_bin = [p_bin, c_bin].sort.first
        largest_bin -= 1
      end

      bins[ p_bin ].p << idx
      bins[ c_bin ].c << idx

      if p_cut.include? idx
        p_bin = largest_bin + 1
        x.call(p_bin)
      end

      if c_cut.include? idx
        c_bin = largest_bin + 1
        x.call(c_bin)
      end
    end

    # Easy way to indicate the start of a strand just in case
    # there is a horizontal cut at position 0
    bins.delete(-1) unless @circular

    str1 = nil
    str2 = nil

    num_txt_repeat = lambda { num_txt = '0123456789'; (num_txt * ( @size / num_txt.size.to_f ).ceil)[0..@size-1] }
    (str1 == nil) ? a = num_txt_repeat.call : a = str1.dup
    (str2 == nil) ? b = num_txt_repeat.call : b = str2.dup

    fragments = Fragments.new(a,b)

    bins.sort.each do |k, bin|
      fragment = Fragment.new( bin.p, bin.c )
      fragments << fragment
    end

    @__fragments = fragments
    return fragments
  end

# Cut occurs immediately after the index supplied.
# For example, a cut at '0' would mean a cut occurs between 0 and 1.
  def add_cut_range( p_cut_left=nil, p_cut_right=nil, c_cut_left=nil, c_cut_right=nil )
    @__fragments_current = false

    if p_cut_left.kind_of? CutRange
      @cut_ranges << p_cut_left
    else
      (raise IndexError unless p_cut_left >= @left and p_cut_left <= @right) unless p_cut_left == nil
      (raise IndexError unless p_cut_right >= @left and p_cut_right <= @right) unless p_cut_right == nil
      (raise IndexError unless c_cut_left >= @left and c_cut_left <= @right) unless c_cut_left == nil
      (raise IndexError unless c_cut_right >= @left and c_cut_right <= @right) unless c_cut_right == nil

      @cut_ranges << VerticalCutRange.new( p_cut_left, p_cut_right, c_cut_left, c_cut_right )
    end
  end

  def add_cut_ranges(*cut_ranges)
    cut_ranges.flatten!
    cut_ranges.each do |cut_range|
      raise TypeError, "Not of type CutRange" unless cut_range.kind_of? CutRange
      self.add_cut_range( cut_range )
    end
  end

  def add_horizontal_cut_range( left, right=left )
    @__fragments_current = false
    @cut_ranges << HorizontalCutRange.new( left, right )
  end
end # SequenceRange
end # Range
end # Bio::RestrictionEnzyme