#
# test/unit/bio/db/sanger_chromatogram/test_scf.rb - Unit test for Bio::Scf
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
require 'bio/db/sanger_chromatogram/scf'

module Bio

  module TestScfData
    DataPath = Pathname.new(File.join(BioRubyTestDataPath,
                                      'sanger_chromatogram')).cleanpath.to_s
    def self.scf_version_2
      fn = File.join(DataPath, 'test_chromatogram_scf_v2.scf')
      File.open(fn, "rb") { |f| f.read }
    end
    def self.scf_version_3
      fn = File.join(DataPath, 'test_chromatogram_scf_v3.scf')
      File.open(fn, "rb") { |f| f.read }
    end
  end #module TestScfData

  module TestScf_common
    Scf_sequence = "attaacgtaaaaggtttggttggttcgctataaaaactcttattttggataatttgtttagctgttgcaatataaattgacccatttaatttataaattggattctcgttgcaataaatttccagatcctgaaaaagctctggcttaaccaaattgccttggctatcaatgcttctacaccaagaaggctttaaagagataggactaactgaaacgacactttttcccgttgcttgatgtatttcaacagcatgtcttatggtttctggcttcctgaatggagaagttggttgtaaaagcaatacactgtcaaaaaaaacctccatttgctgaaacttaaacaggaggtcaataacagtatgaatcacatccgaagtatccgtggctaaatcttccgatcttagccaaggtactgaagccccatattgaacggann".freeze
    Scf_RC_sequence = "nntccgttcaatatggggcttcagtaccttggctaagatcggaagatttagccacggatacttcggatgtgattcatactgttattgacctcctgtttaagtttcagcaaatggaggttttttttgacagtgtattgcttttacaaccaacttctccattcaggaagccagaaaccataagacatgctgttgaaatacatcaagcaacgggaaaaagtgtcgtttcagttagtcctatctctttaaagccttcttggtgtagaagcattgatagccaaggcaatttggttaagccagagctttttcaggatctggaaatttattgcaacgagaatccaatttataaattaaatgggtcaatttatattgcaacagctaaacaaattatccaaaataagagtttttatagcgaaccaaccaaaccttttacgttaat".freeze
      
    Scf_first_10_peak_indices = [16,24,37,49,64,64,80,92,103,113].freeze
    Scf_last_10_peak_indices = [5120,5132,5145,5157,5169,5182,5195,5207,5219,5231].freeze

    Scf_atrace_size = 5236
      
    Scf_RC_first_10_peak_indices = Scf_last_10_peak_indices.collect{|index| Scf_atrace_size - index}.reverse.freeze
    Scf_RC_last_10_peak_indices = Scf_first_10_peak_indices.collect{|index| Scf_atrace_size - index}.reverse.freeze

    def test_seq
      assert_equal(Scf_sequence, @scf.seq.to_s)
    end
     
    def test_to_biosequence
      assert_equal(Scf_sequence, @scf.to_biosequence.to_s)
    end
    
    def test_complement
      @RC_chromatogram = @scf.complement
      # check reverse complemented sequence
      assert_equal(Scf_RC_sequence, @RC_chromatogram.sequence)
      # check reverse complemented peak indices
      assert_equal(Scf_RC_first_10_peak_indices,
                   @RC_chromatogram.peak_indices.slice(0,10))
      assert_equal(Scf_RC_last_10_peak_indices,
                   @RC_chromatogram.peak_indices.slice(-10..-1))
      # check reverse complemented traces
      assert_equal(@scf.atrace.slice(0,10),
                   @RC_chromatogram.ttrace.slice(-10..-1).reverse)
      assert_equal(@scf.ctrace.slice(0,10),
                   @RC_chromatogram.gtrace.slice(-10..-1).reverse)
      assert_equal(@scf.gtrace.slice(0,10),
                   @RC_chromatogram.ctrace.slice(-10..-1).reverse)
      assert_equal(@scf.ttrace.slice(0,10),
                   @RC_chromatogram.atrace.slice(-10..-1).reverse)
      # check reverse complemented individual and combined qualities
      #if @RC_chromatogram.chromatogram_type == ".scf"
      assert_equal(@scf.aqual.slice(0,10),
                   @RC_chromatogram.tqual.slice(-10..-1).reverse)
      assert_equal(@scf.cqual.slice(0,10),
                   @RC_chromatogram.gqual.slice(-10..-1).reverse)
      assert_equal(@scf.gqual.slice(0,10),
                   @RC_chromatogram.cqual.slice(-10..-1).reverse)
      assert_equal(@scf.tqual.slice(0,10),
                   @RC_chromatogram.aqual.slice(-10..-1).reverse)
      #end
      assert_equal(@scf.qualities.slice(0,10),
                   @RC_chromatogram.qualities.slice(-10..-1).reverse)
    end
  end #module TestScf_common

  class TestScf_version_2 < Test::Unit::TestCase
    include TestScf_common
    def setup
      @scf = Scf.new(TestScfData.scf_version_2)
    end
  end

  class TestScf_version_3 < Test::Unit::TestCase
    include TestScf_common
    def setup
      @scf = Scf.new(TestScfData.scf_version_3)
    end
  end #class TestScf_version_3

end #module Bio
