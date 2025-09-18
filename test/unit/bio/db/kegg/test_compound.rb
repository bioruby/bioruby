#
# test/unit/bio/db/kegg/test_compound.rb - Unit test for Bio::KEGG::COMPOUND
#
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/compound'

module Bio
  class TestKeggCompound < Test::Unit::TestCase
    def setup
      testdata_kegg = Pathname.new(File.join(BioRubyTestDataPath, 'KEGG')).cleanpath.to_s
      entry = File.read(File.join(testdata_kegg, 'C00025.compound'))
      @obj = Bio::KEGG::COMPOUND.new(entry)
    end

    def test_entry_id
      assert_equal('C00025', @obj.entry_id)
    end

    def test_name
      assert_equal('L-Glutamate', @obj.name)
    end

    def test_names
      assert_equal(['L-Glutamate', 'L-Glutamic acid', 'L-Glutaminic acid', 'Glutamate'], @obj.names)
    end

    def test_formula
      assert_equal('C5H9NO4', @obj.formula)
    end

    def test_mass
      assert_equal(147.0532, @obj.mass)
    end

    def test_remark
      assert_equal('Same as: D00007', @obj.remark)
    end

    def test_reactions
      assert_equal(
        %w[R00021 R00093 R00114 R00239 R00241 R00243 R00245 R00248 R00250 R00251 R00253
           R00254 R00256 R00257 R00258 R00259 R00260 R00261 R00262 R00263 R00355 R00372 R00411 R00457 R00494 R00525 R00573 R00575 R00578 R00609 R00667 R00668 R00684 R00694 R00707 R00708 R00734 R00768 R00894 R00895 R00908 R00942 R00986 R01072 R01090 R01155 R01161 R01214 R01231 R01339 R01585 R01586 R01648 R01654 R01684 R01716 R01939 R01956 R02040 R02077 R02199 R02237 R02274 R02282 R02283 R02285 R02287 R02313 R02315 R02433 R02619 R02700 R02772 R02773 R02929 R02930 R03053 R03120 R03189 R03207 R03243 R03248 R03266 R03651 R03905 R03916 R03952 R03970 R03971 R04028 R04029 R04051 R04171 R04173 R04188 R04212 R04217 R04234 R04241 R04269 R04338 R04438 R04463 R04467 R04475 R04529 R04558 R04776 R05052 R05085 R05197 R05207 R05224 R05225 R05507 R05578 R05815 R06423 R06426 R06844 R06977 R07275 R07276 R07277 R07396 R07414 R07419 R07456 R07613 R07643 R07659 R08244], @obj.reactions
      )
    end

    def test_rpairs
      assert_equal([], @obj.rpairs)
    end

    def test_pathways_as_strings
      assert_equal(
        ['PATH: ko00250  Alanine, aspartate and glutamate metabolism', 'PATH: ko00330  Arginine and proline metabolism',
         'PATH: ko00340  Histidine metabolism', 'PATH: ko00471  D-Glutamine and D-glutamate metabolism', 'PATH: ko00480  Glutathione metabolism', 'PATH: ko00650  Butanoate metabolism', 'PATH: ko00660  C5-Branched dibasic acid metabolism', 'PATH: ko00860  Porphyrin and chlorophyll metabolism', 'PATH: ko00910  Nitrogen metabolism', 'PATH: ko00970  Aminoacyl-tRNA biosynthesis', 'PATH: map01060  Biosynthesis of plant secondary metabolites', 'PATH: ko01064  Biosynthesis of alkaloids derived from ornithine, lysine and nicotinic acid', 'PATH: ko01100  Metabolic pathways', 'PATH: ko02010  ABC transporters', 'PATH: ko04080  Neuroactive ligand-receptor interaction', 'PATH: ko04540  Gap junction', 'PATH: ko04720  Long-term potentiation', 'PATH: ko04730  Long-term depression', 'PATH: ko04742  Taste transduction', 'PATH: ko05014  Amyotrophic lateral sclerosis (ALS)', "PATH: ko05016  Huntington's disease"], @obj.pathways_as_strings
      )
    end

    def test_enzymes
      assert_equal(
        ['1.4.1.2', '1.4.1.3', '1.4.1.4', '1.4.1.13', '1.4.1.14', '1.4.3.11', '1.4.7.1', '1.5.1.9', '1.5.1.10', '1.5.1.12',
         '1.5.99.5', '2.1.1.21', '2.1.2.5', '2.3.1.1', '2.3.1.14', '2.3.1.35', '2.3.2.2', '2.3.2.-', '2.4.2.14', '2.4.2.-', '2.6.1.1', '2.6.1.2', '2.6.1.3', '2.6.1.4', '2.6.1.5', '2.6.1.6', '2.6.1.7', '2.6.1.8', '2.6.1.9', '2.6.1.11', '2.6.1.13', '2.6.1.16', '2.6.1.17', '2.6.1.19', '2.6.1.22', '2.6.1.23', '2.6.1.24', '2.6.1.26', '2.6.1.27', '2.6.1.29', '2.6.1.33', '2.6.1.34', '2.6.1.36', '2.6.1.38', '2.6.1.39', '2.6.1.40', '2.6.1.42', '2.6.1.48', '2.6.1.49', '2.6.1.52', '2.6.1.55', '2.6.1.57', '2.6.1.59', '2.6.1.65', '2.6.1.67', '2.6.1.68', '2.6.1.72', '2.6.1.75', '2.6.1.76', '2.6.1.79', '2.6.1.80', '2.6.1.81', '2.6.1.82', '2.6.1.83', '2.6.1.85', '2.6.1.-', '2.7.2.11', '2.7.2.13', '3.5.1.2', '3.5.1.38', '3.5.1.55', '3.5.1.65', '3.5.1.68', '3.5.1.87', '3.5.1.94', '3.5.1.96', '3.5.2.9', '3.5.3.8', '4.1.1.15', '4.1.3.27', '4.1.3.-', '5.1.1.3', '5.4.99.1', '6.1.1.17', '6.1.1.24', '6.3.1.2', '6.3.1.6', '6.3.1.11', '6.3.1.-', '6.3.2.2', '6.3.2.12', '6.3.2.17', '6.3.2.18', '6.3.4.2', '6.3.4.12', '6.3.5.1', '6.3.5.2', '6.3.5.3', '6.3.5.4', '6.3.5.5', '6.3.5.6', '6.3.5.7', '6.3.5.9', '6.3.5.10'], @obj.enzymes
      )
    end

    def test_dblinks_as_strings
      assert_equal(['CAS: 56-86-0',
                    'PubChem: 3327',
                    'ChEBI: 16015',
                    'KNApSAcK: C00001358',
                    'PDB-CCD: GLU',
                    '3DMET: B00007',
                    'NIKKAJI: J9.171E'], @obj.dblinks_as_strings)
    end

    def test_dblinks_as_hash
      expected = {
        'CAS' => ['56-86-0'],
        'PubChem' => ['3327'],
        'ChEBI' => ['16015'],
        'KNApSAcK' => ['C00001358'],
        'PDB-CCD' => ['GLU'],
        '3DMET' => ['B00007'],
        'NIKKAJI' => ['J9.171E']
      }
      assert_equal(expected, @obj.dblinks_as_hash)
      assert_equal(expected, @obj.dblinks)
    end

    def test_pathways_as_hash
      expected = {
        'ko00250' => 'Alanine, aspartate and glutamate metabolism',
        'ko00330' => 'Arginine and proline metabolism',
        'ko00340' => 'Histidine metabolism',
        'ko00471' => 'D-Glutamine and D-glutamate metabolism',
        'ko00480' => 'Glutathione metabolism',
        'ko00650' => 'Butanoate metabolism',
        'ko00660' => 'C5-Branched dibasic acid metabolism',
        'ko00860' => 'Porphyrin and chlorophyll metabolism',
        'ko00910' => 'Nitrogen metabolism',
        'ko00970' => 'Aminoacyl-tRNA biosynthesis',
        'map01060' => 'Biosynthesis of plant secondary metabolites',
        'ko01064' =>
        'Biosynthesis of alkaloids derived from ornithine, lysine and nicotinic acid',
        'ko01100' => 'Metabolic pathways',
        'ko02010' => 'ABC transporters',
        'ko04080' => 'Neuroactive ligand-receptor interaction',
        'ko04540' => 'Gap junction',
        'ko04720' => 'Long-term potentiation',
        'ko04730' => 'Long-term depression',
        'ko04742' => 'Taste transduction',
        'ko05014' => 'Amyotrophic lateral sclerosis (ALS)',
        'ko05016' => "Huntington's disease"
      }
      assert_equal(expected, @obj.pathways_as_hash)
      assert_equal(expected, @obj.pathways)
    end

    def test_kcf
      assert_equal("ATOM        10
            1   C1c C    23.8372  -17.4608
            2   C1b C    25.0252  -16.7233
            3   C6a C    22.6023  -16.7994
            4   N1a N    23.8781  -18.8595
            5   C1b C    26.2601  -17.3788
            6   O6a O    21.4434  -17.5954
            7   O6a O    22.6198  -15.4007
            8   C6a C    27.4482  -16.6414
            9   O6a O    28.6830  -17.3028
            10  O6a O    27.4714  -15.2426
BOND        9
            1     1   2 1
            2     1   3 1
            3     1   4 1 #Down
            4     2   5 1
            5     3   6 1
            6     3   7 2
            7     5   8 1
            8     8   9 1
            9     8  10 2", @obj.kcf)
    end

    def test_comment
      assert_equal('The name "glutamate" also means DL-Glutamate (see [CPD:C00302])', @obj.comment)
    end
  end
end
