#
# test/unit/bio/db/test_fasta.rb - Unit test for Bio::FastaFormat
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_fasta.rb,v 1.5 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/fasta'

module Bio
  class TestFastaFormatConst < Test::Unit::TestCase

    def test_delimiter
      assert_equal("\n>", Bio::FastaFormat::DELIMITER)
      assert_equal("\n>", Bio::FastaFormat::RS)
    end

  end # class TestFastaFormatConst


  class TestFastaFormatSwissProt < Test::Unit::TestCase
    def setup
      text =<<END
>gi|1171674|sp|P42267|NDD_BPR69 NUCLEAR DISRUPTION PROTEIN
MKYMTVTDLNNAGATVIGTIKGGEWFLGTPHKDILSKPGFYFLVSKLDGRPFSNPCVSARFYVGNQRSKQGFSAVLSHIR
QRRSQLARTIANNNMVYTVFYLPASKMKPLTTGFGKGQLALAFTRNHHSEYQTLEEMNRMLADNFKFVLQAY
END
      @obj = Bio::FastaFormat.new(text)
    end

    def test_locus
      assert_equal(nil, @obj.locus)
    end
  end

  class TestFastaFormatKeggGenesNT < Test::Unit::TestCase
    def setup
      text =<<END
>eco:b0001 thrL; thr operon leader peptide (N)
atgaaacgcattagcaccaccattaccaccaccatcaccattaccacaggtaacggtgcg
ggctga
END
      @obj = Bio::FastaFormat.new(text)
    end

    def test_naseq_class
      assert_equal(Bio::Sequence::NA, @obj.naseq.class)
    end

    def test_naseq
      seq = 'atgaaacgcattagcaccaccattaccaccaccatcaccattaccacaggtaacggtgcgggctga'
      assert_equal(seq, @obj.naseq)
    end

    def test_nalen
      assert_equal(66, @obj.nalen)
    end
  end

  class TestFastaFormatKeggGenesAA < Test::Unit::TestCase
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

    def test_entry_id
      assert_equal('sce:YBR160W', @obj.entry_id)
    end

    def test_acc_version
      assert_equal(nil, @obj.acc_version)
    end

    def test_entry
      data = ">sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]\nMSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG\nVPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME\nGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL\nKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC\nIFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP\nQWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES\n"
      assert_equal(data, @obj.entry)
    end

    def test_definition
      data = "sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]"
      assert_equal(data, @obj.definition)
    end

    def test_data
      data = "\nMSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG\nVPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME\nGIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL\nKLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC\nIFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP\nQWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES\n"
      assert_equal(data, @obj.data)
    end
  end

  class TestFastaFormat < Test::Unit::TestCase

    def setup
      text =<<END
