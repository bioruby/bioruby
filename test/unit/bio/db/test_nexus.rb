#
# = test/bio/db/nexus.rb - Unit test for Bio::Nexus
#
# Copyright::  Copyright (C) 2006        Christian M Zmasek <cmzmasek@yahoo.com>
#
# License::     The Ruby License
#
# $Id: test_nexus.rb,v 1.2 2007/04/05 23:35:43 trevor Exp $
#
# == Description
#
# This file contains unit tests for Bio::Nexus.
#

require 'test/unit'
require 'bio/db/nexus'

module Bio
  
  class TestNexus < Test::Unit::TestCase

    NEXUS_STRING_1 = <<-END_OF_NEXUS_STRING
    #NEXUS
    Begin Taxa;
     Dimensions [[comment]] ntax=4;
     TaxLabels "hag fish" [comment] 'african frog'
     [lots of different comment follow]
     [] [a] [[a]] [ a ] [[ a ]] [ [ a ] ] [a ]
     [[a ]] [ [a ] ] [ a] [[ a]] [ [ a] ] [  ]
     [[  ]] [ [  ] ] [ a b ] [[ a b ]] [ [ a b ] ]
     [x[ x [x[ x[[x[[xx[x[  x]] ]x ] []]][x]]x]]]
     
     [comment_1 comment_3] "rat    snake" 'red
     
     
     mouse';
    End;
    
    [yet another comment End; ]
   
    Begin Characters;
     Dimensions nchar=20
                ntax=4;
             [  ntax=1000; ]
     Format DataType=DNA
            Missing=x
            Gap=- MatchChar=.;
     Matrix [comment]
     fish  ACATA GAGGG 
                       TACCT CTAAG
     frog  ACTTA GAGGC TACCT CTAGC
     snake ACTCA CTGGG TACCT TTGCG
     mouse ACTCA GACGG TACCT TTGCG;
    End;
    
    Begin Trees;
     [comment]
     Tree best=(fish,(frog,(snake,mo
                          use)));
      [some long comment]                    
     Tree
     
     other=(snake,
     
                     (frog,(fish,mo
                           use
                           )));
    End;
    
    
    
    Begin Trees;
     [comment]
     Tree worst=(A,(B,(C,D
                           )));
     Tree bad=(a,
   
                      (b,(c ,  d
                           )
                           
                           
                           )     );
    End; 
  
   
    Begin Distances;
     Dimensions nchar=20 ntax=5;
     Format Triangle=Both;
     Matrix
     taxon_1 0.0 1.0
             2.0 4.0 7.0
     taxon_2 1.0
             0.0 3.0 5.0 8.0
     taxon_3 3.0 4.0 0.0 6.0 9.0
     taxon_4 7.0 3.0 2.0 0.0 9.5
     taxon_5 1.2 1.3 1.4 1.5 0.0;
    End;
  
    Begin Data;
     Dimensions ntax=5 nchar=14;
     Format Datatype=RNA gap=# MISSING=x MatchChar=^;
     TaxLabels ciona
                 cow [comment1 commentX] ape
               'purple urchin' "green lizard";
     Matrix
     [ comment [old comment] ]
     taxon_1    A- CCGTCGA-GTTA
     taxon_2 T- CCG-CGA-GATC
     
     taxon_3 A- C-GTCGA-GATG
       
       taxon_4                A-    C   C   TC   G
         A  -     -G  T         T
         
         T
         
     taxon_5
T-CGGTCGT-CTTA;
    End;
  
    Begin Private1;
     Something foo=5 bar=20;
     Format Datatype=DNA;
     Matrix
      taxon_1 1111 1111111111
      taxon_2 2222 2222222222
      taxon_3 3333 3333333333
      taxon_4 4444 4444444444
      taxon_5 5555 5555555555;
    End;
    
    Begin Private1;
     some [boring]
     interesting [
      outdated
     ] data be here
    End;
    
    END_OF_NEXUS_STRING
    
    DATA_BLOCK_OUTPUT_STRING = <<-DATA_BLOCK_OUTPUT_STRING
