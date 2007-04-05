#
# = bio/db/pdb/chemicalcomponent.rb - PDB Chemical Component Dictionary parser
#
# Copyright:: Copyright (C) 2006
#             GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
# License::   The Ruby License
#
# $Id: chemicalcomponent.rb,v 1.3 2007/04/05 23:35:41 trevor Exp $
#
# = About Bio::PDB::ChemicalComponent
#
# Please refer Bio::PDB::ChemicalComponent.
#
# = References
#
# * ((<URL:http://deposit.pdb.org/cc_dict_tut.html>))
# * http://deposit.pdb.org/het_dictionary.txt
#

require 'bio/db/pdb/pdb'

module Bio
  class PDB

    # Bio::PDB::ChemicalComponet is a parser for a entry of
    # the PDB Chemical Component Dictionary.
    # 
    # The PDB Chemical Component Dictionary is available in
    # http://deposit.pdb.org/het_dictionary.txt
    class ChemicalComponent

      # delimiter for reading via Bio::FlatFile
      DELIMITER = RS = "\n\n"

      # Single field (normally single line) of a entry
      class Record < Bio::PDB::Record

        # fetches record name
        def fetch_record_name(str)
          str[0..6].strip
        end
        private :fetch_record_name

        # fetches record name
        def self.fetch_record_name(str)
          str[0..6].strip
        end
        private_class_method :fetch_record_name

        # RESIDUE field.
        # It would be wrong because the definition described in documents
        # seems ambiguous.
        RESIDUE =
          def_rec([ 11, 13, Pdb_LString[3], :hetID ],
                  [ 16, 20, Pdb_Integer,    :numHetAtoms ]
                  )

        # CONECT field
        # It would be wrong because the definition described in documents
        # seems ambiguous.
        CONECT =
          def_rec([ 12, 15, Pdb_Atom,         :name ],
                  [ 19, 20, Pdb_Integer,      :num ],
                  [ 21, 24, Pdb_Atom,         :other_atoms ],
                  [ 26, 29, Pdb_Atom,         :other_atoms ],
                  [ 31, 34, Pdb_Atom,         :other_atoms ],
                  [ 36, 39, Pdb_Atom,         :other_atoms ],
                  [ 41, 44, Pdb_Atom,         :other_atoms ],
                  [ 46, 49, Pdb_Atom,         :other_atoms ],
                  [ 51, 54, Pdb_Atom,         :other_atoms ],
                  [ 56, 59, Pdb_Atom,         :other_atoms ],
                  [ 61, 64, Pdb_Atom,         :other_atoms ],
                  [ 66, 69, Pdb_Atom,         :other_atoms ],
                  [ 71, 74, Pdb_Atom,         :other_atoms ],
                  [ 76, 79, Pdb_Atom,         :other_atoms ]
                  )

        # HET field.
        # It is the same as Bio::PDB::Record::HET.
        HET    = Bio::PDB::Record::HET

        #--
        #HETSYN = Bio::PDB::Record::HETSYN
        #++

        # HETSYN field.
        # It is very similar to Bio::PDB::Record::HETSYN.
        HETSYN = 
            def_rec([  9, 10, Pdb_Continuation, nil ],
                    [ 12, 14, Pdb_LString(3),   :hetID ],
                    [ 16, 70, Pdb_String,       :hetSynonyms ]
                    )

        # HETNAM field.
        # It is the same as Bio::PDB::Record::HETNAM.
        HETNAM = Bio::PDB::Record::HETNAM

        # FORMUL field.
        # It is the same as Bio::PDB::Record::FORMUL.
        FORMUL = Bio::PDB::Record::FORMUL

        # default definition for unknown fields.
        Default = Bio::PDB::Record::Default

        # Hash to store allowed definitions.
        Definition = create_definition_hash

        # END record class.
        #
        # Because END is a reserved word of Ruby, it is separately
        # added to the hash
        End    = Bio::PDB::Record::End
        Definition['END'] = End

        # Look up the class in Definition hash
        def self.get_record_class(str)
          t = fetch_record_name(str)
          return Definition[t]
        end
      end #class Record

      # Creates a new object.
      def initialize(str)
        @data = str.split(/[\r\n]+/)
        @hash = {}

        #Flag to say whether the current line is part of a continuation
        cont = false
        
        #Goes through each line and replace that line with a PDB::Record
        @data.collect! do |line|
          #Go to next if the previous line was contiunation able, and
          #add_continuation returns true. Line is added by add_continuation
          next if cont and cont = cont.add_continuation(line)

          #Make the new record
          f = Record.get_record_class(line).new.initialize_from_string(line)
          #p f
          #Set cont
          cont = f if f.continue?
          #Set the hash to point to this record either by adding to an
          #array, or on it's own
          key = f.record_name
          if a = @hash[key] then
            a << f
          else
            @hash[key] = [ f ]
          end
          f
        end #each
        #At the end we need to add the final model
        @data.compact!
      end

      # all records in this entry as an array.
      attr_reader :data

      # all records in this entry as an hash accessed by record names.
      attr_reader :hash

      # Identifier written in the first line "RESIDUE" record. (e.g. CMP)
      def entry_id
        @data[0].hetID
      end

      # Synonyms for the comical component. Returns an array of strings.
      def hetsyn
        unless defined? @hetsyn
          if r = @hash["HETSYN"]
            @hetsyn = r[0].hetSynonyms.to_s.split(/\;\s*/)
          else
            return []
          end
        end
        @hetsyn
      end
      
      # The name of the chemical component.
      # Returns a string (or nil, if the entry is something wrong).
      def hetnam
        @hash["HETNAM"][0].text
      end

      # The chemical formula of the chemical component.
      # Returns a string  (or nil, if the entry is something wrong).
      def formul
        @hash["FORMUL"][0].text
      end

      # Returns an hash of bindings of atoms.
      # Note that each white spaces are stripped for atom symbols.
      def conect
        unless defined? @conect
          c = {}
          @hash["CONECT"].each do |e|
            key = e.name.to_s.strip
            unless key.empty?
              val = e.other_atoms.collect { |x| x.strip }
              #warn "Warning: #{key}: atom name conflict?" if c[key]
              c[key] = val
            end
          end
          @conect = c
        end
        @conect
      end

      # Gets all records whose record type is _name_.
      # Returns an array of <code>Bio::PDB::Record::*</code> objects.
      #
      # if _name_ is nil, returns hash storing all record data.
      #
      # Example:
      # p pdb.record('CONECT')
      # p pdb.record['CONECT']
      #
      def record(name = nil)
        name ? @hash[name] : @hash
      end

    end #class ChemicalComponent
  end #class PDB
end #module Bio

