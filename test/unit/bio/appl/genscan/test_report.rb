#
# test/unit/bio/appl/genscan/test_report.rb - Unit test for Bio::Genscan::Report
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_report.rb,v 1.4 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/genscan/report'


module Bio

  class TestGenscanReport < Test::Unit::TestCase

    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      test_data = Pathname.new(File.join(bioruby_root, 'test', 'data', 'genscan')).cleanpath.to_s
      report = File.open(File.join(test_data, 'sample.report')).read

      @obj = Bio::Genscan::Report.new(report)
    end

    def test_genscan_version
      assert_equal('1.0', @obj.genscan_version)
    end

    def test_date_run
      assert_equal('30-May-103', @obj.date_run)
    end

    def test_time
      assert_equal("14:06:28", @obj.time)
    end

    def test_query_name
      assert_equal('HUMRASH', @obj.query_name)
    end

    def test_length
      assert_equal(12942, @obj.length)
    end

    def test_gccontent
      assert_equal(68.17, @obj.gccontent)
    end

    def test_isochore
      assert_equal('4 (57 - 100 C+G%)', @obj.isochore)
    end

    def test_matrix
      assert_equal('HumanIso.smat', @obj.matrix)
    end

    def test_predictions_size
      assert_equal(2, @obj.predictions.size)
    end

  end # TestGenscanReport


  class TestGenscanReportGene < Test::Unit::TestCase

    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      test_data = Pathname.new(File.join(bioruby_root, 'test', 'data', 'genscan')).cleanpath.to_s
      report = File.open(File.join(test_data, 'sample.report')).read
      @obj = Bio::Genscan::Report.new(report).predictions
    end

    def test_number
      assert_equal(1, @obj.first.number)
    end

    def test_aaseq
      assert_equal(Bio::FastaFormat, @obj.first.aaseq.class)
      seq =  "MTEYKLVVVGAGGVGKSALTIQLIQNHFVDEYDPTIEDSYRKQVVIDGETCLLDILDTAGQEEYSAMRDQYMRTGEGFLCVFAINNTKSFEDIHQYREQIKRVKDSDDVPMVLVGNKCDLAARTVESRQAQDLARSYGIPYIETSAKTRQGVEDAFYTLVREIRQHKLRKLNPPDESGPGCMSCKCVLS"
      assert_equal(seq, @obj.first.aaseq.seq)
      definition = "HUMRASH|GENSCAN_predicted_peptide_1|189_aa"
      assert_equal(definition, @obj.first.aaseq.definition)
    end

    def test_naseq
      assert_equal(Bio::FastaFormat, @obj.first.naseq.class)
      seq = "atgacggaatataagctggtggtggtgggcgccggcggtgtgggcaagagtgcgctgaccatccagctgatccagaaccattttgtggacgaatacgaccccactatagaggattcctaccggaagcaggtggtcattgatggggagacgtgcctgttggacatcctggataccgccggccaggaggagtacagcgccatgcgggaccagtacatgcgcaccggggagggcttcctgtgtgtgtttgccatcaacaacaccaagtcttttgaggacatccaccagtacagggagcagatcaaacgggtgaaggactcggatgacgtgcccatggtgctggtggggaacaagtgtgacctggctgcacgcactgtggaatctcggcaggctcaggacctcgcccgaagctacggcatcccctacatcgagacctcggccaagacccggcagggagtggaggatgccttctacacgttggtgcgtgagatccggcagcacaagctgcggaagctgaaccctcctgatgagagtggccccggctgcatgagctgcaagtgtgtgctctcctga"
      assert_equal(seq, @obj.first.naseq.seq)
      definition = "HUMRASH|GENSCAN_predicted_CDS_1|570_bp"
      assert_equal(definition, @obj.first.naseq.definition)
    end

    def test_promoter
      assert_equal(Bio::Genscan::Report::Exon, @obj.last.promoter.class)
      assert_equal("Prom", @obj.last.promoter.exon_type)
    end

    def test_polyA
      assert_equal(Bio::Genscan::Report::Exon, @obj.first.polyA.class)
      assert_equal('PlyA', @obj.first.polyA.exon_type)
    end

  end # TestGenscanReportGene


  class TestGenscanReportExon < Test::Unit::TestCase

    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      test_data = Pathname.new(File.join(bioruby_root, 'test', 'data', 'genscan')).cleanpath.to_s
      report = File.open(File.join(test_data, 'sample.report')).read
      @obj = Bio::Genscan::Report.new(report).predictions.first.exons.first
    end

    def test_number
      assert_equal(1, @obj.number)
    end

    def test_exon_type
      assert_equal('Init', @obj.exon_type)
    end

    def test_exon_type_long
      assert_equal('Initial exon',  @obj.exon_type_long)
    end

    def test_strand
      assert_equal('+', @obj.strand)
    end

    def test_first
      assert_equal(1664, @obj.first)
    end

    def test_last
      assert_equal(1774, @obj.last)
    end

    def test_range
      assert_equal(1664..1774, @obj.range)
    end

    def test_phase
      assert_equal('0', @obj.phase)
    end

    def test_acceptor_score
      assert_equal(94, @obj.acceptor_score)
    end

    def test_donor_score
      assert_equal(83, @obj.donor_score)
    end

    def test_initiation_score
      assert_equal(94, @obj.initiation_score)
    end

    def test_termination_score
      assert_equal(83, @obj.termination_score)
    end

    def test_score
      assert_equal(212, @obj.score)
    end

    def test_p_value
      assert_equal(0.997, @obj.p_value)
    end

    def test_t_score
      assert_equal(21.33, @obj.t_score)
    end

  end # TestGenscanReportExon

end
