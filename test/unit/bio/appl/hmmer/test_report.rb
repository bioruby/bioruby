#
# test/unit/bio/appl/hmmer/test_report.rb - Unit test for Bio::HMMER::Report
#
# Copyright::  Copyright (C) 2006 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_report.rb,v 1.3 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/hmmer/report'


module Bio

  class TestHMMERReportData
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
    TestDataHMMER = Pathname.new(File.join(bioruby_root, 'test', 'data', 'HMMER')).cleanpath.to_s

    def self.hmmpfam
      File.open(File.join(TestDataHMMER, 'hmmpfam.out')).read 
    end

    def self.output
      self.hmmpfam
    end

    def self.hmmsearch
      File.open(File.join(TestDataHMMER, 'hmmsearch.out')).read 
    end
  end


  class TestHMMERReportClassMethods < Test::Unit::TestCase
    def test_reports_ary
      ary = Bio::HMMER.reports(Bio::TestHMMERReportData.output)
      assert_equal(Array, ary.class)
    end

    def test_reports_ary
      Bio::HMMER.reports(Bio::TestHMMERReportData.output).each do |report|
        assert_equal(Bio::HMMER::Report, report.class)
      end
    end
  end

  
  class TestHMMERReportConstants < Test::Unit::TestCase
    def test_rs
      assert_equal("\n//\n", Bio::HMMER::Report::RS)
      assert_equal("\n//\n", Bio::HMMER::Report::DELIMITER)
    end
  end

    
  class TestHMMERReportHmmpfam < Test::Unit::TestCase
    def setup
      @obj = Bio::HMMER::Report.new(Bio::TestHMMERReportData.hmmpfam)
    end
    
    def test_program
      assert_equal(Hash, @obj.program.class)
      assert_equal("hmmpfam - search one or more sequences against HMM database", @obj.program['name'])
      assert_equal("HMMER 2.3.2 (Oct 2003)", @obj.program['version'])
      assert_equal("Copyright (C) 1992-2003 HHMI/Washington University School of Medicine", @obj.program['copyright'])
      assert_equal("Freely distributed under the GNU General Public License (GPL)", @obj.program['license'])
    end

    def test_parameter
      assert_equal(Hash, @obj.parameter.class)
      assert_equal("/Users/nakao/Sites/iprscan/tmp/20050517/iprscan-20050517-16244071/chunk_1/iprscan-20050517-16244071.nocrc", @obj.parameter["Sequence file"])
      assert_equal("/Users/nakao/Sites/iprscan/data/Pfam", @obj.parameter['HMM file'])
    end

    def test_query_info
      assert_equal(Hash, @obj.query_info.class)
      assert_equal("104K_THEPA", @obj.query_info["Query sequence"])
      assert_equal("[none]", @obj.query_info["Accession"])
      assert_equal("[none]", @obj.query_info["Description"])
    end

    def test_hits
      assert_equal(Bio::HMMER::Report::Hit, @obj.hits.first.class)
    end

    def test_hsps
      assert_equal(Bio::HMMER::Report::Hsp, @obj.hsps.first.class)
    end

    def test_histogram
      assert_equal(nil, @obj.histogram)
    end

    def test_statistical_detail
      assert_equal(nil, @obj.statistical_detail)
    end

    def test_total_seq_searched
      assert_equal(nil, @obj.total_seq_searched)
    end

    def test_whole_seq_top_hits
      assert_equal(nil, @obj.whole_seq_top_hits)
    end

    def test_domain_top_hits
      assert_equal(nil, @obj.domain_top_hits)
    end

    def test_each
      @obj.each do |hit|
        assert_equal(Bio::HMMER::Report::Hit, hit.class)
      end
    end

    def test_each_hit
      @obj.each_hit do |hit|
        assert_equal(Bio::HMMER::Report::Hit, hit.class)
      end
    end
  end 


  class TestHMMERReportHit < Test::Unit::TestCase
    def setup
      @obj = Bio::HMMER::Report.new(Bio::TestHMMERReportData.output).hits.first
    end

    def test_hit
      assert_equal(Bio::HMMER::Report::Hit, @obj.class)
    end

    def test_hsps
      assert_equal(Bio::HMMER::Report::Hsp, @obj.hsps.first.class)
    end

    def test_accession
      assert_equal("PF04385.4", @obj.accession)
    end
    def test_target_id
      assert_equal("PF04385.4", @obj.target_id)
    end
    def test_hit_id
      assert_equal("PF04385.4", @obj.hit_id)
    end
    def test_entry_id
      assert_equal("PF04385.4", @obj.entry_id)
    end

    def test_description
      assert_equal("Domain of unknown function, DUF529", @obj.description)
    end
    def test_definition
      assert_equal("Domain of unknown function, DUF529", @obj.definition)
    end

    def test_score
      assert_equal(259.3, @obj.score)
    end
    def test_bit_score
      assert_equal(259.3, @obj.bit_score)
    end

    def test_evalue
      assert_equal(6.6e-75, @obj.evalue)
    end

    def test_num
      assert_equal(4, @obj.num)
    end
    
    def test_each
      @obj.each do |hsp|
        assert_equal(Bio::HMMER::Report::Hsp, hsp.class)
      end
    end

    def test_each_hsp
      @obj.each_hsp do |hsp|
        assert_equal(Bio::HMMER::Report::Hsp, hsp.class)
      end
    end

    def test_target_def
      assert_equal("<4> Domain of unknown function, DUF529", @obj.target_def)
    end

    def test_append_hsp
      hsp = @obj.hsps.first
      assert_equal(5, @obj.append_hsp(hsp).size)
    end
  end

  class TestHMMERReportHsp < Test::Unit::TestCase

    def setup
      @obj = Bio::HMMER::Report.new(Bio::TestHMMERReportData.output).hits.first.hsps.first
    end

    def test_hsp
      assert_equal(Bio::HMMER::Report::Hsp, @obj.class)
    end
    
    def test_accession
      assert_equal("PF04385.4", @obj.accession)
    end

    def test_domain
      assert_equal("1/4", @obj.domain)
    end

    def test_seq_f
      assert_equal(36, @obj.seq_f)
    end

    def test_seq_t
      assert_equal(111, @obj.seq_t)
    end

    def test_seq_ft
      assert_equal("..", @obj.seq_ft)
    end

    def test_hmm_f
      assert_equal(1, @obj.hmm_f)
    end

    def test_hmm_t
      assert_equal(80, @obj.hmm_t)
    end

    def test_score
      assert_equal(65.0, @obj.score)
    end
    def test_bit_score
      assert_equal(65.0, @obj.bit_score)
    end

    def test_evalue
      assert_equal(2.0e-16, @obj.evalue)
    end

    def test_midline
      assert_equal("t+D+n++++    f  +v+++g+++ + ++ ++v+++++++Gn+v+We++   + +l++ ++++++++++++++++ +++", @obj.midline)
    end

    def test_hmmseq
      assert_equal("tLDlndtgstlkqfdykvalngdivvtytpkpGvkftkitdGnevvWeseddpefglivtlsfyldsnkfLvlllintak", @obj.hmmseq)
    end

    def test_flatseq
      assert_equal("TFDINSNQTG-PAFLTAVEMAGVKYLQVQHGSNVNIHRLVEGNVVIWENA---STPLYTGAIVTNNDGPYMAYVEVLGDP", @obj.flatseq)
    end

    def test_query_frame
      assert_equal(1, @obj.query_frame)
    end

    def test_target_frame
      assert_equal(1, @obj.target_frame)
    end

    def test_csline
      assert_equal(nil, @obj.csline)
    end

    def test_rfline
      assert_equal(nil, @obj.rfline)
    end

    def test_set_alignment
    end

    def test_query_seq
      assert_equal("TFDINSNQTG-PAFLTAVEMAGVKYLQVQHGSNVNIHRLVEGNVVIWENA---STPLYTGAIVTNNDGPYMAYVEVLGDP", @obj.query_seq)
    end

    def test_target_seq
      assert_equal("tLDlndtgstlkqfdykvalngdivvtytpkpGvkftkitdGnevvWeseddpefglivtlsfyldsnkfLvlllintak", @obj.target_seq)
    end

    def test_target_from
      assert_equal(1, @obj.target_from)
    end

    def test_targat_to
      assert_equal(80, @obj.target_to)
    end

    def test_query_from
      assert_equal(36, @obj.query_from)
    end

    def test_query_to
      assert_equal(111, @obj.query_to)
    end
  end

  class TestHMMERReportHmmsearch < Test::Unit::TestCase
    def setup
      @obj = Bio::HMMER::Report.new(Bio::TestHMMERReportData.hmmsearch)
    end

    def test_histogram
      hist = "score    obs    exp  (one = represents 1 sequences)\n-----    ---    ---\n  377      1      0|="
      assert_equal(hist, @obj.histogram)
    end
    
    def test_statistical_detail
      hash = {"P(chi-square)" => 0.0, "chi-sq statistic" => 0.0, "lambda" => 0.7676, "mu" => -10.6639}
      assert_equal(hash, @obj.statistical_detail)
      hash.keys.each do |key|
        assert_equal(hash[key], @obj.statistical_detail[key])
      end
    end
    
    def test_total_seq_searched
      assert_equal(1, @obj.total_seq_searched)
    end

    def test_whole_seq_top_hit
      hash = {"Total memory" => "16K", "Satisfying E cutoff" => 1, "Total hits" => 1}
      assert_equal(hash, @obj.whole_seq_top_hits)
      hash.keys.each do |key|
        assert_equal(hash[key], @obj.whole_seq_top_hits[key])
      end
    end

    def test_domain_top_hits
      hash = {"Total memory" => "17K", "Satisfying E cutoff" => 1, "Total hits" => 1}
      assert_equal(hash, @obj.domain_top_hits)
      hash.keys.each do |key|
        assert_equal(hash[key], @obj.domain_top_hits[key])
      end
    end
  end

end # module Bio
