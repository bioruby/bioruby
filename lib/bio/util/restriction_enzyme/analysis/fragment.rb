require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/analysis/tags'
require 'bio/util/restriction_enzyme/analysis/cut_ranges'
require 'bio/util/restriction_enzyme/analysis/horizontal_cut_range'
require 'bio'

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

#
# bio/util/restriction_enzyme/analysis/fragment.rb -
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: fragment.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
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
bio/util/restriction_enzyme/analysis/fragment.rb -
=end
class Fragment

  attr_reader :size
#  attr_reader :tags

  def initialize( primary_bin, complement_bin )
#    @tags = []
    @primary_bin = primary_bin
    @complement_bin = complement_bin
  end

#  def add_tag( index, info=nil )
#    @tags[index] = info
#  end

  DisplayFragment = Struct.new(:primary, :complement)

  def for_display(p_str=nil, c_str=nil)
    df = DisplayFragment.new
    df.primary = ''
    df.complement = ''

    both_bins = (@primary_bin + @complement_bin).sort.uniq
    both_bins.each do |item|
      @primary_bin.include?(item) ? df.primary << p_str[item] : df.primary << ' '
      @complement_bin.include?(item) ? df.complement << c_str[item] : df.complement << ' '
    end

    df
  end



end

end
end
