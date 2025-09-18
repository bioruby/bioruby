#
# test/unit/bio/sequence/test_compat.rb - Unit test for Bio::Sequencce::Compat
#
# Copyright::   Copyright (C) 2006 Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/sequence/compat'

module Bio
  module TestSequenceCompat
    class TSequence < String
      include Bio::Sequence::Common
    end

    class TestSequenceCompat < Test::Unit::TestCase
      def setup
        @obj  = TSequence.new('atgcatgcatgcatgcaaaa')
      end

      def test_to_s
        str = 'atgcatgcatgcatgcaaaa'
        assert_equal(str, @obj.to_s)
      end
    end

    class TestSequenceCommonCompat < Test::Unit::TestCase
      # Test Sequence#to_fasta
      def test_to_fasta
        sequence = TSequence.new('agtc' * 10)
        header = 'the header'
        str = ">the header\n" + ('agtc' * 5) + "\n" + ('agtc' * 5) + "\n"
        assert_equal(str, sequence.to_fasta(header, 20))
      end
    end

    require 'bio/sequence/na'

    class TestSequenceNACompat < Test::Unit::TestCase
      def test_na_self_randomize
        composition = Bio::Sequence::NA.new('acgtacgt').composition
        assert(Bio::Sequence::NA.randomize(composition))
      end
    end

    require 'bio/sequence/aa'

    class TestSequenceNACompat < Test::Unit::TestCase
      def test_aa_self_randomize
        composition = Bio::Sequence::AA.new('WWDTGAK').composition
        assert(Bio::Sequence::AA.randomize(composition))
      end
    end
  end
end # module Bio; module TestSequenceCompat
