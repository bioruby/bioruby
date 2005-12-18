#
# bio/db/pdb/pdb.rb - PDB database class for PDB file format
#
#   Copyright (C) 2003,2004 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: pdb.rb,v 1.6 2005/12/18 17:37:14 ngoto Exp $
#

# *** CAUTION ***
# This is pre-alpha version. Specs shall be changed frequently.
#

require 'bio/db/pdb'
require 'bio/data/aa'

module Bio

  #This is the main PDB class which takes care of parsing, annotations
  #and is the entry way to the co-ordinate data held in models
  class PDB #< DB

    include Utils
    include AtomFinder
    include ResidueFinder
    include ChainFinder
    include ModelFinder
    include Enumerable

    DELIMITER = RS = nil # 1 file 1 entry

    #Modules required by the field definitions
    module DataType

      Pdb_Continuation = nil

      module Pdb_Integer
        def self.new(str)
          str.to_i
        end
      end

      module Pdb_SList
        def self.new(str)
          str.strip.split(/\;\s*/)
        end
      end

      module Pdb_List
        def self.new(str)
          str.strip.split(/\,\s*/)
        end
      end

      module Pdb_Specification_list
        def self.new(str)
          a = str.strip.split(/\;\s*/)
          a.collect! { |x| x.split(/\:\s*/, 2) }
          a
        end
      end

      module Pdb_String
        def self.new(str)
          str.gsub(/\s+\z/, '')
        end

        #Creates a new module with a string left justified to the
        #length given in nn
        def self.[](nn)
          m = Module.new
          m.module_eval %Q{
            @@nn = nn
            def self.new(str)
              str.gsub(/\s+\z/, '').ljust(@@nn)[0, @@nn]
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
              str.ljust(@@nn)[0, @@nn]
            end
          }
          m
        end
        def self.new(str)
          String.new(str)
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
          str.gsub(/\A\s+/, '')
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

    class Record < Struct
      include DataType
      extend DataType::ConstLikeMethod

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
            define_method(x) { do_parse; super }
          end
        }
        klass
      end #def self.def_rec

      def self.new_inherit(klass)
        newklass = Class.new(klass)
        newklass.module_eval {
          @definition = klass.module_eval { @definition }
          @symbols    = klass.module_eval { @symbols }
          @cont       = klass.module_eval { @cont }
        }
        newklass
      end

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
            r = super
            do_parse
            r
          }
        }
        klass
      end #def self.new_direct

      def self.symbols
        #p self
        @symbols
      end

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

      #Return original string for this record (usually just @str, but
      #sometimes add on the continuation data from other lines
      def original_data
        if defined?(@cont_data) then
          [ @str, *@cont_data ]
        else
          [ @str ]
        end
      end

      # initialize from the string
      def initialize_from_string(str)
        @str = str
        @record_name = fetch_record_name(str)
        @parsed = false
        self
      end

      #Called when we need to access the data, takes the string
      #and the array of FieldDefs and parses it out
      def do_parse
        return self if @parsed
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

      def fetch_record_name(str)
        str[0..5].strip
      end
      private :fetch_record_name

      def self.fetch_record_name(str)
        str[0..5].strip
      end
      private_class_method :fetch_record_name

      # If given str can be the continuation of the current record, then
      # then return the order number of the continuation associated with
      # the Pdb_Continuation field definition.
      # Otherwise, returns -1.
      def fetch_cont(str)
        (c = continue?) ? str[c].to_i : -1
      end
      private :fetch_cont

      def record_name
        @record_name or self.class.to_s.split(/\:\:/)[-1]
      end
      # keeping compatibility with old version
      alias record_type record_name

      # Adds continuation data to the record from str if str is
      # really the continuation of current record.
      # Returns self (= not nil) if str is the continuation.
      # Otherwaise, returns false.
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
          hash[x] =  const_get(x) if /\A[A-Z][A-Z0-9]+\z/ =~ x
        end
        if x = const_get(:Default) then
          hash.default = x
        end
        hash
      end

      def inspect
        #do_parse
        super
      end

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

      HEADER = 
        def_rec([ 11, 50, Pdb_String, :classification ], #Pdb_String(40)
                [ 51, 59, Pdb_Date,   :depDate ],
                [ 63, 66, Pdb_IDcode, :idCode ]
                )

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

      TITLE =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_String, :title ]
                )
        
      CAVEAT =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 12, 15, Pdb_IDcode, :idcode ],
                [ 20, 70, Pdb_String, :comment ]
                )

      COMPND =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_Specification_list, :compound ]
                )

      SOURCE =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_Specification_list, :srcName ]
                )

      KEYWDS =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_List, :keywds ]
                )

      EXPDTA =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_SList, :technique ]
                )

      AUTHOR =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 11, 70, Pdb_List, :authorList ]
                )

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
      
      MODRES =
        def_rec([  8, 11, Pdb_IDcode,       :idCode ],
                [ 13, 15, Pdb_Residue_name, :resName ],
                [ 17, 17, Pdb_Character,    :chainID ],
                [ 19, 22, Pdb_Integer,      :seqNum ],
                [ 23, 23, Pdb_AChar,        :iCode ],
                [ 25, 27, Pdb_Residue_name, :stdRes ],
                [ 30, 70, Pdb_String,       :comment ]
                )
      
      HET =
        def_rec([  8, 10, Pdb_LString(3), :hetID ],
                [ 13, 13, Pdb_Character,  :ChainID ],
                [ 14, 17, Pdb_Integer,    :seqNum ],
                [ 18, 18, Pdb_AChar,      :iCode ],
                [ 21, 25, Pdb_Integer,    :numHetAtoms ],
                [ 31, 70, Pdb_String,     :text ]
                )
      
      HETNAM =
        def_rec([ 9, 10,  Pdb_Continuation, nil ],
                [ 12, 14, Pdb_LString(3),   :hetID ],
                [ 16, 70, Pdb_String,       :text ]
                )
        
      HETSYN =
        def_rec([  9, 10, Pdb_Continuation, nil ],
                [ 12, 14, Pdb_LString(3),   :hetID ],
                [ 16, 70, Pdb_SList,        :hetSynonyms ]
                )
      
      FORMUL =
        def_rec([  9, 10, Pdb_Integer,    :compNum ],
                [ 13, 15, Pdb_LString(3), :hetID ],
                [ 17, 18, Pdb_Integer,    :continuation ],
                [ 19, 19, Pdb_Character,  :asterisk ],
                [ 20, 70, Pdb_String,     :text ]
                )
      
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
      
      # ORIGXn n=1, 2, or 3
      ORIGX1 =
        def_rec([ 11, 20, Pdb_Real('10.6'), :On1 ],
                [ 21, 30, Pdb_Real('10.6'), :On2 ],
                [ 31, 40, Pdb_Real('10.6'), :On3 ],
                [ 46, 55, Pdb_Real('10.5'), :Tn ]
                )
      
      ORIGX2 = new_inherit(ORIGX1)
      ORIGX3 = new_inherit(ORIGX1)

      # SCALEn n=1, 2, or 3
      SCALE1 =
        def_rec([ 11, 20, Pdb_Real('10.6'), :Sn1 ],
                [ 21, 30, Pdb_Real('10.6'), :Sn2 ],
                [ 31, 40, Pdb_Real('10.6'), :Sn3 ],
                [ 46, 55, Pdb_Real('10.5'), :Un ]
                )
      
      SCALE2 = new_inherit(SCALE1)
      SCALE3 = new_inherit(SCALE1)
      
      # MTRIXn n=1,2, or 3
      MTRIX1 =
        def_rec([  8, 10, Pdb_Integer,      :serial ],
                [ 11, 20, Pdb_Real('10.6'), :Mn1 ],
                [ 21, 30, Pdb_Real('10.6'), :Mn2 ],
                [ 31, 40, Pdb_Real('10.6'), :Mn3 ],
                [ 46, 55, Pdb_Real('10.5'), :Vn ],
                [ 60, 60, Pdb_Integer,      :iGiven ]
                )
      
      MTRIX2 = new_inherit(MTRIX1)
      MTRIX3 = new_inherit(MTRIX1)

      TVECT =
        def_rec([  8, 10, Pdb_Integer,      :serial ],
                [ 11, 20, Pdb_Real('10.5'), :t1 ],
                [ 21, 30, Pdb_Real('10.5'), :t2 ],
                [ 31, 40, Pdb_Real('10.5'), :t3 ],
                [ 41, 70, Pdb_String,       :text ]
                )

      MODEL =
        def_rec([ 11, 14, Pdb_Integer, :serial ]
                )
        # ChangeLog: model_serial are changed to serial
      
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

      class ATOM

        include Utils
        include Comparable

        # for backward compatibility
        alias occ  occupancy
        alias bfac tempFactor

        # residue the atom belongs to.
        attr_accessor :residue

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
          return self if @parsed
          self.serial     = @str[6..10].to_i
          self.name       = @str[12..15]
          self.altLoc     = @str[16..16]
          self.resName    = @str[17..19].rstrip
          self.chainID    = @str[21..21]
          self.resSeq     = @str[22..25].to_i
          self.iCode      = @str[26..26]
          self.x          = @str[30..37].to_f
          self.y          = @str[38..45].to_f
          self.z          = @str[46..53].to_f
          self.occupancy  = @str[54..59].to_f
          self.tempFactor = @str[60..65].to_f
          self.segID      = @str[72..75]
          self.element    = @str[76..77]
          self.charge     = @str[78..79]
          @parsed = true
          self
        end
      end #class ATOM

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

      HETATM = new_inherit(ATOM)

      ENDMDL =
        def_rec([  2,  1, Pdb_Integer, :serial ] # dummy field (always 0)
                )

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

      class Jrnl < self
        # subrecord of JRNL
        # 13, 16
        AUTH =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "AUTH"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_List,         :authorList ]
                  )

        TITL =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "TITL"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :title ]
                  )

        EDIT =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "EDIT"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_List,         :editorList ]
                  )

        REF =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "REF"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 47, Pdb_LString,      :pubName ],
                  [ 50, 51, Pdb_LString(2),   "V." ],
                  [ 52, 55, Pdb_String,       :volume ],
                  [ 57, 61, Pdb_String,       :page ],
                  [ 63, 66, Pdb_Integer,      :year ]
                  )

        PUBL =
          def_rec([ 13, 16, Pdb_String,       :sub_record ], # "PUBL"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :pub ]
                  )

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
        # ''
        Default =
          def_rec([ 13, 16, Pdb_String, :sub_record ]) # ""
        
        Definition = create_definition_hash
      end #class JRNL

      class Remark1 < self
        # 13, 16
        EFER =
          def_rec([  8, 10, Pdb_Integer,    :remarkNum ],  # "1"
                  [ 12, 20, Pdb_String,     :sub_record ], # "REFERENCE"
                  [ 22, 70, Pdb_Integer,    :refNum ]
                  )
        
        AUTH =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,       :sub_record ], # "AUTH"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_List,         :authorList ]
                  )
        
        TITL =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,       :sub_record ], # "TITL"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :title ]
                  )
        
        EDIT =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,       :sub_record ], # "EDIT"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :editorList ]
                  )
        
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
        
        PUBL =
          def_rec([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,       :sub_record ], # "PUBL"
                  [ 17, 18, Pdb_Continuation, nil ],
                  [ 20, 70, Pdb_LString,      :pub ]
                  )
        
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
        
        Default =
          def_rec([  8, 10, Pdb_Integer,    :remarkNum ],  # "1"
                  [ 13, 16, Pdb_String,     :sub_record ]  # ""
                  )

        Definition = create_definition_hash
      end #class Remark1

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
      
      RemarkN =
        def_rec([  8, 10, Pdb_Integer, :remarkNum ],
                [ 12, 70, Pdb_LString, :text ]
                )

      Default = def_rec([ 8, 70, Pdb_LString, :text ])

      Definition = create_definition_hash

      # because END is a reserved word of Ruby, it is separately
      # added to the hash
      End = 
        def_rec([  2,  1, Pdb_Integer, :serial ]) # dummy field (always 0)

      Definition['END'] = End

      # Basically just look up the class in Definition hash
      # do some munging for JRNL and REMARK
      def self.get_record_class(str)
        t = fetch_record_name(str)
        if d = Definition[t] then
          return d
        end
        case t
        when 'JRNL'
          d = Jrnl::Definition[str[12..15].to_s.strip]
        when 'REMARK'
          case str[7..9].to_i
          when 1
            d = Remark1::Definition[str[12..15].to_s.strip]
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
      'ENDMDL' => true,
      'ATOM'   => true,
      'HETATM' => true,
      'SIGATM' => true,
      'SIGUIJ' => true,
      'ANISOU' => true,
      'TER'    => true,
    }

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
      cModel   = Bio::PDB::Model.new
      cChain   = Bio::PDB::Chain.new
      cResidue = Bio::PDB::Residue.new

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
        case key
        when 'ATOM'
          residueID = "#{f.resSeq}#{f.iCode.strip}".strip
          #p f

          if f.chainID == cChain.id
            chain = cChain
          elsif !(chain = cModel[f.chainID])
            #If we don't have chain, add a new chain
            newChain = Chain.new(f.chainID, cModel)
            cModel.addChain(newChain)
            cChain = newChain
            chain = newChain
          end

          if !newChain and residueID == cResidue.id
            residue = cResidue
          elsif newChain or !(residue = chain[residueID])
            newResidue = Residue.new(f.resName, f.resSeq, f.iCode, chain)
            chain.addResidue(newResidue)
            cResidue = newResidue
            residue = newResidue
          end

          f.residue = residue
          residue.addAtom(f)

        when 'HETATM'

          #Each model has a special solvent chain
          #any chain id with the solvent is lost
          #I can fix this if really needed
          if f.resName == 'HOH'
            solvent =   Residue.new(f.resName, f.resSeq, f.iCode,
                                    cModel.solvent, true)
            #p solvent
            f.residue = solvent
            solvent.addAtom(f)
            cModel.addSolvent(solvent)
            
          else

            #Make residue we add 'LIGAND' to the id if it's a HETATM
            #I think this is neccessary because some PDB files reuse
            #numbers for HETATMS
            residueID = "#{f.resSeq}#{f.iCode.strip}".strip
            residueID = "LIGAND" + residueID
            #p f
            #p residueID

            if f.chainID == cChain.id
              chain = cChain
            elsif !(chain = cModel[f.chainID])
              #If we don't have chain, add a new chain
              newChain = Chain.new(f.chainID, cModel)
              cModel.addChain(newChain)
              cChain = newChain
              chain = newChain
            end

            if !newChain and residueID == cResidue.id
              residue = cResidue
            elsif newChain or !(residue = chain[residueID])
              newResidue = Residue.new(f.resName, f.resSeq, f.iCode,
                                       chain, true)
              chain.addLigand(newResidue)
              cResidue = newResidue
              residue = newResidue
            end

            f.residue = residue
            residue.addAtom(f)
            
          end

        when 'MODEL'
          if cModel.model_serial
            self.addModel(cModel)
          end
          model_serial = line[6,5]
          cModel = Model.new(model_serial)
        end
        f
      end #each
      #At the end we need to add the final model
      self.addModel(cModel)
      @data.compact!
    end #def initialize

    attr_reader :data, :hash

    #Adds a Bio::Model to the current strucutre
    def addModel(model)
      raise "Expecting a Bio::PDB::Model" if not model.is_a? Bio::PDB::Model
      @models.push(model)
      self
    end
    
    #Iterates over the models
    def each
      @models.each{ |model| yield model }
    end
    #Alias needed for Bio::PDB::ModelFinder
    alias each_model each
    
    #Provides keyed access to the models based on serial number
    #returns nil if it's not there (should it raise an exception?)
    def [](key)
      @models.find{ |model| key == model.model_serial }
    end
    
    #Stringifies to a list of atom records - we could add the annotation
    #as well if needed
    def to_s
      string = ""
      @models.each{ |model| string << model.to_s }
      string << "END"
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

    def record(name)
      @hash[name]
    end

    # PDB original methods
    #Returns a hash of the REMARK records based on the remarkNum
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

    #Returns a hash of journal entries
    def jrnl(sub_record = nil)
      unless defined?(@jrnl)
        @jrnl = make_hash(self.record('JRNL'), :sub_record)
      end
      sub_record ? @jrnl[sub_record] : @jrnl
    end

    #Finding methods - just grabs the record with the appropriate id
    #or returns and array of all of them
    def helix(helixID = nil)
      if helixID then
        self.record('HELIX').find { |f| f.helixID == helixID }
      else
        self.record('HELIX')
      end
    end

    def turn(turnId = nil)
      if turnId then
        self.record('TURN').find { |f| f.turnId == turnId }
      else
        self.record('TURN')
      end
    end

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

    def ssbond
      self.record('SSBOND')
    end

    #Get seqres - we get this to return a nice Bio::Seq object
    def seqres(chainID = nil)
      unless defined?(@seqres)
        h = make_hash(self.record('SEQRES'), :chainID)
        newHash = {}
        h.each do |k, a|
          a.collect! { |f| f.resName }
          a.flatten!
          a.collect!{ |aa|
            #aa is three letter code: i.e. ALA
            #need to look up with Ala
            aa = aa.capitalize
            aa = AminoAcid.names.invert[aa]
            aa = 'X' if aa.nil? 
          }
          newHash[k] = Bio::Sequence::AA.new(a.to_s)
        end
        @seqres = newHash
      end
      if chainID then
        @seqres[chainID]
      else
        @seqres
      end
    end

    def dbref(chainID = nil)
      if chainID then
        self.record('DBREF').find_all { |f| f.chainID == chainID }
      else
        self.record('DBREF')
      end
    end

    def keywords
      self.record('KEYWDS').collect { |f| f.keywds }.flatten
    end

    def classification
      self.record('HEADER').first.classification
    end

    # Bio::DB methods
    def entry_id
      @id = self.record('HEADER').first.idCode unless @id
      @id
    end

    def accession
      self.entry_id
    end

    def definition
      self.record('TITLE').first.title
    end

    def version
      self.record('REVDAT').first.modNum
    end

  end #class PDB

