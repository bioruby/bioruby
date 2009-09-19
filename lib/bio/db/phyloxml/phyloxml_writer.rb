#
# = bio/db/phyloxml_writer.rb - PhyloXML writer
#
# Copyright::   Copyright (C) 2009
#               Diana Jaunzeikare <latvianlinuxgirl@gmail.com>
# License::     The Ruby License
#
# $Id:$
#
# == Description
#
# This file containts writer for PhyloXML.
#
# == Requirements
#
# Libxml2 XML parser is required. Install libxml-ruby bindings from
# http://libxml.rubyforge.org or
#
#   gem install -r libxml-ruby
#
# == References
#
# * http://www.phyloxml.org
#
# * https://www.nescent.org/wg_phyloinformatics/PhyloSoC:PhyloXML_support_in_BioRuby

module Bio

  module PhyloXML

  # == Description
  #
  # Bio::PhyloXML::Writer is for writing phyloXML (version 1.10) format files.
  #
  # == Requirements
  #
  # Libxml2 XML parser is required. Install libxml-ruby bindings from
  # http://libxml.rubyforge.org or
  #
  #   gem install -r libxml-ruby
  #
  # == Usage
  #
  #   require 'bio'
  #
  #  # Create new phyloxml parser
  #  phyloxml = Bio::PhyloXML::Parser.new('example.xml')
  #
  #  # Read in some trees from file
  #  tree1 = phyloxml.next_tree
  #  tree2 = phyloxml.next_tree
  #
  #  # Create new phyloxml writer
  #  writer = Bio::PhyloXML::Writer.new('tree.xml')
  #
  #  # Write tree to the file tree.xml
  #  writer.write(tree1)
  #
  #  # Add another tree to the file
  #  writer.write(tree2)
  #
  # == References
  #
  # http://www.phyloxml.org/documentation/version_100/phyloxml.xsd.html

    class Writer

      include LibXML

      SCHEMA_LOCATION = 'http://www.phyloxml.org http://www.phyloxml.org/1.10/phyloxml.xsd'
            
      attr_accessor :write_branch_length_as_subelement

      #
      # Create new Writer object. As parameters provide filename of xml file
      # you wish to create. Optional parameter is whether to indent or no.
      # Default is true. By default branch_length is written as subelement of
      # clade element.
      #
      def initialize(filename, indent=true)
      @write_branch_length_as_subelement = true #default value
      @filename = filename
      @indent = indent

      @doc = XML::Document.new()
      @doc.root = XML::Node.new('phyloxml')
      @root = @doc.root
      @root['xmlns:xsi'] = 'http://www.w3.org/2001/XMLSchema-instance'
      @root['xsi:schemaLocation'] = SCHEMA_LOCATION
      @root['xmlns'] = 'http://www.phyloxml.org'

      #@todo save encoding to be UTF-8. (However it is the default one).
      #it gives error NameError: uninitialized constant LibXML::XML::Encoding
      #@doc.encoding = XML::Encoding::UTF_8

      @doc.save(@filename, :indent => true)
      end

      #
      # Write a tree to a file in phyloxml format.
      #
      #  require 'Bio'
      #  writer = Bio::PhyloXML::Writer.new
      #  writer.write(tree)
      #
      def write(tree)
        @root << phylogeny = XML::Node.new('phylogeny')        
        
        PhyloXML::Writer.generate_xml(phylogeny, tree, [
            [:attr, 'rooted'],
            [:simple, 'name', tree.name],
            [:complex, 'id', tree.phylogeny_id],
            [:simple, 'description', tree.description],
            [:simple, 'date', tree.date],
            [:objarr, 'confidence', 'confidences']])

        root_clade = tree.root.to_xml(nil, @write_branch_length_as_subelement)
        
        phylogeny << root_clade 

        tree.children(tree.root).each do |node|
          root_clade << node_to_xml(tree, node, tree.root)
        end

        Bio::PhyloXML::Writer::generate_xml(phylogeny, tree, [
            [:objarr, 'clade_relation', 'clade_relations'],
            [:objarr, 'sequence_relation', 'sequence_relations'],
            [:objarr, 'property', 'properties']] )

        @doc.save(@filename, :indent => @indent)
      end #writer#write


      #
      # PhyloXML Schema allows to save data in different xml format after all
      # phylogeny elements. This method is to write these additional data.
      #
      #  parser = PhyloXML::Parser.new('phyloxml_examples.xml')
      #  writer = PhyloXML::Writer.new('new.xml')
      #
      #  parser.each do |tree|
      #    writer.write(tree)
      #  end
      #
      #  # When all the trees are read in by the parser, whats left is saved at
      #  # PhyloXML::Parser#other
      #  writer.write(parser.other)
      #

      def write_other(other_arr)
        other_arr.each do |other_obj|
          @root << other_obj.to_xml
        end
        @doc.save(@filename, :indent => @indent)
      end

      #class method

      #
      # Used by to_xml methods of PhyloXML element classes. Generally not to be
      # invoked directly. 
      #
      def self.generate_xml(root, elem, subelement_array)
       #example usage: generate_xml(node, self, [[ :complex,'accession', ], [:simple, 'name',  @name], [:simple, 'location', @location]])
      subelement_array.each do |subelem|
        if subelem[0] == :simple         
          root << XML::Node.new(subelem[1], subelem[2].to_s) if subelem[2] != nil and not subelem[2].to_s.empty?

        elsif subelem[0] == :complex
          root << subelem[2].send("to_xml") if subelem[2] != nil

        elsif subelem[0] == :pattern
          #seq, self, [[:pattern, 'symbol', @symbol, "\S{1,10}"]
          if subelem[2] != nil
            if subelem[2] =~ subelem[3]
              root << XML::Node.new(subelem[1], subelem[2])
            else
              raise "#{subelem[2]} is not a valid value of #{subelem[1]}. It should follow pattern #{subelem[3]}"
            end
          end

        elsif subelem[0] == :objarr
          #[:objarr, 'annotation', 'annotations']])
          obj_arr = elem.send(subelem[2])
          obj_arr.each do |arr_elem|
            root << arr_elem.to_xml
          end

        elsif subelem[0] == :simplearr
          #  [:simplearr, 'common_name', @common_names]
          subelem[2].each do |elem_val|
            root << XML::Node.new(subelem[1], elem_val)
          end
        elsif subelem[0] == :attr
          #[:attr, 'rooted']
          obj = elem.send(subelem[1])
          if obj != nil
            root[subelem[1]] = obj.to_s
          end
        else
          raise "Not supported type of element by method generate_xml."
        end
      end
      return root
     end

      private

      def node_to_xml(tree, node, parent)
        edge = tree.get_edge(parent, node)
        branch_length = edge.distance

        clade = node.to_xml(branch_length, @write_branch_length_as_subelement)

        tree.children(node).each do |new_node|
          clade << node_to_xml(tree, new_node, node)
        end

        return clade
      end

    end

  end
end