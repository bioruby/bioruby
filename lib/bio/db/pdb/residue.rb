#
# = bio/db/pdb/residue.rb - residue class for PDB
#
# Copyright::  Copyright (C) 2004, 2006
#              Alex Gutteridge <alexg@ebi.ac.uk>
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: residue.rb,v 1.14 2007/12/18 13:48:42 ngoto Exp $
#
# = Bio::PDB::Residue
#
# = Bio::PDB::Heterogen
#

require 'bio/db/pdb'

module Bio

  class PDB

    # Bio::PDB::Residue is a class to store a residue.
    # The object would contain some atoms (Bio::PDB::Record::ATOM objects).
    #
    class Residue
      
      include Utils
      include AtomFinder

      include Enumerable
      include Comparable

      # Creates residue id from an ATOM (or HETATM) object.
      def self.get_residue_id_from_atom(atom)
        "#{atom.resSeq}#{atom.iCode.strip}".strip
      end

      # Creates a new Residue object.
      def initialize(resName = nil, resSeq = nil, iCode = nil, 
                     chain = nil)
        
        @resName = resName
        @resSeq  = resSeq
        @iCode   = iCode
        
        @chain   = chain
        @atoms   = []

        update_residue_id
      end

      # atoms in this residue. (Array)
      attr_reader :atoms

      # the chain to which this residue belongs
      attr_accessor :chain

      # resName (residue name)
      attr_accessor :resName

      # residue id (String or nil).
      # The id is a composite of resSeq and iCode.
      attr_reader   :residue_id

      # Now, Residue#id is an alias of residue_id.
      alias id residue_id

      #Keyed access to atoms based on atom name e.g. ["CA"]
      def [](key)
        atom = @atoms.find{ |atom| key == atom.name }
      end

      # Updates residue id. This is a private method.
      # Need to call this method to make sure id is correctly updated.
      def update_residue_id
        if !@resSeq and !@iCode
          @residue_id = nil
        else
          @residue_id = "#{@resSeq}#{@iCode.to_s.strip}".strip
        end
      end
      private :update_residue_id

      # resSeq
      attr_reader :resSeq

      # resSeq=()
      def resSeq=(resSeq)
        @resSeq = resSeq.to_i
        update_residue_id
        @resSeq
      end

      # iCode
      attr_reader :iCode

      # iCode=()
      def iCode=(iCode)
        @iCode = iCode
        update_residue_id
        @iCode
      end
      
      # Adds an atom to this residue
      def addAtom(atom)
        raise "Expecting ATOM or HETATM" unless atom.is_a? Bio::PDB::Record::ATOM
        @atoms.push(atom)
        self
      end
      
      # Iterator over the atoms
      def each
        @atoms.each{ |atom| yield atom }
      end
      # Alias to override AtomFinder#each_atom
      alias each_atom each
      
      # Sorts based on resSeq and iCode if need be
      def <=>(other)
        if @resSeq != other.resSeq
          return @resSeq <=> other.resSeq
        else
          return @iCode <=> other.iCode
        end
      end
      
      # Stringifies each atom
      def to_s
        @atoms.join('')
      end

      # returns a string containing human-readable representation
      # of this object.
      def inspect
        "#<#{self.class.to_s} resName=#{resName.inspect} id=#{residue_id.inspect} chain.id=#{(chain ? chain.id : nil).inspect} resSeq=#{resSeq.inspect} iCode=#{iCode.inspect} atoms.size=#{atoms.size}>"
      end

      # Always returns false.
      #
      # If the residue is HETATM, returns true.
      # Otherwise, returns false.
      def hetatm
        false
      end
    end #class Residue

    # Bio::PDB::Heterogen is a class to store a heterogen.
    # It inherits Bio::PDB::Residue and most of the methods are the same.
    #
    # The object would contain some HETATMs
    # (Bio::PDB::Record::HETATM objects).
    class Heterogen < Residue

      include HetatmFinder

      # Always returns true.
      #
      # If the residue is HETATM, returns true.
      # Otherwise, returns false.
      def hetatm
        true
      end

      # Alias to override HetatmFinder#each_hetatm
      alias each_hetatm each

      # Alias needed for HeterogenFinder.
      alias hetatms atoms

      # Alias to avoid confusion
      alias heterogen_id residue_id
    end #class Heterogen

  end #class PDB

end #module Bio
