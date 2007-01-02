#
# bio/util/restrction_enzyme/range/horizontal_cut_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: horizontal_cut_range.rb,v 1.1 2007/01/02 00:13:07 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/range/cut_range'

module Bio; end
class Bio::RestrictionEnzyme
class Range

#
# bio/util/restrction_enzyme/range/horizontal_cut_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
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
    @min = nil
    @max = nil
    @range = nil

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
end # Bio::RestrictionEnzyme
