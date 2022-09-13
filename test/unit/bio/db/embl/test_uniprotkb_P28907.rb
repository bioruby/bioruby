# frozen_string_literal: true
#
# test/unit/bio/db/embl/test_uniprotkb_P28907.rb - Unit tests for Bio::UniProtKB
#
# Copyright:::  Copyright (C) 2022 BioRuby Project <staff@bioruby.org>
# License::     The Ruby License
# Contributor:: 2005 Mitsuteru Nakao <n@bioruby.org>
#               2022 Naohisa Goto <ng@bioruby.org>
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/embl/uniprotkb'

module Bio
  class TestUniProtKB_P28907 < Test::Unit::TestCase

    def setup
      data = File.read(File.join(BioRubyTestDataPath, 
                                 'uniprot', 'P28907.uniprot'))
      @obj = Bio::UniProtKB.new(data)
    end

    def test_id_line
      assert(@obj.id_line)
    end

    def test_id_line_entry_name
      assert_equal('CD38_HUMAN', @obj.id_line('ENTRY_NAME'))
    end   

    def test_id_line_data_class
      assert_equal('Reviewed', @obj.id_line('DATA_CLASS'))
    end

    #def test_id_line_molecule_type
    #  assert_equal('PRT', @obj.id_line('MOLECULE_TYPE'))
    #end

    def test_id_line_sequence_length
      assert_equal(300, @obj.id_line('SEQUENCE_LENGTH'))
    end

    def test_entry
      entry = 'CD38_HUMAN'
      assert_equal(entry, @obj.entry)
      assert_equal(entry, @obj.entry_name)
      assert_equal(entry, @obj.entry_id)
    end

    #def test_molecule
    #  assert_equal('PRT', @obj.molecule)
    #  assert_equal('PRT', @obj.molecule_type)
    #end

    def test_sequence_length
      seqlen = 300
      assert_equal(seqlen, @obj.sequence_length)
      assert_equal(seqlen, @obj.aalen)
    end

    def test_ac
      acs = ["P28907", "O00121", "O00122", "Q96HY4"].freeze
      assert_equal(acs, @obj.ac)
      assert_equal(acs, @obj.accessions)
    end

    def test_accession
      assert_equal('P28907', @obj.accession)
    end

    def test_dr
      assert_equal(81, @obj.dr.size)
      assert_equal(39, @obj.dr['GO'].size)
      assert_equal([["IPR003193", "ADP-ribosyl_cyclase"],
                    ["IPR033567", "CD38"]],
                   @obj.dr['InterPro'])
    end

    def test_dr_with_key
      pfam = [{" "              => "1",
               "Version"        => "Rib_hydrolayse",
               "Accession"      => "PF02267",
               "Molecular Type" => nil
              }].freeze
      assert_equal(pfam, @obj.dr('Pfam'))
      embl = [{"Accession"      => "M34461",
               "Version"        => "AAA68482.1",
               " "              => "-",
               "Molecular Type" => "mRNA"},
              {"Accession"      => "D84276",
               "Version"        => "BAA18964.1",
               " "              => "-",
               "Molecular Type" => "mRNA"},
              {"Accession"      => "D84277",
               "Version"        => "BAA18965.1",
               " "              => "-",
               "Molecular Type" => "mRNA"},
              {"Accession"      => "D84284",
               "Version"        => "BAA18966.1",
               " "              => "-",
               "Molecular Type" => "Genomic_DNA"},
              {"Accession"      => "BC007964",
               "Version"        => "AAH07964.1",
               " "              => "-",
               "Molecular Type" => "mRNA"}].freeze
      assert_equal(embl, @obj.dr('EMBL'))
    end

    def test_dr_with_key_empty
      assert_equal([], @obj.dr('NOT_A_DATABASE'))
    end

    def test_dt
      assert(@obj.dt)
    end

    def test_dt_created
      assert_equal('01-DEC-1992, integrated into UniProtKB/Swiss-Prot.',
                   @obj.dt('created'))
    end

    def test_dt_sequence
      assert_equal('23-NOV-2004, sequence version 2.', 
                   @obj.dt('sequence'))
    end

    def test_dt_annotation
      assert_equal('03-AUG-2022, entry version 213.', 
                   @obj.dt('annotation'))
    end

    def test_de
      assert(@obj.de)
    end

    def test_protein_name
      assert_equal("ADP-ribosyl cyclase/cyclic ADP-ribose hydrolase 1",
                   @obj.protein_name)
    end

    def test_synonyms
      ary = [
        "EC 3.2.2.6",
        "2'-phospho-ADP-ribosyl cyclase",
        "2'-phospho-ADP-ribosyl cyclase/2'-phospho-cyclic-ADP-ribose transferase",
        "EC 2.4.99.20",
        "2'-phospho-cyclic-ADP-ribose transferase",
        "ADP-ribosyl cyclase 1",
        "ADPRC 1",
        "Cyclic ADP-ribose hydrolase 1",
        "cADPr hydrolase 1",
        "T10",
        "CD_antigen=CD38"
      ].freeze
      assert_equal(ary, @obj.synonyms)
    end

    def test_protein_name_after_calling_de
      assert(@obj.de)
      assert_equal("ADP-ribosyl cyclase/cyclic ADP-ribose hydrolase 1",
                   @obj.protein_name)
    end

    def test_synonyms_after_calling_de
      assert(@obj.de)
      assert_equal(11, @obj.synonyms.size)
    end

    def test_gn
      assert_equal([{:orfs=>[], :synonyms=>[], :name=>"CD38", :loci=>[]}], 
                   @obj.gn)
    end

    def test_gn_uniprot_parser
      assert_equal([{:orfs=>[], :loci=>[], :name=>"CD38", :synonyms=>[]}], 
                   @obj.instance_eval("gn_uniprot_parser"))
    end

    def test_gn_old_parser
      assert_equal([["Name=CD38;"]], 
                   @obj.instance_eval("gn_old_parser"))
    end

    def test_gene_names
      assert_equal(["CD38"], @obj.gene_names)
    end

    def test_gene_name
      assert_equal('CD38', @obj.gene_name)
    end

    def test_os
      assert(@obj.os)
    end

    def test_os_access
      assert_equal("Homo sapiens (Human)", @obj.os(0))
    end

    def test_os_access2
      assert_equal({"name"=>"(Human)", "os"=>"Homo sapiens"}, @obj.os[0])
    end

    def test_oc
      assert_equal(["Eukaryota", "Metazoa", "Chordata", "Craniata",
                    "Vertebrata", "Euteleostomi", "Mammalia", "Eutheria",
                    "Euarchontoglires", "Primates",
                    "Haplorrhini", "Catarrhini", "Hominidae", "Homo"],
                   @obj.oc)
    end

    def test_ox
      assert_equal({"NCBI_TaxID"=>["9606"]}, @obj.ox)
    end

    def test_ref # Bio::UniProtKB#ref
      assert_equal(Array, @obj.ref.class)
    end

    def test_cc
      assert_equal(Hash, @obj.cc.class)
    end
   
    def test_cc_database
      assert_equal(nil, @obj.cc('DATABASE'))
    end

    def test_cc_alternative_products
      ap = { "Event"=>["Alternative splicing"],
             "Named isoforms"=>"2",
             "Comment"=>"",
             "Variants"=>
             [{"Name"=>"1",
               "Synonyms"=>[],
               "IsoId"=>["P28907-1"],
               "Sequence"=>["Displayed"]},
              {"Name"=>"2",
               "Synonyms"=>[],
               "IsoId"=>["P28907-2"],
               "Sequence"=>["VSP_000707", "VSP_000708"]}]}
      assert_equal(ap, @obj.cc('ALTERNATIVE PRODUCTS'))
    end

    def test_cc_mass_spectrometry
      assert_equal(nil, @obj.cc('MASS SPECTROMETRY'))
    end


    def test_kw
      keywords = ["3D-structure", "Alternative splicing",
                  "Diabetes mellitus", "Disulfide bond",
                  "Glycoprotein", "Hydrolase", "Membrane",
                  "NAD", "NADP", "Receptor", "Reference proteome",
                  "Signal-anchor", "Transferase", "Transmembrane",
                  "Transmembrane helix"]
      assert_equal(keywords, @obj.kw)
    end
    
    def test_ft
      assert(@obj.ft)
      name = 'TOPO_DOM'
      data = [{"From"=>1,
               "To"=>21,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "1",
                "21",
                [["note", "Cytoplasmic"],
                 ["evidence", "ECO:0000255"]]],
               "note"=>"Cytoplasmic",
               "evidence"=>"ECO:0000255"},
              {"From"=>43,
               "To"=>300,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "43",
                "300",
                [["note", "Extracellular"],
                 ["evidence", "ECO:0000255"]]],
               "note"=>"Extracellular",
               "evidence"=>"ECO:0000255"}].freeze

      assert_equal(data, @obj.ft[name])
    end

    def test_sq
      assert_equal({"CRC64"=>"47BBE38C3DE3E6AA", "aalen"=>300, "MW"=>34328}, 
                   @obj.sq)
    end

    def test_sq_crc64
      assert_equal("47BBE38C3DE3E6AA", @obj.sq('CRC64'))
    end

    def test_sq_mw
      mw = 34328
      assert_equal(mw, @obj.sq('mw'))
      assert_equal(mw, @obj.sq('molecular'))
      assert_equal(mw, @obj.sq('weight'))
    end

    def test_sq_len
      length = 300
      assert_equal(length, @obj.sq('len'))
      assert_equal(length, @obj.sq('length'))
      assert_equal(length, @obj.sq('AA'))
    end

    def test_seq
      seq = "MANCEFSPVSGDKPCCRLSRRAQLCLGVSILVLILVVVLAVVVPRWRQQWSGPGTTKRFPETVLARCVKYTEIHPEMRHVDCQSVWDAFKGAFISKHPCNITEEDYQPLMKLGTQTVPCNKILLWSRIKDLAHQFTQVQRDMFTLEDTLLGYLADDLTWCGEFNTSKINYQSCPDWRKDCSNNPVSVFWKTVSRRFAEAACDVVHVMLNGSRSKIFDKNSTFGSVEVHNLQPEKVQTLEAWVIHGGREDSRDLCQDPTIKELESIISKRNIQFSCKNIYRPDKFLQCVKNPEDSSCTSEI"
      assert_equal(seq, @obj.seq)
      assert_equal(seq, @obj.aaseq)
    end

  end # class TestUniProtKB
end # module Bio

