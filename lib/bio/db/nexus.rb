#
# = bio/db/nexus.rb - Nexus Standard phylogenetic tree parser / formatter
#
# Copyright::  Copyright (C) 2006        Christian M Zmasek <cmzmasek@yahoo.com>
#
# License::    The Ruby License
#
# $Id: nexus.rb,v 1.3 2007/04/05 23:35:40 trevor Exp $
#
# == Description
#
# This file contains classes that implement a parser for NEXUS formatted
# data as well as objects to store, access, and write the parsed data.
#
# The following five blocks:
# taxa, characters, distances, trees, data
# are recognizable and parsable.
#
# The parser can deal with (nested) comments (indicated by square brackets),
# unless the comments are inside a command or data item (e.g. 
# "Dim[comment]ensions" or inside a matrix).
#
# Single or double quoted TaxLabels are processed as follows (by way
# of example): "mus musculus" -> mus_musculus
#
#
# == USAGE
#
#   require 'bio/db/nexus'
#
#   # Create a new parser:
#   nexus = Bio::Nexus.new( nexus_data_as_string )
#
#   # Get first taxa block:   
#   taxa_block = nexus.get_taxa_blocks[ 0 ]
#   # Get number of taxa:
#   number_of_taxa = taxa_block.get_number_of_taxa.to_i
#   # Get name of first taxon:
#   first_taxon = taxa_block.get_taxa[ 0 ]
#
#   # Get first data block:   
#   data_block = nexus.get_data_blocks[ 0 ]
#   # Get first characters name:
#   seq_name = data_block.get_row_name( 0 )
#   # Get first characters row named "taxon_2" as Bio::Sequence sequence:
#   seq_tax_2 = data_block.get_sequences_by_name( "taxon_2" )[ 0 ]
#   # Get third characters row as Bio::Sequence sequence:
#   seq_2 = data_block.get_sequence( 2 )
#   # Get first characters row named "taxon_3" as String:   
#   string_tax_3 = data_block.get_characters_strings_by_name( "taxon_3" )
#   # Get name of first taxon:
#   taxon_0 = data_block.get_taxa[ 0 ]
#   # Get characters matrix as Bio::Nexus::NexusMatrix (names are in column 0)
#   characters_matrix = data_block.get_matrix
#
#   # Get first characters block (same methods as Nexus::DataBlock except
#   # it lacks get_taxa method):   
#   characters_block = nexus.get_characters_blocks[ 0 ]
#   
#   # Get trees block(s):   
#   trees_block = nexus.get_trees_blocks[ 0 ]
#   # Get first tree named "best" as String:
#   string_fish = trees_block.get_tree_strings_by_name( "best" )[ 0 ]
#   # Get first tree named "best" as Bio::Db::Newick object:
#   tree_fish = trees_block.get_trees_by_name( "best" )[ 0 ]
#   # Get first tree as Bio::Db::Newick object:
#   tree_first = trees_block.get_tree( 0 )
#
#   # Get distances block(s):   
#   distances_blocks = nexus.get_distances_blocks
#   # Get matrix as Bio::Nexus::NexusMatrix object:
#   matrix = distances_blocks[ 0 ].get_matrix
#   # Get value (column 0 are names):
#   val = matrix.get_value( 1, 5 )
#
#   # Get blocks for which no class exists (private blocks):
#   private_blocks = nexus.get_blocks_by_name( "my_block" )
#   # Get first block names "my_block":
#   my_block_0 = private_blocks[ 0 ]
#   # Get first token in first block names "my_block":
#   first_token = my_block_0.get_tokens[ 0 ]
#
#
# == References
#
# * Maddison DR, Swofford DL, Maddison WP (1997). NEXUS: an extensible file
#   format for systematic information. 
#   Syst Biol. 1997 46(4):590-621. 
#

require 'bio/sequence'
require 'bio/tree'
require 'bio/db/newick'

