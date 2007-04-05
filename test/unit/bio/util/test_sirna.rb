#
# test/unit/bio/util/test_sirna.rb - Unit test for Bio::SiRNA.
#
# Copyright::  Copyright (C) 2005 Mitsuteru C. Nakap <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_sirna.rb,v 1.4 2007/04/05 23:35:44 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4 , 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/sirna'

module Bio

  RANDOM_SEQ = "ctttcggtgcggacgtaaggagtattcctgtactaactaaatggagttaccaaggtaggaccacggtaaaatcgcgagcagcctcgatacaagcgttgtgctgaagcctatcgctgacctgaaggggggcgtaagcaaggcagcggttcaccttcatcagttctgctagaaatcacctagcaccccttatcatccgcgtcaggtccattacccttcccattatgtcggactcaattgaggtgcttgtgaacttatacttgaatccaaaacgtctactgtattggcgactaaaaagcacttgtggggagtcggcttgatcagcctccattagggccaggcactgaggatcatccagttaacgtcagattcaaggtctggctcttagcactcggagttgcac"

  class TestSiRNANew < Test::Unit::TestCase
    def test_new
      naseq = Bio::Sequence::NA.new(RANDOM_SEQ)
      assert(Bio::SiRNA.new(naseq))
      assert(Bio::SiRNA.new(naseq, 21))
      assert(Bio::SiRNA.new(naseq, 21, 60.0))
      assert(Bio::SiRNA.new(naseq, 21, 60.0, 40.0))
      assert_raise(ArgumentError) { Bio::SiRNA.new(naseq, 21, 60.0, 40.0, 10.0) }
    end

  end

  class TestSiRNA < Test::Unit::TestCase
    def setup
      naseq = Bio::Sequence::NA.new(RANDOM_SEQ)
      @obj = Bio::SiRNA.new(naseq)
    end

    def test_antisense_size
      assert_equal(21, @obj.antisense_size)
    end

    def test_max_gc_percent
      assert_equal(60.0, @obj.max_gc_percent)
    end

    def test_min_gc_percent
      assert_equal(40.0, @obj.min_gc_percent)
    end

    def test_uitei?
      target = "aaGaa"
      assert_equal(false, @obj.uitei?(target))
      target = "aaAaa"
      assert_equal(false, @obj.uitei?(target))
      target = "G" * 9
      assert_equal(false, @obj.uitei?(target))
    end

    def test_reynolds?
      target = "G" * 9
      assert_equal(false, @obj.reynolds?(target))
      target = "aaaaAaaaaaaUaaAaaaaaAaa"
      assert_equal(true, @obj.reynolds?(target))
    end

    def test_uitei
      assert(@obj.uitei)
    end

    def test_reynolds
      assert(@obj.reynolds)
    end

    def test_design
      assert(@obj.design)
    end


    def test_design_uitei
      assert(@obj.design('uitei'))
    end

    def test_design_reynolds
      assert(@obj.design('reynolds'))
    end
  end

  class TestSiRNAPairNew < Test::Unit::TestCase
    def test_new
      target = ""
      sense = ""
      antisense = ""
      start = 0
      stop = 1
      rule = 'rule'
      gc_percent = 60.0
      assert_raise(ArgumentError) { Bio::SiRNA::Pair.new(target, sense, antisense, start, stop, rule) }
      assert(Bio::SiRNA::Pair.new(target, sense, antisense, start, stop, rule, gc_percent))
      assert_raise(ArgumentError) { Bio::SiRNA::Pair.new(target, sense, antisense, start, stop, rule, gc_percent, "") }
    end
  end


  class TestSiRNAPair < Test::Unit::TestCase
    def setup
      naseq = Bio::Sequence::NA.new(RANDOM_SEQ)
      @obj = Bio::SiRNA.new(naseq).design.first
    end

    def test_target
      assert_equal("gcggacguaaggaguauuccugu", @obj.target)
    end

    def test_sense
      assert_equal("ggacguaaggaguauuccugu", @obj.sense)
    end

    def test_antisense
      assert_equal("aggaauacuccuuacguccgc", @obj.antisense)
    end

    def test_start
      assert_equal(9, @obj.start)
    end

    def test_stop
      assert_equal(32, @obj.stop)
    end

    def test_rule
      assert_equal("uitei", @obj.rule)
    end

    def test_gc_percent
      assert_equal(52.0, @obj.gc_percent)
    end

    def test_report