end #module Bio

=begin

= Caution

 This is a test version, specs of these class shall be changed.

= Bio::PDB < Bio::DB

 PDB File format class.

--- Bio::PDB.new(str)

 Creates new object.

--- Bio::PDB#entry_id

 PDB identifier written in "HEADER". (e.g. 1A00)

--- Bio::PDB#accession

 Same as Bio::PDB#entry_id

--- Bio::PDB#version

 Current modification number in "REVDAT".

--- Bio::PDB#definition

 Title of this entry in "TITLE".

--- Bio::PDB#keywords

 Keywords in "KEYWDS".
 Returns an array of string.

--- Bio::PDB#classification

 Classification in "HEADER".

--- Bio::PDB#record(name)

 Gets all records whose record type is 'name'.
 Returns an array of Bio::PDB::Record.

--- Bio::PDB#remark(number = nil)

 Gets REMARK records.
 If no arguments, it returns all REMARK records as a hash.
 If remark number is specified, returns only corresponding REMARK records.
 If number == 1 or 2 ("REMARK   1" or "REMARK   2"), returns an array
 of Bio::PDB::Record instances. Otherwise, returns an array of strings.

--- Bio::PDB#jrnl(sub_record = nil)

 Gets JRNL records.
 If no arguments, it returns all JRNL records as a hash.
 If sub record name is specified, it returns only corresponding records
 as an array of Bio::PDB::Record instances.

