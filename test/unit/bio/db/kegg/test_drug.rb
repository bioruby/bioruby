#
# test/unit/bio/db/kegg/test_drug.rb - Unit test for Bio::KEGG::DRUG
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
require 'bio/db/kegg/drug'

module Bio
  class TestBioKeggDRUG < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/D00063.drug')
      @obj = Bio::KEGG::DRUG.new(File.read(filename))
    end

    def test_dblinks_as_hash
      expected = {
        "ChEBI"=>["28864"],
        "PubChem"=>["7847131"],
        "NIKKAJI"=>["J4.533K"],
        "PDB-CCD"=>["TOY"],
        "DrugBank"=>["DB00684"],
        "LigandBox"=>["D00063"],
        "CAS"=>["32986-56-4"]
      }
      assert_equal(expected, @obj.dblinks_as_hash)
      assert_equal(expected, @obj.dblinks)
    end

    def test_pathways_as_hash
      expected = {"map07021"=>"Aminoglycosides"}
      assert_equal(expected, @obj.pathways_as_hash)
      assert_equal(expected, @obj.pathways)
    end

    def test_entry_id
      assert_equal("D00063", @obj.entry_id)
    end

    def test_names
      expected = [ "Tobramycin (JP15/USP)",
                   "TOB", "Tobracin (TN)", "Tobrex (TN)" ]
      assert_equal(expected, @obj.names)
    end

    def test_name
      expected = "Tobramycin (JP15/USP)"
      assert_equal(expected, @obj.name)
    end

    def test_formula
      assert_equal("C18H37N5O9", @obj.formula)
    end

    def test_mass
      assert_equal(467.2591, @obj.mass)
    end

    def test_activity
      expected = "Antibacterial"
      assert_equal(expected, @obj.activity)
    end

    def test_remark
      expected = "Same as: C00397 Therapeutic category: 1317 6123 ATC code: J01GB01 S01AA12"
      assert_equal(expected, @obj.remark)
    end

    def test_pathways_as_strings
      expected = [ "PATH: map07021  Aminoglycosides" ]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_dblinks_as_strings
      expected = [ "CAS: 32986-56-4",
                   "PubChem: 7847131",
                   "ChEBI: 28864",
                   "DrugBank: DB00684",
                   "PDB-CCD: TOY",
                   "LigandBox: D00063",
                   "NIKKAJI: J4.533K" ]
      assert_equal(expected, @obj.dblinks_as_strings)
    end

    def test_kcf
      expected = <<END_OF_EXPECTED_KCF
ATOM        32
            1   C1y C    20.6560  -20.0968
            2   C1y C    20.6560  -21.4973
            3   C1y C    21.8689  -22.1975
            4   C1y C    23.0818  -21.4973
            5   C1y C    23.0818  -20.0968
            6   O2x O    21.8689  -19.3965
            7   C1b C    19.4432  -19.3965
            8   O1a O    18.2473  -20.0872
            9   O1a O    19.4432  -22.1975
            10  N1a N    21.8689  -23.5978
            11  O1a O    24.3134  -22.2085
            12  O2a O    24.3134  -19.3855
            13  C1y C    25.4878  -18.6963
            14  C1y C    26.7056  -19.3879
            15  C1x C    27.9134  -18.6791
            16  C1y C    27.9035  -17.2786
            17  C1y C    26.6857  -16.5869
            18  C1y C    25.4779  -17.2958
            19  N1a N    26.7157  -20.7965
            20  N1a N    29.0779  -16.5893
            21  O1a O    24.2675  -16.6084
            22  O2a O    26.6757  -15.1950
            23  C1y C    27.8854  -14.4851
            24  O2x O    29.0946  -15.1718
            25  C1y C    30.3025  -14.4631
            26  C1y C    30.2926  -13.0626
            27  C1x C    29.0835  -12.3758
            28  C1y C    27.8755  -13.0846
            29  C1b C    31.5468  -15.1693
            30  N1a N    31.5569  -16.5953
            31  O1a O    31.5060  -12.3503
            32  N1a N    26.6567  -12.3923
BOND        34
            1     1   2 1
            2     2   3 1
            3     3   4 1
            4     4   5 1
            5     5   6 1
            6     1   6 1
            7     1   7 1 #Up
            8     7   8 1
            9     2   9 1 #Down
            10    3  10 1 #Up
            11    4  11 1 #Down
            12    5  12 1 #Down
            13   13  12 1 #Down
            14   13  14 1
            15   14  15 1
            16   15  16 1
            17   16  17 1
            18   17  18 1
            19   13  18 1
            20   14  19 1 #Up
            21   16  20 1 #Up
            22   18  21 1 #Up
            23   17  22 1 #Down
            24   23  22 1 #Down
            25   23  24 1
            26   24  25 1
            27   25  26 1
            28   26  27 1
            29   27  28 1
            30   23  28 1
            31   25  29 1 #Up
            32   29  30 1
            33   26  31 1 #Down
            34   28  32 1 #Down
END_OF_EXPECTED_KCF
      assert_equal(expected, @obj.kcf)
    end

    def test_comment
      expected = "natural product"
      assert_equal(expected, @obj.comment)
    end

    def test_products
      expected =
        [
         "TOBI (Novartis Pharma) 94F9E516-6BF6-4E30-8DDE-8833C25C2560",
         "TOBRAMYCIN (Bristol-Myers Squibb) 7305F9BB-622B-43C0-981A-56E2F226CFD7",
         "TOBRAMYCIN (Hospira) C5A005B0-7B6F-4E30-DF92-9A20B1CA66A1",
         "Tobramycin (Akorn-Strides) 49151A62-191A-4BA8-8B8C-BD8535F2FDB3",
         "Tobramycin (Bausch and Lomb) A5693EC9-D2F7-4D45-90B0-A113C54840D7",
         "Tobramycin (Falcon Pharma) 27E2C16E-19B0-4745-93EB-5CF99F94BB92",
         "Tobramycin (Hospira) 4E115874-3637-4AED-B6AF-77D53A850208",
         "Tobramycin (Hospira) EB02166C-18F6-4BE0-F493-AC89D65DA759",
         "Tobramycin (X-Gen Pharma) A384641C-04E3-4AB5-B152-7408CD07B64D",
         "Tobramycin in Sodium Chloride (Hospira) EE907146-E4A8-4578-A9B0-C8E9790E3D55",
         "Tobrex (Alcon Lab) 4B8716C4-0FFD-49AA-9006-A3BF5B6D19A6",
         "Tobrex (Alcon Lab) CDD423C5-A231-47D4-BF51-00B5C29E6A60"
        ]
      assert_equal(expected, @obj.products)
    end

  end #class TestBioKeggDRUG
end #module Bio

