#
# test/unit/bio/data/test_aa.rb - Unit test for Bio::AminoAcid
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
#  $Id: test_aa.rb,v 1.3 2005/11/23 05:10:34 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/data/aa'

module Bio
  class TestAA < Test::Unit::TestCase

    def setup
      @obj = Bio::AminoAcid.new
    end

    def test_bio_aminoacid
      assert_equal('Ala', Bio::AminoAcid['A'])
    end

    def test_13
      assert_equal("Ala", @obj['A'])
    end

    def test_1n
      assert_equal('alanine', @obj.name('A'))
    end

    def test_to_1_name
      assert_equal('A', @obj.to_1('alanine'))
    end

    def test_to_1_3
      assert_equal('A', @obj.to_1('Ala'))
    end

    def test_to_1_1
      assert_equal('A', @obj.to_1('A'))
    end

    def test_to_3_name
      assert_equal('Ala', @obj.to_3('alanine'))
    end

    def test_to_3_3
      assert_equal('Ala', @obj.to_3('Ala'))
    end

    def test_to_3_1
      assert_equal('Ala', @obj.to_3('A'))
    end

    def test_one2three
      assert_equal('Ala', @obj.one2three('A'))
    end

    def test_three2one
      assert_equal('A', @obj.three2one('Ala'))
    end

    def test_one2name
      assert_equal('alanine', @obj.one2name('A'))
    end

    def test_name2one
      assert_equal('A', @obj.name2one('alanine'))
    end
    
    def test_three2name
      assert_equal('alanine', @obj.three2name('Ala'))
    end

    def test_name2three
      assert_equal('Ala', @obj.name2three('alanine'))
    end
    
    def test_to_re
      assert_equal(/[DN][EQ]ACDEFGHIKLMNPQRSTVWYU/, @obj.to_re('BZACDEFGHIKLMNPQRSTVWYU'))
    end
  end
end
