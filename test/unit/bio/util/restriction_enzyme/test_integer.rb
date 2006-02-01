require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme/integer'

module Bio

class TestCutLocationsInEnzymeNotation < Test::Unit::TestCase

  def test_negative?
    assert_equal(false, 1.negative?)
    assert_equal(false, 0.negative?)
    assert_equal(true, -1.negative?)
  end

end

end
