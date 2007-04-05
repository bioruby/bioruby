#
# = test/unit/bio/appl/test_pts1.rb - Unit test for Bio::PTS1
#
# Copyright::   Copyright (C) 2006 
#               Mitsuteru Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: test_pts1.rb,v 1.3 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/pts1'


module Bio

  class TestPTS1Constant < Test::Unit::TestCase
    def test_FUNCTION
      keys = ['METAZOA-specific','FUNGI-specific','GENERAL'].sort
      assert_equal(keys, Bio::PTS1::FUNCTION.keys.sort)
    end

  end

  class TestPTS1New < Test::Unit::TestCase
    def test_metazoa
      pts1 = Bio::PTS1.new_with_metazoa_function
      assert_equal('METAZOA-specific', pts1.function)
    end

    def test_fungi
      pts1 = Bio::PTS1.new_with_fungi_function
      assert_equal('FUNGI-specific', pts1.function)
    end

    def test_general
      pts1 = Bio::PTS1.new_with_general_function
      assert_equal('GENERAL', pts1.function)
    end
  end

  class TestPTS1 < Test::Unit::TestCase

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

  class TestPTS1Report < Test::Unit::TestCase
    def setup
      serv = Bio::PTS1.new
      seq = ">hoge\nAVSFLSMRRARL\n"
      @report = serv.exec(seq)
    end
    

    def test_output_size
      assert_equal(1634, @report.output.size)
    end

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
