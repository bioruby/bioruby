#
# test/unit/bio/db/fasta/test_format_qual.rb - Unit test for Bio::Sequence::Format::Formatter::Fasta_numeric and Qual
#
# Copyright::  Copyright (C) 2009 Naohisa Goto
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/db/fasta/format_qual'

module Bio
  class TestSequenceFormatFormatterFasta_numeric < Test::Unit::TestCase

    def setup
      @sequence = Bio::Sequence.new('acgt' * 50 + 'a')
      @sequence.quality_scores = (-100..100).to_a.freeze
      @sequence.entry_id = 'TEST0001'
      @sequence.definition = 'this is test'
    end

    def test_output
      expected = <<_END_EXPECTED_
>TEST0001 this is test
-100 -99 -98 -97 -96 -95 -94 -93 -92 -91 -90 -89 -88 -87 -86 -85 -84
-83 -82 -81 -80 -79 -78 -77 -76 -75 -74 -73 -72 -71 -70 -69 -68 -67
-66 -65 -64 -63 -62 -61 -60 -59 -58 -57 -56 -55 -54 -53 -52 -51 -50
-49 -48 -47 -46 -45 -44 -43 -42 -41 -40 -39 -38 -37 -36 -35 -34 -33
-32 -31 -30 -29 -28 -27 -26 -25 -24 -23 -22 -21 -20 -19 -18 -17 -16
-15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9
10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32
33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55
56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78
79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100
_END_EXPECTED_

      str = @sequence.output(:fasta_numeric)
      assert_equal(expected, str)

      # default width is 70
      str = @sequence.output(:fasta_numeric, { :width => 70 })
      assert_equal(expected, str)

      # Modifying the sequence does not affect the output.
      @sequence.delete!('a')
      str = @sequence.output(:fasta_numeric)
      assert_equal(expected, str)
    end

    def test_output_width_35
      expected = <<_END_OF_EXPECTED_
>TEST0001 this is test
-100 -99 -98 -97 -96 -95 -94 -93
-92 -91 -90 -89 -88 -87 -86 -85 -84
-83 -82 -81 -80 -79 -78 -77 -76 -75
-74 -73 -72 -71 -70 -69 -68 -67 -66
-65 -64 -63 -62 -61 -60 -59 -58 -57
-56 -55 -54 -53 -52 -51 -50 -49 -48
-47 -46 -45 -44 -43 -42 -41 -40 -39
-38 -37 -36 -35 -34 -33 -32 -31 -30
-29 -28 -27 -26 -25 -24 -23 -22 -21
-20 -19 -18 -17 -16 -15 -14 -13 -12
-11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14
15 16 17 18 19 20 21 22 23 24 25 26
27 28 29 30 31 32 33 34 35 36 37 38
39 40 41 42 43 44 45 46 47 48 49 50
51 52 53 54 55 56 57 58 59 60 61 62
63 64 65 66 67 68 69 70 71 72 73 74
75 76 77 78 79 80 81 82 83 84 85 86
87 88 89 90 91 92 93 94 95 96 97 98
99 100
_END_OF_EXPECTED_

      str = @sequence.output(:fasta_numeric, { :width => 35 })
      assert_equal(expected, str)
    end

    def test_output_width_nil
      expected = ">TEST0001 this is test\n" + 
        (-100..100).collect { |x| x.to_s }.join(' ') + "\n"
      str = @sequence.output(:fasta_numeric, { :width => nil })
      assert_equal(expected, str)
    end

  end #clsaa TestSequenceFormatFormatterFasta_numeric

  class TestSequenceFormatFormatterQual < Test::Unit::TestCase
    def setup
      @sequence = Bio::Sequence.new('acgt' * 28)
      @sequence.quality_scores = [ -100, *(-10..100).to_a ].freeze
      @sequence.entry_id = 'TEST0001'
      @sequence.definition = 'this is test'
    end

    def test_output
      expected = <<_END_EXPECTED_
