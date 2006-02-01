require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

module Bio; end
class Bio::RestrictionEnzyme
class Analysis

#
# bio/util/restriction_enzyme/analysis/fragments.rb -
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: fragments.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
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
bio/util/restriction_enzyme/analysis/fragments.rb -
=end
class Fragments < Array
  
  attr_accessor :primary
  attr_accessor :complement

  def initialize(primary, complement)
    @primary = primary
    @complement = complement
  end

  DisplayFragment = Struct.new(:primary, :complement)

  def for_display(p_str=nil, c_str=nil)
    p_str ||= @primary
    c_str ||= @complement
    pretty_fragments = []
    self.each { |fragment| pretty_fragments << fragment.for_display(p_str, c_str) }
    pretty_fragments
  end

end

end
end
