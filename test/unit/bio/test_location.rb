#
# test/bio/test_location.rb - Unit test for Bio::Location
#
#   Copyright (C) 2004 Moses Hohman <mmhohman@northwestern.edu>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: test_location.rb,v 1.1 2004/11/12 02:27:08 k Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), [".."]*2, "lib")).cleanpath.to_s
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
