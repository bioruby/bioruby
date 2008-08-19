#
# test/unit/bio/appl/paml/codeml/test_rates.rb - Unit test for Bio::PAML::Codeml::Rates
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 6, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/paml/codeml/rates'

class TestCodemlRates < Test::Unit::TestCase

  bioruby_root  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 6)).cleanpath.to_s
  TEST_DATA = Pathname.new(File.join(bioruby_root, 'test', 'data', 'paml', 'codeml')).cleanpath.to_s

  def setup
    str = File.read(File.join(TEST_DATA, 'rates'))
    @example_rates = Bio::PAML::Codeml::Rates.new(str)
  end

  def test_rates_first_position
    assert_equal('***M', @example_rates.first[:data])
    assert_equal(1, @example_rates.first[:rate])
    assert_equal(1, @example_rates.first[:freq])
  end

  def test_rates_hundred_and_fiftieth_position
    assert('GGGG', @example_rates[149][:data])
    assert(0.828, @example_rates[149][:rate])
    assert(9, @example_rates[149][:freq])
  end
  
  def test_rates_last_position
    assert('PHPP', @example_rates.last[:data])
    assert(1.752, @example_rates.last[:rate])
    assert(1, @example_rates.last[:freq])
  end
end
