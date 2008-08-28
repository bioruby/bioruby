#
# test/unit/bio/appl/blast/test_report.rb - Unit test for Bio::Blast::Report
#
# Copyright::  Copyright (C) 2005, 2008
#              Mitsuteru Nakao <n@bioruby.org>,
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/blast/report'


module Bio

  module TestBlastReportHelper
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
    TestDataBlast = Pathname.new(File.join(bioruby_root, 'test', 'data', 'blast')).cleanpath.to_s

    private

    def get_input_data(basename = 'b0002.faa')
      File.open(File.join(TestDataBlast, basename)).read
    end

    def get_output_data(basename = 'b0002.faa', format = 7)
      fn = basename + ".m#{format.to_i}"

      # available filenames:
      # 'b0002.faa.m0'
      # 'b0002.faa.m7'
      # 'b0002.faa.m8'

      File.open(File.join(TestDataBlast, fn)).read
    end

    def create_report_object(basename = 'b0002.faa')
      case self.class.name.to_s
      when /XMLParser/i
        text = get_output_data(basename, 7)
        Bio::Blast::Report.new(text, :xmlparser)
      when /REXML/i
        text = get_output_data(basename, 7)
        Bio::Blast::Report.new(text, :rexml)
      when /Default/i
        text = get_output_data(basename, 0)
        Bio::Blast::Default::Report.new(text)
      when /Tab/i
        text = get_output_data(basename, 8)
        Bio::Blast::Report.new(text)
      else
        text = get_output_data(basename, 7)
        Bio::Blast::Report.new(text)
      end
    end
  end #module TestBlastReportHelper

  class TestBlastReport < Test::Unit::TestCase
    include TestBlastReportHelper

    def setup
      @report = create_report_object
    end
    
    def test_iterations
      assert(@report.iterations)
    end

    def test_parameters
      assert_equal('BLOSUM62', @report.parameters['matrix'])
      assert_equal(10, @report.parameters['expect'])
      assert_equal(11, @report.parameters['gap-open'])
      assert_equal(1, @report.parameters['gap-extend'])
      assert_equal('S', @report.parameters['filter'])
    end

    def test_program
      assert_equal('blastp', @report.program)
    end

    def test_version
      assert_equal('blastp 2.2.10 [Oct-19-2004]', @report.version)
    end

    def test_reference
      xml_quoted_str = "~Reference: Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer, ~Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997), ~&quot;Gapped BLAST and PSI-BLAST: a new generation of protein database search~programs&quot;,  Nucleic Acids Res. 25:3389-3402."
      text_str = '~Reference: Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer, ~Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997), ~"Gapped BLAST and PSI-BLAST: a new generation of protein database search~programs",  Nucleic Acids Res. 25:3389-3402.'
