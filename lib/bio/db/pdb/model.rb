#
# = bio/db/pdb/model.rb - model class for PDB
#
# Copyright:: Copyright (C) 2004, 2006
#             Alex Gutteridge <alexg@ebi.ac.uk>
#             Naohisa Goto <ng@bioruby.org>
# License::   The Ruby License
#
# $Id: model.rb,v 1.10 2007/12/18 13:48:42 ngoto Exp $
#
# = Bio::PDB::Model
#
# Please refer Bio::PDB::Model.
#

require 'bio/db/pdb'

module Bio

  class PDB

    # Bio::PDB::Model is a class to store a model.
    #
    # The object would contain some chains (Bio::PDB::Chain objects).
    class Model
      
      include Utils
      include AtomFinder
      include ResidueFinder
      include ChainFinder

      include HetatmFinder
      include HeterogenFinder

      include Enumerable
      include Comparable
      
      # Creates a new Model object
      def initialize(serial = nil, structure = nil)
        
        @serial = serial
        @structure = structure
        @chains = []
        @chains_hash = {}
        @solvents = Chain.new('', self)
      end

      # chains in this model
      attr_reader :chains

      # (OBSOLETE) solvents (water, HOH) in this model
      attr_reader :solvents

      # serial number of this model. (Integer or nil)
      attr_accessor :serial

      # for backward compatibility
      alias model_serial serial

      # (reserved for future extension)
      attr_reader :structure
     
      # Adds a chain to this model
      def addChain(chain)
        raise "Expecting a Bio::PDB::Chain" unless chain.is_a? Bio::PDB::Chain
        @chains.push(chain)
        if @chains_hash[chain.chain_id] then
          $stderr.puts "Warning: chain_id #{chain.chain_id.inspect} is already used" if $VERBOSE
        else
          @chains_hash[chain.chain_id] = chain
        end
        self
      end

      # rehash chains hash
      def rehash
        begin
          chains_bak = @chains
          chains_hash_bak = @chains_hash
          @chains = []
          @chains_hash = {}
          chains_bak.each do |chain|
            self.addChain(chain)
          end
        rescue RuntimeError
          @chains = chains_bak
          @chains_hash = chains_hash_bak
          raise
        end
        self
      end
      
      # (OBSOLETE) Adds a solvent molecule to this model
      def addSolvent(solvent)
        raise "Expecting a Bio::PDB::Residue" unless solvent.is_a? Bio::PDB::Residue
        @solvents.addResidue(solvent)
      end

      # (OBSOLETE) not recommended to use this method
      def removeSolvent
        @solvents = nil
      end

      # Iterates over each chain
      def each(&x) #:yields: chain
        @chains.each(&x)
      end
      # Alias to override ChainFinder#each_chain
      alias each_chain each
     
      # Operator aimed to sort models based on serial number
      def <=>(other)
        return @serial <=> other.model_serial
      end
      
      # Keyed access to chains
      def [](key)
        #chain = @chains.find{ |chain| key == chain.id }
        @chains_hash[key]
      end
      
      # stringifies to chains
      def to_s
        string = ""
        if model_serial
          string = "MODEL     #{model_serial}\n" #Should use proper formatting
        end
        @chains.each{ |chain| string << chain.to_s }
        #if solvent
        #  string << @solvent.to_s
        #end
        if model_serial
          string << "ENDMDL\n"
        end
        return string
      end

      # returns a string containing human-readable representation
      # of this object.
      def inspect
        "#<#{self.class.to_s} serial=#{serial.inspect} chains.size=#{chains.size}>"
      end
      
    end #class Model

  end #class PDB

end #module Bio
