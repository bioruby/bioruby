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
      assert_nothing_raised do
        result = @togows.entry('nucleotide', acc)
      end
      assert(!result.to_s.strip.empty?)
      gb = Bio::GenBank.new(result)
      assert(gb.accessions.include?(acc))
    end

    def test_entry_multi
      result = nil
      accs = %w[AF237819 AB302966 AY582120]
      assert_nothing_raised do
        result = @togows.entry('nucleotide', accs)
      end
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
      assert_nothing_raised do
        result2 = @togows.entry('nucleotide', accs2)
      end
      assert(result2 == result)
    end

    def test_entry_with_format
      result = nil
      acc = 'AF237819'
      assert_nothing_raised do
        result = @togows.entry('nucleotide', acc, 'fasta')
      end
      assert(!result.to_s.strip.empty?)
      assert_match(/^>/, result)
    end

    def test_entry_with_key
      result = nil
      assert_nothing_raised do
        result = @togows.entry('pubmed', '16381885', nil, 'authors')
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_entry_with_format_and_key
      result = nil
      assert_nothing_raised do
        result = @togows.entry('pubmed', '16381885', 'json', 'authors')
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_search
      result = nil
      assert_nothing_raised do
        result = @togows.search('nuccore', 'Milnesium tardigradum')
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_search_with_offset_limit
      result = nil
      assert_nothing_raised do
        result = @togows.search('nuccore', 'Milnesium tardigradum', 2, 3)
      end
      assert(!result.to_s.strip.empty?)
      ary = result.chomp.split("\n")
      assert_equal(3, ary.size)
    end

    def test_search_with_offset_limit_format
      result = nil
      assert_nothing_raised do
        result = @togows.search('nuccore', 'Milnesium tardigradum', 2, 3,
                                'json')
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_convert
      data = File.read(File.join(TestData, 'blast', 'b0002.faa.m0'))
      result = nil
      assert_nothing_raised do
        result = @togows.convert(data, 'blast', 'gff')
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_retrieve
      result = nil
      assert_nothing_raised do
        result = @togows.retrieve('AF237819')
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_retrieve_1id_1db
      result = nil
      assert_nothing_raised do
        result = @togows.retrieve('hsa:124',
                                  database: 'kegg-genes',
                                  field: 'entry_id',
                                  format: 'json')
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_retrieve_1id_2db
      result = nil
      assert_nothing_raised do
        result = @togows.retrieve('1.1.1.1',
                                  database: %w[kegg-genes kegg-enzyme])
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_retrieve_2id_2db
      result = nil
      assert_nothing_raised do
        result = @togows.retrieve(['1.1.1.1', 'hsa:124'],
                                  database: %w[kegg-genes kegg-enzyme])
      end
      assert(!result.to_s.strip.empty?)
    end

    def test_entry_database_list
      result = nil
      assert_nothing_raised do
        result = @togows.entry_database_list
      end
      assert_kind_of(Array, result)
      assert(!result.empty?)
    end

    def test_search_database_list
      result = nil
      assert_nothing_raised do
        result = @togows.search_database_list
      end
      assert_kind_of(Array, result)
      assert(!result.empty?)
    end
  end # FuncTestTogoWSRESTcommon

  # functional test for Bio::TogoWS::REST
  class FuncTestTogoWSREST < Test::Unit::TestCase
    include FuncTestTogoWSRESTcommon

    def setup
      @togows = Bio::TogoWS::REST.new
    end
  end # class FuncTestTogoWSREST

  # functional test for Bio::TogoWS::REST private methods
  class FuncTestTogoWSRESTprivate < Test::Unit::TestCase
    def setup
      @togows = Bio::TogoWS::REST.new
    end

    def test_get
      response = nil
      acc = 'AF237819'
      assert_nothing_raised do
        response = @togows.instance_eval do
          get('entry', 'nucleotide', acc, 'entry_id')
        end
      end
      assert_kind_of(Net::HTTPResponse, response)
      assert_equal('200', response.code)
      result = response.body
      assert(!result.to_s.strip.empty?)
    end

    def test_get_dir
      response = nil
      assert_nothing_raised do
        response = @togows.instance_eval do
          get_dir('search')
        end
      end
      assert_kind_of(Net::HTTPResponse, response)
      assert_equal('200', response.code)
      result = response.body
      assert(!result.to_s.strip.empty?)
    end

    def test_post_data
      data = File.read(File.join(Bio::FuncTestTogoWSRESTcommon::TestData,
                                 'blast', 'b0002.faa.m0'))
      response = nil
      assert_nothing_raised do
        response = @togows.instance_eval do
          post_data(data, 'convert', 'blast.gff')
        end
      end
      assert_kind_of(Net::HTTPResponse, response)
      assert_equal('200', response.code)
      result = response.body
      assert(!result.to_s.strip.empty?)
    end

    def test_database_list
      result = nil
      assert_nothing_raised do
        result = @togows.instance_eval do
          database_list('entry')
        end
      end
      assert_kind_of(Array, result)
      assert(!result.empty?)
    end
  end # class FuncTestTogoWSRESTprivate

  # if false
end # module Bio
