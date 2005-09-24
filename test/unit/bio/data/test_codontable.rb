#
# test/unit/bio/data/test_codontable.rb - Unit test for Bio::CodonTable
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
#  $Id: test_codontable.rb,v 1.1 2005/09/24 02:21:12 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/data/codontable'

module Bio
  class TestCodonTable < Test::Unit::TestCase
    
    def setup
      @ct = Bio::CodonTable[1]
    end

    def test_self_accessor
      assert(Bio::CodonTable[1])
    end

    def test_self_copy
      assert(Bio::CodonTable.copy(1))
    end

    def test_table
      assert(@ct.table)
    end

    def test_definition
      assert_equal(@ct.definition, "Standard (Eukaryote)")
    end
    
    def test_start
      assert_equal(@ct.start, ['ttg', 'ctg', 'atg', 'gtg'])
    end

    def test_stop
      assert_equal(@ct.stop, ['taa', 'tag', 'tga'])
    end

    def test_accessor #[]
      assert_equal(@ct['atg'], 'M')
    end

    def test_set_accessor #[]=
      alternative = 'Y'
      @ct['atg'] = alternative
      assert_equal(@ct['atg'], alternative)
      @ct['atg'] = 'M'
      assert_equal(@ct['atg'], 'M')
    end

    def test_each
      assert(@ct.each {|x| })
    end

    def test_revtrans
      assert_equal(@ct.revtrans('M'), ['atg'])
    end

    def test_start_codon?
      assert_equal(@ct.start_codon?('atg'), true)
      assert_equal(@ct.start_codon?('taa'), false)
    end

    def test_stop_codon?
      assert_equal(@ct.stop_codon?('atg'), false)
      assert_equal(@ct.stop_codon?('taa'), true)
    end

    def test_Definitions
      assert(Bio::CodonTable::Definitions)
      assert(Bio::CodonTable::Definitions[1], "Standard (Eukaryote)")
    end

    def test_Starts
      assert(Bio::CodonTable::Starts)
      assert_equal(Bio::CodonTable::Starts[1], ['ttg', 'ctg', 'atg', 'gtg'])
    end

    def test_stops
      assert(Bio::CodonTable::Stops)
      assert_equal(Bio::CodonTable::Stops[1], ['taa', 'tag', 'tga'])
    end

    def test_Tables
      assert(Bio::CodonTable::Tables)
      assert_equal(Bio::CodonTable::Tables[1], @ct.table)
    end

  end
end # module Bio
