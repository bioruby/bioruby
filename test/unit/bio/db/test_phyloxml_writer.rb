#
# = test/unit/bio/db/test_phyloxml_writer.rb - Unit test for Bio::PhyloXML::Writer
#
# Copyright::   Copyright (C) 2009
#               Diana Jaunzeikare <latvianlinuxgirl@gmail.com>
# License::     The Ruby License
#

require 'test/unit'
require 'singleton'

#this code is required for being able to require 'bio/db/phyloxml'
require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/command'

begin
  require 'libxml'
rescue LoadError
end

if defined?(LibXML) then
  require 'bio/db/phyloxml/phyloxml_writer'
end

module Bio
  class TestPhyloXMLWriter_Check_LibXML < Test::Unit::TestCase
    def test_libxml
      assert(defined?(LibXML),
             "Error: libxml-ruby library is not present. Please install libxml-ruby library. It is needed for Bio::PhyloXML module. Unit test for PhyloXML will not be performed.")
    end
  end #class TestPhyloXMLWriter_Check_LibXML
end #module Bio

module Bio

  module TestPhyloXMLWriterData

  bioruby_root  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s
  PHYLOXML_WRITER_TEST_DATA = Pathname.new(File.join(bioruby_root, 'test', 'data', 'phyloxml')).cleanpath.to_s

  def self.example_xml
    File.join PHYLOXML_WRITER_TEST_DATA, 'phyloxml_examples.xml'
  end

  def self.mollusca_short_xml
    File.join PHYLOXML_WRITER_TEST_DATA, 'ncbi_taxonomy_mollusca_short.xml'
  end

  def self.made_up_xml
    File.join PHYLOXML_WRITER_TEST_DATA, 'made_up.xml'
  end

  end #end module TestPhyloXMLWriterData

  class TestPhyloXMLWriter < Test::Unit::TestCase

    # helper class to write files using temporary directory
    class WriteTo
      include Singleton

      def initialize
        @leave_tmpdir = ENV['BIORUBY_TEST_DEBUG'].to_s.empty? ? false : true
        @tests = nil
        @tests_passed = 0
        @tmpdir = nil
      end

      attr_accessor :tests

      def test_passed
        @tests_passed += 1
        if !@leave_tmpdir and @tmpdir and @tests and
            @tests_passed >= @tests then
          #$stderr.print "Removing #{@tmpdir.path}\n"
          @tmpdir.close!
          @tmpdir = nil
          @tests_passed = 0
        end
      end

      def tmpdir
        @tmpdir ||= Bio::Command::Tmpdir.new('PhyloXML')
        @tmpdir
      end

      def file(f)
        File.join(self.tmpdir.path, f)
      end
    
      def example_xml_test
        self.file('phyloxml_examples_written.xml')
      end
    end #class WriteTo

    def setup
      @writeto = WriteTo.instance
      @writeto.tests ||= self.methods.collect { |x|
        x.to_s }.find_all { |y|
        /\Atest\_/ =~ y }.size
    end

    def teardown
      @writeto.test_passed
    end

