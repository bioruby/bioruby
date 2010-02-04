#
# test/unit/bio/appl/paml/codeml/test_report_single.rb - Unit test for Bio::PAML::Codeml::Report
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/paml/codeml/report'

module Bio; module TestPAMLCodeml
class TestCodemlReport < Test::Unit::TestCase

  TEST_DATA = Pathname.new(File.join(BioRubyTestDataPath, 'paml', 'codeml')).cleanpath.to_s

  def setup
    str = File.read(File.join(TEST_DATA, 'output.txt'))
    @example_report = Bio::PAML::Codeml::Report.new(str)
  end

  def test_tree_log_likelihood
    assert_equal(-1817.465211, @example_report.tree_log_likelihood)
  end

  def test_tree_length
    assert_equal(0.77902, @example_report.tree_length)
  end

  def test_alpha
    assert_equal(0.58871, @example_report.alpha)
  end

  def test_tree
    tree = "(((rabbit: 0.082889, rat: 0.187866): 0.038008, human: 0.055050): 0.033639, goat-cow: 0.096992, marsupial: 0.284574);"
    assert_equal(tree, @example_report.tree)
  end

end

end; end #module TestPAMLCodeml; module Bio
