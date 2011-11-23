#
# test/unit/bio/db/sanger_chromatogram/test_abif.rb - Unit test for Bio::Abif
#
# Copyright::	Copyright (C) 2009 Anthony Underwood <anthony.underwood@hpa.org.uk>, <email2ants@gmail.com>
# License::	The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/sanger_chromatogram/chromatogram'
require 'bio/db/sanger_chromatogram/abif'

module Bio

  module TestAbifData
    DataPath = Pathname.new(File.join(BioRubyTestDataPath,
                                      'sanger_chromatogram')).cleanpath.to_s
    def self.abif
      fn = File.join(DataPath, 'test_chromatogram_abif.ab1')
      File.open(fn, 'rb') { |f| f.read }
    end
  end #module TestAbifData

  class TestAbif < Test::Unit::TestCase

    Abif_sequence = "nnnnnnnnnnnttggttggttcgctataaaaactcttattttggataatttgtttagctgttgcaatataaattgacccatttaatttataaattggattctcgttgcaataaatttccagatcctgaaaaagctctggcttaaccaaattgccttggctatcaatgcttctacaccaagaaggctttaaagagataggactaactgaaacgacactttttcccgttgcttgatgtatttcaacagcatgtcttatggtttctggcttcctgaatggagaagttggttgtaaaagcaatacactgtcaaaaaaaacctccatttgctgaaacttaaacaggaggtcaataacagtatgaatcacatccgaagtatccgtggctaaatcttccgatcttagccaaggtactgaagccccatattgaacn".freeze
    Abif_RC_sequence = "ngttcaatatggggcttcagtaccttggctaagatcggaagatttagccacggatacttcggatgtgattcatactgttattgacctcctgtttaagtttcagcaaatggaggttttttttgacagtgtattgcttttacaaccaacttctccattcaggaagccagaaaccataagacatgctgttgaaatacatcaagcaacgggaaaaagtgtcgtttcagttagtcctatctctttaaagccttcttggtgtagaagcattgatagccaaggcaatttggttaagccagagctttttcaggatctggaaatttattgcaacgagaatccaatttataaattaaatgggtcaatttatattgcaacagctaaacaaattatccaaaataagagtttttatagcgaaccaaccaannnnnnnnnnn".freeze

    Abif_first_10_peak_indices = [3, 16,38,61,66,91,105,115,138,151].freeze
    Abif_last_10_peak_indices = [5070,5081,5094,5107,5120,5133,5145,5157,5169,5182].freeze

    Abif_atrace_size = 5236

    Abif_RC_first_10_peak_indices = Abif_last_10_peak_indices.collect{|index| Abif_atrace_size - index}.reverse.freeze
    Abif_RC_last_10_peak_indices = Abif_first_10_peak_indices.collect{|index| Abif_atrace_size - index}.reverse.freeze

    def setup
      @abi = Abif.new(TestAbifData.abif)
    end

    def test_seq
      assert_equal(Abif_sequence, @abi.seq.to_s)
    end
     
    def test_to_biosequence
      assert_equal(Abif_sequence, @abi.to_biosequence.to_s)
    end
    
    def test_complement
      @RC_chromatogram = @abi.complement
      # check reverse complemented sequence
      assert_equal(Abif_RC_sequence, @RC_chromatogram.sequence)
      # check reverse complemented peak indices
      assert_equal(Abif_RC_first_10_peak_indices,
                   @RC_chromatogram.peak_indices.slice(0,10))
      assert_equal(Abif_RC_last_10_peak_indices,
                   @RC_chromatogram.peak_indices.slice(-10..-1))
      # check reverse complemented traces
      assert_equal(@abi.atrace.slice(0,10),
                   @RC_chromatogram.ttrace.slice(-10..-1).reverse)
      assert_equal(@abi.ctrace.slice(0,10),
                   @RC_chromatogram.gtrace.slice(-10..-1).reverse)
      assert_equal(@abi.gtrace.slice(0,10),
                   @RC_chromatogram.ctrace.slice(-10..-1).reverse)
      assert_equal(@abi.ttrace.slice(0,10),
                   @RC_chromatogram.atrace.slice(-10..-1).reverse)

      assert_equal(@abi.qualities.slice(0,10),
                   @RC_chromatogram.qualities.slice(-10..-1).reverse)
    end
  end
end
