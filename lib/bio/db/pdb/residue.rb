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
#  $Id: residue.rb,v 1.5 2006/01/04 13:01:09 ngoto Exp $

require 'bio/db/pdb'

module Bio

  class PDB

    #Residue class - id is a composite of resSeq and iCode
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

      # residue id (String or nil)
      attr_reader   :residue_id

      # Now, Residue#id is an alias of residue_id.
      alias id residue_id

      #Keyed access to atoms based on element e.g. ["CA"]
      def [](key)
        atom = @atoms.find{ |atom| key == atom.element }
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
      #Alias to override AtomFinder#each_atom
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
        string = ""
        @atoms.each{ |atom| string << atom.to_s << "\n" }
        return string
      end

      # If the residue is HETATM, returns true.
      # Otherwise, returns false.
      def hetatm
        false
      end
    end #class Residue

    class HeteroCompound < Residue

      # Creates residue id from an ATOM (or HETATM) object.
      # 
      # We add 'LIGAND' to the id if it's a HETATM.
      # I think this is neccessary because some PDB files reuse
      # numbers for HETATMS.
      def self.get_residue_id_from_atom(atom)
        'LIGAND' + super
      end

      # Residue id is required because resSeq doesn't uniquely identify
      # a residue. ID is constructed from resSeq and iCode and is appended
      # to 'LIGAND' if the residue is a HETATM
      def update_residue_id
        super
        @residue_id = 'LIGAND' + @residue_id if @residue_id
      end
      private :update_residue_id

      # If the residue is HETATM, returns true.
      # Otherwise, returns false.
      def hetatm
        true
      end
    end #class HeteroCompound

  end #class PDB

end #module Bio
