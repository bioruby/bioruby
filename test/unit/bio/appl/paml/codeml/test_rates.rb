#
# test/unit/bio/appl/paml/codeml/test_rates.rb - Unit test for Bio::PAML::Codeml::Rates
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
require 'bio/appl/paml/codeml/rates'

module Bio; module TestPAMLCodeml
class TestCodemlRates < Test::Unit::TestCase

  TEST_DATA = Pathname.new(File.join(BioRubyTestDataPath, 'paml', 'codeml')).cleanpath.to_s

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
    assert_equal('GGGG', @example_rates[150][:data])
    assert_equal(0.828, @example_rates[150][:rate])
    assert_equal(8, @example_rates[150][:freq])
  end
  
  def test_rates_last_position
    assert_equal('PHPP', @example_rates.last[:data])
    assert_equal(1.752, @example_rates.last[:rate])
    assert_equal(1, @example_rates.last[:freq])
  end
end

end; end #module TestPAMLCodeml; module Bio
