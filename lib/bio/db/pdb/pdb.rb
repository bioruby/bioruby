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
#  $Id: pdb.rb,v 1.1 2004/03/08 07:30:40 ngoto Exp $
#

# *** CAUTION ***
# This is pre-alpha version. Specs shall be changed frequently.
#

require 'bio/db/pdb'
require 'bio/data/aa'

module Bio

  #This is the main PDB class which takes care of parsing, annotations
  #and is the entry way to the co-ordinate data held in models
  class PDB < DB

    include Utils
    include AtomFinder
    include ResidueFinder
    include ChainFinder
    include ModelFinder
    include Enumerable

    DELIMITER = RS = nil # 1 file 1 entry

    Pdb_Continuation = nil

    #Modules required by the field definitions
    module Pdb_Integer
      def self.new(str)
	str.strip.to_i
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
    end

    #Creates a new module with a string left justified to the
    #length given in nn
    def self.Pdb_String(nn)
      m = Module.new
      m.module_eval {
	@@nn = nn
	def self.new(str)
	  str.gsub(/\s+\z/, '').ljust(@@nn)[0, @@nn]
	end
      }
      m
    end

    Pdb_LString = String
    def self.Pdb_LString(nn)
      m = Module.new
      m.module_eval {
	@@nn = nn
	def self.new(str)
	  str.ljust(@@nn)[0, @@nn]
	end
      }
      m
    end

    def self.Pdb_Real(fmt)
      Pdb_String
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

    #Field definition class - each record contains a FieldDef which
    #contains an array of field definintions( range, type, symbol)
    #a hash of the symbols used, and a flag to say whether it continues
    #over muiltiple lines or not.
    #The symbol hash has symbols as keys and an array of types and string 
    #ranges as values
    class FieldDef

      def initialize(*ary)

	@definition = ary
	@symbols = {}
	@cont = false

        #For each field definition (range,type,symbol)
	ary.each do |x|
	  range = (x[0] - 1)..(x[1] - 1)
          #If type is nil (Pdb_Continuation) then set @cont to the range
          #(other wise it is false to indicate no continuation in this FieldDef
	  unless x[2] then
	    @cont = range
	  else
	    klass = x[2]
	    sym = x[3]
            #If the symbol is a proper symbol then...
	    if sym.is_a?(Symbol) then
              #..if we have the symbol already in the symbol hash
              #then add the range onto the range array
	      if @symbols.has_key?(sym) then
		@symbols[sym][1] << range
	      else
                #Other wise put a new symbol in with its type and range
                #range is given its own array, not sure why. Can you 
                #have anumber of ranges (I suppose so!)
		@symbols[sym] = [ klass, [ range ] ]
	      end
	    end
	  end
	end #each
      end #def initialize

      attr_reader :symbols
      def continue?
	@cont
      end

      #Each method - returns the symbol(k), type(x[0]) and range
      #of each symbol. Or rather the array of ranges(x[1])
      def each
	@symbols.each do |k, x|
	  yield k, x[0], x[1]
	end
      end
    end #class FieldDef

    #Record class - contains the original string, the type (str[0..5])
    #and the definition (looked up from the Definition hash). Each definition
    #is an array of FieldDef(s). parse is a flag to say whether the string
    #has been parsed. Parsing auto-generates hash entries using the symbol 
    #table. Remember Record is just a hash!
    class Record < Hash
      def initialize(str)
	@str = str
        #fetch_type just does str[0..5]
	@type = fetch_type(str)
        #get definition does the lookup in the Definition hash and some
        #munging if the type is JRNL or REMARK
	@definition = get_definition(str)
	@parse = nil
      end #def initialize

      attr_reader :definition
      def definition=(d)
	@definition = d
	@parse = false
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

      #Called when we need to access the data, takes the string
      #and the array of FieldDefs and parses it out
      def do_parse
	return self if @parse
	str = @str
        #.each returns the symbol (key), the type (klass) and range array
	@definition.each do |key, klass, ranges|
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
	end #each
        #If we have continuations then for each line of extra data...
	if defined?(@cont_data) then
	  @cont_data.each do |str|
            #Get the symbol, type and range array 
	    @definition.each do |key, klass, ranges|
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
	@parse = true
	self
      end

      def fetch_type(str)
	str[0..5].strip
      end
      private :fetch_type

      #If this can contiunue then return the str associated with the
      #Pdb_Continuation field definition. Hmmmm. Still not sure here
      def fetch_cont(str)
	(c = continue?) ? str[c].to_i : -1
      end
      private :fetch_cont

      def record_type
	@type
      end

      #Returns true if this record has a field type which allows 
      #continuations
      def continue?
	@definition.continue?
      end

      #Adds continuation data to the record from str
      def add_continuation(str)
        #Check that this record can continue
        #and that str has the same type and definition
	return false unless self.continue?
	return false unless fetch_type(str) == @type
	return false unless get_definition(str) == @definition
	return false unless fetch_cont(str) >= 2
        #If all this is OK then add onto @cont_data
	unless defined?(@cont_data)
	  @cont_data = []
	end
	@cont_data << str
	self
      end

      #Basically just look up the definition in Definition hash
      #do some munging for JRNL and REMARK
      def get_definition(str)
	d = Definition[@type]
	return d if d
	case @type
	when 'JRNL'
	  d = Def_JRNL[str[12..15].to_s.strip]
	  d = Def_JRNL[''] unless d
	when 'REMARK'
	  case str[7..9].to_i
	  when 1
	    d = Def_REMARK_1[str[12..15].to_s.strip]
	    d = Def_REMARK_1[''] unless d
	  when 2
	    if str[28..37] == 'ANGSTROMS.' then
	      d = Def_REMARK_2[0]
	    elsif str[22..37] == ' NOT APPLICABLE.' then
	      d = Def_REMARK_2[1]
	    else
	      d = Def_REMARK_2[2]
	    end
	  else
	    d = Def_REMARK_N
	  end
	else
	  # unknown field
	  d = Def_default
	end
	d
      end

      #The clever bit - doesn't parse anything until its asked for
      def method_missing(name)
	self.do_parse
	unless @definition.symbols[name] then
	  raise NameError, "undefiend method `#{name}' for #{@type} (#{self.class.to_s})"
	else
	  self[name]
	end
      end
    end #class Record


    #Definition hash - contains all the rules for parsing each field
    # based on format V 2.2, 16-DEC-1996
    #
    # http://www.rcsb.org/pdb/docs/format/pdbguide2.2/guide2.2_frame.html
    # http://www.rcsb.org/pdb/docs/format/pdbguide2.2/Contents_Guide_21.html
    #
    # Details of following data are taken from these documents.


    #1..6,  :Record_name, nil
    Definition = {
      # 'XXXXXX' => \
      # FieldDef.new([ start, end, type of data, symbol to access ], ...),

      'HEADER' => \
      FieldDef.new([ 11, 50, Pdb_String, :classification ], #Pdb_String(40)
		   [ 51, 59, Pdb_Date,   :depDate ],
		   [ 63, 66, Pdb_IDcode, :idCode ]
		   ),

      'OBSLTE' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
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
		   ),

      'TITLE' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
		   [ 11, 70, Pdb_String, :title ]
		   ),

      'CAVEAT' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
		   [ 12, 15, Pdb_IDcode, :idcode ],
		   [ 20, 70, Pdb_String, :comment ]
		   ),

      'COMPND' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
		   [ 11, 70, Pdb_Specification_list, :compound ]
		   ),

      'SOURCE' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
		   [ 11, 70, Pdb_Specification_list, :srcName ]
		   ),

      'KEYWDS' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
		   [ 11, 70, Pdb_List, :keywds ]
		   ),

      'EXPDTA' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
		   [ 11, 70, Pdb_SList, :technique ]
		   ),

      'AUTHOR' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
		   [ 11, 70, Pdb_List, :authorList ]
		   ),

      'REVDAT' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :modNum  ],
		   [ 11, 12, Pdb_Continuation, nil      ],
		   [ 14, 22, Pdb_Date,         :modDate ],
		   [ 24, 28, Pdb_String,       :modId   ], # Pdb_String(5)
		   [ 32, 32, Pdb_Integer,      :modType ],
		   [ 40, 45, Pdb_LString(6),   :record  ],
		   [ 47, 52, Pdb_LString(6),   :record  ],
		   [ 54, 59, Pdb_LString(6),   :record  ],
		   [ 61, 66, Pdb_LString(6),   :record  ]
		   ),

      'SPRSDE' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
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
		   ),

      # 'JRNL'
      'JRNL' => nil,

      # 'REMARK'
      'REMARK' => nil,

      'DBREF' => \
      FieldDef.new([  8, 11, Pdb_IDcode,    :idCode      ],
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
		   ),

      'SEQADV' => \
      FieldDef.new([  8, 11, Pdb_IDcode,       :idCode   ],
		   [ 13, 15, Pdb_Residue_name, :resName  ],
		   [ 17, 17, Pdb_Character,    :chainID  ],
		   [ 19, 22, Pdb_Integer,      :seqNum   ],
		   [ 23, 23, Pdb_AChar,        :iCode    ],
		   [ 25, 28, Pdb_String,       :database ], #Pdb_LString
		   [ 30, 38, Pdb_String,       :dbIdCode ], #Pdb_LString
		   [ 40, 42, Pdb_Residue_name, :dbRes    ],
		   [ 44, 48, Pdb_Integer,      :dbSeq    ],
		   [ 50, 70, Pdb_LString,      :conflict ]
		   ),

      'SEQRES' => \
      FieldDef.new(#[  9, 10, Pdb_Integer,      :serNum ],
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
		   ),

      'MODRES' => \
      FieldDef.new([  8, 11, Pdb_IDcode,       :idCode ],
		   [ 13, 15, Pdb_Residue_name, :resName ],
		   [ 17, 17, Pdb_Character,    :chainID ],
		   [ 19, 22, Pdb_Integer,      :seqNum ],
		   [ 23, 23, Pdb_AChar,        :iCode ],
		   [ 25, 27, Pdb_Residue_name, :stdRes ],
		   [ 30, 70, Pdb_String,       :comment ]
		   ),

      'HET' => \
      FieldDef.new([  8, 10, Pdb_LString(3), :hetID ],
		   [ 13, 13, Pdb_Character,  :ChainID ],
		   [ 14, 17, Pdb_Integer,    :seqNum ],
		   [ 18, 18, Pdb_AChar,      :iCode ],
		   [ 21, 25, Pdb_Integer,    :numHetAtoms ],
		   [ 31, 70, Pdb_String,     :text ]
		   ),

      'HETNAM' => \
      FieldDef.new([ 9, 10,  Pdb_Continuation, nil ],
		   [ 12, 14, Pdb_LString(3),   :hetID ],
		   [ 16, 70, Pdb_String,       :text ]
		   ),

      'HETSYN' => \
      FieldDef.new([  9, 10, Pdb_Continuation, nil ],
		   [ 12, 14, Pdb_LString(3),   :hetID ],
		   [ 16, 70, Pdb_SList,        :hetSynonyms ]
		   ),

      'FORMUL' =>
      FieldDef.new([  9, 10, Pdb_Integer,    :compNum ],
		   [ 13, 15, Pdb_LString(3), :hetID ],
		   [ 17, 18, Pdb_Integer,    :continuation ],
		   [ 19, 19, Pdb_Character,  :asterisk ],
		   [ 20, 70, Pdb_String,     :text ]
		   ),

      'HELIX' =>
      FieldDef.new([  8, 10, Pdb_Integer,      :serNum ],
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
		   ),

      'SHEET' =>
      FieldDef.new([  8, 10, Pdb_Integer,      :strand ],
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
		   ),

      'TURN' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :seq ],
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
		   ),

      'SSBOND' =>
      FieldDef.new([  8, 10, Pdb_Integer,    :serNum   ],
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
		   ),

      'LINK' => \
      FieldDef.new([ 13, 16, Pdb_Atom,         :name1 ],
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
		   ),

      'HYDBND' => \
      FieldDef.new([ 13, 16, Pdb_Atom,         :name1 ],
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
		   ),

      'SLTBRG' =>
      FieldDef.new([ 13, 16, Pdb_Atom,          :atom1 ],
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
		   ),

      'CISPEP' => \
      FieldDef.new([  8, 10, Pdb_Integer,     :serNum ],
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
		   ),

      'SITE' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :seqNum    ],
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
		   ),

      'CRYST1' => \
      FieldDef.new([  7, 15, Pdb_Real('9.3'), :a ],
		   [ 16, 24, Pdb_Real('9.3'), :b ],
		   [ 25, 33, Pdb_Real('9.3'), :c ],
		   [ 34, 40, Pdb_Real('7.2'), :alpha ],
		   [ 41, 47, Pdb_Real('7.2'), :beta ],
		   [ 48, 54, Pdb_Real('7.2'), :gamma ],
		   [ 56, 66, Pdb_LString,     :sGroup ],
		   [ 67, 70, Pdb_Integer,     :z ]
		   ),

      # ORIGXn n=1, 2, or 3
      'ORIGX1' => \
      FieldDef.new([ 11, 20, Pdb_Real('10.6'), :On1 ],
		   [ 21, 30, Pdb_Real('10.6'), :On2 ],
		   [ 31, 40, Pdb_Real('10.6'), :On3 ],
		   [ 46, 55, Pdb_Real('10.5'), :Tn ]
		   ),

      # SCALEn n=1, 2, or 3
      'SCALE1' => \
      FieldDef.new([ 11, 20, Pdb_Real('10.6'), :Sn1 ],
		   [ 21, 30, Pdb_Real('10.6'), :Sn2 ],
		   [ 31, 40, Pdb_Real('10.6'), :Sn3 ],
		   [ 46, 55, Pdb_Real('10.5'), :Un ]
		   ),

      # MTRIXn n=1,2, or 3
      'MTRIX1' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :serial ],
		   [ 11, 20, Pdb_Real('10.6'), :Mn1 ],
		   [ 21, 30, Pdb_Real('10.6'), :Mn2 ],
		   [ 31, 40, Pdb_Real('10.6'), :Mn3 ],
		   [ 46, 55, Pdb_Real('10.5'), :Vn ],
		   [ 60, 60, Pdb_Integer,      :iGiven ]
		   ),

      'TVECT' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :serial ],
		   [ 11, 20, Pdb_Real('10.5'), :t1 ],
		   [ 21, 30, Pdb_Real('10.5'), :t2 ],
		   [ 31, 40, Pdb_Real('10.5'), :t3 ],
		   [ 41, 70, Pdb_String,       :text ]
		   ),

      'MODEL' => \
      FieldDef.new(#[ 11, 14, Pdb_Integer, :serial ]
		   [ 11, 14, Pdb_Integer, :model_serial ],
		   [  2,  1, Pdb_Integer, :serial ] # dummy field (always 0)
		   ),

      'ATOM' => \
      FieldDef.new([  7, 11, Pdb_Integer,      :serial ],
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
		   ),

      'SIGATM' => \
      FieldDef.new([  7, 11, Pdb_Integer,      :serial ],
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
		   ),

      'ANISOU' => \
      FieldDef.new([  7, 11, Pdb_Integer,      :serial ],
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
		   ),

      'SIGUIJ' => \
      FieldDef.new([  7, 11, Pdb_Integer,      :serial ],
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
		   ),

      'TER' => \
      FieldDef.new([  7, 11, Pdb_Integer,      :serial ],
		   [ 18, 20, Pdb_Residue_name, :resName ],
		   [ 22, 22, Pdb_Character,    :chainID ],
		   [ 23, 26, Pdb_Integer,      :resSeq ],
		   [ 27, 27, Pdb_AChar,        :iCode ]
		   ),

      'HETATM' => \
      FieldDef.new([  7, 11, Pdb_Integer,      :serial ],
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
		   ),

      'ENDMDL' => \
      FieldDef.new([  2,  1, Pdb_Integer, :serial ] # dummy field (always 0)
		   ),

      'CONECT' => \
      FieldDef.new([  7, 11, Pdb_Integer, :serial ],
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
		   ),

      'MASTER' => \
      FieldDef.new([ 11, 15, Pdb_Integer, :numRemark ],
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
		   ),

      'END' => FieldDef.new(), 

      ''=> FieldDef.new()
    } #Definition

    # ORIGXn n=1, 2, or 3
    Definition['ORIGX2'] = Definition['ORIGX1']
    Definition['ORIGX3'] = Definition['ORIGX1']
    # SCALEn n=1, 2, or 3
    Definition['SCALE2'] = Definition['SCALE1']
    Definition['SCALE3'] = Definition['SCALE1']
    # MTRIXn n=1,2, or 3
    Definition['MTRIX2'] = Definition['MTRIX1']
    Definition['MTRIX3'] = Definition['MTRIX1']

    Def_JRNL = {
      # 13, 16
      'AUTH' => \
      FieldDef.new([ 13, 16, Pdb_String,       :sub_record ], # "AUTH"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 70, Pdb_List,         :authorList ]
		   ),

      'TITL' => \
      FieldDef.new([ 13, 16, Pdb_String,       :sub_record ], # "TITL"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 70, Pdb_LString,      :title ]
		   ),

      'EDIT' => \
      FieldDef.new([ 13, 16, Pdb_String,       :sub_record ], # "EDIT"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 70, Pdb_List,         :editorList ]
		   ),

      'REF' => \
      FieldDef.new([ 13, 16, Pdb_String,       :sub_record ], # "REF"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 47, Pdb_LString,      :pubName ],
		   [ 50, 51, Pdb_LString(2),   "V." ],
		   [ 52, 55, Pdb_String,       :volume ],
		   [ 57, 61, Pdb_String,       :page ],
		   [ 63, 66, Pdb_Integer,      :year ]
		   ),

      'PUBL' => \
      FieldDef.new([ 13, 16, Pdb_String,       :sub_record ], # "PUBL"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 70, Pdb_LString,      :pub ]
		   ),

      'REFN' => \
      FieldDef.new([ 13, 16, Pdb_String,     :sub_record ], # "REFN"
		   [ 20, 23, Pdb_LString(4), "ASTM" ], 
		   [ 25, 30, Pdb_LString(6), :astm ],
		   [ 33, 34, Pdb_LString(2), :country ],
		   [ 36, 39, Pdb_LString(4), :BorS ], # "ISBN" or "ISSN"
		   [ 41, 65, Pdb_LString,    :isbn ],
		   [ 67, 70, Pdb_LString(4), :coden ] # "0353" for unpublished
		   ),

      '' => \
      FieldDef.new([ 13, 16, Pdb_String, :sub_record ]) # ""
    } #Def_JRNL

    Def_REMARK_1 = {
      # 13, 16
      'EFER' => \
      FieldDef.new([  8, 10, Pdb_Integer,    :remarkNum ],  # "1"
		   [ 12, 20, Pdb_String,     :sub_record ], # "REFERENCE"
		   [ 22, 70, Pdb_Integer,    :refNum ]
		   ),

      'AUTH' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
		   [ 13, 16, Pdb_String,       :sub_record ], # "AUTH"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 70, Pdb_List,         :authorList ]
		   ),

      'TITL' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
		   [ 13, 16, Pdb_String,       :sub_record ], # "TITL"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 70, Pdb_LString,      :title ]
		   ),

      'EDIT' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
		   [ 13, 16, Pdb_String,       :sub_record ], # "EDIT"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 70, Pdb_LString,      :editorList ]
		   ),

      'REF' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
		   [ 13, 16, Pdb_LString(3),   :sub_record ], # "REF"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 47, Pdb_LString,      :pubName ],
		   [ 50, 51, Pdb_LString(2),   "V." ],
		   [ 52, 55, Pdb_String,       :volume ],
		   [ 57, 61, Pdb_String,       :page ],
		   [ 63, 66, Pdb_Integer,      :year ]
		   ),

      'PUBL' => \
      FieldDef.new([  8, 10, Pdb_Integer,      :remarkNum ],  # "1"
		   [ 13, 16, Pdb_String,       :sub_record ], # "PUBL"
		   [ 17, 18, Pdb_Continuation, nil ],
		   [ 20, 70, Pdb_LString,      :pub ]
		   ),

      'REFN' => \
      FieldDef.new([  8, 10, Pdb_Integer,    :remarkNum ],  # "1"
		   [ 13, 16, Pdb_String,     :sub_record ], # "REFN"
		   [ 20, 23, Pdb_LString(4), "ASTM" ],
		   [ 25, 30, Pdb_LString,    :astm ],
		   [ 33, 34, Pdb_LString,    :country ],
		   [ 36, 39, Pdb_LString(4), :BorS ],
		   [ 41, 65, Pdb_LString,    :isbn ],
		   [ 68, 70, Pdb_LString(4), :coden ]
		   ),

      '' => \
      FieldDef.new([  8, 10, Pdb_Integer,    :remarkNum ],  # "1"
		   [ 13, 16, Pdb_String,     :sub_record ]  # ""
		   )
    } #Def_REMARK_1

    Def_REMARK_2 = [
      # 29, 38 == 'ANGSTROMS.'
      FieldDef.new([  8, 10, Pdb_Integer,     :remarkNum ], # "2"
		   [ 12, 22, Pdb_LString(11), :sub_record ], # "RESOLUTION."
		   [ 23, 27, Pdb_Real('5.2'), :resolution ],
		   [ 29, 38, Pdb_LString(10), "ANGSTROMS." ]
		   ),

      # 23, 38 == ' NOT APPLICABLE.'
      FieldDef.new([  8, 10, Pdb_Integer,     :remarkNum ], # "2"
		   [ 12, 22, Pdb_LString(11), :sub_record ], # "RESOLUTION."
		   [ 23, 38, Pdb_LString(16), :resolution ], # " NOT APPLICABLE."
		   [ 41, 70, Pdb_String,      :comment ]
		   ),

      # others
      FieldDef.new([  8, 10, Pdb_Integer,     :remarkNum ], # "2"
		   [ 12, 22, Pdb_LString(11), :sub_record ], # "RESOLUTION."
		   [ 24, 70, Pdb_String,      :comment ]
		   ),
    ] #Def_REMARK_2

    Def_REMARK_N = 
      FieldDef.new([  8, 10, Pdb_Integer, :remarkNum ],
		   [ 12, 70, Pdb_LString, :text ]
		   )

    Def_default = 
      FieldDef.new([ 8, 70, Pdb_LString, :text ])

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

    #Aha! Our entry into the world of PDB parsing, we initialise a PDB
    #object with the whole PDB file as a string
    #each PDB has an array of the lines of the original file
    #a bit memory-tastic! A hash of records and an array of models
    #also has an id
    def initialize(str)

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
	f = Record.new(line)
        #Set cont
	cont = f if f.continue?
        #Set the hash to point to this record either by adding to an
        #array, or on it's own
	key = f.record_type
	if a = @hash[key] then
	  a << f
	else
	  @hash[key] = [ f ]
	end

        #The meat of the atom parsing - could be speeded up I think
	if key == 'ATOM' or key == 'HETATM' then

          #Do my own parsing here because this is speed critical
          #This makes it x5 faster because otherwise you're calling
          #methods on f all the time
          serial     = line[6,5].to_i
          name       = line[12,4].strip
          altLoc     = line[16,1].strip
          resName    = line[17,3].strip
          chainID    = line[21,1].strip
          resSeq     = line[22,4].to_i
          iCode      = line[26,1].strip
          x          = line[30,8].to_f
          y          = line[38,8].to_f
          z          = line[46,8].to_f
          occupancy  = line[54,6].to_f
          tempFactor = line[60,6].to_f

          #Each model has a special solvent chain
          #any chain id with the solvent is lost
          #I can fix this if really needed
          if key == 'HETATM' and resName == 'HOH'
            solvent =   Residue.new(resName,resSeq,iCode,
                                    cModel.solvent,true)
            solvent_atom = Atom.new(serial,name,altLoc,
                                    x,y,z,
                                    occupancy,tempFactor,
                                    solvent)
            solvent.addAtom(solvent_atom)
            cModel.addSolvent(solvent)
            
          else

            #Make residue we add 'LIGAND' to the id if it's a HETATM
            #I think this is neccessary because some PDB files reuse
            #numbers for HETATMS
            residueID = "#{resSeq}#{iCode}".strip
            if key == 'HETATM'
              residueID = "LIGAND" << residueID
            end
            
            #If this atom is part of the current residue then add it to
            #the current residue straight away
            if chainID == cChain.id and residueID == cResidue.id
              
              #If we have this chain and residue just add the atom
              atom = Atom.new(serial,name,altLoc,
                              x,y,z,
                              occupancy,tempFactor,
                              cResidue)
              cResidue.addAtom(atom) 

            elsif !cModel[chainID]
              
              #If we don't have anyhting, add a new chain, residue and atom
              newChain   = Chain.new(chainID,cModel)
              cModel.addChain(newChain)
              
              if key == 'ATOM'
                newResidue = Residue.new(resName,resSeq,iCode,
                                         newChain)
                newChain.addResidue(newResidue)
              else
                newResidue = Residue.new(resName,resSeq,iCode,
                                         newChain,true)
                newChain.addLigand(newResidue)
              end
              
              atom = Atom.new(serial,name,altLoc,
                              x,y,z,
                              occupancy,tempFactor,
                              newResidue)
              newResidue.addAtom(atom)
              
              cChain   = newChain
              cResidue = newResidue

            elsif !cModel[chainID][residueID]

              #If we have the chain (but not the residue)
              #make a new residue, add it and add the atom
              chain = cModel[chainID]
              
              if key == 'ATOM'
                newResidue = Residue.new(resName,resSeq,iCode,
                                         chain)
                chain.addResidue(newResidue)
              else
                newResidue = Residue.new(resName,resSeq,iCode,
                                         chain,true)
                chain.addLigand(newResidue)
              end
              
              atom = Atom.new(serial,name,altLoc,
                              x,y,z,
                              occupancy,tempFactor,
                              newResidue)
              newResidue.addAtom(atom)
              
              cResidue = newResidue
              
            end
          end
        elsif key == 'MODEL'
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
    alias :each_model :each
    
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
