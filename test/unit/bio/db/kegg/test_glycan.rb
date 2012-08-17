#
# test/unit/bio/db/kegg/test_glycan.rb - Unit test for Bio::KEGG::GLYCAN
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
require 'bio/db/kegg/glycan'

module Bio

  class TestBioKeggGLYCAN < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/G00024.glycan')
      @obj = Bio::KEGG::GLYCAN.new(File.read(filename))
    end

    def test_dblinks_as_hash
      expected = {
        "JCGGDB"=>["JCGG-STR025711"],
        "GlycomeDB"=>["475"],
        "CCSD" =>
        %w( 98 99 100 2225 2236 2237 2238 2239 2240 2241 2242 2243 3406
            5035 5038 5887 14321 18613 25363 27572 28182 29046 29092 29175
            29393 29521 29554 30734 30735 30848 30849 30850 30917 32646
            33022 33851 33878 33952 34823 34829 34986 34995 35029 35050
            35107 35108 35805 35833 35991 36236 36826 36863 37982 38587
            38640 38672 42797 43915 44029 44775 45346 46438 46466 47186
            48015 48891 49283 49293 50466 50469 50477 )
      }
      assert_equal(expected, @obj.dblinks_as_hash)
      assert_equal(expected, @obj.dblinks)
    end

    def test_pathways_as_hash
      expected = {
        "ko01100" => "Metabolic pathways",
        "ko00512" => "O-Glycan biosynthesis"
      }
      assert_equal(expected, @obj.pathways_as_hash)
      assert_equal(expected, @obj.pathways)
    end

    def test_orthologs_as_hash
      expected = {
        "K00780" => "beta-galactoside alpha-2,3-sialyltransferase (sialyltransferase 4A) [EC:2.4.99.4]",
        "K00727" => "beta-1,3-galactosyl-O-glycosyl-glycoprotein beta-1,6-N-acetylglucosaminyltransferase [EC:2.4.1.102]",
        "K03368" => "beta-galactoside alpha-2,3-sialyltransferase (sialyltransferase 4B) [EC:2.4.99.4]",
        "K00731" => "glycoprotein-N-acetylgalactosamine 3-beta-galactosyltransferase [EC:2.4.1.122]"
      }
      assert_equal(expected, @obj.orthologs_as_hash)
      assert_equal(expected, @obj.orthologs)
    end

    def test_entry_id
      assert_equal("G00024", @obj.entry_id)
    end

    def test_name
      assert_equal("T antigen", @obj.name)
    end

    def test_composition
      expected = {"Ser/Thr"=>1, "Gal"=>1, "GalNAc"=>1}
      assert_equal(expected, @obj.composition)
    end

    def test_mass
      assert_equal(365.3, @obj.mass)
    end

    def test_keggclass
      expected = "Glycoprotein; O-Glycan Neoglycoconjugate"
      assert_equal(expected, @obj.keggclass)
    end

    def test_compounds
      assert_equal([], @obj.compounds)
    end

    def test_reactions
      expected = ["R05908", "R05912", "R05913", "R06140"]
      assert_equal(expected, @obj.reactions)
    end

    def test_pathways_as_strings
      expected = [ "PATH: ko00512  O-Glycan biosynthesis",
                   "PATH: ko01100  Metabolic pathways" ]
      assert_equal(expected, @obj.pathways_as_strings)
    end

    def test_enzymes
      expected = ["2.4.1.102", "2.4.1.122", "2.4.99.4", "3.2.1.97"]
      assert_equal(expected, @obj.enzymes)
    end

    def test_orthologs_as_strings
      expected =
        [ "KO: K00727  beta-1,3-galactosyl-O-glycosyl-glycoprotein beta-1,6-N-acetylglucosaminyltransferase [EC:2.4.1.102]",
          "KO: K00731  glycoprotein-N-acetylgalactosamine 3-beta-galactosyltransferase [EC:2.4.1.122]",
          "KO: K00780  beta-galactoside alpha-2,3-sialyltransferase (sialyltransferase 4A) [EC:2.4.99.4]",
          "KO: K03368  beta-galactoside alpha-2,3-sialyltransferase (sialyltransferase 4B) [EC:2.4.99.4]"
        ]
      assert_equal(expected, @obj.orthologs_as_strings)
    end

    def test_comment
      assert_equal("", @obj.comment)
    end

    def test_remark
      assert_equal("Same as: C04750 C04776", @obj.remark)
    end

    def test_references
      expected =
        [ "1  [PMID:12950230] Backstrom M, Link T, Olson FJ, Karlsson H, Graham R, Picco G, Burchell J, Taylor-Papadimitriou J, Noll T, Hansson GC. Recombinant MUC1 mucin with a breast cancer-like O-glycosylation produced in large amounts in Chinese-hamster ovary cells. Biochem. J. 376 (2003) 677-86.",
          "2  [PMID:14631106] Wu AM. Carbohydrate structural units in glycoproteins and polysaccharides as important ligands for Gal and GalNAc reactive lectins. J. Biomed. Sci. 10 (2003) 676-88." ]
      assert_equal(expected, @obj.references)
    end

    def test_dblinks_as_strings
      expected =
        [ "CCSD: 98 99 100 2225 2236 2237 2238 2239 2240 2241 2242 2243 3406 5035 5038 5887 14321 18613 25363 27572 28182 29046 29092 29175 29393 29521 29554 30734 30735 30848 30849 30850 30917 32646 33022 33851 33878 33952 34823 34829 34986 34995 35029 35050 35107 35108 35805 35833 35991 36236 36826 36863 37982 38587 38640 38672 42797 43915 44029 44775 45346 46438 46466 47186 48015 48891 49283 49293 50466 50469 50477",
          "GlycomeDB: 475",
          "JCGGDB: JCGG-STR025711"
        ]
      assert_equal(expected, @obj.dblinks_as_strings)
    end

    def test_kcf
      expected = <<END_OF_EXPECTED_KCF
