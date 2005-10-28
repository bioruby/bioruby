#
# test/unit/bio/appl/blast/test_report.rb - Unit test for Bio::Blast::Report
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
#  $Id: test_report.rb,v 1.1 2005/10/28 02:30:57 nakao Exp $
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
      File.open(File.join(TestDataBlast, 'eco:b0002.faa')).read
    end

    def self.output(format = 7)
      case format
      when 0
        File.open(File.join(TestDataBlast, 'eco:b0002.faa.m0')).read 
      when 7
        File.open(File.join(TestDataBlast, 'eco:b0002.faa.m7')).read 
      when 8
        File.open(File.join(TestDataBlast, 'eco:b0002.faa.m8')).read 
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
      assert_equal(@report.parameters['matrix'], 'BLOSUM62')
      assert_equal(@report.parameters['expect'], 10)
      assert_equal(@report.parameters['gap-open'], 11)
      assert_equal(@report.parameters['gap-extend'], 1)
      assert_equal(@report.parameters['filter'], 'S')
    end

    def test_program
      assert_equal(@report.program, 'blastp')
    end

    def test_version
      assert_equal(@report.version, 'blastp 2.2.10 [Oct-19-2004]')
    end

    def test_reference
      xml_quoted_str = "~Reference: Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer, ~Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997), ~&quot;Gapped BLAST and PSI-BLAST: a new generation of protein database search~programs&quot;,  Nucleic Acids Res. 25:3389-3402."
      text_str = '~Reference: Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer, ~Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997), ~"Gapped BLAST and PSI-BLAST: a new generation of protein database search~programs",  Nucleic Acids Res. 25:3389-3402.'
      assert_equal(@report.reference, xml_quoted_str)
      assert_equal(@report.reference, text_str)
    end

    def test_db
      assert_equal(@report.db, 'eco:b0002.faa')
    end

    def test_query_id
      assert_equal(@report.query_id, 'lcl|QUERY')
    end

    def test_query_def
      assert_equal(@report.query_def, 'eco:b0002 thrA, Hs, thrD, thrA2, thrA1; bifunctional: aspartokinase I (N-terminal); homoserine dehydrogenase I (C-terminal) [EC:2.7.2.4 1.1.1.3]; K00003 homoserine dehydrogenase; K00928 aspartate kinase (A)')
    end

    def test_query_len
      assert_equal(@report.query_len, 820)
    end

    def test_matrix
      assert_equal(@report.matrix, 'BLOSUM62')
    end

    def test_expect
      assert_equal(@report.expect, 10)
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
      assert_equal(@report.gap_open, 11)
    end

    def test_gap_extend
      assert_equal(@report.gap_extend, 1)
    end

    def test_filter
      assert_equal(@report.filter, 'S')
    end

    def test_pattern
      assert(@report.pattern)
    end

    def test_extrez_query
      assert(@report.entrez_query)
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
      assert_equal(@report.statistics, {"kappa"=>0.041, "db-num"=>1, "eff-space"=>605284.0, "hsp-len"=>42, "db-len"=>820, "lambda"=>0.267, "entropy"=>0.14})
    end

    def test_db_num
      assert_equal(@report.db_num, 1)
    end

    def test_db_len
      assert_equal(@report.db_len, 820)
    end

    def test_hsp_len
      assert_equal(@report.hsp_len, 42)
    end

    def test_eff_space
      assert_equal(@report.eff_space, 605284)
    end

    def test_kappa
      assert_equal(@report.kappa, 0.041)
    end

    def test_lambda
      assert_equal(@report.lambda, 0.267)
    end

    def test_entropy
      assert_equal(@report.entropy, 0.14)
    end

    def test_message
      assert(@report.message)
    end
  end
  
  class TestBlastReportIteration < Test::Unit::TestCase
    def setup
      data = Bio::TestBlastData.data
      report = Bio::Blast::Report.new(data)
      @itr = report.iterations.first
    end

    def test_hits
      assert(@itr.hits)
    end

    def test_statistics
      assert(@itr.statistics)
    end

    def test_num
      assert_equal(@itr.num, 1)
    end

    def test_message
      assert(@itr.message)
    end
  end

  class TestBlastReportHit < Test::Unit::TestCase
    def setup
      data = Bio::TestBlastData.data
      report = Bio::Blast::Report.new(data)
      @hit = report.hits.first
    end

    def test_Hit_hsps
      assert(@hit.hsps)
    end

    def test_Hit_query_id
      assert_equal(@hit.query_id, 'lcl|QUERY')
    end

    def test_Hit_query_def
      assert_equal(@hit.query_def, 'eco:b0002 thrA, Hs, thrD, thrA2, thrA1; bifunctional: aspartokinase I (N-terminal); homoserine dehydrogenase I (C-terminal) [EC:2.7.2.4 1.1.1.3]; K00003 homoserine dehydrogenase; K00928 aspartate kinase (A)')
    end

    def test_Hit_query_len
      assert_equal(@hit.query_len, 820)
    end

    def test_Hit_num
      assert(@hit.num)
    end

    def test_Hit_hit_id
      assert_equal(@hit.hit_id, 'gnl|BL_ORD_ID|0') 
    end

    def test_Hit_len
      assert_equal(@hit.len, 820)
    end

    def test_Hit_target_len
      assert_equal(@hit.target_len, 820)
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
      assert_equal(@hit.evalue, 0)
    end

    def test_Hit_bit_score
      assert_equal(@hit.bit_score, 1567.75)
    end

    def test_Hit_identity
      assert_equal(@hit.identity, 820)
    end

    def test_Hit_overlap
      assert_equal(@hit.overlap, 820)
    end

    def test_Hit_query_seq
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(@hit.query_seq, seq)
    end

    def test_Hit_target_seq
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(@hit.target_seq, seq)
    end

    def test_Hit_midline
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(@hit.midline, seq)
    end

    def test_Hit_query_start
      assert_equal(@hit.query_start, 1)
