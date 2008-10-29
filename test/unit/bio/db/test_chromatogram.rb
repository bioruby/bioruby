require 'test/unit'
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), [".."] * 4, "lib")).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)
require 'bio/db/chromatogram'
require 'bio/db/chromatogram/scf'

module Bio

  class TestChromatogramData
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s
    TestChromatogramData = Pathname.new(File.join(bioruby_root, 'test', 'data', 'chromatogram')).cleanpath.to_s
    def self.input
      File.open(File.join(TestChromatogramData, 'test_chromatogram_scf_v3.scf')).read
    end
  end

  class TestChromatogram < Test::Unit::TestCase
    def setup
      @chromatogram = Scf.new(TestChromatogramData.input)
      @sequence = "attaacgtaaaaggtttggttggttcgctataaaaactcttattttggataatttgtttagctgttgcaatataaattgacccatttaatttataaattggattctcgttgcaataaatttccagatcctgaaaaagctctggcttaaccaaattgccttggctatcaatgcttctacaccaagaaggctttaaagagataggactaactgaaacgacactttttcccgttgcttgatgtatttcaacagcatgtcttatggtttctggcttcctgaatggagaagttggttgtaaaagcaatacactgtcaaaaaaaacctccatttgctgaaacttaaacaggaggtcaataacagtatgaatcacatccgaagtatccgtggctaaatcttccgatcttagccaaggtactgaagccccatattgaacggann"
      @reverse_comp_sequence = "nntccgttcaatatggggcttcagtaccttggctaagatcggaagatttagccacggatacttcggatgtgattcatactgttattgacctcctgtttaagtttcagcaaatggaggttttttttgacagtgtattgcttttacaaccaacttctccattcaggaagccagaaaccataagacatgctgttgaaatacatcaagcaacgggaaaaagtgtcgtttcagttagtcctatctctttaaagccttcttggtgtagaagcattgatagccaaggcaatttggttaagccagagctttttcaggatctggaaatttattgcaacgagaatccaatttataaattaaatgggtcaatttatattgcaacagctaaacaaattatccaaaataagagtttttatagcgaaccaaccaaaccttttacgttaat"
      @first_10_peak_indices = [5,17,29,41,54,67,79,91,104,116]
      @last_10_peak_indices = [5123,5133,5144,5156,5172,5172,5187,5199,5212,5220]
    end

    def test_seq
      assert_equal(@chromatogram.seq.to_s, @sequence)
    end
     
    def test_to_biosequence
      assert_equal(@chromatogram.to_biosequence.to_s, @sequence)
    end
    
    def test_complement
      @reverse_comp_chromatogram = @chromatogram.complement
      # check reverse complemented sequence
      assert_equal(@reverse_comp_chromatogram.sequence, @reverse_comp_sequence)
      # check reverse complemented peak indices
      assert_equal(@reverse_comp_chromatogram.peak_indices.slice(0,10) , @first_10_peak_indices)
      assert_equal(@reverse_comp_chromatogram.peak_indices.slice(-10..-1) , @last_10_peak_indices)
      # check reverse complemented traces
      assert_equal(@chromatogram.atrace.slice(0,10), @reverse_comp_chromatogram.ttrace.slice(-10..-1).reverse)
      assert_equal(@chromatogram.ctrace.slice(0,10), @reverse_comp_chromatogram.gtrace.slice(-10..-1).reverse)
      assert_equal(@chromatogram.gtrace.slice(0,10), @reverse_comp_chromatogram.ctrace.slice(-10..-1).reverse)
      assert_equal(@chromatogram.ttrace.slice(0,10), @reverse_comp_chromatogram.atrace.slice(-10..-1).reverse)
      # check reverse complemented individual and combined qualities
      assert_equal(@chromatogram.aqual.slice(0,10), @reverse_comp_chromatogram.tqual.slice(-10..-1).reverse)
      assert_equal(@chromatogram.cqual.slice(0,10), @reverse_comp_chromatogram.gqual.slice(-10..-1).reverse)
      assert_equal(@chromatogram.gqual.slice(0,10), @reverse_comp_chromatogram.cqual.slice(-10..-1).reverse)
      assert_equal(@chromatogram.tqual.slice(0,10), @reverse_comp_chromatogram.aqual.slice(-10..-1).reverse)
      assert_equal(@chromatogram.qualities.slice(0,10), @reverse_comp_chromatogram.qualities.slice(-10..-1).reverse)
    end
  end
end