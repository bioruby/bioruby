#
# test/unit/bio/appl/clustalw/test_report.rb - Unit test for Bio::ClustalW::Report
#
# Copyright::  Copyright (C) 2010 Pjotr Prins <pjotr.prins@thebird.nl> 
# License::    The Ruby License
#

require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s
require 'test/unit'
require 'bio/appl/clustalw/report'

module Bio

  class TestClustalWReport < Test::Unit::TestCase

    def setup
      test_data_path = Pathname.new(File.join(BioRubyTestDataPath, 'clustalw')).cleanpath.to_s
      aln_filename = File.join(test_data_path, 'example1.aln')
      text = File.read(aln_filename)
      @aln = Bio::ClustalW::Report.new(text)
    end

    # CLUSTAL 2.0.9 multiple sequence alignment
    #
    #
    # The alignment reads like:
    #
    # query                      -MKNTLLKLGVCVSLLGITPFVSTISSVQAERTVEHKVIKNETGTISISQ
    # gi|115023|sp|P10425|       MKKNTLLKVGLCVSLLGTTQFVSTISSVQASQKVEQIVIKNETGTISISQ
    #                                                                          .: :
    # 
    # query                      LNKNVWVHTELGYFSG-EAVPSNGLVLNTSKGLVLVDSSWDDKLTKELIE
    # gi|115023|sp|P10425|       LNKNVWVHTELGYFNG-EAVPSNGLVLNTSKGLVLVDSSWDNKLTKELIE
    #                                *:   .     .     **. .   ..   ::*:       . * :

    def test_header
      assert_equal('CLUSTAL 2.0.9 multiple sequence alignment',@aln.header)
    end

    def test_sequences
      seq = @aln.get_sequence(0)
      assert_equal('query',seq.definition)
      assert_equal("-MKNTLLKLGVCVSLLGITPFVSTISSVQAERTVEHKVIKNETGTISISQLNKNVWVHTELGYFSG-EAVPSNGLVLNTSKGLVLVDSSWDDKLTKELIEMVEKKFKKRVTDVIITHAHADRIGGMKTLKERGIKAHSTALTAELAKKNG--------------------YEEPLGDLQSVTNLKFGN----MKVETFYPGKGHTEDNIVVWLPQYQILAGGCLVKSASSKDLGNVADAYVNEWSTSIENVLKRYGNINLVVPGHGEVGDR-----GLLLHTLDLLK---------------------------------------------------------------------",seq.to_s)
      seq = @aln.get_sequence(1)
      assert_equal('gi|115023|sp|P10425|',seq.definition)
      assert_equal("MKKNTLLKVGLCVSLLGTTQFVSTISSVQASQKVEQIVIKNETGTISISQLNKNVWVHTELGYFNG-EAVPSNGLVLNTSKGLVLVDSSWDNKLTKELIEMVEKKFQKRVTDVIITHAHADRIGGITALKERGIKAHSTALTAELAKKSG--------------------YEEPLGDLQTVTNLKFGN----TKVETFYPGKGHTEDNIVVWLPQYQILAGGCLVKSAEAKNLGNVADAYVNEWSTSIENMLKRYRNINLVVPGHGKVGDK-----GLLLHTLDLLK---------------------------------------------------------------------",seq.to_s)
    end

    def test_alignment
      assert_equal("???????????SN?????????????D??????????L??????????????????H?H?D",@aln.alignment.consensus[60..120])
    end

    def test_match_line
      assert_equal("                                              .: :    *:   .     .     **. .   ..   ::*:       . * : : .        .: .* * *   *   :   * .  :     .     .                       *   :    .: .        .:      .*:  ::***:*  .:* .* :: .           .        ::.:            *              :  .                                                                          " ,@aln.match_line)
    end

  end # class TestClustalwFormat

  class TestClustalWReportWith2ndArgument < Test::Unit::TestCase

    def setup
      aln_filename = File.join(BioRubyTestDataPath, 'clustalw',
                               'example1.aln')
      text = File.read(aln_filename)
      @aln = Bio::ClustalW::Report.new(text, "PROTEIN")
    end

    def test_sequences
      seq = @aln.get_sequence(0)
      assert_equal('query',seq.definition)
      assert_equal("-MKNTLLKLGVCVSLLGITPFVSTISSVQAERTVEHKVIKNETGTISISQLNKNVWVHTELGYFSG-EAVPSNGLVLNTSKGLVLVDSSWDDKLTKELIEMVEKKFKKRVTDVIITHAHADRIGGMKTLKERGIKAHSTALTAELAKKNG--------------------YEEPLGDLQSVTNLKFGN----MKVETFYPGKGHTEDNIVVWLPQYQILAGGCLVKSASSKDLGNVADAYVNEWSTSIENVLKRYGNINLVVPGHGEVGDR-----GLLLHTLDLLK---------------------------------------------------------------------",seq.to_s)
      seq = @aln.get_sequence(1)
      assert_equal('gi|115023|sp|P10425|',seq.definition)
      assert_equal("MKKNTLLKVGLCVSLLGTTQFVSTISSVQASQKVEQIVIKNETGTISISQLNKNVWVHTELGYFNG-EAVPSNGLVLNTSKGLVLVDSSWDNKLTKELIEMVEKKFQKRVTDVIITHAHADRIGGITALKERGIKAHSTALTAELAKKSG--------------------YEEPLGDLQTVTNLKFGN----TKVETFYPGKGHTEDNIVVWLPQYQILAGGCLVKSAEAKNLGNVADAYVNEWSTSIENMLKRYRNINLVVPGHGKVGDK-----GLLLHTLDLLK---------------------------------------------------------------------",seq.to_s)
    end

  end #class TestClustalWReportWith2ndArgument
end
