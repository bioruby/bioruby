#
# test/unit/bio/appl/blast/test_report.rb - Unit test for Bio::Blast::Report
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_report.rb,v 1.5 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/blast/report'


module Bio
  class TestBlastReportData
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
    TestDataBlast = Pathname.new(File.join(bioruby_root, 'test', 'data', 'blast')).cleanpath.to_s

    def self.input
      File.open(File.join(TestDataBlast, 'b0002.faa')).read
    end

    def self.output(format = 7)
      case format
      when 0
        File.open(File.join(TestDataBlast, 'b0002.faa.m0')).read 
      when 7
        File.open(File.join(TestDataBlast, 'b0002.faa.m7')).read 
      when 8
        File.open(File.join(TestDataBlast, 'b0002.faa.m8')).read 
      end
    end
  end

    
  class TestBlastReport < Test::Unit::TestCase
    require 'bio/appl/blast/report'

    def setup
      @report = Bio::Blast::Report.new(Bio::TestBlastReportData.output)
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
      assert(@report.inclusion)
    end

    def test_sc_match
      assert(@report.sc_match)
    end

    def test_sc_mismatch
      assert(@report.sc_mismatch)
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

    def test_extrez_query
      assert_equal(nil, @report.entrez_query)
    end

    def test_each_iteration
      @report.each_iteration { |itr| }
    end

    def test_each_hit
      @report.each_hit { |hit| }
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
    def setup
      data = Bio::TestBlastReportData.output
      report = Bio::Blast::Report.new(data)
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
    def setup
      data = Bio::TestBlastReportData.output
      report = Bio::Blast::Report.new(data)
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
    def setup
      data = Bio::TestBlastReportData.output
      report = Bio::Blast::Report.new(data)
      @hsp = report.hits.first.hsps.first
    end
    
    def test_Hsp_num
      assert_equal(1, @hsp.num)
    end

    def test_Hsp_hit_score
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
      assert(@hsp.gaps)
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
      @hsp.pattern_from
    end

    def test_Hsp_pattern_to
      @hsp.pattern_to 
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
      @hsp.percent_identity
    end

    def test_Hsp_mismatch_count
      @hsp.mismatch_count
    end

  end 

end # module Bio