--- Bio::PDB#seqres(chainID = nil)

 Amino acid or nucleic acid sequence of backbone residues in "SEQRES".
 If chainID is given, it returns corresponding sequence as an array of string.
 Otherwise, returns a hash which contains all sequences.

--- Bio::PDB#helix(helixID = nil)

 Gets HELIX records.
 If no arguments are given, it returns all HELIX records.
 (Returns an array of Bio::PDB::Record instances.)
 If helixID is given, it only returns records corresponding to given helixID.
 (Returns an Bio::PDB::Record instance.)

--- Bio::PDB#sheet(sheetID = nil)

 Gets SHEET records.
 If no arguments are given, it returns all SHEET records as an array of
 arrays of Bio::PDB::Record instances.
 If sheetID is given, it returns an array of Bio::PDB::Record instances.

--- Bio::PDB#turn(turnId = nil)

 Gets TURN records.
 If no arguments are given, it returns all TURN records. 
 (Returns an array of Bio::PDB::Record instances.)
 If turnId is given, it only returns a record corresponding to given turnId.
 (Returns an Bio::PDB::Record instance.)

--- Bio::PDB.addModel(model)

 Adds a model to the current structure
 Returns self

--- Bio::PDB.each

 Iterates over each of the models in the structure
 Returns Bio::PDB::Models

