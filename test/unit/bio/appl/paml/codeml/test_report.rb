#
# test/unit/bio/appl/paml/codeml/test_report.rb - Unit test for Bio::PAML::Codeml::Report
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 6, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/paml/codeml/report'

class TestCodemlReport < Test::Unit::TestCase

  bioruby_root  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 6)).cleanpath.to_s
  TEST_DATA = Pathname.new(File.join(bioruby_root, 'test', 'data', 'paml', 'codeml')).cleanpath.to_s

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

end
