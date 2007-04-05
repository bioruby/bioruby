#
# test/unit/bio/data/test_na.rb - Unit test for Bio::NucleicAcid
#
# Copyright::  Copyright (C) 2005,2006 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_na.rb,v 1.9 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/data/na'

module Bio

  class TestNAConstants  < Test::Unit::TestCase
    def test_NAMES
      assert_equal('a', Bio::NucleicAcid::NAMES['a'])
    end

    def test_NAMES_1_to_name
      assert_equal('Adenine', Bio::NucleicAcid::NAMES['A'])
    end

    def test_WEIGHT
      mw = 135.15
      assert_equal(mw, Bio::NucleicAcid::WEIGHT['a'])
      assert_equal(mw, Bio::NucleicAcid::WEIGHT[:adenine])
    end
  end


  class TestNA < Test::Unit::TestCase

    def setup
      @obj = Bio::NucleicAcid.new
    end

    def test_to_re
      re = /[tcy][agr][atw][gcw][tgk][acm][tgcyskb][atgrwkd][agcmrsv][atgcyrwskmbdhvn]atgc/
      str = 'yrwskmbdvnatgc'
      str0 = str.clone
      assert_equal(re, @obj.to_re(str))
      assert_equal(str0, str)
      assert_equal(re, Bio::NucleicAcid.to_re(str))
    end


    def test_weight
      mw = 135.15
      assert_equal(mw, @obj.weight('a'))
      assert_equal(mw, Bio::NucleicAcid.weight('a'))
    end

    def test_weight_rna
      mw = 135.15
      assert_equal(mw, @obj.weight('A', true))
      assert_equal(mw, Bio::NucleicAcid.weight('A', true))
    end

    
    def test_accessor
      assert_equal('Adenine', @obj['A'])
    end
    
    def test_names
      assert_equal(Bio::NucleicAcid::NAMES, @obj.names)
    end
    def test_na
      assert_equal(Bio::NucleicAcid::NAMES, @obj.na)
    end

    def test_name
      assert_equal('Adenine', @obj.name('A'))
    end
  end
end
