require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/analysis/cut_range'

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

#
# bio/util/restriction_enzyme/analysis/vertical_cut_range.rb -
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: vertical_cut_range.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
#
#
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#
#

=begin rdoc
bio/util/restriction_enzyme/analysis/vertical_cut_range.rb -
=end
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

end

end
end
