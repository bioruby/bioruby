#
# bio/util/restrction_enzyme/analysis/horizontal_cut_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: horizontal_cut_range.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/analysis/cut_range'

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

#
# bio/util/restrction_enzyme/analysis/horizontal_cut_range.rb - 
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
    # variables from CutRange would result in unpredictable
    # behavior.

    @p_cut_left = nil
    @p_cut_right = nil
    @c_cut_left = nil
    @c_cut_right = nil
    @min = nil
    @max = nil
    @range = nil

    @hcuts = (left..right)
  end

  def include?(i)
    @range.include?(i)
  end
end # HorizontalCutRange
end # Analysis
end # Bio::RestrictionEnzyme
