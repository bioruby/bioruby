#
# = bio/db/pdb/atom.rb - Coordinate class for PDB
#
# Copyright::  Copyright (C) 2004, 2006
#              Alex Gutteridge <alexg@ebi.ac.uk>
#              Naohisa Goto <ng@bioruby.org>
# License:: LGPL
#
#  $Id: atom.rb,v 1.6 2006/01/08 12:59:04 ngoto Exp $
#
#--
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
#++
#
# = Bio::PDB::Coordinate
#
# Coordinate class for PDB.
#
# = Compatibility Note
#
# From bioruby 0.7.0, the Bio::PDB::Atom class is no longer available.
# Please use Bio::PDB::Record::ATOM and Bio::PDB::Record::HETATM instead.
#

require 'matrix'
require 'bio/db/pdb'

module Bio
  class PDB

    # Bio::PDB::Coordinate is a class to store a 3D coordinate.
    # It inherits Vector (in bundled library in Ruby).
    #
    class Coordinate < Vector
      # same as Vector.[x,y,z]
      def self.[](x,y,z)
        super
      end

      # same as Vector.elements
      def self.elements(array, *a)
        raise 'Size of given array must be 3' if array.size != 3
        super
      end

      # x
      def x; self[0]; end
      # y
      def y; self[1]; end
      # z
      def z; self[2]; end
      # x=(n)
      def x=(n); self[0]=n; end
      # y=(n)
      def y=(n); self[1]=n; end
      # z=(n)
      def z=(n); self[2]=n; end

      # Implicit conversion to an array.
      #
      # Note that this method would be deprecated in the future.
      #
      #--
      # Definition of 'to_ary' means objects of the class is
      # implicitly regarded as an array.
      #++
      def to_ary; self.to_a; end

      # returns self.
      def xyz; self; end

      # distance between <em>object2</em>.
      def distance(object2)
        Utils::convert_to_xyz(object2)
        (self - object2).r
      end
    end #class Coordinate

  end #class PDB
end #class Bio

