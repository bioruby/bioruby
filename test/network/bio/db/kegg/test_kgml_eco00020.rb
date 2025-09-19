#
# test/network/bio/db/kegg/test_kgml_eco00020.rb - Network test for Bio::KEGG::KGML
#
# Copyright::  Copyright (C) 2024 BioRuby Project <staff@bioruby.org>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/kgml'
require 'net/http'
require 'uri'

module Bio

  # This network test fetches real KEGG KGML data from the KEGG REST API
  # to test the KGML parser with actual data.
  # This approach is used instead of including static KEGG data files
  # due to KEGG data license restrictions.
  #
  # Note that this test may fail due to network issues or data updates in KEGG.
  class TestBioKEGGKGML_eco00020 < Test::Unit::TestCase

    # Fetch KGML data for eco00020 (Citrate cycle) pathway
    def self.fetch_kgml_data
      uri = URI('https://rest.kegg.jp/get/eco00020/kgml')
      begin
        response = Net::HTTP.get_response(uri)
        if response.code == '200'
          response.body
        else
          warn "Failed to fetch KEGG data: HTTP #{response.code}"
          nil
        end
      rescue StandardError => e
        warn "Failed to fetch KEGG data: #{e.message}"
        nil
      end
    end

    DATA = fetch_kgml_data.freeze

    def setup
      return unless DATA
      @obj = Bio::KEGG::KGML.new(DATA)
    end

    def test_pathway_attributes
      return unless DATA
      # Test that basic pathway attributes are parsed correctly
      assert_not_nil @obj.name
      assert_match(/^path:eco00020$/, @obj.name)
      assert_equal "eco", @obj.org
      assert_equal "00020", @obj.number
      assert_not_nil @obj.title
      assert_match(/citrate cycle/i, @obj.title)
    end

    def test_entries_exist
      return unless DATA
      # Test that entries are parsed and contain expected content
      assert_not_nil @obj.entries
      assert @obj.entries.size > 0, "Should have at least some entries"
      
      # Check that entries have the expected structure
      entry = @obj.entries.first
      assert_not_nil entry.id
      assert_not_nil entry.name
      assert_not_nil entry.type
    end

    def test_entry_types
      return unless DATA
      # Test that various entry types are represented
      types = @obj.entries.map(&:type).uniq
      assert_include types, "gene"
      # Citrate cycle should have gene entries
    end

    def test_relations_exist
      return unless DATA
      # Test that relations are parsed (if any exist)
      assert_respond_to @obj, :relations
      if @obj.relations && @obj.relations.size > 0
        relation = @obj.relations.first
        assert_not_nil relation.entry1
        assert_not_nil relation.entry2
        assert_not_nil relation.type
      end
    end

    def test_reactions_exist
      return unless DATA
      # Test that reactions are parsed (if any exist)
      assert_respond_to @obj, :reactions
      if @obj.reactions && @obj.reactions.size > 0
        reaction = @obj.reactions.first
        assert_not_nil reaction.name
        assert_not_nil reaction.type
      end
    end

    def test_graphics_parsing
      return unless DATA
      # Test that graphics elements are parsed correctly
      entries_with_graphics = @obj.entries.select { |e| e.graphics && e.graphics.size > 0 }
      assert entries_with_graphics.size > 0, "Should have at least some entries with graphics"
      
      graphics = entries_with_graphics.first.graphics.first
      assert_respond_to graphics, :x
      assert_respond_to graphics, :y
      assert_respond_to graphics, :width
      assert_respond_to graphics, :height
    end

    def test_gene_entries
      return unless DATA
      # Test specific functionality for gene entries
      gene_entries = @obj.entries.select { |e| e.type == "gene" }
      assert gene_entries.size > 0, "Citrate cycle should have gene entries"
      
      gene = gene_entries.first
      assert_match(/^eco:b/, gene.name)
    end

    def test_names_method
      return unless DATA
      # Test the names method that splits space-separated names
      @obj.entries.each do |entry|
        names = entry.names
        assert_kind_of Array, names
        assert names.size > 0
        names.each do |name|
          assert_kind_of String, name
          assert !name.include?(' '), "Individual names should not contain spaces"
        end
      end
    end

    def test_data_consistency
      return unless DATA
      # Test that the parsed data is consistent
      @obj.entries.each do |entry|
        assert_kind_of Integer, entry.id
        assert entry.id > 0
        assert_kind_of String, entry.name
        assert !entry.name.empty?
        assert_kind_of String, entry.type
        assert !entry.type.empty?
      end
    end

  end #class TestBioKEGGKGML_eco00020

end #module Bio
