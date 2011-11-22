#
# = test/unit/bio/db/test_phyloxml.rb - Unit test for Bio::PhyloXML::Parser
#
# Copyright::   Copyright (C) 2009
#               Diana Jaunzeikare <latvianlinuxgirl@gmail.com>
# License::     The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'

begin
  require 'libxml'
rescue LoadError
end

if defined?(LibXML) then
  require 'bio/db/phyloxml/phyloxml_parser'
end

module Bio
  class TestPhyloXML_Check_LibXML < Test::Unit::TestCase
    def test_libxml
      assert(defined?(LibXML),
             "Error: libxml-ruby library is not present. Please install libxml-ruby library. It is needed for Bio::PhyloXML module. Unit test for PhyloXML will not be performed.")
    end
  end #class TestPhyloXML_LibXMLCheck
end #module Bio

module Bio

  module TestPhyloXMLData

  PHYLOXML_TEST_DATA = Pathname.new(File.join(BioRubyTestDataPath, 'phyloxml')).cleanpath.to_s

  def self.example_xml
    File.join PHYLOXML_TEST_DATA, 'phyloxml_examples.xml'
    #If you want to test the output of writer, then do this:
    #File.join PHYLOXML_TEST_DATA, 'phyloxml_examples_test.xml'
    # But make sure you run ruby test/unit/bio/db/test_phyloxml_writer.rb before
  end

  def self.made_up_xml
    File.join PHYLOXML_TEST_DATA, 'made_up.xml'
    #If you want to test the output of writer, then do this:
    #File.join PHYLOXML_TEST_DATA, 'made_up_test.xml'
    # But make sure you run ruby test/unit/bio/db/test_phyloxml_writer.rb before
  end

  def self.metazoa_xml
    File.join PHYLOXML_TEST_DATA, 'ncbi_taxonomy_metazoa.xml'
  end

  def self.mollusca_xml
    File.join PHYLOXML_TEST_DATA, 'ncbi_taxonomy_mollusca.xml'
  end

  def self.life_xml
    File.join PHYLOXML_TEST_DATA, 'tol_life_on_earth_1.xml'
  end

  def self.dollo_xml
    File.join PHYLOXML_TEST_DATA, 'o_tol_332_d_dollo.xml'
  end

  def self.mollusca_short_xml
    File.join PHYLOXML_TEST_DATA, 'ncbi_taxonomy_mollusca_short.xml'
  end

