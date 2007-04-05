#
# test/unit/bio/db/test_rebase.rb - Unit test for Bio::Lasergene
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2007 Center for Biomedical Research Informatics, University of Minnesota (http://cbri.umn.edu)
# License::   The Ruby License
#
#  $Id: test_lasergene.rb,v 1.2 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio'
require 'bio/db/lasergene'

module Bio #:nodoc:
  class TestLasergene < Test::Unit::TestCase #:nodoc:
    
    def setup
      file_format_1 = <<END
"Contig 1" (1,934)
  Contig Length:                  934 bases
  Average Length/Sequence:        467 bases
  Total Sequence Length:         1869 bases
  Top Strand:                       2 sequences
  Bottom Strand:                    2 sequences
  Total:                            4 sequences
^^
ATGACGTATCCAAAGAGGCGTTACCGGAGAAGAAGACACCGCCCCCGCAGTCCTCTTGGCCAGATCCTCCGCCGCCGCCCCTGGCTCGTCCACCCCCGCCACAGTTACCGCTGGAGAAGGAAAAATGGCATCTTCAWCACCCGCCTATCCCGCAYCTTCGGAWRTACTATCAAGCGAACCACAGTCAGAACGCCCTCCTGGGCGGTGGACATGATGAGATTCAATATTAATGACTTTCTTCCCCCAGGAGGGGGCTCAAACCCCCGCTCTGTGCCCTTTGAATACTACAGAATAAGAAAGGTTAAGGTTGAATTCTGGCCCTGCTCCCCGATCACCCAGGGTGACAGGGGAATGGGCTCCAGTGCTGWTATTCTAGMTGATRRCTTKGTAACAAAGRCCACAGCCCTCACCTATGACCCCTATGTAAACTTCTCCTCCCGCCATACCATAACCCAGCCCTTCTCCTACCRCTCCCGYTACTTTACCCCCAAACCTGTCCTWGATKCCACTATKGATKACTKCCAACCAAACAACAAAAGAAACCAGCTGTGGSTGAGACTACAWACTGCTGGAAATGTAGACCWCGTAGGCCTSGGCACTGCGTKCGAAAACAGTATATACGACCAGGAATACAATATCCGTGTMACCATGTATGTACAATTCAGAGAATTTAATCTTAAAGACCCCCCRCTTMACCCKTAATGAATAATAAMAACCATTACGAAGTGATAAAAWAGWCTCAGTAATTTATTYCATATGGAAATTCWSGGCATGGGGGGGAAAGGGTGACGAACKKGCCCCCTTCCTCCSTSGMYTKTTCYGTAGCATTCYTCCAMAAYACCWAGGCAGYAMTCCTCCSATCAAGAGcYTSYACAGCTGGGACAGCAGTTGAGGAGGACCATTCAAAGGGGGTCGGATTGCTGGTAATCAGA
END

      file_format_2 = <<END
^^:                                  350,935
Contig 1 (1,935)
  Contig Length:                  935 bases
  Average Length/Sequence:        580 bases
  Total Sequence Length:         2323 bases
  Top Strand:                       2 sequences
  Bottom Strand:                    2 sequences
  Total:                            4 sequences
^^
ATGTCGGGGAAATGCTTGACCGCGGGCTACTGCTCATCATTGCTTTCTTTGTGGTATATCGTGCCGTTCTGTTTTGCTGTGCTCGTCAACGCCAGCGGCGACAGCAGCTCTCATTTTCAGTCGATTTATAACTTGACGTTATGTGAGCTGAATGGCACGAACTGGCTGGCAGACAACTTTAACTGGGCTGTGGAGACTTTTGTCATCTTCCCCGTGTTGACTCACATTGTTTCCTATGGTGCACTCACTACCAGTCATTTTCTTGACACAGTTGGTCTAGTTACTGTGTCTACCGCCGGGTTTTATCACGGGCGGTACGTCTTGAGTAGCATCTACGCGGTCTGTGCTCTGGCTGCGTTGATTTGCTTCGCCATCAGGTTTGCGAAGAACTGCATGTCCTGGCGCTACTCTTGCACTAGATACACCAACTTCCTCCTGGACACCAAGGGCAGACTCTATCGTTGGCGGTCGCCTGTCATCATAGAGAAAGGGGGTAAGGTTGAGGTCGAAGGTCATCTGATCGATCTCAAAAGAGTTGTGCTTGATGGCTCTGTGGCGACACCTTTAACCAGAGTTTCAGCGGAACAATGGGGTCGTCCCTAGACGACTTTTGCCATGATAGTACAGCCCCACAGAAGGTGCTCTTGGCGTTTTCCATCACCTACACGCCAGTGATGATATATGCCCTAAAGGTAAGCCGCGGCCGACTTTTGGGGCTTCTGCACCTTTTGATTTTTTTGAACTGTGCCTTTACTTTCGGGTACATGACATTCGTGCACTTTCGGAGCACGAACAAGGTCGCGCTCACTATGGGAGCAGTAGTCGCACTCCTTTGGGGGGTGTACTCAGCCATAGAAACCTGGAAATTCATCACCTCCAGATGCCGTTGTGCTTGCTAGGCCGCAAGTACATTCTGGCCCCTGCCCACCACGTTG
END

      file_format_3 = <<END
LOCUS       PRU87392               15411 bp    RNA     linear   VRL 17-NOV-2000
DEFINITION  Porcine reproductive and respiratory syndrome virus strain VR-2332,
            complete genome.
ACCESSION   U87392 AF030244 U00153
VERSION     U87392.3  GI:11192298
[...cut...]
     3'UTR           15261..15411
     polyA_site      15409
ORIGIN      
^^
atgacgtataggtgttggctctatgccttggcatttgtattgtcaggagctgtgaccattggcacagcccaaaacttgctgcacagaaacacccttctgtgatagcctccttcaggggagcttagggtttgtccctagcaccttgcttccggagttgcactgctttacggtctctccacccctttaaccatgtctgggatacttgatcggtgcacgtgtacccccaatgccagggtgtttatggcggagggccaagtctactgcacacgatgcctcagtgcacggtctctccttcccctgaacctccaagtttctgagctcggggtgctaggcctattctacaggcccgaagagccactccggtggacgttgccacgtgcattccccactgttgagtgctcccccgccggggcctgctggctttctgcaatctttccaatcgcacgaatgaccagtggaaacctgaacttccaacaaagaatggtacgggtcgcagctgagctttacagagccggccagctcacccctgcagtcttgaaggctctacaagtttatgaacggggttgccgctggtaccccattgttggacctgtccctggagtggccgttttcgccaattccctacatgtgagtgataaacctttcccgggagcaactcacgtgttgaccaacctgccgctcccgcagagacccaagcctgaagacttttgcccctttgagtgtgctatggctactgtctatgacattggtcatgacgccgtcatgtatgtggccgaaaggaaagtctcctgggcccctcgtggcggggatgaagtgaaatttgaagctgtccccggggagttgaagttgattgcgaaccggctccgcacctccttcccgccccaccacacagtggacatgtctaagttcgccttcacagcccctgggtgtggtgtttctatgcgggtcgaacgccaacacggctgccttcccgctgacactgtccctgaaggcaactgctggtggagcttgtttgacttgcttccactggaagttcagaacaaagaaattcgccatgctaaccaatttggctaccagaccaagcatggtgtctctggcaagtacctacagcggaggctgca
END

      @lc = Bio::Lasergene
      @obj1 = @lc.new(file_format_1)
      @obj2 = @lc.new(file_format_2)
      @obj3 = @lc.new(file_format_3)
    end

    def test_methods
      a1 = @obj1
      a1_seq = 'atgacgtatccaaagaggcgttaccggagaagaagacaccgcccccgcagtcctcttggccagatcctccgccgccgcccctggctcgtccacccccgccacagttaccgctggagaaggaaaaatggcatcttcawcacccgcctatcccgcaycttcggawrtactatcaagcgaaccacagtcagaacgccctcctgggcggtggacatgatgagattcaatattaatgactttcttcccccaggagggggctcaaacccccgctctgtgccctttgaatactacagaataagaaaggttaaggttgaattctggccctgctccccgatcacccagggtgacaggggaatgggctccagtgctgwtattctagmtgatrrcttkgtaacaaagrccacagccctcacctatgacccctatgtaaacttctcctcccgccataccataacccagcccttctcctaccrctcccgytactttacccccaaacctgtcctwgatkccactatkgatkactkccaaccaaacaacaaaagaaaccagctgtggstgagactacawactgctggaaatgtagaccwcgtaggcctsggcactgcgtkcgaaaacagtatatacgaccaggaatacaatatccgtgtmaccatgtatgtacaattcagagaatttaatcttaaagaccccccrcttmacccktaatgaataataamaaccattacgaagtgataaaawagwctcagtaatttattycatatggaaattcwsggcatgggggggaaagggtgacgaackkgcccccttcctccstsgmytkttcygtagcattcytccamaayaccwaggcagyamtcctccsatcaagagcytsyacagctgggacagcagttgaggaggaccattcaaagggggtcggattgctggtaatcaga'
      a2 = @obj2
      a2_seq = 'atgtcggggaaatgcttgaccgcgggctactgctcatcattgctttctttgtggtatatcgtgccgttctgttttgctgtgctcgtcaacgccagcggcgacagcagctctcattttcagtcgatttataacttgacgttatgtgagctgaatggcacgaactggctggcagacaactttaactgggctgtggagacttttgtcatcttccccgtgttgactcacattgtttcctatggtgcactcactaccagtcattttcttgacacagttggtctagttactgtgtctaccgccgggttttatcacgggcggtacgtcttgagtagcatctacgcggtctgtgctctggctgcgttgatttgcttcgccatcaggtttgcgaagaactgcatgtcctggcgctactcttgcactagatacaccaacttcctcctggacaccaagggcagactctatcgttggcggtcgcctgtcatcatagagaaagggggtaaggttgaggtcgaaggtcatctgatcgatctcaaaagagttgtgcttgatggctctgtggcgacacctttaaccagagtttcagcggaacaatggggtcgtccctagacgacttttgccatgatagtacagccccacagaaggtgctcttggcgttttccatcacctacacgccagtgatgatatatgccctaaaggtaagccgcggccgacttttggggcttctgcaccttttgatttttttgaactgtgcctttactttcgggtacatgacattcgtgcactttcggagcacgaacaaggtcgcgctcactatgggagcagtagtcgcactcctttggggggtgtactcagccatagaaacctggaaattcatcacctccagatgccgttgtgcttgctaggccgcaagtacattctggcccctgcccaccacgttg'
      a3 = @obj3
      a3_seq = 'atgacgtataggtgttggctctatgccttggcatttgtattgtcaggagctgtgaccattggcacagcccaaaacttgctgcacagaaacacccttctgtgatagcctccttcaggggagcttagggtttgtccctagcaccttgcttccggagttgcactgctttacggtctctccacccctttaaccatgtctgggatacttgatcggtgcacgtgtacccccaatgccagggtgtttatggcggagggccaagtctactgcacacgatgcctcagtgcacggtctctccttcccctgaacctccaagtttctgagctcggggtgctaggcctattctacaggcccgaagagccactccggtggacgttgccacgtgcattccccactgttgagtgctcccccgccggggcctgctggctttctgcaatctttccaatcgcacgaatgaccagtggaaacctgaacttccaacaaagaatggtacgggtcgcagctgagctttacagagccggccagctcacccctgcagtcttgaaggctctacaagtttatgaacggggttgccgctggtaccccattgttggacctgtccctggagtggccgttttcgccaattccctacatgtgagtgataaacctttcccgggagcaactcacgtgttgaccaacctgccgctcccgcagagacccaagcctgaagacttttgcccctttgagtgtgctatggctactgtctatgacattggtcatgacgccgtcatgtatgtggccgaaaggaaagtctcctgggcccctcgtggcggggatgaagtgaaatttgaagctgtccccggggagttgaagttgattgcgaaccggctccgcacctccttcccgccccaccacacagtggacatgtctaagttcgccttcacagcccctgggtgtggtgtttctatgcgggtcgaacgccaacacggctgccttcccgctgacactgtccctgaaggcaactgctggtggagcttgtttgacttgcttccactggaagttcagaacaaagaaattcgccatgctaaccaatttggctaccagaccaagcatggtgtctctggcaagtacctacagcggaggctgca'
      
      assert_equal(a1_seq, a1.seq.seq)
      assert_equal(a2_seq, a2.seq.seq)
      assert_equal(a3_seq, a3.seq.seq)
      
      assert_equal('"Contig 1"', a1.entry_id)
      assert_equal('Contig 1', a2.name)
      assert_equal(nil, a3.name)
      
      assert_equal(4, a1.total_sequences)
      assert_equal(4, a2.total_sequences)
      assert_equal(nil, a3.total_sequences)

      assert_equal(true, a1.standard_comment?)
      assert_equal(true, a2.standard_comment?)
      assert_equal(false, a3.standard_comment?) 
    end

  end

end
