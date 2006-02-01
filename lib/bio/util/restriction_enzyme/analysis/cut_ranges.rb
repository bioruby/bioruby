require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio'

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

#
# bio/util/restriction_enzyme/analysis/cut_ranges.rb -
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: cut_ranges.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
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
bio/util/restriction_enzyme/analysis/cut_ranges.rb -
=end
class CutRanges < Array
  def min; self.collect{|a| a.min}.flatten.sort.first; end
  def max; self.collect{|a| a.max}.flatten.sort.last; end
  def include?(i); self.collect{|a| a.include?(i)}.include?(true); end
end

end
end
