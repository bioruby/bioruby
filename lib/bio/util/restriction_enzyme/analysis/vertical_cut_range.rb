#
# bio/util/restrction_enzyme/analysis/vertical_cut_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: vertical_cut_range.rb,v 1.2 2006/12/31 21:50:31 trevor Exp $
#
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/analysis/cut_range'

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

#
# bio/util/restrction_enzyme/analysis/vertical_cut_range.rb - 
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
class VerticalCutRange < CutRange
  attr_reader :p_cut_left, :p_cut_right
  attr_reader :c_cut_left, :c_cut_right
  attr_reader :min, :max
  attr_reader :range

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
  end

  def include?(i)
    return false if @range == nil
    @range.include?(i)
  end
end # VerticalCutRange
end # Analysis
end # Bio::RestrictionEnzyme
