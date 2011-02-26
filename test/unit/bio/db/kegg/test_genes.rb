#
# test/unit/bio/db/kegg/test_genes.rb - Unit test for Bio::KEGG::GENES
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
#              Copyright (C) 2010 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/genes'

module Bio
  class TestKeggGenesStructure < Test::Unit::TestCase
    def setup
      entry =<<END
STRUCTURE   PDB: 1A9X 1CS0 1C30 1T36 1M6V 1KEE 1C3O 1CE8 1BXR 1JDB
END
      @obj = Bio::KEGG::GENES.new(entry)
    end
    
    def test_data
      str = "STRUCTURE   PDB: 1A9X 1CS0 1C30 1T36 1M6V 1KEE 1C3O 1CE8 1BXR 1JDB"
      assert_equal(str, @obj.instance_eval('get("STRUCTURE")'))
    end

    def test_ids_in_array
      assert_equal(Array, @obj.structure.class)
    end

    def test_ids
      expected = %w( 1A9X 1CS0 1C30 1T36 1M6V 1KEE 1C3O 1CE8 1BXR 1JDB )
      assert_equal(expected, @obj.structure)
      assert_equal(expected, @obj.structures)
    end

  end


  class TestKeggGenesDblinks < Test::Unit::TestCase

    def setup
      entry =<<END
DBLINKS     TIGR: At3g05560
            NCBI-GI: 15230008  42572267
