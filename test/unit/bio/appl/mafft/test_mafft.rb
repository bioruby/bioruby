# frozen_string_literal: true

#
# test/unit/bio/appl/mafft/test_mafft.rb - Unit test for Bio::MAFFT
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
require 'bio/appl/mafft'

module Bio
  class TestMAFFT < Test::Unit::TestCase
    def setup
      @mafft = Bio::MAFFT.new
    end

    def test_program
      assert_equal('mafft', @mafft.program)
    end

    def test_program_set
      @mafft.program = 'other'
      assert_equal('other', @mafft.program)
    end

    def test_options
      assert_equal([], @mafft.options)
    end

    def test_options_set
      @mafft.options = ['--retree', '2']
      assert_equal(['--retree', '2'], @mafft.options)
    end

    def test_command_initial
      assert_nil(@mafft.command)
    end

    def test_output_initial
      assert_nil(@mafft.output)
    end

    def test_report_initial
      assert_nil(@mafft.report)
    end

    def test_exit_status_initial
      assert_nil(@mafft.exit_status)
    end

    def test_str_new_with_opt
      mafft = Bio::MAFFT.new('mafft2', ['--retree', '2'])
      assert_equal('mafft2', mafft.program)
      assert_equal(['--retree', '2'], mafft.options)
    end

    def test_option_deprecated
      assert_equal([], @mafft.option)
    end

    def test_log_deprecated
      assert_equal('', @mafft.log)
    end

    def test_data_stdout
      @mafft.data_stdout = 'log'
      assert_equal('log', @mafft.data_stdout)
    end
  end # class TestMAFFT

  class TestMAFFTClassMethods < Test::Unit::TestCase
    def test_fftns
      assert_equal('fftns', Bio::MAFFT.fftns.program)
      assert_equal([], Bio::MAFFT.fftns.options)
    end

    def test_fftns_with_number
      mafft = Bio::MAFFT.fftns(3)
      assert_equal('fftns', mafft.program)
      assert_equal(['3'], mafft.options)
    end

    def test_fftns_with_i
      assert_equal('fftnsi', Bio::MAFFT.fftns('i').program)
    end

    def test_fftnsi
      assert_equal('fftnsi', Bio::MAFFT.fftnsi.program)
    end

    def test_nwns
      mafft = Bio::MAFFT.nwns(2)
      assert_equal('nwns', mafft.program)
      assert_equal(['2'], mafft.options)
    end

    def test_nwns_with_i
      assert_equal('nwnsi', Bio::MAFFT.nwns('i').program)
    end

    def test_nwns_all_positive
      mafft = Bio::MAFFT.nwns(2, true)
      assert_equal(['--all-positive', '2'], mafft.options)
    end

    def test_nwnsi
      assert_equal('nwnsi', Bio::MAFFT.nwnsi.program)
    end

    def test_nwnsi_all_positive
      assert_equal(['--all-positive'], Bio::MAFFT.nwnsi(true).options)
    end

    def test_nwap
      mafft = Bio::MAFFT.nwap(3)
      assert_equal('nwns', mafft.program)
      assert_equal(['--all-positive', '3'], mafft.options)
    end

    def test_new2_with_dir
      mafft = Bio::MAFFT.new2('/usr/local/bin', 'mafft')
      assert_equal('/usr/local/bin/mafft', mafft.program)
    end

    def test_new2_without_dir
      mafft = Bio::MAFFT.new2(nil, 'mafft', '--retree', '2')
      assert_equal('mafft', mafft.program)
      assert_equal(['--retree', '2'], mafft.options)
    end
  end # class TestMAFFTClassMethods

  class TestMAFFTExecLocal < Test::Unit::TestCase
    def setup
      @mafft = Bio::MAFFT.new(RbConfig.ruby)
    end

    def test_exec_local_stdout
      @mafft.send(:exec_local, ['-e', 'print "hello"'])
      assert_equal('hello', @mafft.data_stdout)
    end

    def test_exec_local_output
      @mafft.send(:exec_local, ['-e', 'print "hello"'])
      assert_equal('hello', @mafft.output)
    end

    def test_exec_local_exit_status
      @mafft.send(:exec_local, ['-e', 'print "hello"'])
      assert_equal(0, @mafft.exit_status.exitstatus)
    end
  end # class TestMAFFTExecLocal

  module TestMAFFTQueryCommon
    def setup
      @mafft = Bio::MAFFT.new('mafft')
      aln = File.read(File.join(BioRubyTestDataPath, 'clustalw',
                                'example1.aln'))
      @mafft.define_singleton_method(:exec_local) do |opt|
        @command = ['mafft', *opt]
        @data_stdout = aln
        @output = aln
        @exit_status = Struct.new(:exitstatus).new(0)
      end
    end
  end # module TestMAFFTQueryCommon

  class TestMAFFTQueryString < Test::Unit::TestCase
    include TestMAFFTQueryCommon

    def test_query_string
      assert_instance_of(Bio::MAFFT::Report,
                         @mafft.query_string(">q1\nACGT\n"))
    end

    def test_query_string_sets_output
      @mafft.query_string(">q1\nACGT\n")
      assert_match(/\ACLUSTAL/, @mafft.output)
    end

    def test_query_string_with_deprecated_arg
      report = @mafft.query_string(">q1\nACGT\n", 'PROTEIN')
      assert_instance_of(Bio::MAFFT::Report, report)
    end

    def test_query_by_filename
      path = File.join(BioRubyTestDataPath, 'clustalw', 'example1.aln')
      assert_instance_of(Bio::MAFFT::Report,
                         @mafft.query_by_filename(path))
    end

    def test_query_by_filename_with_deprecated_arg
      path = File.join(BioRubyTestDataPath, 'clustalw', 'example1.aln')
      assert_instance_of(Bio::MAFFT::Report,
                         @mafft.query_by_filename(path, 'PROTEIN'))
    end
  end # class TestMAFFTQueryString

  class TestMAFFTQueryNil < Test::Unit::TestCase
    include TestMAFFTQueryCommon

    def test_query_nil_success
      assert_equal(true, @mafft.query(nil))
    end

    def test_query_nil_failure
      @mafft.define_singleton_method(:exec_local) do |_opt|
        @exit_status = Struct.new(:exitstatus).new(1)
      end
      assert_equal(false, @mafft.query(nil))
    end
  end # class TestMAFFTQueryNil

  class TestMAFFTQueryAlign < Test::Unit::TestCase
    include TestMAFFTQueryCommon

    def setup
      super
      @seqs = [Bio::Sequence::NA.new('ACGT'), Bio::Sequence::NA.new('ACGA')]
    end

    def test_query_align_with_array
      assert_instance_of(Bio::MAFFT::Report, @mafft.query_align(@seqs))
    end

    def test_query_align_with_alignment
      aln = Bio::Alignment.new(@seqs)
      assert_instance_of(Bio::MAFFT::Report, @mafft.query_align(aln))
    end

    def test_query_align_with_deprecated_arg
      assert_instance_of(Bio::MAFFT::Report,
                         @mafft.query_align(@seqs, 'PROTEIN'))
    end

    def test_query_alignment
      assert_instance_of(Bio::MAFFT::Report,
                         @mafft.query_alignment(@seqs))
    end

    def test_query_with_seqs
      assert_instance_of(Bio::MAFFT::Report, @mafft.query(@seqs))
    end
  end # class TestMAFFTQueryAlign

  class TestMAFFTReset < Test::Unit::TestCase
    include TestMAFFTQueryCommon

    def test_reset
      @mafft.query_string(">q1\nACGT\n")
      @mafft.reset
      assert_nil(@mafft.output)
      assert_nil(@mafft.command)
      assert_nil(@mafft.report)
      assert_nil(@mafft.exit_status)
      assert_nil(@mafft.data_stdout)
    end

    def test_reset_keeps_program_and_options
      @mafft.reset
      assert_equal('mafft', @mafft.program)
      assert_equal([], @mafft.options)
    end
  end # class TestMAFFTReset
end # module Bio
