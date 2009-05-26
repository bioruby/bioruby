#
# = test/bio/db/phyloxml.rb - Unit test for Bio::PhyloXML
#
# Copyright::   Copyright (C) 2009
#               Diana Jaunzeikare <latvianlinuxgirl@gmail.com>
# License::     The Ruby License
#

require 'test/unit'

#this code is required for being able to require 'bio/db/phyloxml'
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio'
require 'bio/tree'

begin #begin rescue LoadError block (test if xml is here)

require 'bio/db/phyloxml/phyloxml_elements'
require 'bio/db/phyloxml/phyloxml_parser'
require 'bio/db/phyloxml/phyloxml_writer'

module Bio

  module TestPhyloXMLData

  bioruby_root  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s
  PHYLOXML_WRITER_TEST_DATA = Pathname.new(File.join(bioruby_root, 'test', 'data', 'phyloxml')).cleanpath.to_s

  def self.file(f)
    File.join PHYLOXML_WRITER_TEST_DATA, f
  end
    
  def self.example_xml
    File.join PHYLOXML_WRITER_TEST_DATA, 'phyloxml_examples.xml'
  end

  def self.mollusca_short_xml
    File.join PHYLOXML_WRITER_TEST_DATA, 'ncbi_taxonomy_mollusca_short.xml'
  end

  def self.example_xml_test
    File.join PHYLOXML_WRITER_TEST_DATA, 'phyloxml_examples_written.xml'
  end

  end #end module TestPhyloXMLData

  class TestPhyloXMLWriter < Test::Unit::TestCase

