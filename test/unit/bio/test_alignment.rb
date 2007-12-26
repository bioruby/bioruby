#
# test/unit/bio/test_alignment.rb - Unit test for Bio::Alignment
#
# Copyright::  Copyright (C) 2004
#              Moses Hohman <mmhohman@northwestern.edu>
#              2005 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_alignment.rb,v 1.12 2007/12/26 13:55:40 ngoto Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/alignment'

module Bio

  class TestAlignmentPropertyMethods < Test::Unit::TestCase

    def setup
      @obj = Object.new
      @obj.extend(Alignment::PropertyMethods)
    end

    def test_is_gap_default_false
      assert_equal(false, @obj.is_gap?('a'), "\"a\" isn't a gap")
    end

    def test_is_gap_default_true
      assert_equal(true, @obj.is_gap?('-'), '"-" is a gap')
    end

    def test_gap_regexp
      assert_not_nil(@obj.gap_regexp)
    end

    def test_gap_regexp_never_nil
      @obj.gap_regexp = nil
      assert_not_nil(@obj.gap_regexp)
    end

    def test_gap_regexp=()
      @obj.gap_regexp = /[^a-zA-Z0-9]/
      assert_equal(/[^a-zA-Z0-9]/, @obj.gap_regexp)
    end

    def test_is_gap_nodefault_false
      @obj.gap_regexp = /[^a-zA-Z0-9]/
      assert_equal(false, @obj.is_gap?('3'))
    end

    def test_is_gap_nodefault_true
      @obj.gap_regexp = /[^atgc]/
      assert_equal(true, @obj.is_gap?('z'))
    end

    def test_gap_char_default
      assert_not_nil(@obj.gap_char)
    end

    def test_gap_char_never_nil
      @obj.gap_char = nil
      assert_not_nil(@obj.gap_char)
    end

    def test_gap_char=()
      @obj.gap_char = '#'
      assert_equal('#', @obj.gap_char)
    end

    def test_missing_char_default
      assert_not_nil(@obj.missing_char)
    end

    def test_missing_char_never_nil
      @obj.missing_char = nil
      assert_not_nil(@obj.missing_char)
    end

    def test_missing_char=()
      @obj.missing_char = '_'
      assert_equal('_', @obj.missing_char)
    end
      
    def test_seqclass_default
      assert_not_nil(@obj.seqclass)
    end

    def test_seqclass_never_nil
      @obj.seqclass = nil
      assert_not_nil(@obj.seqclass)
    end

    def test_seqclass=()
      @obj.seqclass = Sequence::NA
      assert_equal(Sequence::NA, @obj.seqclass)
    end

    def test_get_all_property_default
      assert_equal({}, @obj.get_all_property)
    end

    def test_get_all_property_nodefault
      @obj.gap_regexp   = /[^acgt]/
      @obj.gap_char     = '#'
      @obj.missing_char = '_'
      @obj.seqclass     = Sequence::NA
      assert_equal({ :gap_regexp   => /[^acgt]/,
                     :gap_char     => '#',
                     :missing_char => '_',
                     :seqclass     => Sequence::NA },
                   @obj.get_all_property)
    end

    def test_set_all_property
      h = { :gap_regexp   => /[^acgt]/,
        :gap_char     => '#',
        :missing_char => '_',
        :seqclass     => Sequence::NA }
      @obj.set_all_property(h)
      assert_equal(h, @obj.get_all_property)
    end
  end #class TestAlignmentPropertyMethods

  # This is a unit test of Bio::Alignment::Site class and
  # Bio::Alignment::SiteMethods module.
  # Since Bio::Alignment::Site includes Bio::Alignment::SiteMethods,
  # we can test both at a time.
  class TestAlignmentSite < Test::Unit::TestCase

    def test_has_gap_true
      site = Alignment::Site[ 'a', '-', 'c', 'g', 't' ]
      assert_equal(true, site.has_gap?)
    end

    def test_has_gap_false
      site = Alignment::Site[ 'a', 'c', 'g', 't' ]
      assert_equal(false, site.has_gap?)
    end

    def test_remove_gaps!
      site = Alignment::Site[ 'a', '-', 'c', '-' ]
      assert_equal(Alignment::Site['a', 'c'], site.remove_gaps!)
    end

    def test_remove_gaps_bang_not_removed
      site = Alignment::Site[ 'a', 'c']
      assert_equal(nil, site.remove_gaps!)
    end

    def test_consensus_string_default
      site = Alignment::Site[ 'a', 'a', 'a', 'a']
      assert_equal('a', site.consensus_string)
    end

    def test_consensus_string_default_nil
      site = Alignment::Site[ 'a', 'a', 'a', 'c']
      assert_nil(site.consensus_string)
    end

    def test_consensus_string_50percent
      site = Alignment::Site[ 'a', 'a', 'c', 'g']
      assert_equal('a', site.consensus_string(0.5))
    end

    def test_consensus_string_50percent_nil
      site = Alignment::Site[ 'a', 'c', 'g', 't']
      assert_nil(site.consensus_string(0.5))
    end

    def test_consensus_iupac
      data = {
        'a' => [ 'a' ],
        'c' => [ 'c' ],
        'g' => [ 'g' ],
        't' => [ 't' ],
        't' => [ 't', 'u' ],
        'm' => [ 'a', 'c' ],
        'r' => [ 'a', 'g' ],
        'w' => [ 'a', 't' ],
        's' => [ 'c', 'g' ],
        'y' => [ 'c', 't' ],
        'k' => [ 'g', 't' ],
        'v' => [ 'a', 'c', 'g' ],
        'h' => [ 'a', 'c', 't' ],
        'd' => [ 'a', 'g', 't' ],
        'b' => [ 'c', 'g', 't' ],
        'n' => [ 'a', 'c', 'g', 't' ],
        nil => [ 'z', 'a' ]
      }
      data.each do |cons, testdata|
        site = Alignment::Site[ *testdata ]
        assert_equal(cons, site.consensus_iupac,
                     "IUPAC consensus of #{testdata.join(',')} is #{cons}")
      end
    end

    def test_match_line_amino_missing
      site = Alignment::Site[ 'P', 'Q', 'R', 'S' ]
      assert_equal(' ', site.match_line_amino)
    end

    def test_match_line_amino_100percent
      site = Alignment::Site[ 'M', 'M', 'M', 'M' ]
      assert_equal('*', site.match_line_amino)
    end

    def test_match_line_amino_strong
      site = Alignment::Site[ 'N', 'E', 'Q', 'K' ]
      assert_equal(':', site.match_line_amino)
    end

    def test_match_line_amino_weak
      site = Alignment::Site[ 'S', 'G', 'N', 'D' ]
      assert_equal('.', site.match_line_amino)
    end

    def test_match_line_nuc_missing
      site = Alignment::Site[ 'A', 'C', 'G', 'T' ]
      assert_equal(' ', site.match_line_nuc)
    end

    def test_match_line_nuc_100percent
      site = Alignment::Site[ 'G', 'G', 'G', 'G' ]
      assert_equal('*', site.match_line_nuc)
    end
  end #class TestAlignmentSite

  # This is sample class for testing Bio::Alignment::EnumerableExtension.
  class A < Array
    include Alignment::EnumerableExtension
  end

  class TestAlignmentEnumerableExtension < Test::Unit::TestCase
    def test_each_seq
      expected_results = [ 'atg', 'aag', 'acg' ]
      a = A[ *expected_results ]
      a.each_seq do |x|
        assert_equal(expected_results.shift, x)
      end
      assert(expected_results.empty?)
    end

    def test_seqclass_default
      a = A.new
      assert_equal(String, a.seqclass)
    end

    def test_seqclass
      a = A[ Bio::Sequence::NA.new('atg') ]
      assert_equal(Bio::Sequence::NA, a.seqclass)
    end

    def test_seqclass=()
      a = A.new
      assert_equal(String, a.seqclass)
      a << Bio::Sequence::NA.new('a')
      assert_equal(Bio::Sequence::NA, a.seqclass)
      a.seqclass = Bio::Sequence::AA
      assert_equal(Bio::Sequence::AA, a.seqclass)
    end

    def test_alignment_length
      a = A[ 'a', 'at', 'atgc', 'atg', '' ]
      assert_equal(4, a.alignment_length)
    end

    def test_private_alignment_site
      a = A[ 'a', 'at', 'atgc', 'atg', '' ]
      assert_equal(Alignment::Site[ '-', 't', 't', 't', '-' ],
                   a.instance_eval { _alignment_site(1) })
    end

    def test_alignment_site
      a = A[ 'a', 'at', 'atgc', 'atg', '' ]
      assert_equal(Alignment::Site[ '-', 't', 't', 't', '-' ],
                   a.__send__(:_alignment_site, 1))
    end

    def test_each_site
      expected_results = [
        Alignment::Site[ 'a', 'a', 'a', 'a', '-' ],
        Alignment::Site[ '-', 't', 't', 't', '-' ],
        Alignment::Site[ '-', '-', 'g', 'g', '-' ],
        Alignment::Site[ '-', '-', 'c', '-', '-' ]
      ]
      a = A[ 'a', 'at', 'atgc', 'atg', '' ]
      a.each_site do |site|
        assert_equal(expected_results.shift, site)
      end
      assert(expected_results.empty?)
    end

    def test_each_site_step
      expected_results = [
        Alignment::Site[ '-', 't', 't', 't', '-' ], # site 1
        Alignment::Site[ '-', 'a', 'g', 't', '-' ], # site 3
      ]
      a = A[ 'a', 'atgatc', 'atggcc', 'atgtga', '' ]
      a.each_site_step(1, 4, 2) do |site|
        assert_equal(expected_results.shift, site)
      end
      assert(expected_results.empty?)
    end

    def test_alignment_collect
      a = A[ 'a', 'at', 'atgc', 'atg', '' ]
      assert_equal(Alignment::SequenceArray[ 'a', 'au', 'augc', 'aug', '' ],
                   a.alignment_collect { |x| x.gsub(/t/, 'u') })
    end

    def test_alignment_window
      a = A[ 'a', 'at', 'atgca', 'atg', '' ]
      assert_equal(Alignment::SequenceArray[ '', 't', 'tgc', 'tg', '' ],
                   a.alignment_window(1, 3))
    end

    def test_each_window
      expected_results = [
        Alignment::SequenceArray[ 'atg', 'tcg', '' ], # 0..2
        Alignment::SequenceArray[ 'gca', 'gat', '' ], # 2..4
        Alignment::SequenceArray[ 'atg', 'tgc', '' ], # 4..6
        Alignment::SequenceArray[ 'c', 'a', '' ]      # 7..7
      ]
      a = A[ 'atgcatgc', 'tcgatgca', '' ]
      r = a.each_window(3, 2) do |x|
        assert_equal(expected_results.shift, x)
      end
      assert_equal(expected_results.shift, r)
      assert(expected_results.empty?)
    end

    def test_collect_each_site
      a = A[ 'a', 'at', 'atgc', 'atg', '' ]
      assert_equal(["aaaa-", "-ttt-", "--gg-", "--c--" ],
                   a.collect_each_site { |x| x.join('') })
    end

    def test_consensus_each_site_default
      expected_results = [
        Alignment::Site[ 'a', 'a', 'a', 'a', 'a' ],
        Alignment::Site[ 'a', 'c', 'g', 't', '-' ]
      ]

      a = A[ 'aa', 'ac', 'ag', 'at', 'a-' ]
      result = a.consensus_each_site do |site|
        assert_equal(expected_results.shift, site)
        'x'
      end
      assert_equal('xx', result)
      assert(expected_results.empty?)
    end

    def test_consensus_each_site_gap_mode_1
      expected_results = [
        Alignment::Site[ 'a', 'a', 'a', 'a', 'a' ]
      ]

      a = A[ 'aa', 'ac', 'ag', 'at', 'a-' ]
      result = a.consensus_each_site(:gap_mode => 1) do |site|
        assert_equal(expected_results.shift, site)
        'x'
      end
      assert_equal('x-', result)
      assert(expected_results.empty?)
    end

    def test_consensus_each_site_gap_mode_minus1
      expected_results = [
        Alignment::Site[ 'a', 'a', 'a', 'a', 'a' ],
        Alignment::Site[ 'a', 'c', 'g', 't' ]
      ]

      a = A[ 'aa', 'ac', 'ag', 'at', 'a-' ]
      result = a.consensus_each_site(:gap_mode => -1) do |site|
        assert_equal(expected_results.shift, site)
        'x'
      end
      assert_equal('xx', result)
      assert(expected_results.empty?)
    end

    def test_consensus_string_default
      a = A[ 'ata', 'aac', 'aag', 'aat' ]
      assert_equal('a??', a.consensus_string)
    end

    def test_consensus_string_half
      a = A[ 'ata', 'aac', 'aag', 'aat' ]
      assert_equal('aa?', a.consensus_string(0.5))
    end

    def test_consensus_iupac
      a = A[
        'acgtaaaccgaaacaz',
        'acgtaaaccgccggcz',
        'acgtcgtgttgtttgz',
        'acgtcgtgttaaactz'
      ]
      assert_equal('acgtmrwsykvhdbn?', a.consensus_iupac)
    end

    def test_match_line_amino
      a = A[
        'M-SNNNQMMHF-CASSSSSNNFH-AW',
        'M-TEHDHIIYY-STATTGNDEVF-FW',
        'M-AQQERLLHW-AVGNPNDEQLY-HW',
        'M-SKKQKVFYF-CASKADEQHIH-LW',
        'M-TNNNQMMHY-STASSSQHRMF-QW',
        'M-AEHDHIIYW-AVGTTGKKKFY-YW'
        #* ::::::::: ...........  *
      ]
      assert_equal('* ::::::::: ...........  *', a.match_line_amino)
    end

    def test_match_line_nuc
      a = A[ 'aaa', 'aa-','aac', 'at-' ]
      assert_equal('*  ', a.match_line_nuc)
    end

    def test_match_line
      a = A[
        Sequence::AA.new('MNSA'),
        Sequence::AA.new('MHTL'),
        Sequence::AA.new('MQNV'),
        Sequence::AA.new('MKKW')
      ]
      assert_equal('*:. ', a.match_line)
      assert_equal('*:. ', a.match_line(:type => :aa))
      assert_equal('*   ', a.match_line(:type => :na))
    end

    def test_convert_match
      a = A[
        'aaaa',
        'accc',
        'acac',
        'actc'
      ]
      a.convert_match
      assert_equal(A[ 'aaaa', '.ccc', '.c.c', '.ctc' ], a)
    end

    def test_convert_unmatch
      a = A[ 'aaaa', '.ccc', '.c.c', '.ctc' ]
      a.convert_unmatch
      assert_equal(A[ 'aaaa', 'accc', 'acac', 'actc' ], a)
    end

    def test_alignment_normalize!
      a = A[ 'a', 'atg', 'atgc', '' ]
      a.alignment_normalize!
      assert_equal(A[ 'a---', 'atg-', 'atgc', '----'], a)
    end

    def test_alignment_rstrip!
      a = A[ '--aaa--', '--t-t--', '---g---', '--t' ]
      assert(a.alignment_rstrip!)
      assert_equal(A[ '--aaa', '--t-t', '---g-', '--t' ], a)
    end

    def test_alignment_rstrip_nil
      a = A[ 'aa', '-a', 'a-' ]
      assert_nil(a.alignment_rstrip!)
      assert_equal(A[ 'aa', '-a', 'a-' ], a)
    end

    def test_alignment_lstrip!
      a = A[ '--aaa--', '--t-t--', '---g---', '--t' ]
      assert(a.alignment_lstrip!)
      assert_equal(A[ 'aaa--', 't-t--', '-g---', 't' ], a)
    end

    def test_alignment_lstrip_nil
      a = A[ 'aa', '-a', 'a-' ]
      assert_nil(a.alignment_lstrip!)
      assert_equal(A[ 'aa', '-a', 'a-' ], a)
    end

    def test_alignment_strip!
      a = A[ '--aaa--', '--t-t--', '---g---', '--t' ]
      assert(a.alignment_strip!)
      assert_equal(A[ 'aaa', 't-t', '-g-', 't' ], a)
    end

    def test_alignment_strip_nil
      a = A[ 'aa', '-a', 'a-' ]
      assert_nil(a.alignment_strip!)
      assert_equal(A[ 'aa', '-a', 'a-' ], a)
    end

    def test_remove_all_gaps!
      a = A[ '--aaa--', '--t-t--', '---g---', '--t' ]
      assert(a.remove_all_gaps!)
      assert_equal(A[ 'aaa', 'tt', 'g', 't' ], a)
    end

    # test of alignment_slice.
    # Please also refer alignment_window.
    def test_alignment_slice
      a = A[ 'a', 'at', 'atgca', 'atg', '' ]
      assert_equal(Alignment::SequenceArray[ '', 't', 'tgc', 'tg', nil ],
                   a.alignment_slice(1, 3))
    end

    def test_alignment_subseq
      a = A[
        Sequence::NA.new('a'),
        Sequence::NA.new('at'),
        Sequence::NA.new('atgca'),
        Sequence::NA.new('atg'),
        Sequence::NA.new('')
      ]
      assert_equal(Alignment::SequenceArray[
                     Sequence::NA.new(''),
                     Sequence::NA.new('t'),
                     Sequence::NA.new('tgc'),
                     Sequence::NA.new('tg'),
                     nil
                   ], a.alignment_subseq(2,4))
    end

    def test_alignment_concat
      a = A[ 'aaa',  'c', 'gg', 't' ]
      a.alignment_concat(A[ 'ttt', 'gg', 'aa', 'cc', 'aa' ])
      assert_equal(A[ 'aaattt', 'cgg', 'ggaa', 'tcc' ], a)
      a.alignment_concat([ 'c', 't' ])
      assert_equal(A[ 'aaatttc', 'cggt', 'ggaa', 'tcc' ], a)
    end
  end #class TestAlignmentEnumerableExtension

  class TestAlignmentOutput < Test::Unit::TestCase
    def setup
      @obj = Object.new
      @obj.extend(Alignment::Output)
    end

    def test_clustal_have_same_name_true
      assert_equal([ 0, 1 ], @obj.instance_eval {
               __clustal_have_same_name?([ 'ATP ATG', 'ATP ATA', 'BBB' ]) })
    end

    def test_have_same_name_false
      assert_equal(false, @obj.instance_eval {
               __clustal_have_same_name?([ 'GTP ATG', 'ATP ATA', 'BBB' ]) })
    end

    def test_avoid_same_name
      assert_equal([ 'ATP_ATG', 'ATP_ATA', 'BBB' ],
               @obj.instance_eval {
                 __clustal_avoid_same_name([ 'ATP ATG', 'ATP ATA', 'BBB' ]) })
    end

    def test_avoid_same_name_numbering
      assert_equal([ '0_ATP', '1_ATP', '2_BBB' ],
               @obj.instance_eval {
                 __clustal_avoid_same_name([ 'ATP', 'ATP', 'BBB' ]) })
    end

  end #class TestAlignmentOutput


  class TestAlignment < Test::Unit::TestCase

    # testing helper method
    def build_na_alignment(*sequences)
      sequences.inject(Alignment.new) { |alignment, sequence| alignment << Sequence::NA.new(sequence) }
    end
    private :build_na_alignment    

    def test_equals
      alignment1 = Alignment.new([Sequence::NA.new("agct"), Sequence::NA.new("tagc")])
      alignment2 = Alignment.new([Sequence::NA.new("agct"), Sequence::NA.new("tagc")])
      assert_equal(alignment1, alignment2)
    end

    # Alignment#store

    def test_store_cannot_override_key
      alignment = Alignment.new
      alignment.store("Cat DNA", Sequence::NA.new("cat"))
      alignment.store("Cat DNA", Sequence::NA.new("gcat"))
      assert_equal("cat", alignment["Cat DNA"])
    end

    def test_store_with_nil_key_uses_next_number_for_key
      alignment = Alignment.new
      alignment.store(nil, Sequence::NA.new("cat"))
      alignment.store(nil, Sequence::NA.new("gat"))
      alignment.store(nil, Sequence::NA.new("tat"))
      assert_equal({0=>"cat",1=>"gat",2=>"tat"}, alignment.to_hash)
    end

    def test_store_with_default_keys_and_user_defined_keys
      alignment = Alignment.new
      alignment.store("cat key", Sequence::NA.new("cat"))
      alignment.store(nil, Sequence::NA.new("cag"))
      alignment.store("gat key", Sequence::NA.new("gat"))
      alignment.store(nil, Sequence::NA.new("gag"))
      assert_equal({"gat key"=>"gat",1=>"cag",3=>"gag","cat key"=>"cat"}, alignment.to_hash)
    end

    # Test append operator

    def test_seqclass_when_sequence_used
      alignment = Alignment.new
      alignment << Sequence::NA.new("cat")
      assert_equal({0=>"cat"}, alignment.to_hash)
    end

    # Test seqclass

    def test_seqclass_when_sequence_used_no_seqclass_set
      alignment = Alignment.new
      alignment << Sequence::NA.new("cat")
      assert_equal(Sequence::NA, alignment.seqclass)
    end

    def test_seqclass_String_seq_not_present_no_seqclass_set
      alignment = Alignment.new
      alignment << nil
      assert_equal(String, alignment.seqclass)
    end

    def test_seqclass_when_seqclass_set
      alignment = Alignment.new
      alignment.seqclass = Fixnum
      alignment << "this doesn't really make sense"
      assert_equal(Fixnum, alignment.seqclass)
    end

    # Alignment#gap_char

    def test_default_gap_char
      alignment = Alignment.new
      assert_equal("-", alignment.gap_char)
    end

    def test_set_and_get_gap_char
      alignment = Alignment.new
      alignment.gap_char = "+"
      assert_equal("+", alignment.gap_char)
    end

    # Alignment#gap_regexp

    def test_default_gap_regexp_matches_default_gap_char
      alignment = Alignment.new
      assert(alignment.gap_regexp.match(alignment.gap_char))
    end

    # Alignment#missing_char

    def test_default_missing_char
      alignment = Alignment.new
      assert_equal("?", alignment.missing_char)
    end

    # Alignment#seq_length

    def test_seq_length_when_one_sequence
      alignment = build_na_alignment("agt")
      assert_equal(3, alignment.seq_length)
    end

    def test_seq_length_is_max_seq_length
      alignment = build_na_alignment("agt", "agtaa", "agta")
      assert_equal(5, alignment.seq_length)
    end

    # Alignment#each_site
    
    def test_each_site_equal_length
      alignment = build_na_alignment("acg", "gta")
      expected_sites = [["a", "g"], ["c", "t"], ["g", "a"]]
      alignment.each_site do |site|
        assert_equal expected_sites.shift, site, "site ##{3-expected_sites.size} wrong"
      end
    end

    def test_each_site_unequal_length
      alignment = build_na_alignment("ac", "gta")
      expected_sites = [["a", "g"], ["c", "t"], ["-", "a"]]
      alignment.each_site do |site|
        assert_equal expected_sites.shift, site, "site ##{3-expected_sites.size} wrong"
      end
    end
    
    #TODO: Lots of stuff needing tests here

    # Alignment#add_seq

    def test_add_seq_no_key
      alignment = Alignment.new
      alignment.add_seq("agct")
      assert_equal(String, alignment.seqclass, "wrong class")
      assert_equal({0=>"agct"}, alignment.to_hash, "wrong hash")
    end

    def test_add_seq_using_seq_with_seq_method
      seq = "agtc"
      class <<seq
        def seq
          Sequence::NA.new(self)
        end
      end

      alignment = Alignment.new
      alignment.add_seq(seq, "key")
      assert_equal(Sequence::NA, alignment.seqclass, "wrong class")
      assert_equal({"key"=>"agtc"}, alignment.to_hash, "wrong hash")
    end

    def test_add_seq_using_seq_with_naseq_method
      seq = "agtc"
      class <<seq
	def naseq
          Sequence::NA.new(self)
        end
      end

      alignment = Alignment.new
      alignment.add_seq(seq, "key")
      assert_equal(Sequence::NA, alignment.seqclass, "wrong class")
      assert_equal({"key"=>"agtc"}, alignment.to_hash, "wrong hash")
    end

    def test_add_seq_using_seq_with_aaseq_method
      seq = "AVGR"
      class <<seq
	def aaseq
          Sequence::AA.new(self)
        end
      end

      alignment = Alignment.new
      alignment.add_seq(seq, "key")
      assert_equal(Sequence::AA, alignment.seqclass, "wrong class")
      assert_equal({"key"=>"AVGR"}, alignment.to_hash, "wrong hash")
    end

    def test_add_seq_using_seq_with_definition_method
      seq = "atgc"
      class <<seq
	def definition
          "this is the key"
        end
      end
      
      alignment = Alignment.new
      alignment.add_seq(seq)
      assert_equal({"this is the key"=>"atgc"}, alignment.to_hash, "wrong hash")
    end

    def test_add_seq_using_seq_with_entry_id_method
      seq = "atgc"
      class <<seq
	def entry_id
          271828
        end
      end
      
      alignment = Alignment.new
      alignment.add_seq(seq)
      assert_equal({271828=>"atgc"}, alignment.to_hash, "wrong hash")
    end

    # Alignment#consensus_string

    def test_consensus_string_no_gaps
      alignment = build_na_alignment("agtcgattaa",
                                     "tttcgatgcc")
      assert_equal("??tcgat???", alignment.consensus_string)
    end

    def test_consensus_threshold_two_sequences
      alignment = build_na_alignment("agtcgattaa",
                                     "tttcgatgcc")
      # the threshold is the fraction of sequences in which a symbol must 
      # occur at a given position to be considered the consensus symbol
      assert_equal("agtcgattaa", alignment.consensus(0.5))
      assert_equal("??tcgat???", alignment.consensus(0.500000001))
    end

    def test_consensus_threshold_four_sequences
      alignment = build_na_alignment("agtg", 
                                     "ttag",
                                     "actc",
                                     "tatc")
      # ties go to the symbol that occurs in the earliest sequence
      assert_equal("agtg", alignment.consensus(0.25))
      assert_equal("a?tg", alignment.consensus(0.26))
    end

    def test_consensus_opt_gap_mode
      alignment = build_na_alignment("gt-gt-a",
                                     "ttcggc-",
                                     "ttcggc-")
      # using threshold = 0.5, that is a symbol must occur >= half the time in order to be consensus
      # gap_mode -1 means gaps are ignored	                                   
      assert_equal("ttcggca", alignment.consensus(0.5, :gap_mode => -1), "gap mode -1")
      # gap_mode 0 means gaps are treated like regular symbols, yielding a gap in the last position
      assert_equal("ttcggc-", alignment.consensus(0.5, :gap_mode => 0), "gap mode 0")
      # gap_mode 1 means gaps take precedence over any other symbol, yielding two more gaps
      assert_equal("tt-gg--", alignment.consensus(0.5, :gap_mode => 1), "gap mode 1")
    end

    def test_consensus_opt_missing_char
      alignment = build_na_alignment("agtcgattaa", 
                                     "tttcgatgcc")
      assert_equal("**tcgat***", alignment.consensus(1, :missing_char => "*"))
    end
    
    # Alignment#consensus_iupac
    
    def test_consensus_iupac_no_gaps
      alignment = build_na_alignment("agtcgattaa", "tttcgatgcc")
      assert_equal("wktcgatkmm", alignment.consensus_iupac)
    end
              
    def test_consensus_iupac_of_ambiguous_bases
      alignment = build_na_alignment("tmrwsykvhdbnd", "uaaaccgaaacab")
      assert_equal("tmrwsykvhdbnn", alignment.consensus_iupac)
    end
              
    def test_consensus_iupac_gap_modes
      alignment = build_na_alignment("a-t", "acc")
      # gap_mode -1 means gaps are ignored	                                   
      assert_equal("acy", alignment.consensus_iupac(:gap_mode => -1))
      # gap_mode 0 means gaps are treated as normal characters, yielding a missing symbol
      assert_equal("a?y", alignment.consensus_iupac(:gap_mode => 0))
      # gap_mode 1 means gaps take precedence over everything, yielding a gap
      assert_equal("a-y", alignment.consensus_iupac(:gap_mode => 1))
    end
              
    def test_consensus_iupac_yields_correct_ambiguous_bases
      assert_equal "t", build_na_alignment("t", "u").consensus_iupac # not really IUPAC
      
      # m = a c
      assert_equal "m", build_na_alignment("a", "c").consensus_iupac, "m #1"
      assert_equal "m", build_na_alignment("m", "c").consensus_iupac, "m #2"
      assert_equal "m", build_na_alignment("a", "m").consensus_iupac, "m #3"
      assert_equal "m", build_na_alignment("m", "a", "c").consensus_iupac, "m #4"
                
      # r = a g
      assert_equal "r", build_na_alignment("a", "g").consensus_iupac, "r #1"
      assert_equal "r", build_na_alignment("r", "g").consensus_iupac, "r #2"
      assert_equal "r", build_na_alignment("a", "r").consensus_iupac, "r #3"
      assert_equal "r", build_na_alignment("a", "r", "g").consensus_iupac, "r #4"
                
      # w = a t/u
      assert_equal "w", build_na_alignment("a", "t").consensus_iupac, "w #1"
      assert_equal "w", build_na_alignment("a", "u").consensus_iupac, "w #2"
      assert_equal "w", build_na_alignment("w", "a").consensus_iupac, "w #3"
      assert_equal "w", build_na_alignment("t", "w").consensus_iupac, "w #4"
      assert_equal "w", build_na_alignment("w", "u").consensus_iupac, "w #5"
      assert_equal "w", build_na_alignment("u", "t", "a").consensus_iupac, "w #6"
      assert_equal "w", build_na_alignment("w", "u", "t", "a").consensus_iupac, "w #7"

      # s = c g
      assert_equal "s", build_na_alignment("c", "g").consensus_iupac, "s #1"
      assert_equal "s", build_na_alignment("s", "g").consensus_iupac, "s #2"
      assert_equal "s", build_na_alignment("c", "s").consensus_iupac, "s #3"
      assert_equal "s", build_na_alignment("c", "s", "g").consensus_iupac, "s #4"

      # y = c t/u
      assert_equal "y", build_na_alignment("c", "t").consensus_iupac, "y #1"
      assert_equal "y", build_na_alignment("c", "u").consensus_iupac, "y #2"
      assert_equal "y", build_na_alignment("y", "c").consensus_iupac, "y #3"
      assert_equal "y", build_na_alignment("t", "y").consensus_iupac, "y #4"
      assert_equal "y", build_na_alignment("y", "u").consensus_iupac, "y #5"
      assert_equal "y", build_na_alignment("u", "t", "c").consensus_iupac, "y #6"
      assert_equal "y", build_na_alignment("y", "u", "t", "c").consensus_iupac, "y #7"

      # k = g t/u
      assert_equal "k", build_na_alignment("g", "t").consensus_iupac, "k #1"
      assert_equal "k", build_na_alignment("g", "u").consensus_iupac, "k #2"
      assert_equal "k", build_na_alignment("k", "g").consensus_iupac, "k #3"
      assert_equal "k", build_na_alignment("t", "k").consensus_iupac, "k #4"
      assert_equal "k", build_na_alignment("k", "u").consensus_iupac, "k #5"
      assert_equal "k", build_na_alignment("u", "t", "g").consensus_iupac, "k #6"
      assert_equal "k", build_na_alignment("k", "u", "t", "g").consensus_iupac, "k #7"

      # v = a c g m r s    
      assert_equal "v", build_na_alignment("a", "c", "g").consensus_iupac, "v #1"
      assert_equal "v", build_na_alignment("g", "m").consensus_iupac, "v #2"
      assert_equal "v", build_na_alignment("a", "s").consensus_iupac, "v #3"
      assert_equal "v", build_na_alignment("c", "r").consensus_iupac, "v #4"
      assert_equal "v", build_na_alignment("m", "s").consensus_iupac, "v #5"
      assert_equal "v", build_na_alignment("m", "r").consensus_iupac, "v #6"
      assert_equal "v", build_na_alignment("s", "r").consensus_iupac, "v #7"
      assert_equal "v", build_na_alignment("s", "r", "m").consensus_iupac, "v #8"
      assert_equal "v", build_na_alignment("s", "r", "m", "a", "c", "g").consensus_iupac, "v #9"
      assert_equal "v", build_na_alignment("v", "g").consensus_iupac, "v #10" # alright, enough
      
      # b = t/u c g s y k    
      assert_equal "b", build_na_alignment("t", "c", "g").consensus_iupac, "b #1"
      assert_equal "b", build_na_alignment("g", "y").consensus_iupac, "b #2"
      assert_equal "b", build_na_alignment("t", "s").consensus_iupac, "b #3"
      assert_equal "b", build_na_alignment("c", "k").consensus_iupac, "b #4"
      assert_equal "b", build_na_alignment("y", "s").consensus_iupac, "b #5"
      assert_equal "b", build_na_alignment("y", "k").consensus_iupac, "b #6"
      assert_equal "b", build_na_alignment("s", "k").consensus_iupac, "b #7"
      assert_equal "b", build_na_alignment("s", "k", "y").consensus_iupac, "b #8"
      assert_equal "b", build_na_alignment("s", "k", "y", "u", "c", "g").consensus_iupac, "b #9"
      assert_equal "b", build_na_alignment("b", "g").consensus_iupac, "b #10"

      # h = t/u c a y w m    
      assert_equal "h", build_na_alignment("t", "c", "a").consensus_iupac, "h #1"
      assert_equal "h", build_na_alignment("a", "y").consensus_iupac, "h #2"
      assert_equal "h", build_na_alignment("c", "w").consensus_iupac, "h #3"
      assert_equal "h", build_na_alignment("u", "m").consensus_iupac, "h #4"
      assert_equal "h", build_na_alignment("y", "w").consensus_iupac, "h #5"
      assert_equal "h", build_na_alignment("y", "m").consensus_iupac, "h #6"
      assert_equal "h", build_na_alignment("y", "w").consensus_iupac, "h #7"
      assert_equal "h", build_na_alignment("w", "m", "y").consensus_iupac, "h #8"
      assert_equal "h", build_na_alignment("w", "m", "y", "t", "c", "a").consensus_iupac, "h #9"
      assert_equal "h", build_na_alignment("h", "t").consensus_iupac, "h #10"

      # d = t/u g a r w k    
      assert_equal "d", build_na_alignment("t", "g", "a").consensus_iupac, "d #1"
      assert_equal "d", build_na_alignment("r", "t").consensus_iupac, "d #2"
      assert_equal "d", build_na_alignment("w", "g").consensus_iupac, "d #3"
      assert_equal "d", build_na_alignment("k", "a").consensus_iupac, "d #4"
      assert_equal "d", build_na_alignment("k", "r").consensus_iupac, "d #5"
      assert_equal "d", build_na_alignment("k", "w").consensus_iupac, "d #6"
      assert_equal "d", build_na_alignment("r", "w").consensus_iupac, "d #7"
      assert_equal "d", build_na_alignment("r", "w", "k").consensus_iupac, "d #8"
      assert_equal "d", build_na_alignment("k", "r", "w", "t", "g", "a").consensus_iupac, "d #9"
      assert_equal "d", build_na_alignment("d", "t").consensus_iupac, "d #10"
      
      # n = anything
      assert_equal "n", build_na_alignment("a", "g", "c", "t").consensus_iupac, "n #1"
      assert_equal "n", build_na_alignment("a", "g", "c", "u").consensus_iupac, "n #2"
      assert_equal "n", build_na_alignment("w", "s").consensus_iupac, "n #3"
      assert_equal "n", build_na_alignment("k", "m").consensus_iupac, "n #4"
      assert_equal "n", build_na_alignment("r", "y").consensus_iupac, "n #5"
    end

    def test_consensus_iupac_missing_char
      alignment = build_na_alignment("a??", "ac?")
      assert_equal("a??", alignment.consensus_iupac())
    end
              
    def test_consensus_iupac_missing_char_option
      alignment = build_na_alignment("a**t", "ac**")
      assert_equal("a***", alignment.consensus_iupac(:missing_char => "*")) 
    end
              
    # Alignment#convert_match
    
    def test_convert_match
      alignment = Alignment.new
      alignment << Sequence::NA.new("agtcgattaa")
      alignment << Sequence::NA.new("tttcgatgcc")
      match = alignment.convert_match
      assert_equal(alignment[0], match[0], "first sequence altered")
      assert_equal("tt.....gcc", match[1], "wrong match")
    end

    # Alignment#convert_unmatch

    def test_convert_unmatch
      alignment = Alignment.new
      alignment << Sequence::NA.new("agtcgattaa")
      alignment << Sequence::NA.new("tt.....gcc")
      unmatched = alignment.convert_unmatch
      assert_equal("agtcgattaa", unmatched[0], "first changed")
      assert_equal("tttcgatgcc", unmatched[1], "second wrong")
    end

    def test_convert_unmatch_multiple_sequences
      alignment = Alignment.new
      alignment << Sequence::NA.new("agtcgattaa")
      alignment << Sequence::NA.new("tt.....gcc")
      alignment << Sequence::NA.new("c...c..g.c")
      unmatched = alignment.convert_unmatch
      assert_equal("agtcgattaa", unmatched[0], "first changed")
      assert_equal("tttcgatgcc", unmatched[1], "second wrong")
      assert_equal("cgtccatgac", unmatched[2], "third wrong")
    end

    def test_convert_unmatch_different_length_sequences_truncates_seq_if_last_matched
      alignment = Alignment.new
      alignment << Sequence::NA.new("agtcgatta")
      alignment << Sequence::NA.new("tt.....gc.")
      unmatched = alignment.convert_unmatch
      assert_equal("agtcgatta", unmatched[0], "first changed")
      assert_equal("tttcgatgc", unmatched[1], "second wrong") #TODO: verify this is correct, and not . at end
    end

    def test_convert_unmatch_different_match_char
      alignment = Alignment.new
      alignment << Sequence::NA.new("agtcga")
      alignment << Sequence::NA.new("tt====")
      unmatched = alignment.convert_unmatch('=')
      assert_equal("agtcga", unmatched[0], "first changed")
      assert_equal("tttcga", unmatched[1], "second wrong")
    end
    
    # Alignment#match_line

    def test_match_line_protein
      alignment = Alignment.new
      alignment << Sequence::AA.new("AELFMCF")
      alignment << Sequence::AA.new("AKLVNNF")
      assert_equal                  "*:*.  *", alignment.match_line
    end

    #TODO: lots more on the consensus, match, etc.

    # Alignment#normalize 

    def test_normalizebang_extends_sequences_with_gaps
      alignment = build_na_alignment("a", "ag", "agc", "agct")
      alignment.normalize!
      assert_equal({0=>"a---",1=>"ag--",2=>"agc-",3=>"agct"}, alignment.to_hash)
    end

    # Alignment#to_clustal
  end
end
