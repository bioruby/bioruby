# frozen_string_literal: true
#
# test/unit/bio/db/embl/test_uniprotkb_P49144.rb - Unit tests for Bio::UniProtKB
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
  class TestUniProtKB_P49144 < Test::Unit::TestCase

    def setup
      data = File.read(File.join(BioRubyTestDataPath, 
                                 'uniprot', 'P49144.uniprot'))
      @obj = Bio::UniProtKB.new(data)
    end

    def test_id_line
      assert(@obj.id_line)
    end

    def test_id_line_entry_name
      assert_equal('5HT1B_RABIT', @obj.id_line('ENTRY_NAME'))
    end   

    def test_id_line_data_class
      assert_equal('Reviewed', @obj.id_line('DATA_CLASS'))
    end

    #def test_id_line_molecule_type
    #  assert_equal('PRT', @obj.id_line('MOLECULE_TYPE'))
    #end

    def test_id_line_sequence_length
      assert_equal(390, @obj.id_line('SEQUENCE_LENGTH'))
    end

    def test_entry
      entry = '5HT1B_RABIT'
      assert_equal(entry, @obj.entry)
      assert_equal(entry, @obj.entry_name)
      assert_equal(entry, @obj.entry_id)
    end

    #def test_molecule
    #  assert_equal('PRT', @obj.molecule)
    #  assert_equal('PRT', @obj.molecule_type)
    #end

    def test_sequence_length
      seqlen = 390
      assert_equal(seqlen, @obj.sequence_length)
      assert_equal(seqlen, @obj.aalen)
    end

    def test_ac
      acs = ["P49144"].freeze
      assert_equal(acs, @obj.ac)
      assert_equal(acs, @obj.accessions)
    end

    def test_accession
      assert_equal('P49144', @obj.accession)
    end

    def test_dr
      assert_equal(28, @obj.dr.size)
      assert_equal(12, @obj.dr['GO'].size)
      assert_equal([["IPR002147", "5HT1B_rcpt"],
                    ["IPR002231", "5HT_rcpt"],
                    ["IPR000276", "GPCR_Rhodpsn"],
                    ["IPR017452", "GPCR_Rhodpsn_7TM"]],
                   @obj.dr['InterPro'])
    end

    def test_dr_with_key
      pfam = [{"Accession"      => "PF00001",
               "Version"        => "7tm_1",
               " "              => "1",
               "Molecular Type" => nil}
             ].freeze
      assert_equal(pfam, @obj.dr('Pfam'))
      embl = [{"Accession"      => "Z50163",
               "Version"        => "CAA90531.1",
               " "              => "-",
               "Molecular Type" => "Genomic_DNA"},
              {"Accession"      => "X89731",
               "Version"        => "CAA61883.1",
               " "              => "-",
               "Molecular Type" => "mRNA"},
              {"Accession"      => "U60826",
               "Version"        => "AAB58467.1",
               " "              => "-",
               "Molecular Type" => "Genomic_DNA"}
             ].freeze
      assert_equal(embl, @obj.dr('EMBL'))
    end

    def test_dr_with_key_empty
      assert_equal([], @obj.dr('NOT_A_DATABASE'))
    end

    def test_dt
      assert(@obj.dt)
    end

    def test_dt_created
      assert_equal('01-FEB-1996, integrated into UniProtKB/Swiss-Prot.',
                   @obj.dt('created'))
    end

    def test_dt_sequence
      assert_equal('01-FEB-1996, sequence version 1.', 
                   @obj.dt('sequence'))
    end

    def test_dt_annotation
      assert_equal('22-FEB-2023, entry version 127.',
                   @obj.dt('annotation'))
    end

    def test_de
      assert(@obj.de)
    end

    def test_protein_name
      assert_equal("5-hydroxytryptamine receptor 1B",
                   @obj.protein_name)
    end

    def test_synonyms
      ary = [
        "5-HT-1B",
        "5-HT1B",
        "Serotonin 1D beta receptor",
        "5-HT-1D-beta",
        "Serotonin receptor 1B"
      ].freeze
      assert_equal(ary, @obj.synonyms)
    end

    def test_protein_name_after_calling_de
      assert(@obj.de)
      assert_equal("5-hydroxytryptamine receptor 1B",
                   @obj.protein_name)
    end

    def test_synonyms_after_calling_de
      assert(@obj.de)
      assert_equal(5, @obj.synonyms.size)
    end

    def test_gn
      assert_equal([{:orfs=>[], :synonyms=>[], :name=>"HTR1B", :loci=>[]}], 
                   @obj.gn)
    end

    def test_gn_uniprot_parser
      assert_equal([{:orfs=>[], :loci=>[], :name=>"HTR1B", :synonyms=>[]}], 
                   @obj.instance_eval("gn_uniprot_parser"))
    end

    def test_gn_old_parser
      assert_equal([["Name=HTR1B;"]], 
                   @obj.instance_eval("gn_old_parser"))
    end

    def test_gene_names
      assert_equal(["HTR1B"], @obj.gene_names)
    end

    def test_gene_name
      assert_equal('HTR1B', @obj.gene_name)
    end

    def test_os
      assert(@obj.os)
    end

    def test_os_access
      assert_equal("Oryctolagus cuniculus (Rabbit)", @obj.os(0))
    end

    def test_os_access2
      assert_equal({"name"=>"(Rabbit)", "os"=>"Oryctolagus cuniculus"},
                   @obj.os[0])
    end

    def test_oc
      assert_equal(["Eukaryota", "Metazoa", "Chordata", "Craniata",
                    "Vertebrata", "Euteleostomi", "Mammalia", "Eutheria",
                    "Euarchontoglires", "Glires", "Lagomorpha",
                    "Leporidae", "Oryctolagus"],
                   @obj.oc)
    end

    def test_ox
      assert_equal({"NCBI_TaxID"=>["9986"]}, @obj.ox)
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
      assert_equal(nil, @obj.cc('ALTERNATIVE PRODUCTS'))
    end

    def test_cc_mass_spectrometry
      assert_equal(nil, @obj.cc('MASS SPECTROMETRY'))
    end


    def test_kw
      keywords = [ "Behavior", "Cell membrane", "Disulfide bond",
                   "G-protein coupled receptor", "Glycoprotein",
                   "Lipoprotein", "Membrane", "Palmitate",
                   "Phosphoprotein", "Receptor", "Reference proteome",
                   "Transducer", "Transmembrane", "Transmembrane helix" ]
      assert_equal(keywords, @obj.kw)
    end
    
    def test_ft
      assert(@obj.ft)
      name = 'TOPO_DOM'
      data = [{"From"=>1,
               "To"=>49,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "1",
                "49",
                [["note", "Extracellular"], ["evidence", "ECO:0000250"]]],
               "note"=>"Extracellular",
               "evidence"=>"ECO:0000250"},
              {"From"=>76,
               "To"=>84,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "76",
                "84",
                [["note", "Cytoplasmic"], ["evidence", "ECO:0000250"]]],
               "note"=>"Cytoplasmic",
               "evidence"=>"ECO:0000250"},
              {"From"=>111,
               "To"=>123,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "111",
                "123",
                [["note", "Extracellular"], ["evidence", "ECO:0000250"]]],
               "note"=>"Extracellular",
               "evidence"=>"ECO:0000250"},
              {"From"=>146,
               "To"=>165,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "146",
                "165",
                [["note", "Cytoplasmic"], ["evidence", "ECO:0000250"]]],
               "note"=>"Cytoplasmic",
               "evidence"=>"ECO:0000250"},
              {"From"=>188,
               "To"=>205,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "188",
                "205",
                [["note", "Extracellular"], ["evidence", "ECO:0000250"]]],
               "note"=>"Extracellular",
               "evidence"=>"ECO:0000250"},
              {"From"=>229,
               "To"=>315,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "229",
                "315",
                [["note", "Cytoplasmic"], ["evidence", "ECO:0000250"]]],
               "note"=>"Cytoplasmic",
               "evidence"=>"ECO:0000250"},
              {"From"=>337,
               "To"=>349,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "337",
                "349",
                [["note", "Extracellular"], ["evidence", "ECO:0000250"]]],
               "note"=>"Extracellular",
               "evidence"=>"ECO:0000250"},
              {"From"=>372,
               "To"=>390,
               "diff"=>[],
               "original"=>
               ["TOPO_DOM",
                "372",
                "390",
                [["note", "Cytoplasmic"], ["evidence", "ECO:0000250"]]],
               "note"=>"Cytoplasmic",
               "evidence"=>"ECO:0000250"}].freeze
      assert_equal(data, @obj.ft[name])
    end

    def test_sq
      assert_equal({"CRC64"=>"C22EBC077C6C897D", "aalen"=>390, "MW"=>43496}, 
                   @obj.sq)
    end

    def test_sq_crc64
      assert_equal("C22EBC077C6C897D", @obj.sq('CRC64'))
    end

    def test_sq_mw
      mw = 43496
      assert_equal(mw, @obj.sq('mw'))
      assert_equal(mw, @obj.sq('molecular'))
      assert_equal(mw, @obj.sq('weight'))
    end

    def test_sq_len
      length = 390
      assert_equal(length, @obj.sq('len'))
      assert_equal(length, @obj.sq('length'))
      assert_equal(length, @obj.sq('AA'))
    end

    def test_seq
      seq = "MEEPGAQCAPPLAAGSQIAVPQANLSAAHSHNCSAEGYIYQDSIALPWKVLLVLLLALFTLATTLSNAFVVATVYRTRKLHTPANYLIASLAVTDLLVSILVMPISTMYTVTGRWTLGQVVCDLWLSSDITCCTASIMHLCVIALDRYWAITDAVEYSAKRTPKRAAIMIRLVWVFSICISLPPFFWRQAKAEEEVSECLVNTDHVLYTVYSTVGAFYLPTLLLIALYGRIYVEARSRILKQTPNRTGKRLTRAQLITDSPGSTTSVTSINSRAPDVPSESGSPVYVNQVKVRVSDALLEKKKLMAARERKATKTLGIILGVFIVCWLPFFIISLVMPICKDACWFHQAIFDFFTWLGYVNSLINPIIYTMSNEDFKQAFHKLIRFKCTS"
      assert_equal(seq, @obj.seq)
      assert_equal(seq, @obj.aaseq)
    end

  end # class TestUniProtKB_P49144
end # module Bio

