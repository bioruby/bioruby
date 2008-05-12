#
# test/unit/bio/appl/blast/test_xmlparser.rb - Unit test for Bio::Blast::Report
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_xmlparser.rb,v 1.8 2008/05/12 12:01:20 ngoto Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/blast'


module Bio::TestBlastXMLParser
  class TestBlastFormat7XMLParserData
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
    TestDataBlast = Pathname.new(File.join(bioruby_root, 'test', 'data', 'blast')).cleanpath.to_s

    def self.input
      File.open(File.join(TestDataBlast, 'b0002.faa')).read
    end

    def self.output
      File.open(File.join(TestDataBlast, 'b0002.faa.m7')).read 
#      File.open(File.join(TestDataBlast, '2.2.15.blastp.m7')).read 
    end
  end

    
  class TestBlastReport < Test::Unit::TestCase
    require 'bio/appl/blast/report'

    def setup
      @report = Bio::Blast::Report.new(TestBlastFormat7XMLParserData.output)
    end
    
    def test_iterations
      @report.iterations
    end

    def test_parameters
      @report.parameters
    end

    def test_program
      @report.program
    end

    def test_version
      @report.version
    end

    def test_reference
      @report.reference
    end

    def test_db
      assert_equal("b0002.faa", @report.db)
    end

    def test_query_id
      @report.query_id
    end

    def test_query_def
      @report.query_def
    end

    def test_query_len
      @report.query_len
    end

    def test_matrix
      @report.matrix
    end

    def test_expect
      @report.expect
    end

    def test_inclusion
      @report.inclusion
    end

    def test_sc_match
      @report.sc_match
    end

    def test_sc_mismatch
      @report.sc_mismatch
    end

    def test_gap_open
      @report.gap_open
    end

    def test_gap_extend
      @report.gap_extend
    end

    def test_filter
      @report.filter
    end

    def test_pattern
      @report.pattern
    end

    def test_extrez_query
      @report.entrez_query
    end

    def test_each_iteration
    end

    def test_each_hit
    end

    def test_hits
    end

    def test_statistics
    end

    def test_db_num
      @report.db_num
    end

    def test_db_len
      @report.db_len
    end

    def test_hsp_len
      @report.hsp_len
    end

    def test_eff_space
      @report.eff_space
    end

    def test_kappa
      @report.kappa
    end

    def test_lambda
      @report.lambda
    end

    def test_entropy
      @report.entropy
    end
    
    def test_message
      @report.message
    end
  end
  

  class TestBlastReportIteration < Test::Unit::TestCase
    def setup
      data = TestBlastFormat7XMLParserData.output
      report = Bio::Blast::Report.new(data)
      @itr = report.iterations.first
    end

    def test_hits
      @itr.hits
    end

    def test_statistics
      @itr.statistics
    end

    def test_num
      @itr.num
    end

    def test_message
      @itr.message
    end
  end


  class TestBlastReportHit < Test::Unit::TestCase
    def setup
      data = TestBlastFormat7XMLParserData.output
      report = Bio::Blast::Report.new(data)
      @hit = report.hits.first
    end

    def test_hsps
      @hit.hsps
    end

    def test_query_id
      @hit.query_id
    end

    def test_query_def
      @hit.query_def
    end

    def test_query_len
      @hit.query_len
    end

    def test_num
      @hit.num
    end

    def test_hit_id
      @hit.hit_id
    end

    def test_len
      @hit.len
    end

    def test_target_len
      @hit.target_len
    end

    def test_definition
      @hit.definition
    end

    def test_taeget_def
      @hit.target_def
    end

    def test_accession
      @hit.accession
    end

    def test_target_id
      @hit.target_id
    end
    
    def test_evalue
      @hit.evalue
    end

    def test_bit_score
      @hit.bit_score
    end

    def test_identity
      @hit.identity
    end

    def test_overlap
      @hit.overlap
    end

    def test_query_seq
      @hit.query_seq
    end

    def test_target_seq
      @hit.target_seq
    end

    def test_midline
      @hit.midline
    end

    def test_query_start
      @hit.query_start
    end

    def test_query_end
      @hit.query_end
    end

    def test_target_start
      @hit.target_start
    end

    def test_target_end
      @hit.target_end
    end

    def test_lap_at
      @hit.lap_at
    end
  end


  class TestBlastReportHsp < Test::Unit::TestCase
    def setup
      data = TestBlastFormat7XMLParserData.output
      report = Bio::Blast::Report.new(data)
      @hsp = report.hits.first.hsps.first
    end
    
    def test_num
      assert_equal(1, @hsp.num)
    end

    def test_hit_score
      @hsp.bit_score
    end

    def test_score
      @hsp.score
    end

    def test_evalue
      @hsp.evalue
    end

    def test_identity
      @hsp.identity
    end

    def test_gaps
      @hsp.gaps
    end

    def test_positive
      @hsp.positive
    end

    def test_align_len
      @hsp.align_len
    end

    def test_density
      @hsp.density
    end

    def test_query_frame
      @hsp.query_frame
    end

    def test_query_from
      @hsp.query_from
    end

    def test_query_to
      @hsp.query_to
    end

    def test_hit_frame
      @hsp.hit_frame
    end

    def test_hit_from
      @hsp.hit_from
    end

    def test_hit_to
      @hsp.hit_to
    end

    def test_pattern_from
      @hsp.pattern_from
    end

    def test_pattern_to
      @hsp.pattern_to 
    end

    def test_qseq
      @hsp.qseq
    end

    def test_midline
      @hsp.midline
    end

    def test_hseq
      @hsp.hseq
    end

    def test_percent_identity
      @hsp.percent_identity
    end

    def test_mismatch_count
      @hsp.mismatch_count
    end
  end
end
