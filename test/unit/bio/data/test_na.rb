#
# test/unit/bio/data/test_na.rb - Unit test for Bio::NucleicAcid
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
#  $Id: test_na.rb,v 1.2 2005/09/24 03:12:56 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/data/na'

module Bio
  class TestNA < Test::Unit::TestCase

    def setup
      @obj = Bio::NucleicAcid.new
    end

    def test_to_re
      re = /[tc][ag][at][gc][tg][ac][tgc][atg][agc][atgc]atgc/
      assert_equal(@obj.to_re('yrwskmbdvnatgc'), re)
      assert_equal(Bio::NucleicAcid.to_re('yrwskmbdvnatgc'), re)
    end

    def test_Names
      assert_equal(Bio::NucleicAcid::Names['a'], 'a')
    end
    def test_Names_1_to_name
      assert_equal(Bio::NucleicAcid::Names['A'], 'adenine')
    end

    def test_Weight
      mw = 135.15
      assert_equal(Bio::NucleicAcid::Weight['a'], mw)
      assert_equal(Bio::NucleicAcid::Weight[:adenine], mw)
    end

    def test_weight
      mw = 135.15
      assert_equal(@obj.weight('a'), mw)
      assert_equal(Bio::NucleicAcid.weight('a'), mw)
    end

    def test_weight_rna
      mw = 135.15
      assert_equal(@obj.weight('A', true), mw)
      assert_equal(Bio::NucleicAcid.weight('A', true), mw)
    end

    
    def test_accessor
      assert_equal(@obj['A'], 'adenine')
    end
    
    def test_names
      assert_equal(@obj.names, Bio::NucleicAcid::Names)
    end
    def test_na
      assert_equal(@obj.na, Bio::NucleicAcid::Names)
    end

    def test_name
      assert_equal(@obj.name('A'), 'adenine')
    end
  end
end
