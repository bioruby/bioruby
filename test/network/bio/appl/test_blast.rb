#
# = test/functional/bio/appl/test_blast.rb - Unit test for Bio::Blast with network connection
#
# Copyright::   Copyright (C) 2011
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/appl/blast'

module Bio
module FunctTestBlast

  module NetTestBlastCommonProteinQuery
    filename = File.join(BioRubyTestDataPath, 'fasta', 'EFTU_BACSU.fasta')
    QuerySequence = File.read(filename).freeze

    def test_query
      report = nil
      assert_nothing_raised {
        report = @blast.query(QuerySequence)
      }
      assert(report.hits.size > 0)
    end
  end #module NetTestBlastCommonProteinQuery

  class NetTestBlast_GenomeNet < Test::Unit::TestCase
    include NetTestBlastCommonProteinQuery

    def setup
      @blast = Bio::Blast.new('blastp', 'mine-aa eco',
                              [ '-e', '1e-10',
                                '-v', '10',
                                '-b', '10' ],
                              'genomenet')
    end
  end #class NetTestBlast_GenomeNet

end #module FuncTestBlast
end #module Bio

