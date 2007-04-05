#
# test/unit/bio/appl/sosui/test_report.rb - Unit test for Bio::SOSUI::Report
#
# Copyright::   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id: test_report.rb,v 1.5 2007/04/05 23:35:43 trevor Exp $
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
      assert_equal("\n>", Bio::SOSUI::Report::DELIMITER)
    end

    def test_rs
      assert_equal("\n>", Bio::SOSUI::Report::RS)
    end

  end


  class TestSOSUIReport < Test::Unit::TestCase

    def setup
      @obj = Bio::SOSUI::Report.new(SOSUIReport)
    end

    def test_entry_id
      assert_equal('Q9HC19', @obj.entry_id)
    end

    def test_prediction
      assert_equal('MEMBRANE PROTEIN', @obj.prediction)
    end

    def test_tmhs
      assert_equal(Array, @obj.tmhs.class)
      assert_equal(Bio::SOSUI::Report::TMH, @obj.tmhs[0].class)
    end

    def test_tmh
      assert_equal(7, @obj.tmhs.size)
    end

  end # class TestSOSUIReport

  class TestSOSUITMH < Test::Unit::TestCase
    def setup
      @obj = Bio::SOSUI::Report.new(SOSUIReport).tmhs.first
    end

    def test_range
      assert_equal(31..53, @obj.range)
    end

    def test_grade
      assert_equal('SECONDARY', @obj.grade)
    end
    
    def test_sequence
      assert_equal('HIRMTFLRKVYSILSLQVLLTTV', @obj.sequence)
    end

  end # class TestSOSUITMH
end