#      assert_equal(xml_quoted_str, @report.reference)
      assert_equal(text_str, @report.reference)
    end

    def test_db
      assert_equal('b0002.faa', @report.db)
    end

    def test_query_id
      assert_equal('lcl|QUERY', @report.query_id)
    end

    def test_query_def
      assert_equal('eco:b0002 thrA, Hs, thrD, thrA2, thrA1; bifunctional: aspartokinase I (N-terminal); homoserine dehydrogenase I (C-terminal) [EC:2.7.2.4 1.1.1.3]; K00003 homoserine dehydrogenase; K00928 aspartate kinase (A)', @report.query_def)
    end

    def test_query_len
      assert_equal(820, @report.query_len)
    end

    def test_matrix
      assert_equal('BLOSUM62', @report.matrix)
    end

    def test_expect
      assert_equal(10, @report.expect)
    end

    def test_inclusion
      assert_nothing_raised { @report.inclusion }
    end

    def test_sc_match
      assert_nothing_raised { @report.sc_match }
    end

    def test_sc_mismatch
      assert_nothing_raised { @report.sc_mismatch }
    end

    def test_gap_open
      assert_equal(11, @report.gap_open)
    end

    def test_gap_extend
      assert_equal(1, @report.gap_extend)
    end

    def test_filter
      assert_equal('S', @report.filter)
    end

    def test_pattern
      assert_equal(nil, @report.pattern)
    end

    def test_entrez_query
      assert_equal(nil, @report.entrez_query)
    end

    def test_each_iteration
      assert_nothing_raised {
        @report.each_iteration { |itr| }
      }
    end

    def test_each_hit
      assert_nothing_raised {
        @report.each_hit { |hit| }
      }
    end

    def test_hits
      assert(@report.hits)
    end

    def test_statistics
      assert_equal({"kappa"=>0.041, "db-num"=>1, "eff-space"=>605284.0, "hsp-len"=>42, "db-len"=>820, "lambda"=>0.267, "entropy"=>0.14}, @report.statistics)
    end

    def test_db_num
      assert_equal(1, @report.db_num)
    end

    def test_db_len
      assert_equal(820, @report.db_len)
    end

    def test_hsp_len
      assert_equal(42, @report.hsp_len)
    end

    def test_eff_space
      assert_equal(605284, @report.eff_space)
    end

    def test_kappa
      assert_equal(0.041, @report.kappa)
    end

    def test_lambda
      assert_equal(0.267, @report.lambda)
    end

    def test_entropy
      assert_equal(0.14, @report.entropy)
    end

    def test_message
      assert_equal(nil, @report.message)
    end
  end
  
  class TestBlastReportIteration < Test::Unit::TestCase
    include TestBlastReportHelper

    def setup
      report = create_report_object
      @itr = report.iterations.first
    end

    def test_hits
      assert(@itr.hits)
    end

    def test_statistics
      stat = {"kappa" => 0.041, "eff-space" => 605284, "db-num" => 1, 
              "hsp-len" => 42, "db-len" => 820, "lambda" => 0.267, 
              "entropy" => 0.14}
      assert_equal(stat, @itr.statistics)
    end

    def test_num
      assert_equal(1, @itr.num)
    end

    def test_message
      assert_equal(nil, @itr.message)
    end
  end

  class TestBlastReportHit < Test::Unit::TestCase
    include TestBlastReportHelper

    def setup
      report = create_report_object
      @hit = report.hits.first
    end

    def test_Hit_hsps
      assert(@hit.hsps)
    end

    def test_Hit_query_id
      assert_equal('lcl|QUERY', @hit.query_id)
    end

    def test_Hit_query_def
      assert_equal('eco:b0002 thrA, Hs, thrD, thrA2, thrA1; bifunctional: aspartokinase I (N-terminal); homoserine dehydrogenase I (C-terminal) [EC:2.7.2.4 1.1.1.3]; K00003 homoserine dehydrogenase; K00928 aspartate kinase (A)', @hit.query_def)
    end

    def test_Hit_query_len
      assert_equal(820, @hit.query_len)
    end

    def test_Hit_num
      assert(@hit.num)
    end

    def test_Hit_hit_id
      assert_equal('gnl|BL_ORD_ID|0', @hit.hit_id) 
    end

    def test_Hit_len
      assert_equal(820, @hit.len)
    end

    def test_Hit_target_len
      assert_equal(820, @hit.target_len)
    end

    def test_Hit_definition
      assert(@hit.definition)
    end

    def test_Hit_taeget_def
      assert(@hit.target_def)
    end

    def test_Hit_accession
      assert(@hit.accession)
    end

    def test_Hit_target_id
      assert(@hit.target_id)
    end
    
    def test_Hit_evalue
      assert_equal(0, @hit.evalue)
    end

    def test_Hit_bit_score
      assert_equal(1567.75, @hit.bit_score)
    end

    def test_Hit_identity
      assert_equal(820, @hit.identity)
    end

    def test_Hit_overlap
      assert_equal(820, @hit.overlap)
    end

    def test_Hit_query_seq
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(seq, @hit.query_seq)
    end

    def test_Hit_target_seq
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(seq, @hit.target_seq)
    end

    def test_Hit_midline
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(seq, @hit.midline)
    end

    def test_Hit_query_start
      assert_equal(1, @hit.query_start)
#      assert_equal(1, @hit.query_from)
    end

    def test_Hit_query_end
      assert_equal(820, @hit.query_end)
#      assert_equal(820, @hit.query_to)
    end

    def test_Hit_target_start
      assert_equal(1, @hit.target_start)
#      assert_equal(1, @hit.hit_from)
    end

    def test_Hit_target_end
      assert_equal(820, @hit.target_end)
