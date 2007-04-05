#
# test/unit/bio/appl/tmhmm/test_report.rb - Unit test for Bio::TMHMM::Report
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
require 'bio/appl/tmhmm/report'


module Bio

  bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
  test_data = Pathname.new(File.join(bioruby_root, 'test', 'data', 'TMHMM')).cleanpath.to_s
  TMHMMReport = File.open(File.join(test_data, 'sample.report')).read


  class TestTMHMMReport_reports < Test::Unit::TestCase
    def test_reports
      assert(Bio::TMHMM.reports(""))
    end
  end

  class TestTMHMMReport < Test::Unit::TestCase

    def setup
      @obj = Bio::TMHMM::Report.new(TMHMMReport)
    end

    def test_entry_id
      assert_equal('O42385', @obj.entry_id)
    end

    def test_query_len
      assert_equal(423, @obj.query_len)
    end

    def test_predicted_tmhs
      assert_equal(7, @obj.predicted_tmhs)
    end

    def test_tmhs
      assert_equal(Array, @obj.tmhs.class)
      assert_equal(15, @obj.tmhs.size)
    end

    def test_exp_aas_in_tmhs
      assert_equal(157.40784, @obj.exp_aas_in_tmhs)
    end

    def test_exp_first_60aa
      assert_equal(13.85627, @obj.exp_first_60aa)
    end

    def test_total_prob_of_N_in
      assert_equal(0.00993, @obj.total_prob_of_N_in)
    end

    def test_helix
      assert_equal(7, @obj.helix.size)
      assert_equal(Bio::TMHMM::TMH, @obj.helix[0].class)
    end
    
    def test_to_s
      str = ["# O42385\tLength:\t423",
             "# O42385\tNumber of predicted TMHs:\t7",
             "# O42385\tExp number of AAs in THMs:\t157.40784",
             "# O42385\tExp number, first 60 AAs:\t13.85627",
             "# O42385\tTotal prob of N-in:\t0.00993",
             "O42385\tTMHMM2.0\toutside\t1\t46",
             "O42385\tTMHMM2.0\tTMhelix\t47\t69",
             "O42385\tTMHMM2.0\tinside\t70\t81",
             "O42385\tTMHMM2.0\tTMhelix\t82\t104",
             "O42385\tTMHMM2.0\toutside\t105\t118",
             "O42385\tTMHMM2.0\tTMhelix\t119\t141",
             "O42385\tTMHMM2.0\tinside\t142\t161",
             "O42385\tTMHMM2.0\tTMhelix\t162\t184",
             "O42385\tTMHMM2.0\toutside\t185\t205",
             "O42385\tTMHMM2.0\tTMhelix\t206\t228",
             "O42385\tTMHMM2.0\tinside\t229\t348",
             "O42385\tTMHMM2.0\tTMhelix\t349\t371",
             "O42385\tTMHMM2.0\toutside\t372\t380",
             "O42385\tTMHMM2.0\tTMhelix\t381\t403",
             "O42385\tTMHMM2.0\tinside\t404\t423"].join("\n")
      assert_equal(str, @obj.to_s)
    end

  end # TestTMHMMReport

  class TestTMHMMTMH < Test::Unit::TestCase

    def setup
      @obj = Bio::TMHMM::Report.new(TMHMMReport).tmhs.first
    end

    def test_entry_id
      assert_equal('O42385', @obj.entry_id)
    end

    def test_version
      assert_equal('TMHMM2.0', @obj.version)
    end

    def test_status
      assert_equal('outside', @obj.status)
    end

    def test_range
      assert_equal(1..46, @obj.range)
    end

    def test_pos
      assert_equal(1..46, @obj.pos)
    end

  end # class TestTMHMMTMH


end
