# frozen_string_literal: true
#
# test/unit/bio/db/embl/test_uniprotkb_P03589.rb - Unit tests for Bio::UniProtKB
#
# Copyright:::  Copyright (C) 2023 BioRuby Project <staff@bioruby.org>
# License::     The Ruby License
# Contributor:: 2005 Mitsuteru Nakao <n@bioruby.org>
#               2023 Naohisa Goto <ng@bioruby.org>
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/embl/uniprotkb'

module Bio
  class TestUniProtKB_P03589 < Test::Unit::TestCase

    def setup
      data = File.read(File.join(BioRubyTestDataPath, 
                                 'uniprot', 'P03589.uniprot'))
      @obj = Bio::UniProtKB.new(data)
    end

    def test_id_line
      assert(@obj.id_line)
    end

    def test_id_line_entry_name
      assert_equal('1A_AMVLE', @obj.id_line('ENTRY_NAME'))
    end

    def test_id_line_data_class
      assert_equal('Reviewed', @obj.id_line('DATA_CLASS'))
    end

    #def test_id_line_molecule_type
    #  assert_equal('PRT', @obj.id_line('MOLECULE_TYPE'))
    #end

    def test_id_line_sequence_length
      assert_equal(1126, @obj.id_line('SEQUENCE_LENGTH'))
    end

    def test_entry
      entry = '1A_AMVLE'
      assert_equal(entry, @obj.entry)
      assert_equal(entry, @obj.entry_name)
      assert_equal(entry, @obj.entry_id)
    end

    #def test_molecule
    #  assert_equal('PRT', @obj.molecule)
    #  assert_equal('PRT', @obj.molecule_type)
    #end

    def test_sequence_length
      seqlen = 1126
      assert_equal(seqlen, @obj.sequence_length)
      assert_equal(seqlen, @obj.aalen)
    end

    def test_ac
      acs = ["P03589"].freeze
      assert_equal(acs, @obj.ac)
      assert_equal(acs, @obj.accessions)
    end

    def test_accession
      assert_equal('P03589', @obj.accession)
    end

    def test_dr
      assert_equal(13, @obj.dr.size)
      assert_equal(8, @obj.dr['GO'].size)
      assert_equal([["IPR027351", "(+)RNA_virus_helicase_core_dom"],
                    ["IPR002588", "Alphavirus-like_MT_dom"],
                    ["IPR027417", "P-loop_NTPase"]],
                   @obj.dr['InterPro'])
    end

    def test_dr_with_key
      pfam = [{" "              => "1",
               "Version"        => "Viral_helicase1",
               "Accession"      => "PF01443",
               "Molecular Type" => nil
              },
              {" "              => "1",
               "Version"        => "Vmethyltransf",
               "Accession"      => "PF01660",
               "Molecular Type" => nil
              }].freeze
      assert_equal(pfam, @obj.dr('Pfam'))
      embl = [{"Accession"      => "L00163",
               "Version"        => "AAA46289.1",
               " "              => "-",
               "Molecular Type" => "Genomic_RNA"
              }].freeze
      assert_equal(embl, @obj.dr('EMBL'))
    end

    def test_dr_with_key_empty
      assert_equal([], @obj.dr('NOT_A_DATABASE'))
    end

    def test_dt
      assert(@obj.dt)
    end

    def test_dt_created
      assert_equal('21-JUL-1986, integrated into UniProtKB/Swiss-Prot.',
                   @obj.dt('created'))
    end

    def test_dt_sequence
      assert_equal('21-JUL-1986, sequence version 1.', 
                   @obj.dt('sequence'))
    end

    def test_dt_annotation
      assert_equal('22-FEB-2023, entry version 78.', 
                   @obj.dt('annotation'))
    end

    def test_de
      assert(@obj.de)
    end

    def test_protein_name
      assert_equal("Replication protein 1a",
                   @obj.protein_name)
    end

    def test_synonyms
      assert_equal([], @obj.synonyms)
    end

    def test_protein_name_after_calling_de
      assert(@obj.de)
      assert_equal("Replication protein 1a",
                   @obj.protein_name)
    end

    def test_gn
      assert_equal([{:orfs=>["ORF1a"], :synonyms=>[], :name=>"", :loci=>[]}], 
                   @obj.gn)
    end

    def test_gn_uniprot_parser
      assert_equal([{:orfs=>["ORF1a"], :loci=>[], :name=>"", :synonyms=>[]}], 
                   @obj.instance_eval("gn_uniprot_parser"))
    end

    def test_gn_old_parser
      assert_equal([["ORFNames=ORF1a;"]], 
                   @obj.instance_eval("gn_old_parser"))
    end

    def test_gene_names
      assert_equal([""], @obj.gene_names)
    end

    def test_gene_name
      assert_equal('', @obj.gene_name)
    end

    def test_os
      assert(@obj.os)
    end

    def test_os_access
      assert_equal("Alfalfa mosaic virus (strain 425 / isolate Leiden)",
                   @obj.os(0))
    end

    def test_os_access2
      assert_equal({"name"=>"(strain 425 / isolate Leiden)",
                    "os"=>"Alfalfa mosaic virus"}, @obj.os[0])
    end

    def test_oc
      assert_equal(["Viruses",
                    "Riboviria",
                    "Orthornavirae",
                    "Kitrinoviricota",
                    "Alsuviricetes",
                    "Martellivirales",
                    "Bromoviridae",
                    "Alfamovirus"],
                   @obj.oc)
    end

    def test_ox
      assert_equal({"NCBI_TaxID"=>["12322"]}, @obj.ox)
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
      keywords = ["ATP-binding",
                  "Helicase",
                  "Host endoplasmic reticulum",
                  "Host membrane",
                  "Hydrolase",
                  "Membrane",
                  "Methyltransferase",
                  "Nucleotide-binding",
                  "Reference proteome",
                  "Transferase"]
      assert_equal(keywords, @obj.kw)
    end

    def test_ft
      assert(@obj.ft)
      ft = {"CHAIN" => [
              {"From"=>1, "To"=>1126, "diff"=>[],
               "original"=>["CHAIN", "1", "1126",
                            [["note", "Replication protein 1a"],
                             ["id", "PRO_0000083254"]]],
               "note"=>"Replication protein 1a",
               "id"=>"PRO_0000083254",
               "FTId"=>"PRO_0000083254"}],
            "DOMAIN"=>
            [{"From"=>90, "To"=>278,"diff"=>[],
              "original"=>["DOMAIN", "90", "278",
                           [["note", "Alphavirus-like MT"],
                            ["evidence",
                             "ECO:0000255|PROSITE-ProRule:PRU01079"]]],
              "note"=>"Alphavirus-like MT",
              "evidence"=>"ECO:0000255|PROSITE-ProRule:PRU01079"},
             {"From"=>806, "To"=>963, "diff"=>[],
              "original"=>["DOMAIN", "806", "963",
                           [["note", "(+)RNA virus helicase ATP-binding"]]],
              "note"=>"(+)RNA virus helicase ATP-binding"},
             {"From"=>964, "To"=>1125, "diff"=>[],
              "original"=>["DOMAIN", "964", "1125",
                           [["note", "(+)RNA virus helicase C-terminal"]]],
              "note"=>"(+)RNA virus helicase C-terminal"}],
            "REGION"=>
            [{"From"=>69, "To"=>406, "diff"=>[],
              "original"=>["REGION", "69", "406",
                           [["note", "Methyltransferase"]]],
              "note"=>"Methyltransferase"},
             {"From"=>834, "To"=>1094, "diff"=>[],
              "original"=>["REGION", "834", "1094",
                           [["note", "ATP-dependent helicase"]]],
              "note"=>"ATP-dependent helicase"}],
            "BINDING"=>
            [{"From"=>838, "To"=>845, "diff"=>[],
              "original"=>["BINDING", "838", "845",
                           [["ligand", "ATP"],
                            ["ligand_id", "ChEBI:CHEBI:30616"],
                            ["evidence", "ECO:0000255"]]],
              "ligand"=>"ATP", "ligand_id"=>"ChEBI:CHEBI:30616",
              "evidence"=>"ECO:0000255"}]}
      assert_equal(ft, @obj.ft)
    end

    def test_sq
      assert_equal({"CRC64"=>"BF5A8019B47D4CBF", "aalen"=>1126, "MW"=>125828}, 
                   @obj.sq)
    end

    def test_sq_crc64
      assert_equal("BF5A8019B47D4CBF", @obj.sq('CRC64'))
    end

    def test_sq_mw
      mw = 125828
      assert_equal(mw, @obj.sq('mw'))
      assert_equal(mw, @obj.sq('molecular'))
      assert_equal(mw, @obj.sq('weight'))
    end

    def test_sq_len
      length = 1126
      assert_equal(length, @obj.sq('len'))
      assert_equal(length, @obj.sq('length'))
      assert_equal(length, @obj.sq('AA'))
    end

    def test_seq
      seq ="MNADAQSTDASLSMREPLSHASIQEMLRRVVEKQAADDTTAIGKVFSEAGRAYAQDALPS" +
           "DKGEVLKISFSLDATQQNILRANFPGRRTVFSNSSSSSHCFAAAHRLLETDFVYRCFGNT" +
           "VDSIIDLGGNFVSHMKVKRHNVHCCCPILDARDGARLTERILSLKSYVRKHPEIVGEADY" +
           "CMDTFQKCSRRADYAFAIHSTSDLDVGELACSLDQKGVMKFICTMMVDADMLIHNEGEIP" +
           "NFNVRWEIDRKKDLIHFDFIDEPNLGYSHRFSLLKHYLTYNAVDLGHAAYRIERKQDFGG" +
           "VMVIDLTYSLGFVPKMPHSNGRSCAWYNRVKGQMVVHTVNEGYYHHSYQTAVRRKVLVDK" +
           "KVLTRVTEVAFRQFRPNADAHSAIQSIATMLSSSTNHTIIGGVTLISGKPLSPDDYIPVA" +
           "TTIYYRVKKLYNAIPEMLSLLDKGERLSTDAVLKGSEGPMWYSGPTFLSALDKVNVPGDF" +
           "VAKALLSLPKRDLKSLFSRSATSHSERTPVRDESPIRCTDGVFYPIRMLLKCLGSDKFES" +
           "VTITDPRSNTETTVDLYQSFQKKIETVFSFILGKIDGPSPLISDPVYFQSLEDVYYAEWH" +
           "QGNAIDASNYARTLLDDIRKQKEESLKAKAKEVEDAQKLNRAILQVHAYLEAHPDGGKIE" +
           "GLGLSSQFIAKIPELAIPTPKPLPEFEKNAETGEILRINPHSDAILEAIDYLKSTSANSI" +
           "ITLNKLGDHCQWTTKGLDVVWAGDDKRRAFIPKKNTWVGPTARSYPLAKYERAMSKDGYV" +
           "TLRWDGEVLDANCVRSLSQYEIVFVDQSCVFASAEAIIPSLEKALGLEAHFSVTIVDGVA" +
           "GCGKTTNIKQIARSSGRDVDLILTSNRSSADELKETIDCSPLTKLHYIRTCDSYLMSASA" +
           "VKAQRLIFDECFLQHAGLVYAAATLAGCSEVIGFGDTEQIPFVSRNPSFVFRHHKLTGKV" +
           "ERKLITWRSPADATYCLEKYFYKNKKPVKTNSRVLRSIEVVPINSPVSVERNTNALYLCH" +
           "TQAEKAVLKAQTHLKGCDNIFTTHEAQGKTFDNVYFCRLTRTSTSLATGRDPINGPCNGL" +
           "VALSRHKKTFKYFTIAHDSDDVIYNACRDAGNTDDSILARSYNHNF"
      seq.freeze
      assert_equal(seq, @obj.seq)
      assert_equal(seq, @obj.aaseq)
    end

    def test_oh
      oh = [
        {"NCBI_TaxID"=>"4045", "HostName"=>"Apium graveolens (Celery)"},
        {"NCBI_TaxID"=>"83862",
         "HostName"=>"Astragalus glycyphyllos (Wild liquorice)"},
        {"NCBI_TaxID"=>"4072",
         "HostName"=>"Capsicum annuum (Capsicum pepper)"},
        {"NCBI_TaxID"=>"41386", "HostName"=>"Caryopteris incana"},
        {"NCBI_TaxID"=>"3827",
         "HostName"=>"Cicer arietinum (Chickpea) (Garbanzo)"},
        {"NCBI_TaxID"=>"3847",
         "HostName"=>"Glycine max (Soybean) (Glycine hispida)"},
        {"NCBI_TaxID"=>"35936",
         "HostName"=>"Lablab purpureus (Hyacinth bean) (Dolichos lablab)"},
        {"NCBI_TaxID"=>"4236",
         "HostName"=>"Lactuca sativa (Garden lettuce)"},
        {"NCBI_TaxID"=>"3864",
         "HostName"=>"Lens culinaris (Lentil) (Cicer lens)"},
        {"NCBI_TaxID"=>"3869", "HostName"=>"Lupinus"},
        {"NCBI_TaxID"=>"145753",
         "HostName"=>"Malva parviflora (Little mallow) (Cheeseweed mallow)"},
        {"NCBI_TaxID"=>"3879",
         "HostName"=>"Medicago sativa (Alfalfa)"},
        {"NCBI_TaxID"=>"4097",
         "HostName"=>"Nicotiana tabacum (Common tobacco)"},
        {"NCBI_TaxID"=>"3885",
         "HostName"=>"Phaseolus vulgaris (Kidney bean) (French bean)"},
        {"NCBI_TaxID"=>"23113", "HostName"=>"Philadelphus"},
        {"NCBI_TaxID"=>"3888", "HostName"=>"Pisum sativum (Garden pea)"},
        {"NCBI_TaxID"=>"4081",
         "HostName"=>
         "Solanum lycopersicum (Tomato) (Lycopersicon esculentum)"},
        {"NCBI_TaxID"=>"4113", "HostName"=>"Solanum tuberosum (Potato)"},
        {"NCBI_TaxID"=>"157662", "HostName"=>"Teramnus repens"},
        {"NCBI_TaxID"=>"60916",
         "HostName"=>"Trifolium incarnatum (Crimson clover)"},
        {"NCBI_TaxID"=>"85293",
         "HostName"=>"Viburnum opulus (High-bush cranberry)"},
        {"NCBI_TaxID"=>"3916",
         "HostName"=>
         "Vigna radiata var. radiata (Mung bean) (Phaseolus aureus)"},
        {"NCBI_TaxID"=>"3917", "HostName"=>"Vigna unguiculata (Cowpea)"}
      ]
      assert_equal(oh, @obj.oh)
    end

  end # class TestUniProtKB
end # module Bio

