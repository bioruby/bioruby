#
# test/unit/bio/db/kegg/test_module.rb - Unit test for Bio::KEGG::MODULE
#
# Copyright::  Copyright (C) 2010 Kozo Nishida <kozo-ni@is.naist.jp>
#              Copyright (C) 2010 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/module'

module Bio
  class TestKeggModule < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/M00118.module')
      entry = File.read(filename)
      @obj = Bio::KEGG::MODULE.new(entry)
    end

    def test_new
      assert_instance_of(Bio::KEGG::MODULE, @obj)
    end

    def test_entry_id
      assert_equal('M00118', @obj.entry_id)
    end

    def test_name
      assert_equal('Pentose interconversion, arabinose/ribulose/xylulose/xylose', @obj.name)
    end

    def test_definition
      expected = "K00011 K01804 K00853 (K01786,K03080) K03331 K05351 K00854 K00011 K01805 K01783 (K00853,K00875) K00039"
      assert_equal(expected, @obj.definition)
    end

    def test_keggclass
      assert_equal('Metabolism; Central metabolism; Other carbohydrate metabolism', @obj.keggclass)
    end

    def test_pathways_as_strings
      expected = ["ko00040(K00011+K01804+K00853+K01786+K03080+K03331+K05351+K00854+K00011+K01805+K01783+K00853+K00875+K00039)  Pentose and glucuronate interconversions"]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_pathways_as_hash
      expected = { "ko00040(K00011+K01804+K00853+K01786+K03080+K03331+K05351+K00854+K00011+K01805+K01783+K00853+K00875+K00039)" =>
        "Pentose and glucuronate interconversions" }
      assert_equal(expected, @obj.pathways_as_hash)
    end

    def test_pathways
      expected = { "ko00040(K00011+K01804+K00853+K01786+K03080+K03331+K05351+K00854+K00011+K01805+K01783+K00853+K00875+K00039)" =>
        "Pentose and glucuronate interconversions" }
      assert_equal(expected, @obj.pathways)
    end

    def test_orthologs_as_strings
      expected =
        [ "K00011  aldehyde reductase [EC:1.1.1.21] [RN:R01758 R01759]",
          "K01804  L-arabinose isomerase [EC:5.3.1.4] [RN:R01761]",
          "K00853  L-ribulokinase [EC:2.7.1.16] [RN:R02439]",
          "K01786,K03080  L-ribulose-5-phosphate 4-epimerase [EC:5.1.3.4] [RN:R05850]",
          "K03331  L-xylulose reductase [EC:1.1.1.10] [RN:R01904]",
          "K05351  D-xylulose reductase [EC:1.1.1.9] [RN:R01896]",
          "K00854  xylulokinase [EC:2.7.1.17] [RN:R01639]",
          "K00011  aldehyde reductase [EC:1.1.1.21] [RN:R01431]",
          "K01805  xylose isomerase [EC:5.3.1.5] [RN:R01432]",
          "K01783  ribulose-phosphate 3-epimerase [EC:5.1.3.1] [RN:R01529]",
          "K00853,K00875  ribulokinase [EC:2.7.1.16 2.7.1.47] [RN:R01526]",
          "K00039  ribitol 2-dehydrogenase [EC:1.1.1.56] [RN:R01895]"
        ]
      assert_equal(expected, @obj.orthologs_as_strings)
    end

    def test_orthologs_as_hash
      expected = {
        "K00039" => "ribitol 2-dehydrogenase [EC:1.1.1.56] [RN:R01895]",
        "K00853" => "L-ribulokinase [EC:2.7.1.16] [RN:R02439]",
        "K00854" => "xylulokinase [EC:2.7.1.17] [RN:R01639]",
        "K05351" => "D-xylulose reductase [EC:1.1.1.9] [RN:R01896]",
        "K00853,K00875" => "ribulokinase [EC:2.7.1.16 2.7.1.47] [RN:R01526]",
        "K03331" => "L-xylulose reductase [EC:1.1.1.10] [RN:R01904]",
        "K00011" => "aldehyde reductase [EC:1.1.1.21] [RN:R01431]",
        "K01786,K03080" =>
        "L-ribulose-5-phosphate 4-epimerase [EC:5.1.3.4] [RN:R05850]",
        "K01804" => "L-arabinose isomerase [EC:5.3.1.4] [RN:R01761]",
        "K01783" => "ribulose-phosphate 3-epimerase [EC:5.1.3.1] [RN:R01529]",
        "K01805" => "xylose isomerase [EC:5.3.1.5] [RN:R01432]"
      }
      assert_equal(expected, @obj.orthologs_as_hash)
    end

    def test_orthologs
      expected = {
        "K00039" => "ribitol 2-dehydrogenase [EC:1.1.1.56] [RN:R01895]",
        "K00853" => "L-ribulokinase [EC:2.7.1.16] [RN:R02439]",
        "K00854" => "xylulokinase [EC:2.7.1.17] [RN:R01639]",
        "K05351" => "D-xylulose reductase [EC:1.1.1.9] [RN:R01896]",
        "K00853,K00875" => "ribulokinase [EC:2.7.1.16 2.7.1.47] [RN:R01526]",
        "K03331" => "L-xylulose reductase [EC:1.1.1.10] [RN:R01904]",
        "K00011" => "aldehyde reductase [EC:1.1.1.21] [RN:R01431]",
        "K01786,K03080" =>
        "L-ribulose-5-phosphate 4-epimerase [EC:5.1.3.4] [RN:R05850]",
        "K01804" => "L-arabinose isomerase [EC:5.3.1.4] [RN:R01761]",
        "K01783" => "ribulose-phosphate 3-epimerase [EC:5.1.3.1] [RN:R01529]",
        "K01805" => "xylose isomerase [EC:5.3.1.5] [RN:R01432]"
      }
      assert_equal(expected, @obj.orthologs)
    end

    def test_orthologs_as_array
      expected =
        [ "K00011",
          "K00039",
          "K00853",
          "K00854",
          "K00875",
          "K01783",
          "K01786",
          "K01804",
          "K01805",
          "K03080",
          "K03331",
          "K05351"
        ]
      assert_equal(expected, @obj.orthologs_as_array)
    end

    def test_reactions_as_strings
      expected = [ "R01903  C00312 -> C00532",
                   "R01758,R01759  C00532 -> C00259",
                   "R01761  C00259 -> C00508",
                   "R02439  C00508 -> C01101",
                   "R05850  C01101 -> C00231",
                   "R01904  C00312 -> C00379",
                   "R01896  C00379 -> C00310",
                   "R01639  C00310 -> C00231",
                   "R01431  C00379 -> C00181",
                   "R01432  C00181 -> C00310",
                   "R01529  C00199 -> C00231",
                   "R01526  C00231 -> C00309",
                   "R01895  C00309 -> C00474"
                 ]
      assert_equal(expected, @obj.reactions_as_strings)
    end

    def test_reactions_as_hash
      expected = {
        "R01529" => "C00199 -> C00231",
        "R01431" => "C00379 -> C00181",
        "R01639" => "C00310 -> C00231",
        "R01761" => "C00259 -> C00508",
        "R01903" => "C00312 -> C00532",
        "R01904" => "C00312 -> C00379",
        "R01432" => "C00181 -> C00310",
        "R01758,R01759" => "C00532 -> C00259",
        "R01895" => "C00309 -> C00474",
        "R01896" => "C00379 -> C00310",
        "R02439" => "C00508 -> C01101",
        "R05850" => "C01101 -> C00231",
        "R01526" => "C00231 -> C00309"
      }
      assert_equal(expected, @obj.reactions_as_hash)
    end

    def test_reactions
      expected = {
        "R01529" => "C00199 -> C00231",
        "R01431" => "C00379 -> C00181",
        "R01639" => "C00310 -> C00231",
        "R01761" => "C00259 -> C00508",
        "R01903" => "C00312 -> C00532",
        "R01904" => "C00312 -> C00379",
        "R01432" => "C00181 -> C00310",
        "R01758,R01759" => "C00532 -> C00259",
        "R01895" => "C00309 -> C00474",
        "R01896" => "C00379 -> C00310",
        "R02439" => "C00508 -> C01101",
        "R05850" => "C01101 -> C00231",
        "R01526" => "C00231 -> C00309"
      }
      assert_equal(expected, @obj.reactions)
    end

    def test_compounds_as_strings
      expected = [ "C00312  L-Xylulose",
                   "C00532  L-Arabitol",
                   "C00259  L-Arabinose",
                   "C00508  L-Ribulose",
                   "C01101  L-Ribulose 5-phosphate",
                   "C00231  D-Xylulose 5-phosphate",
                   "C00379  Xylitol",
                   "C00310  D-Xylulose",
                   "C00181  D-Xylose",
                   "C00199  D-Ribulose 5-phosphate",
                   "C00309  D-Ribulose",
                   "C00474  Ribitol"
                 ]
      assert_equal(expected, @obj.compounds_as_strings)
    end

    def test_compounds_as_hash
      expected = {
        "C00231" => "D-Xylulose 5-phosphate",
        "C00474" => "Ribitol",
        "C00309" => "D-Ribulose",
        "C00199" => "D-Ribulose 5-phosphate",
        "C01101" => "L-Ribulose 5-phosphate",
        "C00310" => "D-Xylulose",
        "C00508" => "L-Ribulose",
        "C00532" => "L-Arabitol",
        "C00312" => "L-Xylulose",
        "C00181" => "D-Xylose",
        "C00379" => "Xylitol",
        "C00259" => "L-Arabinose"
      }
      assert_equal(expected, @obj.compounds_as_hash)
    end

    def test_compounds
      expected = {
        "C00231" => "D-Xylulose 5-phosphate",
        "C00474" => "Ribitol",
        "C00309" => "D-Ribulose",
        "C00199" => "D-Ribulose 5-phosphate",
        "C01101" => "L-Ribulose 5-phosphate",
        "C00310" => "D-Xylulose",
        "C00508" => "L-Ribulose",
        "C00532" => "L-Arabitol",
        "C00312" => "L-Xylulose",
        "C00181" => "D-Xylose",
        "C00379" => "Xylitol",
        "C00259" => "L-Arabinose"
      }
      assert_equal(expected, @obj.compounds)
    end

  end
end
