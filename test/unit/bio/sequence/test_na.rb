#
# = test/unit/bio/sequence/test_na.rb - Unit test for Bio::Sequencce::NA
#
# Copyright::   Copyright (C) 2006 
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: test_na.rb,v 1.6 2007/12/03 06:19:12 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/sequence'
require 'bio/sequence/na'  

module Bio

  class TestSequenceNANew < Test::Unit::TestCase
    def test_new
      str = 'atgcatgcatgcatgcaaaa'
      assert(Bio::Sequence::NA.new(str))
    end

    def test_new_t
      str = "atgcatgcatgcatgcaaaa"
      str_t = "atgcatgcat\tgca\ttgcaaaa"
      assert_equal(str, Bio::Sequence::NA.new(str_t))
    end

    def test_new_n
      str = "atgcatgcatgcatgcaaaa"
      str_n = "atgcatgcat\ngca\ntgcaaaa"
      assert_equal(str, Bio::Sequence::NA.new(str_n))
    end

    def test_new_r
      str = "atgcatgcatgcatgcaaaa"
      str_r = "atgcatgcat\n\rgca\n\rtgcaaaa"
      assert_equal(str, Bio::Sequence::NA.new(str_r))
    end

  end
  
  class TestSequenceNA < Test::Unit::TestCase

    def setup
      @obj = Bio::Sequence::NA.new('atgcatgcatgcatgcaaaa')
    end

    def test_splicing
      #     'atgcatgcatgcatgcaaaa'
      #      12345678901234567890
      str = 'atgca  catgcatg'.gsub(' ','')
      assert_equal(str, @obj.splicing("join(1..5,8..15)"))
    end

    def test_forward_complement
      str       = 'atgcatgcatgcatgcaaaa'
      str_fcomp = 'tacgtacgtacgtacgtttt'
      fcomp = @obj.forward_complement
      assert_equal(str_fcomp, @obj.forward_complement)
      assert_equal(str, @obj)
      assert_equal(str_fcomp, @obj.forward_complement!)
      assert_equal(str_fcomp, @obj)
    end

    def test_reverse_complement
      str       = 'atgcatgcatgcatgcaaaa'
      str_rcomp = 'tacgtacgtacgtacgtttt'.reverse
      rcomp = @obj.forward_complement
      assert_equal(str_rcomp, @obj.reverse_complement)
      assert_equal(str, @obj)
      assert_equal(str_rcomp, @obj.reverse_complement!)
      assert_equal(str_rcomp, @obj)
    end

    def test_complement
      assert(@obj.complement)
      assert(@obj.complement!)
    end

    def test_to_s
      str = 'atgcatgcatgcatgcaaaa'
      assert_equal(str, @obj.to_s)
    end

    def test_codon_usage
      usage = {"cat"=>1, "caa"=>1, "tgc"=>1, "gca"=>1, "atg"=>2}
      assert_equal(usage, @obj.codon_usage)
    end

    def test_gc_percent
      assert_equal(40, @obj.gc_percent)
      @obj[0, 1] = 'g'
      assert_equal(45, @obj.gc_percent)
    end

    def test_gc_content
      assert_in_delta(0.4, @obj.gc_content, Float::EPSILON)
      @obj[0, 1] = 'g'
      assert_in_delta(0.45, @obj.gc_content, Float::EPSILON)
    end

    def test_at_content
      assert_in_delta(0.6, @obj.at_content, Float::EPSILON)
      @obj[0, 1] = 'g'
      assert_in_delta(0.55, @obj.at_content, Float::EPSILON)
    end

    def test_gc_skew
      assert_in_delta(0.0, @obj.gc_skew, Float::EPSILON)
      @obj[0, 1] = 'g'
      assert_in_delta(1.0/9.0, @obj.gc_skew, Float::EPSILON)
      @obj.gsub!(/a/, 'c')
      assert_in_delta(-3.0/8.0, @obj.gc_skew, Float::EPSILON)
    end

    def test_at_skew
      assert_in_delta(1.0/3.0, @obj.at_skew, Float::EPSILON)
      @obj[0, 1] = 'g'
      assert_in_delta(3.0/11.0, @obj.at_skew, Float::EPSILON)
    end

    def test_iliegal_bases
      @obj[0, 1] = 'n'
      @obj[1, 1] = 'y'
      assert_equal(['n', 'y'], @obj.illegal_bases)
    end

    def test_molecular_weight
      assert_in_delta(6174.3974, @obj.molecular_weight, 1e-4)
    end

    def test_to_re
      assert_equal(/atgcatgcatgcatgcaaaa/, @obj.to_re)
      @obj[1,1] = 'n'
      @obj[2,1] = 'r'
      @obj[3,1] = 's'
      @obj[4,1] = 'y'
      @obj[5,1] = 'w'
      assert_equal(/a[atgcyrwskmbdhvn][agr][gcw][tcy][atw]gcatgcatgcaaaa/, @obj.to_re)
    end

    def test_names
      ary = ["Adenine", "Thymine", "Guanine"]
      assert_equal(ary , @obj.splice("1..3").names)
    end

    def test_dna
      @obj[0,1] = 'u'
      assert_equal('utgcatgcatgcatgcaaaa', @obj)
      assert_equal('ttgcatgcatgcatgcaaaa', @obj.dna)
    end

    def test_dna!
      @obj[0,1] = 'u'
      assert_equal('utgcatgcatgcatgcaaaa', @obj)
      @obj.dna!
      assert_equal('ttgcatgcatgcatgcaaaa', @obj)
    end

    def test_rna
      assert_equal('atgcatgcatgcatgcaaaa', @obj)
      assert_equal('augcaugcaugcaugcaaaa', @obj.rna)
    end

    def test_rna!
      assert_equal('atgcatgcatgcatgcaaaa', @obj)
      @obj.rna!
      assert_equal('augcaugcaugcaugcaaaa', @obj)
    end

  end

  class TestSequenceCommon < Test::Unit::TestCase

    def setup
      @obj  = Bio::Sequence::NA.new('atgcatgcatgcatgcaaaa')
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
      str = "atgcatgcatgcatgcaaaaa"
      assert_equal(str, @obj << "A")
    end

    # concat(*arg)
    def test_concat
      str = "atgcatgcatgcatgcaaaaa"
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


  class TestSequenceNATranslation < Test::Unit::TestCase
    def setup

      str = "aaacccgggttttaa"
      #      K>>P>>G>>F>>*>>
      #       N>>P>>G>>F>>
      #        T>>R>>V>>L>>
      #         P>>G>>F>>*>>
      #     "tttgggcccaaaatt"
      #      <<F<<G<<P<<K<<L
      #        <<G<<P<<N<<*
      #       <<V<<R<<T<<K            
      @obj = Bio::Sequence::NA.new(str)
    end

    def test_translate
      assert_equal("KPGF*", @obj.translate)
    end

    def test_translate_1
      assert_equal("KPGF*", @obj.translate(1))
    end

    def test_translate_2
      assert_equal("NPGF", @obj.translate(2))
    end

    def test_translate_3
      assert_equal("TRVL", @obj.translate(3))
    end

    def test_translate_4
      assert_equal("LKPGF", @obj.translate(4))
    end

    def test_translate_5
      assert_equal("*NPG", @obj.translate(5))
    end

    def test_translate_6
      assert_equal("KTRV", @obj.translate(6))
    end

    def test_translate_7
      assert_equal("KPGF*", @obj.translate(7))
      assert_equal(@obj.translate, @obj.translate(7))
    end

    def test_translate_n1
      assert_equal("LKPGF", @obj.translate(-1))
      assert_equal(@obj.translate(4), @obj.translate(-1))
    end

    def test_translate_n2
      assert_equal("*NPG", @obj.translate(-2))
      assert_equal(@obj.translate(5), @obj.translate(-2))
    end

    def test_translate_n3
      assert_equal("KTRV", @obj.translate(-3))
      assert_equal(@obj.translate(6), @obj.translate(-3))
    end

    def test_translate_0
      assert_equal("KPGF*", @obj.translate(0))
      assert_equal(@obj.translate, @obj.translate(0))
      assert_equal(@obj.translate(7), @obj.translate(0))
    end

    def test_translate_unknown_x
      @obj[3, 1] = 'N'
      assert_equal("KXGF*", @obj.translate)
    end

    def test_translate_unknown_o
      @obj[3, 1] = 'N'
      assert_equal("KOGF*", @obj.translate(1, 1, 'O'))
    end

    def test_translate_given_codon_table
      @obj[0, 1] = 't'
      @obj[1, 1] = 'g'
      @obj[2, 1] = 'a'
      seleno_ct = Bio::CodonTable.copy(1)
      seleno_ct['tga']  = 'U'
      assert_equal("UPGF*", @obj.translate(1, seleno_ct))
    end

  end

end
