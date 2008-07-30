require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/codeml/rates'

BIORUBY_ROOT  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
TEST_DATA = Pathname.new(File.join(BIORUBY_ROOT, 'test', 'data', 'codeml')).cleanpath.to_s

class TestCodemlReport < Test::Unit::TestCase

  EXAMPLE_RATES = Bio::CodeML::Rates.new(File.open(TEST_DATA + '/rates').read)

  def test_rates_first_position
    assert_equal(EXAMPLE_RATES[1][:data],'VVVVV')
    assert_equal(EXAMPLE_RATES[1][:rate],0.462)
    assert_equal(EXAMPLE_RATES[1][:freq],16)
  end

  def test_rates_hundred_and_fiftieth_position
    assert(EXAMPLE_RATES[150][:data],'VVVVI')
    assert(EXAMPLE_RATES[150][:rate],1.406)
    assert(EXAMPLE_RATES[150][:freq],1)
  end
  
end