>gi|55416189|gb|AAV50056.1| NADH dehydrogenase subunit 1 [Dasyurus hallucatus]
MFTINLLIYIIPILLAVAFLTLIERKMLGYMQFRKGPNIVGPYGLLQPFADAVKLFTKEPLRPLTSSISIFIIAPILALT
IALTIWTPLPMPNTLLDLNLGLIFILSLSGLSVYSILWSGWASNSKYALIGALRAVAQTISYEVSLAIILLSIMLINGSF
TLKTLSITQENLWLIITTWPLAMMWYISTLAETNRAPFDLTEGESELVSGFNVEYAAGPFAMFFLAEYANIIAMNAITTI
LFLGPSLTPNLSHLNTLSFMLKTLLLTMVFLWVRASYPRFRYDQLMHLLWKNFLPMTLAMCLWFISLPIALSCIPPQL
>gi|55416190|gb|AAV50057.1| NADH dehydrogenase subunit 2 [Dasyurus hallucatus]
MSPYVLMILTLSLFIGTCLTIFSNHWFTAWMGLEINTLAIIPLMTAPNNPRSTEAATKYFLTQATASMLMMFAIIYNAWS
TNQWALPQLSDDWISLLMTVALAIKLGLAPFHFWVPEVTQGIPLLTGMILLTWQKIAPTAILFQIAPYLNMKFLVILAIL
STLVGGWGGLNQTHLRKILAYSSIAHMGWMIIIVQINPTLSIFTLTIYVMATLTTFLTLNLSNSTKIKSLGNLWNKSATA
TIIIFLTLLSLGGLPPLTGFMPKWLILQELINNGNIITATMMALSALLNLFFYMRLIYASSLTMFPSINNSKMQWYNNSM
KTTTLIPTATVISSLLLPLTPLFVTLY
END
      @obj = Bio::FastaFormat.new(text)
    end

    def test_entry
      data = ">gi|55416189|gb|AAV50056.1| NADH dehydrogenase subunit 1 [Dasyurus hallucatus]\nMFTINLLIYIIPILLAVAFLTLIERKMLGYMQFRKGPNIVGPYGLLQPFADAVKLFTKEPLRPLTSSISIFIIAPILALT\nIALTIWTPLPMPNTLLDLNLGLIFILSLSGLSVYSILWSGWASNSKYALIGALRAVAQTISYEVSLAIILLSIMLINGSF\nTLKTLSITQENLWLIITTWPLAMMWYISTLAETNRAPFDLTEGESELVSGFNVEYAAGPFAMFFLAEYANIIAMNAITTI\nLFLGPSLTPNLSHLNTLSFMLKTLLLTMVFLWVRASYPRFRYDQLMHLLWKNFLPMTLAMCLWFISLPIALSCIPPQL\n"
      assert_equal(data, @obj.entry)
    end

    def test_entry_id
      assert_equal('gi|55416189', @obj.entry_id)
    end

    def test_definition
      data = "gi|55416189|gb|AAV50056.1| NADH dehydrogenase subunit 1 [Dasyurus hallucatus]"
      assert_equal(data, @obj.definition)
    end

    def test_data
      data = "\nMFTINLLIYIIPILLAVAFLTLIERKMLGYMQFRKGPNIVGPYGLLQPFADAVKLFTKEPLRPLTSSISIFIIAPILALT\nIALTIWTPLPMPNTLLDLNLGLIFILSLSGLSVYSILWSGWASNSKYALIGALRAVAQTISYEVSLAIILLSIMLINGSF\nTLKTLSITQENLWLIITTWPLAMMWYISTLAETNRAPFDLTEGESELVSGFNVEYAAGPFAMFFLAEYANIIAMNAITTI\nLFLGPSLTPNLSHLNTLSFMLKTLLLTMVFLWVRASYPRFRYDQLMHLLWKNFLPMTLAMCLWFISLPIALSCIPPQL\n"
      assert_equal(data, @obj.data)
    end

    def test_seq
      seq = 'MFTINLLIYIIPILLAVAFLTLIERKMLGYMQFRKGPNIVGPYGLLQPFADAVKLFTKEPLRPLTSSISIFIIAPILALTIALTIWTPLPMPNTLLDLNLGLIFILSLSGLSVYSILWSGWASNSKYALIGALRAVAQTISYEVSLAIILLSIMLINGSFTLKTLSITQENLWLIITTWPLAMMWYISTLAETNRAPFDLTEGESELVSGFNVEYAAGPFAMFFLAEYANIIAMNAITTILFLGPSLTPNLSHLNTLSFMLKTLLLTMVFLWVRASYPRFRYDQLMHLLWKNFLPMTLAMCLWFISLPIALSCIPPQL'
      assert_equal(seq, @obj.seq)
    end

    def test_length
      assert_equal(318, @obj.length)
    end

    def test_aaseq
      seq = "MFTINLLIYIIPILLAVAFLTLIERKMLGYMQFRKGPNIVGPYGLLQPFADAVKLFTKEPLRPLTSSISIFIIAPILALTIALTIWTPLPMPNTLLDLNLGLIFILSLSGLSVYSILWSGWASNSKYALIGALRAVAQTISYEVSLAIILLSIMLINGSFTLKTLSITQENLWLIITTWPLAMMWYISTLAETNRAPFDLTEGESELVSGFNVEYAAGPFAMFFLAEYANIIAMNAITTILFLGPSLTPNLSHLNTLSFMLKTLLLTMVFLWVRASYPRFRYDQLMHLLWKNFLPMTLAMCLWFISLPIALSCIPPQL"
      assert_equal(seq, @obj.aaseq)
    end

    def test_aalen
      assert_equal(318, @obj.aalen)
    end

    def test_identifiers
      assert_equal(Bio::FastaDefline, @obj.identifiers.class)
    end

    def test_gi
      assert_equal('55416189', @obj.gi)
    end

    def test_accession
      assert_equal('AAV50056', @obj.accession)
    end

    def test_accessions
      assert_equal(['AAV50056'], @obj.accessions)
    end

    def test_acc_version
      assert_equal('AAV50056.1', @obj.acc_version)
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
      assert_equal(">CRA3575282.F\n24 15 23 29 20 13 20 21 21 23 22 25 13 22 17 15 25 27 32 26  \n32 29 29 25\n", @obj.entry)
    end

    def test_entry_id
      assert_equal('CRA3575282.F', @obj.entry_id) 
    end

    def test_definition
      assert_equal('CRA3575282.F', @obj.definition)
    end

    def test_data
      data = [24, 15, 23, 29, 20, 13, 20, 21, 21, 23, 22, 25, 13, 22, 17, 15, 25, 27, 32, 26, 32, 29, 29, 25]
      assert_equal(data, @obj.data)
    end

    def test_length
      assert_equal(24, @obj.length)
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
