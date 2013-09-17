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

module BenchmarkClustalWReport
  def self.benchmark_clustalw_report
    Benchmark.bmbm do |x|
      test_data_path = Pathname.new(File.join(BioRubyTestDataPath, 'clustalw')).cleanpath.to_s
      aln_filename = File.join(test_data_path, 'example1.aln')
      text = File.read(aln_filename)
      x.report do
        for i in 1...10_000
          aln = Bio::ClustalW::Report.new(text)
          aln.alignment
        end
      end
    end
  end
end

BenchmarkClustalWReport.benchmark_clustalw_report
