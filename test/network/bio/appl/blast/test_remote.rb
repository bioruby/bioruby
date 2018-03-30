#
# = test/functional/bio/appl/blast/test_remote.rb - Unit test for Bio::Blast::Remote::Genomenet with network connection
#
# Copyright::   Copyright (C) 2011
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/appl/blast'

module Bio
module FuncTestBlastRemote

  module NetTestBlastRemoteCommon

    Programs = %w( blastn tblastn tblastx blastp blastx ).freeze
    Programs.each { |x| x.freeze }

    def test_databases
      Programs.each do |prog|
        databases = nil
        assert_nothing_raised {
          databases = @klass.databases(prog)
        }
        assert_kind_of(Array, databases, "wrong data type for #{prog}")
        assert(!databases.empty?, "no database found for #{prog}")
      end
    end

    # sampling test for blastn database
    def test_databases_blastn
      databases = @klass.databases("blastn")
      self.class::BLASTN_DBNAME_KEYWORDS.each do |re|
        assert(databases.find { |x| re =~ x })
      end
    end

    # sampling test for blastp database
    def test_databases_blastp
      databases = @klass.databases("blastp")
      self.class::BLASTP_DBNAME_KEYWORDS.each do |re|
        assert(databases.find { |x| re =~ x })
      end
    end

    def test_database_description
      Programs.each do |prog|
        @klass.databases(prog).each do |db|
          assert_kind_of(String, @klass.database_description(prog, db))
        end
      end
    end
  end #module NetTestBlastRemoteCommon

  # This test class only contains tests for meta information.
  # BLAST execution tests are written in ../test_blast.rb 
  class NetTestBlastRemoteGenomeNet < Test::Unit::TestCase

    include NetTestBlastRemoteCommon

    BLASTN_DBNAME_KEYWORDS = [ /genes/, /nt/ ]
    BLASTP_DBNAME_KEYWORDS = [ /genes/, /uniprot/, /nr/ ]

    def setup
      @klass = Bio::Blast::Remote::GenomeNet
    end
  end #class NetTestBlastRemoteGenomeNet

end #module FuncTestBlastRemote
end #module Bio

