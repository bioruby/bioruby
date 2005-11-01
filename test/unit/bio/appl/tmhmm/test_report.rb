#
# test/unit/bio/appl/tmhmm/test_report.rb - Unit test for Bio::TMHMM::Report
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
#  $Id: test_report.rb,v 1.1 2005/11/01 05:13:57 nakao Exp $
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
      assert_equal(@obj.entry_id, 'O42385')
    end

    def test_query_len
      assert_equal(@obj.query_len, 423)
    end

    def test_predicted_tmhs
      assert_equal(@obj.predicted_tmhs, 7)
    end

    def test_tmhs
      assert_equal(@obj.tmhs.class, Array)
      assert_equal(@obj.tmhs.size, 15)
    end

    def test_exp_aas_in_tmhs
      assert_equal(@obj.exp_aas_in_tmhs, 157.40784)
    end

    def test_exp_first_60aa
      assert_equal(@obj.exp_first_60aa, 13.85627)
    end

    def test_total_prob_of_N_in
      assert_equal(@obj.total_prob_of_N_in, 0.00993)
    end

    def test_helix
      assert_equal(@obj.helix.size, 7)
      assert_equal(@obj.helix[0].class, Bio::TMHMM::TMH)
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
      assert_equal(@obj.to_s, str)
    end

  end # TestTMHMMReport

  class TestTMHMMTMH < Test::Unit::TestCase

    def setup
      @obj = Bio::TMHMM::Report.new(TMHMMReport).tmhs.first
    end

    def test_entry_id
      assert_equal(@obj.entry_id, 'O42385')
    end

    def test_version
      assert_equal(@obj.version, 'TMHMM2.0')
    end

    def test_status
      assert_equal(@obj.status, 'outside')
    end

    def test_range
      assert_equal(@obj.range, 1..46)
    end

    def test_pos
      assert_equal(@obj.pos, 1..46)
    end

  end # class TestTMHMMTMH


end
