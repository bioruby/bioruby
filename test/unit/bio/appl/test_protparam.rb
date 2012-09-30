#
# test/unit/bio/appl/test_protparam.rb - Unit test for
# Bio::Protparam
#
#  Copyright::   Copyright (C) 2011
#                Hiroyuki Nakamura <hiroyuki@1vq9.com>
#  License::     The Ruby License
#
#  $Id:$
#

require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/embl/uniprot'
require 'bio/appl/protparam'

module Bio
  class TestProtparam < Test::Unit::TestCase
    def setup
      data = File.read(File.join(BioRubyTestDataPath, 'uniprot', 'p53_human.uniprot'))
      uniprot = Bio::UniProt.new(data)
      @obj = Bio::Protparam.new(uniprot.seq)
    end

    def test_num_neg
      assert_equal(50, @obj.num_neg)
    end

    def test_num_pos
      assert_equal(46, @obj.num_pos)
    end

    def test_amino_acid_number
      assert_equal(393, @obj.amino_acid_number)
    end

    def test_total_atoms
      assert_equal(6040, @obj.total_atoms)
    end

    def test_num_carbon
      assert_equal(1898, @obj.num_carbon)
    end

    def test_num_hydrogen
      assert_equal(2980, @obj.num_hydrogen)
    end

    def test_num_nitro
      assert_equal(548, @obj.num_nitro)
    end

    def test_num_oxygen
      assert_equal(592, @obj.num_oxygen)
    end

    def test_num_sulphur
      assert_equal(22, @obj.num_sulphur)
    end

    def test_molecular_weight
      assert_equal(43653.1, @obj.molecular_weight)
    end

    def test_theoretical_pI
      assert_equal(6.33, @obj.theoretical_pI)
    end

    def test_half_life
      assert_equal(1800, @obj.half_life(:mammalian))
      assert_equal(1200, @obj.half_life(:yeast))
      assert_equal(600, @obj.half_life(:ecoli))
    end

    def test_instability_index
      assert_equal(73.59, @obj.instability_index)
    end

    def test_stability
      assert_equal('unstable', @obj.stability)
    end

    def test_aliphatic_index
      assert_equal(59.08, @obj.aliphatic_index)
    end

    def test_gravy
      assert_equal(-0.756, @obj.gravy)
    end

    def test_aa_comp
      correct_comp = {
        A:  6.1,
        R:  6.6,
        N:  3.6,
        D:  5.1,
        C:  2.5,
        Q:  3.8,
        E:  7.6,
        G:  5.9,
        H:  3.1,
        I:  2.0,
        L:  8.1,
        K:  5.1,
        M:  3.1,
        F:  2.8,
        P: 11.5,
        S:  9.7,
        T:  5.6,
        W:  1.0,
        Y:  2.3,
        V:  4.6,
        O:  0.0,
        U:  0.0,
        B:  0.0,
        Z:  0.0,
        X:  0.0,
      }
      assert_equal(correct_comp, @obj.aa_comp)
    end
  end

end
