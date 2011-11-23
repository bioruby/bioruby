#
# = test/functional/bio/appl/test_pts1.rb - Unit test for Bio::PTS1 with network connection
#
# Copyright::   Copyright (C) 2006 
#               Mitsuteru Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/pts1'


module Bio

  class FuncTestPTS1 < Test::Unit::TestCase

    def setup
      @seq =<<END
>AB000464
MRTGGDNAGPSHSHIKRLPTSGLSTWLQGTQTCVLHLPTGTRPPAHHPLLGYSSRRSYRL
LENPAAGCWARFSFCQGAAWDWDLEGVQWLRALAGGVSTAPSAPPGNLVFLSVSIFLCGS
LLLETCPAYFSSLDPD*
END
      @serv = Bio::PTS1.new
    end


    def test_function_set
      @serv.function("GENERAL")
      assert_equal("GENERAL", @serv.function)
    end

    def test_function_show
      assert_equal("METAZOA-specific", @serv.function)
    end

    def test_function_set_number_1
      @serv.function(1)
      assert_equal("METAZOA-specific", @serv.function)
    end

    def test_function_set_number_2
      @serv.function(2)
      assert_equal("FUNGI-specific", @serv.function)
    end

    def test_function_set_number_3
      @serv.function(3)
      assert_equal("GENERAL", @serv.function)
    end


    def test_exec
      report = @serv.exec(@seq)
      assert_equal(Bio::PTS1::Report, report.class)
    end

    def test_exec_with_faa
      report = @serv.exec(Bio::FastaFormat.new(@seq))
      assert_equal(Bio::PTS1::Report, report.class)
    end

  end

  class FuncTestPTS1Report < Test::Unit::TestCase
    def setup
      serv = Bio::PTS1.new
      seq = ">hoge\nAVSFLSMRRARL\n"
      @report = serv.exec(seq)
    end
    

    #def test_output_size
    #  assert_equal(1634, @report.output.size)
    #end

    def test_entry_id
      assert_equal("hoge", @report.entry_id)
    end

    def test_prediction
      assert_equal("Targeted", @report.prediction)
    end
    
    def test_cterm
      assert_equal("AVSFLSMRRARL", @report.cterm)
    end
    
    def test_score
      assert_equal("7.559", @report.score)
    end

    def test_fp
      assert_equal("2.5e-04", @report.fp)
    end
    
    def test_sppta
      assert_equal("-5.833", @report.sppta)
    end
    
    def test_spptna
      assert_equal("-1.698", @report.spptna)
    end

    def test_profile
      assert_equal("15.091", @report.profile)
    end
  end
end
