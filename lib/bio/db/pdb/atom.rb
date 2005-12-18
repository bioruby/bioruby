#
# bio/db/pdb/atom.rb - Coordinate and atom class for PDB
#
#   Copyright (C) 2004 Alex Gutteridge <alexg@ebi.ac.uk>
#   Copyright (C) 2004 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: atom.rb,v 1.5 2005/12/18 17:33:32 ngoto Exp $

require 'matrix'
require 'bio/db/pdb'

module Bio
  class PDB

    class Coordinate < Vector
      def self.[](x,y,z)
        super
      end

      def self.elements(array, *a)
        raise 'Size of given array must be 3' if array.size != 3
        super
      end
      
      def x; self[0]; end
      def y; self[1]; end
      def z; self[2]; end
      def x=(n); self[0]=n; end
      def y=(n); self[1]=n; end
      def z=(n); self[2]=n; end

      # Definition of 'to_ary' means objects of the class is
      # implicitly regarded as an array.
      def to_ary; self.to_a; end

      def xyz; self; end
      
      def distance(object2)
        Utils::to_xyz(object2)
        (self - object2).r
      end
    end #class Coordinate

  end #class PDB
end #class Bio

