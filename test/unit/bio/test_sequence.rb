#
# test/unit/bio/test_sequence.rb - Unit test for Bio::Sequencce
#
# Copyright::  Copyright (C) 2004
#              Moses Hohman <mmhohman@northwestern.edu>
#              2006 Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_sequence.rb,v 1.9 2007/04/05 23:35:42 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/sequence'

module Bio
  class TestSequence < Test::Unit::TestCase

    def setup
      @na  = Sequence::NA.new('atgcatgcatgcatgcaaaa')
      @rna = Sequence::NA.new('augcaugcaugcaugcaaaa')
      @aa  = Sequence::AA.new('ACDEFGHIKLMNPQRSTVWYU')
    end


    # "main" method tests translated into unit tests
    
    # Test Sequence::NA.new
    
    def test_DNA_new_blank_sequence
      sequence = Sequence::NA.new('')
      assert_equal(0, sequence.size)
    end
    
    def test_DNA_new_sequence_downcases_symbols
      string = 'atgcatgcATGCATGCAAAA'
      sequence = Sequence::NA.new(string)
      assert_equal(string.downcase, sequence.to_s)
    end
    
    def test_RNA_new_sequence
      string = 'augcaugcaugcaugcaaaa'
      sequence = Sequence::NA.new(string)
      assert_equal(string, sequence.to_s)
    end
    
    # added
    
    def test_DNA_new_sequence_removes_whitespace
      sequence = Sequence::NA.new("a g\tc\nt\ra")
      assert_equal("agcta", sequence)
    end

    # Test Sequence::AA.new
    
    def test_AA_new_blank_sequence
      sequence = Sequence::AA.new('')
      assert_equal(0, sequence.size)
    end

    def test_AA_new_sequence_all_legal_symbols
      string = 'ACDEFGHIKLMNPQRSTVWYU'
      sequence = Sequence::AA.new(string)
      assert_equal(string, sequence.to_s)
    end

    # added
    
    def test_AA_new_sequence_upcases_symbols
      string = 'upcase'
      sequence = Sequence::AA.new(string)
      assert_equal(string.upcase, sequence.to_s)
    end

    def test_AA_new_sequence_removes_whitespace
      sequence = Sequence::AA.new("S T\tR\nI\rP")
      assert_equal("STRIP", sequence)
    end

    # test element indexing
    
    def test_element_reference_operator_with_two_arguments
      sequence = Sequence::NA.new("atggggggtc")
      assert_equal("gggggg", sequence[2,6])
    end
    
    # added
    def test_element_reference_operator_with_one_argument
      sequence = Sequence::NA.new("atggggggtc")
      assert_equal(?t, sequence[1])
    end
    
    
    # Test Sequence#total
    
    def test_total
      sequence = Sequence::NA.new("catccagtccctggt")
      assert_equal(2346, sequence.total({'a'=>1000, 'g'=>100, 't'=>10, 'c'=>1}))
    end

    # Test Sequence#composition
    
    def test_dna_composition
      sequence = Sequence::NA.new("aggtttcccc")
      expected = {'a'=>1,'g'=>2,'t'=>3,'c'=>4}
      expected.default = 0
      assert_equal(expected, sequence.composition)
    end

    def test_rna_composition
      sequence = Sequence::NA.new("agguuucccc")
      expected = {'a'=>1,'g'=>2,'u'=>3,'c'=>4}
      expected.default = 0
      assert_equal(expected, sequence.composition)
    end

    # I don't get splicing

    # Test Sequence::NA#complement

    def test_dna_sequence_complement
      assert_equal('ttttgcatgcatgcatgcat', @na.complement)
    end

    def test_rna_sequence_complement
      assert_equal('uuuugcaugcaugcaugcau', @rna.complement)
    end
    
    def test_ambiguous_dna_sequence_complement
      assert_equal("nwsbvhdkmyrcgta", Sequence::NA.new('tacgyrkmhdbvswn').complement)
    end

    def test_ambiguous_rna_sequence_complement
      assert_equal("nwsbvhdkmyrcgua", Sequence::NA.new('uacgyrkmhdbvswn').complement)
    end

    # Test Sequence::NA#translate

    def test_dna_sequence_translate
      assert_equal("MHACMQ", @na.translate)
    end

    def test_rna_sequence_translate
      assert_equal("MHACMQ", @rna.translate)
    end

    # Test Sequence::NA#gc_percent

    def test_dna_gc_percent
      assert_equal(40, @na.gc_percent)
    end

    def test_rna_gc_percent
      assert_equal(40, @rna.gc_percent)
    end

    # Test Sequence::NA#illegal_bases

    def test_valid_dna_sequence_illegal_bases
      assert_equal([], @na.illegal_bases)
    end

    def test_invalid_nucleic_acid_illegal_bases
      string = 'tacgyrkmhdbvswn'
      expected = []
      string[4..-1].each_byte { |val| expected << val.chr }
      assert_equal(expected.sort, Sequence::NA.new(string).illegal_bases)
    end

    def test_invalid_nucleic_acid_illegal_bases_more
      string = ('abcdefghijklmnopqrstuvwxyz-!%#$@')
      expected = []
      'bdefhijklmnopqrsvwxyz-!%#$@'.each_byte { |val| expected << val.chr }
      assert_equal(expected.sort, Sequence::NA.new(string).illegal_bases)
    end

    # Test Sequence::NA#molecular_weight

    def test_dna_molecular_weight
      assert_in_delta(6174.3974, @na.molecular_weight, 1e-5)
    end
    
    def test_rna_molecular_weight
      assert_in_delta(6438.2774, @rna.molecular_weight, 1e-5)
    end

    # Test Sequence::NA#to_re

    def test_dna_to_re
      assert_equal(/atgc[agr][tcy][acm][tgk][atgrwkd][atcwmyh][agcmrsv][tgcyskb][gcw][atw][atgcyrwskmbdhvn]/, Sequence::NA.new('atgcrymkdhvbswn').to_re)
    end

    def test_rna_to_re
      assert_equal(/augc[agr][ucy][acm][ugk][augrwkd][aucwmyh][agcmrsv][ugcyskb][gcw][auw][augcyrwskmbdhvn]/, Sequence::NA.new('augcrymkdhvbswn').to_re)
    end

    # Test Sequence::NA#names

    def test_nucleic_acid_names
      # It is a Bio::NucleicAcid feature.
      #      assert_equal(["adenine", "cytosine", "guanine", "thymine", "uracil"], Sequence::NA.new('acgtu').names)
      assert(Sequence::NA.new('acgtu').names)
    end

    # Test Sequence::NA#pikachu

    def test_dna_pikachu
      assert_equal("pika", Sequence::NA.new('atgc').pikachu)
    end

    def test_rna_pikachu
      assert_equal("pika", Sequence::NA.new('augc').pikachu)
    end

    # Test Sequence::NA#randomize

    def test_randomize_dna_retains_composition
      assert_equal(@na.composition, @na.randomize.composition)
    end

    # this test has a neglibly small chance of failure
    def test_two_consecutive_dna_randomizations_not_equal
      assert_not_equal(@na.randomize, @na.randomize)
    end

    def test_randomize_dna_can_be_chained
      assert_equal(@na.composition, @na.randomize.randomize.composition)
    end

    def test_randomize_dna_with_block
      appended = ""
      @na.randomize {|x| appended << x}
      assert_equal(@na.composition, Sequence::NA.new(appended).composition)
    end

    # Test Sequence::NA.randomize(counts)

    def test_NA_randomize_with_counts
      counts = {'a'=>10,'c'=>20,'g'=>30,'u'=>40}
      counts.default = 0
      assert_equal(counts, Sequence::NA.randomize(counts).composition)
    end

    def test_NA_randomize_with_counts_and_block
      appended = ""
      counts = {'a'=>10,'c'=>20,'g'=>30,'u'=>40}
      counts.default = 0
      Sequence::NA.randomize(counts) {|x| appended << x}
      assert_equal(counts, Sequence::NA.new(appended).composition)
    end

    # Test Sequence::AA#codes

    def test_amino_acid_codes
      assert_equal(["Ala", "Cys", "Asp", "Glu", "Phe", "Gly", "His", "Ile", "Lys", 
                    "Leu", "Met", "Asn", "Pro", "Gln", "Arg", "Ser", "Thr", "Val", "Trp", 
                    "Tyr", "Sec"], @aa.codes)
    end

    # Test Sequence::AA#names

    def test_amino_acid_names
      assert_equal(["alanine", "cysteine", "aspartic acid", "glutamic acid", "phenylalanine",
                    "glycine", "histidine", "isoleucine", "lysine", "leucine", "methionine",
                    "asparagine", "proline", "glutamine", "arginine", "serine", "threonine",
                    "valine", "tryptophan", "tyrosine", "selenocysteine"], @aa.names)
    end

    # Test Sequence::AA#molecular_weight

    def test_amino_acid_molecular_weight
      assert_in_delta(2395.725, @aa.subseq(1,20).molecular_weight, 0.0001)
    end

    #Test Sequence::AA#randomize

    def test_amino_acid_randomize_has_same_composition
      aaseq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDA'
      s = Sequence::AA.new(aaseq)
      assert_equal(s.composition, s.randomize.composition)
    end

    # this test has a neglibly small chance of failure
    def test_consecutive_amino_acid_randomizes_are_not_equal
      aaseq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDA'
      s = Sequence::AA.new(aaseq)
      assert_not_equal(s.randomize, s.randomize)
    end

    def test_amino_acid_randomize_can_be_chained
      aaseq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDA'
      s = Sequence::AA.new(aaseq)
      assert_equal(s.randomize.composition, s.randomize.randomize.composition)
    end
  end


  class TestNATranslate < Test::Unit::TestCase
    def setup
      @obj = Bio::Sequence::NA.new("AAA")
    end

    def test_translate
      assert_equal("K", @obj.translate)
    end
    def test_translate_1
      assert_equal("K", @obj.translate(1))
    end
    def test_translate_2
      assert_equal("", @obj.translate(2))
    end
    def test_translate_3
      assert_equal("", @obj.translate(3))
    end
    def test_translate_4
      assert_equal("F", @obj.translate(4))
    end
    def test_translate_5
      assert_equal("", @obj.translate(5))
    end
    def test_translate_5
      assert_equal("", @obj.translate(6))
    end
  end

end
