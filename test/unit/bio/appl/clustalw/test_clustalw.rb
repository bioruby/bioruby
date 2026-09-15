# frozen_string_literal: true

#
# test/unit/bio/appl/clustalw/test_clustalw.rb - Unit test for Bio::ClustalW
#
# Copyright::  Copyright (C) 2026
#               The BioRuby developers
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'rbconfig'
require 'bio/alignment'
require 'bio/sequence'
require 'bio/appl/clustalw'

module Bio
  class TestClustalW < Test::Unit::TestCase
    def setup
      @clustalw = Bio::ClustalW.new
    end

    def test_program
      assert_equal('clustalw', @clustalw.program)
    end

    def test_program_set
      @clustalw.program = 'other'
      assert_equal('other', @clustalw.program)
    end

    def test_options
      assert_equal([], @clustalw.options)
    end

    def test_options_set
      @clustalw.options = ['-quicktree']
      assert_equal(['-quicktree'], @clustalw.options)
    end

    def test_command_initial
      assert_nil(@clustalw.command)
    end

    def test_output_initial
      assert_nil(@clustalw.output)
    end

    def test_report_initial
      assert_nil(@clustalw.report)
    end

    def test_exit_status_initial
      assert_nil(@clustalw.exit_status)
    end

    def test_log_initial
      assert_nil(@clustalw.log)
    end

    def test_data_stdout
      @clustalw.data_stdout = 'log'
      assert_equal('log', @clustalw.data_stdout)
    end

    def test_str_new_with_opt
      clustalw = Bio::ClustalW.new('clustalw2', ['-quicktree'])
      assert_equal('clustalw2', clustalw.program)
      assert_equal(['-quicktree'], clustalw.options)
    end
  end # class TestClustalW

  class TestClustalWDeprecated < Test::Unit::TestCase
    def setup
      @clustalw = Bio::ClustalW.new('clustalw', ['-quicktree'])
    end

    def test_option
      assert_equal(['-quicktree'], @clustalw.option)
    end

    def test_errorlog
      assert_equal('', @clustalw.errorlog)
    end
  end # class TestClustalWDeprecated

  class TestClustalWExecLocal < Test::Unit::TestCase
    def setup
      @clustalw = Bio::ClustalW.new(RbConfig.ruby)
    end

    def test_exec_local_stdout
      @clustalw.send(:exec_local, ['-e', 'print "hello"'])
      assert_equal('hello', @clustalw.data_stdout)
    end

    def test_exec_local_command
      @clustalw.send(:exec_local, ['-e', 'print "hello"'])
      assert_equal(RbConfig.ruby, @clustalw.command.first)
    end

    def test_exec_local_exit_status
      @clustalw.send(:exec_local, ['-e', 'print "hello"'])
      assert_equal(0, @clustalw.exit_status.exitstatus)
    end
  end # class TestClustalWExecLocal

  module TestClustalWQueryCommon
    def setup
      aln = clustalw_alignment
      @clustalw = stub_clustalw(aln)
    end

    def clustalw_alignment
      File.read(File.join(BioRubyTestDataPath, 'clustalw', 'example1.aln'))
    end

    def stub_clustalw(aln)
      writer = clustalw_writer(aln)
      clustalw = Bio::ClustalW.new('clustalw')
      clustalw.define_singleton_method(:exec_local) do |opt|
        writer.call(opt)
        @data_stdout = "log\n"
        @exit_status = Struct.new(:exitstatus).new(0)
      end
      clustalw
    end

    def clustalw_writer(aln)
      lambda do |opt|
        out = opt.find { |x| x =~ /\A-outfile=(.*)/ } && ::Regexp.last_match(1)
        dnd = opt.find { |x| x =~ /\A-newtree=(.*)/ } && ::Regexp.last_match(1)
        File.write(out, aln) if out
        File.write(dnd, "tree\n") if dnd
      end
    end
  end # module TestClustalWQueryCommon

  class TestClustalWQueryString < Test::Unit::TestCase
    include TestClustalWQueryCommon

    def test_query_string
      assert_instance_of(Bio::ClustalW::Report,
                         @clustalw.query_string(">q1\nACGT\n"))
    end

    def test_query_string_sets_output
      @clustalw.query_string(">q1\nACGT\n")
      assert_match(/\ACLUSTAL/, @clustalw.output)
    end

    def test_query_string_sets_dnd
      @clustalw.query_string(">q1\nACGT\n")
      assert_equal("tree\n", @clustalw.output_dnd)
    end

    def test_query_string_with_deprecated_arg
      report = @clustalw.query_string(">q1\nACGT\n", 'PROTEIN')
      assert_instance_of(Bio::ClustalW::Report, report)
    end

    def test_query_by_filename
      path = File.join(BioRubyTestDataPath, 'clustalw', 'example1.aln')
      assert_instance_of(Bio::ClustalW::Report,
                         @clustalw.query_by_filename(path))
    end

    def test_query_by_filename_with_deprecated_arg
      path = File.join(BioRubyTestDataPath, 'clustalw', 'example1.aln')
      assert_instance_of(Bio::ClustalW::Report,
                         @clustalw.query_by_filename(path, 'PROTEIN'))
    end
  end # class TestClustalWQueryString

  class TestClustalWQueryNil < Test::Unit::TestCase
    include TestClustalWQueryCommon

    def test_query_nil_success
      assert_equal(true, @clustalw.query(nil))
    end

    def test_query_nil_failure
      @clustalw.define_singleton_method(:exec_local) do |_opt|
        @exit_status = Struct.new(:exitstatus).new(1)
      end
      assert_equal(false, @clustalw.query(nil))
    end
  end # class TestClustalWQueryNil

  class TestClustalWQueryAlign < Test::Unit::TestCase
    include TestClustalWQueryCommon

    def setup
      super
      @seqs = [Bio::Sequence::NA.new('ACGT'), Bio::Sequence::NA.new('ACGA')]
    end

    def test_query_align_with_array
      assert_instance_of(Bio::ClustalW::Report,
                         @clustalw.query_align(@seqs))
    end

    def test_query_align_with_alignment
      aln = Bio::Alignment.new(@seqs)
      assert_instance_of(Bio::ClustalW::Report, @clustalw.query_align(aln))
    end

    def test_query_alignment
      assert_instance_of(Bio::ClustalW::Report,
                         @clustalw.query_alignment(@seqs))
    end

    def test_query_with_seqs
      assert_instance_of(Bio::ClustalW::Report, @clustalw.query(@seqs))
    end
  end # class TestClustalWQueryAlign

  class TestClustalWReset < Test::Unit::TestCase
    include TestClustalWQueryCommon

    def test_reset
      @clustalw.query_string(">q1\nACGT\n")
      @clustalw.reset
      assert_nil(@clustalw.output)
      assert_nil(@clustalw.command)
      assert_nil(@clustalw.report)
      assert_nil(@clustalw.exit_status)
      assert_nil(@clustalw.data_stdout)
      assert_nil(@clustalw.output_dnd)
    end

    def test_reset_keeps_program_and_options
      @clustalw.reset
      assert_equal('clustalw', @clustalw.program)
      assert_equal([], @clustalw.options)
    end
  end # class TestClustalWReset
end # module Bio
