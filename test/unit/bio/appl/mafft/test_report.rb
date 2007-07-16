#
# test/unit/bio/appl/mafft/test_report.rb - Unit test for Bio::Alignment::MultiFastaFormat
#
# Copyright::  Copyright (C) 2007
#              2005 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_report.rb,v 1.1 2007/07/16 12:21:39 ngoto Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'

require 'bio'

module Bio
  class TestAlignmentMultiFastaFormat < Test::Unit::TestCase
    def setup
      @na = Bio::Alignment::MultiFastaFormat.new <<__END_OF_NASEQS__
>naseq1
TAGATTTCGAATTTCTAGnGAACCGAACCGkACAGCCTTACATyATTCAGACCAATGTGT
TACCAATTCGAGTATACAAGAACAGTGATAAGGTACCAAACAACGACTTCTTCCCGAACC
>naseq2
TAGATTTCGAATCTAGGGAATCCGATACGGACAGCCTTACATTATTCAGACCAATGTGTA
TACCAATTCGAGAATACAAGAACGTGATAAGGTACCCAAACAACGACTTCTTCCCGAACC
>naseq3
TAGATTTCGAATCTAGGGAATCCGATACCGGACAGCCTTACATTATTCAGACCAATGTGT
TACCAATTCGAGAATACAAGAACGTGATAAGGTACCCAAACAACGACTTCTTCCCGAACC
__END_OF_NASEQS__

      @aa = Bio::Alignment::MultiFastaFormat.new <<__END_OF_AASEQS__
>aaseq1
MVHWTAEEKQLITGLWGKVNVAECGAEALARLLIVYPWTQRFFASFGNLSSPTAILGNPMVRAHGKKVLT
>aaseq2
MLTAEEKAAVTGFWGKVKVDEVGAEALGRLLVVYPWTQRFFEHFGDLSSADAVMNNAKVKAHGKKVLDSF
>aaseq3
MVHLTDAEKSAVSCLWAKVNPDEVGGEALGRLLVVYPWTQRYFDSFGDLSSASAIMGNPKVKAHGKKVIT
>aaseq4
MVHLTDAEKAAVNGLWGKVNPDDVGGEALGRLLVVYPWTQRYFDSFGDLSSASAIMGNPKVKAHGKKVIN
__END_OF_AASEQS__
    end #def setup

    def test_alignment
      assert_equal(120, @na.alignment.alignment_length)
      assert_equal(70, @aa.alignment.alignment_length)
    end

    def test_entries
      assert_equal(3, @na.entries.size)
      assert_equal(4, @aa.entries.size)
    end

    def test_determine_seq_method
      @na.alignment
      assert_equal(:naseq, @na.instance_eval { @seq_method })
      @aa.alignment
      assert_equal(:aaseq, @aa.instance_eval { @seq_method })
    end
  end #class TestAlignmentMultiFastaFormat
end #module Bio
