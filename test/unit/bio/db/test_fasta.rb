#
# test/unit/bio/db/test_fasta.rb - Unit test for Bio::FastaFormat
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
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
    
    def test_first_name
      assert_equal('sce:YBR160W', @obj.first_name)
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

    def test_entry_overrun
      data =<<END
>gi|55416190|gb|AAV50057.1| NADH dehydrogenase subunit 2 [Dasyurus hallucatus]
MSPYVLMILTLSLFIGTCLTIFSNHWFTAWMGLEINTLAIIPLMTAPNNPRSTEAATKYFLTQATASMLMMFAIIYNAWS
TNQWALPQLSDDWISLLMTVALAIKLGLAPFHFWVPEVTQGIPLLTGMILLTWQKIAPTAILFQIAPYLNMKFLVILAIL
STLVGGWGGLNQTHLRKILAYSSIAHMGWMIIIVQINPTLSIFTLTIYVMATLTTFLTLNLSNSTKIKSLGNLWNKSATA
TIIIFLTLLSLGGLPPLTGFMPKWLILQELINNGNIITATMMALSALLNLFFYMRLIYASSLTMFPSINNSKMQWYNNSM
KTTTLIPTATVISSLLLPLTPLFVTLY
END
      assert_equal(data, @obj.entry_overrun)
    end

    class DummyFactory
      def query(str)
        @query_str = str
        "DummyFactoryResult#{str.length}"
      end
      attr_reader :query_str
    end #class DummyFactory

    def test_query
      data =<<END
>gi|55416189|gb|AAV50056.1| NADH dehydrogenase subunit 1 [Dasyurus hallucatus]
MFTINLLIYIIPILLAVAFLTLIERKMLGYMQFRKGPNIVGPYGLLQPFADAVKLFTKEPLRPLTSSISIFIIAPILALT
IALTIWTPLPMPNTLLDLNLGLIFILSLSGLSVYSILWSGWASNSKYALIGALRAVAQTISYEVSLAIILLSIMLINGSF
TLKTLSITQENLWLIITTWPLAMMWYISTLAETNRAPFDLTEGESELVSGFNVEYAAGPFAMFFLAEYANIIAMNAITTI
LFLGPSLTPNLSHLNTLSFMLKTLLLTMVFLWVRASYPRFRYDQLMHLLWKNFLPMTLAMCLWFISLPIALSCIPPQL
END

      factory = DummyFactory.new
      assert_equal("DummyFactoryResult401", @obj.query(factory))
      assert_equal(data, factory.query_str)
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
    
    def test_first_name
      assert_equal('gi|55416189|gb|AAV50056.1|', @obj.first_name)
    end

  end # class TestFastaFormat


  class TestFastaFirstName < Test::Unit::TestCase
    def test_first_name1
      data = ">abc def\nATGC"
      assert_equal 'abc', Bio::FastaFormat.new(data).first_name
    end
    
    def test_first_name_multi_identifier
      data = ">gi|398365175|ref|NP_009718.3| Cdc28p [Saccharomyces cerevisiae S288c] #=> 'gi|398365175|ref|NP_009718.3|\nATGCTG"
      assert_equal 'gi|398365175|ref|NP_009718.3|', Bio::FastaFormat.new(data).first_name
    end
    
    def test_first_name_single_worded_defintion
      data = ">abc\nATGC"
      assert_equal 'abc', Bio::FastaFormat.new(data).first_name
    end
    
    def test_no_definition
      data = ">\nATGC"
      assert_equal '', Bio::FastaFormat.new(data).first_name
    end
    
    def test_tabbed_defintion
      data = ">gabc\tdef\nATGC"
      assert_equal 'gabc', Bio::FastaFormat.new(data).first_name
    end
    
    def test_space_before_first_name
      data = "> gabcds\tdef\nATGC"
      assert_equal 'gabcds', Bio::FastaFormat.new(data).first_name
    end
  end
end