>TEST0001 this is test
-100 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14
15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37
38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83
84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100
_END_EXPECTED_

      str = @sequence.output(:qual)
      assert_equal(expected, str)

      # default width is 70
      str = @sequence.output(:qual, { :width => 70 })
      assert_equal(expected, str)
    end

    def test_output_width45
      expected = <<_END_EXPECTED_
>TEST0001 this is test
-100 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4
5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
22 23 24 25 26 27 28 29 30 31 32 33 34 35 36
37 38 39 40 41 42 43 44 45 46 47 48 49 50 51
52 53 54 55 56 57 58 59 60 61 62 63 64 65 66
67 68 69 70 71 72 73 74 75 76 77 78 79 80 81
82 83 84 85 86 87 88 89 90 91 92 93 94 95 96
97 98 99 100
_END_EXPECTED_

      str = @sequence.output(:qual, { :width => 45 })
      assert_equal(expected, str)
    end

    def test_output_after_truncating_sequence
      expected = <<_END_EXPECTED_
>TEST0001 this is test
-100 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14
15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37
38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
61 62 63 64 65 66 67 68 69 70 71 72
_END_EXPECTED_

      # Modifying the sequence affects the output.
      @sequence.delete!('a')
      str = @sequence.output(:qual)
      assert_equal(expected, str)
    end

    def test_output_after_adding_sequence
      expected = <<_END_EXPECTED_
>TEST0001 this is test
-100 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14
15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37
38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83
84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
_END_EXPECTED_

      # Modifying the sequence affects the output.
      @sequence.gsub!(/a/, 'at')
      str = @sequence.output(:qual)
      assert_equal(expected, str)
    end

    def test_output_with_default_score
      expected = <<_END_EXPECTED_
>TEST0001 this is test
-100 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14
15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37
38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83
84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 -10 -10 -10 -10
-10 -10 -10 -10
_END_EXPECTED_

      # Modifying the sequence affects the output.
      @sequence.concat('aaaatttt')
      str = @sequence.output(:qual, { :default_score => -10 })
      assert_equal(expected, str)
    end

    def test_output_with_converting_score_solexa2phred
      expected = <<_END_EXPECTED_
>TEST0001 this is test
0 0 1 1 1 1 1 1 2 2 3 3 4 4 5 5 6 7 8 9 10 10 11 12 13 14 15 16 17 18
19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41
42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64
65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87
88 89 90 91 92 93 94 95 96 97 98 99 100 -99 -99 -99 -99
_END_EXPECTED_

      @sequence.quality_score_type = :solexa
      @sequence.concat('aaaa')
      str = @sequence.output(:qual, { :default_score => -99 })
      assert_equal(expected, str)
    end

    def test_output_with_converting_score_phred2solexa
      expected = <<_END_EXPECTED_
>TEST0001 this is test
-6 -2 0 2 3 5 6 7 8 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49
50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72
73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95
96 97 98 99 100 -99 -99 -99 -99 -99 -99 -99 -99 -99 -99 -99 -99
_END_EXPECTED_

      @sequence.quality_score_type = :phred
      @sequence.quality_scores =
        @sequence.quality_scores.find_all { |x| x > 0 }

      str = @sequence.output(:qual,
                             { :default_score => -99,
                               :quality_score_type => :solexa
                             })
      assert_equal(expected, str)

      # If @sequence.quality_score_type == nil, :phred is assumed.
      @sequence.quality_score_type = nil
      str = @sequence.output(:qual,
                             { :default_score => -75,
                               :quality_score_type => :solexa
                             })
      expected2 = expected.gsub(/ \-99/, ' -75')
      assert_equal(expected2, str)
    end

    def test_output_from_error_probabilities
      # @sequence.quality_scores
      expected_qsc = <<_END_EXPECTED_
>TEST0001 this is test
-100 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14
15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37
38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60
61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83
84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100
_END_EXPECTED_

      # @sequence.error_probabilities to phred score
      expected_ep_phred = <<_END_EXPECTED_
