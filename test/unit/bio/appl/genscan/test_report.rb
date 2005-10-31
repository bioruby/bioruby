#
# test/unit/bio/appl/genscan/test_report.rb - Unit test for Bio::Genscan::Report
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
#  $Id: test_report.rb,v 1.1 2005/10/31 16:27:46 nakao Exp $
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
      assert_equal(@obj.genscan_version, '1.0')
    end

    def test_date_run
      assert_equal(@obj.date_run, '30-May-103')
    end

    def test_time
      assert_equal(@obj.time, "14:06:28")
    end

    def test_query_name
      assert_equal(@obj.query_name, 'HUMRASH')
    end

    def test_length
      assert_equal(@obj.length, 12942)
    end

    def test_gccontent
      assert_equal(@obj.gccontent, 68.17)
    end

    def test_isochore
      assert_equal(@obj.isochore, '4 (57 - 100 C+G%)')
    end

    def test_matrix
      assert_equal(@obj.matrix, 'HumanIso.smat')
    end

    def test_predictions_size
      assert_equal(@obj.predictions.size, 2)
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
      assert_equal(@obj.first.number, 1)
    end

    def test_aaseq
      assert_equal(@obj.first.aaseq.class, Bio::FastaFormat)
      seq =  "MTEYKLVVVGAGGVGKSALTIQLIQNHFVDEYDPTIEDSYRKQVVIDGETCLLDILDTAGQEEYSAMRDQYMRTGEGFLCVFAINNTKSFEDIHQYREQIKRVKDSDDVPMVLVGNKCDLAARTVESRQAQDLARSYGIPYIETSAKTRQGVEDAFYTLVREIRQHKLRKLNPPDESGPGCMSCKCVLS"
      assert_equal(@obj.first.aaseq.seq, seq)
      definition = "HUMRASH|GENSCAN_predicted_peptide_1|189_aa"
      assert_equal(@obj.first.aaseq.definition, definition)
    end

    def test_naseq
      assert_equal(@obj.first.naseq.class, Bio::FastaFormat)
      seq = "atgacggaatataagctggtggtggtgggcgccggcggtgtgggcaagagtgcgctgaccatccagctgatccagaaccattttgtggacgaatacgaccccactatagaggattcctaccggaagcaggtggtcattgatggggagacgtgcctgttggacatcctggataccgccggccaggaggagtacagcgccatgcgggaccagtacatgcgcaccggggagggcttcctgtgtgtgtttgccatcaacaacaccaagtcttttgaggacatccaccagtacagggagcagatcaaacgggtgaaggactcggatgacgtgcccatggtgctggtggggaacaagtgtgacctggctgcacgcactgtggaatctcggcaggctcaggacctcgcccgaagctacggcatcccctacatcgagacctcggccaagacccggcagggagtggaggatgccttctacacgttggtgcgtgagatccggcagcacaagctgcggaagctgaaccctcctgatgagagtggccccggctgcatgagctgcaagtgtgtgctctcctga"
      assert_equal(@obj.first.naseq.seq, seq)
      definition = "HUMRASH|GENSCAN_predicted_CDS_1|570_bp"
      assert_equal(@obj.first.naseq.definition, definition)
    end

    def test_promoter
      assert_equal(@obj.last.promoter.class, Bio::Genscan::Report::Exon)
      assert_equal(@obj.last.promoter.exon_type, "Prom")
    end

    def test_polyA
      assert_equal(@obj.first.polyA.class, Bio::Genscan::Report::Exon)
      assert_equal(@obj.first.polyA.exon_type, 'PlyA')
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
      assert_equal(@obj.number, 1)
    end

    def test_exon_type
      assert_equal(@obj.exon_type, 'Init')
    end

    def test_exon_type_long
      assert_equal(@obj.exon_type_long, 'Initial exon')
    end

    def test_strand
      assert_equal(@obj.strand, '+')
    end

    def test_first
      assert_equal(@obj.first, 1664)
    end

    def test_last
      assert_equal(@obj.last, 1774)
    end

    def test_range
      assert_equal(@obj.range, 1664..1774)
    end

    def test_phase
      assert_equal(@obj.phase, '0')
    end

    def test_acceptor_score
      assert_equal(@obj.acceptor_score, 94)
    end

    def test_donor_score
      assert_equal(@obj.donor_score, 83)
    end

    def test_initiation_score
      assert_equal(@obj.initiation_score, 94)
    end

    def test_termination_score
      assert_equal(@obj.termination_score, 83)
    end

    def test_score
      assert_equal(@obj.score, 212)
    end

    def test_p_value
      assert_equal(@obj.p_value, 0.997)
    end

    def test_t_score
      assert_equal(@obj.t_score, 21.33)
    end

  end # TestGenscanReportExon

end
