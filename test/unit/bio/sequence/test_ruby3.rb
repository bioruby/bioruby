#
# test/unit/bio/sequence/test_ruby3.rb - Unit test for Bio::Sequencce::Common with Ruby version 3
#
# Copyright::   Copyright (C) 2021 BioRuby Project
# Maintainter:: Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/sequence/common'

module Bio; module TestSequenceRuby3

  class TSeq < String
    include Bio::Sequence::Common
  end

  class TestSequenceCommon < Test::Unit::TestCase

    def test_multiply
      str = 'atgc'.freeze
      obj = TSeq.new(str)
      val = obj * 3
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str * 3), val)
    end

    def test_chomp
      [ "atgc\n".freeze, "atgc".freeze ].each do |str|
        obj = TSeq.new(str)
        val = obj.chomp
        assert_instance_of(TSeq, val)
        assert_equal(TSeq.new(str.chomp), val)
      end
    end

    def test_chop
      [ "atgc\n".freeze, "atgc".freeze ].each do |str|
        obj = TSeq.new(str)
        val = obj.chop
        assert_instance_of(TSeq, val)
        assert_equal(TSeq.new(str.chop), val)
      end
    end

    def test_delete
      str = "atgggc".freeze
      obj = TSeq.new(str)
      val = obj.delete("g")
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new("atc"), val)
    end

    if "string".respond_to?(:delete_prefix)
      def test_delete_prefix
        str = "atgggc".freeze
        obj = TSeq.new(str)
        val = obj.delete_prefix("atg")
        assert_instance_of(TSeq, val)
        assert_equal(TSeq.new("ggc"), val)
      end
    end #if "string".respond_to?(:delete_prefix)


    if "string".respond_to?(:delete_suffix)
      def test_delete_suffix
        str = "atgggc".freeze
        obj = TSeq.new(str)
        val = obj.delete_suffix("ggc")
        assert_instance_of(TSeq, val)
        assert_equal(TSeq.new("atg"), val)
      end
    end #if "string".respond_to?(:delete_suffix)

    def test_each_char
      str = 'atgc'.freeze
      ary = str.split(//)
      obj = TSeq.new(str)
      obj.each_char do |c|
        assert_instance_of(TSeq, c)
        assert_equal(TSeq.new(ary.shift), c)
      end
    end

    def test_each_char_enum
      str = 'atgc'.freeze
      ary = str.split(//).collect { |c| TSeq.new(c) }
      obj = TSeq.new(str)
      e = obj.each_char
      to_a =  e.to_a
      to_a.each { |c| assert_instance_of(TSeq, c) }
      assert_equal(ary, to_a)
    end

    if "string".respond_to?(:each_grapheme_cluster)
      def test_each_grapheme_cluster
        str = 'atgc'.freeze
        ary = str.split(//)
        obj = TSeq.new(str)
        obj.each_grapheme_cluster do |c|
          assert_instance_of(TSeq, c)
          assert_equal(TSeq.new(ary.shift), c)
        end
      end

      def test_each_grapheme_cluster_enum
        str = 'atgc'.freeze
        ary = str.split(//).collect { |c| TSeq.new(c) }
        obj = TSeq.new(str)
        e = obj.each_grapheme_cluster
        to_a =  e.to_a
        to_a.each { |c| assert_instance_of(TSeq, c) }
        assert_equal(ary, to_a)
      end
    end #if "string".respond_to?(:each_grapheme_cluster)

    def test_each_line
      str = "aagtcgt\nttgctagc\nggtacagt\n".freeze
      ary = str.each_line.to_a
      obj = TSeq.new(str)
      obj.each_line do |c|
        assert_instance_of(TSeq, c)
        assert_equal(TSeq.new(ary.shift), c)
      end
    end

    def test_each_line_enum
      str = "aagtcgt\nttgctagc\nggtacagt\n".freeze
      ary = str.each_line.collect { |x| TSeq.new(x) }
      obj = TSeq.new(str)
      e = obj.each_line
      to_a =  e.to_a
      to_a.each { |x| assert_instance_of(TSeq, x) }
      assert_equal(ary, to_a)
    end

    def test_gsub
      str = "aagtcgtaacaaggt".freeze
      str2 = str.gsub(/aa/, "bb")
      obj = TSeq.new(str)
      val = obj.gsub(/aa/, "bb")
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end
      
    def test_sub
      str = "aagtcgtaacaaggt".freeze
      str2 = str.sub(/aa/, "bb")
      obj = TSeq.new(str)
      val = obj.sub(/aa/, "bb")
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end
      
    def test_gsub_with_block
      str = "aagtcgtaacaaggtaagt".freeze
      str2 = str.gsub(/a(ag)/) { |x| "bb" }
      obj = TSeq.new(str)
      val = obj.gsub(/a(ag)/) do |x|
        assert_equal("ag", $1)
        assert_equal("aag", $&)
        assert_equal(TSeq.new("aag"), x)
        assert_instance_of(MatchData, Regexp.last_match)
        assert_instance_of(TSeq, x)
        "bb"
      end
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_sub_with_block
      str = "aagtcgtaacaaggtaagt".freeze
      str2 = str.sub(/a(ag)/) { |x| "bb" }
      obj = TSeq.new(str)
      val = obj.sub(/a(ag)/) do |x|
        assert_equal("ag", $1)
        assert_equal("aag", $&)
        assert_equal(TSeq.new("aag"), x)
        assert_instance_of(MatchData, Regexp.last_match)
        assert_instance_of(TSeq, x)
        "bb"
      end
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_ljust
      str = "atgc".freeze
      str2 = str.ljust(20, "xyz")
      obj = TSeq.new(str)
      val = obj.ljust(20, "xyz")
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_rjust
      str = "atgc".freeze
      str2 = str.rjust(20, "xyz")
      obj = TSeq.new(str)
      val = obj.rjust(20, "xyz")
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_center
      str = "atgc".freeze
      str2 = str.center(20, "xyz")
      obj = TSeq.new(str)
      val = obj.center(20, "xyz")
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_strip
      str = " at gc\n".freeze
      str2 = str.strip
      obj = TSeq.new(str)
      val = obj.strip
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end
 
    def test_lstrip
      str = " at gc\n".freeze
      str2 = str.lstrip
      obj = TSeq.new(str)
      val = obj.lstrip
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_rstrip
      str = " at gc\n".freeze
      str2 = str.rstrip
      obj = TSeq.new(str)
      val = obj.rstrip
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_split
      str = "aagtcgta".freeze
      ary = str.split("gt").collect { |x| TSeq.new(x) }
      obj = TSeq.new(str)
      val = obj.split("gt")
      val.each do |x|
        assert_instance_of(TSeq, x)
      end
      assert_equal(ary, val)
    end

    def test_reverse
      str = "aagtttcca".freeze
      str2 = str.reverse
      obj = TSeq.new(str)
      val = obj.reverse
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_squeeze
      str = "aagtttcca".freeze
      str2 = str.squeeze
      obj = TSeq.new(str)
      val = obj.squeeze
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_succ
      str = "aagt".freeze
      str2 = str.succ
      obj = TSeq.new(str)
      val = obj.succ
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_next
      str = "aagt".freeze
      str2 = str.next
      obj = TSeq.new(str)
      val = obj.next
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_capitalize
      str = "aacgt".freeze
      str2 = str.capitalize
      obj = TSeq.new(str)
      val = obj.capitalize
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_upcase
      str = "aacgt".freeze
      str2 = str.upcase
      obj = TSeq.new(str)
      val = obj.upcase
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_downcase
      str = "AACGT".freeze
      str2 = str.downcase
      obj = TSeq.new(str)
      val = obj.downcase
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_swapcase
      str = "AaCgT".freeze
      str2 = str.swapcase
      obj = TSeq.new(str)
      val = obj.swapcase
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_tr
      str = "acggt".freeze
      str2 = str.tr("cg", "xy")
      obj = TSeq.new(str)
      val = obj.tr("cg", "xy")
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_tr_s
      str = "acggt".freeze
      str2 = str.tr("cg", "n")
      obj = TSeq.new(str)
      val = obj.tr("cg", "n")
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_slice
      str = "aagtcgta".freeze
      str2 = str.slice(3, 3)
      obj = TSeq.new(str)
      val = obj.slice(3, 3)
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end

    def test_slice2
      str = "aagtcgta".freeze
      str2 = str[3, 3]
      obj = TSeq.new(str)
      val = obj[3, 3]
      assert_instance_of(TSeq, val)
      assert_equal(TSeq.new(str2), val)
    end
  end #class TestSequenceCommon


  class TestSequenceCommonPartition < Test::Unit::TestCase
    def test_partition
      str = "atgatgagttctattcatc".freeze
      sep = "ttc".freeze
      a0 = str.partition(sep)
      a1 = [ TSeq.new(a0[0]), a0[1], TSeq.new(a0[2]) ]
      obj = TSeq.new(str)
      val = obj.partition(sep)
      assert_instance_of(TSeq, val[0])
      assert_instance_of(String, val[1])
      assert_instance_of(TSeq, val[2])
      assert_equal(a1, val)
    end

    def test_partition_sep_TSeq
      str = "atgatgagttctattcatc".freeze
      sep = TSeq.new("ttc").freeze
      a0 = str.partition(sep)
      a1 = [ TSeq.new(a0[0]), a0[1], TSeq.new(a0[2]) ]
      obj = TSeq.new(str)
      val = obj.partition(sep)
      val.each { |x| assert_instance_of(TSeq, x) }
      assert_equal(a1, val)
    end

    def test_partition_sep_regexp
      str = "atgatgagttctattcatc".freeze
      sep = /ttc/
      a1 = str.partition(sep).collect { |x| TSeq.new(x) }
      obj = TSeq.new(str)
      val = obj.partition(sep)
      val.each { |x| assert_instance_of(TSeq, x) }
      assert_equal(a1, val)
    end

    def test_partition_nomatch
      str = "atgatgagttctattcatc".freeze
      sep = "x".freeze
      a1 = str.partition(sep).collect { |x| TSeq.new(x) }
      obj = TSeq.new(str)
      val = obj.partition(sep)
      val.each { |x| assert_instance_of(TSeq, x) }
      assert_equal(a1, val)
    end
  end #class TestSequenceCommonPartition


  class TestSequenceCommonRpartition < Test::Unit::TestCase
    def test_rpartition
      str = "atgatgagttctattcatc".freeze
      sep = "ttc".freeze
      a0 = str.rpartition(sep)
      a1 = [ TSeq.new(a0[0]), a0[1], TSeq.new(a0[2]) ]
      obj = TSeq.new(str)
      val = obj.rpartition(sep)
      assert_instance_of(TSeq, val[0])
      assert_instance_of(String, val[1])
      assert_instance_of(TSeq, val[2])
      assert_equal(a1, val)
    end

    def test_rpartition_sep_TSeq
      str = "atgatgagttctattcatc".freeze
      sep = TSeq.new("ttc").freeze
      a0 = str.rpartition(sep)
      a1 = [ TSeq.new(a0[0]), a0[1], TSeq.new(a0[2]) ]
      obj = TSeq.new(str)
      val = obj.rpartition(sep)
      val.each { |x| assert_instance_of(TSeq, x) }
      assert_equal(a1, val)
    end

    def test_rpartition_sep_regexp
      str = "atgatgagttctattcatc".freeze
      sep = /ttc/
      a1 = str.rpartition(sep).collect { |x| TSeq.new(x) }
      obj = TSeq.new(str)
      val = obj.rpartition(sep)
      val.each { |x| assert_instance_of(TSeq, x) }
      assert_equal(a1, val)
    end

    def test_rpartition_nomatch
      str = "atgatgagttctattcatc".freeze
      sep = "x".freeze
      a1 = str.rpartition(sep).collect { |x| TSeq.new(x) }
      obj = TSeq.new(str)
      val = obj.rpartition(sep)
      val.each { |x| assert_instance_of(TSeq, x) }
      assert_equal(a1, val)
    end
  end #class TestSequenceCommonRpartition

end; end #module Bio; module TestSequenceRuby3