module Bio
  
  # == DESCRIPTION
  # Bio::Nexus is a parser for nexus formatted data.
  # It contains classes and constants enabling the representation and
  # processing of nexus data.
  #
  # == USAGE
  #
  #   # Parsing a nexus formatted string str:
  #   nexus = Bio::Nexus.new( nexus_str )
  #   
  #   # Obtaining of the nexus blocks as array of GenericBlock or
  #   # any of its subclasses (such as DistancesBlock):
  #   blocks = nexus.get_blocks
  #
  #   # Getting a block by name:
  #   my_blocks = nexus.get_blocks_by_name( "my_block" )
  #
  #   # Getting distance blocks:
  #   distances_blocks = nexus.get_distances_blocks
  #
  #   # Getting trees blocks:
  #   trees_blocks = nexus.get_trees_blocks
  #
  #   # Getting data blocks:
  #   data_blocks = nexus.get_data_blocks
  #
  #   # Getting characters blocks: 
  #   character_blocks = nexus.get_characters_blocks
  #
  #   # Getting taxa blocks: 
  #   taxa_blocks = nexus.get_taxa_blocks
  #
  class Nexus
    
   
    END_OF_LINE      = "\n"
    INDENTENTION     = " "
    DOUBLE_QUOTE     = "\""
    SINGLE_QUOTE     = "'"
    
    
    BEGIN_NEXUS      = "#NEXUS"
    DELIMITER        = ";"
    BEGIN_BLOCK      = "Begin"
    END_BLOCK        = "End" + DELIMITER
    BEGIN_COMMENT    = "["
    END_COMMENT      = "]"
    
    
    TAXA             = "Taxa"
    CHARACTERS       = "Characters"
    DATA             = "Data"
    DISTANCES        = "Distances"
    TREES            = "Trees"
    TAXA_BLOCK       = TAXA + DELIMITER
    CHARACTERS_BLOCK = CHARACTERS + DELIMITER
    DATA_BLOCK       = DATA + DELIMITER
    DISTANCES_BLOCK  = DISTANCES + DELIMITER
    TREES_BLOCK      = TREES + DELIMITER
    
    
    DIMENSIONS       = "Dimensions"
    FORMAT           = "Format"
    NTAX             = "NTax"
    NCHAR            = "NChar"
    DATATYPE         = "DataType"
    TAXLABELS        = "TaxLabels"
    MATRIX           = "Matrix"
    # End of constants.
    
 
    # Nexus parse error class, 
    # indicates error during parsing of nexus formatted data.
    class NexusParseError < RuntimeError; end

    # Creates a new nexus parser for 'nexus_str'.  
    #
    # ---
    # *Arguments*:
    # * (required) _nexus_str_: String - nexus formatted data
    def initialize( nexus_str )
      @blocks             = Array.new
      @current_cmd        = nil
      @current_subcmd     = nil
      @current_block_name = nil
      @current_block      = nil
      parse( nexus_str )
    end
  
   
    # Returns an Array of all blocks found in the String 'nexus_str'
    # set via Bio::Nexus.new( nexus_str ).
    #
    # ---
    # *Returns*:: Array of GenericBlocks or any of its subclasses  
    def get_blocks
      @blocks
    end
    
    # A convenience methods which returns an array of
    # all nexus blocks for which the name equals 'name' found
    # in the String 'nexus_str' set via Bio::Nexus.new( nexus_str ).
    #
    # ---
    # *Arguments*:
    # * (required) _name_: String
    # *Returns*:: Array of GenericBlocks or any of its subclasses 
    def get_blocks_by_name( name )
      found_blocks = Array.new
      @blocks.each do | block |
        if ( name == block.get_name )
          found_blocks.push( block )
        end
      end
      found_blocks
    end
    
    # A convenience methods which returns an array of
    # all data blocks.
    #
    # ---
    # *Returns*:: Array of DataBlocks 
    def get_data_blocks
      get_blocks_by_name( DATA_BLOCK.chomp( ";").downcase )
    end
    
    # A convenience methods which returns an array of
    # all characters blocks.
    #
    # ---
    # *Returns*:: Array of CharactersBlocks
    def get_characters_blocks
      get_blocks_by_name( CHARACTERS_BLOCK.chomp( ";").downcase )
    end
    
    # A convenience methods which returns an array of
    # all trees blocks.
    #
    # ---
    # *Returns*:: Array of TreesBlocks
    def get_trees_blocks
      get_blocks_by_name( TREES_BLOCK.chomp( ";").downcase )
    end
    
    # A convenience methods which returns an array of
    # all distances blocks.
    #
    # ---
    # *Returns*:: Array of DistancesBlock   
    def get_distances_blocks
      get_blocks_by_name( DISTANCES_BLOCK.chomp( ";").downcase )
    end
    
    # A convenience methods which returns an array of
    # all taxa blocks.
    #
    # ---
    # *Returns*:: Array of TaxaBlocks
    def get_taxa_blocks
      get_blocks_by_name( TAXA_BLOCK.chomp( ";").downcase )
    end
  
    # Returns a String listing how many of each blocks it parsed.
    #
    # ---
    # *Returns*:: String 
    def to_s
      str = String.new
      if get_blocks.length < 1
        str << "empty"
      else 
        str << "number of blocks: " << get_blocks.length.to_s
        if get_characters_blocks.length > 0
          str << " [characters blocks: " << get_characters_blocks.length.to_s << "] "
        end  
        if get_data_blocks.length > 0
          str << " [data blocks: " << get_data_blocks.length.to_s << "] "
        end
        if get_distances_blocks.length > 0
          str << " [distances blocks: " << get_distances_blocks.length.to_s << "] "
        end  
        if get_taxa_blocks.length > 0
          str << " [taxa blocks: " << get_taxa_blocks.length.to_s << "] "
        end    
        if get_trees_blocks.length > 0
          str << " [trees blocks: " << get_trees_blocks.length.to_s << "] "
        end        
      end
      str
    end
    alias to_str to_s
  
    private
    
    # The master method for parsing.
    # Stores the resulting block in array @blocks.
    #
    # ---
    # *Arguments*:
    # * (required) _str_: String - the String to be parsed
    def parse( str )
      str = str.chop if str[-1..-1] == ';'
      ary = str.split(/[\s+=]/)
      ary.collect! { |x| x.strip!; x.empty? ? nil : x }
      ary.compact!
      in_comment = false
      comment_level = 0
     
      # Main loop
      while token = ary.shift
        # Quotes:
        if ( token.index( SINGLE_QUOTE ) == 0 ||
             token.index( DOUBLE_QUOTE ) == 0 )
          token << "_" << ary.shift
          token = token.chop if token[-1..-1] == ';'
          token = token.slice( 1, token.length - 2 )
        end
        # Comments: 
        open = token.count( BEGIN_COMMENT )
        close = token.count( END_COMMENT )
        comment = comment_level > 0
        comment_level = comment_level + open - close
        if ( open > 0 && open == close  )
          next
        elsif comment_level > 0 || comment
          next
        elsif equal?( token, END_BLOCK )
          end_block()
        elsif equal?( token, BEGIN_BLOCK )
          begin_block()
          @current_block_name = token = ary.shift
          @current_block_name.downcase!
          @current_block = create_block()
          @blocks.push( @current_block )
        elsif ( @current_block_name != nil )  
          process_token( token.chomp( DELIMITER ), ary )
        end
      end # main loop
      @blocks.compact!
    end # parse
    
    # Operations required when beginnig of block encountered.
    # 
    # --- 
    def begin_block() 
      if @current_block_name != nil
        raise NexusParseError, "Cannot have nested nexus blocks (\"end;\" might be missing)"
      end
      reset_command_state()
    end
    
    # Operations required when ending of block encountered.
    # 
    # ---
    def end_block()
      if @current_block_name == nil
        raise NexusParseError, "Cannot have two or more \"end;\" tokens in sequence"
      end
      @current_block_name = nil
    end
    
    # This calls various process_token_for_<name>_block methods
    # depeding on state of @current_block_name.
    #
    # ---
    # *Arguments*:
    # * (required) _token_: String
    # * (required) _ary_: Array
    def process_token( token, ary )
      case @current_block_name
        when TAXA_BLOCK.downcase
          process_token_for_taxa_block( token )
        when CHARACTERS_BLOCK.downcase
          process_token_for_character_block( token, ary )
        when DATA_BLOCK.downcase
          process_token_for_data_block( token, ary )
        when DISTANCES_BLOCK.downcase
          process_token_for_distances_block( token, ary )
        when TREES_BLOCK.downcase  
          process_token_for_trees_block( token, ary )
        else
          process_token_for_generic_block( token )  
      end
    end
    
    # Resets @current_cmd and @current_subcmd to nil.
    #
    # ---
    def reset_command_state()
      @current_cmd    = nil
      @current_subcmd = nil
    end
    
    # Creates GenericBlock (or any of its subclasses) the type of
    # which is determined by the state of @current_block_name.
    #
    # ---
    # *Returns*:: GenericBlock (or any of its subclasses) object
    def create_block()
      case @current_block_name
        when TAXA_BLOCK.downcase
          return Bio::Nexus::TaxaBlock.new( @current_block_name )
        when CHARACTERS_BLOCK.downcase
          return Bio::Nexus::CharactersBlock.new( @current_block_name )
        when DATA_BLOCK.downcase
          return Bio::Nexus::DataBlock.new( @current_block_name )
        when DISTANCES_BLOCK.downcase
          return Bio::Nexus::DistancesBlock.new( @current_block_name )
        when TREES_BLOCK.downcase
          return Bio::Nexus::TreesBlock.new( @current_block_name )
        else
          return Bio::Nexus::GenericBlock.new( @current_block_name )
      end 
    end 
  
    # This processes the tokens (between Begin Taxa; and End;) for a taxa block 
    # Example of a currently parseable taxa block:
    # Begin Taxa;
    #  Dimensions NTax=4;
    #  TaxLabels fish [comment] 'african frog' "rat snake" 'red mouse';
    # End;
    #
    # ---
    # *Arguments*:
    # * (required) _token_: String
    def process_token_for_taxa_block( token )
      if ( equal?( token, DIMENSIONS ) )
        @current_cmd    = DIMENSIONS
        @current_subcmd = nil
      elsif ( equal?( token, TAXLABELS ) )
        @current_cmd    = TAXLABELS
        @current_subcmd = nil
      elsif ( @current_cmd == DIMENSIONS && equal?( token, NTAX ) )
        @current_subcmd = NTAX
      elsif ( cmds_equal_to?( DIMENSIONS, NTAX ) )
        @current_block.set_number_of_taxa( token )
      elsif ( cmds_equal_to?( TAXLABELS, nil ) )
        @current_block.add_taxon( token )
      end
    end
    
    # This processes the tokens (between Begin Taxa; and End;) for a character
    # block 
    # Example of a currently parseable character block:
    # Begin Characters;
    # Dimensions NChar=20
    #             NTax=4;
    # Format DataType=DNA
    # Missing=x
    # Gap=- MatchChar=.;
    # Matrix
    # fish  ACATA GAGGG TACCT CTAAG
    # frog  ACTTA GAGGC TACCT CTAGC
    # snake ACTCA CTGGG TACCT TTGCG
    # mouse ACTCA GACGG TACCT TTGCG;
    # End;
    #
    # ---
    # *Arguments*:
    # * (required) _token_: String
    # * (required) _ary_: Array
    def process_token_for_character_block( token, ary )
      if ( equal?( token, DIMENSIONS ) )
        @current_cmd    = DIMENSIONS
        @current_subcmd = nil
      elsif ( equal?( token, FORMAT ) )
        @current_cmd    = FORMAT
        @current_subcmd = nil  
      elsif ( equal?( token, MATRIX ) )
        @current_cmd    = MATRIX
        @current_subcmd = nil
      elsif ( @current_cmd == DIMENSIONS && equal?( token, NTAX ) )
        @current_subcmd = NTAX
      elsif ( @current_cmd == DIMENSIONS && equal?( token, NCHAR ) )
        @current_subcmd = NCHAR
      elsif ( @current_cmd == FORMAT && equal?( token, DATATYPE ) )
        @current_subcmd = DATATYPE
      elsif ( @current_cmd == FORMAT && equal?( token, CharactersBlock::MISSING ) )
        @current_subcmd = CharactersBlock::MISSING 
      elsif ( @current_cmd == FORMAT && equal?( token, CharactersBlock::GAP ) )
        @current_subcmd = CharactersBlock::GAP
      elsif ( @current_cmd == FORMAT && equal?( token, CharactersBlock::MATCHCHAR ) )
        @current_subcmd = CharactersBlock::MATCHCHAR  
      elsif ( cmds_equal_to?( DIMENSIONS, NTAX ) )
        @current_block.set_number_of_taxa( token )
      elsif ( cmds_equal_to?( DIMENSIONS, NCHAR ) )
        @current_block.set_number_of_characters( token )  
      elsif ( cmds_equal_to?( FORMAT, DATATYPE ) )
        @current_block.set_datatype( token )
      elsif ( cmds_equal_to?( FORMAT, CharactersBlock::MISSING ) )
        @current_block.set_missing( token )
      elsif ( cmds_equal_to?( FORMAT, CharactersBlock::GAP ) )
        @current_block.set_gap_character( token )
      elsif ( cmds_equal_to?( FORMAT, CharactersBlock::MATCHCHAR ) )
        @current_block.set_match_character( token )  
      elsif ( cmds_equal_to?( MATRIX, nil ) )
        @current_block.set_matrix( make_matrix( token, ary,
                                   @current_block.get_number_of_characters, true ) )
      end
    end
    
    # This processes the tokens (between Begin Trees; and End;) for a trees block 
    # Example of a currently parseable taxa block:
    # Begin Trees;
    # Tree best=(fish,(frog,(snake, mouse)));
    # Tree other=(snake,(frog,( fish, mouse)));
    # End;
    #
    # ---
    # *Arguments*:
    # * (required) _token_: String
    # * (required) _ary_: Array 
    def process_token_for_trees_block( token, ary )
      if ( equal?( token, TreesBlock::TREE ) )
        @current_cmd    = TreesBlock::TREE
        @current_subcmd = nil
      elsif ( cmds_equal_to?( TreesBlock::TREE, nil ) )
        @current_block.add_tree_name( token )
        tree_string = ary.shift
        while ( tree_string.index( ";" ) == nil )
          tree_string << ary.shift
        end
        @current_block.add_tree( tree_string )
        @current_cmd    = nil
      end  
    end
    
    # This processes the tokens (between Begin Taxa; and End;) for a character
    # block. 
    # Example of a currently parseable character block:
    # Begin Distances;
    #  Dimensions nchar=20 ntax=5;
    #  Format Triangle=Upper;
    #  Matrix
    #  taxon_1 0.0 1.0 2.0 4.0 7.0
    #  taxon_2 1.0 0.0 3.0 5.0 8.0
    #  taxon_3 3.0 4.0 0.0 6.0 9.0
    #  taxon_4 7.0 3.0 1.0 0.0 9.5
    #  taxon_5 1.2 1.3 1.4 1.5 0.0;
    # End;
    #
    # ---
    # *Arguments*:
    # * (required) _token_: String
    # * (required) _ary_: Array 
    def process_token_for_distances_block( token, ary )
      if ( equal?( token, DIMENSIONS ) )
        @current_cmd    = DIMENSIONS
        @current_subcmd = nil
      elsif ( equal?( token, FORMAT ) )
        @current_cmd    = FORMAT
        @current_subcmd = nil  
      elsif ( equal?( token, MATRIX ) )
        @current_cmd    = MATRIX
        @current_subcmd = nil
      elsif ( @current_cmd == DIMENSIONS && equal?( token, NTAX ) )
        @current_subcmd = NTAX
      elsif ( @current_cmd == DIMENSIONS && equal?( token, NCHAR ) )
        @current_subcmd = NCHAR
      elsif ( @current_cmd == FORMAT && equal?( token, DATATYPE ) )
        @current_subcmd = DATATYPE
      elsif ( @current_cmd == FORMAT && equal?( token, DistancesBlock::TRIANGLE ) )
        @current_subcmd = DistancesBlock::TRIANGLE   
      elsif ( cmds_equal_to?( DIMENSIONS, NTAX ) )
        @current_block.set_number_of_taxa( token )
      elsif ( cmds_equal_to?( DIMENSIONS, NCHAR ) )
        @current_block.set_number_of_characters( token )  
      elsif ( cmds_equal_to?( FORMAT, DistancesBlock::TRIANGLE ) )
        @current_block.set_triangle( token )
      elsif ( cmds_equal_to?( MATRIX, nil ) )
        @current_block.set_matrix( make_matrix( token, ary,
                                   @current_block.get_number_of_taxa, false ) )
      end
    end
    
    # This processes the tokens (between Begin Taxa; and End;) for a data
    # block. 
    # Example of a currently parseable data block:
    # Begin Data;
    # Dimensions ntax=5 nchar=14;
    # Format Datatype=RNA gap=# MISSING=x MatchChar=^;
    # TaxLabels ciona cow [comment] ape 'purple urchin' "green lizard";
    # Matrix
    # taxon_1 A- CCGTCGA-GTTA
    # taxon_2 T- CCG-CGA-GATA
    # taxon_3 A- C-GTCGA-GATA
    # taxon_4 A- CCTCGA--GTTA
    # taxon_5 T- CGGTCGT-CTTA;
    # End;
    #
    # ---
    # *Arguments*:
    # * (required) _token_: String
    # * (required) _ary_: Array
    def process_token_for_data_block( token, ary )
      if ( equal?( token, DIMENSIONS ) )
        @current_cmd    = DIMENSIONS
        @current_subcmd = nil
      elsif ( equal?( token, FORMAT ) )
        @current_cmd    = FORMAT
        @current_subcmd = nil
      elsif ( equal?( token, TAXLABELS ) )
        @current_cmd    = TAXLABELS
        @current_subcmd = nil  
      elsif ( equal?( token, MATRIX ) )
        @current_cmd    = MATRIX
        @current_subcmd = nil
      elsif ( @current_cmd == DIMENSIONS && equal?( token, NTAX ) )
        @current_subcmd = NTAX
      elsif ( @current_cmd == DIMENSIONS && equal?( token, NCHAR ) )
        @current_subcmd = NCHAR
      elsif ( @current_cmd == FORMAT && equal?( token, DATATYPE ) )
        @current_subcmd = DATATYPE
      elsif ( @current_cmd == FORMAT && equal?( token, CharactersBlock::MISSING ) )
        @current_subcmd = CharactersBlock::MISSING 
      elsif ( @current_cmd == FORMAT && equal?( token, CharactersBlock::GAP ) )
        @current_subcmd = CharactersBlock::GAP
      elsif ( @current_cmd == FORMAT && equal?( token, CharactersBlock::MATCHCHAR ) )
        @current_subcmd = CharactersBlock::MATCHCHAR  
      elsif ( cmds_equal_to?( DIMENSIONS, NTAX ) )
        @current_block.set_number_of_taxa( token )
      elsif ( cmds_equal_to?( DIMENSIONS, NCHAR ) )
        @current_block.set_number_of_characters( token )  
      elsif ( cmds_equal_to?( FORMAT, DATATYPE ) )
        @current_block.set_datatype( token )
      elsif ( cmds_equal_to?( FORMAT, CharactersBlock::MISSING ) )
        @current_block.set_missing( token )
      elsif ( cmds_equal_to?( FORMAT, CharactersBlock::GAP ) )
        @current_block.set_gap_character( token )
      elsif ( cmds_equal_to?( FORMAT, CharactersBlock::MATCHCHAR ) )
        @current_block.set_match_character( token )
      elsif ( cmds_equal_to?( TAXLABELS, nil ) )
        @current_block.add_taxon( token ) 
      elsif ( cmds_equal_to?( MATRIX, nil ) )
        @current_block.set_matrix( make_matrix( token, ary,
                                   @current_block.get_number_of_characters, true ) )
      end
    end
    
    # Makes a NexusMatrix out of token from token Array ary
    # Used by process_token_for_X_block methods which contain
    # data in a matrix form. Column 0 contains names.
    # This will shift tokens from ary.
    # ---
    # *Arguments*:
    # * (required) _token_: String
    # * (required) _ary_: Array
    # * (required) _size_: Integer
    # * (optional) _scan_token_: true or false 
    # *Returns*:: NexusMatrix
    def make_matrix( token, ary, size, scan_token = false )
      matrix = NexusMatrix.new
      col = -1
      row = 0
      done = false
      while ( !done )
        if ( col == -1 )
          # name
          col = 0
          matrix.set_value( row, col, token ) # name is in col 0  
        else
          # values
          col = add_token_to_matrix( token, scan_token, matrix, row, col )
          if ( col == size.to_i  )
            col = -1
            row += 1
          end
        end
        token = ary.shift
        if ( token.index( DELIMITER ) != nil )
          col = add_token_to_matrix( token.chomp( ";" ), scan_token, matrix, row, col )
          done = true
        end
      end # while
      matrix
    end
    
    # Helper method for make_matrix.
    #
    # ---
    # *Arguments*:
    # * (required) _token_: String
    # * (required) _scan_token_: true or false - add whole token
    #                                            or
    #                                            scan into chars
    # * (required) _matrix_: NexusMatrix  - the matrix to which to add token
    # * (required) _row_: Integer - the row for matrix
    # * (required) _col_: Integer - the starting row
    # *Returns*:: Integer - ending row
    def add_token_to_matrix( token, scan_token, matrix, row, col )
      if ( scan_token )
        token.scan(/./) { |w|
        col += 1
        matrix.set_value( row, col, w )
      }
      else
        col += 1
        matrix.set_value( row, col, token )
      end
      col
    end
    
    # This processes the tokens (between Begin Taxa; and End;) for a block
    # for which a specific parser is not available.
    # Example of a currently parseable generic block:
    # Begin Taxa;
    #  token1 token2 token3 ...
    # End;
    #
    # ---
    # *Arguments*:
    # * (required) _token_: String
    def process_token_for_generic_block( token )
        @current_block.add_token( token )
    end
    
    # Returns true if Strings str1 and str2 are
    # equal - ignoring case.
    #
    # ---
    # *Arguments*:
    # * (required) _str1_: String
    # * (required) _str2_: String
    # *Returns*:: true or false 
    def equal?( str1, str2 )
      if ( str1 == nil || str2 == nil )
        return false
      else
        return ( str1.downcase == str2.downcase )
      end
    end
    
    # Returns true if @current_cmd == command
    # and @current_subcmd == subcommand, false otherwise
    # ---
    # *Arguments*:
    # * (required) _command_: String
    # * (required) _subcommand_: String
    # *Returns*:: true or false
    def cmds_equal_to?( command, subcommand )
      return ( @current_cmd == command && @current_subcmd == subcommand )
    end
    
    # Classes to represent nexus data follow.
    
    # ==  DESCRIPTION
    # Bio::Nexus::GenericBlock represents a generic nexus block.
    # It is mainly intended to be extended into more specific classes,
    # although it is used for blocks not represented by more specific
    # block classes.
    # It has a name and a array for the tokenized content of a
    # nexus block.   
    #
    # == USAGE
    #
    #   require 'bio/db/nexus'
    #
    #   # Create a new parser:
    #   nexus = Bio::Nexus.new( nexus_data_as_string )
    #
    #   # Get blocks for which no class exists (private blocks)
    #   as Nexus::GenericBlock:
    #   private_blocks = nexus.get_blocks_by_name( "my_block" )
    #   # Get first block names "my_block":
    #   my_block_0 = private_blocks[ 0 ]
    #   # Get first token in first block names "my_block":
    #   first_token = my_block_0.get_tokens[ 0 ]
    #   # Get name of block (would return "my_block" in this case):
    #   name = my_block_0.get_name
    #   # Return data of block as nexus formatted String:
    #   name = my_block_0.to_nexus
    #
    class GenericBlock
      
      # Creates a new GenericBlock object named 'name'.  
      # ---
      # *Arguments*:
      # * (required) _name_: String
      def initialize( name )
        @name = name.chomp(";") 
        @tokens = Array.new
      end
      
      # Gets the name of this block.
      #
      # ---
      # *Returns*:: String 
      def get_name
        @name
      end
      
      # Returns contents as Array of Strings.
      #
      # ---
      # *Returns*:: Array
      def get_tokens
        @tokens
      end
      
      # Same as to_nexus.
      #
      # ---
      # *Returns*:: String 
      def to_s
        to_nexus
      end
      alias to_str to_s
      
      # Should return a String describing this block as nexus formatted data.
      # ---
      # *Returns*:: String
      def to_nexus
        str = "generic block \"" + get_name + "\" [do not know how to write in nexus format]"
      end
      
      # Adds a token to this.
      #
      # ---
      # *Arguments*:
      # * (required) _token_: String
      def add_token( token )
        @tokens.push( token )
      end
      
    end # class GenericBlock
    
    
    # == DESCRIPTION
    # Bio::Nexus::TaxaBlock represents a taxa nexus block.
    #
    # = Example of Taxa block:
    # Begin Taxa;
    #  Dimensions NTax=4;
    #  TaxLabels fish [comment] 'african frog' "rat snake" 'red mouse';
    # End;
    #
    # == USAGE
    #
    #   require 'bio/db/nexus'
    #
    #   # Create a new parser:
    #   nexus = Bio::Nexus.new( nexus_data_as_string )
    #
    #   # Get first taxa block:   
    #   taxa_block = nexus.get_taxa_blocks[ 0 ]
    #   # Get number of taxa:
    #   number_of_taxa = taxa_block.get_number_of_taxa.to_i
    #   # Get name of first taxon:
    #   first_taxon = taxa_block.get_taxa[ 0 ]
    #
    class TaxaBlock < GenericBlock
      
      # Creates a new TaxaBlock object named 'name'.  
      # ---
      # *Arguments*:
      # * (required) _name_: String
      def initialize( name )
        super( name )
        @number_of_taxa = 0
        @taxa = Array.new
      end
      
      # Returns a String describing this block as nexus formatted data.
      # ---
      # *Returns*:: String
      def to_nexus
        line_1 = String.new
        line_1 << DIMENSIONS 
        if ( Nexus::Util::larger_than_zero( get_number_of_taxa  ) )
          line_1 << " " <<  NTAX << "=" << get_number_of_taxa
        end
        line_1 << DELIMITER
        line_2 = String.new
        line_2 << TAXLABELS << " " << Nexus::Util::array_to_string( get_taxa ) << DELIMITER
        Nexus::Util::to_nexus_helper( TAXA_BLOCK, [ line_1, line_2 ] )
      end
      
      # Gets the "number of taxa" property.
      #
      # ---
      # *Returns*:: Integer 
      def get_number_of_taxa
        @number_of_taxa
      end
      
      # Gets the taxa of this block.
      #
      # ---
      # *Returns*:: Array
      def get_taxa
        @taxa
      end
      
      # Sets the "number of taxa" property.
      #
      # ---
      # *Arguments*:
      # * (required) _number_of_taxa_: Integer
      def set_number_of_taxa( number_of_taxa )
        @number_of_taxa = number_of_taxa
      end
      
      # Adds a taxon name to this block.
      #
      # ---
      # *Arguments*:
      # * (required) _taxon_: String
      def add_taxon( taxon )
        @taxa.push( taxon )
      end
      
    end # class TaxaBlock
    
    
    # == DESCRIPTION
    # Bio::Nexus::CharactersBlock represents a characters nexus block.
    #
    # = Example of Characters block:
    # Begin Characters;
    #  Dimensions NChar=20
    #             NTax=4;
    #  Format DataType=DNA
    #  Missing=x
    #  Gap=- MatchChar=.;
    #  Matrix
    #   fish  ACATA GAGGG TACCT CTAAG
    #   frog  ACTTA GAGGC TACCT CTAGC
    #   snake ACTCA CTGGG TACCT TTGCG
    #   mouse ACTCA GACGG TACCT TTGCG;
    # End;
    #
    #
    # == USAGE
    #
    #   require 'bio/db/nexus'
    #
    #   # Create a new parser:
    #   nexus = Bio::Nexus.new( nexus_data_as_string )
    #
    #
    #   # Get first characters block (same methods as Nexus::DataBlock except
    #   # it lacks get_taxa method):   
    #   characters_block = nexus.get_characters_blocks[ 0 ]
    #  
    class CharactersBlock < GenericBlock
      
      MISSING    = "Missing"
      GAP        = "Gap"
      MATCHCHAR  = "MatchChar"
      
      # Creates a new CharactersBlock object named 'name'.  
      # ---
      # *Arguments*:
      # * (required) _name_: String
      def initialize( name )
        super( name )
        @number_of_taxa = 0
        @number_of_characters = 0
        @data_type = String.new
        @gap_character = String.new
        @missing = String.new
        @match_character = String.new
        @matrix = NexusMatrix.new
      end
      
      # Returns a String describing this block as nexus formatted data.
      #
      # ---
      # *Returns*:: String
      def to_nexus
        line_1 = String.new
        line_1 << DIMENSIONS  
        if ( Nexus::Util::larger_than_zero( get_number_of_taxa ) )
          line_1 << " " <<  NTAX << "=" << get_number_of_taxa
        end
        if ( Nexus::Util::larger_than_zero( get_number_of_characters ) )
          line_1 << " " <<  NCHAR << "=" << get_number_of_characters
        end
        line_1 << DELIMITER
        
        line_2 = String.new
        line_2 << FORMAT  
        if ( Nexus::Util::longer_than_zero( get_datatype ) )
          line_2 << " " <<  DATATYPE << "=" << get_datatype
        end
        if ( Nexus::Util::longer_than_zero( get_missing ) )
          line_2 << " " <<  MISSING << "=" << get_missing
        end
        if ( Nexus::Util::longer_than_zero( get_gap_character ) )
          line_2 << " " <<  GAP << "=" << get_gap_character
        end
        if ( Nexus::Util::longer_than_zero( get_match_character ) )
          line_2 << " " <<  MATCHCHAR << "=" << get_match_character
        end
        line_2 << DELIMITER
        
        line_3 = String.new
        line_3 << MATRIX 
        Nexus::Util::to_nexus_helper( CHARACTERS_BLOCK, [ line_1, line_2, line_3 ] +
                                      get_matrix.to_nexus_row_array  )
      end
      
      # Gets the "number of taxa" property.
      #
      # ---
      # *Returns*:: Integer
      def get_number_of_taxa
        @number_of_taxa
      end
      
      # Gets the "number of characters" property.
      #
      # ---
      # *Returns*:: Integer
      def get_number_of_characters
        @number_of_characters
      end
      
      # Gets the "datatype" property.
      # ---
      # *Returns*:: String
      def get_datatype
        @data_type
      end
      
      # Gets the "gap character" property.
      # ---
      # *Returns*:: String
      def get_gap_character
        @gap_character
      end
      
      # Gets the "missing" property.
      # ---
      # *Returns*:: String
      def get_missing
        @missing
      end
      
      # Gets the "match character" property.
      # ---
      # *Returns*:: String
      def get_match_character 
        @match_character 
      end
      
      # Gets the matrix.
      # ---
      # *Returns*:: Bio::Nexus::NexusMatrix
      def get_matrix
        @matrix 
      end
      
      # Returns character data as Bio::Sequence object Array
      # for matrix rows named 'name'.
      # ---
      # *Arguments*:
      # * (required) _name_: String
      # *Returns*:: Bio::Sequence
      def get_sequences_by_name( name )
        seq_strs = get_characters_strings_by_name( name )
        seqs = Array.new
        seq_strs.each do | seq_str |
          seqs.push( create_sequence( seq_str, name ) )
        end
        seqs
      end
      
      # Returns the characters in the matrix at row 'row' as
      # Bio::Sequence object. Column 0 of the matrix is set as
      # the definition of the Bio::Sequence object.
      # ---
      # *Arguments*:
      # * (required) _row_: Integer
      # *Returns*:: Bio::Sequence
      def get_sequence( row )
        create_sequence( get_characters_string( row ), get_row_name( row )  )
      end
      
      # Returns the String in the matrix at row 'row' and column 0,
      # which usually is interpreted as a sequence name (if the matrix
      # contains molecular sequence characters).
      #
      # ---
      # *Arguments*:
      # * (required) _row_: Integer
      # *Returns*:: String
      def get_row_name( row )
        get_matrix.get_name( row )
      end
      
      # Returns character data as String Array
      # for matrix rows named 'name'.
      #
      # ---
      # *Arguments*:
      # * (required) _name_: String
      # *Returns*:: Array of Strings
      def get_characters_strings_by_name( name )
        get_matrix.get_row_strings_by_name( name, "" )
      end
      
      # Returns character data as String
      # for matrix row 'row'.
      #
      # ---
      # *Arguments*:
      # * (required) _row_: Integer
      # *Returns*:: String
      def get_characters_string( row )
        get_matrix.get_row_string( row, "" )
      end
      
      # Sets the "number of taxa" property.
      # ---
      # *Arguments*:
      # * (required) _number_of_taxa_: Integer
      def set_number_of_taxa( number_of_taxa )
        @number_of_taxa = number_of_taxa
      end
      
      # Sets the "number of characters" property.
      # ---
      # *Arguments*:
      # * (required) _number_of_characters_: Integer
      def set_number_of_characters( number_of_characters )
        @number_of_characters = number_of_characters
      end
      
      # Sets the "data type" property.
      # ---
      # *Arguments*:
      # * (required) _data_type_: String
      def set_datatype( data_type )
        @data_type = data_type
      end
      
      # Sets the "gap character" property.
      # ---
      # *Arguments*:
      # * (required) _gap_character_: String
      def set_gap_character( gap_character )
        @gap_character = gap_character
      end
      
      # Sets the "missing" property.
      # ---
      # *Arguments*:
      # * (required) _missing_: String
      def set_missing( missing )
        @missing = missing
      end
      
      # Sets the "match character" property.
      # ---
      # *Arguments*:
      # * (required) _match_character_: String
      def set_match_character( match_character )
        @match_character = match_character
      end
      
      # Sets the matrix.
      # ---
      # *Arguments*:
      # * (required) _matrix_: Bio::Nexus::NexusMatrix
      def set_matrix( matrix )
        @matrix = matrix
      end
      
      private
      
      # Creates a Bio::Sequence object with sequence 'seq_str'
      # and definition 'definition'.
      # ---
      # *Arguments*:
      # * (required) _seq_str_: String
      # * (optional) _defintion_: String
      # *Returns*:: Bio::Sequence
      def create_sequence( seq_str, definition = "" )
        seq = Bio::Sequence.auto( seq_str )
        seq.definition = definition
        seq
      end  
      
    end # class CharactersBlock
    
    
    # == DESCRIPTION
    # Bio::Nexus::DataBlock represents a data nexus block.
    # A data block is a Bio::Nexus::CharactersBlock with the added
    # capability to store taxa names.
    #
    # = Example of Data block:
    # Begin Data;
    #  Dimensions ntax=5 nchar=14;
    #  Format Datatype=RNA gap=# MISSING=x MatchChar=^;
    #  TaxLabels ciona cow [comment] ape 'purple urchin' "green lizard";
    #  Matrix
    #   taxon_1 A- CCGTCGA-GTTA
    #   taxon_2 T- CCG-CGA-GATA
    #   taxon_3 A- C-GTCGA-GATA
    #   taxon_4 A- CCTCGA--GTTA
    #   taxon_5 T- CGGTCGT-CTTA;
    # End;
    #
    #
    # == USAGE
    #
    #   require 'bio/db/nexus'
    #
    #   # Create a new parser:
    #   nexus = Bio::Nexus.new( nexus_data_as_string )
    #
    #
    #   # Get first data block:   
    #   data_block = nexus.get_data_blocks[ 0 ]
    #   # Get first characters name:
    #   seq_name = data_block.get_row_name( 0 )
    #   # Get first characters row named "taxon_2" as Bio::Sequence sequence:
    #   seq_tax_2 = data_block.get_sequences_by_name( "taxon_2" )[ 0 ]
    #   # Get third characters row as Bio::Sequence sequence:
    #   seq_2 = data_block.get_sequence( 2 )
    #   # Get first characters row named "taxon_3" as String:   
    #   string_tax_3 = data_block.get_characters_strings_by_name( "taxon_3" )
    #   # Get name of first taxon:
    #   taxon_0 = data_block.get_taxa[ 0 ]
    #   # Get characters matrix as Bio::Nexus::NexusMatrix (names are in column 0)
    #   characters_matrix = data_block.get_matrix
    #
    class DataBlock < CharactersBlock
      
      # Creates a new DataBlock object named 'name'.  
      # ---
      # *Arguments*:
      # * (required) _name_: String
      def initialize( name )
        super( name )
        @taxa = Array.new
      end
      
      # Returns a String describing this block as nexus formatted data.
      # ---
      # *Returns*:: String
      def to_nexus
        line_1 = String.new
        line_1 << DIMENSIONS  
        if ( Nexus::Util::larger_than_zero( get_number_of_taxa ) )
          line_1 << " " <<  NTAX << "=" << get_number_of_taxa
        end
        if ( Nexus::Util::larger_than_zero( get_number_of_characters ) )
          line_1 << " " <<  NCHAR << "=" << get_number_of_characters
        end
        line_1 << DELIMITER
        
        line_2 = String.new
        line_2 << FORMAT  
        if ( Nexus::Util::longer_than_zero( get_datatype ) )
          line_2 << " " <<  DATATYPE << "=" << get_datatype
        end
        if ( Nexus::Util::longer_than_zero( get_missing ) )
          line_2 << " " <<  MISSING << "=" << get_missing
        end
        if ( Nexus::Util::longer_than_zero( get_gap_character ) )
          line_2 << " " <<  GAP << "=" << get_gap_character
        end
        if ( Nexus::Util::longer_than_zero( get_match_character ) )
          line_2 << " " <<  MATCHCHAR << "=" << get_match_character
        end
        line_2 << DELIMITER
        
        line_3 = String.new
        line_3 << TAXLABELS << " " << Nexus::Util::array_to_string( get_taxa )
        line_3 << DELIMITER
        
        line_4 = String.new
        line_4 << MATRIX 
        Nexus::Util::to_nexus_helper( DATA_BLOCK, [ line_1, line_2, line_3, line_4 ] +
                                      get_matrix.to_nexus_row_array  )
      end
      
      # Gets the taxa of this block. 
      # ---
      # *Returns*:: Array
      def get_taxa
        @taxa
      end
      
      # Adds a taxon name to this block. 
      # ---
      # *Arguments*:
      # * (required) _taxon_: String
      def add_taxon( taxon )
        @taxa.push( taxon )
      end
       
    end # class DataBlock
    
    
    # == DESCRIPTION
    # Bio::Nexus::DistancesBlock represents a distances nexus block.
    #
    # = Example of Distances block:
    # Begin Distances;
    #  Dimensions nchar=20 ntax=5;
    #  Format Triangle=Upper;
    #  Matrix
    #   taxon_1 0.0 1.0 2.0 4.0 7.0
    #   taxon_2 1.0 0.0 3.0 5.0 8.0
    #   taxon_3 3.0 4.0 0.0 6.0 9.0
    #   taxon_4 7.0 3.0 1.0 0.0 9.5
    #   taxon_5 1.2 1.3 1.4 1.5 0.0;
    # End;
    #
    #
    # == USAGE
    #
    #   require 'bio/db/nexus'
    #
    #   # Create a new parser:
    #   nexus = Bio::Nexus.new( nexus_data_as_string )
    #
    #   # Get distances block(s):   
    #   distances_blocks = nexus.get_distances_blocks
    #   # Get matrix as Bio::Nexus::NexusMatrix object:
    #   matrix = distances_blocks[ 0 ].get_matrix
    #   # Get value (column 0 are names):
    #   val = matrix.get_value( 1, 5 )
    #
    class DistancesBlock < GenericBlock
      TRIANGLE = "Triangle"
      
      # Creates a new DistancesBlock object named 'name'.  
      # ---
      # *Arguments*:
      # * (required) _name_: String
      def initialize( name )
        super( name )        
        @number_of_taxa = 0
        @number_of_characters = 0
        @triangle = String.new
        @matrix = NexusMatrix.new
      end
      
      # Returns a String describing this block as nexus formatted data.
      # ---
      # *Returns*:: String
      def to_nexus
        line_1 = String.new
        line_1 << DIMENSIONS  
        if ( Nexus::Util::larger_than_zero( get_number_of_taxa ) )
          line_1 << " " <<  NTAX << "=" << get_number_of_taxa
        end
        if ( Nexus::Util::larger_than_zero( get_number_of_characters ) )
          line_1 << " " <<  NCHAR << "=" << get_number_of_characters
        end
        line_1 << DELIMITER
        
        line_2 = String.new
        line_2 << FORMAT  
        if ( Nexus::Util::longer_than_zero( get_triangle ) )
          line_2 << " " << TRIANGLE << "=" << get_triangle
        end
        line_2 << DELIMITER
        
        line_3 = String.new
        line_3 << MATRIX 
        Nexus::Util::to_nexus_helper( DISTANCES_BLOCK, [ line_1, line_2, line_3 ] +
                                      get_matrix.to_nexus_row_array( " " ) )
      end
      
      # Gets the "number of taxa" property.
      # ---
      # *Returns*:: Integer
      def get_number_of_taxa
        @number_of_taxa
      end
      
      # Gets the "number of characters" property.
      # ---
      # *Returns*:: Integer
      def get_number_of_characters
        @number_of_characters
      end
      
      # Gets the "triangle" property.
      # ---
      # *Returns*:: String
      def get_triangle
        @triangle
      end
      
      # Gets the matrix.
      # ---
      # *Returns*:: Bio::Nexus::NexusMatrix
      def get_matrix
        @matrix
      end
      
      # Sets the "number of taxa" property.
      # ---
      # *Arguments*:
      # * (required) _number_of_taxa_: Integer
      def set_number_of_taxa( number_of_taxa )
        @number_of_taxa = number_of_taxa
      end
      
      # Sets the "number of characters" property.
      # ---
      # *Arguments*:
      # * (required) _number_of_characters_: Integer
      def set_number_of_characters( number_of_characters )
        @number_of_characters = number_of_characters
      end
      
      # Sets the "triangle" property.
      # ---
      # *Arguments*:
      # * (required) _triangle_: String
      def set_triangle( triangle )
        @triangle = triangle
      end
      
      # Sets the matrix.
      # ---
      # *Arguments*:
      # * (required) _matrix_: Bio::Nexus::NexusMatrix
      def set_matrix( matrix )
        @matrix = matrix
      end
      
    end # class DistancesBlock
    
    
    # == DESCRIPTION
    # Bio::Nexus::TreesBlock represents a trees nexus block.
    #
    # = Example of Trees block:
    # Begin Trees;
    #  Tree best=(fish,(frog,(snake, mouse)));
    #  Tree other=(snake,(frog,( fish, mouse)));
    # End;
    #
    #
    # == USAGE
    #
    #   require 'bio/db/nexus'
    #
    #   # Create a new parser:
    #   nexus = Bio::Nexus.new( nexus_data_as_string )
    #
    #   Get trees block(s):   
    #   trees_block = nexus.get_trees_blocks[ 0 ]
    #   # Get first tree named "best" as String:
    #   string_fish = trees_block.get_tree_strings_by_name( "best" )[ 0 ]
    #   # Get first tree named "best" as Bio::Db::Newick object:
    #   tree_fish = trees_block.get_trees_by_name( "best" )[ 0 ]
    #   # Get first tree as Bio::Db::Newick object:
    #   tree_first = trees_block.get_tree( 0 )
    #
    class TreesBlock < GenericBlock
      TREE  = "Tree"
      def initialize( name )
        super( name ) 
        @trees      = Array.new
        @tree_names = Array.new
      end
      
      # Returns a String describing this block as nexus formatted data.
      # ---
      # *Returns*:: String
      def to_nexus
        trees_ary = Array.new
        for i in 0 .. @trees.length - 1
          trees_ary.push( TREE + " " + @tree_names[ i ] + "=" + @trees[ i ] )
        end
        Nexus::Util::to_nexus_helper( TREES_BLOCK, trees_ary  )
      end
      
      # Returns an array of strings describing trees
      # ---
      # *Returns*:: Array
      def get_tree_strings
        @trees  
      end
      
      # Returns an array of tree names.
      # ---
      # *Returns*:: Array
      def get_tree_names
        @tree_names 
      end
      
      # Returns an array of strings describing trees
      # for which name matches the tree name.
      # ---
      # *Arguments*:
      # * (required) _name_: String
      # *Returns*:: Array
      def get_tree_strings_by_name( name )
        found_trees = Array.new
        i = 0
        @tree_names.each do | n |
          if ( n == name )
            found_trees.push( @trees[ i ] )
          end
          i += 1
        end
        found_trees
      end
      
      # Returns tree i (same order as in nexus data) as
      # newick parsed tree object.
      # ---
      # *Arguments*:
      # * (required) _i_: Integer
      # *Returns*:: Bio::Newick
      def get_tree( i )
        newick = Bio::Newick.new( @trees[ i ] )
        tree = newick.tree
        tree
      end
      
      # Returns an array of newick parsed tree objects
      # for which name matches the tree name.
      # ---
      # *Arguments*:
      # * (required) _name_: String
      # *Returns*:: Array of Bio::Newick
      def get_trees_by_name( name )
        found_trees = Array.new
        i = 0
        @tree_names.each do | n |
          if ( n == name )
            found_trees.push( get_tree( i ) )
          end
          i += 1
        end
        found_trees
      end  
      
      # Adds a tree name to this block. 
      # ---
      # *Arguments*:
      # * (required) _tree_name_: String
      def add_tree_name( tree_name )
        @tree_names.push( tree_name )
      end
     
      # Adds a tree to this block. 
      # ---
      # *Arguments*:
      # * (required) _tree_as_string_: String
      def add_tree( tree_as_string )
        @trees.push( tree_as_string )
      end
      
    end # class TreesBlock
    
    
    # == DESCRIPTION
    # Bio::Nexus::NexusMatrix represents a characters or distance matrix,
    # where the names are stored in column zero.
    #
    #
    # == USAGE
    #
    #   require 'bio/db/nexus'
    #
    #   # Create a new parser:
    #   nexus = Bio::Nexus.new( nexus_data_as_string )
    #   # Get distances block(s):   
    #   distances_block = nexus.get_distances_blocks[ 0 ]
    #   # Get matrix as Bio::Nexus::NexusMatrix object:
    #   matrix = distances_blocks.get_matrix
    #   # Get value (column 0 are names):
    #   val = matrix.get_value( 1, 5 )
    #   # Return first row as String (all columns except column 0),
    #   # values are separated by "_":
    #   row_str_0 = matrix.get_row_string( 0, "_" )
    #   # Return all rows named "ciona" as String (all columns except column 0),
    #   # values are separated by "+":
    #   ciona_rows = matrix.get_row_strings_by_name( "ciona", "+" ) 
    class NexusMatrix
      
      # Nexus matrix error class.
      class NexusMatrixError < RuntimeError; end
      
       # Creates new NexusMatrix.
      def initialize()
        @rows = Hash.new
        @max_row = -1
        @max_col = -1
      end
  
      # Sets the value at row 'row' and column 'col' to 'value'.
      # ---
      # *Arguments*:
      # * (required) _row_: Integer
      # * (required) _col_: Integer
      # * (required) _value_: Object
      def set_value( row, col, value ) 
        if ( ( row < 0 ) || ( col < 0 ) )
            raise( NexusTableError, "attempt to use negative values for row or column" )
        end
        if ( row > get_max_row() ) 
          set_max_row( row )
        end
        if ( col > get_max_col() ) 
          set_max_col( col )
        end
        row_map = nil
        if ( @rows.has_key?( row ) ) 
          row_map = @rows[ row ]
        else 
          row_map = Hash.new
          @rows[ row ] = row_map
        end
        row_map[ col ] = value
      end
  
      # Returns the value at row 'row' and column 'col'.
      # ---
      # *Arguments*:
      # * (required) _row_: Integer
      # * (required) _col_: Integer
      # *Returns*:: Object
      def get_value( row, col )
        if ( ( row > get_max_row() ) || ( row < 0 ) ) 
          raise( NexusMatrixError, "value for row (" + row.to_s +
            ") is out of range [max row: " + get_max_row().to_s + "]" )
        elsif ( ( col > get_max_col() ) || ( row < 0 ) )
          raise( NexusMatrixError, "value for column (" + col.to_s +
           ") is out of range [max column: " + get_max_col().to_s + "]" )
        end
        r = @rows[ row ]
        if ( ( r == nil ) || ( r.length < 1 ) ) 
          return nil
        end
        r[ col ]
      end
  
      # Returns the maximal columns number.
      # ---
      # *Returns*:: Integer
      def get_max_col 
        return @max_col
      end
  
      # Returns the maximal row number.
      # ---
      # *Returns*:: Integer
      def get_max_row 
        return @max_row
      end
      
      # Returns true of matrix is empty.
      #
      # ---
      # *Returns*:: true or false
      def is_empty?
        return get_max_col < 0 || get_max_row < 0
      end
      
      # Convenience method which return the value of
      # column 0 and row 'row' which is usually the name.
      #
      # ---
      # *Arguments*:
      # * (required) _row_: Integer 
      # *Returns*:: String
      def get_name( row )
        get_value( row, 0 ).to_s
      end
      
      # Returns the values of columns 1 to maximal column length
      # in row 'row' concatenated as string. Individual values can be
      # separated by 'spacer'.
      #
      # ---
      # *Arguments*:
      # * (required) _row_: Integer  
      # * (optional) _spacer_: String
      # *Returns*:: String
      def get_row_string( row, spacer = "" )
        row_str = String.new
        if is_empty?
          return row_str
        end
        for col in 1 .. get_max_col
          row_str << get_value( row, col ) << spacer
        end
        row_str
      end
      
      # Returns all rows as Array of Strings separated by 'spacer'
      # for which column 0 is 'name'.
      # ---
      # *Arguments*:
      # * (required) _name_: String  
      # * (optional) _spacer_: String
      # *Returns*:: Array
      def get_row_strings_by_name( name, spacer = "" )
        row_strs = Array.new
        if is_empty?
          return row_strs
        end
        for row in 0 .. get_max_row
          if ( get_value( row, 0 ) == name )
            row_strs.push( get_row_string( row, spacer ) )  
          end
        end
        row_strs
      end
   
      # Returns matrix as String, returns "empty" if empty.
      # ---
      # *Returns*:: String
      def to_s
        if is_empty?
          return "empty"  
        end
        str = String.new
        row_array = to_nexus_row_array( spacer = " ", false )
        row_array.each do | row |
          str << row << END_OF_LINE
        end
        str
      end
      alias to_str to_s
      
      # Helper method to produce nexus formatted data.
      # ---
      # *Arguments*:
      # * (optional) _spacer_: String
      # * (optional) _append_delimiter_: true or false
      # *Returns*:: Array
      def to_nexus_row_array( spacer = "", append_delimiter = true )
        ary = Array.new
        if is_empty?
          return ary
        end
        max_length = 10
        for row in 0 .. get_max_row
          l = get_value( row, 0 ).length
          if ( l > max_length )
            max_length = l
          end
        end  
        for row in 0 .. get_max_row
          row_str = String.new
          ary.push( row_str )
          name = get_value( row, 0 )
          name = name.ljust( max_length + 1 )
          row_str << name << " " << get_row_string( row, spacer )
          if ( spacer != nil && spacer.length > 0 )
            row_str.chomp!( spacer )
          end
          if ( append_delimiter && row == get_max_row )
            row_str << DELIMITER 
          end
        end
        ary
      end
      

      private
  
      # Returns row data as Array.
      # ---
      # *Arguments*:
      # * (required) _row_: Integer
      # *Returns*:: Array
      def get_row( row ) 
        return @rows[ row ]
      end
      
      # Sets maximal column number.
      # ---
      # *Arguments*:
      # * (required) _max_col_: Integer
      def set_max_col( max_col ) 
        @max_col = max_col
      end
      
      # Sets maximal row number.
      # ---
      # *Arguments*:
      # * (required) _max_row_: Integer
      def set_max_row( max_row ) 
        @max_row = max_row
      end
      
    end # NexusMatrix
  
    # End of classes to represent nexus data.
    
    # = DESCRIPTION
    # Bio::Nexus::Util is a class containing static helper methods
    #
    class Util
      
      # Helper method to produce nexus formatted data.
      # ---
      # *Arguments*:
      # * (required) _block_: Nexus:GenericBlock or its subclasses
      # * (required) _block_: Array
      # *Returns*:: String
      def Util::to_nexus_helper( block, lines )
        str = String.new
        str << BEGIN_BLOCK << " " << block << END_OF_LINE
        lines.each do | line |
          if ( line != nil )
            str << INDENTENTION << line << END_OF_LINE
          end
        end # do
        str << END_BLOCK << END_OF_LINE
        str
      end
      
      # Returns string as array separated by " ".
      # ---
      # *Arguments*:
      # * (required) _ary_: Array  
      # *Returns*:: String
      def Util::array_to_string( ary )
        str = String.new
        ary.each do | e |
          str << e << " "
        end
        str.chomp!( " " )
        str  
      end
      
      # Returns true if Integer i is not nil and larger than 0.
      # ---
      # *Arguments*:
      # * (required) _i_: Integer 
      # *Returns*:: true or false
      def Util::larger_than_zero( i )
        return ( i != nil && i.to_i > 0 )
      end
        
      # Returns true if String str is not nil and longer than 0.
      # ---
      # *Arguments*:
      # * (required) _str_: String 
      # *Returns*:: true or false
      def Util::longer_than_zero( str )
        return ( str != nil && str.length > 0 )
      end
      
    end # class Util
      
  end # class Nexus
    
end #module Bio


