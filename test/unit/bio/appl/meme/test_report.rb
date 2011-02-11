#
# test/unit/bio/appl/meme/test_report.rb - Unit test for Bio::Meme::Report
#
# Copyright::  Copyright (C) 2008 Adam Kraut <adamnkraut@gmail.com>
# Copyright::  Copyright (C) 2011 Brandon Fulk <brandon.fulk@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/meme/report'

module Bio
module TestMemeReportData
  
  TEST_DATA = Pathname.new(File.join(BioRubyTestDataPath, 'meme')).cleanpath.to_s
  
  def self.example_meme_output
    File.join TEST_DATA, 'meme.out'
  end
  
end
class TestMemeReport < Test::Unit::TestCase
  
  TEST_DATA = TestMemeReportData::TEST_DATA
  
  def setup
    @report = Meme::Report.new(File.read(TestMemeReportData.example_meme_output))
  end
  
  def test_report_has_motifs
    obj = @report.motifs.first
    assert_kind_of(Meme::Motif, obj)
  end
  
  # need to refactor this to assert correct format
  def test_parse_motif_list_with_bad_data
    data = "#heres\n2 bad data lines\n"
    assert_raises(RuntimeError) { Meme::Report.new(data) }
  end

  def test_motif_has_valid_data
    motif = @report.motifs.first
    assert_equal(motif.motif_number, 1)
    assert_equal(motif.motif_width, 33)
  end

  def test_site_has_valid_data
    motif = @report.motifs.first
    motif.each_site do |site|
      puts site.site_name
    end
    site = motif.sites.first
    # shit, I think I have the parameter order switched!!!
    assert_equal('NP_523684', site.site_name)
    assert_equal(206, site.site_start)
    assert_equal(238, site.site_end)
    assert_equal(1.17e-39, site.site_pvalue)
  end
  

    
  
end # TestMastReport
end # Bio
