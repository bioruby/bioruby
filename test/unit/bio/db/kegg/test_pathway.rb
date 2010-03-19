#
# test/unit/bio/db/kegg/test_pathway.rb - Unit test for Bio::KEGG::PATHWAY
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
require 'bio/db/kegg/pathway'

module Bio
  class TestKeggPathway_map00052 < Test::Unit::TestCase

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

    def test_references
      assert_equal([], @obj.references)
    end

  end #class TestKeggPathway_map00052

  class TestBioKEGGPATHWAY_map00030 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/map00030.pathway')
      @obj = Bio::KEGG::PATHWAY.new(File.read(filename))
    end

    def test_references
      data =
        [ { "authors"  => [ "Nishizuka Y (ed)." ],
            "comments" => [ "(map 3)" ],
            "journal"  => "Tokyo Kagaku Dojin",
            "title"    => "[Metabolic Maps] (In Japanese)",
            "year"     => "1980"
          },
          { "authors"  => [ "Nishizuka Y", "Seyama Y", "Ikai A",
                            "Ishimura Y", "Kawaguchi A (eds)." ],
            "comments" => [ "(map 4)" ],
            "journal"  => "Tokyo Kagaku Dojin",
            "title"=>"[Cellular Functions and Metabolic Maps] (In Japanese)",
            "year"     => "1997"
          },
          { "authors" => [ "Michal G." ],
            "journal" => "Wiley",
            "title"   => "Biochemical Pathways",
            "year"    => "1999"
          },
          { "authors" => [ "Hove-Jensen B", "Rosenkrantz TJ",
                           "Haldimann A", "Wanner BL." ],
            "journal" => "J Bacteriol",
            "pages"   => "2793-801",
            "pubmed"  => "12700258",
            "title"   => "Escherichia coli phnN, encoding ribose 1,5-bisphosphokinase activity (phosphoribosyl diphosphate forming): dual role in phosphonate degradation and NAD biosynthesis pathways.",
            "volume"  => "185",
            "year"    => "2003"
          }
        ]
      expected = data.collect { |h| Bio::Reference.new(h) }
      assert_equal(expected, @obj.references)
    end

    def test_new
      assert_instance_of(Bio::KEGG::PATHWAY, @obj)
    end

    def test_entry_id
      assert_equal("map00030", @obj.entry_id)
    end

    def test_name
      assert_equal("Pentose phosphate pathway", @obj.name)
    end

    def test_keggclass
      expected = "Metabolism; Carbohydrate Metabolism"
      assert_equal(expected, @obj.keggclass)
    end

    def test_pathway_modules_as_strings
      expected =
        [ "M00004  Pentose phosphate pathway (Pentose phosphate cycle) [PATH:map00030]",
          "M00005  PRPP biosynthesis, ribose 5P -> PRPP [PATH:map00030]",
          "M00006  Pentose phosphate pathway, oxidative phase, glucose 6P => ribulose 5P [PATH:map00030]",
          "M00007  Pentose phosphate pathway, non-oxidative phase, fructose 6P => ribose 5P [PATH:map00030]",
          "M00008  Entner-Doudoroff pathway, glucose-6P => glyceraldehyde-3P + pyruvate [PATH:map00030]",
          "M00680  Semi-phosphorylative Entner-Doudoroff pathway, gluconate => glyceraldehyde-3P + pyruvate [PATH:map00030]",
          "M00681  Non-phosphorylative Entner-Doudoroff pathway, gluconate => glyceraldehyde + pyruvate [PATH:map00030]"
        ]
      assert_equal(expected, @obj.pathway_modules_as_strings)
    end

    def test_pathway_modules_as_hash
      expected = {
        "M00008" => "Entner-Doudoroff pathway, glucose-6P => glyceraldehyde-3P + pyruvate [PATH:map00030]",
        "M00680" => "Semi-phosphorylative Entner-Doudoroff pathway, gluconate => glyceraldehyde-3P + pyruvate [PATH:map00030]",
        "M00681" => "Non-phosphorylative Entner-Doudoroff pathway, gluconate => glyceraldehyde + pyruvate [PATH:map00030]",
        "M00004" => "Pentose phosphate pathway (Pentose phosphate cycle) [PATH:map00030]",
        "M00005" => "PRPP biosynthesis, ribose 5P -> PRPP [PATH:map00030]",
        "M00006" => "Pentose phosphate pathway, oxidative phase, glucose 6P => ribulose 5P [PATH:map00030]",
        "M00007" => "Pentose phosphate pathway, non-oxidative phase, fructose 6P => ribose 5P [PATH:map00030]"
      }
      assert_equal(expected, @obj.pathway_modules_as_hash)
      assert_equal(expected, @obj.pathway_modules)
    end

    def test_rel_pathways_as_strings
      expected = [ "map00010  Glycolysis / Gluconeogenesis",
                   "map00040  Pentose and glucuronate interconversions",
                   "map00230  Purine metabolism",
                   "map00240  Pyrimidine metabolism",
                   "map00340  Histidine metabolism" ]
      assert_equal(expected, @obj.rel_pathways_as_strings)
    end

    def test_rel_pathways_as_hash
      expected = {
        "map00240" => "Pyrimidine metabolism",
        "map00340" => "Histidine metabolism",
        "map00230" => "Purine metabolism",
        "map00010" => "Glycolysis / Gluconeogenesis",
        "map00040" => "Pentose and glucuronate interconversions"
      }
      assert_equal(expected, @obj.rel_pathways_as_hash)
      assert_equal(expected, @obj.rel_pathways)
    end

  end #class TestBioKEGGPATHWAY

end #module Bio
