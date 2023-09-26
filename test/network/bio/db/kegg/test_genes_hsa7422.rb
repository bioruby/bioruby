#
# test/network/bio/db/kegg/test_genes_hsa7422.rb - Unit test for Bio::KEGG::GENES
#
# Copyright::  Copyright (C) 2019 BioRuby Project <staff@bioruby.org>
# License::    The Ruby License
# Contributor:: kojix2 <2xijok@gmail.com>
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/genes'
require 'bio/io/togows'

module Bio

  # This test is moved from test/unit/bio/db/kegg/test_genes.rb
  # and modified to get sample data from the internet
  # because of KEGG data license issue.
  #
  # Note that this test may fail due to the data entry updates in KEGG.
  class TestBioKEGGGENES_hsa7422 < Test::Unit::TestCase

    str = Bio::TogoWS::REST.entry("kegg-genes", "hsa:7422")
    DATA = str.freeze

    def setup
      #filename = File.join(BioRubyTestDataPath, 'KEGG/hsa7422.gene')
      @obj = Bio::KEGG::GENES.new(DATA)
    end

    def test_diseases_as_strings
      expected = ["H01456  Diabetic nephropathy",
                  "H01457  Diabetic retinopathy",
                  "H01459  Diabetic neuropathy",
                  "H01529  Avascular necrosis of femoral head",
                  "H01709  Glucocorticoid-induced osteonecrosis",
                  "H02559  Microvascular complications of diabetes"]

      assert_equal(expected, @obj.diseases_as_strings)
    end

    def test_diseases_as_hash
      expected = {"H01456"=>"Diabetic nephropathy",
                  "H01457"=>"Diabetic retinopathy",
                  "H01459"=>"Diabetic neuropathy",
                  "H01529"=>"Avascular necrosis of femoral head",
                  "H01709"=>"Glucocorticoid-induced osteonecrosis",
                  "H02559"=>"Microvascular complications of diabetes"}
      assert_equal(expected, @obj.diseases_as_hash)
    end

    def test_drug_targets_as_strings
      expected = ["Abicipar pegol: D11517",
                  "Aflibercept: D09574<JP/US>",
                  "Aflibercept beta: D10819<JP>",
                  "Bevacizumab: D06409<JP/US>",
                  "Bevasiranib sodium: D08874",
                  "Brolucizumab: D11083<JP/US>",
                  "Dilpacimab: D11642",
                  "Emvododstat: D11890",
                  "Faricimab: D11516<JP/US>",
                  "Navicixizumab: D11126",
                  "Pegaptanib: D05386",
                  "Ranibizumab: D05697<JP/US>",
                  "Tarcocimab: D12507",
                  "Tarcocimab tedromer: D12508",
                  "Vanucizumab: D11244"]
      assert_equal(expected, @obj.drug_targets_as_strings)
    end

    def test_networks_as_strings
      expected = ["nt06124  Chemokine signaling (viruses)",
                  "nt06164  Kaposi sarcoma-associated herpesvirus (KSHV)",
                  "nt06219  JAK-STAT signaling",
                  "nt06224  CXCR signaling",
                  "nt06225  HIF-1 signaling",
                  "nt06227  Nuclear receptor signaling",
                  "nt06262  Pancreatic cancer",
                  "nt06264  Renal cell carcinoma",
                  "nt06360  Cushing syndrome",
                  "nt06526  MAPK signaling",
                  "nt06528  Calcium signaling",
                  "nt06530  PI3K signaling",
                  "N00079  HIF-1 signaling pathway",
                  "N00080  Loss of VHL to HIF-1 signaling pathway",
                  "N00081  Mutation-inactivated VHL to HIF-1 signaling pathway",
                  "N00095  ERBB2-overexpression to EGF-Jak-STAT signaling pathway",
                  "N00157  KSHV vGPCR to GNB/G-ERK signaling pathway",
                  "N00317  AhR signaling pathway",
                  "N01412  Metals to HTF-1 signaling pathway",
                  "N01592  GF-RTK-RAS-ERK signaling pathway",
                  "N01641  RTK-PLCG-ITPR signaling pathway",
                  "N01656  GF-RTK-PI3K signaling pathway",
                  "N01658  GF-RTK-RAS-PI3K signaling pathway"]
      assert_equal(expected, @obj.networks_as_strings)
    end

  end #class TestBioKEGGGENES_hsa7422

end #module Bio
