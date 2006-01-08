#
# = bio/db/pdb/chain.rb - chain class for PDB
#
# Copyright:: Copyright (C) 2004, 2006
#             Alex Gutteridge <alexg@ebi.ac.uk>
#             Naohisa Goto <ng@bioruby.org>
# License:: LGPL
# 
#  $Id: chain.rb,v 1.4 2006/01/08 12:59:04 ngoto Exp $
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
# = Bio::PDB::Chain
# 
# Please refer Bio::PDB::Chain.
#

require 'bio/db/pdb'

module Bio

  class PDB

    # Bio::PDB::Chain is a class to store a chain.
    #
    # The object would contain some residues (Bio::PDB::Residue objects)
    # and some heterogens (Bio::PDB::Heterogen objects).
    # 
    class Chain
      
      include Utils
      include AtomFinder
      include ResidueFinder

      include HetatmFinder
      include HeterogenFinder

      include Enumerable
      include Comparable

      # Creates a new chain object.
      def initialize(id = nil, model = nil)
        
        @chain_id  = id
        
        @model    = model
        
        @residues   = []
        @heterogens = []
      end

      # Identifier of this chain
      attr_accessor :chain_id
      # alias
      alias id chain_id

      # the model to which this chain belongs.
      attr_reader :model

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

      # gets an amino acid sequence of this chain from ATOM records
      def aaseq
        unless defined? @aaseq
          string = ""
          last_residue_num = nil
          @residues.each do |residue|
            if last_residue_num and 
                (x = (residue.resSeq.to_i - last_residue_num).abs) > 1 then
              x.times { string << 'X' }
            end
            tlc = residue.resName.capitalize
            olc = (Bio::AminoAcid.three2one(tlc) or 'X')
            string << olc
          end
          @aaseq = Bio::Sequence::AA.new(string)
        end
        @aaseq
      end
      # for backward compatibility
      alias atom_seq aaseq
      
    end #class Chain

  end #class PDB

end #module Bio