#      assert_equal(820, @hit.hit_to)
    end

    def test_Hit_lap_at
      assert_equal([1, 820, 1, 820], @hit.lap_at)
    end
  end

  class TestBlastReportHsp < Test::Unit::TestCase
    include TestBlastReportHelper

    def setup
      report = create_report_object
      @hsp = report.hits.first.hsps.first
    end
    
    def test_Hsp_num
      assert_equal(1, @hsp.num)
    end

    def test_Hsp_bit_score
      assert_equal(1567.75, @hsp.bit_score)
    end

    def test_Hsp_score
      assert_equal(4058, @hsp.score)
    end

    def test_Hsp_evalue
      assert_equal(0, @hsp.evalue)
    end

    def test_Hsp_identity
      assert_equal(820, @hsp.identity)
    end

    def test_Hsp_gaps
      assert_nothing_raised { @hsp.gaps }
    end

    def test_Hsp_positive
      assert_equal(820, @hsp.positive)
    end

    def test_Hsp_align_len
      assert_equal(820, @hsp.align_len)
    end

    def test_Hsp_density
      assert(@hsp.density)
    end

    def test_Hsp_query_frame
      assert_equal(1, @hsp.query_frame)
    end

    def test_Hsp_query_from
      assert_equal(1, @hsp.query_from)
    end

    def test_Hsp_query_to
      assert_equal(820, @hsp.query_to)
    end

    def test_Hsp_hit_frame
      assert_equal(1, @hsp.hit_frame)
    end

    def test_Hsp_hit_from
      assert_equal(1, @hsp.hit_from)
    end

    def test_Hsp_hit_to
      assert_equal(820, @hsp.hit_to)
    end

    def test_Hsp_pattern_from
      assert_nothing_raised { @hsp.pattern_from }
    end

    def test_Hsp_pattern_to
      assert_nothing_raised { @hsp.pattern_to }
    end

    def test_Hsp_qseq
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(seq, @hsp.qseq)
    end

    def test_Hsp_midline
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(seq, @hsp.midline)
    end

    def test_Hsp_hseq
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(seq, @hsp.hseq)
    end

    def test_Hsp_percent_identity
      assert_nothing_raised { @hsp.percent_identity }
    end

    def test_Hsp_mismatch_count
      assert_nothing_raised { @hsp.mismatch_count }
    end

  end 

  class TestBlastReportREXML < TestBlastReport
  end

  class TestBlastReportIterationREXML < TestBlastReportIteration
  end

  class TestBlastReportHitREXML < TestBlastReportHit
  end

  class TestBlastReportHspREXML < TestBlastReportHsp
  end

  if defined? XMLParser then

  class TestBlastReportXMLParser < TestBlastReport
  end

  class TestBlastReportIterationXMLParser < TestBlastReportIteration
  end

  class TestBlastReportHitXMLParser < TestBlastReportHit
  end

  class TestBlastReportHspXMLParser < TestBlastReportHsp
  end

  end #if defined? XMLParser

  class TestBlastReportDefault < TestBlastReport
    undef test_entrez_query
    undef test_filter
    undef test_hsp_len
    undef test_inclusion
    undef test_parameters
    undef test_query_id
    undef test_statistics

    def test_program
      assert_equal('BLASTP', @report.program)
    end

    def test_reference
      text_str = 'Reference: Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer, Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997), "Gapped BLAST and PSI-BLAST: a new generation of protein database search programs", Nucleic Acids Res. 25:3389-3402.'
      assert_equal(text_str, @report.reference)
    end

    def test_version
      assert_equal('BLASTP 2.2.10 [Oct-19-2004]', @report.version)
    end

    def test_kappa
      assert_equal(0.134, @report.kappa)
    end

    def test_lambda
      assert_equal(0.319, @report.lambda)
    end

    def test_entropy
      assert_equal(0.383, @report.entropy)
    end

    def test_gapped_kappa
      assert_equal(0.0410, @report.gapped_kappa)
    end

    def test_gapped_lambda
      assert_equal(0.267, @report.gapped_lambda)
    end

    def test_gapped_entropy
      assert_equal(0.140, @report.gapped_entropy)
    end
  end

  class TestBlastReportIterationDefault < TestBlastReportIteration
    undef test_statistics
  end

  class TestBlastReportHitDefault < TestBlastReportHit
    undef test_Hit_accession
    undef test_Hit_hit_id
    undef test_Hit_num
    undef test_Hit_query_def
    undef test_Hit_query_id
    undef test_Hit_query_len

    def setup
      @filtered_query_sequence = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQxxxxxxxxxxxxxxALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      super
    end

    def test_Hit_bit_score
      # differs from XML because of truncation in the default format
      assert_equal(1567.0, @hit.bit_score)
    end

    def test_Hit_identity
      # differs from XML because filtered residues are not counted in the
      # default format
      assert_equal(806, @hit.identity)
    end

    def test_Hit_midline
      # differs from XML because filtered residues are not specified in XML
      seq = @filtered_query_sequence.gsub(/x/, ' ')
      assert_equal(seq, @hit.midline)
    end

    def test_Hit_query_seq
      # differs from XML because filtered residues are not specified in XML
      seq = @filtered_query_sequence.gsub(/x/, 'X')
      assert_equal(seq, @hit.query_seq)
    end
  end

  class TestBlastReportHspDefault < TestBlastReportHsp
    undef test_Hsp_density
    undef test_Hsp_mismatch_count
    undef test_Hsp_num
    undef test_Hsp_pattern_from
    undef test_Hsp_pattern_to

    def setup
      @filtered_query_sequence = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQxxxxxxxxxxxxxxALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      super
    end

    def test_Hsp_identity
      # differs from XML because filtered residues are not counted in the
      # default format
      assert_equal(806, @hsp.identity)
    end

    def test_Hsp_positive
      # differs from XML because filtered residues are not counted in the
      # default format
      assert_equal(806, @hsp.positive)
    end

    def test_Hsp_midline
      # differs from XML because filtered residues are not specified in XML
      seq = @filtered_query_sequence.gsub(/x/, ' ')
      assert_equal(seq, @hsp.midline)
    end

    def test_Hsp_qseq
      # differs from XML because filtered residues are not specified in XML
      seq = @filtered_query_sequence.gsub(/x/, 'X')
      assert_equal(seq, @hsp.qseq)
    end
    
    def test_Hsp_bit_score
      # differs from XML because of truncation in the default format
      assert_equal(1567.0, @hsp.bit_score)
    end

    def test_Hsp_hit_frame
      # differs from XML because not available in the default BLASTP format
      assert_equal(nil, @hsp.hit_frame)
    end

    def test_Hsp_query_frame
      # differs from XML because not available in the default BLASTP format
      assert_equal(nil, @hsp.query_frame)
    end
  end

  ########################################################################
  # Tests for new BLAST XML format (blastall 2.2.14 or later)
  # with the result of multiple query sequences
  ########################################################################

  class TestBlastReportMulti < Test::Unit::TestCase
    include TestBlastReportHelper

    def setup
      @report = create_report_object('blastp-multi')
      @overall = [ @report ] + @report.reports
    end

    def test_reports
      assert_equal(5, @report.reports.size)
    end

    def test_iterations
      assert_equal(1, @report.iterations.size)
      assert_equal([ 1, 1, 1, 1, 1],
                   @report.reports.collect { |x| x.iterations.size })
    end

    def test_parameters
      @overall.each do |r|
        assert_equal('BLOSUM62', r.parameters['matrix'])
        assert_equal(0.001,      r.parameters['expect'])
        assert_equal(11,         r.parameters['gap-open'])
        assert_equal(1,          r.parameters['gap-extend'])
        assert_equal('F',        r.parameters['filter'])
      end
    end

    def test_program
      @overall.each do |r|
        assert_equal('blastp', r.program)
      end
    end

    def test_version
      @overall.each do |r|
        assert_equal('blastp 2.2.18 [Mar-02-2008]', r.version)
      end
    end

    def test_reference
      text_str = '~Reference: Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer, ~Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997), ~"Gapped BLAST and PSI-BLAST: a new generation of protein database search~programs",  Nucleic Acids Res. 25:3389-3402.'

      @overall.each do |r|
        assert_equal(text_str, r.reference)
      end
    end

    def test_db
      @overall.each do |r|
        assert_equal('BA000007.faa', r.db)
      end
    end

    def test_query_id
      qids = [ 'lcl|1_0', 'lcl|2_0', 'lcl|3_0', nil, 'lcl|5_0' ]
      assert_equal(qids[0], @report.query_id)
      assert_equal(qids,
                   @report.reports.collect { |r| r.query_id })
    end

    def test_query_def
      qdefs =
        [ 'gi|1790845|gb|AAC77338.1| predicted DNA-binding transcriptional regulator [Escherichia coli str. K-12 substr. MG1655]',
          'gi|1790846|gb|AAC77339.1| lipoate-protein ligase A [Escherichia coli str. K-12',
          'gi|1790847|gb|AAC77340.1| conserved protein [Escherichia coli str. K-12 substr. MG1655]',
          nil,
          'gi|1790849|gb|AAC77341.1| 3-phosphoserine phosphatase [Escherichia coli str. K-12 substr. MG1655]'
        ]
      assert_equal(qdefs[0], @report.query_def)
      assert_equal(qdefs,
                   @report.reports.collect { |r| r.query_def })
    end

    def test_query_len
      qlens = [ 443, 346, 214, nil, 322 ]
      assert_equal(qlens[0], @report.query_len)
      assert_equal(qlens,
                   @report.reports.collect { |r| r.query_len })
    end

    def test_matrix
      @overall.each do |r|
        assert_equal('BLOSUM62', r.matrix)
      end
    end

    def test_expect
      @overall.each do |r|
        assert_equal(0.001, r.expect)
      end
    end

    def test_gap_open
      @overall.each do |r|
        assert_equal(11, r.gap_open)
      end
    end

    def test_gap_extend
      @overall.each do |r|
        assert_equal(1, r.gap_extend)
      end
    end

    def test_filter
      @overall.each do |r|
        assert_equal('F', r.filter)
      end
    end

    def test_pattern
      @overall.each do |r|
        assert_equal(nil, r.pattern)
      end
    end

    def test_each_iteration
      @overall.each do |r|
        count = 0
        assert_nothing_raised {
          r.each_iteration { |itr| count += 1 }
        }
        assert_equal(1, count)
      end
    end

    def test_each_hit
      @overall.each do |r|
        assert_nothing_raised {
          r.each_hit { |hit| }
        }
      end
    end

    def test_hits
      hsizes = [ 0, 1, 1, 0, 2 ]
      assert_equal(hsizes[0], @report.hits.size)
      assert_equal(hsizes,
                   @report.reports.collect { |r| r.hits.size })
    end

    def test_statistics
      assert_equal({}, @report.statistics)

      stat = {
        "kappa" => 0.041, "eff-space" => 0, "db-num" => 5361, 
        "hsp-len" => 0, "db-len" => 1609188, "lambda" => 0.267, 
        "entropy" => 0.14
      }
      stats = [ {}, stat, stat, {}, stat ]
      @report.reports.each do |r|
        assert_equal(stats.shift, r.statistics)
      end
    end

    def test_db_num
      assert_equal(nil, @report.db_num)
      ary = [ nil, 5361, 5361, nil, 5361 ]
      @report.reports.each do |r|
        assert_equal(ary.shift, r.db_num)
      end
    end

    def test_db_len
      assert_equal(nil, @report.db_len)
      ary = [ nil, 1609188, 1609188, nil, 1609188 ]
      @report.reports.each do |r|
        assert_equal(ary.shift, r.db_len)
      end
    end

    def test_hsp_len
      assert_equal(nil, @report.hsp_len)
      ary = [ nil, 0, 0, nil, 0 ]
      @report.reports.each do |r|
        assert_equal(ary.shift, r.hsp_len)
      end
    end

    def test_eff_space
      assert_equal(nil, @report.eff_space)
      ary = [ nil, 0, 0, nil, 0 ]
      @report.reports.each do |r|
        assert_equal(ary.shift, r.eff_space)
      end
    end

    def test_kappa
      assert_equal(nil, @report.kappa)
      ary = [ nil, 0.041, 0.041, nil, 0.041 ]
      @report.reports.each do |r|
        assert_equal(ary.shift, r.kappa)
      end
    end

    def test_lambda
      assert_equal(nil, @report.lambda)
      ary = [ nil, 0.267, 0.267, nil, 0.267 ]
      @report.reports.each do |r|
        assert_equal(ary.shift, r.lambda)
      end
    end

    def test_entropy
      assert_equal(nil, @report.entropy)
      ary = [ nil, 0.14, 0.14, nil, 0.14 ]
      @report.reports.each do |r|
        assert_equal(ary.shift, r.entropy)
      end
    end

    def test_message
      @overall.each do |r|
        assert_equal(nil, r.message)
      end
    end
  end
  
  class TestBlastReportIterationMulti < Test::Unit::TestCase
    include TestBlastReportHelper

    def setup
      report = create_report_object('blastp-multi')
      @itr = report.reports[4].iterations[0]
    end

    def test_query_id
      assert_equal('lcl|5_0', @itr.query_id)
    end

    def test_query_def
      assert_equal('gi|1790849|gb|AAC77341.1| 3-phosphoserine phosphatase [Escherichia coli str. K-12 substr. MG1655]', @itr.query_def)
    end

    def test_query_len
      assert_equal(322, @itr.query_len)
    end

    def test_hits
      assert_equal(2, @itr.hits.size)
    end

    def test_each
      count = 0
      assert_nothing_raised {
        @itr.each { |hit| count += 1 }
      }
      assert_equal(2, count)
    end

    def test_statistics
      stat = {
        "kappa" => 0.041, "eff-space" => 0, "db-num" => 5361, 
        "hsp-len" => 0, "db-len" => 1609188, "lambda" => 0.267, 
        "entropy" => 0.14
      }
      assert_equal(stat, @itr.statistics)
    end

    def test_num
      assert_equal(5, @itr.num)
    end

    def test_message
      assert_equal(nil, @itr.message)
    end
  end

  class TestBlastReportHitMulti < Test::Unit::TestCase
    include TestBlastReportHelper

    def setup
      report = create_report_object('blastp-multi')
      @hit = report.reports[4].iterations[0].hits[1]
    end

    def test_Hit_hsps
      assert_equal(1, @hit.hsps.size)
    end

    def test_Hit_query_id
      assert_equal('lcl|5_0', @hit.query_id)
    end

    def test_Hit_query_def
      assert_equal('gi|1790849|gb|AAC77341.1| 3-phosphoserine phosphatase [Escherichia coli str. K-12 substr. MG1655]', @hit.query_def)
    end

    def test_Hit_query_len
      assert_equal(322, @hit.query_len)
    end

    def test_Hit_num
      assert_equal(2, @hit.num)
    end

    def test_Hit_hit_id
      assert_equal('gi|13363792|dbj|BAB37741.1|', @hit.hit_id) 
    end

    def test_Hit_len
      assert_equal(732, @hit.len)
    end

    def test_Hit_target_len
      assert_equal(732, @hit.target_len)
    end

    def test_Hit_definition
      assert_equal('zinc-transporting ATPase [Escherichia coli O157:H7 str. Sakai]', @hit.definition)
    end

    def test_Hit_taeget_def
      assert_equal('zinc-transporting ATPase [Escherichia coli O157:H7 str. Sakai]', @hit.target_def)
    end

    def test_Hit_accession
      assert_equal('BAB37741', @hit.accession)
    end

    def test_Hit_target_id
      #assert_equal('gi|13363792|dbj|BAB37741.1|', @hit.target_id)
      assert_equal('BAB37741', @hit.target_id)
    end
    
    def test_Hit_evalue
      assert_equal(0.000899657, @hit.evalue)
    end

    def test_Hit_bit_score
      assert_equal(38.1206, @hit.bit_score)
    end

    def test_Hit_identity
      assert_equal(39, @hit.identity)
    end

    def test_Hit_overlap
      # alignment length
      assert_equal(123, @hit.overlap)
    end

    def test_Hit_query_seq
      seq = 'VLKLETLGWKVAIASGGFTFFAEYLRDKLRLTAVVANELEIMDGKFTGNVIGDIVDAQYKAKTLTRLAQEYEIPLAQTVAIGDGANDLPMIKAAGLGIAYHAKPKVN-EKAEVTIRHADLMGV'
      assert_equal(seq, @hit.query_seq)
    end

    def test_Hit_target_seq
      seq = 'ISELNALGVKGVILTG----------DNPRAAAAIAGELGL---EFKAGLL-----PEDKVKAVTELNQHA--PLAM---VGDGINDAPAMKAAAIGIAMGSGTDVALETADAALTHNHLRGL'
      assert_equal(seq, @hit.target_seq)
    end

    def test_Hit_midline
      seq = '+ +L  LG K  I +G          D  R  A +A EL +   +F   ++      + K K +T L Q    PLA    +GDG ND P +KAA +GIA  +   V  E A+  + H  L G+'
      assert_equal(seq, @hit.midline)
    end

    def test_Hit_query_start
      assert_equal(190, @hit.query_start)
