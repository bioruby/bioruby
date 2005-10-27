#
# test/unit/bio/db/test_fasta.rb - Unit test for Bio::FastaFormat
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
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
#  $Id: test_fasta.rb,v 1.1 2005/10/27 14:21:23 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/fasta'

module Bio
  class TestFastaFormatConst < Test::Unit::TestCase

    def test_delimiter
      assert_equal(Bio::FastaFormat::DELIMITER, "\n>")
      assert_equal(Bio::FastaFormat::RS, "\n>")
    end

  end # class TestFastaFormatConst


  class TestFastaFormat < Test::Unit::TestCase

    def setup
      text =<<END
>sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]
MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG
VPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME
GIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL
KLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC
IFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP
QWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES
>sce:YBR274W  CHK1; probable serine/threonine-protein kinase [EC:2.7.1.-] [SP:KB9S_YEAST]
MSLSQVSPLPHIKDVVLGDTVGQGAFACVKNAHLQMDPSIILAVKFIHVP
TCKKMGLSDKDITKEVVLQSKCSKHPNVLRLIDCNVSKEYMWIILEMADG
GDLFDKIEPDVGVDSDVAQFYFQQLVSAINYLHVECGVAHRDIKPENILL
DKNGNLKLADFGLASQFRRKDGTLRVSMDQRGSPPYMAPEVLYSEEGYYA
DRTDIWSIGILLFVLLTGQTPWELPSLENEDFVFFIENDGNLNWGPWSKI
EFTHLNLLRKILQPDPNKRVTLKALKLHPWVLRRASFSGDDGLCNDPELL
AKKLFSHLKVSLSNENYLKFTQDTNSNNRYISTQPIGNELAELEHDSMHF
QTVSNTQRAFTSYDSNTNYNSGTGMTQEAKWTQFISYDIAALQFHSDEND
CNELVKRHLQFNPNKLTKFYTLQPMDVLLPILEKALNLSQIRVKPDLFAN
FERLCELLGYDNVFPLIINIKTKSNGGYQLCGSISIIKIEEELKSVGFER
KTGDPLEWRRLFKKISTICRDIILIPN
END
      @obj = Bio::FastaFormat.new(text)
    end

    def test_entry
      data = ">sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]\nMSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG\nVPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME\nGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL\nKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC\nIFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP\nQWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES\n"
      assert_equal(@obj.entry, data)
    end

    def test_entry_id
      assert_equal(@obj.entry_id, 'sce:YBR160W')
    end

    def test_definition
      data = "sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]"
      assert_equal(@obj.definition, data)
    end

    def test_data
      data = "\nMSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG\nVPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME\nGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL\nKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC\nIFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP\nQWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES\n"
      assert_equal(@obj.data, data)
    end

    def test_seq
      seq = 'MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEGVPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYMEGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNLKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGCIFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFPQWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES'
      assert_equal(@obj.seq, seq)
    end

    def test_length
      assert_equal(@obj.length, 298)
    end

    def test_naseq
      seq = 'msgelanykrlekvgegtygvvykaldlrpgqgqrvvalkkirlesedegvpstaireisllkelkddnivrlydivhsdahklylvfefldldlkrymegipkdqplgadivkkfmmqlckgiaychshrilhrdlkpqnllinkdgnlklgdfglarafgvplraytheivtlwyrapevllggkqystgvdtwsigcifaemcnrkpifsgdseidqifkifrvlgtpneaiwpdivylpdfkpsfpqwrrkdlsqvvpsldprgidlldkllaydpinrisarraaihpyfqes'
      assert_equal(@obj.naseq, seq)
    end

    def test_nalen
      assert_equal(@obj.nalen, 298)
    end

    def test_aaseq
      seq = "MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEGVPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYMEGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNLKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGCIFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFPQWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES"
      assert_equal(@obj.aaseq, seq)
    end

    def test_aalen
      assert_equal(@obj.aalen, 298)
    end

    def test_identifiers
      assert_equal(@obj.identifiers, '')
    end

    def test_gi
      assert_equal(@obj.gi, '')
    end

    def test_accession
      assert_equal(@obj.accession, '')
    end

    def test_accessions
      assert_equal(@obj.accessions, '')
    end

    def test_acc_version
      assert_equal(@obj.acc_version, '')
    end

    def test_locus
      assert_equal(@obj.locus, '')
    end

  end # class TestFastaFormat


  class TestFastaNumericFormat < Test::Unit::TestCase

    def setup
      text =<<END
>CRA3575282.F 
24 15 23 29 20 13 20 21 21 23 22 25 13 22 17 15 25 27 32 26  
32 29 29 25
END
      @obj = Bio::FastaNumericFormat.new(text)
    end

    def test_entry
      assert_equal(@obj.entry, ">CRA3575282.F\n24 15 23 29 20 13 20 21 21 23 22 25 13 22 17 15 25 27 32 26  \n32 29 29 25\n")
    end

    def test_entry_id
      assert_equal(@obj.entry_id, 'CRA3575282.F') 
    end

    def test_definition
      assert_equal(@obj.definition, 'CRA3575282.F')
    end

    def test_data
      data = [24, 15, 23, 29, 20, 13, 20, 21, 21, 23, 22, 25, 13, 22, 17, 15, 25, 27, 32, 26, 32, 29, 29, 25]
      assert_equal(@obj.data, data)
    end

    def test_length
      assert_equal(@obj.length, 24)
    end

    def test_each
      assert(@obj.each {|x| })
    end

    def test_arg
      assert(@obj[0], '')
      assert(@obj[-1], '')
    end


  end # class TestFastaFormatNumeric


  class TestFastaDefinition < Test::Unit::TestCase

    def setup
    end

    def test_defline
    end
  end # class TestFastaDefinition

end
