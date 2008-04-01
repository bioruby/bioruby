#
# = bio/db/pdb/pdb.rb - PDB database class for PDB file format
#
# Copyright:: Copyright (C) 2003-2006
#             GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
#             Alex Gutteridge <alexg@ebi.ac.uk>
# License::   The Ruby License
#
#  $Id: pdb.rb,v 1.28 2008/04/01 10:36:44 ngoto Exp $
#
# = About Bio::PDB
#
# Please refer document of Bio::PDB class.
#
# = References
#
# * ((<URL:http://www.rcsb.org/pdb/>))
# * PDB File Format Contents Guide Version 2.2 (20 December 1996)
#   ((<URL:http://www.rcsb.org/pdb/file_formats/pdb/pdbguide2.2/guide2.2_frame.html>))
#
# = *** CAUTION ***
# This is beta version. Specs shall be changed frequently.
#

require 'bio/db/pdb'
require 'bio/data/aa'

module Bio

  # This is the main PDB class which takes care of parsing, annotations
  # and is the entry way to the co-ordinate data held in models.
  #
  # There are many related classes.
  #
  # Bio::PDB::Model
  # Bio::PDB::Chain
  # Bio::PDB::Residue
  # Bio::PDB::Heterogen
  # Bio::PDB::Record::ATOM
  # Bio::PDB::Record::HETATM
  # Bio::PDB::Record::*
  # Bio::PDB::Coordinate
  # 
  class PDB

    include Utils
    include AtomFinder
    include ResidueFinder
    include ChainFinder
    include ModelFinder

    include HetatmFinder
    include HeterogenFinder

    include Enumerable

    # delimiter for reading via Bio::FlatFile
    DELIMITER = RS = nil # 1 file 1 entry

    # Modules required by the field definitions
    module DataType

      Pdb_Continuation = nil

      module Pdb_Integer
        def self.new(str)
          str.to_i
        end
      end

      module Pdb_SList
        def self.new(str)
          str.to_s.strip.split(/\;\s*/)
        end
      end

      module Pdb_List
        def self.new(str)
          str.to_s.strip.split(/\,\s*/)
        end
      end

      module Pdb_Specification_list
        def self.new(str)
          a = str.to_s.strip.split(/\;\s*/)
          a.collect! { |x| x.split(/\:\s*/, 2) }
          a
        end
      end

      module Pdb_String
        def self.new(str)
          str.to_s.gsub(/\s+\z/, '')
        end

        #Creates a new module with a string left justified to the
        #length given in nn
        def self.[](nn)
          m = Module.new
          m.module_eval %Q{
            @@nn = nn
            def self.new(str)
              str.to_s.gsub(/\s+\z/, '').ljust(@@nn)[0, @@nn]
            end
          }
          m
        end
      end #module Pdb_String

      module Pdb_LString
        def self.[](nn)
          m = Module.new
          m.module_eval %Q{
            @@nn = nn
            def self.new(str)
              str.to_s.ljust(@@nn)[0, @@nn]
            end
          }
          m
        end
        def self.new(str)
          String.new(str.to_s)
        end
      end

      module Pdb_Real
        def self.[](fmt)
          m = Module.new
          m.module_eval %Q{
            @@format = fmt
            def self.new(str)
              str.to_f
            end
          }
          m
        end
        def self.new(str)
          str.to_f
        end
      end

      module Pdb_StringRJ
        def self.new(str)
          str.to_s.gsub(/\A\s+/, '')
        end
      end

      Pdb_Date         = Pdb_String
      Pdb_IDcode       = Pdb_String
      Pdb_Residue_name = Pdb_String
      Pdb_SymOP        = Pdb_String
      Pdb_Atom         = Pdb_String
      Pdb_AChar        = Pdb_String
      Pdb_Character    = Pdb_LString

      module ConstLikeMethod
        def Pdb_LString(nn)
          Pdb_LString[nn]
        end

        def Pdb_String(nn)
          Pdb_String[nn]
        end

        def Pdb_Real(fmt)
          Pdb_Real[fmt]
        end
      end #module ConstLikeMethod
    end #module DataType

    # The ancestor of every single PDB record class.
    # It inherits <code>Struct</code> class.
    # Basically, each line of a PDB file corresponds to
    # an instance of each corresponding child class.
    # If continuation exists, multiple lines may correspond to
    # single instance.
    #
    class Record < Struct
      include DataType
      extend DataType::ConstLikeMethod

      # Internal use only.
      #
      # parse filed definitions.
      def self.parse_field_definitions(ary)
        symbolhash = {}
        symbolary = []
        cont = false

        # For each field definition (range(start, end), type,symbol)
        ary.each do |x|
          range = (x[0] - 1)..(x[1] - 1)
          # If type is nil (Pdb_Continuation) then set 'cont' to the range
          # (other wise it is false to indicate no continuation
          unless x[2] then
            cont = range
          else
            klass = x[2]
            sym = x[3]
            # If the symbol is a proper symbol then...
            if sym.is_a?(Symbol) then
              # ..if we have the symbol already in the symbol hash
              # then add the range onto the range array
              if symbolhash.has_key?(sym) then
                symbolhash[sym][1] << range
              else
                # Other wise put a new symbol in with its type and range
                # range is given its own array. You can have
                # anumber of ranges.
                symbolhash[sym] = [ klass, [ range ] ]
                symbolary << sym
              end
            end
          end
        end #each
        [ symbolhash, symbolary, cont ]
      end
      private_class_method :parse_field_definitions

      # Creates new class by given field definition
      # The difference from new_direct() is the class
      # created by the method does lazy evaluation.
      #
      # Internal use only.
      def self.def_rec(*ary)
        symbolhash, symbolary, cont = parse_field_definitions(ary)

        klass = Class.new(self.new(*symbolary))
        klass.module_eval {
          @definition = ary
          @symbols = symbolhash
          @cont = cont
        }
        klass.module_eval {
          symbolary.each do |x|
            define_method(x) { do_parse; super() }
          end
        }
        klass
      end #def self.def_rec

      # creates new class which inherits given class.
      def self.new_inherit(klass)
        newklass = Class.new(klass)
        newklass.module_eval {
          @definition = klass.module_eval { @definition }
          @symbols    = klass.module_eval { @symbols }
          @cont       = klass.module_eval { @cont }
        }
        newklass
      end

      # Creates new class by given field definition.
      #
      # Internal use only.
      def self.new_direct(*ary)
        symbolhash, symbolary, cont = parse_field_definitions(ary)
        if cont
          raise 'continuation not allowed. please use def_rec instead'
        end

        klass = Class.new(self.new(*symbolary))
        klass.module_eval {
          @definition = ary
          @symbols = symbolhash
          @cont = cont
        }
        klass.module_eval {
          define_method(:initialize_from_string) { |str|
            r = super(str)
            do_parse
            r
          }
        }
        klass
      end #def self.new_direct

      # symbols
      def self.symbols
        #p self
        @symbols
      end

      # Returns true if this record has a field type which allows 
      # continuations.
      def self.continue?
        @cont
      end

      # Returns true if this record has a field type which allows 
      # continuations.
      def continue?
        self.class.continue?
      end

      # yields the symbol(k), type(x[0]) and array of ranges
      # of each symbol.
      def each_symbol
        self.class.symbols.each do |k, x|
          yield k, x[0], x[1]
        end
      end

      # Return original string (except that "\n" are truncated) 
      # for this record (usually just @str, but
      # sometimes add on the continuation data from other lines.
      # Returns an array of string.
      #
      def original_data
        if defined?(@cont_data) then
          [ @str, *@cont_data ]
        else
          [ @str ]
        end
      end

      # initialize this record from the given string.
      # <em>str</em> must be a line (in PDB format).
      #
      # You can add continuation lines later using
      # <code>add_continuation</code> method.
      def initialize_from_string(str)
        @str = str
        @record_name = fetch_record_name(str)
        @parsed = false
        self
      end

      #--
      # Called when we need to access the data, takes the string
      # and the array of FieldDefs and parses it out.
      #++

      # In order to speeding up processing of PDB file format,
      # fields have not been parsed before calling this method.
      #
      # Normally, it is automatically called and you don't explicitly
      # need to call it .
      #
      def do_parse
        return self if @parsed or !@str
        str = @str
        each_symbol do |key, klass, ranges|
          #If we only have one range then pull that out
          #and store it in the hash
          if ranges.size <= 1 then
            self[key] = klass.new(str[ranges.first])
          else
            #Go through each range and add the string to an array
            #set the hash key to point to that array
            ary = []
            ranges.each do |r|
              ary << klass.new(str[r]) unless str[r].to_s.strip.empty?
            end
            self[key] = ary
          end
        end #each_symbol
        #If we have continuations then for each line of extra data...
        if defined?(@cont_data) then
          @cont_data.each do |str|
            #Get the symbol, type and range array 
            each_symbol do |key, klass, ranges|
              #If there's one range then grab that range
              if ranges.size <= 1 then
                r = ranges.first
                unless str[r].to_s.strip.empty?
                  #and concatenate the new data onto the old
                  v = klass.new(str[r])
                  self[key].concat(v) if self[key] != v
                end
              else
                #If there's more than one range then add to the array
                ary = self[key]
                ranges.each do |r|
                  ary << klass.new(str[r]) unless str[r].to_s.strip.empty?
                end
              end
            end
          end
        end
        @parsed = true
        self
      end

      # fetches record name
      def fetch_record_name(str)
        str[0..5].strip
      end
      private :fetch_record_name

      # fetches record name
      def self.fetch_record_name(str)
        str[0..5].strip
      end
      private_class_method :fetch_record_name

      # If given <em>str</em> can be the continuation of the current record,
      # then return the order number of the continuation associated with
      # the Pdb_Continuation field definition.
      # Otherwise, returns -1.
      def fetch_cont(str)
        (c = continue?) ? str[c].to_i : -1
      end
      private :fetch_cont

      # Record name of this record, e.g. "HEADER", "ATOM".
      def record_name
        @record_name or self.class.to_s.split(/\:\:/)[-1].to_s.upcase
      end
      # keeping compatibility with old version
      alias record_type record_name

      # Internal use only.
      #
      # Adds continuation data to the record from str if str is
      # really the continuation of current record.
      # Returns self (= not nil) if str is the continuation.
      # Otherwaise, returns false.
      #
      def add_continuation(str)
        #Check that this record can continue
        #and that str has the same type and definition
        return false unless self.continue?
        return false unless fetch_record_name(str) == @record_name
        return false unless self.class.get_record_class(str) == self.class
        return false unless fetch_cont(str) >= 2
        #If all this is OK then add onto @cont_data
        unless defined?(@cont_data)
          @cont_data = []
        end
        @cont_data << str
        # Returns self (= not nil) if succeeded.
        self
      end

      # creates definition hash from current classes constants
      def self.create_definition_hash
        hash = {}
        constants.each do |x|
          x = x.intern # keep compatibility both Ruby 1.8 and 1.9
          hash[x] = const_get(x) if /\A[A-Z][A-Z0-9]+\z/ =~ x.to_s
        end
        if x = const_get(:Default) then
          hash.default = x
        end
        hash
      end

      # same as Struct#inspect.
      #
      # Note that <code>do_parse</code> is automatically called
      # before <code>inspect</code>.
      #
      # (Warning: The do_parse might sweep hidden bugs in PDB classes.)
      def inspect
        do_parse
        super
      end

      #--
      #
      # definitions
      # contains all the rules for parsing each field
      # based on format V 2.2, 16-DEC-1996
      #
      # http://www.rcsb.org/pdb/docs/format/pdbguide2.2/guide2.2_frame.html
      # http://www.rcsb.org/pdb/docs/format/pdbguide2.2/Contents_Guide_21.html
      #
      # Details of following data are taken from these documents.

      # [ 1..6,  :Record_name, nil ],

      # XXXXXX =
      #   new([ start, end, type of data, symbol to access ], ...)
      #
      #++

      # HEADER record class
      HEADER = 
        def_rec([ 11, 50, Pdb_String, :classification ], #Pdb_String(40)
                [ 51, 59, Pdb_Date,   :depDate ],
                [ 63, 66, Pdb_IDcode, :idCode ]
                )

      # OBSLTE record class
      OBSLTE =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 12, 20, Pdb_Date,   :repDate ],
                [ 22, 25, Pdb_IDcode, :idCode ],
                [ 32, 35, Pdb_IDcode, :rIdCode ],
                [ 37, 40, Pdb_IDcode, :rIdCode ],
                [ 42, 45, Pdb_IDcode, :rIdCode ],
                [ 47, 50, Pdb_IDcode, :rIdCode ],
                [ 52, 55, Pdb_IDcode, :rIdCode ],
                [ 57, 60, Pdb_IDcode, :rIdCode ],
                [ 62, 65, Pdb_IDcode, :rIdCode ],
                [ 67, 70, Pdb_IDcode, :rIdCode ]
                )

      # TITLE record class
      TITLE =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_String, :title ]
                )
        
      # CAVEAT record class
      CAVEAT =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 12, 15, Pdb_IDcode, :idcode ],
                [ 20, 70, Pdb_String, :comment ]
                )

      # COMPND record class
      COMPND =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_Specification_list, :compound ]
                )

      # SOURCE record class
      SOURCE =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_Specification_list, :srcName ]
                )

      # KEYWDS record class
      KEYWDS =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_List, :keywds ]
                )

      # EXPDTA record class
      EXPDTA =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_SList, :technique ]
                )

      # AUTHOR record class
      AUTHOR =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_List, :authorList ]
                )

      # REVDAT record class
      REVDAT =
        def_rec([  8, 10, Pdb_Integer,      :modNum  ],
                [ 11, 12, Pdb_Continuation, nil      ],
                [ 14, 22, Pdb_Date,         :modDate ],
                [ 24, 28, Pdb_String,       :modId   ], # Pdb_String(5)
                [ 32, 32, Pdb_Integer,      :modType ],
                [ 40, 45, Pdb_LString(6),   :record  ],
                [ 47, 52, Pdb_LString(6),   :record  ],
                [ 54, 59, Pdb_LString(6),   :record  ],
                [ 61, 66, Pdb_LString(6),   :record  ]
                )

      # SPRSDE record class
      SPRSDE =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 12, 20, Pdb_Date,   :sprsdeDate ],
                [ 22, 25, Pdb_IDcode, :idCode ],
                [ 32, 35, Pdb_IDcode, :sIdCode ],
                [ 37, 40, Pdb_IDcode, :sIdCode ],
                [ 42, 45, Pdb_IDcode, :sIdCode ],
                [ 47, 50, Pdb_IDcode, :sIdCode ],
                [ 52, 55, Pdb_IDcode, :sIdCode ],
                [ 57, 60, Pdb_IDcode, :sIdCode ],
                [ 62, 65, Pdb_IDcode, :sIdCode ],
                [ 67, 70, Pdb_IDcode, :sIdCode ]
                )

      # 'JRNL' is defined below
      JRNL = nil

      # 'REMARK' is defined below
      REMARK = nil

      # DBREF record class
      DBREF =
        def_rec([  8, 11, Pdb_IDcode,    :idCode      ],
                [ 13, 13, Pdb_Character, :chainID     ],
                [ 15, 18, Pdb_Integer,   :seqBegin    ],
                [ 19, 19, Pdb_AChar,     :insertBegin ],
                [ 21, 24, Pdb_Integer,   :seqEnd      ],
                [ 25, 25, Pdb_AChar,     :insertEnd   ],
                [ 27, 32, Pdb_String,    :database    ], #Pdb_LString
                [ 34, 41, Pdb_String,    :dbAccession ], #Pdb_LString
                [ 43, 54, Pdb_String,    :dbIdCode    ], #Pdb_LString
                [ 56, 60, Pdb_Integer,   :dbseqBegin  ],
                [ 61, 61, Pdb_AChar,     :idbnsBeg    ],
                [ 63, 67, Pdb_Integer,   :dbseqEnd    ],
                [ 68, 68, Pdb_AChar,     :dbinsEnd    ]
                )
        
      # SEQADV record class
      SEQADV =
        def_rec([  8, 11, Pdb_IDcode,       :idCode   ],
                [ 13, 15, Pdb_Residue_name, :resName  ],
                [ 17, 17, Pdb_Character,    :chainID  ],
                [ 19, 22, Pdb_Integer,      :seqNum   ],
                [ 23, 23, Pdb_AChar,        :iCode    ],
                [ 25, 28, Pdb_String,       :database ], #Pdb_LString
                [ 30, 38, Pdb_String,       :dbIdCode ], #Pdb_LString
                [ 40, 42, Pdb_Residue_name, :dbRes    ],
                [ 44, 48, Pdb_Integer,      :dbSeq    ],
                [ 50, 70, Pdb_LString,      :conflict ]
                )

      # SEQRES record class
      SEQRES =
        def_rec(#[  9, 10, Pdb_Integer,      :serNum ],
                [  9, 10, Pdb_Continuation, nil      ],
                [ 12, 12, Pdb_Character,    :chainID ],
                [ 14, 17, Pdb_Integer,      :numRes  ],
                [ 20, 22, Pdb_Residue_name, :resName ],
                [ 24, 26, Pdb_Residue_name, :resName ],
                [ 28, 30, Pdb_Residue_name, :resName ],
                [ 32, 34, Pdb_Residue_name, :resName ],
                [ 36, 38, Pdb_Residue_name, :resName ],
                [ 40, 42, Pdb_Residue_name, :resName ],
                [ 44, 46, Pdb_Residue_name, :resName ],
                [ 48, 50, Pdb_Residue_name, :resName ],
                [ 52, 54, Pdb_Residue_name, :resName ],
                [ 56, 58, Pdb_Residue_name, :resName ],
                [ 60, 62, Pdb_Residue_name, :resName ],
                [ 64, 66, Pdb_Residue_name, :resName ],
                [ 68, 70, Pdb_Residue_name, :resName ]
                )
      
      # MODRS record class
      MODRES =
        def_rec([  8, 11, Pdb_IDcode,       :idCode ],
                [ 13, 15, Pdb_Residue_name, :resName ],
                [ 17, 17, Pdb_Character,    :chainID ],
                [ 19, 22, Pdb_Integer,      :seqNum ],
                [ 23, 23, Pdb_AChar,        :iCode ],
                [ 25, 27, Pdb_Residue_name, :stdRes ],
                [ 30, 70, Pdb_String,       :comment ]
                )
      
      # HET record class
      HET =
        def_rec([  8, 10, Pdb_LString(3), :hetID ],
                [ 13, 13, Pdb_Character,  :ChainID ],
                [ 14, 17, Pdb_Integer,    :seqNum ],
                [ 18, 18, Pdb_AChar,      :iCode ],
                [ 21, 25, Pdb_Integer,    :numHetAtoms ],
                [ 31, 70, Pdb_String,     :text ]
                )
      
      # HETNAM record class
      HETNAM =
        def_rec([ 9, 10,  Pdb_Continuation, nil ],
                [ 12, 14, Pdb_LString(3),   :hetID ],
                [ 16, 70, Pdb_String,       :text ]
                )
        
      # HETSYN record class
      HETSYN =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 12, 14, Pdb_LString(3),   :hetID ],
                [ 16, 70, Pdb_SList,        :hetSynonyms ]
                )
      
      # FORMUL record class
      FORMUL =
        def_rec([  9, 10, Pdb_Integer,    :compNum ],
                [ 13, 15, Pdb_LString(3), :hetID ],
                [ 17, 18, Pdb_Integer,    :continuation ],
                [ 19, 19, Pdb_Character,  :asterisk ],
                [ 20, 70, Pdb_String,     :text ]
                )
      
      # HELIX record class
      HELIX =
        def_rec([  8, 10, Pdb_Integer,      :serNum ],
                #[ 12, 14, Pdb_LString(3),   :helixID ],
                [ 12, 14, Pdb_StringRJ,     :helixID ],
                [ 16, 18, Pdb_Residue_name, :initResName ],
                [ 20, 20, Pdb_Character,    :initChainID ],
                [ 22, 25, Pdb_Integer,      :initSeqNum ],
                [ 26, 26, Pdb_AChar,        :initICode ],
                [ 28, 30, Pdb_Residue_name, :endResName ],
                [ 32, 32, Pdb_Character,    :endChainID ],
                [ 34, 37, Pdb_Integer,      :endSeqNum ],
                [ 38, 38, Pdb_AChar,        :endICode ],
                [ 39, 40, Pdb_Integer,      :helixClass ],
                [ 41, 70, Pdb_String,       :comment ],
                [ 72, 76, Pdb_Integer,      :length ]
                )

      # SHEET record class
      SHEET =
        def_rec([  8, 10, Pdb_Integer,      :strand ],
                #[ 12, 14, Pdb_LString(3),   :sheetID ],
                [ 12, 14, Pdb_StringRJ,     :sheetID ],
                [ 15, 16, Pdb_Integer,      :numStrands ],
                [ 18, 20, Pdb_Residue_name, :initResName ],
                [ 22, 22, Pdb_Character,    :initChainID ],
                [ 23, 26, Pdb_Integer,      :initSeqNum ],
                [ 27, 27, Pdb_AChar,        :initICode ],
                [ 29, 31, Pdb_Residue_name, :endResName ],
                [ 33, 33, Pdb_Character,    :endChainID ],
                [ 34, 37, Pdb_Integer,      :endSeqNum ],
                [ 38, 38, Pdb_AChar,        :endICode ],
                [ 39, 40, Pdb_Integer,      :sense ],
                [ 42, 45, Pdb_Atom,         :curAtom ],
                [ 46, 48, Pdb_Residue_name, :curResName ],
                [ 50, 50, Pdb_Character,    :curChainId ],
                [ 51, 54, Pdb_Integer,      :curResSeq ],
                [ 55, 55, Pdb_AChar,        :curICode ],
                [ 57, 60, Pdb_Atom,         :prevAtom ],
                [ 61, 63, Pdb_Residue_name, :prevResName ],
                [ 65, 65, Pdb_Character,    :prevChainId ],
                [ 66, 69, Pdb_Integer,      :prevResSeq ],
                [ 70, 70, Pdb_AChar,        :prevICode ]
                )
      
      # TURN record class
      TURN =
        def_rec([  8, 10, Pdb_Integer,      :seq ],
                #[ 12, 14, Pdb_LString(3),   :turnId ],
                [ 12, 14, Pdb_StringRJ,     :turnId ],
                [ 16, 18, Pdb_Residue_name, :initResName ],
                [ 20, 20, Pdb_Character,    :initChainId ],
                [ 21, 24, Pdb_Integer,      :initSeqNum ],
                [ 25, 25, Pdb_AChar,        :initICode ],
                [ 27, 29, Pdb_Residue_name, :endResName ],
                [ 31, 31, Pdb_Character,    :endChainId ],
                [ 32, 35, Pdb_Integer,      :endSeqNum ],
                [ 36, 36, Pdb_AChar,        :endICode ],
                [ 41, 70, Pdb_String,       :comment ]
                )
        
      # SSBOND record class
      SSBOND =
        def_rec([  8, 10, Pdb_Integer,    :serNum   ],
                [ 12, 14, Pdb_LString(3), :pep1     ], # "CYS"
                [ 16, 16, Pdb_Character,  :chainID1 ],
                [ 18, 21, Pdb_Integer,    :seqNum1  ],
                [ 22, 22, Pdb_AChar,      :icode1   ],
                [ 26, 28, Pdb_LString(3), :pep2     ], # "CYS"
                [ 30, 30, Pdb_Character,  :chainID2 ],
                [ 32, 35, Pdb_Integer,    :seqNum2  ],
                [ 36, 36, Pdb_AChar,      :icode2   ],
                [ 60, 65, Pdb_SymOP,      :sym1     ],
                [ 67, 72, Pdb_SymOP,      :sym2     ]
                )

      # LINK record class
      LINK =
        def_rec([ 13, 16, Pdb_Atom,         :name1 ],
                [ 17, 17, Pdb_Character,    :altLoc1 ],
                [ 18, 20, Pdb_Residue_name, :resName1 ],
                [ 22, 22, Pdb_Character,    :chainID1 ],
                [ 23, 26, Pdb_Integer,      :resSeq1 ],
                [ 27, 27, Pdb_AChar,        :iCode1 ],
                [ 43, 46, Pdb_Atom,         :name2 ],
                [ 47, 47, Pdb_Character,    :altLoc2 ],
                [ 48, 50, Pdb_Residue_name, :resName2 ],
                [ 52, 52, Pdb_Character,    :chainID2 ],
                [ 53, 56, Pdb_Integer,      :resSeq2 ],
                [ 57, 57, Pdb_AChar,        :iCode2 ],
                [ 60, 65, Pdb_SymOP,        :sym1 ],
                [ 67, 72, Pdb_SymOP,        :sym2 ]
                )
        
      # HYDBND record class
      HYDBND =
        def_rec([ 13, 16, Pdb_Atom,         :name1 ],
                [ 17, 17, Pdb_Character,    :altLoc1 ],
                [ 18, 20, Pdb_Residue_name, :resName1 ],
                [ 22, 22, Pdb_Character,    :Chain1 ],
                [ 23, 27, Pdb_Integer,      :resSeq1 ],
                [ 28, 28, Pdb_AChar,        :ICode1 ],
                [ 30, 33, Pdb_Atom,         :nameH ],
                [ 34, 34, Pdb_Character,    :altLocH ],
                [ 36, 36, Pdb_Character,    :ChainH ],
                [ 37, 41, Pdb_Integer,      :resSeqH ],
                [ 42, 42, Pdb_AChar,        :iCodeH ],
                [ 44, 47, Pdb_Atom,         :name2 ],
                [ 48, 48, Pdb_Character,    :altLoc2 ],
                [ 49, 51, Pdb_Residue_name, :resName2 ],
                [ 53, 53, Pdb_Character,    :chainID2 ],
                [ 54, 58, Pdb_Integer,      :resSeq2 ],
                [ 59, 59, Pdb_AChar,        :iCode2 ],
                [ 60, 65, Pdb_SymOP,        :sym1 ],
                [ 67, 72, Pdb_SymOP,        :sym2 ]
                )
        
      # SLTBRG record class
      SLTBRG =
        def_rec([ 13, 16, Pdb_Atom,          :atom1 ],
                [ 17, 17, Pdb_Character,     :altLoc1 ],
                [ 18, 20, Pdb_Residue_name,  :resName1 ],
                [ 22, 22, Pdb_Character,     :chainID1 ],
                [ 23, 26, Pdb_Integer,       :resSeq1 ],
                [ 27, 27, Pdb_AChar,         :iCode1 ],
                [ 43, 46, Pdb_Atom,          :atom2 ],
                [ 47, 47, Pdb_Character,     :altLoc2 ],
                [ 48, 50, Pdb_Residue_name,  :resName2 ],
                [ 52, 52, Pdb_Character,     :chainID2 ],
                [ 53, 56, Pdb_Integer,       :resSeq2 ],
                [ 57, 57, Pdb_AChar,         :iCode2 ],
                [ 60, 65, Pdb_SymOP,         :sym1 ],
                [ 67, 72, Pdb_SymOP,         :sym2 ]
                )
      
      # CISPEP record class
      CISPEP =
        def_rec([  8, 10, Pdb_Integer,     :serNum ],
                [ 12, 14, Pdb_LString(3),  :pep1 ],
                [ 16, 16, Pdb_Character,   :chainID1 ],
                [ 18, 21, Pdb_Integer,     :seqNum1 ],
                [ 22, 22, Pdb_AChar,       :icode1 ],
                [ 26, 28, Pdb_LString(3),  :pep2 ],
                [ 30, 30, Pdb_Character,   :chainID2 ],
                [ 32, 35, Pdb_Integer,     :seqNum2 ],
                [ 36, 36, Pdb_AChar,       :icode2 ],
                [ 44, 46, Pdb_Integer,     :modNum ],
                [ 54, 59, Pdb_Real('6.2'), :measure ]
                )
      
      # SITE record class
      SITE =
        def_rec([  8, 10, Pdb_Integer,      :seqNum    ],
                [ 12, 14, Pdb_LString(3),   :siteID    ],
                [ 16, 17, Pdb_Integer,      :numRes    ],
                [ 19, 21, Pdb_Residue_name, :resName1  ],
                [ 23, 23, Pdb_Character,    :chainID1  ],
                [ 24, 27, Pdb_Integer,      :seq1      ],
                [ 28, 28, Pdb_AChar,        :iCode1    ],
                [ 30, 32, Pdb_Residue_name, :resName2  ],
                [ 34, 34, Pdb_Character,    :chainID2  ],
                [ 35, 38, Pdb_Integer,      :seq2      ],
                [ 39, 39, Pdb_AChar,        :iCode2    ],
                [ 41, 43, Pdb_Residue_name, :resName3  ],
                [ 45, 45, Pdb_Character,    :chainID3  ],
                [ 46, 49, Pdb_Integer,      :seq3      ],
                [ 50, 50, Pdb_AChar,        :iCode3    ],
                [ 52, 54, Pdb_Residue_name, :resName4  ],
                [ 56, 56, Pdb_Character,    :chainID4  ],
                [ 57, 60, Pdb_Integer,      :seq4      ],
                [ 61, 61, Pdb_AChar,        :iCode4    ]
                )
      
      # CRYST1 record class
      CRYST1 =
        def_rec([  7, 15, Pdb_Real('9.3'), :a ],
                [ 16, 24, Pdb_Real('9.3'), :b ],
                [ 25, 33, Pdb_Real('9.3'), :c ],
                [ 34, 40, Pdb_Real('7.2'), :alpha ],
                [ 41, 47, Pdb_Real('7.2'), :beta ],
                [ 48, 54, Pdb_Real('7.2'), :gamma ],
                [ 56, 66, Pdb_LString,     :sGroup ],
                [ 67, 70, Pdb_Integer,     :z ]
                )
      
      # ORIGX1 record class
      #
      # ORIGXn n=1, 2, or 3
      ORIGX1 =
        def_rec([ 11, 20, Pdb_Real('10.6'), :On1 ],
                [ 21, 30, Pdb_Real('10.6'), :On2 ],
                [ 31, 40, Pdb_Real('10.6'), :On3 ],
                [ 46, 55, Pdb_Real('10.5'), :Tn ]
                )
      
      # ORIGX2 record class
      ORIGX2 = new_inherit(ORIGX1)
      # ORIGX3 record class
      ORIGX3 = new_inherit(ORIGX1)

      # SCALE1 record class
      #
      # SCALEn n=1, 2, or 3
      SCALE1 =
        def_rec([ 11, 20, Pdb_Real('10.6'), :Sn1 ],
                [ 21, 30, Pdb_Real('10.6'), :Sn2 ],
                [ 31, 40, Pdb_Real('10.6'), :Sn3 ],
                [ 46, 55, Pdb_Real('10.5'), :Un ]
                )
      
      # SCALE2 record class
      SCALE2 = new_inherit(SCALE1)
      # SCALE3 record class
      SCALE3 = new_inherit(SCALE1)
      
      # MTRIX1 record class
      #
      # MTRIXn n=1,2, or 3
      MTRIX1 =
        def_rec([  8, 10, Pdb_Integer,      :serial ],
                [ 11, 20, Pdb_Real('10.6'), :Mn1 ],
                [ 21, 30, Pdb_Real('10.6'), :Mn2 ],
                [ 31, 40, Pdb_Real('10.6'), :Mn3 ],
                [ 46, 55, Pdb_Real('10.5'), :Vn ],
                [ 60, 60, Pdb_Integer,      :iGiven ]
                )
      
      # MTRIX2 record class
      MTRIX2 = new_inherit(MTRIX1)
      # MTRIX3 record class
      MTRIX3 = new_inherit(MTRIX1)

      # TVECT record class
      TVECT =
        def_rec([  8, 10, Pdb_Integer,      :serial ],
                [ 11, 20, Pdb_Real('10.5'), :t1 ],
                [ 21, 30, Pdb_Real('10.5'), :t2 ],
                [ 31, 40, Pdb_Real('10.5'), :t3 ],
                [ 41, 70, Pdb_String,       :text ]
                )

      # MODEL record class
      MODEL =
        def_rec([ 11, 14, Pdb_Integer, :serial ]
                )
        # ChangeLog: model_serial are changed to serial
      
      # ATOM record class
      ATOM =
        new_direct([  7, 11, Pdb_Integer,      :serial ],
                   [ 13, 16, Pdb_Atom,         :name ],
                   [ 17, 17, Pdb_Character,    :altLoc ],
                   [ 18, 20, Pdb_Residue_name, :resName ],
                   [ 22, 22, Pdb_Character,    :chainID ],
                   [ 23, 26, Pdb_Integer,      :resSeq ],
                   [ 27, 27, Pdb_AChar,        :iCode ],
                   [ 31, 38, Pdb_Real('8.3'),  :x ],
                   [ 39, 46, Pdb_Real('8.3'),  :y ],
                   [ 47, 54, Pdb_Real('8.3'),  :z ],
                   [ 55, 60, Pdb_Real('6.2'),  :occupancy ],
                   [ 61, 66, Pdb_Real('6.2'),  :tempFactor ],
                   [ 73, 76, Pdb_LString(4),   :segID ],
                   [ 77, 78, Pdb_LString(2),   :element ],
                   [ 79, 80, Pdb_LString(2),   :charge ]
                   )

      # ATOM record class
      class ATOM

        include Utils
        include Comparable

        # for backward compatibility
        alias occ  occupancy
        # for backward compatibility
        alias bfac tempFactor

        # residue the atom belongs to.
        attr_accessor :residue

        # SIGATM record
        attr_accessor :sigatm

        # ANISOU record
        attr_accessor :anisou

        # TER record
        attr_accessor :ter

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

        def do_parse
          return self if @parsed or !@str
          self.serial     = @str[6..10].to_i
          self.name       = @str[12..15].strip
          self.altLoc     = @str[16..16]
          self.resName    = @str[17..19].strip
          self.chainID    = @str[21..21]
          self.resSeq     = @str[22..25].to_i
          self.iCode      = @str[26..26].strip
          self.x          = @str[30..37].to_f
          self.y          = @str[38..45].to_f
          self.z          = @str[46..53].to_f
          self.occupancy  = @str[54..59].to_f
          self.tempFactor = @str[60..65].to_f
          self.segID      = @str[72..75].to_s.rstrip
          self.element    = @str[76..77].to_s.lstrip
          self.charge     = @str[78..79].to_s.strip
          @parsed = true
          self
        end

        def justify_atomname
          atomname = self.name.to_s
          return atomname[0, 4] if atomname.length >= 4
          case atomname.length
          when 0
            return '    '
          when 1
            return ' ' + atomname + '  '
          when 2
            if /\A[0-9]/ =~ atomname then
              return sprintf('%-4s', atomname)
            elsif /[0-9]\z/ =~ atomname then
              return sprintf(' %-3s', atomname)
            end
          when 3
            if /\A[0-9]/ =~ atomname then
              return sprintf('%-4s', atomname)
            end
          end
          # ambiguous case for two- or three-letter name
          elem = self.element.to_s.strip
          if elem.size > 0 and i = atomname.index(elem) then
            if i == 0 and elem.size == 1 then
              return sprintf(' %-3s', atomname)
            else
              return sprintf('%-4s', atomname)
            end
          end
          if self.kind_of?(HETATM) then
            if /\A(B[^AEHIKR]|C[^ADEFLMORSU]|F[^EMR]|H[^EFGOS]|I[^NR]|K[^R]|N[^ABDEIOP]|O[^S]|P[^ABDMORTU]|S[^BCEGIMNR]|V|W|Y[^B])/ =~
                atomname then
              return sprintf(' %-3s', atomname)
            else
              return sprintf('%-4s', atomname)
            end
          else # ATOM
            if /\A[CHONSP]/ =~ atomname then
              return sprintf(' %-3s', atomname)
            else
              return sprintf('%-4s', atomname)
            end
          end
          # could not be reached here
          raise 'bug!'
        end
        private :justify_atomname

        def to_s
          atomname = justify_atomname
          sprintf("%-6s%5d %-4s%-1s%3s %-1s%4d%-1s   %8.3f%8.3f%8.3f%6.2f%6.2f      %-4s%2s%-2s\n",
                  self.record_name,
                  self.serial, 
                  atomname,
                  self.altLoc,
                  self.resName,
                  self.chainID,
                  self.resSeq,
                  self.iCode,
                  self.x, self.y, self.z,
                  self.occupancy,
                  self.tempFactor,
                  self.segID,
                  self.element,
                  self.charge)
        end
      end #class ATOM

      # SIGATM record class
      SIGATM =
        def_rec([  7, 11, Pdb_Integer,      :serial ],
                [ 13, 16, Pdb_Atom,         :name ],
                [ 17, 17, Pdb_Character,    :altLoc ],
                [ 18, 20, Pdb_Residue_name, :resName ],
                [ 22, 22, Pdb_Character,    :chainID ],
                [ 23, 26, Pdb_Integer,      :resSeq ],
                [ 27, 27, Pdb_AChar,        :iCode ],
                [ 31, 38, Pdb_Real('8.3'),  :sigX ],
                [ 39, 46, Pdb_Real('8.3'),  :sigY ],
                [ 47, 54, Pdb_Real('8.3'),  :sigZ ],
                [ 55, 60, Pdb_Real('6.2'),  :sigOcc ],
                [ 61, 66, Pdb_Real('6.2'),  :sigTemp ],
                [ 73, 76, Pdb_LString(4),   :segID ],
                [ 77, 78, Pdb_LString(2),   :element ],
                [ 79, 80, Pdb_LString(2),   :charge ]
                )

      # ANISOU record class
      ANISOU =
        def_rec([  7, 11, Pdb_Integer,      :serial ],
                [ 13, 16, Pdb_Atom,         :name ],
                [ 17, 17, Pdb_Character,    :altLoc ],
                [ 18, 20, Pdb_Residue_name, :resName ],
                [ 22, 22, Pdb_Character,    :chainID ],
                [ 23, 26, Pdb_Integer,      :resSeq ],
                [ 27, 27, Pdb_AChar,        :iCode ],
                [ 29, 35, Pdb_Integer,      :U11 ],
                [ 36, 42, Pdb_Integer,      :U22 ],
                [ 43, 49, Pdb_Integer,      :U33 ],
                [ 50, 56, Pdb_Integer,      :U12 ],
                [ 57, 63, Pdb_Integer,      :U13 ],
                [ 64, 70, Pdb_Integer,      :U23 ],
                [ 73, 76, Pdb_LString(4),   :segID ],
                [ 77, 78, Pdb_LString(2),   :element ],
                [ 79, 80, Pdb_LString(2),   :charge ]
                )

      # ANISOU record class
      class ANISOU
        # SIGUIJ record
        attr_accessor :siguij
      end #class ANISOU

      # SIGUIJ record class
      SIGUIJ =
        def_rec([  7, 11, Pdb_Integer,      :serial ],
                [ 13, 16, Pdb_Atom,         :name ],
                [ 17, 17, Pdb_Character,    :altLoc ],
                [ 18, 20, Pdb_Residue_name, :resName ],
                [ 22, 22, Pdb_Character,    :chainID ],
                [ 23, 26, Pdb_Integer,      :resSeq ],
                [ 27, 27, Pdb_AChar,        :iCode ],
                [ 29, 35, Pdb_Integer,      :SigmaU11 ],
                [ 36, 42, Pdb_Integer,      :SigmaU22 ],
                [ 43, 49, Pdb_Integer,      :SigmaU33 ],
                [ 50, 56, Pdb_Integer,      :SigmaU12 ],
                [ 57, 63, Pdb_Integer,      :SigmaU13 ],
                [ 64, 70, Pdb_Integer,      :SigmaU23 ],
                [ 73, 76, Pdb_LString(4),   :segID ],
                [ 77, 78, Pdb_LString(2),   :element ],
                [ 79, 80, Pdb_LString(2),   :charge ]
                )

      # TER record class
      TER =
        def_rec([  7, 11, Pdb_Integer,      :serial ],
                [ 18, 20, Pdb_Residue_name, :resName ],
                [ 22, 22, Pdb_Character,    :chainID ],
                [ 23, 26, Pdb_Integer,      :resSeq ],
                [ 27, 27, Pdb_AChar,        :iCode ]
                )
      
      #HETATM =
      #  new_direct([  7, 11, Pdb_Integer,      :serial ],
      #             [ 13, 16, Pdb_Atom,         :name ],
      #             [ 17, 17, Pdb_Character,    :altLoc ],
      #             [ 18, 20, Pdb_Residue_name, :resName ],
      #             [ 22, 22, Pdb_Character,    :chainID ],
      #             [ 23, 26, Pdb_Integer,      :resSeq ],
      #             [ 27, 27, Pdb_AChar,        :iCode ],
      #             [ 31, 38, Pdb_Real('8.3'),  :x ],
      #             [ 39, 46, Pdb_Real('8.3'),  :y ],
      #             [ 47, 54, Pdb_Real('8.3'),  :z ],
      #             [ 55, 60, Pdb_Real('6.2'),  :occupancy ],
      #             [ 61, 66, Pdb_Real('6.2'),  :tempFactor ],
      #             [ 73, 76, Pdb_LString(4),   :segID ],
      #             [ 77, 78, Pdb_LString(2),   :element ],
      #             [ 79, 80, Pdb_LString(2),   :charge ]
      #             )

      # HETATM record class
      HETATM = new_inherit(ATOM)

      # HETATM record class.
      # It inherits ATOM class.
      class HETATM; end

      # ENDMDL record class
      ENDMDL =
        def_rec([  2,  1, Pdb_Integer, :serial ] # dummy field (always 0)
                )

      # CONECT record class
      CONECT =
        def_rec([  7, 11, Pdb_Integer, :serial ],
                [ 12, 16, Pdb_Integer, :serial ],
                [ 17, 21, Pdb_Integer, :serial ],
                [ 22, 26, Pdb_Integer, :serial ],
                [ 27, 31, Pdb_Integer, :serial ],
                [ 32, 36, Pdb_Integer, :serial ],
                [ 37, 41, Pdb_Integer, :serial ],
                [ 42, 46, Pdb_Integer, :serial ],
                [ 47, 51, Pdb_Integer, :serial ],
                [ 52, 56, Pdb_Integer, :serial ],
                [ 57, 61, Pdb_Integer, :serial ]
                )

      # MASTER record class
      MASTER =
        def_rec([ 11, 15, Pdb_Integer, :numRemark ],
                [ 16, 20, Pdb_Integer, "0" ],
                [ 21, 25, Pdb_Integer, :numHet ],
                [ 26, 30, Pdb_Integer, :numHelix ],
                [ 31, 35, Pdb_Integer, :numSheet ],
                [ 36, 40, Pdb_Integer, :numTurn ],
                [ 41, 45, Pdb_Integer, :numSite ],
                [ 46, 50, Pdb_Integer, :numXform ],
                [ 51, 55, Pdb_Integer, :numCoord ],
                [ 56, 60, Pdb_Integer, :numTer ],
                [ 61, 65, Pdb_Integer, :numConect ],
                [ 66, 70, Pdb_Integer, :numSeq ]
                )

      # JRNL record classes
      class Jrnl < self
        # subrecord of JRNL
        # 13, 16
        # JRNL AUTH record class
        AUTH =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "AUTH"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_List,         :authorList ]
                  )

        # JRNL TITL record class
        TITL =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "TITL"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :title ]
                  )

        # JRNL EDIT record class
        EDIT =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "EDIT"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_List,         :editorList ]
                  )

        # JRNL REF record class
        REF =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "REF"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 47, Pdb_LString,      :pubName ],
                  [ 50, 51, Pdb_LString(2),   "V." ],
                  [ 52, 55, Pdb_String,       :volume ],
                  [ 57, 61, Pdb_String,       :page ],
                  [ 63, 66, Pdb_Integer,      :year ]
                  )

        # JRNL PUBL record class
        PUBL =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "PUBL"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :pub ]
                  )

        # JRNL REFN record class
        REFN =
          def_rec([ 13, 16, Pdb_String,     :sub_record ], # "REFN"
                  [ 20, 23, Pdb_LString(4), "ASTM" ], 
                  [ 25, 30, Pdb_LString(6), :astm ],
                  [ 33, 34, Pdb_LString(2), :country ],
                  [ 36, 39, Pdb_LString(4), :BorS ], # "ISBN" or "ISSN"
                  [ 41, 65, Pdb_LString,    :isbn ],
                  [ 67, 70, Pdb_LString(4), :coden ] # "0353" for unpublished
                  )

        # default or unknown record
        #
        Default =
          def_rec([ 13, 16, Pdb_String, :sub_record ]) # ""
        
        # definitions (hash)
        Definition = create_definition_hash
      end #class JRNL

      # REMARK record classes for REMARK 1
      class Remark1 < self
        # 13, 16
        # REMARK 1 REFERENCE record class
        EFER =
          def_rec([  8, 10, Pdb_Integer,    :remarkNum ],  # "1"
                  [ 12, 20, Pdb_String,     :sub_record ], # "REFERENCE"
                  [ 22, 70, Pdb_Integer,    :refNum ]
                  )
        
        # REMARK 1 AUTH record class
        AUTH =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,       :sub_record ], # "AUTH"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_List,         :authorList ]
                  )
        
        # REMARK 1 TITL record class
        TITL =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,       :sub_record ], # "TITL"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :title ]
                  )
        
        # REMARK 1 EDIT record class
        EDIT =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,       :sub_record ], # "EDIT"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :editorList ]
                  )
        
        # REMARK 1 REF record class
        REF =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_LString(3),   :sub_record ], # "REF"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 47, Pdb_LString,      :pubName ],
                  [ 50, 51, Pdb_LString(2),   "V." ],
                  [ 52, 55, Pdb_String,       :volume ],
                  [ 57, 61, Pdb_String,       :page ],
                  [ 63, 66, Pdb_Integer,      :year ]
                  )
        
        # REMARK 1 PUBL record class
        PUBL =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,       :sub_record ], # "PUBL"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :pub ]
                  )
        
        # REMARK 1 REFN record class
        REFN =
          def_rec([  8, 10, Pdb_Integer,    :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,     :sub_record ], # "REFN"
                  [ 20, 23, Pdb_LString(4), "ASTM" ],
                  [ 25, 30, Pdb_LString,    :astm ],
                  [ 33, 34, Pdb_LString,    :country ],
                  [ 36, 39, Pdb_LString(4), :BorS ],
                  [ 41, 65, Pdb_LString,    :isbn ],
                  [ 68, 70, Pdb_LString(4), :coden ]
                  )
        
        # default (or unknown) record class for REMARK 1
        Default =
          def_rec([  8, 10, Pdb_Integer,    :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,     :sub_record ]  # ""
                  )

        # definitions (hash)
        Definition = create_definition_hash
      end #class Remark1

      # REMARK record classes for REMARK 2
      class Remark2 < self
        # 29, 38 == 'ANGSTROMS.'
        ANGSTROMS = 
          def_rec([  8, 10, Pdb_Integer,     :remarkNum ], # "2"
                  [ 12, 22, Pdb_LString(11), :sub_record ], # "RESOLUTION."
                  [ 23, 27, Pdb_Real('5.2'), :resolution ],
                  [ 29, 38, Pdb_LString(10), "ANGSTROMS." ]
                  )
        
        # 23, 38 == ' NOT APPLICABLE.'
        NOT_APPLICABLE = 
          def_rec([  8, 10, Pdb_Integer,     :remarkNum ], # "2"
                  [ 12, 22, Pdb_LString(11), :sub_record ], # "RESOLUTION."
                  [ 23, 38, Pdb_LString(16), :resolution ], # " NOT APPLICABLE."
                  [ 41, 70, Pdb_String,      :comment ]
                  )
        
        # others
        Default = 
          def_rec([  8, 10, Pdb_Integer,     :remarkNum ], # "2"
                  [ 12, 22, Pdb_LString(11), :sub_record ], # "RESOLUTION."
                  [ 24, 70, Pdb_String,      :comment ]
                  )
      end #class Remark2
      
      # REMARK record class for REMARK n (n>=3)
      RemarkN =
        def_rec([  8, 10, Pdb_Integer, :remarkNum ],
                [ 12, 70, Pdb_LString, :text ]
                )

      # default (or unknown) record class
      Default = def_rec([ 8, 70, Pdb_LString, :text ])

      # definitions (hash)
      Definition = create_definition_hash

      # END record class.
      #
      # Because END is a reserved word of Ruby, it is separately
      # added to the hash
      End = 
        def_rec([  2,  1, Pdb_Integer, :serial ]) # dummy field (always 0)

      Definition['END'.intern] = End

      # Basically just look up the class in Definition hash
      # do some munging for JRNL and REMARK
      def self.get_record_class(str)
        t = fetch_record_name(str)
        t = t.intern unless t.empty?
        if d = Definition[t] then
          return d
        end
        case t
        when :JRNL
          ts = str[12..15].to_s.strip
          ts = ts.intern unless ts.empty?
          d = Jrnl::Definition[ts]
        when :REMARK
          case str[7..9].to_i
          when 1
            ts = str[12..15].to_s.strip
            ts = ts.intern unless ts.empty?
            d = Remark1::Definition[ts]
          when 2
            if str[28..37] == 'ANGSTROMS.' then
              d = Remark2::ANGSTROMS
            elsif str[22..37] == ' NOT APPLICABLE.' then
              d = Remark2::NOT_APPLICABLE
            else
              d = Remark2::Default
            end
          else
            d = RemarkN
          end
        else
          # unknown field
          d = Default
        end
        return d
      end
    end #class Record

    Coordinate_fileds = {
      'MODEL'  => true,
      :MODEL   => true,
      'ENDMDL' => true,
      :ENDMDL  => true,
      'ATOM'   => true,
      :ATOM    => true,
      'HETATM' => true,
      :HETATM  => true,
      'SIGATM' => true,
      :SIGATM  => true,
      'SIGUIJ' => true,
      :SIGUIJ  => true,
      'ANISOU' => true,
      :ANISOU  => true,
      'TER'    => true,
      :TER     => true,
    }

    # Creates a new Bio::PDB object from given <em>str</em>.
    def initialize(str)
      #Aha! Our entry into the world of PDB parsing, we initialise a PDB
      #object with the whole PDB file as a string
      #each PDB has an array of the lines of the original file
      #a bit memory-tastic! A hash of records and an array of models
      #also has an id

      @data = str.split(/[\r\n]+/)
      @hash = {}
      @models = []
      @id = nil

      #Flag to say whether the current line is part of a continuation
      cont = false

      #Empty current model
      cModel    = Model.new
      cChain    = nil #Chain.new
      cResidue  = nil #Residue.new
      cLigand   = nil #Heterogen.new
      c_atom    = nil

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

        # Do something for ATOM and HETATM
        if key == 'ATOM' or key == 'HETATM' then
          if cChain and f.chainID == cChain.id
            chain = cChain
          else
            if chain = cModel[f.chainID]
              cChain = chain unless cChain
            else
              # If we don't have chain, add a new chain
              newChain = Chain.new(f.chainID, cModel)
              cModel.addChain(newChain)
              cChain = newChain
              chain = newChain
            end
            # chain might be changed, clearing cResidue and cLigand
            cResidue = nil
            cLigand = nil
          end
        end

        case key
        when 'ATOM'
          c_atom = f
          residueID = Residue.get_residue_id_from_atom(f)

          if cResidue and residueID == cResidue.id
            residue = cResidue
          else
            if residue = chain.get_residue_by_id(residueID)
              cResidue = residue unless cResidue
            else
              # add a new residue
              newResidue = Residue.new(f.resName, f.resSeq, f.iCode, chain)
              chain.addResidue(newResidue)
              cResidue = newResidue
              residue = newResidue
            end
          end
          
          f.residue = residue
          residue.addAtom(f)

        when 'HETATM'
          c_atom = f
          residueID = Heterogen.get_residue_id_from_atom(f)

          if cLigand and residueID == cLigand.id
            ligand = cLigand
          else
            if ligand = chain.get_heterogen_by_id(residueID)
              cLigand = ligand unless cLigand
            else
              # add a new heterogen
              newLigand = Heterogen.new(f.resName, f.resSeq, f.iCode, chain)
              chain.addLigand(newLigand)
              cLigand = newLigand
              ligand = newLigand
              #Each model has a special solvent chain. (for compatibility)
              if f.resName == 'HOH'
                cModel.addSolvent(newLigand)
              end
            end
          end

          f.residue = ligand
          ligand.addAtom(f)

        when 'MODEL'
          c_atom = nil
          cChain = nil
          cResidue = nil
          cLigand = nil
          if cModel.model_serial or cModel.chains.size > 0 then
            self.addModel(cModel)
          end
          cModel = Model.new(f.serial)

        when 'TER'
          if c_atom
            c_atom.ter = f
          else
            #$stderr.puts "Warning: stray TER?"
          end
        when 'SIGATM'
          if c_atom
            #$stderr.puts "Warning: duplicated SIGATM?" if c_atom.sigatm
            c_atom.sigatm = f
          else
            #$stderr.puts "Warning: stray SIGATM?"
          end
        when 'ANISOU'
          if c_atom
            #$stderr.puts "Warning: duplicated ANISOU?" if c_atom.anisou
            c_atom.anisou = f
          else
            #$stderr.puts "Warning: stray ANISOU?"
          end
        when 'SIGUIJ'
          if c_atom and c_atom.anisou
            #$stderr.puts "Warning: duplicated SIGUIJ?" if c_atom.anisou.siguij
            c_atom.anisou.siguij = f
          else
            #$stderr.puts "Warning: stray SIGUIJ?"
          end

        else
          c_atom = nil

        end
        f
      end #each
      #At the end we need to add the final model
      self.addModel(cModel)
      @data.compact!
    end #def initialize

    # all records in this entry as an array.
    attr_reader :data

    # all records in this entry as an hash accessed by record names.
    attr_reader :hash

    # models in this entry (array).
    attr_reader :models

    # Adds a <code>Bio::Model</code> object to the current strucutre.
    # Adds a model to the current structure.
    # Returns self.
    def addModel(model)
      raise "Expecting a Bio::PDB::Model" if not model.is_a? Bio::PDB::Model
      @models.push(model)
      self
    end
    
    # Iterates over each model.
    # Iterates over each of the models in the structure.
    # Returns <code>self</code>.
    def each
      @models.each{ |model| yield model }
      self
    end
    # Alias needed for Bio::PDB::ModelFinder
    alias each_model each
    
    # Provides keyed access to the models based on serial number
    # returns nil if it's not there 
    def [](key)
      @models.find{ |model| key == model.model_serial }
    end
    #--
    # (should it raise an exception?)
    #++

    #--
    #Stringifies to a list of atom records - we could add the annotation
    #as well if needed
    #++

    # Returns a string of Bio::PDB::Models. This propogates down the heirarchy
    # till you get to Bio::PDB::Record::ATOM which are outputed in PDB format
    def to_s
      string = ""
      @models.each{ |model| string << model.to_s }
      string << "END\n"
      return string
    end
    
    #Makes a hash out of an array of PDB::Records and some kind of symbol
    #.__send__ invokes the method specified by the symbol.
    #Essentially it ends up with a hash with keys given in the sub_record
    #Not sure I fully understand this
    def make_hash(ary, meth)
      h = {}
      ary.each do |f|
        k = f.__send__(meth)
        h[k] = [] unless h.has_key?(k)
        h[k] << f
      end
      h
    end
    private :make_hash

    #Takes an array and returns another array of PDB::Records
    def make_grouping(ary, meth)
      a = []
      k_prev = nil
      ary.each do |f|
        k = f.__send__(meth)
        if k_prev and k_prev == k then
          a.last << f
        else
          a << []
          a.last << f
        end
        k_prev = k
      end
      a
    end
    private :make_grouping

    # Gets all records whose record type is _name_.
    # Returns an array of <code>Bio::PDB::Record::*</code> objects.
    #
    # if _name_ is nil, returns hash storing all record data.
    #
    # Example:
    # p pdb.record('HETATM')
    # p pdb.record['HETATM']
    #
    def record(name = nil)
      name ? (@hash[name] || []) : @hash
    end

    #--
    # PDB original methods
    #Returns a hash of the REMARK records based on the remarkNum
    #++

    # Gets REMARK records.
    # If no arguments, it returns all REMARK records as a hash.
    # If remark number is specified, returns only corresponding REMARK records.
    # If number == 1 or 2 ("REMARK   1" or "REMARK   2"), returns an array
    # of Bio::PDB::Record instances. Otherwise, returns an array of strings.
    #
    def remark(nn = nil)
      unless defined?(@remark)
        h = make_hash(self.record('REMARK'), :remarkNum)
        h.each do |i, a|
            a.shift # remove first record (= space only)
          if i != 1 and i != 2 then
            a.collect! { |f| f.text.gsub(/\s+\z/, '') }
          end
        end
        @remark = h
      end
      nn ? @remark[nn] : @remark
    end

    # Gets JRNL records.
    # If no arguments, it returns all JRNL records as a hash.
    # If sub record name is specified, it returns only corresponding records
    # as an array of Bio::PDB::Record instances.
    #
    def jrnl(sub_record = nil)
      unless defined?(@jrnl)
        @jrnl = make_hash(self.record('JRNL'), :sub_record)
      end
      sub_record ? @jrnl[sub_record] : @jrnl
    end

    #--
    #Finding methods - just grabs the record with the appropriate id
    #or returns and array of all of them
    #++

    # Gets HELIX records.
    # If no arguments are given, it returns all HELIX records.
    # (Returns an array of <code>Bio::PDB::Record::HELIX</code> instances.)
    # If <em>helixID</em> is given, it only returns records
    # corresponding to given <em>helixID</em>.
    # (Returns an <code>Bio::PDB::Record::HELIX</code> instance.)
    #
    def helix(helixID = nil)
      if helixID then
        self.record('HELIX').find { |f| f.helixID == helixID }
      else
        self.record('HELIX')
      end
    end

    # Gets TURN records.
    # If no arguments are given, it returns all TURN records. 
    # (Returns an array of <code>Bio::PDB::Record::TURN</code> instances.)
    # If <em>turnId</em> is given, it only returns a record
    # corresponding to given <em>turnId</em>.
    # (Returns an <code>Bio::PDB::Record::TURN</code> instance.)
    #
    def turn(turnId = nil)
      if turnId then
        self.record('TURN').find { |f| f.turnId == turnId }
      else
        self.record('TURN')
      end
    end

    # Gets SHEET records.
    # If no arguments are given, it returns all SHEET records
    # as an array of arrays of <code>Bio::PDB::Record::SHEET</code> instances.
    # If <em>sheetID</em> is given, it returns an array of
    # <code>Bio::PDB::Record::SHEET</code> instances.
    def sheet(sheetID = nil)
      unless defined?(@sheet)
        @sheet = make_grouping(self.record('SHEET'), :sheetID)
      end
      if sheetID then
        @sheet.find_all { |f| f.first.sheetID == sheetID }
      else
        @sheet
      end
    end

    # Gets SSBOND records.
    def ssbond
      self.record('SSBOND')
    end

    #--
    # Get seqres - we get this to return a nice Bio::Seq object
    #++
    
    # Amino acid or nucleic acid sequence of backbone residues in "SEQRES".
    # If <em>chainID</em> is given, it returns corresponding sequence
    # as an array of string.
    # Otherwise, returns a hash which contains all sequences.
    #
    def seqres(chainID = nil)
      unless defined?(@seqres)
        h = make_hash(self.record('SEQRES'), :chainID)
        newHash = {}
        h.each do |k, a|
          a.collect! { |f| f.resName }
          a.flatten!
          # determine nuc or aa?
          tmp = Hash.new(0)
          a[0,13].each { |x| tmp[x.to_s.strip.size] += 1 }
          if tmp[3] >= tmp[1] then
            # amino acid sequence
            a.collect! do |aa|
              #aa is three letter code: i.e. ALA
              #need to look up with Ala
              aa = aa.capitalize
              (begin
                 Bio::AminoAcid.three2one(aa)
               rescue ArgumentError
                 nil
               end || 'X')
            end
            seq = Bio::Sequence::AA.new(a.to_s)
          else
            # nucleic acid sequence
            a.collect! do |na|
              na = na.delete('^a-zA-Z')
              na.size == 1 ? na : 'n'
            end
            seq = Bio::Sequence::NA.new(a.to_s)
          end
          newHash[k] = seq
        end
        @seqres = newHash
      end
      if chainID then
        @seqres[chainID]
      else
        @seqres
      end
    end

    # Gets DBREF records.
    # Returns an array of Bio::PDB::Record::DBREF objects.
    #
    # If <em>chainID</em> is given, it returns corresponding DBREF records.
    def dbref(chainID = nil)
      if chainID then
        self.record('DBREF').find_all { |f| f.chainID == chainID }
      else
        self.record('DBREF')
      end
    end

    # Keywords in "KEYWDS".
    # Returns an array of string.
    def keywords
      self.record('KEYWDS').collect { |f| f.keywds }.flatten
    end

    # Classification in "HEADER".
    def classification
      f = self.record('HEADER').first
      f ? f.classification : nil
    end

    # Get authors in "AUTHOR".
    def authors
      self.record('AUTHOR').collect { |f| f.authorList }.flatten
    end

    #--
    # Bio::DB methods
    #++

    # PDB identifier written in "HEADER". (e.g. 1A00)
    def entry_id
      unless @id
        f = self.record('HEADER').first
        @id = f ? f.idCode : nil
      end
      @id
    end

    # Same as <tt>Bio::PDB#entry_id</tt>.
    def accession
      self.entry_id
    end

    # Title of this entry in "TITLE".
    def definition
      f = self.record('TITLE').first
      f ? f.title : nil
    end

    # Current modification number in "REVDAT".
    def version
      f = self.record('REVDAT').first
      f ? f.modNum : nil
    end

    # returns a string containing human-readable representation
    # of this object.
    def inspect
      "#<#{self.class.to_s} entry_id=#{entry_id.inspect}>"
    end

  end #class PDB

end #module Bio

