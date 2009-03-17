#
# test/unit/bio/appl/meme/test_mast.rb - Unit test for Bio::Meme::Mast::Report
#
# Copyright::  Copyright (C) 2008 Adam Kraut <adamnkraut@gmail.com>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 6, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/meme/mast/report'

module Bio
module TestMastReportData
  
  bioruby_root  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 6)).cleanpath.to_s
  TEST_DATA = Pathname.new(File.join(bioruby_root, 'test', 'data', 'meme')).cleanpath.to_s
  
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