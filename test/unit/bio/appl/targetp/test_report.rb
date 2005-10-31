#
# test/unit/bio/appl/targetp/test_report.rb - Unit test for Bio::TargetP::Report
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
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
#  $Id: test_report.rb,v 1.2 2005/10/31 17:59:46 nakao Exp $
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
      assert_equal(Bio::TargetP::Report::DELIMITER, "\n \n")
    end

    def test_rs
      assert_equal(Bio::TargetP::Report::RS, "\n \n")
    end

  end # class TestTargetPReportConst


  class TestTargetPReport < Test::Unit::TestCase

    def setup
      @obj = Bio::TargetP::Report.new(TargetPReport_plant)
    end

    def test_version
      assert_equal(@obj.version, '1.0')
    end

    def test_query_sequences
      assert_equal(@obj.query_sequences, 0)
    end

    def test_cleavage_site_prediction
      assert_equal(@obj.cleavage_site_prediction, 'not included')
    end

    def test_networks
      assert_equal(@obj.networks, 'PLANT')
    end

    def test_prediction
      hash = {"Name"=>"MGI_2141503", "Loc."=>"_", "RC"=>3, "SP"=>0.271,
              "other"=>0.844, "mTP"=>0.161, "cTP"=>0.031, "Length"=>640}
      assert_equal(@obj.pred, hash)
      assert_equal(@obj.prediction, hash)
    end

    def test_cutoff
      hash = {"SP"=>0.0, "other"=>0.0, "mTP"=>0.0, "cTP"=>0.0}
      assert_equal(@obj.cutoff, hash)
    end


    def test_entry_id
      assert_equal(@obj.entry_id, 'MGI_2141503')
    end

    def test_name
      assert_equal(@obj.name, 'MGI_2141503')
    end

    def test_query_len
      assert_equal(@obj.query_len, 640)
    end

    def test_length
      assert_equal(@obj.length, 640)
    end

    def test_loc
      assert_equal(@obj.loc, '_')
    end

    def test_rc
      assert_equal(@obj.rc, 3)
    end
  end # class TestTargetPReport
end