>TEST0001 this is test
0 3 10 18 28 39 51 63 76 90 104 119 134 149 165 181 197 213 230 247
264 282 300 317 336 354 372 391 409 428 447 467 486 505 525 545 565
585 605 625 645 666 686 707 727 748 769 790 811 832 854 875 897 918
940 962 983 1005 1027 1049 1071 1093 1116 1138 1160 1183 1205 1228
1250 1273 1296 1319 1342 1365 1388 1411 1434 1457 1480 1503 1527 1550
1574 1597 1621 1644 1668 1692 1715 1739 1763 1787 1811 1835 1859 1883
1907 1931 1956 1980 2004 2029 2053 2078 2102 2127 2151 2176 2200 2225
2250 2275
_END_EXPECTED_

      # @sequence.error_probabilities to phred score
      expected_ep_solexa = <<_END_EXPECTED_
>TEST0001 this is test
-80 0 9 18 28 39 51 63 76 90 104 119 134 149 165 181 197 213 230 247
264 282 300 317 336 354 372 391 409 428 447 467 486 505 525 545 565
585 605 625 645 666 686 707 727 748 769 790 811 832 854 875 897 918
940 962 983 1005 1027 1049 1071 1093 1116 1138 1160 1183 1205 1228
1250 1273 1296 1319 1342 1365 1388 1411 1434 1457 1480 1503 1527 1550
1574 1597 1621 1644 1668 1692 1715 1739 1763 1787 1811 1835 1859 1883
1907 1931 1956 1980 2004 2029 2053 2078 2102 2127 2151 2176 2200 2225
2250 2275
_END_EXPECTED_

      @sequence.error_probabilities =
        (0...(@sequence.length)).collect { |i| ((i + 1) ** -i) }
      # Because Solexa score does not allow 1.
      @sequence.error_probabilities[0] = 0.99999999

      # @sequence.quality_score_type: nil
      # output :qual, :quality_score_type => (not set)
      #
      # ==> using @sequence.quality_scores
      #
      @sequence.quality_score_type = nil
      str = @sequence.output(:qual)
      assert_equal(expected_qsc, str)

      # @sequence.quality_score_type: :phred
      # output :qual, :quality_score_type => (not set)
      #
      # ==> using @sequence.error_probabilities
      #
      @sequence.quality_score_type = :phred
      str = @sequence.output(:qual)
      assert_equal(expected_ep_phred, str)

      # @sequence.quality_score_type: nil
      # output :qual, :quality_score_type => :phred
      #
      # ==> using @sequence.error_probabilities
      #
      @sequence.quality_score_type = nil
      str = @sequence.output(:qual, :quality_score_type => :phred)
      assert_equal(expected_ep_phred, str)

      # @sequence.quality_score_type: :phred
      # output :qual, :quality_score_type => :solexa
      #
      # ==> using @sequence.error_probabilities
      #
      @sequence.quality_score_type = :phred
      str = @sequence.output(:qual, :quality_score_type => :solexa)
      assert_equal(expected_ep_solexa, str)

      # @sequence.quality_score_type: :solexa
      # output :qual, :quality_score_type => :phred
      #
      # ==> using @sequence.error_probabilities
      #
      @sequence.quality_score_type = :solexa
      str = @sequence.output(:qual, :quality_score_type => :phred)
      assert_equal(expected_ep_phred, str)

      # @sequence.quality_score_type: :phred
      # output :qual, :quality_score_type => :phred
      #
      # ==> using @sequence.quality_scores
      #
      @sequence.quality_score_type = :phred
      str = @sequence.output(:qual, :quality_score_type => :phred)
      assert_equal(expected_qsc, str)

      # After removing @sequence.quality_scores:
      # @sequence.quality_score_type: :phred
      # output :qual, :quality_score_type => :phred
      #
      # ==> using @sequence.error_probabilities
      #
      @sequence.quality_scores = nil
      @sequence.quality_score_type = :phred
      str = @sequence.output(:qual, :quality_score_type => :phred)
      assert_equal(expected_ep_phred, str)
    end

  end #class TestSequenceFormatFormatterQual

end #module Bio


