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
#  $Id: test_codontable.rb,v 1.3 2005/11/23 05:10:34 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
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
      assert_equal("Standard (Eukaryote)", @ct.definition)
    end
    
    def test_start
      assert_equal(['ttg', 'ctg', 'atg', 'gtg'], @ct.start)
    end

    def test_stop
      assert_equal(['taa', 'tag', 'tga'], @ct.stop)
    end

    def test_accessor #[]
      assert_equal('M', @ct['atg'])
    end

    def test_set_accessor #[]=
      alternative = 'Y'
      @ct['atg'] = alternative
      assert_equal(alternative, @ct['atg'])
      @ct['atg'] = 'M'
      assert_equal('M', @ct['atg'])
    end

    def test_each
      assert(@ct.each {|x| })
    end

    def test_revtrans
      assert_equal(['atg'], @ct.revtrans('M'))
    end

    def test_start_codon?
      assert_equal(true, @ct.start_codon?('atg'))
      assert_equal(false, @ct.start_codon?('taa'))
    end

    def test_stop_codon?
      assert_equal(false, @ct.stop_codon?('atg'))
      assert_equal(true, @ct.stop_codon?('taa'))
    end

    def test_Definitions
      assert(Bio::CodonTable::Definitions)
      assert(Bio::CodonTable::Definitions[1], "Standard (Eukaryote)")
    end

    def test_Starts
      assert(Bio::CodonTable::Starts)
      assert_equal(['ttg', 'ctg', 'atg', 'gtg'], Bio::CodonTable::Starts[1])
    end

    def test_stops
      assert(Bio::CodonTable::Stops)
      assert_equal(['taa', 'tag', 'tga'], Bio::CodonTable::Stops[1])
    end

    def test_Tables
      assert(Bio::CodonTable::Tables)
      assert_equal(@ct.table, Bio::CodonTable::Tables[1])
    end

  end
end # module Bio
