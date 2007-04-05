#
# test/unit/bio/test_location.rb - Unit test for Bio::Location
#
# Copyright::  Copyright (C) 2004 
#              Moses Hohman <mmhohman@northwestern.edu>
# License::    The Ruby License
#
#  $Id: test_location.rb,v 1.4 2007/04/05 23:35:42 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 2, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/location'

module Bio
  class TestLocation < Test::Unit::TestCase
    def test_hat
      loc = Locations.new('754^755')
      assert_equal([754, 755], loc.span, "span wrong")
      assert_equal(754..755, loc.range, "range wrong")
      assert_equal(1, loc[0].strand, "strand wrong")
    end

    def test_complement
      loc = Locations.new('complement(53^54)')
      assert_equal([53, 54], loc.span, "span wrong")
      assert_equal(53..54, loc.range, "range wrong")
      assert_equal(-1, loc[0].strand, "strand wrong")
    end

    def test_replace_single_base
      loc = Locations.new('replace(4792^4793,"a")')
      assert_equal("a", loc[0].sequence)
    end
  end
end
