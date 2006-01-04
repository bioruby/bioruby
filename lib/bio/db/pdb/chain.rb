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
#  $Id: chain.rb,v 1.3 2006/01/04 15:41:50 ngoto Exp $

require 'bio/db/pdb'

module Bio

  class PDB

    class Chain
      
      include Utils
      include AtomFinder
      include ResidueFinder

      include HetatmFinder
      include HeterogenFinder

      include Enumerable
      include Comparable
      
      def initialize(id = nil, model = nil)
        
        @chain_id  = id
        
        @model    = model
        
        @residues   = []
        @heterogens = []
      end

      attr_accessor :chain_id
      attr_reader :model

      alias id chain_id

      # residues in this chain
      attr_reader :residues

      # heterogens in this chain
      attr_reader :heterogens
      
      # get the residue by id
      def get_residue_by_id(key)
        @residues.find { |r| r.residue_id == key }
      end

      # get the residue by id.
      # Compatibility Note: now, you cannot find HETATMS in this method.
      # To add LIGAND to the id is no longer available.
      # To get heterogens, you must use get_heterogen_by_id.
      def [](key)
        get_residue_by_id(key)
      end

      # get the heterogen (ligand) by id
      def get_heterogen_by_id(key)
        @heterogens.find { |r| r.residue_id == key }
      end
      
      #Add a residue to this chain
      def addResidue(residue)
        raise "Expecting a Bio::PDB::Residue" unless residue.is_a? Bio::PDB::Residue
        @residues.push(residue)
        self
      end
      
      #Add a heterogen (ligand) to this chain
      def addLigand(ligand)
        raise "Expecting a Bio::PDB::Residue" unless ligand.is_a? Bio::PDB::Residue
        @heterogens.push(ligand)
        self
      end
      
      # Iterates over each residue
      def each(&x) #:yields: residue
        @residues.each(&x)
      end
      #Alias to override ResidueFinder#each_residue
      alias each_residue each

      # Iterates over each hetero-compound
      def each_heterogen(&x) #:yields: heterogen
        @heterogens.each(&x)
      end
      
      # Operator aimed to sort based on chain id
      def <=>(other)
        return @chain_id <=> other.chain_id
      end
      
      # Stringifies each residue
      def to_s
        @residues.join('') + "TER\n"
      end

      # gets an amino acid sequence of the chain
      def atom_seq
        string = ""
        last_residue_num = nil
        @residues.each do |residue|
          if last_residue_num and 
              (x = (residue.resSeq.to_i - last_residue_num).abs) > 1 then
            x.times { string << 'X' }
          end
          tlc = residue.resName.capitalize
          olc = AminoAcid.names.invert[tlc]
          if !olc
            olc = 'X'
          end
          string << olc
        end
        Bio::Sequence::AA.new(string)
      end
      
    end #class Chain

  end #class PDB

end #module Bio
