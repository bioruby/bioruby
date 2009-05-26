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
  PHYLOXML_TEST_DATA = Pathname.new(File.join(bioruby_root, 'test', 'data', 'phyloxml')).cleanpath.to_s

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

#  class TestPhyloXML0 <Test::Unit::TestCase
#    #test if xml lib exists.
#
#    def test_libxml
#      begin
#        require 'xml'
#      rescue LoadError
#        puts "Please install libxml-ruby library. It is needed for Bio::PhyloXML module. Unit tests will exit now."
#        #exit 1
#      end
#    end
#
#  end

  

  class TestPhyloXML1 < Test::Unit::TestCase
  
    def setup
      @phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
    end
    
    def test_init
      assert_equal(@phyloxml.class, Bio::PhyloXML::Parser)
    end 
      
    def test_next_tree()
      tree = @phyloxml.next_tree
      tree_arr = []
      while tree != nil do

        tree_arr[tree_arr.length] = tree.name
        tree = @phyloxml.next_tree
      end      
      assert_equal(tree_arr.length, 13)
    end
     
  end #class TestPhyloXML



  class TestPhyloXML2 < Test::Unit::TestCase
  
    #setup is called before and every time any function es executed.  
    def setup
      @phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      @tree = @phyloxml.next_tree
    end
    
    def test_tree_name
      assert_equal(@tree.name, "example from Prof. Joe Felsenstein's book \"Inferring Phylogenies\"")
    end
    
    def test_tree_description
      assert_equal(@tree.description, "phyloXML allows to use either a \"branch_length\" attribute or element to indicate branch lengths.")
    end
    
    def test_branch_length_attribute
      assert_equal(@tree.total_distance, 0.792)
    end

    def test_rooted_atr
       assert_equal(@tree.rooted, true)
    end
    
   
    def test_branch_length_tag
      @tree = @phyloxml.next_tree
      assert_equal(@tree.total_distance, 0.792)
    end
    
    def test_bootstrap
      #iterate throuch first 2 trees to get to the third
      @tree = @phyloxml.next_tree
      @tree = @phyloxml.next_tree
      node = @tree.get_node_by_name("AB")
      assert_equal(node.confidences[0].type, 'bootstrap')
      assert_equal(node.confidences[0].value, 89)
    end

    def test_to_biotreenode_bootstrap
      #iterate throuch first 2 trees to get to the third
      @tree = @phyloxml.next_tree
      @tree = @phyloxml.next_tree
      node = @tree.get_node_by_name("AB")
      bionode = node.to_biotreenode
      assert_equal(bionode.bootstrap, 89)
    end

    def test_duplications
      4.times do
        @tree = @phyloxml.next_tree
      end
      node = @tree.root
      assert_equal(node.events.speciations, 1)
    end

    def test_taxonomy_scientific_name
      3.times do
        @tree = @phyloxml.next_tree
      end
      t = @tree.get_node_by_name('A').taxonomies[0]
      assert_equal(t.scientific_name, 'E. coli')
      assert_equal(t.authority, "J. G. Cooper, 1863")
      t = @tree.get_node_by_name('C').taxonomies[0]
      assert_equal(t.scientific_name, 'C. elegans')
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
      assert_equal(codes.sort, ["CLOAB",  "DICDI", "OCTVU"])
     #@todo assert ids, id_types. or create new class for id.
    end

    def test_taxonomy2
      9.times do
        @tree = @phyloxml.next_tree
      end
      taxonomy = @tree.root.taxonomies[0]
      assert_equal(taxonomy.taxonomy_id.value, "8556")
      assert_equal(taxonomy.taxonomy_id.provider, "NCBI")
      assert_equal(taxonomy.scientific_name, "Varanus")
      assert_equal(taxonomy.rank, "genus")
      assert_equal(taxonomy.uri.desc, "EMBL REPTILE DATABASE")
      assert_equal(taxonomy.uri.uri, "http://www.embl-heidelberg.de/~uetz/families/Varanidae.html")
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
      assert_equal(descrs.sort, ['Africa', 'Asia', 'Australia'])
    end

    def test_distribution_point
      10.times do
        @tree = @phyloxml.next_tree
      end
      point = @tree.get_node_by_name('A').distributions[0].points[0]
      assert_equal(point.geodetic_datum, "WGS84")
      assert_equal(point.lat, 47.481277)
      assert_equal(point.long, 8.769303)
      assert_equal(point.alt,472)

      point = @tree.get_node_by_name('B').distributions[0].points[0]
      assert_equal(point.geodetic_datum, "WGS84")
      assert_equal(point.lat, 35.155904)
      assert_equal(point.long, 136.915863)
      assert_equal(point.alt,10)
    end

    def test_sequence
      3.times do
        @tree = @phyloxml.next_tree
      end
      sequence_a = @tree.get_node_by_name('A').sequences[0]
      assert_equal(sequence_a.annotations[0].desc, 'alcohol dehydrogenase')
      assert_equal(sequence_a.annotations[0].confidence.type, "probability" )
      assert_equal(sequence_a.annotations[0].confidence.value, 0.99 )
      sequence_b = @tree.get_node_by_name('B').sequences[0]
      assert_equal(sequence_b.annotations[0].desc, 'alcohol dehydrogenase')
      assert_equal(sequence_b.annotations[0].confidence.type, "probability" )
      assert_equal(sequence_b.annotations[0].confidence.value, 0.91 )
      sequence_c = @tree.get_node_by_name('C').sequences[0]
      assert_equal(sequence_c.annotations[0].desc, 'alcohol dehydrogenase')
      assert_equal(sequence_c.annotations[0].confidence.type, "probability" )
      assert_equal(sequence_c.annotations[0].confidence.value, 0.67 )

    end

     def test_sequence2
       4.times do
         @tree = @phyloxml.next_tree
       end
       leaves = @tree.leaves
       leaves.each { |node|
         #just test one node for now
         if node.sequences[0].id_source == 'x'
           assert_equal(node.sequences[0].symbol, 'adhB')
           assert_equal(node.sequences[0].accession.source, "ncbi")
           assert_equal(node.sequences[0].accession.value, 'AAB80874')
           assert_equal(node.sequences[0].name, 'alcohol dehydrogenase')
         end
         if node.sequences[0].id_source == 'z'
           assert_equal(node.sequences[0].annotations[0].ref, "InterPro:IPR002085")
         end
       }
     end

     def test_sequence3
       5.times do
         @tree = @phyloxml.next_tree
       end
       @tree.leaves.each { |node|
         if node.sequences[0].symbol == 'ADHX'
          assert_equal(node.sequences[0].accession.source, 'UniProtKB')
          assert_equal(node.sequences[0].accession.value, 'P81431')
          assert_equal(node.sequences[0].name, 'Alcohol dehydrogenase class-3')
          assert_equal(node.sequences[0].is_aligned, true)
          assert_equal(node.sequences[0].is_aligned?, true)
          assert_equal(node.sequences[0].mol_seq, 'TDATGKPIKCMAAIAWEAKKPLSIEEVEVAPPKSGEVRIKILHSGVCHTD')
          assert_equal(node.sequences[0].annotations[0].ref, 'EC:1.1.1.1')
          assert_equal(node.sequences[0].annotations[1].ref, 'GO:0004022')
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
           assert_equal(seq.definition, 'Alcohol dehydrogenase class-3')
           assert_equal(seq.id_namespace, 'UniProtKB' )
           assert_equal(seq.entry_id, 'P81431')
           assert_equal(seq.seq.to_s, 'TDATGKPIKCMAAIAWEAKKPLSIEEVEVAPPKSGEVRIKILHSGVCHTD')
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
           assert_equal(seq.definition,'Alcohol dehydrogenase class-3' )
           assert_equal(seq.seq.to_s,'TDATGKPIKCMAAIAWEAKKPLSIEEVEVAPPKSGEVRIKILHSGVCHTD' )
           assert_equal(seq.classification[0],'Octopus vulgaris')
         end
       }
     end

     def test_date
       11.times do
         @tree = @phyloxml.next_tree
       end
       date_a = @tree.get_node_by_name('A').date
       assert_equal(date_a.unit, 'mya')
       assert_equal(date_a.desc, "Silurian")
       assert_equal(date_a.value, 425)
       date_b = @tree.get_node_by_name('B').date
       assert_equal(date_b.unit, 'mya')
       assert_equal(date_b.desc, "Devonian")
       assert_equal(date_b.value, 320)
       date_c = @tree.get_node_by_name('C').date
       assert_equal(date_c.unit, 'mya')
       assert_equal(date_c.desc, 'Ediacaran')
       assert_equal(date_c.value, 600)
       assert_equal(date_c.minimum, 570)
       assert_equal(date_c.maximum, 630)
     end

     def test_property
       7.times do
         @tree = @phyloxml.next_tree
       end
       property = @tree.get_node_by_name('A').properties[0]
       assert_equal(property.datatype, 'xsd:integer')
       assert_equal(property.ref,'NOAA:depth')
       assert_equal(property.applies_to, 'clade')
       assert_equal(property.unit, 'METRIC:m')
       assert_equal(property.value, ' 1200 ')
     end

     def test_uri
       9.times do
         @tree = @phyloxml.next_tree
       end
       uri = @tree.root.taxonomies[0].uri
       assert_equal(uri.desc, "EMBL REPTILE DATABASE")
       assert_equal(uri.uri, "http://www.embl-heidelberg.de/~uetz/families/Varanidae.html")
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
      assert_equal(node_names, ["A", "B"])
    end

  
  end # class

  class TestPhyloXML4 < Test::Unit::TestCase

    #test cases what pertain to tree

    def test_clade_relation

      @phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      7.times do
        @tree = @phyloxml.next_tree
      end
       cr = @tree.clade_relations[0]
       assert_equal(cr.id_ref_0, "b")
       assert_equal(cr.id_ref_1, "c")
       assert_equal(cr.type, "network_connection")
    end

    def test_sequence_realations
      @phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      5.times do
        @tree = @phyloxml.next_tree
      end

      sr = @tree.sequence_relations[0]
       
       assert_equal(sr.id_ref_0, "x")
       assert_equal(sr.id_ref_1, "y")
       assert_equal(sr.type, "paralogy")
    end


  end

  class TestPhyloXML5 < Test::Unit::TestCase

    #testing file made_up.xml
    def setup
      @phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.made_up_xml)
    end

    def test_phylogeny_confidence
      tree = @phyloxml.next_tree()
      assert_equal(tree.confidences[0].type, "bootstrap")
      assert_equal(tree.confidences[0].value, 89)
      assert_equal(tree.confidences[1].type, "probability")
      assert_equal(tree.confidences[1].value, 0.71)
    end

    def test_to_biotreenode_probability
      tree = @phyloxml.next_tree()
      node = tree.get_node_by_name('c').to_biotreenode
      assert_equal(node.bootstrap, nil)
    end

    def test_polygon
      2.times do
        @tree = @phyloxml.next_tree
      end
      polygon = @tree.get_node_by_name('A').distributions[0].polygons[0]
      assert_equal(polygon.points.length,3 )
      assert_equal(polygon.points[0].lat, 47.481277)
      assert_equal(polygon.points[0].alt_unit, "m")
      assert_equal(polygon.points[1].long, 136.915863)
      assert_equal(polygon.points[2].alt, 452)
      polygon = @tree.get_node_by_name('A').distributions[0].polygons[1]
      #making sure can read in second polygon
      assert_equal(polygon.points.length,3 )
      assert_equal(polygon.points[0].lat, 40.481277)
    end

    def test_reference
      3.times do
        @tree = @phyloxml.next_tree
      end
      references = @tree.get_node_by_name('A').references
      assert_equal(references[0].doi, "10.1093/bioinformatics/btm619")
      assert_equal(references[0].desc, "Phyutility: a phyloinformatics tool for trees, alignments and molecular data")
      assert_equal(references[1].doi, "10.1186/1471-2105-9-S1-S23")
    end


    def test_single_clade
      4.times do
        @tree = @phyloxml.next_tree()
      end
      assert_equal(@tree.root.name, "A")
    end

    def test_domain_architecture
      5.times {@tree = @phyloxml.next_tree()}
      node = @tree.get_node_by_name("22_MOUSE")
      assert_equal(node.name, "22_MOUSE")
      assert_equal(node.taxonomies[0].code, "MOUSE")
      domain_arch = node.sequences[0].domain_architecture
      assert_equal(domain_arch.length,1249 )
      assert_equal(domain_arch.domains[0].from, 6)
      assert_equal(domain_arch.domains[0].to, 90)
      assert_in_delta(domain_arch.domains[0].confidence, 7.0E-26, 1E-26)
      assert_equal(domain_arch.domains[0].value, "CARD")
      assert_equal(domain_arch.domains[0].id, "x")
      assert_equal(domain_arch.domains[5].from, 733)
      assert_equal(domain_arch.domains[5].to, 771)
      assert_in_delta(domain_arch.domains[5].confidence, 4.7E-14, 1E-15)
      assert_equal(domain_arch.domains[5].value, "WD40")
      assert_equal(domain_arch.domains.last.from, 1168)
      assert_equal(domain_arch.domains.last.to, 1204)
      assert_equal(domain_arch.domains.last.confidence, 0.3)
      assert_equal(domain_arch.domains.last.value, "WD40")
    end

    def test_clade_width
      @tree = @phyloxml.next_tree
      assert_equal(@tree.root.width, 0.2)
    end

    def test_binary_characters
      6.times do
        @tree = @phyloxml.next_tree
      end
      bc =@tree.get_node_by_name("cellular_organisms").binary_characters
      assert_equal(bc.bc_type, "parsimony inferred")
      assert_equal(bc.lost_count, 0)
      assert_equal(bc.gained_count,0)
      assert_equal(bc.lost, [])

      bc2 = @tree.get_node_by_name("Eukaryota").binary_characters
      assert_equal(bc2.gained_count, 2)
      assert_equal(bc2.gained, ["Cofilin_ADF", "Gelsolin"])
      assert_equal(bc2.present, ["Cofilin_ADF", "Gelsolin"])
    end

    def test_rerootable2
      6.times do
        @tree = @phyloxml.next_tree
      end
      assert_equal(@tree.rerootable, false)
    end

    def test_phylogeny_attributes
      @tree = @phyloxml.next_tree
      assert_equal(@tree.rooted, true)
      assert_equal(@tree.rerootable, false)
      #@todo make this test pass
      #assert_equal(@tree.branch_length_unit, "1")

    end

    def test_taxonomy_synonym
      5.times do
        @tree = @phyloxml.next_tree
      end
      node = @tree.get_node_by_name('22_MOUSE')
      t = node.taxonomies[0]
      assert_equal(t.synonyms[0], "murine")
      assert_equal(t.synonyms[1], "vermin")

    end

    def test_annotation_property
      5.times do
        @tree =@phyloxml.next_tree
      end
      node = @tree.get_node_by_name('22_MOUSE')
      prop = node.sequences[0].annotations[0].properties[0]
      assert_equal(prop.value, "1200")
    end

  end
  class TestPhyloXML5 < Test::Unit::TestCase

    def test_each
      phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      count = 0
      phyloxml.each do |tree|
        count +=1
      end
      assert_equal(count, 13)
    end

    def test_other
      phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      assert_equal(phyloxml.other[0], nil)
      phyloxml.each do |tree|
        #iterate through all trees, to get to the end
      end
      o = phyloxml.other[0]
      assert_equal(o.element_name, 'align:alignment')
      assert_equal(o.children[0].element_name, 'seq')
      assert_equal(o.children[1].value, 'aggtcgcggcctgtggaagtcctctcct')
      assert_equal(o.children[2].attributes["name"], "C")

    end

    def test_array_behaviour
      phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.example_xml)
      tree = phyloxml[2]
      assert_equal(tree.name, "same example, with support of type \"bootstrap\"")
    end


#    def test_get_tree_by_name
#       @phyloxml = Bio::PhyloXML::Parser.new(TestPhyloXMLData.made_up_xml)
#       tree = @phyloxml.get_tree_by_name "testing confidence"
#
#    end

  end


end #end module Biof

rescue LoadError
    raise "Error: libxml-ruby library is not present. Please install libxml-ruby library. It is needed for Bio::PhyloXML module. Unit test for PhyloXML will not be performed."
end #end begin and rescue block