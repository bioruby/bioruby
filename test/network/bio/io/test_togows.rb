#
# test/functional/bio/io/test_togows.rb - Functional test for Bio::TogoWS
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'uri'
require 'bio/version'
require 'bio/io/togows'
require 'bio/db/genbank/genbank'
require 'test/unit'

module Bio

  # common tests for both instance methods and class methods
  module FuncTestTogoWSRESTcommon

    TestData = BioRubyTestDataPath

    def test_entry
      result = nil
      acc = 'AF237819'
      assert_nothing_raised {
        result = @togows.entry('nucleotide', acc)
      }
      assert(!result.to_s.strip.empty?)
      gb = Bio::GenBank.new(result)
      assert(gb.accessions.include?(acc))
    end

    def test_entry_multi
      result = nil
      accs = [ 'AF237819' ,'AB302966', 'AY582120' ]
      assert_nothing_raised {
        result = @togows.entry('nucleotide', accs)
      }
      assert(!result.to_s.strip.empty?)
      count = 0
      accs.each do |x|
        assert_match(Regexp.new(x), result)
        count += 1
      end
      assert_equal(accs.size, count)

      # argument is a string
      accs2 = accs.join(',')
      result2 = nil
      assert_nothing_raised {
        result2 = @togows.entry('nucleotide', accs2)
      }
      assert(result2 == result)
    end

    def test_entry_with_format
      result = nil
      acc = 'AF237819'
      assert_nothing_raised {
        result = @togows.entry('nucleotide', acc, 'fasta')
      }
      assert(!result.to_s.strip.empty?)
      assert_match(/^\>/, result)
    end

    def test_entry_with_key
      result = nil
      assert_nothing_raised {
        result = @togows.entry('pubmed', '16381885', nil, 'authors')
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_entry_with_format_and_key
      result = nil
      assert_nothing_raised {
        result = @togows.entry('pubmed', '16381885', 'json', 'authors')
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_search
      result = nil
      assert_nothing_raised {
        result = @togows.search('nuccore', 'Milnesium tardigradum')
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_search_with_offset_limit
      result = nil
      assert_nothing_raised {
        result = @togows.search('nuccore', 'Milnesium tardigradum', 2, 3)
      }
      assert(!result.to_s.strip.empty?)
      ary = result.chomp.split(/\n/)
      assert_equal(3, ary.size)
    end

    def test_search_with_offset_limit_format
      result = nil
      assert_nothing_raised {
        result = @togows.search('nuccore', 'Milnesium tardigradum', 2, 3,
                                'json')
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_convert
      data = File.read(File.join(TestData, 'blast', 'b0002.faa.m0'))
      result = nil
      assert_nothing_raised {
        result = @togows.convert(data, 'blast', 'gff')
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_retrieve
      result = nil
      assert_nothing_raised {
        result = @togows.retrieve('AF237819')
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_retrieve_1id_1db
      result = nil
      assert_nothing_raised {
        result = @togows.retrieve('hsa:124',
                                  :database => 'kegg-genes',
                                  :field => 'entry_id',
                                  :format => 'json')
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_retrieve_1id_2db
      result = nil
      assert_nothing_raised {
        result = @togows.retrieve('1.1.1.1',
                                  :database => [ 'kegg-genes', 'kegg-enzyme' ])
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_retrieve_2id_2db
      result = nil
      assert_nothing_raised {
        result = @togows.retrieve([ '1.1.1.1', 'hsa:124' ],
                                  :database => [ 'kegg-genes', 'kegg-enzyme' ])
      }
      assert(!result.to_s.strip.empty?)
    end

    def test_entry_database_list
      result = nil
      assert_nothing_raised {
        result = @togows.entry_database_list
      }
      assert_kind_of(Array, result)
      assert(!result.empty?)
    end

    def test_search_database_list
      result = nil
      assert_nothing_raised {
        result = @togows.search_database_list
      }
      assert_kind_of(Array, result)
      assert(!result.empty?)
    end

  end #FuncTestTogoWSRESTcommon

  # functional test for Bio::TogoWS::REST
  class FuncTestTogoWSREST < Test::Unit::TestCase

    include FuncTestTogoWSRESTcommon

    def setup
      @togows = Bio::TogoWS::REST.new
    end

  end #class FuncTestTogoWSREST

  # functional test for Bio::TogoWS::REST private methods
  class FuncTestTogoWSRESTprivate < Test::Unit::TestCase

    def setup
      @togows = Bio::TogoWS::REST.new
    end

    def test_get
      response = nil
      acc = 'AF237819'
      assert_nothing_raised {
        response = @togows.instance_eval {
          get('entry', 'nucleotide', acc, 'entry_id')
        }
      }
      assert_kind_of(Net::HTTPResponse, response)
      assert_equal("200", response.code)
      result = response.body
      assert(!result.to_s.strip.empty?)
    end

    def test_get_dir
      response = nil
      assert_nothing_raised {
        response = @togows.instance_eval {
          get_dir('search')
        }
      }
      assert_kind_of(Net::HTTPResponse, response)
      assert_equal("200", response.code)
      result = response.body
      assert(!result.to_s.strip.empty?)
    end

    def test_post_data
      data = File.read(File.join(Bio::FuncTestTogoWSRESTcommon::TestData,
                                 'blast', 'b0002.faa.m0'))
      response = nil
      assert_nothing_raised {
        response = @togows.instance_eval {
          post_data(data, 'convert', 'blast.gff')
        }
      }
      assert_kind_of(Net::HTTPResponse, response)
      assert_equal("200", response.code)
      result = response.body
      assert(!result.to_s.strip.empty?)
    end

    def test_database_list
      result = nil
      assert_nothing_raised {
        result = @togows.instance_eval {
          database_list('entry')
        }
      }
      assert_kind_of(Array, result)
      assert(!result.empty?)
    end

  end #class FuncTestTogoWSRESTprivate

  if false # DISABLED because of the server load and execution time

    # functional test for Bio::TogoWS::REST class methods
    class FuncTestTogoWSRESTclassMethod < Test::Unit::TestCase
      include FuncTestTogoWSRESTcommon
      def setup
        @togows = Bio::TogoWS::REST
      end
    end #class FuncTestTogoWSRESTclassMethod

  end #if false

end #module Bio
