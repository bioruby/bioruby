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
#  $Id: atom.rb,v 1.4 2005/12/18 15:09:46 ngoto Exp $

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

    # Bio::PDB::Atom is a class for atom data.
    # Each ATOM line is parsed into an Atom object.
    Atom = Struct.new(:serial, :element, :alt_loc, :x, :y, :z,
                      :occ, :bfac, :residue)
    class Atom
      include Utils
      include Comparable

      #Returns a Coordinate class instance of the xyz positions
      def xyz
        Coordinate[ x, y, z ]
      end

      #Returns an array of the xyz positions
      def to_a
        [ x, y, z ]
      end
      
      #Sorts based on serial numbers
      def <=>(other)
        return serial <=> other.serial
      end
      
      #Stringifies to PDB format
      def to_s
        if element.length < 4
          elementOutput = sprintf(" %-3s", element)
        else
          elementOutput = element
        end
        sprintf("%-6s%5s %s%1s%3s %1s%4s%1s   %8.3f%8.3f%8.3f%6.2f%6.2f",
                record_type,
                serial, elementOutput, alt_loc, residue.resName,
                residue.chain.id, residue.resSeq, residue.iCode,
                x, y, z, occ, bfac)
      end

      def record_name
        'ATOM'
      end
      def record_type
        record_name
      end
    end #class Atom

    # Bio::PDB::HetAtm is a class for HETATM data.
    # Each HETATM line is parsed into an HetAtm object.
    # Since HetAtm inherits Atom class, please refer Atom class for usage.
    class HetAtm < Atom
      def record_name
        'HETATM'
      end
    end #class HetAtm

  end #class PDB
end #class Bio
