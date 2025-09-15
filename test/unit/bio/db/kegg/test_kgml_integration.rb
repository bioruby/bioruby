#
# test/unit/bio/db/kegg/test_kgml_integration.rb - Integration test for Bio::KEGG::KGML
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

module Bio; module TestKeggKGMLIntegration

  # Sample KGML data that mimics the structure of real KEGG pathway data
  # This represents a simplified version of eco00020 (Citrate cycle)
  SAMPLE_KGML_DATA = <<-EOF
<?xml version="1.0"?>
<!DOCTYPE pathway SYSTEM "http://www.genome.jp/kegg/xml/KGML_v0.7.1_.dtd">
<pathway name="path:eco00020" org="eco" number="00020"
         title="Citrate cycle (TCA cycle)"
         image="http://www.kegg.jp/kegg/pathway/eco/eco00020.png"
         link="http://www.kegg.jp/kegg-bin/show_pathway?eco00020">
    <entry id="15" name="ec:1.1.1.37" type="enzyme" reaction="rn:R00267"
        link="http://www.kegg.jp/dbget-bin/www_bget?ec:1.1.1.37">
        <graphics name="1.1.1.37" fgcolor="#000000" bgcolor="#BFBFFF"
             type="rectangle" x="177" y="162" width="46" height="17"/>
    </entry>
    <entry id="16" name="ec:1.2.4.1 ec:1.2.4.2" type="enzyme" reaction="rn:R01082"
        link="http://www.kegg.jp/dbget-bin/www_bget?ec:1.2.4.1+ec:1.2.4.2">
        <graphics name="1.2.4.1" fgcolor="#000000" bgcolor="#BFBFFF"
             type="rectangle" x="314" y="162" width="46" height="17"/>
        <graphics name="1.2.4.2" fgcolor="#FF0000" bgcolor="#FFCCCC"
             type="rectangle" x="314" y="180" width="46" height="17"/>
    </entry>
    <entry id="17" name="cpd:C00022" type="compound"
        link="http://www.kegg.jp/dbget-bin/www_bget?C00022">
        <graphics name="C00022" fgcolor="#000000" bgcolor="#C0FFD0"
             type="circle" x="100" y="200" width="8" height="8"/>
    </entry>
    <entry id="18" name="undefined" type="group">
        <graphics fgcolor="#000000" bgcolor="#FFFFFF"
             type="rectangle" x="400" y="300" width="100" height="50"/>
        <component id="15"/>
        <component id="16"/>
    </entry>
    <relation entry1="15" entry2="16" type="ECrel">
        <subtype name="compound" value="17"/>
    </relation>
    <relation entry1="16" entry2="17" type="PCrel">
        <subtype name="hidden compound" value="cpd:C00024"/>
    </relation>
    <reaction id="1" name="rn:R00267" type="reversible">
        <substrate id="17" name="cpd:C00022"/>
        <product id="19" name="cpd:C00024"/>
        <product id="20" name="cpd:C00036"/>
    </reaction>
    <reaction id="2" name="rn:R01082 rn:R01083" type="irreversible">
        <substrate id="19" name="cpd:C00024"/>
        <substrate id="21" name="cpd:C00003"/>
        <product id="22" name="cpd:C00091"/>
        <product id="23" name="cpd:C00004"/>
    </reaction>
