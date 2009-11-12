#
# test/unit/bio/appl/test_blast.rb - Unit test for Bio::Blast
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/blast'


module Bio
  class TestBlastData
    TestDataBlast = Pathname.new(File.join(BioRubyTestDataPath, 'blast')).cleanpath.to_s

    def self.input
      File.open(File.join(TestDataBlast, 'b0002.faa')).read
    end

    def self.output(format = '7')
      case format
      when '0'
        File.open(File.join(TestDataBlast, 'b0002.faa.m0')).read 
      when '7'
        File.open(File.join(TestDataBlast, 'b0002.faa.m7')).read 
      when '8'
        File.open(File.join(TestDataBlast, 'b0002.faa.m8')).read 
      end
    end
  end

    
  class TestBlast < Test::Unit::TestCase
    def setup
      @program = 'blastp'
      @db = 'test'
      @option = []
      @server = 'localhost'
      @blast = Bio::Blast.new(@program, @db, @option, @server)
    end
    
    def test_new
      blast = Bio::Blast.new(@program, @db)
      assert_equal(@program, blast.program)
      assert_equal(@db, blast.db)
      assert(blast.options)
      assert_equal('local', blast.server)
      assert_equal('blastall', blast.blastall)
    end

    def test_new_opt_string
      blast = Bio::Blast.new(@program, @db, '-m 7 -F F')
      assert_equal(['-m', '7', '-F', 'F'], blast.options)
    end

    def test_program
      assert_equal(@program, @blast.program) 
    end

    def test_db
      assert_equal(@db, @blast.db) 
    end

    def test_options
      assert_equal([], @blast.options) 
    end

    def test_option
      assert_equal('', @blast.option) 
    end

    def test_option_set
      @blast.option = '-m 7 -p T'
      assert_equal('-m 7 -p T', @blast.option) 
    end

    def test_option_set_m0
      @blast.option = '-m 0'
      assert_equal('-m 0', @blast.option) 
    end


    def test_server
      assert_equal(@server, @blast.server) 
    end

    def test_blastll
      assert_equal('blastall', @blast.blastall) 
    end

    def test_matrix
      assert_equal(nil, @blast.matrix) 
    end

    def test_filter
      assert_equal(nil, @blast.filter) 
    end

    def test_parser
      assert_equal(nil, @blast.instance_eval { @parser })
    end

    def test_output
      assert_equal('', @blast.output)  
    end

     def test_format
       assert(@blast.format)  
     end

     def test_self_local
       assert(Bio::Blast.local(@program, @db, @option))
     end

     def test_self_remote
       assert(Bio::Blast.remote(@program, @db, @option))
     end

     def test_query
       # to be tested in test/functional/bio/test_blast.rb
     end

     def test_blast_reports_xml
       ret = Bio::Blast.reports_xml(TestBlastData.output)
       assert_instance_of(Array, ret)
       count = 0
       ret.each do |report|
         count += 1
         assert_instance_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_xml_with_block
       count = 0
       Bio::Blast.reports_xml(TestBlastData.output) do |report|
         count += 1
         assert_instance_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format0
       ret = Bio::Blast.reports(TestBlastData.output('0'))
       assert_instance_of(Array, ret)
       count = 0
       ret.each do |report|
         count += 1
         assert_instance_of(Bio::Blast::Default::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format7
       ret = Bio::Blast.reports(TestBlastData.output('7'))
       assert_instance_of(Array, ret)
       count = 0
       ret.each do |report|
         count += 1
         assert_instance_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format8
       ret = Bio::Blast.reports(TestBlastData.output('8'))
       assert_instance_of(Array, ret)
       count = 0
       ret.each do |report|
         count += 1
         assert_kind_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format0_with_block
       count = 0
       Bio::Blast.reports(TestBlastData.output('0')) do |report|
         count += 1
         assert_instance_of(Bio::Blast::Default::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format7_with_block
       count = 0
       Bio::Blast.reports(TestBlastData.output('7')) do |report|
         count += 1
         assert_instance_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format8_with_block
       count = 0
       Bio::Blast.reports(TestBlastData.output('8')) do |report|
         count += 1
         assert_kind_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end
     
     def test_blast_reports_format7_with_parser
       ret = Bio::Blast.reports(TestBlastData.output('7'), :rexml)
       assert_instance_of(Array, ret)
       count = 0
       ret.each do |report|
         count += 1
         assert_instance_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format8_with_parser
       ret = Bio::Blast.reports(TestBlastData.output('8'), :tab)
       assert_instance_of(Array, ret)
       count = 0
       ret.each do |report|
         count += 1
         assert_kind_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format7_with_parser_with_block
       count = 0
       Bio::Blast.reports(TestBlastData.output('7'), :rexml) do |report|
         count += 1
         assert_instance_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_blast_reports_format8_with_parser_with_block
       count = 0
       Bio::Blast.reports(TestBlastData.output('8'), :tab) do |report|
         count += 1
         assert_kind_of(Bio::Blast::Report, report)
       end
       assert_equal(1, count)
     end

     def test_make_command_line
       @blast = Bio::Blast.new(@program, @db, '-m 7 -F F')
       assert_equal(["blastall", "-p", "blastp", "-d", "test", "-m", "7", "-F", "F"], 
                    @blast.instance_eval { make_command_line })
     end
     def test_make_command_line_2
       @blast = Bio::Blast.new(@program, @db, '-m 0 -F F')
       assert_equal(["blastall", "-p", "blastp", "-d", "test", "-m", "0", "-F",  "F"], 
                    @blast.instance_eval { make_command_line })
     end

     def test_parse_result
       assert(@blast.instance_eval { parse_result(TestBlastData.output) })
     end

     def test_exec_local
       # to be tested in test/functional/bio/test_blast.rb       
     end
     
     def test_exec_genomenet
       # to be tested in test/functional/bio/test_blast.rb
     end

     def test_exec_ncbi
       # to be tested in test/functional/bio/test_blast.rb
     end
   end
 end
