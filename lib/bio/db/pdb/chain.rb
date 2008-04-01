#
# = bio/db/pdb/chain.rb - chain class for PDB
#
# Copyright:: Copyright (C) 2004, 2006
#             Alex Gutteridge <alexg@ebi.ac.uk>
#             Naohisa Goto <ng@bioruby.org>
# License::   The Ruby License
# 
# $Id: chain.rb,v 1.10 2008/04/01 10:36:44 ngoto Exp $
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
        @residues_hash = {}
        @heterogens = []
        @heterogens_hash = {}
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
        #@residues.find { |r| r.residue_id == key }
        @residues_hash[key]
      end

      # get the residue by id.
      #
      # Compatibility Note: Now, you cannot find HETATMS in this method.
      # To add "LIGAND" to the id is no longer available.
      # To get heterogens, you must use <code>get_heterogen_by_id</code>.
      def [](key)
        get_residue_by_id(key)
      end

      # get the heterogen (ligand) by id
      def get_heterogen_by_id(key)
        #@heterogens.find { |r| r.residue_id == key }
        @heterogens_hash[key]
      end
      
      #Add a residue to this chain
      def addResidue(residue)
        raise "Expecting a Bio::PDB::Residue" unless residue.is_a? Bio::PDB::Residue
        @residues.push(residue)
        if @residues_hash[residue.residue_id] then
          $stderr.puts "Warning: residue_id #{residue.residue_id.inspect} is already used" if $VERBOSE
        else
          @residues_hash[residue.residue_id] = residue
        end
        self
      end
      
      #Add a heterogen (ligand) to this chain
      def addLigand(ligand)
        raise "Expecting a Bio::PDB::Residue" unless ligand.is_a? Bio::PDB::Residue
        @heterogens.push(ligand)
        if @heterogens_hash[ligand.residue_id] then
          $stderr.puts "Warning: heterogen_id (residue_id) #{ligand.residue_id.inspect} is already used" if $VERBOSE
        else
          @heterogens_hash[ligand.residue_id] = ligand
        end
        self
      end

      # rehash residues hash
      def rehash_residues
        begin
          residues_bak = @residues
          residues_hash_bak = @residues_hash
          @residues = []
          @residues_hash = {}
          residues_bak.each do |residue|
            self.addResidue(residue)
          end
        rescue RuntimeError
          @residues = residues_bak
          @residues_hash = residues_hash_bak
          raise
        end
        self
      end

      # rehash heterogens hash
      def rehash_heterogens
        begin
          heterogens_bak = @heterogens
          heterogens_hash_bak = @heterogens_hash
          @heterogens = []
          @heterogens_hash = {}
          heterogens_bak.each do |heterogen|
            self.addLigand(heterogen)
          end
        rescue RuntimeError
          @heterogens = heterogens_bak
          @heterogens_hash = heterogens_hash_bak
          raise
        end
        self
      end

      # rehash residues hash and heterogens hash
      def rehash
        rehash_residues
        rehash_heterogens
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
        @residues.join('') + "TER\n" + @heterogens.join('')
      end

      # returns a string containing human-readable representation
      # of this object.
      def inspect
        "#<#{self.class.to_s} id=#{chain_id.inspect} model.serial=#{(model ? model.serial : nil).inspect} residues.size=#{residues.size} heterogens.size=#{heterogens.size} aaseq=#{aaseq.inspect}>"
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
            olc = (begin
                     Bio::AminoAcid.three2one(tlc)
                   rescue ArgumentError
                     nil
                   end || 'X')
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
