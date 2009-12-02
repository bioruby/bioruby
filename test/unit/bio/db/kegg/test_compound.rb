#
# test/unit/bio/db/kegg/test_compound.rb - Unit test for Bio::KEGG::COMPOUND
#
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/compound'

module Bio
  class TestKeggCompound < Test::Unit::TestCase

    def setup
      testdata_kegg = Pathname.new(File.join(BioRubyTestDataPath, 'KEGG')).cleanpath.to_s
      entry = File.read(File.join(testdata_kegg, "C00025.compound"))
      @obj = Bio::KEGG::COMPOUND.new(entry)
    end

    def test_entry_id
      assert_equal('C00025', @obj.entry_id)
    end

    def test_name
      assert_equal("L-Glutamate", @obj.name)
    end

    def test_names
      assert_equal(["L-Glutamate", "L-Glutamic acid", "L-Glutaminic acid", "Glutamate"], @obj.names)
    end

    def test_formula
      assert_equal("C5H9NO4", @obj.formula)
    end

    def test_mass
      assert_equal(147.0532, @obj.mass)
    end

    def test_dblinks
      assert_equal([ "CAS: 56-86-0",
                     "PubChem: 3327",
                     "ChEBI: 16015",
                     "KNApSAcK: C00001358",
                     "PDB-CCD: GLU",
                     "3DMET: B00007",
                     "NIKKAJI: J9.171E" ], @obj.dblinks)
    end

    def test_dblinks_as_hash
      assert_equal({ "CAS"      => [ "56-86-0" ],
                     "PubChem"  => [ "3327" ],
                     "ChEBI"    => [ "16015" ],
                     "KNApSAcK" => [ "C00001358" ],
                     "PDB-CCD"  => [ "GLU" ],
                     "3DMET"    => [ "B00007" ],
                     "NIKKAJI"  => [ "J9.171E" ] }, @obj.dblinks_as_hash)
    end

    def test_pathways_as_hash
      expected = {
        "ko00250"  => "Alanine, aspartate and glutamate metabolism",
        "ko00330"  => "Arginine and proline metabolism",
        "ko00340"  => "Histidine metabolism",
        "ko00471"  => "D-Glutamine and D-glutamate metabolism",
        "ko00480"  => "Glutathione metabolism",
        "ko00650"  => "Butanoate metabolism",
        "ko00660"  => "C5-Branched dibasic acid metabolism",
        "ko00860"  => "Porphyrin and chlorophyll metabolism",
        "ko00910"  => "Nitrogen metabolism",
        "ko00970"  => "Aminoacyl-tRNA biosynthesis",
        "map01060" => "Biosynthesis of plant secondary metabolites",
        "ko01064"  =>
        "Biosynthesis of alkaloids derived from ornithine, lysine and nicotinic acid",
        "ko01100"  => "Metabolic pathways",
        "ko02010"  => "ABC transporters",
        "ko04080"  => "Neuroactive ligand-receptor interaction",
        "ko04540"  => "Gap junction",
        "ko04720"  => "Long-term potentiation",
        "ko04730"  => "Long-term depression",
        "ko04742"  => "Taste transduction",
        "ko05014"  => "Amyotrophic lateral sclerosis (ALS)",
        "ko05016"  => "Huntington's disease"
      }
      assert_equal(expected, @obj.pathways_as_hash)
    end

  end
end
