#
# test/unit/bio/util/restriction_enzyme/test_analysis.rb - Unit test for Bio::RestrictionEnzyme::Analysis
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: test_analysis.rb,v 1.6 2007/01/02 07:33:46 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme/analysis'

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

  end

  def test_cut
    assert_equal(["ag", "cag"], @obj_1.primary)
    assert_equal(["gtc", "tc"], @obj_1.complement)
    assert_equal(2, @obj_1.size)
    assert_equal(Bio::RestrictionEnzyme::Analysis::UniqueFragments, @obj_1.class)
    assert_equal(Bio::RestrictionEnzyme::Analysis::UniqueFragment, @obj_1[0].class)

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

    # NOTE: investigate where the '' is coming from
    assert_equal(["", "ag", "ag", "cag", "ccagg"], Bio::Sequence::NA.new('cagagagccagg').cut_with_enzymes('ag^ag', 'EcoRII').primary )
  end

end

end
