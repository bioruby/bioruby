#
# test/bio/test_alignment.rb - Unit test for Bio::Alignment
#
#   Copyright (C) 2004 Moses Hohman <mmhohman@northwestern.edu>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: test_alignment.rb,v 1.1 2004/11/12 02:27:08 k Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), [".."]*2, "lib")).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/alignment'

module Bio
    class TestAlignment < Test::Unit::TestCase

	def test_equals
	    seqs1 = []
	    seqs1 << Sequence::NA.new("agct")
	    seqs1 << Sequence::NA.new("tagc")
	    alignment1 = Alignment.new(seqs1)

	    seqs2 = []
	    seqs2 << Sequence::NA.new("agct")
	    seqs2 << Sequence::NA.new("tagc")
	    alignment2 = Alignment.new(seqs2)

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
	    alignment = Alignment.new
	    alignment << Sequence::NA.new("agt")
	    assert_equal(3, alignment.seq_length)
	end

	def test_seq_length_is_max_seq_length
	    alignment = Alignment.new
	    alignment << Sequence::NA.new("agt")
	    alignment << Sequence::NA.new("agtaa")
	    alignment << Sequence::NA.new("agta")
	    assert_equal(5, alignment.seq_length)
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
	    alignment = Alignment.new
	    alignment << Sequence::NA.new("agtcgattaa")
	    alignment << Sequence::NA.new("tttcgatgcc")
	    assert_equal("??tcgat???", alignment.consensus_string)
	end

	def test_consensus_threshold
	    alignment = Alignment.new
	    alignment << Sequence::NA.new("agtcgattaa")
	    alignment << Sequence::NA.new("tttcgatgcc")
	    assert_equal("agtcgattaa", alignment.consensus(0.5)) #TODO: verify
	    assert_equal("??tcgat???", alignment.consensus(0.500000001)) #TODO: verify
	end

	def test_consensus_opt_gap_mode
	    alignment = Alignment.new
	    alignment << Sequence::NA.new("agt?gatt?a")
	    alignment << Sequence::NA.new("tttcgatgc?")
	    assert_equal("??tcgat?ca", alignment.consensus(1, :gap_mode => -1), "gap mode -1") #TODO verify
	    assert_equal("??t?gat???", alignment.consensus(1, :gap_mode => 0), "gap mode 0") #TODO verify
	    assert_equal("??t-gat?--", alignment.consensus(1, :gap_mode => 1), "gap mode 1") #TODO verify
	end

	def test_consensus_opt_missing_char
	    alignment = Alignment.new
	    alignment << Sequence::NA.new("agtcgattaa")
	    alignment << Sequence::NA.new("tttcgatgcc")
	    assert_equal("**tcgat***", alignment.consensus(1, :missing_char => "*"))
	end

	#TODO: Repeat opt tests above for consensus_iupac

	# Alignment#consensus_iupac

	def test_consensus_string_no_gaps
	    alignment = Alignment.new
	    alignment << Sequence::NA.new("agtcgattaa")
	    alignment << Sequence::NA.new("tttcgatgcc")
	    assert_equal("wktcgatkmm", alignment.consensus_iupac)
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
	    assert_equal("*:*.  *", alignment.match_line)
	end

	#TODO: lots more on the consensus, match, etc.

	# Alignment#normalize 

	def test_normalizebang_extends_sequences_with_gaps
	    alignment = Alignment.new
	    alignment << Sequence::NA.new("a")
	    alignment << Sequence::NA.new("ag")
	    alignment << Sequence::NA.new("agc")
	    alignment << Sequence::NA.new("agct")
	    alignment.normalize!
	    assert_equal({0=>"a---",1=>"ag--",2=>"agc-",3=>"agct"}, alignment.to_hash)
	end

	# Alignment#to_clustal
    end
end

