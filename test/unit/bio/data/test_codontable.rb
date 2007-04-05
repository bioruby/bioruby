#
# test/unit/bio/data/test_codontable.rb - Unit test for Bio::CodonTable
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_codontable.rb,v 1.6 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/data/codontable'

module Bio
  class TestCodonTableConstants < Test::Unit::TestCase
    def test_Definitions
      assert(Bio::CodonTable::DEFINITIONS)
      assert(Bio::CodonTable::DEFINITIONS[1], "Standard (Eukaryote)")
    end

    def test_Starts
      assert(Bio::CodonTable::STARTS)
      assert_equal(['ttg', 'ctg', 'atg', 'gtg'], Bio::CodonTable::STARTS[1])
    end

    def test_stops
      assert(Bio::CodonTable::STOPS)
      assert_equal(['taa', 'tag', 'tga'], Bio::CodonTable::STOPS[1])
    end

    def test_Tables
      assert(Bio::CodonTable::TABLES)
    end
  end


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


    def test_Tables
      assert_equal(@ct.table, Bio::CodonTable::TABLES[1])
    end

  end
end # module Bio
