#
# test/unit/bio/sequence/test_common.rb - Unit test for Bio::Sequencce::Common
#
# Copyright::  Copyright (C) 2006 Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_common.rb,v 1.5 2007/12/03 06:19:12 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/sequence'
require 'bio/sequence/common'

module Bio

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
      obj = Bio::TSequence.new(str)
      assert_equal("atgcatgcatgcatgcaaaA", obj)
    end

    def test_normalize_A
      str = "atgcatgcatgcatgcaaaA"
      seq = Bio::TSequence.new(str)
      assert_equal("atgcatgcatgcatgcaaaA", seq)
      obj = seq.normalize!
      assert_equal("atgcatgcatgcatgcaaaA", obj)
    end

    def test_normalize_a
      str = "atgcatgcatgcatgcaaa"
      seq = Bio::TSequence.new(str)
      assert_equal("atgcatgcatgcatgcaaa", seq)
      obj = seq.normalize!
      assert_equal("atgcatgcatgcatgcaaa", obj)
    end
  end 


  class TestSequenceCommonRansomize < Test::Unit::TestCase

    def test_self_randomize
      # self.randomize(*arg, &block)
    end

    def test_randomize
      #randomize(hash = nil)
    end

  end


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

end
