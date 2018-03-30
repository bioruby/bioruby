#
# test/unit/bio/sequence/test_common.rb - Unit test for Bio::Sequencce::Common
#
# Copyright::  Copyright (C) 2006-2008
#              Mitsuteru C. Nakao <n@bioruby.org>,
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
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
require 'bio/sequence/common'

module Bio; module TestSequenceCommon

  class TSequence < String
    include Bio::Sequence::Common
  end

  class TestSequenceCommon < Test::Unit::TestCase

    def setup
      @obj  = TSequence.new('atgcatgcatgcatgcaaaa')
    end

    def test_to_s
      assert_equal('atgcatgcatgcatgcaaaa', @obj.to_s)
    end

    def test_to_str
      assert_equal('atgcatgcatgcatgcaaaa', @obj.to_str)
    end

    def test_seq
      str = "atgcatgcatgcatgcaaaa"
      assert_equal(str, @obj.seq)
    end

    # <<(*arg)
    def test_push
      str = "atgcatgcatgcatgcaaaaA"
      assert_equal(str, @obj << "A")
    end

    # concat(*arg)
    def test_concat
      str = "atgcatgcatgcatgcaaaaA"
      assert_equal(str, @obj.concat("A"))
    end

    # +(*arg)
    def test_sum 
      str = "atgcatgcatgcatgcaaaaatgcatgcatgcatgcaaaa"
      assert_equal(str, @obj + @obj)
    end

    # window_search(window_size, step_size = 1)
    def test_window_search
      @obj.window_search(4) do |subseq|
        assert_equal(20, @obj.size)
      end
    end

    #total(hash)
    def test_total
      hash = {'a' => 1, 'c' => 2, 'g' => 4, 't' => 3}
      assert_equal(44.0, @obj.total(hash))
    end

    def test_composition
      composition = {"a"=>8, "c"=>4, "g"=>4, "t"=>4}
      assert_equal(composition, @obj.composition)
    end
    
    def test_splicing
      #(position)
      assert_equal("atgcatgc", @obj.splicing("join(1..4, 13..16)"))
    end
  end


  class TestSequenceCommonNormalize < Test::Unit::TestCase
    def test_no_normalize
      str = "atgcatgcatgcatgcaaaA"
      obj = TSequence.new(str)
      assert_equal("atgcatgcatgcatgcaaaA", obj)
    end

    def test_normalize_A
      str = "atgcatgcatgcatgcaaaA"
      seq = TSequence.new(str)
      assert_equal("atgcatgcatgcatgcaaaA", seq)
      obj = seq.normalize!
      assert_equal("atgcatgcatgcatgcaaaA", obj)
    end

    def test_normalize_a
      str = "atgcatgcatgcatgcaaa"
      seq = TSequence.new(str)
      assert_equal("atgcatgcatgcatgcaaa", seq)
      obj = seq.normalize!
      assert_equal("atgcatgcatgcatgcaaa", obj)
    end
  end 


  class TestSequenceCommonRandomize < Test::Unit::TestCase

    def setup
      @str = "attcacgcctgctattcccgtcagcctgagcttgccgcgaagctgatgaaagatgttatc"
      @seq = TSequence.new(@str)
      @orig = TSequence.new(@str)
    end

    # test for Bio::Sequence::Common#randomize(hash = nil)
    def test_randomize
      rseqs = (0..2).collect { |i| @seq.randomize }

      # not breaking given seq?
      assert_equal(@orig, @seq)

      # same length?
      rseqs.each do |rseq|
        assert_equal(@orig.length, rseq.length)
      end

      # same composition?
      [ 'a', 'c', 'g', 't', 'n' ].each do |chr|
        count = @orig.count(chr)
        rseqs.each do |rseq|
          assert_equal(count, rseq.count(chr))
        end
      end

      # randomized? (very simple check)
      assert(rseqs[0] != rseqs[1])
      assert(rseqs[0] != rseqs[2])
      assert(rseqs[1] != rseqs[2])
    end

    # testing Bio::Sequence::Common#randomize() { |x| ... }
    def test_randomize_with_block
      composition = Hash.new(0)
      [ 'a', 'c', 'g', 't' ].each do |chr|
        composition[chr] = @seq.count(chr)
      end

      rseqs = (0..2).collect do |i|
        newcomposition = Hash.new(0)
        newseq = ''
        ret = @seq.randomize do |c|
          assert_kind_of(TSequence, c)
          newcomposition[c] += 1
          newseq.concat c
        end
        # same length?
        assert_equal(@orig.length, newseq.length)
        # same composition?
        assert_equal(composition, newcomposition)
        # returned value is empty sequence?
        assert_equal(TSequence.new(''), ret)
        # not breaking given seq?
        assert_equal(@orig, @seq)
        newseq
      end

      # randomized? (very simple check)
      assert(rseqs[0] != rseqs[1])
      assert(rseqs[0] != rseqs[2])
      assert(rseqs[1] != rseqs[2])
    end

    # testing Bio::Sequence::Common#randomize(hash)
    def test_randomize_with_hash
      hash = { 'a' => 20, 'c' => 19, 'g' => 18, 't' => 17 }
      hash.default = 0
      len = 0
      hash.each_value { |v| len += v }

      rseqs = (0..2).collect do |i|
        rseq = @seq.randomize(hash)
        # same length?
        assert_equal(len, rseq.length)
        # same composition?
        [ 'a', 'c', 'g', 't', 'n' ].each do |chr|
          assert_equal(hash[chr], rseq.count(chr))
        end
        # returned value is instance of TSequence?
        assert_instance_of(TSequence, rseq)
        # not breaking given seq?
        assert_equal(@orig, @seq)
        rseq
      end

      # randomized? (very simple check)
      assert(rseqs[0] != rseqs[1])
      assert(rseqs[0] != rseqs[2])
      assert(rseqs[1] != rseqs[2])
    end

    # testing Bio::Sequence::Common#randomize(hash) { |x| ... }
    def test_randomize_with_hash_block
      hash = { 'a' => 20, 'c' => 19, 'g' => 18, 't' => 17 }
      hash.default = 0
      len = 0
      hash.each_value { |v| len += v }

      rseqs = (0..2).collect do |i|
        newcomposition = Hash.new(0)
        newseq = ''
        ret = @seq.randomize(hash) do |c|
          #assert_kind_of(TSequence, c)
          assert_kind_of(String, c)
          newcomposition[c] += 1
          newseq.concat c
        end
        # same length?
        assert_equal(len, newseq.length)
        # same composition?
        assert_equal(hash, newcomposition)
        # returned value is empty TSequence?
        assert_equal(TSequence.new(''), ret)
        # not breaking given seq?
        assert_equal(@orig, @seq)
        newseq
      end

      # randomized? (very simple check)
      assert(rseqs[0] != rseqs[1])
      assert(rseqs[0] != rseqs[2])
      assert(rseqs[1] != rseqs[2])
    end

  end #class TestSequenceCommonRandomize

  class TestSequenceCommonRandomizeChi2 < Test::Unit::TestCase

    def chi2(hist, f, k)
      chi2 = 0
      (0...k).each do |i|
        chi2 += ((hist[i] - f) ** 2).quo(f)
      end
      chi2
    end
    private :chi2

    # chi-square test for distribution of chi2 values from
    # distribution of index('a')
    def randomize_equiprobability_chi2
      # Reference: http://www.geocities.jp/m_hiroi/light/pystat04.html
      seq = TSequence.new('ccccgggtta') # length must be 10
      k = 10
      hist = Array.new(k, 0)
      iter = 200
      # F for index('a')
      f = iter.quo(seq.length).to_f

      # chi2 distribution, degree of freedom 9
      # Reference: http://www.geocities.jp/m_hiroi/light/pystat04.html
      # Reference: http://keisan.casio.jp/has10/SpecExec.cgi
      # P = 0.9, 0.8, 0.7, ... 0.1, 0
      chi2_table = [ 14.684, 12.242, 10.656, 9.414, 8.343,
                      7.357,  6.393,  5.380, 4.168, 0.000 ]

      chi2_hist = Array.new(k, 0)
      chi2_iter = 200
      chi2_iter.times do
        hist.fill(0)
        iter.times { hist[yield(seq).index('a')] += 1 }
        chi2 = chi2(hist, f, k)
        idx = (0...(chi2_table.size)).find { |i| chi2 >= chi2_table[i] }
        chi2_hist[idx] += 1
      end

      chi2_f = chi2_iter.quo(k).to_f
      chi2_chi2 = chi2(chi2_hist, chi2_f, k)
      #$stderr.puts chi2_chi2

      chi2_chi2
    end
    private :randomize_equiprobability_chi2

    def randomize_equiprobability(&block)
      ## chi-square test, freedom 9, significance level 5%
      #critical_value = 16.919
      #significance_level_message = "5%"
      #
      # chi-square test, freedom 9, significance level 1%
      critical_value = 21.666
      significance_level_message = "1%"

      # max trial times till the test sucess
      max_trial = 10

      values =[]
      max_trial.times do |i|
        chi2_chi2 = randomize_equiprobability_chi2(&block)
        values.push chi2_chi2
        # immediately breaks if the test succeeds
        break if chi2_chi2 < critical_value
        $stderr.print "Bio::Sequence::Common#randomize test of chi2 (=#{chi2_chi2}) < #{critical_value} failed (expected #{significance_level_message} by chance)"
        if values.size < max_trial then
          $stderr.puts ", retrying."
        else
          $stderr.puts " #{values.size} consecutive times!"
        end
      end

      assert_operator(values[-1], :<, critical_value,
                      "test of chi2 < #{critical_value} failed #{values.size} times consecutively (#{values.inspect})")
    end
    private :randomize_equiprobability

    def test_randomize_equiprobability
      randomize_equiprobability { |seq| seq.randomize }
    end

    def test_randomize_with_hash_equiprobability
      hash = { 'c' => 4, 'g' => 3, 't' => 2, 'a' => 1 }
      randomize_equiprobability { |seq| seq.randomize(hash) }
    end

    ## disabled because it takes too long time.
    #def test_randomize_with_block_equiprobability
    #  randomize_equiprobability do |seq|
    #    newseq = ''
    #    seq.randomize do |c|
    #      newseq.concat c
    #    end
    #    newseq
    #  end
    #end

    ## disabled because it takes too long time.
    #def test_randomize_with_hash_block_equiprobability
    #  hash = { 'c' => 4, 'g' => 3, 't' => 2, 'a' => 1 }
    #  randomize_equiprobability do |seq|
    #    newseq = ''
    #    seq.randomize(hash) do |c|
    #      newseq.concat c
    #    end
    #    newseq
    #  end
    #end

  end #class TestSequenceCommonRandomizeChi2


  class TestSequenceCommonSubseq < Test::Unit::TestCase
    #def subseq(s = 1, e = self.length)

    def test_to_s_returns_self_as_string
      s = "abcefghijklmnop"
      sequence = TSequence.new(s)
      assert_equal(s, sequence.to_s, "wrong value")
      assert_instance_of(String, sequence.to_s, "not a String")
    end

    def test_subseq_returns_RuntimeError_blank_sequence_default_end
      sequence = TSequence.new("")
      assert_raise(RuntimeError) { sequence.subseq(5) }
    end

    def test_subseq_returns_RuntimeError_start_less_than_one
      sequence = TSequence.new("blahblah")
      assert_raise(RuntimeError) { sequence.subseq(0) }
    end

    def test_subseq_returns_subsequence
      sequence = TSequence.new("hahasubhehe")
      assert_equal("sub", sequence.subseq(5,7))
    end

  end


  # Test Sequence#window_wearch
  class TestSequenceCommonWindowSearch < Test::Unit::TestCase
    
    def test_window_search_with_width_3_default_step_no_residual
      sequence = TSequence.new("agtca")
      windows = []
      returned_value = sequence.window_search(3) { |window| windows << window }
      assert_equal(["agt", "gtc", "tca"], windows, "windows wrong")
      assert_equal("", returned_value, "returned value wrong")
    end
    
    # added
    def test_window_search_with_width_3_step_two_with_residual
      sequence = TSequence.new("agtcat")
      windows = []
      returned_value = sequence.window_search(3, 2) { |window| windows << window }
      assert_equal(["agt", "tca"], windows, "windows wrong")
      assert_equal("t", returned_value, "returned value wrong")
    end

  end

end; end #module Bio; module TestSequenceCommon