NODE        3
            1   Ser/Thr     8     0
            2   GalNAc     -1     0
            3   Gal        -9     0
EDGE        2
            1     2:a1    1
            2     3:b1    2:3
END_OF_EXPECTED_KCF
      assert_equal(expected, @obj.kcf)
    end
  end #class TestBioKeggGLYCAN

  class TestBioKeggGLYCAN_G01366 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/G01366.glycan')
      @obj = Bio::KEGG::GLYCAN.new(File.read(filename))
    end

    def test_dblinks_as_hash
      expected = {
        "JCGGDB"=>["JCGG-STR026574"],
        "GlycomeDB"=>["5567"],
        "CCSD"=>["2549", "2550", "16559", "25204"]
      }
      assert_equal(expected, @obj.dblinks_as_hash)
      assert_equal(expected, @obj.dblinks)
    end

    def test_pathways_as_hash
      assert_equal({}, @obj.pathways_as_hash)
      assert_equal({}, @obj.pathways)
    end

    def test_orthologs_as_hash
      assert_equal({}, @obj.orthologs_as_hash)
      assert_equal({}, @obj.orthologs)
    end

    def test_entry_id
      assert_equal("G01366", @obj.entry_id)
    end

    def test_name
      assert_equal("", @obj.name)
    end

    def test_composition
      expected = {"GlcNAc"=>1, "4dlyxHex"=>1, "Man"=>2}
      assert_equal(expected, @obj.composition)
    end

    def test_mass
      assert_equal(691.6, @obj.mass)
    end

    def test_keggclass
      expected = "Glycoprotein; N-Glycan"
      assert_equal(expected, @obj.keggclass)
    end

    def test_compounds
      assert_equal([], @obj.compounds)
    end

    def test_reactions
      assert_equal([], @obj.reactions)
    end

    def test_pathways_as_strings
      assert_equal([], @obj.pathways_as_strings)
    end

    def test_enzymes
      assert_equal([], @obj.enzymes)
    end

    def test_orthologs_as_strings
      assert_equal([], @obj.orthologs_as_strings)
    end

    def test_comment
      expected = "synthetic (CCSD:2549)"
      assert_equal(expected, @obj.comment)
    end

    def test_remark
      assert_equal("", @obj.remark)
    end

    def test_references
      assert_equal([], @obj.references)
    end

    def test_dblinks_as_strings
      expected = [ "CCSD: 2549 2550 16559 25204",
                   "GlycomeDB: 5567",
                   "JCGGDB: JCGG-STR026574"
                 ]
      assert_equal(expected, @obj.dblinks_as_strings)
    end

    def test_kcf
      expected = <<END_OF_EXPECTED_KCF
NODE        4
            1   GlcNAc   11.4     0
            2   4dlyxHex  -0.6     0
            3   Man     -10.6     5
            4   Man     -10.6    -5
EDGE        3
            1     2:b1    1:4
            2     3:a1    2:6
            3     4:a1    2:3
END_OF_EXPECTED_KCF
      assert_equal(expected, @obj.kcf)
    end
  end #class TestBioKeggGLYCAN_G01366

end #module Bio