end #end module TestPhyloXMLData

  

  class TestPhyloXML_class_methods < Test::Unit::TestCase
  
    def test_open
      filename = TestPhyloXMLData.example_xml
      assert_instance_of(Bio::PhyloXML::Parser,
                         phyloxml = Bio::PhyloXML::Parser.open(filename))
      common_test_next_tree(phyloxml)
      phyloxml.close
    end

    def test_open_with_block
      filename = TestPhyloXMLData.example_xml
      phyloxml_bak = nil
      ret = Bio::PhyloXML::Parser.open(filename) do |phyloxml|
        assert_instance_of(Bio::PhyloXML::Parser, phyloxml)
        common_test_next_tree(phyloxml)
        phyloxml_bak = phyloxml
        "ok"
      end
      assert_equal("ok", ret)
      assert_equal(true, phyloxml_bak.closed?)
    end

    def test_new
      str = File.read(TestPhyloXMLData.example_xml)
      assert_instance_of(Bio::PhyloXML::Parser,
                         phyloxml = Bio::PhyloXML::Parser.new(str))
      common_test_next_tree(phyloxml)
    end

    def test_for_io
      io = File.open(TestPhyloXMLData.example_xml)
      assert_instance_of(Bio::PhyloXML::Parser,
                         phyloxml = Bio::PhyloXML::Parser.for_io(io))
      common_test_next_tree(phyloxml)
      io.close
    end

    def common_test_next_tree(phyloxml)
      tree = phyloxml.next_tree
      tree_arr = []
      while tree != nil do
        tree_arr[tree_arr.length] = tree.name
        tree = phyloxml.next_tree
      end      
      assert_equal(13, tree_arr.length)
    end
    private :common_test_next_tree
    
  end #class TestPhyloXML_class_methods



  class TestPhyloXML_private_methods < Test::Unit::TestCase
    def setup
      @phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml)
    end

    def teardown
      @phyloxml.close
    end

    def test__validate
      assert_nothing_raised {
        @phyloxml.instance_eval {
          _validate(:file, TestPhyloXMLData.example_xml)
        }
      }
    end

    def test__validate_string
      assert_nothing_raised {
        @phyloxml.instance_eval {
          _validate(:string, '<?xml version="1.0"?><phyloxml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.phyloxml.org http://www.phyloxml.org/1.10/phyloxml.xsd" xmlns="http://www.phyloxml.org"/>')
        }
      }
    end

    def test__validate_validation_error
      libxml_set_handler_quiet
      assert_raise(RuntimeError) {
        @phyloxml.instance_eval {
          _validate(:string, '<a>test</a>')
        }
      }
      libxml_set_handler_verbose
    end

    def test__schema
      s = @phyloxml.instance_eval { _schema }
      assert_instance_of(LibXML::XML::Schema, s)
    end

    def test__secure_filename
      assert_equal('http:/bioruby.org/test.xml',
                   @phyloxml.instance_eval {
                     _secure_filename('http://bioruby.org/test.xml')
                   })
    end

    def test__secure_filename_unchanged
      assert_equal('test/test.xml',
                   @phyloxml.instance_eval {
                     _secure_filename('test/test.xml')
                   })
    end

    def test_ClosedPhyloXMLParser
      cp = Bio::PhyloXML::Parser::ClosedPhyloXMLParser.new
      assert_raise(LibXML::XML::Error) { cp.next_tree }
    end

    private

    def libxml_set_handler_quiet
      # Sets quiet handler.
      # Note that there are no way to get current handler.
      LibXML::XML::Error.set_handler(&LibXML::XML::Error::QUIET_HANDLER)
    end

    def libxml_set_handler_verbose
      # Sets verbose handler (default LibXML error handler).
      # Note that there are no way to get current handler.
      LibXML::XML::Error.set_handler(&LibXML::XML::Error::VERBOSE_HANDLER)
    end
  end #class TestPhyloXML_private_methods



  class TestPhyloXML_close < Test::Unit::TestCase
    def phyloxml_open(&block)
      Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml, &block)
    end
    private :phyloxml_open

    def test_close
      phyloxml = phyloxml_open
      phyloxml.next_tree
      assert_nil(phyloxml.close)
    end

    def test_closed?
      phyloxml = phyloxml_open
      assert_equal(false, phyloxml.closed?)
      phyloxml.next_tree
      assert_equal(false, phyloxml.closed?)
      phyloxml.close
      assert_equal(true, phyloxml.closed?)
    end

    def test_closed_with_block
      ret = phyloxml_open do |phyloxml|
        assert_equal(false, phyloxml.closed?)
        phyloxml.next_tree
        assert_equal(false, phyloxml.closed?)
        phyloxml
      end
      assert_equal(true, ret.closed?)
    end

    def test_close_after_close
      phyloxml = phyloxml_open
      phyloxml.close
      assert_raise(LibXML::XML::Error) { phyloxml.close }
    end

    def test_next_tree_after_close
      phyloxml = phyloxml_open
      phyloxml.close
      assert_raise(LibXML::XML::Error) { phyloxml.next_tree }
    end

    def test_next_tree_after_open_with_block
      phyloxml = phyloxml_open { |arg| arg }
      assert_raise(LibXML::XML::Error) { phyloxml.next_tree }
    end

    def test_close_after_open_with_block
      phyloxml = phyloxml_open { |arg| arg }
      assert_raise(LibXML::XML::Error) { phyloxml.close }
    end

    def test_close_in_open_with_block
      phyloxml = phyloxml_open do |arg|
        ret = arg
        assert_nil(arg.close)
        ret
      end
      assert_raise(LibXML::XML::Error) { phyloxml.close }
    end

    def test_close_does_not_affect_io
      io = File.open(TestPhyloXMLData.example_xml)
      phyloxml = Bio::PhyloXML::Parser.for_io(io)
      phyloxml.next_tree
      phyloxml.close
      assert(!io.closed?)
    end
  end #class TestPhyloXML_close



  class TestPhyloXML1 < Test::Unit::TestCase
  
    def setup
      @phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml)
    end

    def teardown
      @phyloxml.close
    end
    
    def test_initialize
      assert_instance_of(Bio::PhyloXML::Parser, @phyloxml)
    end 
      
    def test_next_tree()
      tree = @phyloxml.next_tree
      tree_arr = []
      while tree != nil do

        tree_arr[tree_arr.length] = tree.name
        tree = @phyloxml.next_tree
      end      
      assert_equal(13, tree_arr.length)
    end
     
  end #class TestPhyloXML1



  class TestPhyloXML2 < Test::Unit::TestCase
  
    #setup is called before and every time any function es executed.  
    def setup
      @phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml)
      @tree = @phyloxml.next_tree
    end
    
    def test_tree_name
      assert_equal("example from Prof. Joe Felsenstein's book \"Inferring Phylogenies\"", @tree.name)
    end
    
    def test_tree_description
      assert_equal("phyloXML allows to use either a \"branch_length\" attribute or element to indicate branch lengths.", @tree.description)
    end
    
    def test_branch_length_attribute
      assert_equal(0.792, @tree.total_distance)
    end

    def test_rooted_atr
       assert_equal(true, @tree.rooted)
    end
    
   
    def test_branch_length_tag
      @tree = @phyloxml.next_tree
      assert_equal(0.792, @tree.total_distance)
    end
    
    def test_bootstrap
      #iterate throuch first 2 trees to get to the third
      @tree = @phyloxml.next_tree
      @tree = @phyloxml.next_tree
      node = @tree.get_node_by_name("AB")
      assert_equal('bootstrap', node.confidences[0].type)
      assert_equal(89, node.confidences[0].value)
    end

    def test_to_biotreenode_bootstrap
      #iterate throuch first 2 trees to get to the third
      @tree = @phyloxml.next_tree
      @tree = @phyloxml.next_tree
      node = @tree.get_node_by_name("AB")
      bionode = node.to_biotreenode
      assert_equal(89, bionode.bootstrap)
    end

    def test_duplications
      4.times do
        @tree = @phyloxml.next_tree
      end
      node = @tree.root
      assert_equal(1, node.events.speciations)
    end

    def test_taxonomy_scientific_name
      3.times do
        @tree = @phyloxml.next_tree
      end
      t = @tree.get_node_by_name('A').taxonomies[0]
      assert_equal('E. coli', t.scientific_name)
      assert_equal("J. G. Cooper, 1863", t.authority)
      t = @tree.get_node_by_name('C').taxonomies[0]
      assert_equal('C. elegans', t.scientific_name)
    end

    def test_taxonomy_id
      5.times do
        @tree = @phyloxml.next_tree
      end
      leaves = @tree.leaves
      codes = []
      ids = []
      #id_types = []
      leaves.each { |node|
        codes[codes.length] = node.taxonomies[0].code
        ids[ids.length] = node.taxonomies[0].taxonomy_id
        #id_types[id_types.length] = node.taxonomy.id_type
      }
      assert_equal(["CLOAB",  "DICDI", "OCTVU"], codes.sort)
     #@todo assert ids, id_types. or create new class for id.
    end

    def test_taxonomy2
      9.times do
        @tree = @phyloxml.next_tree
      end
      taxonomy = @tree.root.taxonomies[0]
      assert_equal("8556", taxonomy.taxonomy_id.value)
      assert_equal("NCBI", taxonomy.taxonomy_id.provider)
      assert_equal("Varanus", taxonomy.scientific_name)
      assert_equal("genus", taxonomy.rank)
      assert_equal("EMBL REPTILE DATABASE", taxonomy.uri.desc)
      assert_equal("http://www.embl-heidelberg.de/~uetz/families/Varanidae.html", taxonomy.uri.uri)
    end

    def test_distribution_desc
      9.times do
        @tree = @phyloxml.next_tree
      end
      leaves = @tree.leaves
      descrs = []
      leaves.each { |node|
        descrs << node.distributions[0].desc
      }
      assert_equal(['Africa', 'Asia', 'Australia'], descrs.sort)
    end

    def test_distribution_point
      10.times do
        @tree = @phyloxml.next_tree
      end
      point = @tree.get_node_by_name('A').distributions[0].points[0]
      assert_equal("WGS84", point.geodetic_datum)
      assert_equal(47.481277, point.lat)
      assert_equal(8.769303, point.long)
      assert_equal(472, point.alt)

      point = @tree.get_node_by_name('B').distributions[0].points[0]
      assert_equal("WGS84", point.geodetic_datum)
      assert_equal(35.155904, point.lat)
      assert_equal(136.915863, point.long)
      assert_equal(10, point.alt)
    end

    def test_sequence
      3.times do
        @tree = @phyloxml.next_tree
      end
      sequence_a = @tree.get_node_by_name('A').sequences[0]
      assert_equal('alcohol dehydrogenase', sequence_a.annotations[0].desc)
      assert_equal("probability", sequence_a.annotations[0].confidence.type)
      assert_equal(0.99, sequence_a.annotations[0].confidence.value)
      sequence_b = @tree.get_node_by_name('B').sequences[0]
      assert_equal('alcohol dehydrogenase', sequence_b.annotations[0].desc)
      assert_equal("probability", sequence_b.annotations[0].confidence.type)
      assert_equal(0.91, sequence_b.annotations[0].confidence.value)
      sequence_c = @tree.get_node_by_name('C').sequences[0]
      assert_equal('alcohol dehydrogenase', sequence_c.annotations[0].desc)
      assert_equal("probability", sequence_c.annotations[0].confidence.type)
      assert_equal(0.67, sequence_c.annotations[0].confidence.value)

    end

     def test_sequence2
       4.times do
         @tree = @phyloxml.next_tree
       end
       leaves = @tree.leaves
       leaves.each { |node|
         #just test one node for now
         if node.sequences[0].id_source == 'x'
           assert_equal('adhB', node.sequences[0].symbol)
           assert_equal("ncbi", node.sequences[0].accession.source)
           assert_equal('AAB80874', node.sequences[0].accession.value)
           assert_equal('alcohol dehydrogenase', node.sequences[0].name)
         end
         if node.sequences[0].id_source == 'z'
           assert_equal("InterPro:IPR002085",
                        node.sequences[0].annotations[0].ref)
         end
       }
     end

     def test_sequence3
       5.times do
         @tree = @phyloxml.next_tree
       end
       @tree.leaves.each { |node|
         if node.sequences[0].symbol == 'ADHX'
          assert_equal('UniProtKB', node.sequences[0].accession.source)
          assert_equal('P81431', node.sequences[0].accession.value)
          assert_equal('Alcohol dehydrogenase class-3', node.sequences[0].name)
          assert_equal(true, node.sequences[0].is_aligned)
          assert_equal(true, node.sequences[0].is_aligned?)
          assert_equal('TDATGKPIKCMAAIAWEAKKPLSIEEVEVAPPKSGEVRIKILHSGVCHTD',
                       node.sequences[0].mol_seq)
          assert_equal('EC:1.1.1.1', node.sequences[0].annotations[0].ref)
          assert_equal('GO:0004022', node.sequences[0].annotations[1].ref)
         end
       }
     end

     def test_to_biosequence
       5.times do
         @tree = @phyloxml.next_tree
       end
       @tree.leaves.each { |node|
         if node.sequences[0].symbol =='ADHX'
           seq = node.sequences[0].to_biosequence
           assert_equal('Alcohol dehydrogenase class-3', seq.definition)
           assert_equal('UniProtKB', seq.id_namespace)
           assert_equal('P81431', seq.entry_id)
           assert_equal('TDATGKPIKCMAAIAWEAKKPLSIEEVEVAPPKSGEVRIKILHSGVCHTD',
                        seq.seq.to_s)
         end
       }
     end

     def test_extract_biosequence
       5.times do
         @tree = @phyloxml.next_tree
       end
       @tree.leaves.each { |node|
         if node.sequences[0].symbol == 'ADHX'
           seq = node.extract_biosequence
           assert_equal('Alcohol dehydrogenase class-3', seq.definition)
           assert_equal('TDATGKPIKCMAAIAWEAKKPLSIEEVEVAPPKSGEVRIKILHSGVCHTD',
                        seq.seq.to_s)
           assert_equal('Octopus vulgaris', seq.classification[0])
         end
       }
     end

     def test_date
       11.times do
         @tree = @phyloxml.next_tree
       end
       date_a = @tree.get_node_by_name('A').date
       assert_equal('mya', date_a.unit)
       assert_equal("Silurian", date_a.desc)
       assert_equal(425, date_a.value)
       date_b = @tree.get_node_by_name('B').date
       assert_equal('mya', date_b.unit)
       assert_equal("Devonian", date_b.desc)
       assert_equal(320, date_b.value)
       date_c = @tree.get_node_by_name('C').date
       assert_equal('mya', date_c.unit)
       assert_equal('Ediacaran', date_c.desc)
       assert_equal(600, date_c.value)
       assert_equal(570, date_c.minimum)
       assert_equal(630, date_c.maximum)
     end

     def test_property
       7.times do
         @tree = @phyloxml.next_tree
       end
       property = @tree.get_node_by_name('A').properties[0]
       assert_equal('xsd:integer', property.datatype)
       assert_equal('NOAA:depth', property.ref)
       assert_equal('clade', property.applies_to)
       assert_equal('METRIC:m', property.unit)
       assert_equal(' 1200 ', property.value)
     end

     def test_uri
       9.times do
         @tree = @phyloxml.next_tree
       end
       uri = @tree.root.taxonomies[0].uri
       assert_equal("EMBL REPTILE DATABASE", uri.desc)
       assert_equal("http://www.embl-heidelberg.de/~uetz/families/Varanidae.html", uri.uri)
     end


    
  end #class TestPhyloXML2
  
  class TestPhyloXML3 < Test::Unit::TestCase
  
  TEST_STRING = 
  """<phylogeny rooted=\"true\">
      <name>same example, with support of type \"bootstrap\"</name>
      <clade>
         <clade branch_length=\"0.06\">
            <name>AB</name>
            <confidence type=\"bootstrap\">89</confidence>
            <clade branch_length=\"0.102\">
               <name>A</name>
            </clade>
            <clade branch_length=\"0.23\">
               <name>B</name>
            </clade>
         </clade>
         <clade branch_length=\"0.4\">
            <name>C</name>
         </clade>
      </clade>
   </phylogeny>"""
   
    def setup
      phyloxml = Bio::PhyloXML::Parser.new(TEST_STRING)
      @tree = phyloxml.next_tree()  

    end
  
    def test_children
      node =  @tree.get_node_by_name("AB")
      # nodes  = @tree.children(node).sort { |a,b| a.name <=> b.name }
      node_names = []
      @tree.children(node).each { |children|
        node_names[node_names.length] = children.name
      }
      node_names.sort!
      assert_equal(["A", "B"], node_names)
    end

  
  end # class

  class TestPhyloXML4 < Test::Unit::TestCase

    #test cases what pertain to tree

    def test_clade_relation

      @phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml)
      7.times do
        @tree = @phyloxml.next_tree
      end
       cr = @tree.clade_relations[0]
       assert_equal("b", cr.id_ref_0)
       assert_equal("c", cr.id_ref_1)
       assert_equal("network_connection", cr.type)
    end

    def test_sequence_realations
      @phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml)
      5.times do
        @tree = @phyloxml.next_tree
      end

      sr = @tree.sequence_relations[0]
       
       assert_equal("x", sr.id_ref_0)
       assert_equal("y", sr.id_ref_1)
       assert_equal("paralogy", sr.type)
    end


  end

  class TestPhyloXML5 < Test::Unit::TestCase

    #testing file made_up.xml
    def setup
      @phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.made_up_xml)
    end

    def test_phylogeny_confidence
      tree = @phyloxml.next_tree()
      assert_equal("bootstrap", tree.confidences[0].type)
      assert_equal(89, tree.confidences[0].value)
      assert_equal("probability", tree.confidences[1].type)
      assert_equal(0.71, tree.confidences[1].value)
    end

    def test_to_biotreenode_probability
      tree = @phyloxml.next_tree()
      node = tree.get_node_by_name('c').to_biotreenode
      assert_equal(nil, node.bootstrap)
    end

    def test_polygon
      2.times do
        @tree = @phyloxml.next_tree
      end
      polygon = @tree.get_node_by_name('A').distributions[0].polygons[0]
      assert_equal(3, polygon.points.length)
      assert_equal(47.481277, polygon.points[0].lat)
      assert_equal("m", polygon.points[0].alt_unit)
      assert_equal(136.915863, polygon.points[1].long)
      assert_equal(452, polygon.points[2].alt)
      polygon = @tree.get_node_by_name('A').distributions[0].polygons[1]
      #making sure can read in second polygon
      assert_equal(3, polygon.points.length)
      assert_equal(40.481277, polygon.points[0].lat)
    end

    def test_reference
      3.times do
        @tree = @phyloxml.next_tree
      end
      references = @tree.get_node_by_name('A').references
      assert_equal("10.1093/bioinformatics/btm619", references[0].doi)
      assert_equal("Phyutility: a phyloinformatics tool for trees, alignments and molecular data", references[0].desc)
      assert_equal("10.1186/1471-2105-9-S1-S23", references[1].doi)
    end


    def test_single_clade
      4.times do
        @tree = @phyloxml.next_tree()
      end
      assert_equal("A", @tree.root.name)
    end

    def test_domain_architecture
      5.times {@tree = @phyloxml.next_tree()}
      node = @tree.get_node_by_name("22_MOUSE")
      assert_equal("22_MOUSE", node.name)
      assert_equal("MOUSE", node.taxonomies[0].code)
      domain_arch = node.sequences[0].domain_architecture
      assert_equal(1249, domain_arch.length)
      assert_equal(6, domain_arch.domains[0].from)
      assert_equal(90, domain_arch.domains[0].to)
      assert_in_delta(7.0E-26, domain_arch.domains[0].confidence, 1E-26)
      assert_equal("CARD", domain_arch.domains[0].value)
      assert_equal("x", domain_arch.domains[0].id)
      assert_equal(733, domain_arch.domains[5].from)
      assert_equal(771, domain_arch.domains[5].to)
      assert_in_delta(4.7E-14, domain_arch.domains[5].confidence, 1E-15)
      assert_equal("WD40", domain_arch.domains[5].value)
      assert_equal(1168, domain_arch.domains.last.from)
      assert_equal(1204, domain_arch.domains.last.to)
      assert_equal(0.3, domain_arch.domains.last.confidence)
      assert_equal("WD40", domain_arch.domains.last.value)
    end

    def test_clade_width
      @tree = @phyloxml.next_tree
      assert_equal(0.2, @tree.root.width)
    end

    def test_binary_characters
      6.times do
        @tree = @phyloxml.next_tree
      end
      bc =@tree.get_node_by_name("cellular_organisms").binary_characters
      assert_equal("parsimony inferred", bc.bc_type)
      assert_equal(0, bc.lost_count)
      assert_equal(0, bc.gained_count)
      assert_equal([], bc.lost)

      bc2 = @tree.get_node_by_name("Eukaryota").binary_characters
      assert_equal(2, bc2.gained_count)
      assert_equal(["Cofilin_ADF", "Gelsolin"], bc2.gained)
      assert_equal(["Cofilin_ADF", "Gelsolin"], bc2.present)
    end

    def test_rerootable2
      6.times do
        @tree = @phyloxml.next_tree
      end
      assert_equal(false, @tree.rerootable)
    end

    def test_phylogeny_attributes
      @tree = @phyloxml.next_tree
      assert_equal(true, @tree.rooted)
      assert_equal(false, @tree.rerootable)
      #@todo make this test pass
      #assert_equal("1", @tree.branch_length_unit)

    end

    def test_taxonomy_synonym
      5.times do
        @tree = @phyloxml.next_tree
      end
      node = @tree.get_node_by_name('22_MOUSE')
      t = node.taxonomies[0]
      assert_equal("murine", t.synonyms[0])
      assert_equal("vermin", t.synonyms[1])

    end

    def test_annotation_property
      5.times do
        @tree =@phyloxml.next_tree
      end
      node = @tree.get_node_by_name('22_MOUSE')
      prop = node.sequences[0].annotations[0].properties[0]
      assert_equal("1200", prop.value)
    end

  end
  class TestPhyloXML5 < Test::Unit::TestCase

    def test_each
      phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml)
      count = 0
      phyloxml.each do |tree|
        count +=1
      end
      assert_equal(13, count)
    end

    def test_other
      phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml)
      assert_equal(nil, phyloxml.other[0])
      phyloxml.each do |tree|
        #iterate through all trees, to get to the end
      end
      o = phyloxml.other[0]
      assert_equal('align:alignment', o.element_name)
      assert_equal('seq', o.children[0].element_name)
      assert_equal('aggtcgcggcctgtggaagtcctctcct', o.children[1].value)
      assert_equal("C", o.children[2].attributes["name"])

    end

    def test_array_behaviour
      phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.example_xml)
      tree = phyloxml[2]
      assert_equal("same example, with support of type \"bootstrap\"",
                   tree.name)
    end


#    def test_get_tree_by_name
#       @phyloxml = Bio::PhyloXML::Parser.open(TestPhyloXMLData.made_up_xml)
#       tree = @phyloxml.get_tree_by_name "testing confidence"
#
#    end

  end


end if defined?(LibXML) #end module Bio