#    def test_write
#       # @todo this is test for Tree.write
#      tree = Bio::PhyloXML::Tree.new
#      filename = @writeto.file('test.xml')
#      tree.write(filename)
#    end

    def test_init
      filename = @writeto.file("test2.xml")
      writer = Bio::PhyloXML::Writer.new(filename)
      
      tree = Bio::PhyloXML::Parser.open(TestPhyloXMLWriterData.mollusca_short_xml).next_tree
      
      writer.write(tree)

      assert_nothing_thrown do
        Bio::PhyloXML::Parser.open(filename)
      end

      #File.delete(filename)
    end

    def test_simple_xml
      filename = @writeto.file("sample.xml")
      writer = Bio::PhyloXML::Writer.new(filename)
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
      
      lines = File.open(filename).readlines()
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

      #File.delete(filename)
    end

    def test_phyloxml_examples_tree1
      tree = Bio::PhyloXML::Parser.open(TestPhyloXMLWriterData.example_xml).next_tree

      filename = @writeto.file('example_tree1.xml')
      writer = Bio::PhyloXML::Writer.new(filename)
      writer.write_branch_length_as_subelement = false
      writer.write(tree)

      assert_nothing_thrown do
        tree2  = Bio::PhyloXML::Parser.open(filename)
      end

      #File.delete(filename)

      #@todo check if branch length is written correctly
    end

    def test_phyloxml_examples_tree2
      phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLWriterData.example_xml)
      2.times do
        @tree = phyloxml.next_tree
      end
      
      filename = @writeto.file('example_tree2.xml')
      writer = Bio::PhyloXML::Writer.new(filename)
      writer.write(@tree)

      assert_nothing_thrown do
        tree2  = Bio::PhyloXML::Parser.open(filename)
      end
      
      #File.delete(filename)
    end

    def test_phyloxml_examples_tree4
      phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLWriterData.example_xml)
      4.times do
        @tree = phyloxml.next_tree
      end
      #@todo tree = phyloxml[4]
      filename = @writeto.file('example_tree4.xml')
      writer = Bio::PhyloXML::Writer.new(filename)
      writer.write(@tree)
      assert_nothing_thrown do
        @tree2 = Bio::PhyloXML::Parser.open(filename).next_tree
      end
      assert_equal(@tree.name, @tree2.name)
      assert_equal(@tree.get_node_by_name('A').taxonomies[0].scientific_name, @tree2.get_node_by_name('A').taxonomies[0].scientific_name)
      assert_equal(@tree.get_node_by_name('B').sequences[0].annotations[0].desc,
        @tree2.get_node_by_name('B').sequences[0].annotations[0].desc)
     # assert_equal(@tree.get_node_by_name('B').sequences[0].annotations[0].confidence.value,@tree2.get_node_by_name('B').sequences[0].annotations[0].confidence.value)
     #File.delete(filename)
    end

    def test_phyloxml_examples_sequence_relation
      phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLWriterData.example_xml)
      filename = @writeto.example_xml_test
      writer = Bio::PhyloXML::Writer.new(filename)
      phyloxml.each do |tree|
        writer.write(tree)
      end

      assert_nothing_thrown do
        @phyloxml_test = Bio::PhyloXML::Parser.open(filename)
      end

      5.times do
        @tree = @phyloxml_test.next_tree
      end

      assert_equal("x", @tree.sequence_relations[0].id_ref_0)
      assert_equal("z", @tree.sequence_relations[1].id_ref_1)
      assert_equal(nil, @tree.sequence_relations[2].distance)
      assert_equal("orthology", @tree.sequence_relations[2].type)

      #File.delete(filename)
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

      filename = @writeto.file('sequence.xml')
      Bio::PhyloXML::Writer.new(filename).write(tree)

      assert_nothing_thrown do
        Bio::PhyloXML::Parser.open(filename).next_tree
      end

      #File.delete(filename)
    end

    def test_phyloxml_examples_file
      outputfn = "phyloxml_examples_generated_in_test.xml"
      phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLWriterData.example_xml)
      filename = @writeto.file(outputfn)
      writer = Bio::PhyloXML::Writer.new(filename)
      phyloxml.each do |tree|
        writer.write(tree)
      end
      writer.write_other(phyloxml.other)

      assert_nothing_thrown do
        Bio::PhyloXML::Parser.open(filename)
      end
      # The output file is not deleted since it might be used in the phyloxml
      # parser test. But since the order of tests can't be assumed, I can't
      # hard code it in.
    end

    def test_made_up_xml_file
      phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLWriterData.made_up_xml)
      filename = @writeto.file("made_up_generated_in_test.xml")
      writer = Bio::PhyloXML::Writer.new(filename)
      # The output file is not deleted since it might be used in the phyloxml
      # parser test. But since the order of tests can't be assumed, I can't
      # hard code it in.
      phyloxml.each do |tree|
        writer.write(tree)
      end      
    end

  end


end if defined?(LibXML) #end module Bio

