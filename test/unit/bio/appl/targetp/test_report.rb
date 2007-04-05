#
# test/unit/bio/appl/targetp/test_report.rb - Unit test for Bio::TargetP::Report
#
# Copyright:  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::   The Ruby License
#
#  $Id: test_report.rb,v 1.5 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/targetp/report'


module Bio

  TargetPReport_plant =<<HOGE
 
### ### ###  T A R G E T P  1.0  prediction results  ### ### ### 
 
# Number of input sequences:  1
# Cleavage site predictions not included.
# Using PLANT networks.
 
#                        Name   Length	  cTP   mTP    SP other  Loc.  RC
#----------------------------------------------------------------------------------
                   MGI_2141503	  640	0.031 0.161 0.271 0.844   _     3
#----------------------------------------------------------------------------------
# cutoff                                 0.00  0.00  0.00  0.00


HOGE

TargetPReport_plant_c =<<HOGE
 
### ### ###  T A R G E T P  1.0  prediction results  ### ### ### 
 
# Number of input sequences:  1
# Cleavage site predictions included.
# Using PLANT networks.
 
#                        Name   Length	  cTP   mTP    SP other  Loc.  RC     TPlen
#----------------------------------------------------------------------------------
                   MGI_2141503	  640	0.031 0.161 0.271 0.844   _     3	  -
#----------------------------------------------------------------------------------
# cutoff                                 0.00  0.00  0.00  0.00



HOGE

TargetPReport_non_plant_c =<<HOGE
 
### ### ###  T A R G E T P  1.0  prediction results  ### ### ### 
 
# Number of input sequences:  1
# Cleavage site predictions included.
# Using NON-PLANT networks.
 
#                        Name   Length    mTP   SP  other  Loc.  RC   TPlen
#--------------------------------------------------------------------------
                     MGI_96083	 2187	0.292 0.053 0.746   _     3	  -
#--------------------------------------------------------------------------
# cutoff                                 0.00  0.00  0.00



HOGE


  class TestTargetPReportConst  < Test::Unit::TestCase

    def test_delimiter
      assert_equal("\n \n", Bio::TargetP::Report::DELIMITER)
    end

    def test_rs
      assert_equal("\n \n", Bio::TargetP::Report::RS)
    end

  end # class TestTargetPReportConst


  class TestTargetPReport < Test::Unit::TestCase

    def setup
      @obj = Bio::TargetP::Report.new(TargetPReport_plant)
    end

    def test_version
      assert_equal('1.0', @obj.version)
    end

    def test_query_sequences
      assert_equal(0, @obj.query_sequences)
    end

    def test_cleavage_site_prediction
      assert_equal('not included', @obj.cleavage_site_prediction)
    end

    def test_networks
      assert_equal('PLANT', @obj.networks)
    end

    def test_prediction
      hash = {"Name"=>"MGI_2141503", "Loc."=>"_", "RC"=>3, "SP"=>0.271,
              "other"=>0.844, "mTP"=>0.161, "cTP"=>0.031, "Length"=>640}
      assert_equal(hash, @obj.pred)
      assert_equal(hash, @obj.prediction)
    end

    def test_cutoff
      hash = {"SP"=>0.0, "other"=>0.0, "mTP"=>0.0, "cTP"=>0.0}
      assert_equal(hash, @obj.cutoff)
    end


    def test_entry_id
      assert_equal('MGI_2141503', @obj.entry_id)
    end

    def test_name
      assert_equal('MGI_2141503', @obj.name)
    end

    def test_query_len
      assert_equal(640, @obj.query_len)
    end

    def test_length
      assert_equal(640, @obj.length)
    end

    def test_loc
      assert_equal('_', @obj.loc)
    end

    def test_rc
      assert_equal(3, @obj.rc)
    end
  end # class TestTargetPReport
end
