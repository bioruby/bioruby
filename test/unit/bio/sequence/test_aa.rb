#
# = test/unit/bio/sequence/test_aa.rb - Unit test for Bio::Sequencce::AA
#
# Copyright::   Copyright (C) 2006 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: test_aa.rb,v 1.5 2007/12/03 06:19:12 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/sequence'
require 'bio/sequence/aa'


module Bio

  class TestSequenceAANew < Test::Unit::TestCase

    def test_new
      str = "RRLEHTFVFL RNFSLMLLRY"
      assert(Bio::Sequence::AA.new(str))
    end

    def test_new_t
      str = "RRLEHTFVFLRNFSLMLLRY"
      str_t = "RRLEHTFVFL\tRNFSLMLLRY"
      assert_equal(str, Bio::Sequence::AA.new(str_t))
    end

    def test_new_n
      str = "RRLEHTFVFLRNFSLMLLRY"
      str_n = "RRLEHTFVFL\nRNFSLMLLRY"
      assert_equal(str, Bio::Sequence::AA.new(str_n))
    end

    def test_new_r
      str = "RRLEHTFVFLRNFSLMLLRY"
      str_r = "RRLEHTFVFL\n\rRNFSLMLLRY"
      assert_equal(str, Bio::Sequence::AA.new(str_r))
    end

  end

  
  class TestSequenceAA < Test::Unit::TestCase

    def setup
      str = "RRLEHTFVFLRNFSLMLLRY"
      @obj = Bio::Sequence::AA.new(str)
    end

    def test_to_s
      str = "RRLEHTFVFLRNFSLMLLRY"
      assert_equal(str, @obj.to_s)
    end

    def test_molecular_weight
      assert_in_delta(2612.105, @obj.molecular_weight, 1e-4)
    end
    
    def test_to_re
      re = /RRLEHTFVFLRNFSLMLLRY/
      assert_equal(re, @obj.to_re)
      @obj[1, 1] = 'B'
      re = /R[DNB]LEHTFVFLRNFSLMLLRY/
      assert_equal(re, @obj.to_re)
    end

    def test_codes
      ary = ["Arg", "Arg", "Leu", "Glu", "His", "Thr", "Phe", "Val", 
             "Phe", "Leu", "Arg", "Asn", "Phe", "Ser", "Leu", "Met", 
             "Leu", "Leu", "Arg", "Tyr"]
      assert_equal(ary, @obj.codes)
    end

    def test_names
      ary = ["arginine", "arginine", "leucine", "glutamic acid", 
             "histidine", "threonine", "phenylalanine", "valine", 
             "phenylalanine", "leucine", "arginine", "asparagine", 
             "phenylalanine", "serine", "leucine", "methionine", 
             "leucine", "leucine", "arginine", "tyrosine"]
      assert_equal(ary, @obj.names)
    end

  end



  require 'bio/sequence/aa'  

  class TestSequenceAACompat < Test::Unit::TestCase
    def test_aa_self_randomize
      composition = Bio::Sequence::AA.new("WWDTGAK").composition
      assert(Bio::Sequence::AA.randomize(composition))
    end
  end

end
