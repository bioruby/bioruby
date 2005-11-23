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
#  $Id: test_na.rb,v 1.4 2005/11/23 05:25:10 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/data/na'

module Bio

  class TestNAConstants  < Test::Unit::TestCase
    def test_NAMES
      assert_equal('a', Bio::NucleicAcid::NAMES['a'])
    end

    def test_NAMES_1_to_name
      assert_equal('adenine', Bio::NucleicAcid::NAMES['A'])
    end

    def test_WEIGHT
      mw = 135.15
      assert_equal(mw, Bio::NucleicAcid::WEIGHT['a'])
      assert_equal(mw, Bio::NucleicAcid::WEIGHT[:adenine])
    end
  end


  class TestNA < Test::Unit::TestCase
    def setup
      @obj = Bio::NucleicAcid.new
    end

    def test_to_re
      re = /[tc][ag][at][gc][tg][ac][tgc][atg][agc][atgc]atgc/
      assert_equal(re, @obj.to_re('yrwskmbdvnatgc'))
      assert_equal(re, Bio::NucleicAcid.to_re('yrwskmbdvnatgc'))
    end


    def test_weight
      mw = 135.15
      assert_equal(mw, @obj.weight('a'))
      assert_equal(mw, Bio::NucleicAcid.weight('a'))
    end

    def test_weight_rna
      mw = 135.15
      assert_equal(mw, @obj.weight('A', true))
      assert_equal(mw, Bio::NucleicAcid.weight('A', true))
    end

    
    def test_accessor
      assert_equal('adenine', @obj['A'])
    end
    
    def test_names
      assert_equal(Bio::NucleicAcid::NAMES, @obj.names)
    end
    def test_na
      assert_equal(Bio::NucleicAcid::NAMES, @obj.na)
    end

    def test_name
      assert_equal('adenine', @obj.name('A'))
    end
  end
end
