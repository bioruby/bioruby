#
# = sample/benchmark_clustalw_report.rb - Benchmark tests for Bio::ClustalW::Report
#
# Copyright::   Copyright (C) 2013
#               Andrew Grimm <andrew.j.grimm@gmail.com>
# License::     The Ruby License

require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 1, "test",
                            'bioruby_test_helper.rb')).cleanpath.to_s

require 'benchmark'
require 'bio'

class BenchmarkClustalWReport

  DataDir = File.join(BioRubyTestDataPath, 'clustalw')
  Filenames = [ 'example1.aln', 'example1-seqnos.aln' ]

  def self.benchmark_clustalw_report
    Filenames.each do |fn|
      print "\n", fn, "\n"
      fullpath = File.join(DataDir, fn)
      self.new(fullpath).benchmark
    end
  end

  def initialize(aln_filename)
    @text = File.open(aln_filename, 'rb') { |f| f.read }
    @text.freeze
  end

  def benchmark
    GC.start
    Benchmark.bmbm do |x|
      x.report do
        for i in 1...10_000
          aln = Bio::ClustalW::Report.new(@text)
          aln.alignment
        end
      end
    end
  end

end #class BenchmarkClustalWReport

BenchmarkClustalWReport.benchmark_clustalw_report
