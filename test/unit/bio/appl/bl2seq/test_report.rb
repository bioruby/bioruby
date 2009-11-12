#
# test/unit/bio/appl/bl2seq/test_report.rb - Unit test for 
# Bio::Blast::Bl2seq::Report
#
#  Copyright::   Copyright (C) 2006 
#                Mitsuteru C. Nakao <n@bioruby.org>
#  License::     The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/bl2seq/report'


module Bio
  class TestBl2seqReportData
    TestDataBl2seq = Pathname.new(File.join(BioRubyTestDataPath, 'bl2seq')).cleanpath.to_s

    def self.output(format = 7)
      case format
      when 'empty'
        File.open(File.join(TestDataBl2seq, 'cd8a_p53_e-5blastp.bl2seq')).read 
      when 'blastp'
        File.open(File.join(TestDataBl2seq, 'cd8a_cd8b_blastp.bl2seq')).read 
      when 'blastn'
      when 'blastx'
      when 'tblastn'
      when 'tblastx'
      end
    end
  end


  class TestBl2seqReportConstants < Test::Unit::TestCase
    def test_rs
      rs = nil
      assert_equal(nil, Bio::Blast::Bl2seq::Report::RS)
      assert_equal(nil, Bio::Blast::Bl2seq::Report::DELIMITER)
    end
  end


  class TestBl2seqReport < Test::Unit::TestCase

    def setup
      @empty = Bio::Blast::Bl2seq::Report.new(Bio::TestBl2seqReportData.output('empty'))
      @blastp = Bio::Blast::Bl2seq::Report.new(Bio::TestBl2seqReportData.output('blastp'))
    end

    def test_new
      assert(@empty)
      assert(@blastp)
    end

    def test_undefed_methods
      methods = ['format0_parse_header',
                 'program',
                 'version',
                 'version_number',
                 'version_date',
                 'message',
                 'converged?',
                 'reference',
                 'db']
      
      methods.each do |x|
        assert_equal(false, @empty.methods.include?(x), "undefined? : #{x}")
      end

      methods.each do |x|
        assert_equal(false, @blastp.methods.include?(x), "undefined? : #{x}")
      end
    end

    #  TestF0dbstat < Test::Unit::TestCase

    def test_db_num
      assert_equal(0, @empty.db_num)
      assert_equal(0, @blastp.db_num)
    end

    def test_db_len
      assert_equal(393, @empty.db_len)
      assert_equal(210, @blastp.db_len)
    end

#    TestIteration < Test::Unit::TestCase
    def test_undefed_methods_for_iteration
      methods = ['message',
                 'pattern_in_database',
                 'pattern',
                 'pattern_positions',
                 'hits_found_again',
                 'hits_newly_found',
                 'hits_for_pattern',
                 'parse_hitlist',
                 'converged?']

      methods.each do |x|
        assert_equal(false, @empty.iterations.first.methods.include?(x), "undefined? : #{x}")
      end

      methods.each do |x|
        assert_equal(false, @blastp.iterations.first.methods.include?(x), "undefined? : #{x}")
      end
    end
  end


  class TestBl2seqReportHit < Test::Unit::TestCase
    def setup
      @empty = Bio::Blast::Bl2seq::Report.new(Bio::TestBl2seqReportData.output('empty'))
      @blastp = Bio::Blast::Bl2seq::Report.new(Bio::TestBl2seqReportData.output('blastp'))
      @empty_hit = @empty.hits.first
      @blastp_hit = @blastp.hits.first
    end

    def test_empty_hits
      assert_equal(0, @empty.hits.size)
    end

    def test_hits
      assert_equal(Bio::Blast::Bl2seq::Report::Hit, @blastp.hits.first.class)
      assert_equal(1, @blastp.hits.size)
    end
  end

end # module Bio
