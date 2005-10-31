#
# test/unit/bio/appl/sosui/test_report.rb - Unit test for Bio::SOSUI::Report
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
#  $Id: test_report.rb,v 1.2 2005/10/31 17:02:45 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/sosui/report'


module Bio

  bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
  test_data = Pathname.new(File.join(bioruby_root, 'test', 'data', 'SOSUI')).cleanpath.to_s
  SOSUIReport = File.open(File.join(test_data, 'sample.report')).read


  class TestSOSUIReportConst  < Test::Unit::TestCase

    def test_delimiter
      assert_equal(Bio::SOSUI::Report::DELIMITER, "\n>")
    end

    def test_rs
      assert_equal(Bio::SOSUI::Report::RS, "\n>")
    end

  end


  class TestSOSUIReport < Test::Unit::TestCase

    def setup
      @obj = Bio::SOSUI::Report.new(SOSUIReport)
    end

    def test_entry_id
      assert_equal(@obj.entry_id, 'Q9HC19')
    end

    def test_prediction
      assert_equal(@obj.prediction, 'MEMBRANE PROTEIN')
    end

    def test_tmhs
      assert_equal(@obj.tmhs.class, Array)
      assert_equal(@obj.tmhs[0].class, Bio::SOSUI::Report::TMH)
    end

    def test_tmh
      assert_equal(@obj.tmhs.size, 7)
    end

  end # class TestSOSUIReport

  class TestSOSUITMH < Test::Unit::TestCase
    def setup
      @obj = Bio::SOSUI::Report.new(SOSUIReport).tmhs.first
    end

    def test_range
      assert_equal(@obj.range, 31..53)
    end

    def test_grade
      assert_equal(@obj.grade, 'SECONDARY')
    end
    
    def test_sequence
      assert_equal(@obj.sequence, 'HIRMTFLRKVYSILSLQVLLTTV')
    end

  end # class TestSOSUITMH
end
