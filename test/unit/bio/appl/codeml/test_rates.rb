#
# test/unit/bio/appl/codeml/test_rates.rb - Unit test for Bio::CodeML::Rates
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/codeml/rates'

class TestCodemlRates < Test::Unit::TestCase

  bioruby_root  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
  TEST_DATA = Pathname.new(File.join(bioruby_root, 'test', 'data', 'codeml')).cleanpath.to_s

  EXAMPLE_RATES = Bio::CodeML::Rates.new(File.open(TEST_DATA + '/rates').read)

  def test_rates_first_position
    assert_equal(EXAMPLE_RATES.first[:data],'VVVVV')
    assert_equal(EXAMPLE_RATES.first[:rate],0.462)
    assert_equal(EXAMPLE_RATES.first[:freq],16)
  end

  def test_rates_hundred_and_fiftieth_position
    assert(EXAMPLE_RATES[149][:data],'VVVVI')
    assert(EXAMPLE_RATES[149][:rate],1.406)
    assert(EXAMPLE_RATES[149][:freq],1)
  end
  
end
