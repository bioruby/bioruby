#
# bio/util/restriction_enzyme/range/horizontal_cut_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: horizontal_cut_range.rb,v 1.5 2007/07/16 19:28:48 k Exp $
#

require 'bio/util/restriction_enzyme'

module Bio
class RestrictionEnzyme
class Range

class HorizontalCutRange < CutRange
  attr_reader :p_cut_left, :p_cut_right
  attr_reader :c_cut_left, :c_cut_right
  attr_reader :min, :max
  attr_reader :hcuts

  def initialize( left, right=left )
    raise "left > right" if left > right

    # The 'range' here is actually off by one on the left
    # side in relation to a normal CutRange, so using the normal
    # variables from CutRange would result in bad behavior.
    #
    # See below - the first horizontal cut is the primary cut plus one.
    #
    #    1 2 3 4 5 6 7
    #    G A|T T A C A
    #       +-----+
    #    C T A A T|G T
    #    1 2 3 4 5 6 7
    # 
    # Primary cut = 2
    # Complement cut = 5
    # Horizontal cuts = 3, 4, 5

    @p_cut_left = nil
    @p_cut_right = nil
    @c_cut_left = nil
    @c_cut_right = nil
    @min = left  # NOTE this used to be 'nil', make sure all tests work
    @max = right # NOTE this used to be 'nil', make sure all tests work
    @range = (@min..@max) unless @min == nil or @max == nil # NOTE this used to be 'nil', make sure all tests work
    

    @hcuts = (left..right)
  end

  # Check if a location falls within the minimum or maximum values of this
  # range.
  #
  # ---
  # *Arguments*
  # * +i+: Location to check if it is included in the range
  # *Returns*:: +true+ _or_ +false+
  def include?(i)
    @range.include?(i)
  end
end # HorizontalCutRange
end # Range
end # RestrictionEnzyme
end # Bio
