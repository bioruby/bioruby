#
# test/unit/bio/appl/meme/test_mast.rb - Unit test for Bio::Meme::Mast::Report
#
# Copyright::  Copyright (C) 2008 Adam Kraut <adamnkraut@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/meme/mast/report'

module Bio
module TestMastReportData
  
  TEST_DATA = Pathname.new(File.join(BioRubyTestDataPath, 'meme')).cleanpath.to_s
  
  def self.example_mast_output
    File.join TEST_DATA, 'mast.out'
  end
  
end
class TestMastReport < Test::Unit::TestCase
  
  TEST_DATA = TestMastReportData::TEST_DATA
  
  def setup
    @report = Meme::Mast::Report.new(File.read(TestMastReportData.example_mast_output))
  end
  
  def test_report_has_motifs
    obj = @report.motifs.first
    assert_kind_of(Meme::Motif, obj)
  end
  
  def test_parse_hit_list_with_bad_data
    data = "#heres\n2 bad data lines\n"
    assert_raises(RuntimeError) { Meme::Mast::Report.new(data) }
  end
  
end # TestMastReport
end # Bio
