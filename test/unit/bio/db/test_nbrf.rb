#
# test/unit/bio/db/test_nbrf.rb - Unit test for Bio::NBRF
#
# Copyright::  Copyright (C) 2010 Kazuhiro Hayashi <k.hayashi.info@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/nbrf'

#some condition is not covered with it. This unit test need a nucleotide acid sequence.
#I can't find a nucleic acid sequence in PIR format 
module Bio
  class TestBioNBRF < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'pir', 'CRAB_ANAPL.pir')
      @obj = Bio::NBRF.new(File.read(filename))
    end


    def test_entry
      expected = <<END_OF_EXPECTED_ENTRY
>P1;CRAB_ANAPL
ALPHA CRYSTALLIN B CHAIN (ALPHA(B)-CRYSTALLIN).
  MDITIHNPLI RRPLFSWLAP SRIFDQIFGE HLQESELLPA SPSLSPFLMR 
  SPIFRMPSWL ETGLSEMRLE KDKFSVNLDV KHFSPEELKV KVLGDMVEIH 
  GKHEERQDEH GFIAREFNRK YRIPADVDPL TITSSLSLDG VLTVSAPRKQ 
  SDVPERSIPI TREEKPAIAG AQRK*
END_OF_EXPECTED_ENTRY
      assert_equal(expected, @obj.entry)
    end

    def test_seq_class
      assert_equal(Bio::Sequence::AA, @obj.seq_class)
    end

    def test_seq
      expected = "MDITIHNPLIRRPLFSWLAPSRIFDQIFGEHLQESELLPASPSLSPFLMRSPIFRMPSWLETGLSEMRLEKDKFSVNLDVKHFSPEELKVKVLGDMVEIHGKHEERQDEHGFIAREFNRKYRIPADVDPLTITSSLSLDGVLTVSAPRKQSDVPERSIPITREEKPAIAGAQRK"
      assert_equal(expected, @obj.seq)
    end

    def test_length
      assert_equal(174, @obj.length)
    end

    def test_naseq
      assert_raise(RuntimeError){ @obj.naseq} #@obj is a protein sequence. the method must output error.
    end

    def test_nalen
      assert_raise(RuntimeError){ @obj.nalen} #@obj is a protein sequence. the method must output error.
    end

    def test_aaseq
      expected = "MDITIHNPLIRRPLFSWLAPSRIFDQIFGEHLQESELLPASPSLSPFLMRSPIFRMPSWLETGLSEMRLEKDKFSVNLDVKHFSPEELKVKVLGDMVEIHGKHEERQDEHGFIAREFNRKYRIPADVDPLTITSSLSLDGVLTVSAPRKQSDVPERSIPITREEKPAIAGAQRK"
      assert_equal(expected, @obj.aaseq)
    end

    def test_aalen
      assert_equal(174, @obj.aalen)
    end

    def test_to_nbrf
      expected =<<EOS
>aaa;ABCD
this is a fake entry.
atgc*
EOS
      nbrf = {:seq_type=>"aaa", :seq=>"atgc", :width=>7, :entry_id=>"ABCD", :definition=>"this is a fake entry."}
      assert_equal(expected, Bio::NBRF.to_nbrf(nbrf))
    end

  end #class TestBioNBRF
end #module Bio

