#
# test/unit/bio/test_extend.rb - Unit test for add-on methods
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
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
#  $Id: test_extend.rb,v 1.1 2005/10/27 15:13:04 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/extend'

module Bio
  class TestString < Test::Unit::TestCase
    
    def test_to_naseq
      assert_equal(String.new("ACGT").to_naseq, Bio::Sequence::NA.new("ACGT"))
    end

    def test_toaaseq
      assert_equal(String.new("ACGT").to_aaseq, Bio::Sequence::AA.new("ACGT"))
    end

    def test_fold
    end

    def test_fill
    end
  end

  class TestArray < Test::Unit::TestCase
    def test_inject
    end

    def test_sum
    end
    
    def test_product
    end
  end
end
