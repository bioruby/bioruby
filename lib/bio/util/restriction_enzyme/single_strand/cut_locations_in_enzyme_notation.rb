require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/cut_symbol'
require 'bio/util/restriction_enzyme/integer'
require 'bio/sequence'

module Bio; end
class Bio::RestrictionEnzyme
class SingleStrand < Bio::Sequence::NA

#
# bio/util/restriction_enzyme/single_strand/cut_locations_in_enzyme_notation.rb - The cut locations, in enzyme notation
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: cut_locations_in_enzyme_notation.rb,v 1.1 2006/02/01 07:34:12 trevor Exp $
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
bio/util/restriction_enzyme/single_strand/cut_locations_in_enzyme_notation.rb - The cut locations, in enzyme notation

Stores the cut location in thier enzyme index notation

May be initialized with a series of cuts or an enzyme pattern marked
with cut symbols.

Enzyme index notation:: 1.._n_, value before 1 is -1

Notes:
* <code>0</code> is invalid as it does not refer to any index 
* +nil+ is not allowed here as it has no meaning
* +nil+ values are kept track of in DoubleStranded::CutLocations as they
  need a reference point on the correlating strand.  +nil+ represents no
  cut or a partial digestion.

=end
class CutLocationsInEnzymeNotation < Array
  include CutSymbol
  extend CutSymbol

  attr_reader :min, :max

  def initialize(*a)
    a.flatten! # in case an array was passed as an argument

    if a.size == 1 and a[0].kind_of? String and a[0] =~ re_cut_symbol
    # Initialize with a cut symbol pattern such as 'n^ng^arraxt^n'
      s = a[0]
      a = []
      i = -( s.tr(cut_symbol, '') =~ %r{[^n]} )  # First character that's not 'n'
      s.each_byte { |c| (a << i; next) if c.chr == cut_symbol; i += 1 }
      a.collect! { |n| n <= 0 ? n-1 : n } # 0 is not a valid enzyme index, decrement from 0 and all negative
    else
      a.collect! { |n| n.to_i } # Cut locations are always integers
    end

    validate_cut_locations( a )
    super(a)
    self.sort!
    @min = self.first
    @max = self.last
    self.freeze
  end

  # Transform the cut locations from enzyme index notation to 0-based index
  # notation.
  #
  #   input -> output
  #   [  1, 2, 3 ] -> [ 0, 1, 2 ]
  #   [  1, 3, 5 ] -> [ 0, 2, 4 ]
  #   [ -1, 1, 2 ] -> [ 0, 1, 2 ]
  #   [ -2, 1, 3 ] -> [ 0, 2, 4 ]
  #
  def to_array_index
    return [] if @min == nil
    if @min.negative?
      calc = lambda do |n| 
        n -= 1 unless n.negative?
        n + @min.abs
      end
    else
      calc = lambda { |n| n - 1 }
    end
    self.collect(&calc)
  end

  #########
  protected
  #########

  def validate_cut_locations( input_cut_locations )
    unless input_cut_locations == input_cut_locations.uniq
      err = "The cut locations supplied contain duplicate values.  Redundant / undefined meaning.\n"
      err += "cuts: #{input_cut_locations.inspect}\n"
      err += "unique: #{input_cut_locations.uniq.inspect}"
      raise ArgumentError, err
    end

    if input_cut_locations.include?(nil)
      err = "The cut locations supplied contained a nil.  nil has no index for enzyme notation, alternative meaning is 'no cut'.\n"
      err += "cuts: #{input_cut_locations.inspect}"
      raise ArgumentError, err
    end

    if input_cut_locations.include?(0)
      err = "The cut locations supplied contained a '0'.  '0' has no index for enzyme notation, alternative meaning is 'no cut'.\n"
      err += "cuts: #{input_cut_locations.inspect}"
      raise ArgumentError, err
    end

  end

end

end
end
