#
# = bio/db/phyloxml_parser.rb - PhyloXML parser
#
# Copyright::   Copyright (C) 2009
#               Diana Jaunzeikare <latvianlinuxgirl@gmail.com>
# License::     The Ruby License
#
# $Id:$
#
# == Description
#
# This file containts parser for PhyloXML.
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


require 'uri'
require 'libxml'

require 'bio/tree'
require 'bio/db/phyloxml/phyloxml_elements'


module Bio

module PhyloXML




  # == Description
  #
  # Bio::PhyloXML::Parser is for parsing phyloXML format files.
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
  #  phyloxml = Bio::PhyloXML::Parser.open('example.xml')
  #
  #  # Print the names of all trees in the file
  #  phyloxml.each do |tree|
  #    puts tree.name
  #  end
  #
  #
  # == References
  #
  # http://www.phyloxml.org/documentation/version_100/phyloxml.xsd.html
  #
  class Parser

    include LibXML

    # After parsing all the trees, if there is anything else in other xml format,
    # it is saved in this array of PhyloXML::Other objects
    attr_reader :other

    # Initializes LibXML::Reader and reads the file until it reaches the first
    # phylogeny element.
    #
    # Create a new Bio::PhyloXML::Parser object.
    #
    #   p = Bio::PhyloXML::Parser.open("./phyloxml_examples.xml")
    #
    # ---
    # *Arguments*:
    # * (required) _filename_: Path to the file to parse.
    # * (optional) _validate_: Whether to validate the file against schema or not. Default value is true.
    # *Returns*:: Bio::PhyloXML::Parser object
    def self.open(filename, validate=true)
      obj = new(nil, validate)
      obj.instance_eval {
        filename = _secure_filename(filename)
        _validate(:file, filename) if validate
        # XML::Parser::Options::NONET for security reason
        @reader = XML::Reader.file(filename,
                                   { :options =>
                                     LibXML::XML::Parser::Options::NONET })
        _skip_leader
      }
      obj
    end

    # Initializes LibXML::Reader and reads the file until it reaches the first
    # phylogeny element.
    #
    # Create a new Bio::PhyloXML::Parser object.
    #
    #   p = Bio::PhyloXML::Parser.open_uri("http://www.phyloxml.org/examples/apaf.xml")
    #
    # ---
    # *Arguments*:
    # * (required) _uri_: (URI or String) URI to the data to parse
    # * (optional) _validate_: For URI reader, the "validate" option is ignored and no validation is executed.
    # *Returns*:: Bio::PhyloXML::Parser object
    def self.open_uri(uri, validate=true)
      case uri
      when URI
        uri = uri.to_s
      else
        # raises error if not a String
        uri = uri.to_str
        # raises error if invalid URI
        URI.parse(uri)
      end

      obj = new(nil, validate)
      obj.instance_eval {
        @reader = XML::Reader.file(uri)
        _skip_leader
      }
      obj
    end

    # Special class for closed PhyloXML::Parser object.
    # It raises error for any methods except essential methods.
    #
    # Bio::PhyloXML internal use only.
    class ClosedPhyloXMLParser #:nodoc:
      def method_missing(*arg)
        raise LibXML::XML::Error, 'closed PhyloXML::Parser object'
      end
    end #class ClosedPhyloXMLParser

    # Closes the LibXML::Reader inside the object.
    # It also closes the opened file if it is created by using
    # Bio::PhyloXML::Parser.open method.
    #
    # When closed object is closed again, or closed object is used,
    # it raises LibXML::XML::Error.
    # ---
    # *Returns*:: nil
    def close
      @reader.close
      @reader = ClosedPhyloXMLParser.new
      nil
    end

    # Initializes LibXML::Reader and reads from the IO until it reaches
    # the first phylogeny element.
    #
    # Create a new Bio::PhyloXML::Parser object.
    #
    #   p = Bio::PhyloXML::Parser.for_io($stdin)
    #
    # ---
    # *Arguments*:
    # * (required) _io_: IO object
    # * (optional) _validate_: For IO reader, the "validate" option is ignored and no validation is executed.
    # *Returns*:: Bio::PhyloXML::Parser object
    def self.for_io(io, validate=true)
      obj = new(nil, validate)
      obj.instance_eval {
        @reader = XML::Reader.io(io,
                                 { :options =>
                                   LibXML::XML::Parser::Options::NONET })
        _skip_leader
      }
      obj
    end

    # (private) returns PhyloXML schema
    def _schema
      XML::Schema.document(XML::Document.file(File.join(File.dirname(__FILE__),'phyloxml.xsd')))
    end
    private :_schema

    # (private) do validation
    # ---
    # *Arguments*:
    # * (required) <em>data_type</em>_: :file for filename, :string for string
    # * (required) _arg_: filename or string
    # *Returns*:: (undefined)
    def _validate(data_type, arg)
      options = { :options =>
        (LibXML::XML::Parser::Options::NOERROR |   # no error messages
         LibXML::XML::Parser::Options::NOWARNING | # no warning messages
         LibXML::XML::Parser::Options::NONET)      # no network access
      }
      case data_type
      when :file
        # No validation when special file e.g. FIFO (named pipe)
        return unless File.file?(arg)
        xml_instance = XML::Document.file(arg, options)
      when :string
        xml_instance = XML::Document.string(arg, options)
      else
        # no validation for unknown data type
        return
      end

      schema = _schema
      begin
        flag = xml_instance.validate_schema(schema) do |msg, flag|
          # The document of libxml-ruby says that the block is called
          # when validation failed, but it seems it is never called
          # even when validation failed!
          raise "Validation of the XML document against phyloxml.xsd schema failed. #{msg}"
        end
      rescue LibXML::XML::Error => evar
        raise "Validation of the XML document against phyloxml.xsd schema failed, or XML error occurred. #{evar.message}"
      end
      unless flag then
        raise "Validation of the XML document against phyloxml.xsd schema failed."
      end
    end
    private :_validate

    # (private) It seems that LibXML::XML::Reader reads from the network
    # even if LibXML::XML::Parser::Options::NONET is set.
    # So, for URI-like filename, '://' is replaced with ':/'.
    def _secure_filename(filename)
      # for safety, URI-like filename is checked.
      if /\A[a-zA-Z]+\:\/\// =~ filename then
        # for example, "http://a/b" is changed to "http:/a/b".
        filename = filename.sub(/\:\/\//, ':/')
      end
      filename
    end
    private :_secure_filename

    # (private) loops through until reaches phylogeny stuff
    def _skip_leader
      #loops through until reaches phylogeny stuff
      # Have to leave this way, if accepting strings, instead of files
      @reader.read until is_element?('phylogeny')
      nil
    end
    private :_skip_leader

    # Initializes LibXML::Reader and reads the PhyloXML-formatted string
    # until it reaches the first phylogeny element.
    #
    # Create a new Bio::PhyloXML::Parser object.
    #
    #   str = File.read("./phyloxml_examples.xml")
    #   p = Bio::PhyloXML::Parser.new(str)
    #
    #
    # Deprecated usage: Reads data from a file. <em>str<em> is a filename.
    #
    #   p = Bio::PhyloXML::Parser.new("./phyloxml_examples.xml")
    #
    # Taking filename is deprecated. Use Bio::PhyloXML::Parser.open(filename).
    # 
    # ---
    # *Arguments*:
    # * (required) _str_: PhyloXML-formatted string
    # * (optional) _validate_: Whether to validate the file against schema or not. Default value is true.
    # *Returns*:: Bio::PhyloXML::Parser object
    def initialize(str, validate=true)

      @other = []

      return unless str

      # For compatibility, if filename-like string is given,
      # treat it as a filename.
      if /[\<\>\r\n]/ !~ str and File.exist?(str) then
        # assume that str is filename
        warn "Bio::PhyloXML::Parser.new(filename) is deprecated. Use Bio::PhyloXML::Parser.open(filename)."
        filename = _secure_filename(str)
        _validate(:file, filename) if validate
        @reader = XML::Reader.file(filename)
        _skip_leader
        return
      end

      # initialize for string
      @reader = XML::Reader.string(str,
                                   { :options =>
                                     LibXML::XML::Parser::Options::NONET })
      _skip_leader
    end


    # Iterate through all trees in the file.
    #
    #  phyloxml = Bio::PhyloXML::Parser.open('example.xml')
    #  phyloxml.each do |tree|
    #    puts tree.name
    #  end
    #
    def each
      while tree = next_tree
        yield tree
      end
    end

    # Access the specified tree in the file. It parses trees until the specified
    # tree is reached.
    #
    #  # Get 3rd tree in the file (starts counting from 0).
    #  parser = PhyloXML::Parser.open('phyloxml_examples.xml')
    #  tree = parser[2]
    #
    def [](i)
      tree = nil
      (i+1).times do
       tree =  self.next_tree
      end
      return tree
    end

    # Parse and return the next phylogeny tree. If there are no more phylogeny
    # element, nil is returned. If there is something else besides phylogeny
    # elements, it is saved in the PhyloXML::Parser#other.
    # 
    #  p = Bio::PhyloXML::Parser.open("./phyloxml_examples.xml")
    #  tree = p.next_tree
    #
    # ---
    # *Returns*:: Bio::PhyloXML::Tree
    def next_tree()

      if not is_element?('phylogeny')
        if @reader.node_type == XML::Reader::TYPE_END_ELEMENT
          if is_end_element?('phyloxml')
            return nil
          else
            @reader.read
            @reader.read
            if is_end_element?('phyloxml')
              return nil
            end
          end
        end        
        # phyloxml can hold only phylogeny and "other" elements. If this is not
        # phylogeny element then it is other. Also, "other" always comes after
        # all phylogenies        
        @other << parse_other        
        #return nil for tree, since this is not valid phyloxml tree.
        return nil
      end

      tree = Bio::PhyloXML::Tree.new

      # keep track of current node in clades array/stack. Current node is the
      # last element in the clades array
      clades = []
      clades.push tree
      
      #keep track of current edge to be able to parse branch_length tag
      current_edge = nil

      # we are going to parse clade iteratively by pointing (and changing) to
      # the current node in the tree. Since the property element is both in
      # clade and in the phylogeny, we need some boolean to know if we are
      # parsing the clade (there can be only max 1 clade in phylogeny) or
      # parsing phylogeny
      parsing_clade = false

      while not is_end_element?('phylogeny') do
        break if is_end_element?('phyloxml')
        
        # parse phylogeny elements, except clade
        if not parsing_clade

          if is_element?('phylogeny')
            @reader["rooted"] == "true" ? tree.rooted = true : tree.rooted = false
            @reader["rerootable"] == "true" ? tree.rerootable = true : tree.rerootable = false
            parse_attributes(tree, ["branch_length_unit", 'type'])
          end

          parse_simple_elements(tree, [ "name", 'description', "date"])

          if is_element?('confidence')
            tree.confidences << parse_confidence
          end

        end

        if @reader.node_type == XML::Reader::TYPE_ELEMENT
          case @reader.name
          when 'clade'
            #parse clade element

            parsing_clade = true

            node= Bio::PhyloXML::Node.new

            branch_length = @reader['branch_length']

            parse_attributes(node, ["id_source"])

            #add new node to the tree
            tree.add_node(node)
            # The first clade will always be root since by xsd schema phyloxml can
            # have 0 to 1 clades in it.
            if tree.root == nil
              tree.root = node
            else
              current_edge = tree.add_edge(clades[-1], node,
                                           Bio::Tree::Edge.new(branch_length))
            end
            clades.push node
            #end if clade element
          else
           parse_clade_elements(clades[-1], current_edge) if parsing_clade
          end
        end

        #end clade element, go one parent up
        if is_end_element?('clade')

           #if we have reached the closing tag of the top-most clade, then our
          # curent node should point to the root, If thats the case, we are done
          # parsing the clade element
          if clades[-1] == tree.root
            parsing_clade = false
          else
            # set current node (clades[-1) to the previous clade in the array
            clades.pop
          end
        end          

        #parsing phylogeny elements
        if not parsing_clade

          if @reader.node_type == XML::Reader::TYPE_ELEMENT
            case @reader.name
            when 'property'
              tree.properties << parse_property

            when 'clade_relation'
              clade_relation = CladeRelation.new
              parse_attributes(clade_relation, ["id_ref_0", "id_ref_1", "distance", "type"])

              #@ add unit test for this
              if not @reader.empty_element?
                @reader.read
                if is_element?('confidence')
                  clade_relation.confidence = parse_confidence
                end
              end
              tree.clade_relations << clade_relation

            when 'sequence_relation'
              sequence_relation = SequenceRelation.new
              parse_attributes(sequence_relation, ["id_ref_0", "id_ref_1", "distance", "type"])
              if not @reader.empty_element?
                @reader.read
                if is_element?('confidence')
                  sequence_relation.confidence = parse_confidence
                end
              end
              tree.sequence_relations << sequence_relation
            when 'phylogeny'
              #do nothing
            else
              tree.other << parse_other
              #puts "Not recognized element. #{@reader.name}"
            end
          end
        end
        # go to next element        
        @reader.read    
      end #end while not </phylogeny>
      #move on to the next tag after /phylogeny which is text, since phylogeny
      #end tag is empty element, which value is nil, therefore need to move to
      #the next meaningful element (therefore @reader.read twice)
      @reader.read 
      @reader.read

      return tree
    end  

    # return tree of specified name.
    # @todo Implement this method. 
    # def get_tree_by_name(name)

#      while not is_end_element?('phyloxml')
#        if is_element?('phylogeny')
#          @reader.read
#          @reader.read
#
#          if is_element?('name')
#            @reader.read
#            if @reader.value == name
#              puts "equasl"
#              tree = next_tree
#              puts tree
#            end
#          end
#        end
#        @reader.read
#      end
#
  #  end


    private

    ####
    # Utility methods
    ###

    def is_element?(str)
      @reader.node_type == XML::Reader::TYPE_ELEMENT and @reader.name == str ? true : false
    end

    def is_end_element?(str)
      @reader.node_type==XML::Reader::TYPE_END_ELEMENT and @reader.name == str ? true : false
    end

    def has_reached_end_element?(str)
      if not(is_end_element?(str))        
        raise "Warning: Should have reached </#{str}> element here"
      end
    end

    # Parses a simple XML element. for example <speciations>1</speciations>
    # It reads in the value and assigns it to object.speciation = 1
    # Also checks if have reached end tag (</speciations> and gives warning
    # if not
    def parse_simple_element(object, name)
      if is_element?(name)
        @reader.read
        object.send("#{name}=", @reader.value)
        @reader.read
        has_reached_end_element?(name)
      end
    end

    def parse_simple_elements(object, elements)
      elements.each do |elmt|
          parse_simple_element(object, elmt)
      end      
    end

    #Parses list of attributes
    #use for the code like: clade_relation.type = @reader["type"]
    def parse_attributes(object, arr_of_attrs)
      arr_of_attrs.each do |attr|
        object.send("#{attr}=", @reader[attr])
      end
    end

    def parse_clade_elements(current_node, current_edge)
      #no loop inside, loop is already outside

      if @reader.node_type == XML::Reader::TYPE_ELEMENT
        case @reader.name
        when 'branch_length'
          # @todo add unit test for this. current_edge is nil, if the root clade
          # has branch_length attribute. 
          @reader.read
          branch_length = @reader.value
          current_edge.distance = branch_length.to_f if current_edge != nil
          @reader.read
        when 'width'
          @reader.read
          current_node.width = @reader.value
          @reader.read
        when  'name'
          @reader.read
          current_node.name = @reader.value
          @reader.read
        when 'events'
          current_node.events = parse_events
        when 'confidence'
          current_node.confidences << parse_confidence
        when 'sequence'
          current_node.sequences << parse_sequence
        when 'property'
          current_node.properties << parse_property
        when 'taxonomy'
          current_node.taxonomies << parse_taxonomy
        when 'distribution'
          current_node.distributions << parse_distribution
        when 'node_id'
          id = Id.new
          id.type = @reader["type"]
          @reader.read
          id.value = @reader.value
          @reader.read
          #has_reached_end_element?('node_id')
          #@todo write unit test for this. There is no example of this in the example files
          current_node.id = id
        when 'color'
          color = BranchColor.new
          parse_simple_element(color, 'red')
          parse_simple_element(color, 'green')
          parse_simple_element(color, 'blue')
          current_node.color = color
          #@todo add unit test for this
        when 'date'
          date = Date.new
          date.unit = @reader["unit"]
          #move to the next token, which is always empty, since date tag does not
          # have text associated with it
          @reader.read
          @reader.read #now the token is the first tag under date tag
          while not(is_end_element?('date'))
            parse_simple_element(date, 'desc')
            parse_simple_element(date, 'value')
            parse_simple_element(date, 'minimum')
            parse_simple_element(date, 'maximum')
            @reader.read
          end
          current_node.date = date
        when 'reference'
          reference = Reference.new()
          reference.doi = @reader['doi']
          if not @reader.empty_element?
            while not is_end_element?('reference')
              parse_simple_element(reference, 'desc')
              @reader.read
            end
          end
          current_node.references << reference
        when 'binary_characters'
          current_node.binary_characters  = parse_binary_characters
        when 'clade'
          #do nothing
        else
          current_node.other << parse_other
          #puts "No match found in parse_clade_elements.(#{@reader.name})"
        end

      end

    end #parse_clade_elements

    def parse_events()
      events = PhyloXML::Events.new
      @reader.read #go to next element
      while not(is_end_element?('events')) do
        parse_simple_elements(events, ['type', 'duplications',
                                            'speciations', 'losses'])
        if is_element?('confidence')
          events.confidence = parse_confidence
          #@todo could add unit test for this (example file does not have this case)
        end
        @reader.read
      end
      return events
    end #parse_events

    def parse_taxonomy
      taxonomy = PhyloXML::Taxonomy.new
      parse_attributes(taxonomy, ["id_source"])
      @reader.read
      while not(is_end_element?('taxonomy')) do

        if @reader.node_type == XML::Reader::TYPE_ELEMENT
          case @reader.name
          when 'code'
            @reader.read
            taxonomy.code = @reader.value
            @reader.read
          when 'scientific_name'
            @reader.read
            taxonomy.scientific_name = @reader.value
            @reader.read
          when 'rank'
            @reader.read
            taxonomy.rank = @reader.value
            @reader.read
          when 'authority'
            @reader.read
            taxonomy.authority = @reader.value
            @reader.read
          when 'id'
            taxonomy.taxonomy_id = parse_id('id')
          when 'common_name'
            @reader.read
            taxonomy.common_names << @reader.value
            @reader.read
            #has_reached_end_element?('common_name')
          when 'synonym'
            @reader.read
            taxonomy.synonyms << @reader.value
            @reader.read
            #has_reached_end_element?('synonym')
          when 'uri'
            taxonomy.uri = parse_uri
          else
            taxonomy.other << parse_other
          end
        end

        @reader.read  #move to next tag in the loop
      end
      return taxonomy
    end #parse_taxonomy

    private

    def parse_sequence
      sequence = Sequence.new
      parse_attributes(sequence, ["type", "id_source", "id_ref"])
      
      @reader.read
      while not(is_end_element?('sequence'))

        if @reader.node_type == XML::Reader::TYPE_ELEMENT
          case @reader.name
          when 'symbol'
            @reader.read
            sequence.symbol = @reader.value
            @reader.read
          when 'name'
            @reader.read
            sequence.name = @reader.value
            @reader.read
          when 'location'
            @reader.read
            sequence.location = @reader.value
            @reader.read
          when 'mol_seq'
            sequence.is_aligned = @reader["is_aligned"]
            @reader.read
            sequence.mol_seq = @reader.value
            @reader.read
            has_reached_end_element?('mol_seq')
          when 'accession'
            sequence.accession = Accession.new
            sequence.accession.source = @reader["source"]
            @reader.read
            sequence.accession.value = @reader.value
            @reader.read
            has_reached_end_element?('accession')
          when 'uri'
            sequence.uri = parse_uri
          when 'annotation'
            sequence.annotations << parse_annotation
          when 'domain_architecture'
            sequence.domain_architecture = DomainArchitecture.new
            sequence.domain_architecture.length = @reader["length"]
            @reader.read
            @reader.read
            while not(is_end_element?('domain_architecture'))
              sequence.domain_architecture.domains << parse_domain
              @reader.read #go to next domain element
            end
          else
            sequence.other << parse_other
            #@todo add unit test            
          end
        end

        @reader.read
      end
      return sequence
    end #parse_sequence

    def parse_uri
      uri = Uri.new
      parse_attributes(uri, ["desc", "type"])
      parse_simple_element(uri, 'uri')
      return uri
    end

    def parse_annotation
      annotation = Annotation.new

      parse_attributes(annotation, ['ref', 'source', 'evidence', 'type'])

      if not @reader.empty_element?
        while not(is_end_element?('annotation'))
          parse_simple_element(annotation, 'desc') if is_element?('desc')

          annotation.confidence  = parse_confidence if is_element?('confidence')

          annotation.properties << parse_property if is_element?('property')

          if is_element?('uri')
            annotation.uri = parse_uri        
          end

          @reader.read
        end
        
      end
      return annotation
    end

    def parse_property
      property = Property.new
      parse_attributes(property, ["ref", "unit", "datatype", "applies_to", "id_ref"])
      @reader.read
      property.value = @reader.value
      @reader.read
      has_reached_end_element?('property')     
      return property
    end #parse_property

    def parse_confidence
      type = @reader["type"]
      @reader.read
      value = @reader.value.to_f
      @reader.read
      has_reached_end_element?('confidence')
      return Confidence.new(type, value)
    end #parse_confidence

    def parse_distribution
      distribution = Distribution.new
      @reader.read
      while not(is_end_element?('distribution')) do

        parse_simple_element(distribution, 'desc')

        distribution.points << parse_point if is_element?('point')
        distribution.polygons << parse_polygon if is_element?('polygon')

        @reader.read
      end
      return distribution
    end #parse_distribution

    def parse_point
      point = Point.new

      point.geodetic_datum = @reader["geodetic_datum"]
      point.alt_unit = @reader["alt_unit"]

      @reader.read
      while not(is_end_element?('point')) do

        parse_simple_elements(point, ['lat', 'long'] )

        if is_element?('alt')
          @reader.read
          point.alt = @reader.value.to_f
          @reader.read
          has_reached_end_element?('alt')
        end
        #advance reader
        @reader.read
      end
      return point
    end #parse_point

    def parse_polygon
      polygon = Polygon.new
      @reader.read
      while not(is_end_element?('polygon')) do
        polygon.points << parse_point if is_element?('point')
        @reader.read
      end

      #@todo should check for it at all? Probably not if xml is valid.
      if polygon.points.length <3
        puts "Warning: <polygon> should have at least 3 points"
      end
      return polygon
    end #parse_polygon

    def parse_id(tag_name)
      id = Id.new
      id.provider = @reader["provider"]
      @reader.read
      id.value = @reader.value
      @reader.read #@todo shouldn't there be another read?
      has_reached_end_element?(tag_name)
      return id
    end #parse_id

    def parse_domain
      domain = ProteinDomain.new
      parse_attributes(domain, ["from", "to", "confidence", "id"])
      @reader.read
      domain.value = @reader.value
      @reader.read
      has_reached_end_element?('domain')
      @reader.read
      return domain
    end

    def parse_binary_characters
      b = PhyloXML::BinaryCharacters.new
      b.bc_type = @reader['type']

      parse_attributes(b, ['gained_count', 'absent_count', 'lost_count', 'present_count'])
      if not @reader.empty_element?
        @reader.read
        while not is_end_element?('binary_characters')

          parse_bc(b, 'lost')
          parse_bc(b, 'gained')
          parse_bc(b, 'absent')
          parse_bc(b, 'present')

          @reader.read
        end
      end
      return b
    end #parse_binary_characters

    def parse_bc(object, element)
      if is_element?(element)
        @reader.read
        while not is_end_element?(element)
          if is_element?('bc')
            @reader.read
            object.send(element) << @reader.value
            @reader.read
            has_reached_end_element?('bc')
          end
        @reader.read
        end
      end
    end #parse_bc

    def parse_other
      other_obj = PhyloXML::Other.new
      other_obj.element_name = @reader.name
      #parse attributes
      code = @reader.move_to_first_attribute
      while code ==1
        other_obj.attributes[@reader.name] = @reader.value
        code = @reader.move_to_next_attribute        
      end

      while not is_end_element?(other_obj.element_name) do
        @reader.read
        if @reader.node_type == XML::Reader::TYPE_ELEMENT
           other_obj.children << parse_other #recursice call to parse children
        elsif @reader.node_type == XML::Reader::TYPE_TEXT
          other_obj.value = @reader.value
        end
      end
      #just a check
      has_reached_end_element?(other_obj.element_name)
      return other_obj
    end #parse_other

  end #class phyloxmlParser

end #module PhyloXML
  
end #module Bio
