#
# test/unit/bio/util/restriction_enzyme/test_analysis.rb - Unit test for Bio::RestrictionEnzyme::Analysis
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: test_analysis.rb,v 1.13 2007/07/16 19:29:32 k Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme/analysis'
require 'bio/sequence'

module Bio #:nodoc:

class TestAnalysis < Test::Unit::TestCase #:nodoc:

  def setup
    @enz = Bio::RestrictionEnzyme
    @t = Bio::RestrictionEnzyme::Analysis
    
    @obj_1 = @t.cut('cagagag', 'ag^ag')
    @obj_2 = @t.cut('agagag', 'ag^ag')
    @obj_3 = @t.cut('cagagagt', 'ag^ag')

    e1 = @enz.new('atgcatgc', [3,3])
    @obj_4 = @t.cut('atgcatgcatgc', e1)

    @obj_4bd = @t.cut('atgcatgcatgccc', e1, 'cc^c') # mix of always cut and sometimes cut

    e2 = @enz.new('atgcatgc', [3,5])
    @obj_5 = @t.cut('atgcatgcatgc', e2)

    e3 = @enz.new('anna', [1,1], [3,3])
    e4 = @enz.new('gg', [1,1])
    @obj_6 = @t.cut('agga', e3, e4)

    @obj_7 = @t.cut('gaccaggaaaaagaccaggaaagcctggaaaagttaac', 'EcoRII')
    @obj_7b = @t.cut('gaccaggaaaaagaccaggaaagcctggaaaagttaaccc', 'EcoRII', 'HincII', 'cc^c')
    @obj_7bd = @t.cut_without_permutations('gaccaggaaaaagaccaggaaagcctggaaaagttaaccc', 'EcoRII', 'HincII', 'cc^c')
    
    @obj_8 = @t.cut('gaccaggaaaaagaccaggaaagcctggaaaagttaac', 'EcoRII', 'HincII')

    @obj_9 = @t.cut('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'EcoRII')
    @obj_9 = @t.cut('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'EcoRII', 'HincII')

    @obj_1d = @t.cut_without_permutations('cagagag', 'ag^ag')
    @obj_2d = @t.cut_without_permutations('agagag', 'ag^ag')
    @obj_3d = @t.cut_without_permutations('cagagagt', 'ag^ag')

    e1 = @enz.new('atgcatgc', [3,3])
    @obj_4d = @t.cut_without_permutations('atgcatgcatgc', e1)

    e2 = @enz.new('atgcatgc', [3,5])
    @obj_5d = @t.cut_without_permutations('atgcatgcatgc', e2)

    e3 = @enz.new('anna', [1,1], [3,3])
    e4 = @enz.new('gg', [1,1])
    @obj_6d = @t.cut_without_permutations('agga', e3, e4)

    @obj_7d = @t.cut_without_permutations('gaccaggaaaaagaccaggaaagcctggaaaagttaac', 'EcoRII')
    @obj_8d = @t.cut_without_permutations('gaccaggaaaaagaccaggaaagcctggaaaagttaac', 'EcoRII', 'HincII')

    @obj_98 = @t.cut('', 'EcoRII', 'HincII')
    @obj_99 = @t.cut_without_permutations('', 'EcoRII', 'HincII')

    @obj_vr1 = @t.cut('gaccaggaaaaagaccaggaaagcctggaaaagttaac', 'EcoRII', {:view_ranges => true})
    @obj_vr2 = @t.cut('cagagag', {:view_ranges => true}, 'ag^ag')
  end

  def test_cut
    assert_equal(["ag", "cag"], @obj_1.primary)
    assert_equal(["gtc", "tc"], @obj_1.complement)
    assert_equal(2, @obj_1.size)
    assert_equal(Bio::RestrictionEnzyme::Fragments, @obj_1.class)
    assert_equal(Bio::RestrictionEnzyme::Fragment, @obj_1[0].class)

    assert_equal(["ag"], @obj_2.primary)
    assert_equal(["ag", "agt", "cag"], @obj_3.primary)
    assert_equal(["atg", "atgcatg", "catg", "catgc"], @obj_4.primary)

=begin
    A T G^C A T G C
    
    A T G C A T G C A T G C
    
    A T G^C A T G^C A T G C
    
    A T G C A T G^C A T G C
=end
    
    assert_equal(["atg", "atgcatg", "catgc", "catgcatgc"], @obj_5.primary)
    assert_equal(["a", "ag", "g", "ga"], @obj_6.primary)
    assert_equal(["ccaggaaaaaga", "ccaggaaag", "cctggaaaagttaac", "ga"], @obj_7.primary)
    assert_equal(["aac", "ccaggaaaaaga", "ccaggaaag", "cctggaaaagtt", "ga"], @obj_8.primary)
    
=begin
    e1 = @enz.new('atgcatgc', [3,3])
    @obj_4bd = @t.cut('atgcatgcatgccc', e1, 'cc^c') # mix of sometimes cut and always cut

    [#<struct Bio::RestrictionEnzyme::Analysis::UniqueFragment
      primary="atgcatg",
      complement="tacgtac">,
     #<struct Bio::RestrictionEnzyme::Analysis::UniqueFragment
      primary="catgcc",
      complement="gtacg ">,
     #<struct Bio::RestrictionEnzyme::Analysis::UniqueFragment
      primary=" c",
      complement="gg">,
     #<struct Bio::RestrictionEnzyme::Analysis::UniqueFragment
      primary="atg",
      complement="tac">,
     #<struct Bio::RestrictionEnzyme::Analysis::UniqueFragment
      primary="catg",
      complement="gtac">]
=end
    assert_equal(["atg", "atgcatg", "c", "catg", "catgcc"], @obj_4bd.primary)    
    assert_equal(["gg", "gtac", "gtacg", "tac", "tacgtac"], @obj_4bd.complement)
  end

  def test_cut_without_permutations
    assert_equal(["ag", "cag"], @obj_1d.primary)
    assert_equal(["ag"], @obj_2d.primary)
    assert_equal(["ag", "agt", "cag"], @obj_3d.primary)
    assert_equal(["atg", "catg", "catgc"], @obj_4d.primary)
    assert_equal(["atg", "catg", "catgc"], @obj_5d.primary)
    assert_equal(["a", "g"], @obj_6d.primary)
    assert_equal(["ccaggaaaaaga", "ccaggaaag", "cctggaaaagttaac", "ga"], @obj_7d.primary)
    assert_equal(["aac", "ccaggaaaaaga", "ccaggaaag", "cctggaaaagtt", "ga"], @obj_8d.primary)
  end

  def test_cut_from_bio_sequence_na
    assert_equal(["ag", "cag"], Bio::Sequence::NA.new('cagagag').cut_with_enzyme('ag^ag').primary )
    assert_equal(["ag", "cag"], Bio::Sequence::NA.new('cagagag').cut_with_enzymes('ag^ag').primary )
    assert_equal(["ag", "cag"], Bio::Sequence::NA.new('cagagag').cut_with_enzymes('ag^ag', 'EcoRII').primary )

    # Note how EcoRII needs extra padding on the beginning and ending of the
    # sequence 'ccagg' to make the match since the cut must occur between 
    # two nucleotides and can not occur on the very end of the sequence.
    #   
    #   EcoRII:
    #     :blunt: "0"
    #     :c2: "5"
    #     :c4: "0"
    #     :c1: "-1"
    #     :pattern: CCWGG
    #     :len: "5"
    #     :name: EcoRII
    #     :c3: "0"
    #     :ncuts: "2"
    #   
    #        -1 1 2 3 4 5
    #   5' - n^c c w g g n - 3'
    #   3' - n g g w c c^n - 5'
    #   
    #   (w == [at])

    assert_equal(["ag", "agccagg", "cag"], Bio::Sequence::NA.new('cagagagccagg').cut_with_enzymes('ag^ag', 'EcoRII').primary )
    assert_equal(["ag", "agccagg", "cag"], Bio::Sequence::NA.new('cagagagccagg').cut_with_enzymes('ag^ag').primary )
    assert_equal(:no_cuts_found, Bio::Sequence::NA.new('cagagagccagg').cut_with_enzymes('EcoRII') )

    assert_equal(["ag", "ag", "cag", "ccaggt"], Bio::Sequence::NA.new('cagagagccaggt').cut_with_enzymes('ag^ag', 'EcoRII').primary )
    assert_equal(["ag", "agccaggt", "cag"], Bio::Sequence::NA.new('cagagagccaggt').cut_with_enzymes('ag^ag').primary )
    assert_equal(["cagagag", "ccaggt"], Bio::Sequence::NA.new('cagagagccaggt').cut_with_enzymes('EcoRII').primary )
    assert_equal(["a", "gtctctcggtcc"], Bio::Sequence::NA.new('cagagagccaggt').cut_with_enzymes('EcoRII').complement )  
  end
  
  def test_view_ranges
    assert_equal(["ccaggaaaaaga", "ccaggaaag", "cctggaaaagttaac", "ga"], @obj_vr1.primary)
    assert_equal(["ctggtcc", "tttcggacc", "ttttcaattg", "tttttctggtcc"], @obj_vr1.complement)

    a0 = @obj_vr1[0]
    assert_equal('ga     ', a0.primary)
    assert_equal('ctggtcc', a0.complement)
    assert_equal(0, a0.p_left)
    assert_equal(1, a0.p_right)
    assert_equal(0, a0.c_left)
    assert_equal(6, a0.c_right)
    
    a1 = @obj_vr1[1]
    assert_equal('ccaggaaaaaga     ', a1.primary)
    assert_equal('     tttttctggtcc', a1.complement)
    assert_equal(2,  a1.p_left)
    assert_equal(13, a1.p_right)
    assert_equal(7,  a1.c_left)
    assert_equal(18, a1.c_right)     

    a2 = @obj_vr1[2]
    assert_equal('ccaggaaag     ', a2.primary)
    assert_equal('     tttcggacc', a2.complement)
    assert_equal(14, a2.p_left)
    assert_equal(22, a2.p_right)
    assert_equal(19, a2.c_left)
    assert_equal(27, a2.c_right)

    a3 = @obj_vr1[3]
    assert_equal('cctggaaaagttaac', a3.primary)
    assert_equal('     ttttcaattg', a3.complement)
    assert_equal(23, a3.p_left)
    assert_equal(37, a3.p_right)
    assert_equal(28, a3.c_left)
    assert_equal(37, a3.c_right)
    
    a4 = @obj_vr1[4]
    assert_equal(nil, a4)
    
    assert_equal(["ag", "ag", "cag"], @obj_vr2.primary)
    assert_equal(["gtc", "tc", "tc"], @obj_vr2.complement)

    a0 = @obj_vr2[0]
    assert_equal('cag', a0.primary)
    assert_equal('gtc', a0.complement)
    assert_equal(0, a0.p_left)
    assert_equal(2, a0.p_right)
    assert_equal(0, a0.c_left)
    assert_equal(2, a0.c_right)
    
    a1 = @obj_vr2[1]
    assert_equal('ag', a1.primary)
    assert_equal('tc', a1.complement)
    assert_equal(3, a1.p_left)
    assert_equal(4, a1.p_right)
    assert_equal(3, a1.c_left)
    assert_equal(4, a1.c_right)
    
    a2 = @obj_vr2[2]
    assert_equal('ag', a2.primary)
    assert_equal('tc', a2.complement)
    assert_equal(5, a2.p_left)
    assert_equal(6, a2.p_right)
    assert_equal(5, a2.c_left)
    assert_equal(6, a2.c_right)
    
    a3 = @obj_vr2[3]
    assert_equal(nil, a3)
  end
  

end

end
