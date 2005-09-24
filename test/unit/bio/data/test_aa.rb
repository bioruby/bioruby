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
#  $Id: test_aa.rb,v 1.1 2005/09/24 02:22:13 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), [".."] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/data/aa'

module Bio
  class TestAA < Test::Unit::TestCase

    def setup
      @obj = Bio::AminoAcid.new
    end

    def test_bio_aminoacid
      assert_equal(Bio::AminoAcid['A'], 'Ala')
    end

    def test_13
      assert_equal(@obj['A'], "Ala")
    end

    def test_1n
      assert_equal(@obj.name('A'), 'alanine')
    end

    def test_to_1_name
      assert_equal(@obj.to_1('alanine'), 'A')
    end

    def test_to_1_3
      assert_equal(@obj.to_1('Ala'), 'A')
    end

    def test_to_1_1
      assert_equal(@obj.to_1('A'), 'A')
    end

    def test_to_3_name
      assert_equal(@obj.to_3('alanine'), 'Ala')
    end

    def test_to_3_3
      assert_equal(@obj.to_3('Ala'), 'Ala')
    end

    def test_to_3_1
      assert_equal(@obj.to_3('A'), 'Ala')
    end

    def test_one2three
      assert_equal(@obj.one2three('A'), 'Ala')
    end

    def test_three2one
      assert_equal(@obj.three2one('Ala'), 'A')
    end

    def test_one2name
      assert_equal(@obj.one2name('A'), 'alanine')
    end

    def test_name2one
      assert_equal(@obj.name2one('alanine'), 'A')
    end
    
    def test_three2name
      assert_equal(@obj.three2name('Ala'), 'alanine')
    end

    def test_name2three
      assert_equal(@obj.name2three('alanine'), 'Ala')
    end
    
    def test_to_re
      assert_equal(@obj.to_re('BZACDEFGHIKLMNPQRSTVWYU'), /[DN][EQ]ACDEFGHIKLMNPQRSTVWYU/)
    end
  end
end
