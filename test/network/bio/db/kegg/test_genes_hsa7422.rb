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
                  "H01709  Glucocorticoid-induced osteonecrosis"]

      assert_equal(expected, @obj.diseases_as_strings)
    end

    def test_diseases_as_hash
      expected = {"H01456"=>"Diabetic nephropathy",
                  "H01457"=>"Diabetic retinopathy",
                  "H01459"=>"Diabetic neuropathy",
                  "H01529"=>"Avascular necrosis of femoral head",
                  "H01709"=>"Glucocorticoid-induced osteonecrosis"}
      assert_equal(expected, @obj.diseases_as_hash)
    end

    def test_drug_targets_as_strings
      expected = ["Abicipar pegol: D11517",
                  "Aflibercept: D09574",
                  "Aflibercept beta: D10819",
                  "Bevacizumab: D06409",
                  "Bevasiranib sodium: D08874",
                  "Brolucizumab: D11083",
                  "Faricimab: D11516",
                  "Navicixizumab: D11126",
                  "Pegaptanib: D05386",
                  "Ranibizumab: D05697",
                  "Vanucizumab: D11244"]
      assert_equal(expected, @obj.drug_targets_as_strings)
    end

    def test_networks_as_strings
      expected = ["nt06114  PI3K signaling (virus)",
                  "nt06124  Chemokine signaling (virus)",
                  "nt06164  Kaposi sarcoma-associated herpesvirus (KSHV)",
                  "nt06214  PI3K signaling",
                  "nt06219  JAK-STAT signaling",
                  "nt06224  CXCR signaling",
                  "nt06225  HIF-1 signaling",
                  "nt06262  Pancreatic cancer",
                  "nt06264  Renal cell carcinoma",
                  "N00079  HIF-1 signaling pathway",
                  "N00080  Loss of VHL to HIF-1 signaling pathway",
                  "N00081  Mutation-inactivated VHL to HIF-1 signaling pathway",
                  "N00095  ERBB2-overexpression to EGF-Jak-STAT signaling pathway",
                  "N00157  KSHV vGPCR to GNB/G-ERK signaling pathway",
                  "N00179  KSHV K1 to PI3K-NFKB signaling pathway"]
      assert_equal(expected, @obj.networks_as_strings)
    end

  end #class TestBioKEGGGENES_hsa7422

end #module Bio