#      assert_equal(@hit.query_from, 1)
    end

    def test_Hit_query_end
      assert_equal(@hit.query_end, 820)
#      assert_equal(@hit.query_to, 820)
    end

    def test_Hit_target_start
      assert_equal(@hit.target_start, 1)
#      assert_equal(@hit.hit_from, 1)
    end

    def test_Hit_target_end
      assert_equal(@hit.target_end,  820)
#      assert_equal(@hit.hit_to,  820)
    end

    def test_Hit_lap_at
      assert_equal(@hit.lap_at, [1, 820, 1, 820])
    end
  end

  class TestBlastReportHsp < Test::Unit::TestCase
    def setup
      data = Bio::TestBlastData.data
      report = Bio::Blast::Report.new(data)
      @hsp = report.hits.first.hsps.first
    end
    
    def test_Hsp_num
      assert_equal(@hsp.num, 1)
    end

    def test_Hsp_hit_score
      assert_equal(@hsp.bit_score, 1567.75)
    end

    def test_Hsp_score
      assert_equal(@hsp.score, 4058)
    end

    def test_Hsp_evalue
      assert_equal(@hsp.evalue, 0)
    end

    def test_Hsp_identity
      assert_equal(@hsp.identity, 820)
    end

    def test_Hsp_gaps
      assert(@hsp.gaps)
    end

    def test_Hsp_positive
      assert_equal(@hsp.positive, 820)
    end

    def test_Hsp_align_len
      assert_equal(@hsp.align_len, 820)
    end

    def test_Hsp_density
      assert(@hsp.density)
    end

    def test_Hsp_query_frame
      assert_equal(@hsp.query_frame, 1)
    end

    def test_Hsp_query_from
      assert_equal(@hsp.query_from, 1)
    end

    def test_Hsp_query_to
      assert_equal(@hsp.query_to, 820)
    end

    def test_Hsp_hit_frame
      assert_equal(@hsp.hit_frame, 1)
    end

    def test_Hsp_hit_from
      assert_equal(@hsp.hit_from, 1)
    end

    def test_Hsp_hit_to
      assert_equal(@hsp.hit_to, 820)
    end

    def test_Hsp_pattern_from
      @hsp.pattern_from
    end

    def test_Hsp_pattern_to
      @hsp.pattern_to 
    end

    def test_Hsp_qseq
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(@hsp.qseq, seq)
    end

    def test_Hsp_midline
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(@hsp.midline, seq)
    end

    def test_Hsp_hseq
      seq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDALPNISDAERIFAELLTGLAAAQPGFPLAQLKTFVDQEFAQIKHVLHGISLLGQCPDSINAALICRGEKMSIAIMAGVLEARGHNVTVIDPVEKLLAVGHYLESTVDIAESTRRIAASRIPADHMVLMAGFTAGNEKGELVVLGRNGSDYSAAVLAACLRADCCEIWTDVDGVYTCDPRQVPDARLLKSMSYQEAMELSYFGAKVLHPRTITPIAQFQIPCLIKNTGNPQAPGTLIGASRDEDELPVKGISNLNNMAMFSVSGPGMKGMVGMAARVFAAMSRARISVVLITQSSSEYSISFCVPQSDCVRAERAMQEEFYLELKEGLLEPLAVTERLAIISVVGDGMRTLRGISAKFFAALARANINIVAIAQGSSERSISVVVNNDDATTGVRVTHQMLFNTDQVIEVFVIGVGGVGGALLEQLKRQQSWLKNKHIDLRVCGVANSKALLTNVHGLNLENWQEELAQAKEPFNLGRLIRLVKEYHLLNPVIVDCTSSQAVADQYADFLREGFHVVTPNKKANTSSMDYYHQLRYAAEKSRRKFLYDTNVGAGLPVIENLQNLLNAGDELMKFSGILSGSLSYIFGKLDEGMSFSEATTLAREMGYTEPDPRDDLSGMDVARKLLILARETGRELELADIEIEPVLPAEFNAEGDVAAFMANLSQLDDLFAARVAKARDEGKVLRYVGNIDEDGVCRVKIAEVDGNDPLFKVKNGENALAFYSHYYQPLPLVLRGYGAGNDVTAAGVFADLLRTLSWKLGV'
      assert_equal(@hsp.hseq, seq)
    end

    def test_Hsp_percent_identity
      @hsp.percent_identity
    end

    def test_Hsp_mismatch_count
      @hsp.mismatch_count
    end

  end 

end # module Bio