#      assert_equal(190, @hit.query_from)
    end

    def test_Hit_query_end
      assert_equal(311, @hit.query_end)
#      assert_equal(311, @hit.query_to)
    end

    def test_Hit_target_start
      assert_equal(569, @hit.target_start)
#      assert_equal(569, @hit.hit_from)
    end

    def test_Hit_target_end
      assert_equal(668, @hit.target_end)
#      assert_equal(668, @hit.hit_to)
    end

    def test_Hit_lap_at
      assert_equal([190, 311, 569, 668], @hit.lap_at)
    end
  end

  class TestBlastReportHspMulti < Test::Unit::TestCase
    include TestBlastReportHelper

    def setup
      report = create_report_object('blastp-multi')
      @hsp = report.reports[4].iterations[0].hits[1].hsps[0]
    end
    
    def test_Hsp_num
      assert_equal(1, @hsp.num)
    end

    def test_Hsp_bit_score
      assert_equal(38.1206, @hsp.bit_score)
    end

    def test_Hsp_score
      assert_equal(87, @hsp.score)
    end

    def test_Hsp_evalue
      assert_equal(0.000899657, @hsp.evalue)
    end

    def test_Hsp_identity
      assert_equal(39, @hsp.identity)
    end

    def test_Hsp_gaps
      assert_equal(24, @hsp.gaps)
    end

    def test_Hsp_positive
      assert_equal(56, @hsp.positive)
    end

    def test_Hsp_align_len
      assert_equal(123, @hsp.align_len)
    end

    def test_Hsp_density
      assert_nothing_raised { @hsp.density }
    end

    def test_Hsp_query_frame
      assert_equal(1, @hsp.query_frame)
    end

    def test_Hsp_query_from
      assert_equal(190, @hsp.query_from)
    end

    def test_Hsp_query_to
      assert_equal(311, @hsp.query_to)
    end

    def test_Hsp_hit_frame
      assert_equal(1, @hsp.hit_frame)
    end

    def test_Hsp_hit_from
      assert_equal(569, @hsp.hit_from)
    end

    def test_Hsp_hit_to
      assert_equal(668, @hsp.hit_to)
    end

    def test_Hsp_pattern_from
      assert_nothing_raised { @hsp.pattern_from }
    end

    def test_Hsp_pattern_to
      assert_nothing_raised { @hsp.pattern_to }
    end

    def test_Hsp_qseq
      seq = 'VLKLETLGWKVAIASGGFTFFAEYLRDKLRLTAVVANELEIMDGKFTGNVIGDIVDAQYKAKTLTRLAQEYEIPLAQTVAIGDGANDLPMIKAAGLGIAYHAKPKVN-EKAEVTIRHADLMGV'
      assert_equal(seq, @hsp.qseq)
    end

    def test_Hsp_midline
      seq = '+ +L  LG K  I +G          D  R  A +A EL +   +F   ++      + K K +T L Q    PLA    +GDG ND P +KAA +GIA  +   V  E A+  + H  L G+'
      assert_equal(seq, @hsp.midline)
    end

    def test_Hsp_hseq
      seq = 'ISELNALGVKGVILTG----------DNPRAAAAIAGELGL---EFKAGLL-----PEDKVKAVTELNQHA--PLAM---VGDGINDAPAMKAAAIGIAMGSGTDVALETADAALTHNHLRGL'
      assert_equal(seq, @hsp.hseq)
    end

    def test_Hsp_percent_identity
      assert_nothing_raised { @hsp.percent_identity }
    end

    def test_Hsp_mismatch_count
      assert_nothing_raised { @hsp.mismatch_count }
    end

  end 

  # Tests for REXML version
  class TestBlastReportMultiREXML < TestBlastReportMulti
  end

  class TestBlastReportIterationMultiREXML < TestBlastReportIterationMulti
  end

  class TestBlastReportHitMultiREXML < TestBlastReportHitMulti
  end

  class TestBlastReportHspMultiREXML < TestBlastReportHspMulti
  end

  # Tests for XMLParser version
  if defined? XMLParser then

  class TestBlastReportMultiXMLParser < TestBlastReportMulti
  end

  class TestBlastReportIterationMultiXMLParser < TestBlastReportIterationMulti
  end

  class TestBlastReportHitMultiXMLParser < TestBlastReportHitMulti
  end

  class TestBlastReportHspMultiXMLParser < TestBlastReportHspMulti
  end

  end #if defined? XMLParser

end # module Bio
