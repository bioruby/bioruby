#
# test/unit/bio/db/kegg/test_pathway.rb - Unit test for Bio::KEGG::PATHWAY
#
# Copyright::  Copyright (C) 2010 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/pathway'

module Bio
  class TestKeggPathway < Test::Unit::TestCase

    def setup
      testdata_kegg = Pathname.new(File.join(BioRubyTestDataPath, 'KEGG')).cleanpath.to_s
      entry = File.read(File.join(testdata_kegg, "map00052.pathway"))
      @obj = Bio::KEGG::PATHWAY.new(entry)
    end

    def test_entry_id
      assert_equal('map00052', @obj.entry_id)
    end

    def test_name
      assert_equal('Galactose metabolism', @obj.name)
    end

    def test_keggclass
      assert_equal('Metabolism; Carbohydrate Metabolism', @obj.keggclass)
    end

    def test_pathway_modules_as_hash
      expected = {
        "M00097"=>"UDP-glucose and UDP-galactose biosynthesis, Glc-1P/Gal-1P => UDP-Glc/UDP-Gal",
        "M00614"=>"PTS system, N-acetylgalactosamine-specific II component",
        "M00616"=>"PTS system, galactitol-specific II component",
        "M00618"=>"PTS system, lactose-specific II component",
        "M00624"=>"PTS system, galactosamine-specific II component"
      }
      assert_equal(expected, @obj.pathway_modules_as_hash)
      assert_equal(expected, @obj.pathway_modules)
    end

    def test_pathway_modules_as_strings
      expected =
        [ "M00097  UDP-glucose and UDP-galactose biosynthesis, Glc-1P/Gal-1P => UDP-Glc/UDP-Gal",
          "M00614  PTS system, N-acetylgalactosamine-specific II component",
          "M00616  PTS system, galactitol-specific II component",
          "M00618  PTS system, lactose-specific II component",
          "M00624  PTS system, galactosamine-specific II component"
        ]
      assert_equal(expected, @obj.pathway_modules_as_strings)
    end

    def test_rel_pathways_as_strings
      expected = [ "map00010  Glycolysis / Gluconeogenesis",
                   "map00040  Pentose and glucuronate interconversions",
                   "map00051  Fructose and mannose metabolism",
                   "map00520  Amino sugar and nucleotide sugar metabolism"
                 ]
      assert_equal(expected, @obj.rel_pathways_as_strings)
    end

    def test_rel_pathways_as_hash
      expected = {
        "map00010"=>"Glycolysis / Gluconeogenesis",
        "map00040"=>"Pentose and glucuronate interconversions",
        "map00051"=>"Fructose and mannose metabolism",
        "map00520"=>"Amino sugar and nucleotide sugar metabolism"
      }
      assert_equal(expected, @obj.rel_pathways_as_hash)
      assert_equal(expected, @obj.rel_pathways)
    end

  end
end