report =<<END
### siRNA
Start: 9
Stop:  32
Rule:  uitei
GC %:  52
Target:    GCGGACGUAAGGAGUAUUCCUGU
Sense:       GGACGUAAGGAGUAUUCCUGU
Antisense: CGCCUGCAUUCCUCAUAAGGA
END
      assert_equal(report, @obj.report)
    end
  end

  class TestShRNANew < Test::Unit::TestCase
    def test_new
      pair = ""
      assert(Bio::SiRNA::ShRNA.new(pair))
      assert_raise(ArgumentError) { Bio::SiRNA::ShRNA.new }
      assert_raise(ArgumentError) { Bio::SiRNA::ShRNA.new(pair, "") }
    end
  end

  class TestShRNA < Test::Unit::TestCase
    def setup
      naseq = Bio::Sequence::NA.new(RANDOM_SEQ)
      sirna = Bio::SiRNA.new(naseq)
      pairs = sirna.design
      @obj = Bio::SiRNA::ShRNA.new(pairs.first)
    end

    def test_top_strand
      @obj.design
      assert_equal("caccggacguaaggaguauuccugugtgtgctgtccacaggaauacuccuuacgucc", @obj.top_strand)
    end

    def test_top_strand_class
      @obj.design
      assert_equal(Bio::Sequence::NA, @obj.top_strand.class)
    end

    def test_top_strand_nil
      assert_equal(nil, @obj.top_strand)
    end

    def test_bottom_strand
      @obj.design
      assert_equal("aaaaggacguaaggaguauuccuguggacagcacacacaggaauacuccuuacgucc", @obj.bottom_strand)
    end

    def test_bottom_strand_class
      @obj.design
      assert_equal(Bio::Sequence::NA, @obj.bottom_strand.class)
    end

    def test_bottom_strand_nil
      assert_equal(nil, @obj.bottom_strand)
    end

    def test_design
      assert(@obj.design)
    end

    def test_design_BLOCK_IT
      assert_raises(NotImplementedError) { @obj.design('BLOCK-IT') }
    end

    def test_blocK_it
      assert_equal("aaaaggacguaaggaguauuccuguggacagcacacacaggaauacuccuuacgucc", @obj.block_it)
    end

    def test_blocK_it_BLOCK_iT
      assert_equal("aaaaggacguaaggaguauuccuguggacagcacacacaggaauacuccuuacgucc", @obj.block_it)
    end

    def test_blocK_it_BLOCK_IT
      assert_raises(NotImplementedError) { @obj.block_it('BLOCK-IT') }
    end

    def test_blocK_it_piGene
      assert_equal("aaaaggacguaaggaguauuccuguggacagcacacacaggaauacuccuuacgucc", @obj.block_it('piGENE'))
    end

    def test_blocK_it_
      assert_raises(NotImplementedError) { @obj.block_it("") }
    end
    
    def test_report
      report =<<END
### shRNA
Top strand shRNA (57 nt):
  5'-CACCGGACGUAAGGAGUAUUCCUGUGTGTGCTGTCCACAGGAAUACUCCUUACGUCC-3'
Bottom strand shRNA (57 nt):
      3'-CCUGCAUUCCUCAUAAGGACACACACGACAGGUGUCCUUAUGAGGAAUGCAGGAAAA-5'
END
      #@obj.design
      @obj.block_it
      assert_equal(report, @obj.report)
    end

    def test_report_before_design
      assert_raises(NoMethodError) { @obj.report }
    end
  end

end