END
      @obj = Bio::KEGG::GENES.new(entry)
    end

    def test_data
      str = "DBLINKS     TIGR: At3g05560\n            NCBI-GI: 15230008  42572267"
      assert_equal(str, @obj.instance_eval('get("DBLINKS")'))
    end

    def test_dblinks_0
      assert_equal(Hash, @obj.dblinks.class)
    end

    def test_dblinks_1
      assert_equal(['At3g05560'], @obj.dblinks['TIGR'])
    end

    def test_dblinks_2
      assert_equal(['15230008', '42572267'], @obj.dblinks['NCBI-GI'])
    end
  end

  class TestBioKEGGGENES_b0529 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/b0529.gene')
      @obj = Bio::KEGG::GENES.new(File.read(filename))
    end

    def test_dblinks_as_hash
      expected = {
        "NCBI-GI"=>["16128513"],
        "UniProt"=>["P24186"],
        "NCBI-GeneID"=>["945221"],
        "ECOCYC"=>["EG10328"],
        "EcoGene"=>["EG10328"],
        "RegulonDB"=>["B0529"]
      }
      assert_equal(expected, @obj.dblinks_as_hash)
    end

    def test_pathways_as_hash
      expected = {
        "eco00630" => "Glyoxylate and dicarboxylate metabolism",
        "eco00670" => "One carbon pool by folate",
        "eco01100" => "Metabolic pathways"
      }
      assert_equal(expected, @obj.pathways_as_hash)
    end

    def test_orthologs_as_hash
      expected = { "K01491" => "methylenetetrahydrofolate dehydrogenase (NADP+) / methenyltetrahydrofolate cyclohydrolase [EC:1.5.1.5 3.5.4.9]" }
      assert_equal(expected, @obj.orthologs_as_hash)
    end

    def test_new
      assert_instance_of(Bio::KEGG::GENES, @obj)
    end

    def test_entry
      expected = {"organism"=>"E.coli", "division"=>"CDS", "id"=>"b0529"}
      assert_equal(expected, @obj.entry)
    end

    def test_entry_id
      assert_equal("b0529", @obj.entry_id)
    end

    def test_division
      assert_equal("CDS", @obj.division)
    end

    def test_organism
      assert_equal("E.coli", @obj.organism)
    end

    def test_name
      assert_equal("folD, ads, ECK0522, JW0518", @obj.name)
    end

    def test_names_as_array
      expected = ["folD", "ads", "ECK0522", "JW0518"]
      assert_equal(expected, @obj.names_as_array)
      assert_equal(expected, @obj.names)
    end

    def test_genes
      expected = ["folD", "ads", "ECK0522", "JW0518"]
      assert_equal(expected, @obj.genes)
    end

    def test_gene
      assert_equal("folD", @obj.gene)
    end

    def test_definition
      expected = "bifunctional 5,10-methylene-tetrahydrofolate dehydrogenase/5,10-methylene-tetrahydrofolate cyclohydrolase (EC:1.5.1.5 3.5.4.9)"
      assert_equal(expected, @obj.definition)
    end

    def test_eclinks
      assert_equal(["1.5.1.5", "3.5.4.9"], @obj.eclinks)
    end

    def test_orthologs_as_strings
      expected = ["K01491  methylenetetrahydrofolate dehydrogenase (NADP+) / methenyltetrahydrofolate cyclohydrolase [EC:1.5.1.5 3.5.4.9]"]
      assert_equal(expected, @obj.orthologs_as_strings)
    end

    def test_pathway
      expected = "eco00630 Glyoxylate and dicarboxylate metabolism eco00670 One carbon pool by folate eco01100 Metabolic pathways"
      assert_equal(expected, @obj.pathway)
    end

    def test_pathways_as_strings
      expected = [ "eco00630  Glyoxylate and dicarboxylate metabolism",
                   "eco00670  One carbon pool by folate",
                   "eco01100  Metabolic pathways" ]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_position
      assert_equal("complement(556098..556964)", @obj.position)
    end

    def test_chromosome
      assert_equal(nil, @obj.chromosome)
    end

    def test_gbposition
      assert_equal("complement(556098..556964)", @obj.gbposition)
    end

    def test_locations
      expected = Bio::Locations.new("complement(556098..556964)")
      assert_equal(expected, @obj.locations)
    end

    def test_motifs_as_strings
      expected =
        [ "Pfam: THF_DHG_CYH_C THF_DHG_CYH Amidohydro_1",
          "PROSITE: THF_DHG_CYH_1 THF_DHG_CYH_2" ]
      assert_equal(expected, @obj.motifs_as_strings)
    end

    def test_motifs_as_hash
      expected = {
        "Pfam"    => ["THF_DHG_CYH_C", "THF_DHG_CYH", "Amidohydro_1"],
        "PROSITE" => ["THF_DHG_CYH_1", "THF_DHG_CYH_2"]
      }
      assert_equal(expected, @obj.motifs_as_hash)
      assert_equal(expected, @obj.motifs)
      assert_equal(expected, @obj.motif)
    end

    def test_dblinks_as_strings
      expected = [ "NCBI-GI: 16128513",
                   "NCBI-GeneID: 945221",
                   "RegulonDB: B0529",
                   "EcoGene: EG10328",
                   "ECOCYC: EG10328",
                   "UniProt: P24186" ]
      assert_equal(expected, @obj.dblinks_as_strings)
    end

    def test_structure
      assert_equal(["1B0A"], @obj.structure)
    end

    def test_codon_usage
      expected = {
        "gcg"=>nil,
        "gtc"=>nil,
        "cat"=>nil,
        "ctg"=>nil,
        "tac"=>nil,
        "gga"=>nil,
        "agg"=>nil,
        "aaa"=>nil,
        "acc"=>nil,
        "att"=>nil,
        "cca"=>nil,
        "tgt"=>nil,
        "tta"=>nil,
        "gag"=>nil,
        "gct"=>nil,
        "tcg"=>nil,
        "ggc"=>nil,
        "agt"=>nil,
        "aac"=>nil,
        "ata"=>nil,
        "cgg"=>nil,
        "caa"=>nil,
        "ccc"=>nil,
        "ctt"=>nil,
        "tga"=>nil,
        "ttc"=>nil,
        "gat"=>nil,
        "gtg"=>nil,
        "tag"=>nil,
        "gca"=>nil,
        "aga"=>nil,
        "acg"=>nil,
        "atc"=>nil,
        "cgt"=>nil,
        "cac"=>nil,
        "cta"=>nil,
        "tgc"=>nil,
        "tct"=>nil,
        "ggg"=>nil,
        "gaa"=>nil,
        "gcc"=>nil,
        "gtt"=>nil,
        "agc"=>nil,
        "aag"=>nil,
        "act"=>nil,
        "cga"=>nil,
        "ccg"=>nil,
        "ctc"=>nil,
        "tat"=>nil,
        "tca"=>nil,
        "ttg"=>nil,
        "ggt"=>nil,
        "gac"=>nil,
        "gta"=>nil,
        "aat"=>nil,
        "aca"=>nil,
        "atg"=>nil,
        "cgc"=>nil,
        "cag"=>nil,
        "cct"=>nil,
        "tgg"=>nil,
        "taa"=>nil,
        "tcc"=>nil,
        "ttt"=>nil }
      assert_equal(expected, @obj.codon_usage)
    end

    def test_cu_list
      assert_equal([], @obj.cu_list)
    end

    def test_aaseq
      expected = "MAAKIIDGKTIAQQVRSEVAQKVQARIAAGLRAPGLAVVLVGSNPASQIYVASKRKACEEVGFVSRSYDLPETTSEAELLELIDTLNADNTIDGILVQLPLPAGIDNVKVLERIHPDKDVDGFHPYNVGRLCQRAPRLRPCTPRGIVTLLERYNIDTFGLNAVVIGASNIVGRPMSMELLLAGCTTTVTHRFTKNLRHHVENADLLIVAVGKPGFIPGDWIKEGAIVIDVGINRLENGKVVGDVVFEDAAKRASYITPVPGGVGPMTVATLIENTLQACVEYHDPQDE"
      assert_equal(expected, @obj.aaseq)
    end

    def test_aalen
      assert_equal(288, @obj.aalen)
    end

    def test_ntseq
      expected = "atggcagcaaagattattgacggtaaaacgattgcgcagcaggtgcgctctgaagttgctcaaaaagttcaggcgcgtattgcagccggactgcgggcaccaggactggccgttgtgctggtgggtagtaaccctgcatcgcaaatttatgtcgcaagcaaacgcaaggcttgtgaagaagtcgggttcgtctcccgctcttatgacctcccggaaaccaccagcgaagcggagctgctggagcttatcgatacgctgaatgccgacaacaccatcgatggcattctggttcaactgccgttaccggcgggtattgataacgtcaaagtgctggaacgtattcatccggacaaagacgtggacggtttccatccttacaacgtcggtcgtctgtgccagcgcgcgccgcgtctgcgtccctgcaccccgcgcggtatcgtcacgctgcttgagcgttacaacattgataccttcggcctcaacgccgtggtgattggcgcatcgaatatcgttggccgcccgatgagcatggaactgctgctggcaggttgcaccactacagtgactcaccgcttcactaaaaatctgcgtcatcacgtagaaaatgccgatctattgatcgttgccgttggcaagccaggctttattcccggtgactggatcaaagaaggcgcaattgtgattgatgtcggcatcaaccgtctggaaaatggcaaagttgtgggcgacgtcgtgtttgaagacgcggctaaacgcgcctcatacattacgcctgttcccggcggcgttggcccgatgacggttgccacgctgattgaaaacacgctacaggcgtgcgttgaatatcatgatccacaggatgagtaa"
      assert_equal(expected, @obj.ntseq)
    end

    def test_ntlen
      assert_equal(867, @obj.ntlen)
    end

    def test_pathway_after_pathways_as_strings
      str = "eco00630 Glyoxylate and dicarboxylate metabolism eco00670 One carbon pool by folate eco01100 Metabolic pathways"
      strary = [ "eco00630  Glyoxylate and dicarboxylate metabolism",
                 "eco00670  One carbon pool by folate",
                 "eco01100  Metabolic pathways" ]
      2.times {
        assert_equal(str, @obj.pathway)
        assert_equal(strary, @obj.pathways_as_strings)
      }
    end

    def test_pathway_before_pathways_as_strings
      str = "eco00630 Glyoxylate and dicarboxylate metabolism eco00670 One carbon pool by folate eco01100 Metabolic pathways"
      strary = [ "eco00630  Glyoxylate and dicarboxylate metabolism",
                 "eco00670  One carbon pool by folate",
                 "eco01100  Metabolic pathways" ]
      2.times {
        assert_equal(strary, @obj.pathways_as_strings)
        assert_equal(str, @obj.pathway)
      }
    end

    def test_keggclass
      expected = "Metabolism; Carbohydrate Metabolism; Glyoxylate and dicarboxylate metabolism [PATH:eco00630] Metabolism; Metabolism of Cofactors and Vitamins; One carbon pool by folate [PATH:eco00670]"
      assert_equal(expected, @obj.keggclass)
    end

    def test_keggclasses
      expected =
        [ "Metabolism; Carbohydrate Metabolism; Glyoxylate and dicarboxylate metabolism",
          "Metabolism; Metabolism of Cofactors and Vitamins; One carbon pool by folate"
        ]
      assert_equal(expected, @obj.keggclasses)
    end

  end #class TestBioKEGGGENES_b0529
end #module Bio