</pathway>
EOF

  class TestKGMLIntegrationParsing < Test::Unit::TestCase
    def setup
      @obj = Bio::KEGG::KGML.new(SAMPLE_KGML_DATA)
    end

    def test_pathway_parsing
      assert_equal "path:eco00020", @obj.name
      assert_equal "eco", @obj.org
      assert_equal "00020", @obj.number
      assert_equal "Citrate cycle (TCA cycle)", @obj.title
      assert_equal "http://www.kegg.jp/kegg/pathway/eco/eco00020.png", @obj.image
      assert_equal "http://www.kegg.jp/kegg-bin/show_pathway?eco00020", @obj.link
    end

    def test_entries_parsing
      assert_equal 4, @obj.entries.size

      # Test enzyme entry
      enzyme = @obj.entries[0]
      assert_equal 15, enzyme.id
      assert_equal "ec:1.1.1.37", enzyme.name
      assert_equal "enzyme", enzyme.type
      assert_equal "rn:R00267", enzyme.reaction
      assert_equal "http://www.kegg.jp/dbget-bin/www_bget?ec:1.1.1.37", enzyme.link

      # Test compound entry
      compound = @obj.entries[2]
      assert_equal 17, compound.id
      assert_equal "cpd:C00022", compound.name
      assert_equal "compound", compound.type
      assert_nil compound.reaction

      # Test group entry
      group = @obj.entries[3]
      assert_equal 18, group.id
      assert_equal "undefined", group.name
      assert_equal "group", group.type
      assert_equal [15, 16], group.components
    end

    def test_graphics_parsing
      # Test enzyme entry graphics
      enzyme = @obj.entries[0]
      assert_equal 1, enzyme.graphics.size
      graphics = enzyme.graphics[0]
      assert_equal "1.1.1.37", graphics.name
      assert_equal "#000000", graphics.fgcolor
      assert_equal "#BFBFFF", graphics.bgcolor
      assert_equal "rectangle", graphics.type
      assert_equal 177, graphics.x
      assert_equal 162, graphics.y
      assert_equal 46, graphics.width
      assert_equal 17, graphics.height

      # Test entry with multiple graphics
      multi_graphics_entry = @obj.entries[1]
      assert_equal 2, multi_graphics_entry.graphics.size

      # Test compound entry graphics (circle)
      compound = @obj.entries[2]
      compound_graphics = compound.graphics[0]
      assert_equal "circle", compound_graphics.type
      assert_equal 100, compound_graphics.x
      assert_equal 200, compound_graphics.y
      assert_equal 8, compound_graphics.width
      assert_equal 8, compound_graphics.height
    end

    def test_relations_parsing
      assert_equal 2, @obj.relations.size

      # Test first relation
      rel1 = @obj.relations[0]
      assert_equal 15, rel1.entry1
      assert_equal 16, rel1.entry2
      assert_equal "ECrel", rel1.type
      assert_equal "compound", rel1.name
      assert_equal "17", rel1.value

      # Test second relation
      rel2 = @obj.relations[1]
      assert_equal 16, rel2.entry1
      assert_equal 17, rel2.entry2
      assert_equal "PCrel", rel2.type
      assert_equal "hidden compound", rel2.name
      assert_equal "cpd:C00024", rel2.value
    end

    def test_reactions_parsing
      assert_equal 2, @obj.reactions.size

      # Test first reaction
      rxn1 = @obj.reactions[0]
      assert_equal 1, rxn1.id
      assert_equal "rn:R00267", rxn1.name
      assert_equal "reversible", rxn1.type
      assert_equal 1, rxn1.substrates.size
      assert_equal 2, rxn1.products.size

      # Test substrates and products
      substrate = rxn1.substrates[0]
      assert_equal 17, substrate.id
      assert_equal "cpd:C00022", substrate.name

      product1 = rxn1.products[0]
      assert_equal 19, product1.id
      assert_equal "cpd:C00024", product1.name

      # Test second reaction (multiple names, multiple substrates/products)
      rxn2 = @obj.reactions[1]
      assert_equal 2, rxn2.id
      assert_equal "rn:R01082 rn:R01083", rxn2.name
      assert_equal "irreversible", rxn2.type
      assert_equal 2, rxn2.substrates.size
      assert_equal 2, rxn2.products.size
    end

    def test_names_method
      # Test space-separated names parsing
      multi_name_entry = @obj.entries[1]
      names = multi_name_entry.names
      assert_equal ["ec:1.2.4.1", "ec:1.2.4.2"], names

      single_name_entry = @obj.entries[0]
      single_names = single_name_entry.names
      assert_equal ["ec:1.1.1.37"], single_names
    end

    def test_deprecated_methods
      # Test that deprecated methods still work
      enzyme = @obj.entries[0]
      
      # Test deprecated aliases
      assert_equal enzyme.id, enzyme.entry_id
      assert_equal enzyme.type, enzyme.category

      # Test deprecated graphics accessors
      assert_equal enzyme.graphics[-1].name, enzyme.label
      assert_equal enzyme.graphics[-1].type, enzyme.shape
      assert_equal enzyme.graphics[-1].x, enzyme.x
      assert_equal enzyme.graphics[-1].y, enzyme.y
      assert_equal enzyme.graphics[-1].width, enzyme.width
      assert_equal enzyme.graphics[-1].height, enzyme.height
      assert_equal enzyme.graphics[-1].fgcolor, enzyme.fgcolor
      assert_equal enzyme.graphics[-1].bgcolor, enzyme.bgcolor
    end

    def test_edge_cases
      # Test entries without graphics
      @obj.entries.each do |entry|
        if entry.graphics.nil? || entry.graphics.empty?
          assert_nil entry.label
          assert_nil entry.shape
          assert_nil entry.x
          assert_nil entry.y
          assert_nil entry.width
          assert_nil entry.height
          assert_nil entry.fgcolor
          assert_nil entry.bgcolor
        end
      end

      # Test entries without components
      non_group_entries = @obj.entries.select { |e| e.type != "group" }
      non_group_entries.each do |entry|
        assert_nil entry.components
      end
    end

    def test_data_types
      # Ensure all IDs are integers
      @obj.entries.each do |entry|
        assert_kind_of Integer, entry.id
        assert entry.id > 0
      end

      @obj.relations.each do |relation|
        assert_kind_of Integer, relation.entry1
        assert_kind_of Integer, relation.entry2
      end

      @obj.reactions.each do |reaction|
        assert_kind_of Integer, reaction.id
        reaction.substrates.each do |substrate|
          assert_kind_of Integer, substrate.id
        end
        reaction.products.each do |product|
          assert_kind_of Integer, product.id
        end
      end

      # Graphics coordinates should be integers
      @obj.entries.each do |entry|
        next unless entry.graphics
        entry.graphics.each do |graphics|
          assert_kind_of Integer, graphics.x
          assert_kind_of Integer, graphics.y
          assert_kind_of Integer, graphics.width
          assert_kind_of Integer, graphics.height
        end
      end
    end

  end #class TestKGMLIntegrationParsing

end; end #module TestKeggKGMLIntegration; #module Bio