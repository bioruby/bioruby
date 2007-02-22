#
# test/unit/bio/appl/iprscan/test_report.rb - Unit test for Bio::InterProScan::Report
#
#   Copyright (C) 2006 Mitsuteru Nakao <n@bioruby.org>
#
#  $Id: test_report.rb,v 1.3 2007/02/22 08:44:34 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/iprscan/report'


module Bio
  class TestIprscanData
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), [".."] * 5)).cleanpath.to_s
    TestDataIprscan = Pathname.new(File.join(bioruby_root, "test", "data", "iprscan")).cleanpath.to_s
    def self.raw_format
      File.open(File.join(TestDataIprscan, "merged.raw"))
    end

    def self.txt_format
      File.open(File.join(TestDataIprscan, "merged.txt"))
    end

  end
  
  
  class TestIprscanPTxtReport < Test::Unit::TestCase

    def setup
      test_entry=<<-END
slr0002\t860
InterPro\tIPR001264\tGlycosyl transferase, family 51
BlastProDom\tPD001895\tsp_Q55683_SYNY3_Q55683\t2e-37\t292-370
HMMPfam\tPF00912\tTransglycosyl\t8e-104\t204-372
InterPro\tIPR001460\tPenicillin-binding protein, transpeptidase domain
HMMPfam\tPF00905\tTranspeptidase\t5.7e-30\t451-742
InterPro\tNULL\tNULL
ProfileScan\tPS50310\tALA_RICH\t10.224\t805-856
//
END
      @obj = Bio::Iprscan::Report.parse_in_ptxt(test_entry)
    end 
   
 
    def test_query_id
      assert_equal('slr0002', @obj.query_id)
    end

    def test_query_length
      assert_equal(860, @obj.query_length)
    end

    def test_matches_size
      assert_equal(4, @obj.matches.size)
    end
    
    def test_match_ipr_id
      assert_equal('IPR001264', @obj.matches.first.ipr_id)
    end

    def test_match_ipr_description
      assert_equal('Glycosyl transferase, family 51', @obj.matches.first.ipr_description)
    end

    def test_match_method
      assert_equal('BlastProDom', @obj.matches.first.method)
    end

    def test_match_accession
      assert_equal('PD001895', @obj.matches.first.accession)
    end

    def test_match_description
      assert_equal('sp_Q55683_SYNY3_Q55683', @obj.matches.first.description)
    end

    def test_match_evalue
      assert_equal('2e-37', @obj.matches.first.evalue)
    end

    def test_match_match_start
      assert_equal(292, @obj.matches.first.match_start)
    end

    def test_match_match_end
      assert_equal(370, @obj.matches.first.match_end)
    end

  end # TestIprscanPTxtReport


  class TestIprscanTxtEntry < Test::Unit::TestCase
    def setup
      test_txt = Bio::TestIprscanData.txt_format.read.split(/\n\nSequence/)[0]
      @obj = Bio::Iprscan::Report.parse_in_txt(test_txt)
    end 

    def test_iprscan_report_class
      assert_equal(Bio::Iprscan::Report, @obj.class)
    end
 
    def test_query_id
      assert_equal('Q9RHD9', @obj.query_id)
    end

    def test_query_length
      assert_equal(267, @obj.query_length)
    end

    def test_matches_size
      assert_equal(16, @obj.matches.size)
    end
    
    def test_match_ipr_id
      assert_equal('IPR000110', @obj.matches.first.ipr_id)
    end

    def test_match_ipr_description
      assert_equal('Ribosomal protein S1', @obj.matches.first.ipr_description)
    end

    def test_match_method
      assert_equal('FPrintScan', @obj.matches.first.method)
    end

    def test_match_accession
      assert_equal('PR00681', @obj.matches.first.accession)
    end

    def test_match_description
      assert_equal('RIBOSOMALS1', @obj.matches.first.description)
    end

    def test_match_evalue
      assert_equal('1.5e-17', @obj.matches.first.evalue)
    end

    def test_match_match_start
      assert_equal(6, @obj.matches.first.match_start)
    end

    def test_match_match_end
      assert_equal(27, @obj.matches.first.match_end)
    end

    def test_match_go_terms
      ary = [["Molecular Function", "RNA binding", "GO:0003723"], 
             ["Molecular Function", "structural constituent of ribosome", "GO:0003735"], 
             ["Cellular Component", "ribosome", "GO:0005840"], 
             ["Biological Process", "protein biosynthesis", "GO:0006412"]]
      assert_equal(ary, @obj.matches.first.go_terms)
    end
  end # TestIprscanTxtEntry



  class TestIprscanTxtReport < Test::Unit::TestCase
    def setup
      @test_txt = Bio::TestIprscanData.txt_format
    end 

    def test_reports_in_txt 
      Bio::Iprscan::Report.reports_in_txt(@test_txt) do |report|
        assert_equal(Bio::Iprscan::Report, report.class)
      end
    end


  end # TestIprscanTxtReport



  class TestIprscanRawReport < Test::Unit::TestCase
    def setup
      test_raw = Bio::TestIprscanData.raw_format
      entry = ''
      @obj = []
      while line = test_raw.gets
        if entry != '' and entry.split("\t").first == line.split("\t").first
          entry << line
        elsif entry != ''
          @obj << Bio::Iprscan::Report.parse_in_raw(entry)
          entry = line
        else
          entry << line
        end
      end
    end
    
    def test_obj
      assert_equal(2, @obj.size)
    end
    
    def test_query_id
      assert_equal('Q9RHD9', @obj.first.query_id)
    end

    def test_entry_id
      assert_equal('Q9RHD9', @obj.first.entry_id)
    end

    def test_query_length
      assert_equal(267, @obj.first.query_length)
    end
    
    def test_match_query_id
      assert_equal('Q9RHD9', @obj.first.matches.first.query_id)
    end
    
    def test_match_crc64
      assert_equal('D44DAE8C544CB7C1', @obj.first.matches.first.crc64)
    end
    
    def test_match_query_length
      assert_equal(267, @obj.first.matches.first.query_length)
    end
    
    def test_match_method
      assert_equal('HMMPfam', @obj.first.matches.first.method)
    end
    
    def test_match_accession
      assert_equal('PF00575', @obj.first.matches.first.accession)
    end
    
    def test_match_description
      assert_equal('S1', @obj.first.matches.first.description)
    end
    
    def test_match_match_start
      assert_equal(1, @obj.first.matches.first.match_start)
    end
    
    def test_match_match_end
      assert_equal(55, @obj.first.matches.first.match_end)
    end
    
    def test_match_evalue
      assert_equal('3.3E-6', @obj.first.matches.first.evalue)
    end
    
    def test_match_status
      assert_equal('T', @obj.first.matches.first.status)
    end

    def test_match_date
      assert_equal('11-Nov-2005', @obj.first.matches.first.date)
    end

    def test_match_ipr_id
      assert_equal('IPR003029', @obj.first.matches.first.ipr_id)
    end

    def test_match_ipr_description
      assert_equal('RNA binding S1', @obj.first.matches.first.ipr_description)
    end

    def test_match_go_terms
      assert_equal(["Molecular Function:RNA binding (GO:0003723)"], @obj.first.matches.first.go_terms)
    end

  end
end
