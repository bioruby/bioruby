require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/double_stranded/cut_locations'
require 'bio/util/restriction_enzyme/double_stranded/cut_location_pair_in_enzyme_notation'

module Bio; end
class Bio::RestrictionEnzyme
class DoubleStranded

#
# bio/util/restriction_enzyme/double_stranded/cut_locations_in_enzyme_notation.rb - 
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: cut_locations_in_enzyme_notation.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
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

=begin rdoc
bio/util/restriction_enzyme/double_stranded/cut_locations_in_enzyme_notation.rb - 
=end
class CutLocationsInEnzymeNotation < CutLocations

  def primary_to_array_index
    helper_for_to_array_index(self.primary)
  end

  def complement_to_array_index
    helper_for_to_array_index(self.complement)
  end

  def to_array_index
    unless self.primary_to_array_index.size == self.complement_to_array_index.size
      err = "Primary and complement strand cut locations are not available in equal numbers.\n"
      err += "primary: #{self.primary_to_array_index.inspect}\n"
      err += "primary.size: #{self.primary_to_array_index.size}\n"
      err += "complement: #{self.complement_to_array_index.inspect}\n"
      err += "complement.size: #{self.complement_to_array_index.size}"
      raise IndexError, err
    end
    a = self.primary_to_array_index.zip(self.complement_to_array_index)
    CutLocations.new( *a.collect {|cl| CutLocationPair.new(cl)} )
  end

  #########
  protected
  #########

  def helper_for_to_array_index(a)
    minimum = (self.primary + self.complement).flatten
    minimum.delete(nil)
    minimum = minimum.sort.first

    return [] if minimum == nil  # no elements

    if minimum.negative?
      calc = lambda do |n|
        unless n == nil
          n -= 1 unless n.negative?
          n += minimum.abs
        end
        n
      end
    else
      calc = lambda do |n| 
        n -= 1 unless n == nil
        n
      end
    end

    a.collect(&calc)
  end

  def validate_args(args)
    args.each do |a|
      unless a.class == Bio::RestrictionEnzyme::DoubleStranded::CutLocationPairInEnzymeNotation
        err = "Not a CutLocationPairInEnzymeNotation\n"
        err += "class: #{a.class}\n"
        err += "inspect: #{a.inspect}"
        raise TypeError, err
      end
    end
  end

end

end
end
