#
# bio/db/pdb/residue.rb - residue class for PDB
#
#   Copyright (C) 2004 Alex Gutteridge <alexg@ebi.ac.uk>
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
#  $Id: residue.rb,v 1.1 2004/03/08 07:30:40 ngoto Exp $

require 'bio/db/pdb'

module Bio

  class PDB

    #Residue class - id is a composite of resSeq and iCode
    class Residue
      
      include Utils
      include AtomFinder
      include Enumerable
      include Comparable
      
      attr_reader :resName, :resSeq, :iCode, :id, :chain, :hetatm
      attr_writer :resName, :chain, :hetatm
      
      def initialize(resName = nil, resSeq = nil, iCode = nil, 
                     chain = nil, hetatm = false)
        
        @resName = resName
        @resSeq  = resSeq
        @iCode   = iCode
        
        @hetatm  = hetatm
        
        #Residue id is required because resSeq doesn't uniquely identify
        #a residue. ID is constructed from resSeq and iCode and is appended
        #to 'LIGAND' if the residue is a HETATM
        if (!@resSeq and !@iCode)
          @id = nil
        else
          @id = @resSeq.to_s << @iCode
          if @hetatm
            @id = 'LIGAND' << @id
          end
        end
        
        @chain   = chain
        
        @atoms   = Array.new
        
      end
      
      #Keyed access to atoms based on element e.g. ["CA"]
      def [](key)
        atom = @atoms.find{ |atom| key == atom.element }
      end
      
      #Need to define these to make sure id is correctly updated
      def resSeq=(resSeq)
        @resSeq = resSeq.to_i
        @id      = resSeq.to_s << @iCode
        if @hetatm
          @id = 'LIGAND' << @id
        end
      end
      
      def iCode=(iCode)
        @iCode = iCode
        @id    = @resSeq.to_s << iCode
        if @hetatm
          @id = 'LIGAND' << @id
        end
      end
      
      #Adds an atom to this residue
      def addAtom(atom)
        raise "Expecting Bio::PDB::Atom" if not atom.is_a? Bio::PDB::Atom
        @atoms.push(atom)
        self
      end
      
      #Iterator over the atoms
      def each
        @atoms.each{ |atom| yield atom }
      end
      #Alias to override AtomFinder#each_atom
      alias :each_atom :each
      
      #Sorts based on resSeq and iCode if need be
      def <=>(other)
        if @resSeq != other.resSeq
          return @resSeq <=> other.resSeq
        else
          return @iCode <=> other.iCode
        end
      end
      
      #Stringifies each atom
      def to_s
        string = ""
        @atoms.each{ |atom| string << atom.to_s << "\n" }
        return string
      end
      
    end

  end

end
