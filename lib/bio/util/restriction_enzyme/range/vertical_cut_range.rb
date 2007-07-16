#
# bio/util/restriction_enzyme/range/vertical_cut_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: vertical_cut_range.rb,v 1.5 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme
class Range

# FIXME docs are kind of out of date.  Change this to VerticalAndHorizontalCutRange
class VerticalCutRange < CutRange
  attr_reader :p_cut_left, :p_cut_right
  attr_reader :c_cut_left, :c_cut_right
  attr_reader :min, :max
  attr_reader :range

  # VerticalCutRange provides an extremely raw, yet precise, method of
  # defining the location of cuts on primary and complementary sequences.
  #
  # Many VerticalCutRange objects are used with HorizontalCutRange objects
  # to be contained in CutRanges to define the cut pattern that a
  # specific enzyme may make.
  #
  # VerticalCutRange takes up to four possible cuts, two on the primary
  # strand and two on the complementary strand.  In typical usage
  # you will want to make a single cut on the primary strand and a single
  # cut on the complementary strand.
  #
  # However, you can construct it with whatever cuts you desire to accomadate
  # the most eccentric of imaginary restriction enzymes.
  #
  # ---
  # *Arguments*
  # * +p_cut_left+: (_optional_) Left-most cut on the primary strand.  +nil+ to skip
  # * +p_cut_right+: (_optional_) Right-most cut on the primary strand.  +nil+ to skip
  # * +c_cut_left+: (_optional_) Left-most cut on the complementary strand.  +nil+ to skip
  # * +c_cut_right+: (_optional_) Right-most cut on the complementary strand.  +nil+ to skip
  # *Returns*:: nothing
  def initialize( p_cut_left=nil, p_cut_right=nil, c_cut_left=nil, c_cut_right=nil )
    @p_cut_left = p_cut_left
    @p_cut_right = p_cut_right
    @c_cut_left = c_cut_left
    @c_cut_right = c_cut_right

    a = [@p_cut_left, @c_cut_left, @p_cut_right, @c_cut_right]
    a.delete(nil)
    a.sort!
    @min = a.first
    @max = a.last

    @range = nil
    @range = (@min..@max) unless @min == nil or @max == nil
    return
  end

  # Check if a location falls within the minimum or maximum values of this
  # range.
  #
  # ---
  # *Arguments*
  # * +i+: Location to check if it is included in the range
  # *Returns*:: +true+ _or_ +false+
  def include?(i)
    return false if @range == nil
    @range.include?(i)
  end
end # VerticalCutRange
end # Range
end # RestrictionEnzyme
end # Bio