--- Bio::PDB[](key)

 Returns the model with the given key as serial number

--- Bio::PDB.to_s

 Returns a string of Bio::PDB::Models. This propogates down the heirarchy
 till you get to Bio::PDB::Atoms which are outputed in PDB format


= Bio::PDB::Record < Hash

 A class for single PDB record.
 Basically, each line of a PDB file corresponds to an instance of the class.
 If continuation exists, multiple lines may correspond to single instance.

--- Bio::PDB::Record.new(line)

 Internal use only.
 Creates a new instance.

--- Bio::PDB::Record#add_continuation(line)

 Internal use only.
 If continuation is allowed and 'line' is a continuation of this record,
 it adds 'line' and returns self.
 Otherwise, returns false.

--- Bio::PDB::Record#original_data

 Original text (except that "\n" are truncated) of this record.
 Returns an array of string.

--- Bio::PDB::Record#record_type

 Record type of this record, e.g. "HEADER", "ATOM".

--- Bio::PDB::Record#do_parse

 In order to speeding up processing of PDB File format,
 fields have not been parsed before calling this method.

 If you want to use this class as a hash (not so recommended),
 you must call this method once.

 When accessing via rec.xxxxx style (described below), 
 do_parse is automatically called.

 Returns self

--- Bio::PDB::Record#"anything"

 Same as Bio::PDB::Record#[](:anything) after do_parse.
 For example, r.helixID is same as r.do_parse; r[:helixID] .


= Bio::PDB::FieldDef

 Internal use only.
 Format definition of each record.

= References

* ((<URL:http://www.rcsb.org/pdb/>))
* PDB File Format Contents Guide Version 2.2 (20 December 1996)
  ((<URL:http://www.rcsb.org/pdb/docs/format/pdbguide2.2/guide2.2_frame.html>))

=end
