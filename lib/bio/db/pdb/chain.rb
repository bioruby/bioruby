#
# bio/db/pdb/chain.rb - chain class for PDB
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
#  $Id: chain.rb,v 1.1 2004/03/08 07:30:40 ngoto Exp $

require 'bio/db/pdb'

module Bio

  class PDB

    class Chain
      
      include Utils
      include AtomFinder
      include ResidueFinder
      include Enumerable
      include Comparable
      
      attr_reader :id, :model
      attr_writer :id
      
      def initialize(id = nil, model = nil)
        
        @id       = id
        
        @model    = model
        
        @residues = Array.new
        @ligands  = Array.new
        
      end
      
      #Keyed access to residues based on ids
      def [](key)
        #If you want to find HETATMS you need to add LIGAND to the id
        if key.to_s[0,6] == 'LIGAND'
          residue = @ligands.find{ |residue| key.to_s == residue.id }
        else
          residue = @residues.find{ |residue| key.to_s == residue.id }
        end
      end
      
      #Add a residue to this chain
      def addResidue(residue)
        raise "Expecting a Bio::PDB::Residue" if not residue.is_a? Bio::PDB::Residue
        @residues.push(residue)
        self
      end
      
      #Add a ligand to this chain
      def addLigand(residue)
        raise "Expecting a Bio::PDB::Residue" if not residue.is_a? Bio::PDB::Residue
        @ligands.push(residue)
        self
      end
      
      #Residue iterator
      def each
        @residues.each{ |residue| yield residue }
      end
      #Alias to override ResidueFinder#each_residue
      alias :each_residue :each
      
      #Sort based on chain id
      def <=>(other)
        return @id <=> other.id
      end
      
      #Stringifies each residue
      def to_s
        string = ""
        @residues.each{ |residue| string << residue.to_s }
        string = string << "TER\n"
        return string
      end

      def atom_seq
        string = ""
        last_residue_num = nil
        @residues.each{ |residue|
          if last_residue_num and 
              (residue.resSeq.to_i - last_residue_num).abs > 1
            (residue.resSeq.to_i - last_residue_num).abs.times{ string << 'X' }
          end
          tlc = residue.resName.capitalize
          olc = AminoAcid.names.invert[tlc]
          if !olc
            olc = 'X'
          end
          string << olc
        }
        Bio::Sequence::AA.new(string)
        
      end
      
    end

  end

end
