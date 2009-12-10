#
# test/unit/bio/db/kegg/test_enzyme.rb - Unit test for Bio::KEGG::ENZYME
#
# Copyright::  Copyright (C) 2009 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'digest/sha1'
require 'bio/db/kegg/enzyme'

module Bio
  class TestKeggEnzyme < Test::Unit::TestCase

    def setup
      testdata_kegg = Pathname.new(File.join(BioRubyTestDataPath,
                                             'KEGG')).cleanpath.to_s
      entry = File.read(File.join(testdata_kegg, "1.1.1.1.enzyme"))
      @obj = Bio::KEGG::ENZYME.new(entry)
    end

    def test_entry
      assert_equal("EC 1.1.1.1 Enzyme", @obj.entry)
    end

    def test_entry_id
      assert_equal("1.1.1.1", @obj.entry_id)
    end

    def test_obsolete?
      assert_equal(false, @obj.obsolete?)
    end

    def test_names
      expected = [ "alcohol dehydrogenase",
                   "aldehyde reductase",
                   "ADH",
                   "alcohol dehydrogenase (NAD)",
                   "aliphatic alcohol dehydrogenase",
                   "ethanol dehydrogenase",
                   "NAD-dependent alcohol dehydrogenase",
                   "NAD-specific aromatic alcohol dehydrogenase",
                   "NADH-alcohol dehydrogenase",
                   "NADH-aldehyde dehydrogenase",
                   "primary alcohol dehydrogenase",
                   "yeast alcohol dehydrogenase" ]
      assert_equal(expected, @obj.names)
    end

    def test_name
      assert_equal("alcohol dehydrogenase", @obj.name)
    end

    def test_classes
      assert_equal([ "Oxidoreductases;",
                     "Acting on the CH-OH group of donors;",
                     "With NAD+ or NADP+ as acceptor" ], @obj.classes)
    end

    def test_sysname
      assert_equal("alcohol:NAD+ oxidoreductase", @obj.sysname)
    end

    def test_reaction
      expected = "an alcohol + NAD+ = an aldehyde or ketone + NADH + H+ [RN:R07326 R07327]"
      assert_equal(expected, @obj.reaction)
    end

    def test_all_reac
      expected = "R07326 > R00623 R00754 R02124 R04805 R04880 R05233 R05234 R06917 R06927 R08281 R08306 R08557 R08558; R07327 > R00624 R08310; (other) R07105"
      assert_equal(expected, @obj.all_reac)
    end

    def test_iubmb_reactions
      expected = [ "R07326 > R00623 R00754 R02124 R04805 R04880 R05233 R05234 R06917 R06927 R08281 R08306 R08557 R08558",
                   "R07327 > R00624 R08310" ]
      assert_equal(expected, @obj.iubmb_reactions)
    end

    def test_kegg_reactions
      assert_equal(["R07105"], @obj.kegg_reactions)
    end

    def test_substrates
      expected = [ "alcohol [CPD:C00069]", "NAD+ [CPD:C00003]" ]
      assert_equal(expected, @obj.substrates)
    end

    def test_products
      expected = [ "aldehyde [CPD:C00071]",
                   "ketone [CPD:C01450]",
                   "NADH [CPD:C00004]",
                   "H+ [CPD:C00080]" ]
      assert_equal(expected, @obj.products)
    end

    def test_inhibitors
      assert_equal([], @obj.inhibitors)
    end

    def test_cofactors
      assert_equal(["Zinc [CPD:C00038]"], @obj.cofactors)
    end

    def test_comment
      expected = "A zinc protein. Acts on primary or secondary alcohols or hemi-acetals; the animal, but not the yeast, enzyme acts also on cyclic secondary alcohols."
      assert_equal(expected, @obj.comment)
    end

    def test_pathways_as_strings
      expected = [ "PATH: ec00010  Glycolysis / Gluconeogenesis",
                   "PATH: ec00071  Fatty acid metabolism",
                   "PATH: ec00260  Glycine, serine and threonine metabolism",
                   "PATH: ec00350  Tyrosine metabolism",
                   "PATH: ec00624  1- and 2-Methylnaphthalene degradation",
                   "PATH: ec00641  3-Chloroacrylic acid degradation",
                   "PATH: ec00830  Retinol metabolism",
                   "PATH: ec00980  Metabolism of xenobiotics by cytochrome P450",
                   "PATH: ec00982  Drug metabolism - cytochrome P450",
                   "PATH: ec01100  Metabolic pathways" ]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_pathways_as_hash
      expected = {
        "ec01100" => "Metabolic pathways",
        "ec00982" => "Drug metabolism - cytochrome P450",
        "ec00641" => "3-Chloroacrylic acid degradation",
        "ec00830" => "Retinol metabolism",
        "ec00071" => "Fatty acid metabolism",
        "ec00260" => "Glycine, serine and threonine metabolism",
        "ec00624" => "1- and 2-Methylnaphthalene degradation",
        "ec00350" => "Tyrosine metabolism",
        "ec00010" => "Glycolysis / Gluconeogenesis",
        "ec00980" => "Metabolism of xenobiotics by cytochrome P450"
      }
      assert_equal(expected, @obj.pathways_as_hash)
      assert_equal(expected, @obj.pathways)
    end

    def test_orthologs_as_strings
      expected = [ "KO: K00001  alcohol dehydrogenase",
                   "KO: K11440  choline dehydrogenase" ]
      assert_equal(expected, @obj.orthologs_as_strings)
    end

    def test_orthologs_as_hash
      expected = {
        "K11440" => "choline dehydrogenase",
        "K00001" => "alcohol dehydrogenase"
      }
      assert_equal(expected, @obj.orthologs_as_hash)
      assert_equal(expected, @obj.orthologs)
    end

    def test_genes_as_strings
      assert_equal(759, @obj.genes_as_strings.size)
      assert_equal("0b01addd884266d7e80fdc34f112b9a89b90cc54",
                   Digest::SHA1.hexdigest(@obj.genes_as_strings.join("\n")))
    end

    def test_genes_as_hash
      assert_equal(759, @obj.genes_as_hash.size)
      assert_equal("025e77f866a7edb0eccaaabcff31df90d8e1fca1",
                   Digest::SHA1.hexdigest(@obj.genes_as_hash.keys.sort.join(";")))
      assert_equal(["124", "125", "126", "127", "128", "130", "131"],
                   @obj.genes_as_hash['hsa'])
      assert_equal(["BSU18430", "BSU26970", "BSU31050"],
                   @obj.genes_as_hash['bsu'])
      assert_equal(["Tpen_1006", "Tpen_1516"],
                   @obj.genes_as_hash['tpe'])
    end

    def test_genes
      assert_equal(759, @obj.genes.size)
      assert_equal("025e77f866a7edb0eccaaabcff31df90d8e1fca1",
                   Digest::SHA1.hexdigest(@obj.genes.keys.sort.join(";")))
      assert_equal(["124", "125", "126", "127", "128", "130", "131"],
                   @obj.genes['hsa'])
      assert_equal(["BSU18430", "BSU26970", "BSU31050"],
                   @obj.genes['bsu'])
      assert_equal(["Tpen_1006", "Tpen_1516"],
                   @obj.genes['tpe'])
    end

    def test_diseases
      assert_equal([], @obj.diseases)
    end

    def test_motifs
      assert_equal([], @obj.motifs)
    end

    def test_structures
      expected = ["1A4U", "1A71", "1A72", "1ADB", "1ADC", "1ADF", "1ADG",
                  "1AGN", "1AXE", "1AXG", "1B14", "1B15", "1B16", "1B2L",
                  "1BTO", "1CDO", "1D1S", "1D1T", "1DEH", "1E3E", "1E3I",
                  "1E3L", "1EE2", "1H2B", "1HDX", "1HDY", "1HDZ", "1HET",
                  "1HEU", "1HF3", "1HLD", "1HSO", "1HSZ", "1HT0", "1HTB",
                  "1JU9", "1JVB", "1LDE", "1LDY", "1LLU", "1M6H", "1M6W",
                  "1MA0", "1MC5", "1MG0", "1MG5", "1MGO", "1MP0", "1N8K",
                  "1N92", "1NTO", "1NVG", "1O2D", "1P1R", "1QLH", "1QLJ",
                  "1QV6", "1QV7", "1R37", "1RJW", "1SBY", "1TEH", "1U3T",
                  "1U3U", "1U3V", "1U3W", "1VJ0", "1YE3", "2EER", "2FZE",
                  "2FZW", "2HCY", "2JHF", "2JHG", "2OHX", "2OXI", "3BTO",
                  "3COS", "3HUD", "3I4C", "5ADH", "6ADH", "7ADH"]
      assert_equal(expected, @obj.structures)
    end

    def test_dblinks_as_strings
      expected = [ "ExplorEnz - The Enzyme Database: 1.1.1.1",
                   "IUBMB Enzyme Nomenclature: 1.1.1.1",
                   "ExPASy - ENZYME nomenclature database: 1.1.1.1",
                   "UM-BBD (Biocatalysis/Biodegradation Database): 1.1.1.1",
                   "BRENDA, the Enzyme Database: 1.1.1.1",
                   "CAS: 9031-72-5" ]
      assert_equal(expected, @obj.dblinks_as_strings)
    end

    def test_dblinks_as_hash
      expected = {
        "UM-BBD (Biocatalysis/Biodegradation Database)" => [ "1.1.1.1" ],
        "ExPASy - ENZYME nomenclature database"         => [ "1.1.1.1" ],
        "IUBMB Enzyme Nomenclature"                     => [ "1.1.1.1" ],
        "BRENDA, the Enzyme Database"                   => [ "1.1.1.1" ],
        "ExplorEnz - The Enzyme Database"               => [ "1.1.1.1" ],
        "CAS"                                           => [ "9031-72-5" ]
      }
      assert_equal(expected, @obj.dblinks_as_hash)
      assert_equal(expected, @obj.dblinks)
    end

  end #class TestKeggEnzyme < Test::Unit::TestCase
end #module Bio

