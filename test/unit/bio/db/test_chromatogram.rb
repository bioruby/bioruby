#
# Copyright::	Copyright (C) 2009 Anthony Underwood <anthony.underwood@hpa.org.uk>, <email2ants@gmail.com>
# License::	The Ruby License
#
require 'test/unit'
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), [".."] * 4, "lib")).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)
require 'bio/db/chromatogram'
require 'bio/db/chromatogram/scf'
require 'bio/db/chromatogram/abi'

module Bio

  class TestChromatogramData
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s
    TestChromatogramData = Pathname.new(File.join(bioruby_root, 'test', 'data', 'chromatogram')).cleanpath.to_s
    def self.scf_version_2
      File.open(File.join(TestChromatogramData, 'test_chromatogram_scf_v2.scf')).read
    end
    def self.scf_version_3
      File.open(File.join(TestChromatogramData, 'test_chromatogram_scf_v3.scf')).read
    end
    def self.abi
      File.open(File.join(TestChromatogramData, 'test_chromatogram_abi.ab1')).read
    end
  end

  class TestChromatogram < Test::Unit::TestCase
    def setup
      @scf_version_2 = Scf.new(TestChromatogramData.scf_version_2)
      @scf_version_3 = Scf.new(TestChromatogramData.scf_version_3)
      @abi = Abi.new(TestChromatogramData.abi)

      @scf_version_2_sequence = "attaacgtaaaaggtttggttggttcgctataaaaactcttattttggataatttgtttagctgttgcaatataaattgacccatttaatttataaattggattctcgttgcaataaatttccagatcctgaaaaagctctggcttaaccaaattgccttggctatcaatgcttctacaccaagaaggctttaaagagataggactaactgaaacgacactttttcccgttgcttgatgtatttcaacagcatgtcttatggtttctggcttcctgaatggagaagttggttgtaaaagcaatacactgtcaaaaaaaacctccatttgctgaaacttaaacaggaggtcaataacagtatgaatcacatccgaagtatccgtggctaaatcttccgatcttagccaaggtactgaagccccatattgaacggann"
      @scf_version_2_RC_sequence = "nntccgttcaatatggggcttcagtaccttggctaagatcggaagatttagccacggatacttcggatgtgattcatactgttattgacctcctgtttaagtttcagcaaatggaggttttttttgacagtgtattgcttttacaaccaacttctccattcaggaagccagaaaccataagacatgctgttgaaatacatcaagcaacgggaaaaagtgtcgtttcagttagtcctatctctttaaagccttcttggtgtagaagcattgatagccaaggcaatttggttaagccagagctttttcaggatctggaaatttattgcaacgagaatccaatttataaattaaatgggtcaatttatattgcaacagctaaacaaattatccaaaataagagtttttatagcgaaccaaccaaaccttttacgttaat"
      
      @scf_version_3_sequence = @scf_version_2_sequence # they are the same sequence but in scf 2 and 3 formats
      @scf_version_3_RC_sequence = @scf_version_2_RC_sequence
      
      @abi_sequence = "nnnnnnnnnnnttggttggttcgctataaaaactcttattttggataatttgtttagctgttgcaatataaattgacccatttaatttataaattggattctcgttgcaataaatttccagatcctgaaaaagctctggcttaaccaaattgccttggctatcaatgcttctacaccaagaaggctttaaagagataggactaactgaaacgacactttttcccgttgcttgatgtatttcaacagcatgtcttatggtttctggcttcctgaatggagaagttggttgtaaaagcaatacactgtcaaaaaaaacctccatttgctgaaacttaaacaggaggtcaataacagtatgaatcacatccgaagtatccgtggctaaatcttccgatcttagccaaggtactgaagccccatattgaacn"
      @abi_RC_sequence = "ngttcaatatggggcttcagtaccttggctaagatcggaagatttagccacggatacttcggatgtgattcatactgttattgacctcctgtttaagtttcagcaaatggaggttttttttgacagtgtattgcttttacaaccaacttctccattcaggaagccagaaaccataagacatgctgttgaaatacatcaagcaacgggaaaaagtgtcgtttcagttagtcctatctctttaaagccttcttggtgtagaagcattgatagccaaggcaatttggttaagccagagctttttcaggatctggaaatttattgcaacgagaatccaatttataaattaaatgggtcaatttatattgcaacagctaaacaaattatccaaaataagagtttttatagcgaaccaaccaannnnnnnnnnn"
      
      
      @scf_version_2_first_10_peak_indices = [16,24,37,49,64,64,80,92,103,113]
      @scf_version_2_last_10_peak_indices = [5120,5132,5145,5157,5169,5182,5195,5207,5219,5231]
      
      @scf_version_2_RC_first_10_peak_indices = @scf_version_2_last_10_peak_indices.collect{|index| @scf_version_2.atrace.size - index}.reverse
      @scf_version_2_RC_last_10_peak_indices = @scf_version_2_first_10_peak_indices.collect{|index| @scf_version_2.atrace.size - index}.reverse
      
      @scf_version_3_first_10_peak_indices = @scf_version_2_first_10_peak_indices
      @scf_version_3_last_10_peak_indices = @scf_version_2_last_10_peak_indices
      @scf_version_3_RC_first_10_peak_indices = @scf_version_2_RC_first_10_peak_indices
      @scf_version_3_RC_last_10_peak_indices = @scf_version_2_RC_last_10_peak_indices
      
      @abi_first_10_peak_indices = [3, 16,38,61,66,91,105,115,138,151]
      @abi_last_10_peak_indices = [5070,5081,5094,5107,5120,5133,5145,5157,5169,5182]
      @abi_RC_first_10_peak_indices = @abi_last_10_peak_indices.collect{|index| @abi.atrace.size - index}.reverse
      @abi_RC_last_10_peak_indices = @abi_first_10_peak_indices.collect{|index| @abi.atrace.size - index}.reverse

    end

    def test_seq
      assert_equal(@scf_version_2.seq.to_s, @scf_version_2_sequence)
      assert_equal(@scf_version_3.seq.to_s, @scf_version_3_sequence)
      assert_equal(@abi.seq.to_s, @abi_sequence)
    end
     
    def test_to_biosequence
      assert_equal(@scf_version_2.to_biosequence.to_s, @scf_version_2_sequence)
      assert_equal(@scf_version_3.to_biosequence.to_s, @scf_version_3_sequence)
      assert_equal(@abi.to_biosequence.to_s, @abi_sequence)
    end
    
    def test_complement
      ["scf_version_2" , "scf_version_3", "abi"].each do |chromatogram_type|
        @RC_chromatogram = instance_variable_get("@#{chromatogram_type}").complement
        # check reverse complemented sequence
        assert_equal(@RC_chromatogram.sequence, instance_variable_get("@#{chromatogram_type}_RC_sequence"))
        # check reverse complemented peak indices
        assert_equal(@RC_chromatogram.peak_indices.slice(0,10) , instance_variable_get("@#{chromatogram_type}_RC_first_10_peak_indices"))
        assert_equal(@RC_chromatogram.peak_indices.slice(-10..-1) , instance_variable_get("@#{chromatogram_type}_RC_last_10_peak_indices"))
        # check reverse complemented traces
        assert_equal(instance_variable_get("@#{chromatogram_type}").atrace.slice(0,10), @RC_chromatogram.ttrace.slice(-10..-1).reverse)
        assert_equal(instance_variable_get("@#{chromatogram_type}").ctrace.slice(0,10), @RC_chromatogram.gtrace.slice(-10..-1).reverse)
        assert_equal(instance_variable_get("@#{chromatogram_type}").gtrace.slice(0,10), @RC_chromatogram.ctrace.slice(-10..-1).reverse)
        assert_equal(instance_variable_get("@#{chromatogram_type}").ttrace.slice(0,10), @RC_chromatogram.atrace.slice(-10..-1).reverse)
        # check reverse complemented individual and combined qualities
        if @RC_chromatogram.chromatogram_type == ".scf"
          assert_equal(instance_variable_get("@#{chromatogram_type}").aqual.slice(0,10), @RC_chromatogram.tqual.slice(-10..-1).reverse)
          assert_equal(instance_variable_get("@#{chromatogram_type}").cqual.slice(0,10), @RC_chromatogram.gqual.slice(-10..-1).reverse)
          assert_equal(instance_variable_get("@#{chromatogram_type}").gqual.slice(0,10), @RC_chromatogram.cqual.slice(-10..-1).reverse)
          assert_equal(instance_variable_get("@#{chromatogram_type}").tqual.slice(0,10), @RC_chromatogram.aqual.slice(-10..-1).reverse)
        end
        assert_equal(instance_variable_get("@#{chromatogram_type}").qualities.slice(0,10), @RC_chromatogram.qualities.slice(-10..-1).reverse)
      end
    end
  end
end