#
# test/functional/bio/sequence/test_output_embl.rb - Functional test for Bio::Sequence#output(:embl)
#
# Copyright::   Copyright (C) 2008
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'

module Bio
  class FuncTestSequenceOutputEMBL < Test::Unit::TestCase
    def setup
      @seq = Bio::Sequence.auto('aattaaaacgccacgcaaggcgattctaggaaatcaaaacgacacgaaatgtggggtgggtgtttgggtaggaaagacagttgtcaacatcagggatttggattgaatcaaaaaaaaagtccttagatttcataaaagctaatcacgcctcaaaactggggcctatctcttcttttttgtcgcttcctgtcggtccttctctatttcttctccaacccctcatttttgaatatttacataacaaaccgttttactttctttggtcaaaattagacccaaaattctatattagtttaagatatgtggtctgtaatttattgttgtattgatataaaaattagttataagcgattatatttttatgctcaagtaactggtgttagttaactatattccaccacgataacctgattacataaaatatgattttaatcattttagtaaaccatatcgcacgttggatgattaattttaacggtttaataacacgtgattaaattatttttagaatgattatttacaaacggaaaagctatatgtgacacaataactcgtgcagtattgttagtttgaaaagtgtatttggtttcttatatttggcctcgattttcagtttatgtgctttttacaaagttttattttcgttatctgtttaacgcgacatttgttgtatggctttaccgatttgagaataaaatcatattacctttatgtagccatgtgtggtgtaatatataataatggtccttctacgaaaaaagcagatcacaattgaaataaagggtgaaatttggtgtcccttttcttcgtcgaaataacagaactaaataaaagaaagtgttatagtatattacgtccgaagaataatccatattcctgaaatacagtcaacatattatatatttagtactttatataaagttaggaattaaatcatatgttttatcgaccatattaagtcacaactttatcataaattaatctgtaattagaattccaagttcgccaccgaatttcgtaacctaatctacatataatagataaaatatatatatgtagagtaattatgatatctatgtatgtagtcatggtatatgaattttgaaattggcaaggtaacattgacggatcgtaacccaacaaataatattaattacaaaatgggtgggcgggaatagtatacaactcataattccactcactttttgtattattaggatatgaaataagagtaatcaacatgcataataaagatgtataatttcttcatcttaaaaaacataactacatggtttaatacacaattttaccttttatcaaaaaagtatttcacaattcactcgcaaattacgaaatgatggctagtgcttcaactccaaatttcgaatattttaaatcacgatgtgtagaaccttttatttactggatactaatcactagtttattgagccaaccaattagttaaatagaacaatcaatattatagccagatattttttcctttaaaaatatttaaaagaggggccagaaaagaaccagagagggaggccatgagacattattatcactagtcaaaaacaacaaaccctccttttgctttttcatataaattattatattttattttgcaggtttcttctcttcttcttcttcttcttcttcttcttcctcttggctgctttctttcatcatccataaagtgaaagctaacgcatagagagagccatatcgtcccaaaaaaagcaaaagtccaaaaaaaaacaactccaaaacattctctcttagctctttactctttagtttctctctctctctctgcctttctctttgttgaagttcatggatgctacgaagtggactcaggtacgtaaaaagatatctctctgctatatctgtttgtttgtagcttctccccgactctcacgctctctctctctctctctctctctttgtgtatctctctactcacataaatatatacatgtgtgtgtatgcatgtttatatgtatgtatgaaaccagtagtggttatacagatagtctatatagagatatcaatatgatgtgttttaatttagactttttatatatccgtttgaaacttccgaagttctcgaatggagttaaggaagttttgttctctacaagttcaatttttcttgtcattaattataaaactctgataactaatggataaaaaaggtatgctttgttagttaccttttgttcttggtgctcaggtcttaccatttttttcctaaattttaattagtctcctttctttaattaattttatgttaacgcactgacgatttaacgttaacaaaaaaacctagattctttttcttttcaatagagcataattattacttcaatttcatttatctcacactaaaccctaatcttggcgaaattccttttatatatataaatttaattaatttttccacaatcttggcggaattcaggactcggttttgcttgttattgttctctcttttaatttgacatggttagggaatacttaaagtatgtcttaattttatagggttttcaagaaatgataaacgtaaagccaatggagcaaatgatttctagcaccaacaacaacacaccgcaacaacaaccaacattcatcgccaccaacacaaggccaaacgccaccgcatccaatggtggctccggaggaaataccaacaacacggctacgatggaaactagaaaggcgaggccacaagagaaagtaaattgtccaagatgcaactcaacaaacacaaagttctgttattacaacaactacagtctcacgcaaccaagatacttctgcaaaggttgtcgaaggtattggaccgaaggtggctctcttcgtaacgtcccagtcggaggtagctcaagaaagaacaagagatcctctacacctttagcttcaccttctaatcccaaacttccagatctaaacccaccgattcttttctcaagccaaatccctaataagtcaaataaagatctcaacttgctatctttcccggtcatgcaagatcatcatcatcatggtatgtctcatttttttcatatgcccaagatagagaacaacaatacttcatcctcaatctatgcttcatcatctcctgtctcagctcttgagcttctaagatccaatggagtctcttcaagaggcatgaacacgttcttgcctggtcaaatgatggattcaaactcagtcctgtactcatctttagggtttccaacaatgcctgattacaaacagagtaataacaacctttcattctccattgatcatcatcaagggattggacataacaccatcaacagtaaccaaagagctcaagataacaatgatgacatgaatggagcaagtagggttttgttccctttttcagacatgaaagagctttcaagcacaacccaagagaagagtcatggtaataatacatattggaatgggatgttcagtaatacaggaggatcttcatggtgaaaaaaggttaaaaagagctcatgaactatcagctttcttctctttttctgtttttttctcctattttattatagtttttactttgatgatcttttgttttttctcacatggggaactttacttaaagttgtcagaacttagtttacagattgtctttttattccttctttctggttttccttttttcctttttttatcagtctttttaaaatatgtatttcataattgggtttgatcattcatatttattagtatcaaaatagagtctatgttcatgagggagtgttaaggggtgtgagggtagaagaataagtgaatacgggggcccg')
      @seq.entry_id = 'AJ224122'
      @seq.sequence_version = 3
      @seq.topology = 'linear'
      @seq.molecule_type = 'genomic DNA'
      @seq.data_class = 'STD'
      @seq.division = 'PLN'
      @seq.primary_accession = 'AJ224122'
      @seq.secondary_accessions = []
      @seq.date_created = '27-FEB-1998 (Rel. 54, Created)'
      @seq.date_modified = '14-NOV-2006 (Rel. 89, Last updated, Version 6)'
      @seq.definition = 'Arabidopsis thaliana DAG1 gene'
      @seq.keywords = ['BBFa gene', 'transcription factor']
      @seq.species = 'Arabidopsis thaliana (thale cress)'
      @seq.classification = ['Eukaryota', 'Viridiplantae', 'Streptophyta', 'Embryophyta', 'Tracheophyta',
                             'Spermatophyta', 'Magnoliophyta', 'eudicotyledons', 'core eudicotyledons', 'rosids',
                             'eurosids II', 'Brassicales', 'Brassicaceae', 'Arabidopsis']
    end

    def test_output_embl
      assert_nothing_raised { @seq.output(:embl) }
    end

    def test_output_fasta
      assert_nothing_raised { @seq.output(:fasta) }
    end
  end # class FuncTestSequenceOutputEMBL
end # module Bio
