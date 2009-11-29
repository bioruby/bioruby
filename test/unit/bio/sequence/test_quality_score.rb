#
# test/unit/bio/sequence/test_quality_score.rb - Unit test for Bio::Sequence::QualityScore
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
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
require 'bio/sequence/quality_score'

module Bio
  module TestSequenceQualityScore

    # A module providing methods to compare float arrays
    module FloatArrayComparison
      private
      def float_array_equivalent?(expected, actual, *arg)
        assert_equal(expected.size, actual.size, *arg)
        dt = Float::EPSILON * 1024
        (0...(expected.size)).each do |i|
          e = expected[i]
          a = actual[i]
          #assert_equal(e, a)
          assert_in_delta(e, a, e.abs * dt)
        end
      end
    end #module FloatArrayComparison

    module TestConverterMethods

      Query  = (-20..100).to_a.freeze
      Result_phred2solexa_1to100 =
        ([ -6, -2, 0, 2, 3, 5, 6, 7, 8, 10 ] + (11..100).to_a).freeze

      Result_solexa2phred = 
        ([ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 3,
          3, 4, 4, 5, 5, 6, 7, 8, 9, 10, 10 ] + (11..100).to_a).freeze

      def test_convert_scores_from_phred_to_solexa
        result = @obj.convert_scores_from_phred_to_solexa(Query)
        assert_equal(Result_phred2solexa_1to100, result[21..-1])
        (0..20).each do |i|
          assert_operator(-6, :>, result[i])
        end
      end

      def test_convert_scores_from_solexa_to_phred
        result = @obj.convert_scores_from_solexa_to_phred(Query)
        assert_equal(Result_solexa2phred, result)
      end

      def test_convert_nothing
        result = @obj.convert_nothing(Query)
        assert_equal(Query, result)
      end

      private

      def do_test_from_phred_to_solexa(obj, meth)
        result = obj.__send__(meth, Query)
        assert_equal(Result_phred2solexa_1to100, result[21..-1])
        (0..20).each do |i|
          assert_operator(-6, :>, result[i])
        end
      end

      def do_test_from_solexa_to_phred(obj, meth)
        result = obj.__send__(meth, Query)
        assert_equal(Result_solexa2phred, result)
      end

      def do_test_convert_nothing(obj, meth)
        result = obj.__send__(meth, Query)
        assert_equal(Query, result)
      end
    end #module TestConverterMethods

    class TestConverter < Test::Unit::TestCase
      include TestConverterMethods

      class Dummy
        include Bio::Sequence::QualityScore::Converter
      end #class Dummy

      def setup
        @obj = Dummy.new
      end
    end #class TestConverter

    class TestPhred < Test::Unit::TestCase
      include FloatArrayComparison
      include TestConverterMethods

      class Dummy
        include Bio::Sequence::QualityScore::Phred
      end #class Dummy

      Qscores = (-20..100).to_a.freeze
      Q2P =
        [ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
          1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
          1.0, 0.794328234724281, 0.630957344480193, 0.501187233627272,
          0.398107170553497, 0.316227766016838, 0.251188643150958,
          0.199526231496888, 0.158489319246111, 0.125892541179417,
          0.1, 0.0794328234724281, 0.0630957344480193, 0.0501187233627272,
          0.0398107170553497, 0.0316227766016838, 0.0251188643150958,
          0.0199526231496888, 0.0158489319246111, 0.0125892541179417,
          0.01, 0.00794328234724281, 0.00630957344480193,
          0.00501187233627272, 0.00398107170553497, 0.00316227766016838,
          0.00251188643150958, 0.00199526231496888, 0.00158489319246111,
          0.00125892541179417, 0.001, 0.000794328234724281,
          0.000630957344480193, 0.000501187233627273, 0.000398107170553497,
          0.000316227766016838, 0.000251188643150958, 0.000199526231496888,
          0.000158489319246111, 0.000125892541179417, 0.0001,
          7.94328234724282e-05, 6.30957344480193e-05, 5.01187233627273e-05,
          3.98107170553497e-05, 3.16227766016838e-05, 2.51188643150958e-05,
          1.99526231496888e-05, 1.58489319246111e-05, 1.25892541179417e-05,
          1.0e-05, 7.94328234724282e-06, 6.30957344480193e-06,
          5.01187233627272e-06, 3.98107170553497e-06, 3.16227766016838e-06,
          2.51188643150958e-06, 1.99526231496888e-06, 1.58489319246111e-06,
          1.25892541179417e-06, 1.0e-06, 7.94328234724282e-07,
          6.30957344480193e-07, 5.01187233627272e-07, 3.98107170553497e-07,
          3.16227766016838e-07, 2.51188643150958e-07, 1.99526231496888e-07,
          1.58489319246111e-07, 1.25892541179417e-07, 1.0e-07,
          7.94328234724282e-08, 6.30957344480193e-08, 5.01187233627272e-08,
          3.98107170553497e-08, 3.16227766016838e-08, 2.51188643150958e-08,
          1.99526231496888e-08, 1.58489319246111e-08, 1.25892541179417e-08,
          1.0e-08, 7.94328234724282e-09, 6.30957344480194e-09,
          5.01187233627271e-09, 3.98107170553497e-09, 3.16227766016838e-09,
          2.51188643150958e-09, 1.99526231496888e-09, 1.58489319246111e-09,
          1.25892541179417e-09, 1.0e-09, 7.94328234724282e-10,
          6.30957344480194e-10, 5.01187233627271e-10, 3.98107170553497e-10,
          3.16227766016838e-10, 2.51188643150958e-10, 1.99526231496888e-10,
          1.58489319246111e-10, 1.25892541179417e-10, 1.0e-10 ].freeze
      P2Q = ( [ 0 ] * 20 + (0..100).to_a ).freeze

      def setup
        @obj = Dummy.new
      end

      def test_quality_score_type
        assert_equal(:phred, @obj.quality_score_type)
      end

      def test_phred_q2p
        result = @obj.phred_q2p(Qscores)
        float_array_equivalent?(Q2P, result)
      end

      def test_q2p
        result = @obj.q2p(Qscores)
        float_array_equivalent?(Q2P, result)
      end

      def test_self_q2p
        result = Bio::Sequence::QualityScore::Phred.q2p(Qscores)
        float_array_equivalent?(Q2P, result)
      end

      def test_phred_p2q
        result = @obj.phred_p2q(Q2P)
        assert_equal(P2Q, result)
      end

      def test_p2q
        result = @obj.p2q(Q2P)
        assert_equal(P2Q, result)
      end

      def test_self_p2q
        result = Bio::Sequence::QualityScore::Phred.p2q(Q2P)
        assert_equal(P2Q, result)
      end

      def test_convert_scores_from_phred
        do_test_convert_nothing(@obj, :convert_scores_from_phred)
      end

      def test_convert_scores_to_phred
        do_test_convert_nothing(@obj, :convert_scores_to_phred)
      end

      def test_convert_scores_from_solexa
        do_test_from_solexa_to_phred(@obj, :convert_scores_from_solexa)
      end

      def test_convert_scores_to_solexa
        do_test_from_phred_to_solexa(@obj, :convert_scores_to_solexa)
      end

      def test_self_convert_scores_to_solexa
        do_test_from_phred_to_solexa(Bio::Sequence::QualityScore::Phred,
                                     :convert_scores_to_solexa)
      end
    end #class TestPhred

    class TestSolexa < Test::Unit::TestCase
      include FloatArrayComparison
      include TestConverterMethods

      class Dummy
        include Bio::Sequence::QualityScore::Solexa
      end #class Dummy

      Qscores = [ -200, -175, -150, -125, -100, -75, -50, -25,
                  *(-20..100).to_a ].freeze
      Q2P =
        [ 1.0, 1.0, 0.999999999999999, 0.999999999999684, 0.9999999999,
          0.999999968377224, 0.999990000099999, 0.99684769081674,
          0.99009900990099, 0.987567264745558, 0.98439833775817,
          0.98043769612742, 0.975496632449664, 0.969346569968284,
          0.961713496117745, 0.952273278965796, 0.940649056897232,
          0.926412443882426, 0.909090909090909, 0.888184230221883,
          0.86319311139679, 0.833662469183438, 0.799239991086898,
          0.759746926647958, 0.715252751049199, 0.666139424583122,
          0.613136820153143, 0.557311633762293, 0.5, 0.442688366237707,
          0.386863179846857, 0.333860575416878, 0.284747248950801,
          0.240253073352042, 0.200760008913102, 0.166337530816562,
          0.13680688860321, 0.111815769778117, 0.0909090909090909,
          0.0735875561175735, 0.0593509431027676, 0.0477267210342039,
          0.0382865038822547, 0.0306534300317155, 0.024503367550336,
          0.0195623038725795, 0.0156016622418296, 0.0124327352544424,
          0.0099009900990099, 0.00788068385033028, 0.00627001234143384,
          0.00498687873668797, 0.0039652856191522, 0.00315230918326021,
          0.00250559266728573, 0.00199128917072832, 0.00158238528080172,
          0.00125734251135529, 0.000999000999000999, 0.000793697778169244,
          0.000630559488339893, 0.000500936170813599, 0.000397948744304877,
          0.000316127797629618, 0.000251125563261462, 0.00019948642872153,
          0.000158464204362237, 0.000125876694242503, 9.99900009999e-05,
          7.94265144001309e-05, 6.30917536274865e-05, 5.0116211602182e-05,
          3.98091322252505e-05, 3.16217766333056e-05, 2.51182333735999e-05,
          1.99522250504614e-05, 1.5848680739949e-05, 1.25890956306177e-05,
          9.99990000099999e-06, 7.94321925200956e-06, 6.30953363433606e-06,
          5.0118472175343e-06, 3.98105585666614e-06, 3.1622676602e-06,
          2.51188012195199e-06, 1.99525833390512e-06, 1.58489068057866e-06,
          1.25892382690297e-06, 9.99999000001e-07, 7.94327603767439e-07,
          6.30956946373274e-07, 5.01186982438755e-07, 3.98107012064241e-07,
          3.1622766601687e-07, 2.5118858005524e-07, 1.99526191686179e-07,
          1.58489294127251e-07, 1.25892525330487e-07, 9.9999990000001e-08,
          7.94328171628553e-08, 6.30957304669478e-08, 5.01187208508409e-08,
          3.98107154704566e-08, 3.16227756016838e-08, 2.51188636841385e-08,
          1.99526227515816e-08, 1.58489316734225e-08, 1.25892539594523e-08,
          9.9999999e-09, 7.94328228414709e-09, 6.30957340499123e-09,
          5.01187231115385e-09, 3.98107168968604e-09, 3.16227765016838e-09,
          2.51188642520001e-09, 1.99526231098781e-09, 1.58489318994922e-09,
          1.25892541020927e-09, 9.99999999e-10, 7.94328234093325e-10,
          6.30957344082087e-10, 5.01187233376083e-10, 3.98107170395008e-10,
          3.16227765916838e-10, 2.51188643087862e-10, 1.99526231457078e-10,
          1.58489319220992e-10, 1.25892541163568e-10, 9.999999999e-11 ].freeze
      P2Q_valid =
        [ -150, -125, -100, -75, -50, -25, *((-20..100).to_a) ].freeze

      def setup
        @obj = Dummy.new
      end

      def test_quality_score_type
        assert_equal(:solexa, @obj.quality_score_type)
      end

      def test_solexa_q2p
        result = @obj.solexa_q2p(Qscores)
        float_array_equivalent?(Q2P, result)
      end

      def test_q2p
        result = @obj.q2p(Qscores)
        float_array_equivalent?(Q2P, result)
      end

      def test_self_q2p
        result = Bio::Sequence::QualityScore::Solexa.q2p(Qscores)
        float_array_equivalent?(Q2P, result)
      end

      def test_solexa_p2q
        result = @obj.solexa_p2q(Q2P)
        assert_equal(P2Q_valid, result[2..-1])
        assert_operator(-150, :>, result[0])
        assert_operator(-150, :>, result[1])
      end

      def test_p2q
        result = @obj.p2q(Q2P)
        assert_equal(P2Q_valid, result[2..-1])
        assert_operator(-150, :>, result[0])
        assert_operator(-150, :>, result[1])
      end

      def test_self_p2q
        result = Bio::Sequence::QualityScore::Solexa.p2q(Q2P)
        assert_equal(P2Q_valid, result[2..-1])
        assert_operator(-150, :>, result[0])
        assert_operator(-150, :>, result[1])
      end

      def test_convert_scores_from_phred
        do_test_from_phred_to_solexa(@obj, :convert_scores_from_phred)
      end

      def test_convert_scores_to_phred
        do_test_from_solexa_to_phred(@obj, :convert_scores_to_phred)
      end

      def test_self_convert_scores_to_phred
        do_test_from_solexa_to_phred(Bio::Sequence::QualityScore::Solexa,
                                     :convert_scores_to_phred)
      end

      def test_convert_scores_from_solexa
        do_test_convert_nothing(@obj, :convert_scores_from_solexa)
      end

      def test_convert_scores_to_solexa
        do_test_convert_nothing(@obj, :convert_scores_to_solexa)
      end
    end #class TestSolexa

  end #module TestSequenceQualityScore
end #module Bio

