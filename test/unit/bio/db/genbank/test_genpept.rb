#
# test/unit/bio/db/genbank/test_genpept.rb - Unit test for Bio::GenPept
#
# Copyright::  Copyright (C) 2010 Kazuhiro Hayashi <k.hayashi.info@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/genbank/genpept'

#The coverage of this class is 100%
#It tests only the methods descripbed in the soruce class.(It dosen't test the inherited methods from NCBIDB)
module Bio
  class TestBioGenPept < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'genbank', 'CAA35997.gp')
      @obj = Bio::GenPept.new(File.read(filename))
    end

    def test_locus
      expected =
        {:circular=>"linear",
          :date=>"12-SEP-1993",
          :division=>"MAM",
          :entry_id=>"CAA35997",
          :length=>100}
      locus  = @obj.locus
      actual =
        {:entry_id=>locus.entry_id,
          :circular=>locus.circular,
          :date=>locus.date,
          :division=>locus.division,
          :length=>locus.length}
        
      assert_equal(expected, actual)
    end

    def test_entry_id
      assert_equal("CAA35997", @obj.entry_id)
    end

    def test_length
      assert_equal(100, @obj.length)
    end

    def test_circular
      assert_equal("linear", @obj.circular)
    end

    def test_division
      assert_equal("MAM", @obj.division)
    end

    def test_date
      assert_equal("12-SEP-1993", @obj.date)
    end

    def test_seq
      expected = "MRTPMLLALLALATLCLAGRADAKPGDAESGKGAAFVSKQEGSEVVKRLRRYLDHWLGAPAPYPDPLEPKREVCELNPDCDELADHIGFQEAYRRFYGPV"
      assert_equal(expected, @obj.seq)
    end

    def test_seq_len
      assert_equal(100, @obj.seq_len)
    end

    def test_dbsource
      expected = "DBSOURCE    embl accession X51700.1\n"
      assert_equal(expected, @obj.dbsource)
    end

  end #class TestBioGenPept
end #module Bio