#    def test_write
#       # @todo this is test for Tree.write
#      tree = Bio::PhyloXML::Tree.new
#      tree.write(TestPhyloXMLData.file('test.xml'))
#    end

    def test_init
      writer = Bio::PhyloXML::Writer.new(TestPhyloXMLData.file("test2.xml"))
      
      tree = Bio::PhyloXML::Parser.new(TestPhyloXMLData.mollusca_short_xml).next_tree
      
      writer.write(tree)

      assert_nothing_thrown do
        Bio::PhyloXML::Parser.new(TestPhyloXMLData.file("test2.xml"))
      end

      File.delete(TestPhyloXMLData.file("test2.xml"))
    end

    def test_simple_xml
      writer = Bio::PhyloXML::Writer.new(TestPhyloXMLData.file("sample.xml"))
      tree = Bio::PhyloXML::Tree.new
      tree.rooted = true
      tree.name = "Test tree"
      root_node = Bio::PhyloXML::Node.new
      tree.root = root_node
      root_node.name = "A"
      #root_node.taxonomies[0] = Bio::PhyloXML::Taxonomy.new
      root_node.taxonomies << Bio::PhyloXML::Taxonomy.new
      root_node.taxonomies[0].scientific_name = "Animal animal"
      node2 = Bio::PhyloXML::Node.new
      node2.name = "B"
      tree.add_node(node2)
      tree.add_edge(root_node, node2)
      writer.write(tree)
      
      lines = File.open(TestPhyloXMLData.file("sample.xml")).readlines()
      assert_equal("<phyloxml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.phyloxml.org http://www.phyloxml.org/1.10/phyloxml.xsd\" xmlns=\"http://www.phyloxml.org\">",
                    lines[1].chomp)
      assert_equal("  <phylogeny rooted=\"true\">", lines[2].chomp)
      assert_equal("    <name>Test tree</name>", lines[3].chomp)
      assert_equal("    <clade>", lines[4].chomp)
      assert_equal("      <name>A</name>", lines[5].chomp)
      assert_equal("      <taxonomy>", lines[6].chomp)
      assert_equal("        <scientific_name>Animal animal</scientific_name>", lines[7].chomp)
      assert_equal("      </taxonomy>", lines[8].chomp)
      assert_equal("        <name>B</name>", lines[10].chomp)
      assert_equal("    </clade>", lines[12].chomp)
      assert_equal("  </phylogeny>", lines[13].chomp)
      assert_equal("</phyloxml>", lines[14].chomp)

      File.delete(TestPhyloXMLData.file("sample.xml"))
    end

    def test_phyloxml_examples_tree1
      tree = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml).next_tree

      writer = Bio::PhyloXML::Writer.new('./example_tree1.xml')
      writer.write_branch_length_as_subelement = false
      writer.write(tree)

      assert_nothing_thrown do
        tree2  = Bio::PhyloXML::Parser.new('./example_tree1.xml')
      end

      File.delete('./example_tree1.xml')

      #@todo check if branch length is written correctly
    end

    def test_phyloxml_examples_tree2
      phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      2.times do
        @tree = phyloxml.next_tree
      end
      
      writer = Bio::PhyloXML::Writer.new('./example_tree2.xml')
      writer.write(@tree)

      assert_nothing_thrown do
        tree2  = Bio::PhyloXML::Parser.new('./example_tree2.xml')
      end
      
      File.delete('./example_tree2.xml')
    end

    def test_phyloxml_examples_tree4
      phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      4.times do
        @tree = phyloxml.next_tree
      end
      #@todo tree = phyloxml[4]
      writer = Bio::PhyloXML::Writer.new('./example_tree4.xml')
      writer.write(@tree)
      assert_nothing_thrown do
        @tree2 = Bio::PhyloXML::Parser.new('./example_tree4.xml').next_tree
      end
      assert_equal(@tree.name, @tree2.name)
      assert_equal(@tree.get_node_by_name('A').taxonomies[0].scientific_name, @tree2.get_node_by_name('A').taxonomies[0].scientific_name)
      assert_equal(@tree.get_node_by_name('B').sequences[0].annotations[0].desc,
        @tree2.get_node_by_name('B').sequences[0].annotations[0].desc)
     # assert_equal(@tree.get_node_by_name('B').sequences[0].annotations[0].confidence.value,@tree2.get_node_by_name('B').sequences[0].annotations[0].confidence.value)
     File.delete('./example_tree4.xml')
    end

    def test_phyloxml_examples_sequence_relation
      phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      writer = Bio::PhyloXML::Writer.new(TestPhyloXMLData.example_xml_test)
      phyloxml.each do |tree|
        writer.write(tree)
      end

      assert_nothing_thrown do
        @phyloxml_test = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml_test)
      end

      5.times do
        @tree = @phyloxml_test.next_tree
      end

      assert_equal(@tree.sequence_relations[0].id_ref_0, "x")
      assert_equal(@tree.sequence_relations[1].id_ref_1, "z")
      assert_equal(@tree.sequence_relations[2].distance, nil)
      assert_equal(@tree.sequence_relations[2].type, "orthology")

      File.delete(TestPhyloXMLData.example_xml_test)
    end

    def test_generate_xml_with_sequence
      tree = Bio::PhyloXML::Tree.new
      r = Bio::PhyloXML::Node.new
      tree.add_node(r)
      tree.root = r
      n = Bio::PhyloXML::Node.new
      tree.add_node(n)
      tree.add_edge(tree.root, n)
      tree.rooted = true

      n.name = "A"
      seq = PhyloXML::Sequence.new
      n.sequences[0] = seq
      seq.annotations[0] = PhyloXML::Annotation.new
      seq.annotations[0].desc = "Sample annotation"
      seq.name = "sequence name"
      seq.location = "somewhere"
      seq.accession = PhyloXML::Accession.new
      seq.accession.source = "ncbi"
      seq.accession.value = "AAB80874"
      seq.symbol = "adhB"
      seq.mol_seq = "TDATGKPIKCMAAIAWEAKKPLSIEEVEVAPPKSGEVRIKILHSGVCHTD"
      seq.uri = PhyloXML::Uri.new
      seq.uri.desc = "EMBL REPTILE DATABASE"
      seq.uri.uri = "http://www.embl-heidelberg.de/~uetz/families/Varanidae.html"
      seq.domain_architecture = PhyloXML::DomainArchitecture.new
      seq.domain_architecture.length = 1249
      domain1 = PhyloXML::ProteinDomain.new
      seq.domain_architecture.domains << domain1
      domain1.from = 6
      domain1.to = 90
      domain1.confidence = "7.0E-26"
      domain1.value = "CARD"
      domain2 = PhyloXML::ProteinDomain.new
      seq.domain_architecture.domains << domain2
      domain2.from = 109
      domain2.to = 414
      domain2.confidence = "7.2E-117"
      domain2.value = "NB-ARC"

      Bio::PhyloXML::Writer.new('./sequence.xml').write(tree)

      assert_nothing_thrown do
        Bio::PhyloXML::Parser.new('./sequence.xml').next_tree
      end

      File.delete('./sequence.xml')
    end

    def test_phyloxml_examples_file
      phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      writer = Bio::PhyloXML::Writer.new(TestPhyloXMLData.file("phyloxml_examples_test.xml"))
      phyloxml.each do |tree|
        writer.write(tree)
      end
      writer.write_other(phyloxml.other)

      assert_nothing_thrown do
        Bio::PhyloXML::Parser.new(TestPhyloXMLData.file("phyloxml_examples_test.xml"))
      end
    end

    def test_made_up_xml_file
      phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.file("made_up.xml"))
      writer = Bio::PhyloXML::Writer.new(TestPhyloXMLData.file("made_up_test.xml"))
      phyloxml.each do |tree|
        writer.write(tree)
      end      
    end

  end


end #end module Biof

rescue LoadError
    raise "Error: libxml-ruby library is not present. Please install libxml-ruby library. It is needed for Bio::PhyloXML module. Unit test for PhyloXML will not be performed."
end #end begin and rescue block