Begin Data;
 Dimensions NTax=5 NChar=14;
 Format DataType=RNA Missing=x Gap=# MatchChar=^;
 TaxLabels ciona cow ape purple_urchin green_lizard;
 Matrix
 taxon_1     A-CCGTCGA-GTTA
 taxon_2     T-CCG-CGA-GATC
 taxon_3     A-C-GTCGA-GATG
 taxon_4     A-CCTCGA--GTTT
 taxon_5     T-CGGTCGT-CTTA;
End;
DATA_BLOCK_OUTPUT_STRING

    def test_nexus
      
      nexus = Bio::Nexus.new( NEXUS_STRING_1 )
      blocks = nexus.get_blocks
      assert_equal( 8, blocks.size )
      
      private_blocks   = nexus.get_blocks_by_name( "private1" )  
      data_blocks      = nexus.get_data_blocks
      character_blocks = nexus.get_characters_blocks
      trees_blocks     = nexus.get_trees_blocks
      distances_blocks = nexus.get_distances_blocks
      taxa_blocks      = nexus.get_taxa_blocks
      
      assert_equal( 2, private_blocks.size )
      assert_equal( 1, data_blocks.size )
      assert_equal( 1, character_blocks.size )
      assert_equal( 2, trees_blocks.size )
      assert_equal( 1, distances_blocks.size )
      assert_equal( 1, taxa_blocks.size )
      
      taxa_block = taxa_blocks[ 0 ]
      assert_equal( taxa_block.get_number_of_taxa.to_i , 4 )
      assert_equal( taxa_block.get_taxa[ 0 ], "hag_fish" )
      assert_equal( taxa_block.get_taxa[ 1 ], "african_frog" )
      assert_equal( taxa_block.get_taxa[ 2 ], "rat_snake" )
      assert_equal( taxa_block.get_taxa[ 3 ], "red_mouse" )
      
      chars_block = character_blocks[ 0 ]
      assert_equal( chars_block.get_number_of_taxa.to_i, 4 )
      assert_equal( chars_block.get_number_of_characters.to_i, 20 )
      assert_equal( chars_block.get_datatype, "DNA" )
      assert_equal( chars_block.get_match_character, "." )
      assert_equal( chars_block.get_missing, "x" )
      assert_equal( chars_block.get_gap_character, "-" )
      assert_equal( chars_block.get_matrix.get_value( 0, 0 ), "fish" )
      assert_equal( chars_block.get_matrix.get_value( 1, 0 ), "frog" )
      assert_equal( chars_block.get_matrix.get_value( 2, 0 ), "snake" )
      assert_equal( chars_block.get_matrix.get_value( 3, 0 ), "mouse" )
      assert_equal( chars_block.get_matrix.get_value( 0, 20 ), "G" )
      assert_equal( chars_block.get_matrix.get_value( 1, 20 ), "C" )
      assert_equal( chars_block.get_matrix.get_value( 2, 20 ), "G" )
      assert_equal( chars_block.get_matrix.get_value( 3, 20 ), "G" )
      assert_equal( chars_block.get_characters_strings_by_name( "fish" )[ 0 ], "ACATAGAGGGTACCTCTAAG" ) 
      assert_equal( chars_block.get_characters_strings_by_name( "frog" )[ 0 ], "ACTTAGAGGCTACCTCTAGC" ) 
      assert_equal( chars_block.get_characters_strings_by_name( "snake" )[ 0 ], "ACTCACTGGGTACCTTTGCG" ) 
      assert_equal( chars_block.get_characters_strings_by_name( "mouse" )[ 0 ], "ACTCAGACGGTACCTTTGCG" ) 
      
      assert_equal( chars_block.get_characters_string( 0 ), "ACATAGAGGGTACCTCTAAG" ) 
      assert_equal( chars_block.get_characters_string( 1 ), "ACTTAGAGGCTACCTCTAGC" ) 
      assert_equal( chars_block.get_characters_string( 2 ), "ACTCACTGGGTACCTTTGCG" ) 
      assert_equal( chars_block.get_characters_string( 3 ), "ACTCAGACGGTACCTTTGCG" )
      
      assert_equal( chars_block.get_row_name( 1 ), "frog" )

      assert_equal( chars_block.get_sequences_by_name( "fish" )[ 0 ].seq.to_s.downcase, "ACATAGAGGGTACCTCTAAG".downcase ) 
      assert_equal( chars_block.get_sequences_by_name( "frog" )[ 0 ].seq.to_s.downcase, "ACTTAGAGGCTACCTCTAGC".downcase ) 
      assert_equal( chars_block.get_sequences_by_name( "snake" )[ 0 ].seq.to_s.downcase, "ACTCACTGGGTACCTTTGCG".downcase ) 
      assert_equal( chars_block.get_sequences_by_name( "mouse" )[ 0 ].seq.to_s.downcase, "ACTCAGACGGTACCTTTGCG".downcase ) 
      
      assert_equal( chars_block.get_sequences_by_name( "fish" )[ 0 ].definition, "fish" )
      assert_equal( chars_block.get_sequences_by_name( "frog" )[ 0 ].definition, "frog" )
      assert_equal( chars_block.get_sequences_by_name( "snake" )[ 0 ].definition, "snake" )
      assert_equal( chars_block.get_sequences_by_name( "mouse" )[ 0 ].definition, "mouse" )
      
      assert_equal( chars_block.get_sequence( 0 ).seq.to_s.downcase, "ACATAGAGGGTACCTCTAAG".downcase ) 
      assert_equal( chars_block.get_sequence( 1 ).seq.to_s.downcase, "ACTTAGAGGCTACCTCTAGC".downcase ) 
      assert_equal( chars_block.get_sequence( 2 ).seq.to_s.downcase, "ACTCACTGGGTACCTTTGCG".downcase ) 
      assert_equal( chars_block.get_sequence( 3 ).seq.to_s.downcase, "ACTCAGACGGTACCTTTGCG".downcase ) 

      assert_equal( chars_block.get_sequence( 0 ).definition, "fish" ) 
      assert_equal( chars_block.get_sequence( 1 ).definition, "frog" ) 
      assert_equal( chars_block.get_sequence( 2 ).definition, "snake" ) 
      assert_equal( chars_block.get_sequence( 3 ).definition, "mouse" ) 
      
      
      tree_block_0 = trees_blocks[ 0 ]
      tree_block_1 = trees_blocks[ 1 ]
      assert_equal( tree_block_0.get_tree_names[ 0 ], "best" )
      assert_equal( tree_block_0.get_tree_names[ 1 ], "other" )
      assert_equal( tree_block_0.get_tree_strings_by_name( "best" )[ 0 ], "(fish,(frog,(snake,mouse)));" )
      assert_equal( tree_block_0.get_tree_strings_by_name( "other" )[ 0 ], "(snake,(frog,(fish,mouse)));" )
      
      best_tree = tree_block_0.get_trees_by_name( "best" )[ 0 ]
      other_tree = tree_block_0.get_trees_by_name( "other" )[ 0 ]
      worst_tree = tree_block_1.get_tree( 0 )
      bad_tree = tree_block_1.get_tree( 1 )
      assert_equal( 6, best_tree.descendents( best_tree.root ).size )
      assert_equal( 4, best_tree.leaves.size)
      assert_equal( 6, other_tree.descendents( other_tree.root ).size )
      assert_equal( 4, other_tree.leaves.size)
      fish_leaf_best = best_tree.nodes.find { |x| x.name == 'fish' }
      assert_equal( 1, best_tree.ancestors(  fish_leaf_best ).size )
      fish_leaf_other = other_tree.nodes.find { |x| x.name == 'fish' }
      assert_equal( 3, other_tree.ancestors(  fish_leaf_other ).size )

      a_leaf_worst = worst_tree.nodes.find { |x| x.name == 'A' }
      assert_equal( 1, worst_tree.ancestors(  a_leaf_worst ).size )
      c_leaf_bad = bad_tree.nodes.find { |x| x.name == 'c' }
      assert_equal( 3, bad_tree.ancestors(  c_leaf_bad ).size )
      
      
      dist_block = distances_blocks[ 0 ]
      assert_equal( dist_block.get_number_of_taxa.to_i, 5 )
      assert_equal( dist_block.get_number_of_characters.to_i, 20 )
      assert_equal( dist_block.get_triangle, "Both" )
      assert_equal( dist_block.get_matrix.get_value( 0, 0 ), "taxon_1" )
      assert_equal( dist_block.get_matrix.get_value( 1, 0 ), "taxon_2" )
      assert_equal( dist_block.get_matrix.get_value( 2, 0 ), "taxon_3" )
      assert_equal( dist_block.get_matrix.get_value( 3, 0 ), "taxon_4" )
      assert_equal( dist_block.get_matrix.get_value( 4, 0 ), "taxon_5" )
      assert_equal( dist_block.get_matrix.get_value( 0, 5 ).to_f, 7.0 )
      assert_equal( dist_block.get_matrix.get_value( 1, 5 ).to_f, 8.0 )
      assert_equal( dist_block.get_matrix.get_value( 2, 5 ).to_f, 9.0 )
      assert_equal( dist_block.get_matrix.get_value( 3, 5 ).to_f, 9.5 )
      assert_equal( dist_block.get_matrix.get_value( 4, 5 ).to_f, 0.0 )
      
      data_block = data_blocks[ 0 ]
      assert_equal( data_block.get_number_of_taxa.to_i, 5 )
      assert_equal( data_block.get_number_of_characters.to_i, 14 )
      assert_equal( data_block.get_datatype, "RNA" )
      assert_equal( data_block.get_match_character, "^" )
      assert_equal( data_block.get_missing, "x" )
      assert_equal( data_block.get_gap_character, "#" )
      assert_equal( data_block.get_matrix.get_value( 0, 0 ), "taxon_1" )
      assert_equal( data_block.get_matrix.get_value( 1, 0 ), "taxon_2" )
      assert_equal( data_block.get_matrix.get_value( 2, 0 ), "taxon_3" )
      assert_equal( data_block.get_matrix.get_value( 3, 0 ), "taxon_4" )
      assert_equal( data_block.get_matrix.get_value( 4, 0 ), "taxon_5" )
      assert_equal( data_block.get_matrix.get_value( 0, 14 ), "A" )
      assert_equal( data_block.get_matrix.get_value( 1, 14 ), "C" )
      assert_equal( data_block.get_matrix.get_value( 2, 14 ), "G" )
      assert_equal( data_block.get_matrix.get_value( 3, 14 ), "T" )
      assert_equal( data_block.get_matrix.get_value( 4, 14 ), "A" )
      assert_equal( data_block.get_taxa[ 0 ], "ciona" )
      assert_equal( data_block.get_taxa[ 1 ], "cow" )
      assert_equal( data_block.get_taxa[ 2 ], "ape" )
      assert_equal( data_block.get_taxa[ 3 ], "purple_urchin" )
      assert_equal( data_block.get_taxa[ 4 ], "green_lizard" )
      
     
      assert_equal( data_block.get_characters_strings_by_name( "taxon_1" )[ 0 ], "A-CCGTCGA-GTTA" ) 
      assert_equal( data_block.get_characters_strings_by_name( "taxon_2" )[ 0 ], "T-CCG-CGA-GATC" ) 
      assert_equal( data_block.get_characters_strings_by_name( "taxon_3" )[ 0 ], "A-C-GTCGA-GATG" ) 
      assert_equal( data_block.get_characters_strings_by_name( "taxon_4" )[ 0 ], "A-CCTCGA--GTTT" )
      assert_equal( data_block.get_characters_strings_by_name( "taxon_5" )[ 0 ], "T-CGGTCGT-CTTA" )     
      
      assert_equal( data_block.get_characters_string( 0 ), "A-CCGTCGA-GTTA" ) 
      assert_equal( data_block.get_characters_string( 1 ), "T-CCG-CGA-GATC" ) 
      assert_equal( data_block.get_characters_string( 2 ), "A-C-GTCGA-GATG" ) 
      assert_equal( data_block.get_characters_string( 3 ), "A-CCTCGA--GTTT" )
      assert_equal( data_block.get_characters_string( 4 ), "T-CGGTCGT-CTTA" )
      
      assert_equal( data_block.get_row_name( 0 ), "taxon_1" )
      assert_equal( data_block.get_row_name( 1 ), "taxon_2" )
      assert_equal( data_block.get_row_name( 2 ), "taxon_3" )
      assert_equal( data_block.get_row_name( 3 ), "taxon_4" )
      assert_equal( data_block.get_row_name( 4 ), "taxon_5" )

      assert_equal( data_block.get_sequences_by_name( "taxon_1" )[ 0 ].seq.to_s.downcase, "A-CCGTCGA-GTTA".downcase ) 
      assert_equal( data_block.get_sequences_by_name( "taxon_2" )[ 0 ].seq.to_s.downcase, "T-CCG-CGA-GATC".downcase ) 
      assert_equal( data_block.get_sequences_by_name( "taxon_3" )[ 0 ].seq.to_s.downcase, "A-C-GTCGA-GATG".downcase ) 
      assert_equal( data_block.get_sequences_by_name( "taxon_4" )[ 0 ].seq.to_s.downcase, "A-CCTCGA--GTTT".downcase ) 
      assert_equal( data_block.get_sequences_by_name( "taxon_5" )[ 0 ].seq.to_s.downcase, "T-CGGTCGT-CTTA".downcase )
      
      assert_equal( data_block.get_sequences_by_name( "taxon_1" )[ 0 ].definition, "taxon_1" )
      assert_equal( data_block.get_sequences_by_name( "taxon_2" )[ 0 ].definition, "taxon_2" )
      assert_equal( data_block.get_sequences_by_name( "taxon_3" )[ 0 ].definition, "taxon_3" )
      assert_equal( data_block.get_sequences_by_name( "taxon_4" )[ 0 ].definition, "taxon_4" )
      assert_equal( data_block.get_sequences_by_name( "taxon_5" )[ 0 ].definition, "taxon_5" )
      
      assert_equal( data_block.get_sequence( 0 ).seq.to_s.downcase, "A-CCGTCGA-GTTA".downcase ) 
      assert_equal( data_block.get_sequence( 1 ).seq.to_s.downcase, "T-CCG-CGA-GATC".downcase ) 
      assert_equal( data_block.get_sequence( 2 ).seq.to_s.downcase, "A-C-GTCGA-GATG".downcase ) 
      assert_equal( data_block.get_sequence( 3 ).seq.to_s.downcase, "A-CCTCGA--GTTT".downcase )
      assert_equal( data_block.get_sequence( 4 ).seq.to_s.downcase, "T-CGGTCGT-CTTA".downcase ) 

      assert_equal( data_block.get_sequence( 0 ).definition, "taxon_1" ) 
      assert_equal( data_block.get_sequence( 1 ).definition, "taxon_2" ) 
      assert_equal( data_block.get_sequence( 2 ).definition, "taxon_3" ) 
      assert_equal( data_block.get_sequence( 3 ).definition, "taxon_4" )
      assert_equal( data_block.get_sequence( 4 ).definition, "taxon_5" ) 
      
      assert_equal( DATA_BLOCK_OUTPUT_STRING, data_block.to_nexus() ) 
      
      generic_0 = private_blocks[ 0 ]
      generic_1 = private_blocks[ 1 ]
      assert_equal( generic_0.get_tokens[ 0 ], "Something" )
      assert_equal( generic_0.get_tokens[ 1 ], "foo" )
      assert_equal( generic_0.get_tokens[ 2 ], "5" )
      assert_equal( generic_0.get_tokens[ 3 ], "bar" )
      assert_equal( generic_0.get_tokens[ 4 ], "20" )
      assert_equal( generic_0.get_tokens[ 5 ], "Format" )
      assert_equal( generic_0.get_tokens[ 6 ], "Datatype" )
      assert_equal( generic_0.get_tokens[ 7 ], "DNA" )
      assert_equal( generic_0.get_tokens[ 8 ], "Matrix" )
      assert_equal( generic_0.get_tokens[ 9 ], "taxon_1" )
      assert_equal( generic_0.get_tokens[10 ], "1111" )
      assert_equal( generic_1.get_tokens[ 0 ], "some" )
      assert_equal( generic_1.get_tokens[ 1 ], "interesting" )
      assert_equal( generic_1.get_tokens[ 2 ], "data" )
      assert_equal( generic_1.get_tokens[ 3 ], "be" )
      assert_equal( generic_1.get_tokens[ 4 ], "here" )
      
    end # test_nexus
  end # class TestNexus
end # module Bio
