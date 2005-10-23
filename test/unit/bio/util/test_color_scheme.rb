#
# test/unit/bio/util/test_color_scheme.rb - Unit test for Bio::ColorScheme
#
#   Copyright (C) 2005 Trevor Wennblom <trevor@corevx.com>
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
#  $Id: test_color_scheme.rb,v 1.1 2005/10/23 08:40:41 k Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4 , 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/color_scheme'

module Bio
  class TestColorScheme < Test::Unit::TestCase

    def test_buried
      s = Bio::ColorScheme::Buried
      assert_equal('00DC22', s['A'])
      assert_equal('00BF3F', s[:c])
      assert_equal(nil, s[nil])
      assert_equal('FFFFFF', s['-'])
      assert_equal('FFFFFF', s[7])
      assert_equal('FFFFFF', s['junk'])
      assert_equal('00CC32', s['t'])
    end

  end
end
