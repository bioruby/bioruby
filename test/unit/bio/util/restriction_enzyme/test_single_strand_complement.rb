#
# test/unit/bio/util/restriction_enzyme/test_single_strand_complement.rb - Unit test for Bio::RestrictionEnzyme::SingleStrandComplement
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/util/restriction_enzyme/single_strand_complement'

# :nodoc:
module Bio
  module TestRestrictionEnzyme
    class TestSingleStrandComplement < Test::Unit::TestCase # :nodoc:
      def setup
        @t = Bio::RestrictionEnzyme::SingleStrandComplement
        @cl = Bio::RestrictionEnzyme::SingleStrand::CutLocationsInEnzymeNotation
        @s = Bio::Sequence::NA

        @obj_1 = @t.new(@s.new('gata'), @cl.new(-2, 1, 3))
        @obj_2 = @t.new('gata', -2, 1, 3)
        @obj_3 = @t.new('garraxt', [-2, 1, 7])
        @obj_4 = @t.new('nnnnnnngarraxtnn', [-2, 1, 7])

        @obj_5 = @t.new('ga^rr^axt')
        @obj_6 = @t.new('^ga^rr^axt')
        @obj_7 = @t.new('n^ngar^raxtnn^n')
      end

      def test_pattern_palindromic?
        assert_equal(true, @t.new('atgcat', 1).palindromic?)
        assert_equal(false, @t.new('atgcgta', 1).palindromic?)

        assert_equal(false, @obj_1.palindromic?)
        assert_equal(false, @obj_2.palindromic?)
        assert_equal(false, @obj_3.palindromic?)
        assert_equal(false, @obj_4.palindromic?)
      end

      def test_stripped
        assert_equal('gata', @obj_1.stripped)
        assert_equal('gata', @obj_2.stripped)
        assert_equal('garraxt', @obj_3.stripped)
        assert_equal('garraxt', @obj_4.stripped)
      end

      def test_pattern
        assert_equal('nngata', @obj_1.pattern)
        assert_equal('nngata', @obj_2.pattern)
        assert_equal('nngarraxtn', @obj_3.pattern)
        assert_equal('nngarraxtn', @obj_4.pattern)

        assert_equal('nngata', @obj_1)
        assert_equal('nngata', @obj_2)
        assert_equal('nngarraxtn', @obj_3)
        assert_equal('nngarraxtn', @obj_4)
      end

      def test_with_cut_symbols
        assert_equal('n^ng^at^a', @obj_1.with_cut_symbols)
        assert_equal('n^ng^at^a', @obj_2.with_cut_symbols)
        assert_equal('n^ng^arraxt^n', @obj_3.with_cut_symbols)
        assert_equal('n^ng^arraxt^n', @obj_4.with_cut_symbols)
      end

      def test_with_spaces
        assert_equal('n^n g^a t^a', @obj_1.with_spaces)
        assert_equal('n^n g^a t^a', @obj_2.with_spaces)
        assert_equal('n^n g^a r r a x t^n', @obj_3.with_spaces)
        assert_equal('n^n g^a r r a x t^n', @obj_4.with_spaces)
      end

      def test_cut_locations_in_enzyme_notation
        assert_equal([-2, 1, 3], @obj_1.cut_locations_in_enzyme_notation)
        assert_equal([-2, 1, 3], @obj_2.cut_locations_in_enzyme_notation)
        assert_equal([-2, 1, 7], @obj_3.cut_locations_in_enzyme_notation)
        assert_equal([-2, 1, 7], @obj_4.cut_locations_in_enzyme_notation)

        assert_equal([2, 4], @obj_5.cut_locations_in_enzyme_notation)
        assert_equal([-1, 2, 4], @obj_6.cut_locations_in_enzyme_notation)
        assert_equal([-2, 3, 9], @obj_7.cut_locations_in_enzyme_notation)
      end

      def test_cut_locations
        assert_equal([0, 2, 4], @obj_1.cut_locations)
        assert_equal([0, 2, 4], @obj_2.cut_locations)
        assert_equal([0, 2, 8], @obj_3.cut_locations)
        assert_equal([0, 2, 8], @obj_4.cut_locations)

        assert_equal([1, 3], @obj_5.cut_locations)
        assert_equal([0, 2, 4], @obj_6.cut_locations)
        assert_equal([0, 4, 10], @obj_7.cut_locations)
      end

      def test_orientation
        assert_equal([3, 5], @obj_1.orientation)
        assert_equal([3, 5], @obj_2.orientation)
        assert_equal([3, 5], @obj_3.orientation)
        assert_equal([3, 5], @obj_4.orientation)
      end

      def test_creation_with_no_cuts
        @obj_8 = @t.new('garraxt')
        assert_equal([3, 5], @obj_8.orientation)
        assert_equal([], @obj_8.cut_locations)
        assert_equal([], @obj_8.cut_locations_in_enzyme_notation)
        assert_equal('garraxt', @obj_8.pattern)
      end

      # NOTE
      def test_to_re; end

      def test_argument_error
        assert_raise(ArgumentError) { @t.new('a', [0, 1, 2]) }
        assert_raise(ArgumentError) { @t.new('a', 0, 1, 2, 0) }

        assert_raise(ArgumentError) { @t.new('a', [nil, 1, 2]) }
        assert_raise(ArgumentError) { @t.new('a', nil, 1, 2, nil) }

        assert_raise(ArgumentError) { @t.new('a', [1, 1, 2]) }
        assert_raise(ArgumentError) { @t.new('a', 1, 1, 2, 2) }

        # NOTE: t| 2009-09-19 commented out for library efficiency
        # re: validate_args(sequence, c) in util/restriction_enzyme/single_strand/single_strand.rb
        # assert_raise(ArgumentError) { @t.new(1, [1,2,3]) }
        # assert_raise(ArgumentError) { @t.new('gaat^aca', [1,2,3]) }
        # assert_raise(ArgumentError) { @t.new('gaat^^aca') }
        # assert_raise(ArgumentError) { @t.new('z', [1,2,3]) }
        #
        # assert_raise(ArgumentError) { @t.new('g', [0,1,2]) }
        # assert_raise(ArgumentError) { @t.new('g', 0,1,2,0) }
        # assert_raise(ArgumentError) { @t.new('g', [0,1,1,2]) }
        # assert_raise(ArgumentError) { @t.new('g', 0,1,1,2,2) }
        # assert_raise(ArgumentError) { @t.new(1,2,3) }
        # assert_raise(ArgumentError) { @t.new(1,2,'g') }
      end
    end
  end
end
