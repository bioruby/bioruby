#
# test/unit/bio/db/kegg/test_orthology.rb - Unit test for Bio::KEGG::ORTHOLOGY
#
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/reference'
require 'bio/db/kegg/orthology'

module Bio
  class TestKeggOrthology < Test::Unit::TestCase

    def setup
      testdata_kegg = Pathname.new(File.join(BioRubyTestDataPath, 'KEGG')).cleanpath.to_s
      entry = File.read(File.join(testdata_kegg, "K02338.orthology"))
      @obj = Bio::KEGG::ORTHOLOGY.new(entry)
    end

    def test_entry_id
      assert_equal('K02338', @obj.entry_id)
    end

    def test_name
      assert_equal("DPO3B, dnaN", @obj.name)
    end

    def test_names
      assert_equal(["DPO3B", "dnaN"], @obj.names)
    end

    def test_definition
      assert_equal("DNA polymerase III subunit beta [EC:2.7.7.7]", @obj.definition)
    end

    def test_dblinks_as_hash
      assert_equal({"COG"=>["COG0592"], "RN"=>["R00375", "R00376", "R00377", "R00378"], "GO"=>["0003887"]}, @obj.dblinks_as_hash)
    end

    def test_dblinks
      expected = {
        "COG" => ["COG0592"],
        "RN"  => ["R00375", "R00376", "R00377", "R00378"],
        "GO"  => ["0003887"]
      }
      assert_equal(expected, @obj.dblinks)
    end

    def test_genes_as_hash
      assert_equal(1000, @obj.genes_as_hash.size)
      assert_equal(["BSU00020"], @obj.genes_as_hash["bsu"])
      assert_equal(["SynWH7803_0001"], @obj.genes_as_hash["syx"])
    end

    def test_modules_as_hash
      expected = {"M00597"=>"DNA polymerase III complex"}
      assert_equal(expected, @obj.modules_as_hash)
    end

    def test_modules
      expected = {"M00597"=>"DNA polymerase III complex"}
      assert_equal(expected, @obj.modules)
    end

    def test_references
      data = 
        [ { "authors" => [ "Stillman B." ],
            "journal" => "Cell",
            "pages"   => "725-8",
            "pubmed"  => "8087839",
            "title"   => "Smart machines at the DNA replication fork.",
            "volume"  => "78",
            "year"    => "1994"
          } ]
      expected = data.collect { |h| Bio::Reference.new(h) }
      assert_equal(expected, @obj.references)
    end

    def test_keggclass
      expected = "Metabolism; Nucleotide Metabolism; Purine metabolism [PATH:ko00230] Metabolism; Nucleotide Metabolism; Pyrimidine metabolism [PATH:ko00240] Genetic Information Processing; Replication and Repair; DNA replication [PATH:ko03030] Genetic Information Processing; Replication and Repair; DNA replication proteins [BR:ko03032] Genetic Information Processing; Replication and Repair; Mismatch repair [PATH:ko03430] Genetic Information Processing; Replication and Repair; Homologous recombination [PATH:ko03440] Genetic Information Processing; Replication and Repair; DNA repair and recombination proteins [BR:ko03400]"
      assert_equal(expected, @obj.keggclass)
    end

    def test_keggclasses
      expected =
        [ "Metabolism; Nucleotide Metabolism; Purine metabolism",
          "Metabolism; Nucleotide Metabolism; Pyrimidine metabolism",
          "Genetic Information Processing; Replication and Repair; DNA replication",
          "Genetic Information Processing; Replication and Repair; DNA replication proteins",
          "Genetic Information Processing; Replication and Repair; Mismatch repair",
          "Genetic Information Processing; Replication and Repair; Homologous recombination",
          "Genetic Information Processing; Replication and Repair; DNA repair and recombination proteins"
        ]
      assert_equal(expected, @obj.keggclasses)
    end

    def test_pathways_as_strings
      expected = ["ko00230  Purine metabolism",
 "ko00240  Pyrimidine metabolism",
 "ko03030  DNA replication",
 "ko03430  Mismatch repair",
 "ko03440  Homologous recombination"]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_pathways_in_keggclass
      expected = ["ko00230", "ko00240", "ko03030", "ko03430", "ko03440"]
      assert_equal(expected, @obj.pathways_in_keggclass)
    end

    def test_modules_as_strings
      expected = ["M00597  DNA polymerase III complex"]
      assert_equal(expected, @obj.modules_as_strings)
    end

    def test_dblinks_as_strings
      expected = [ "RN: R00375 R00376 R00377 R00378",
                   "COG: COG0592", "GO: 0003887" ]
      assert_equal(expected, @obj.dblinks_as_strings)
    end

    def test_genes_as_strings
      assert_equal(1000, @obj.genes_as_strings.size)
      assert_equal("ECO: b3701(dnaN)", @obj.genes_as_strings[0])
      assert_equal("BPN: BPEN_015(dnaN)", @obj.genes_as_strings[100])
      assert_equal("SVO: SVI_0032(dnaN)", @obj.genes_as_strings[200])
      assert_equal("RFR: Rfer_0002 Rfer_4311", @obj.genes_as_strings[300])
      assert_equal("OTS: OTBS_0002(dnaN)", @obj.genes_as_strings[400])
      assert_equal("ACR: Acry_1437", @obj.genes_as_strings[500])
      assert_equal("SPD: SPD_0002(dnaN)", @obj.genes_as_strings[600])
      assert_equal("TEX: Teth514_0002", @obj.genes_as_strings[700])
      assert_equal("FAL: FRAAL0004(dnaN) FRAAL1257",
                   @obj.genes_as_strings[800])
      assert_equal("AMU: Amuc_0816", @obj.genes_as_strings[900])
      assert_equal("DAP: Dacet_2869", @obj.genes_as_strings[-1])
    end

  end
end
