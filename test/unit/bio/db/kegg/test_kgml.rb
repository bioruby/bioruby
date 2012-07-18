#
# test/unit/bio/db/kegg/test_kgml.rb - Unit test for Bio::KEGG::KGML
#
#              Copyright (C) 2012 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/kgml'

module Bio; module TestKeggKGML

  filename = File.join(BioRubyTestDataPath, 'KEGG', 'test.kgml')
  KGMLTestXMLstr = File.read(filename).freeze

  class TestKGMLPathway < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr)
    end

    def test_name
      assert_equal 'path:xxx09876', @obj.name
    end

    def test_org
      assert_equal 'xxx', @obj.org
    end

    def test_number
      assert_equal '09876', @obj.number
    end

    def test_title
      assert_equal 'This is test title', @obj.title
    end

    def test_image
      assert_equal 'http://example.com/pathway/ec/09876.png', @obj.image
    end

    def test_link
      assert_equal 'http://example.com/show_pathway?xxx09876', @obj.link
    end

    def test_entries__size
      assert_equal 3, @obj.entries.size
    end

    def test_relations__size
      assert_equal 1, @obj.relations.size
    end

    def test_reactions__size
      assert_equal 1, @obj.reactions.size
    end

    def test_entries=()
      a = [ nil, nil, nil ]
      b = [ nil, nil, nil, nil ]
      assert_equal a, (@obj.entries = a)
      assert_equal a, @obj.entries
      assert_equal b, (@obj.entries = b)
      assert_equal b, @obj.entries
    end

    def test_relations=()
      a = [ nil, nil, nil ]
      b = [ nil, nil, nil, nil ]
      assert_equal a, (@obj.relations = a)
      assert_equal a, @obj.relations
      assert_equal b, (@obj.relations = b)
      assert_equal b, @obj.relations
    end

    def test_reactions=()
      a = [ nil, nil, nil ]
      b = [ nil, nil, nil, nil ]
      assert_equal a, (@obj.reactions = a)
      assert_equal a, @obj.reactions
      assert_equal b, (@obj.reactions = b)
      assert_equal b, @obj.reactions
    end
  end #class TestKGMLPathway

  class TestKGMLEntrySetter < Test::Unit::TestCase
    def setup
      @obj = Bio::KEGG::KGML::Entry.new
    end

    def test_id=()
      assert_nil @obj.id
      assert_equal 1234, (@obj.id = 1234)
      assert_equal 1234, @obj.id
      assert_equal 4567, (@obj.id = 4567)
      assert_equal 4567, @obj.id
    end

    def test_name=()
      assert_nil @obj.name
      assert_equal 'cpd:C99999', (@obj.name = 'cpd:C99999')
      assert_equal 'cpd:C99999', @obj.name
      assert_equal 'cpd:C98765', (@obj.name = 'cpd:C98765')
      assert_equal 'cpd:C98765', @obj.name
    end

    def test_type=()
      assert_equal 'compound', (@obj.type = 'compound')
      assert_equal 'compound', @obj.type
      assert_equal 'enzyme', (@obj.type = 'enzyme')
      assert_equal 'enzyme', @obj.type
    end

    def test_link=()
      str1 = 'http://example.com/dbget-bin/www_bget?C99999'.freeze
      str2 = 'http://example.com/dbget-bin/www_bget?C98765'.freeze
      assert_equal str1, (@obj.link = str1)
      assert_equal str1, @obj.link
      assert_equal str2, (@obj.link = str2)
      assert_equal str2, @obj.link
    end

    def test_reaction=()
      assert_equal "rn:R99999", (@obj.reaction = 'rn:R99999')
      assert_equal "rn:R99999", @obj.reaction
      assert_equal "rn:R98765", (@obj.reaction = 'rn:R98765')
      assert_equal "rn:R98765", @obj.reaction
    end

    def test_graphics=()
      a = [ nil, nil ]
      b = [ nil, nil, nil ]
      assert_equal a, (@obj.graphics = a)
      assert_equal a, @obj.graphics
      assert_equal b, (@obj.graphics = b)
      assert_equal b, @obj.graphics
    end

    def test_components=()
      a = [ nil, nil ]
      b = [ nil, nil, nil ]
      assert_equal a, (@obj.components = a)
      assert_equal a, @obj.components
      assert_equal b, (@obj.components = b)
      assert_equal b, @obj.components
    end
  end #class TestKGMLEntrySetter

  # for deprecated methods/attributes
  class TestKGMLEntrySetterDeprecated < Test::Unit::TestCase
    def setup
      @obj = Bio::KEGG::KGML::Entry.new
    end

    def test_entry_id=()
      assert_nil @obj.entry_id
      assert_equal 1234, (@obj.entry_id = 1234)
      assert_equal 1234, @obj.entry_id
      assert_equal 4567, (@obj.entry_id = 4567)
      assert_equal 4567, @obj.entry_id

      assert_equal 4567, @obj.id
      @obj.id = 7890
      assert_equal 7890, @obj.entry_id
    end

    def test_category=()
      assert_nil @obj.category
      assert_equal 'compound', (@obj.category = 'compound')
      assert_equal 'compound', @obj.category
      assert_equal 'enzyme', (@obj.category = 'enzyme')
      assert_equal 'enzyme', @obj.category

      assert_equal 'enzyme', @obj.type
      @obj.type = 'gene'
      assert_equal 'gene', @obj.category
    end

    def test_pathway=()
      assert_nil @obj.pathway
      assert_equal 'deprecated', (@obj.pathway = 'deprecated')
      assert_equal 'deprecated', @obj.pathway
      assert_equal "don't use", (@obj.pathway = "don't use")
      assert_equal "don't use", @obj.pathway
    end

    def test_label=()
      assert_nil @obj.label
      assert_equal 'deprecated', (@obj.label = 'deprecated')
      assert_equal 'deprecated', @obj.label

      assert_equal "don't use", (@obj.label = "don't use")
      assert_equal "don't use", @obj.label

      assert_equal "don't use", @obj.graphics[-1].name
      @obj.graphics[-1].name = 'test'
      assert_equal 'test', @obj.label
    end

    def test_shape=()
      assert_nil @obj.shape
      assert_equal 'deprecated', (@obj.shape = 'deprecated')
      assert_equal 'deprecated', @obj.shape

      assert_equal "don't use", (@obj.shape = "don't use")
      assert_equal "don't use", @obj.shape

      assert_equal "don't use", @obj.graphics[-1].type
      @obj.graphics[-1].type = 'test'
      assert_equal 'test', @obj.shape
    end

    def test_x=()
      assert_equal 123, (@obj.x = 123)
      assert_equal 123, @obj.x

      assert_equal 456, (@obj.x = 456)
      assert_equal 456, @obj.x

      assert_equal 456, @obj.graphics[-1].x
      @obj.graphics[-1].x = 789
      assert_equal 789, @obj.x
    end

    def test_y=()
      assert_equal 123, (@obj.y = 123)
      assert_equal 123, @obj.y

      assert_equal 456, (@obj.y = 456)
      assert_equal 456, @obj.y

      assert_equal 456, @obj.graphics[-1].y
      @obj.graphics[-1].y = 789
      assert_equal 789, @obj.y
    end

    def test_width=()
      assert_equal 123, (@obj.width = 123)
      assert_equal 123, @obj.width

      assert_equal 456, (@obj.width = 456)
      assert_equal 456, @obj.width

      assert_equal 456, @obj.graphics[-1].width
      @obj.graphics[-1].width = 789
      assert_equal 789, @obj.width
    end

    def test_height=()
      assert_equal 123, (@obj.height = 123)
      assert_equal 123, @obj.height

      assert_equal 456, (@obj.height = 456)
      assert_equal 456, @obj.height

      assert_equal 456, @obj.graphics[-1].height
      @obj.graphics[-1].height = 789
      assert_equal 789, @obj.height
    end

    def test_fgcolor=()
      assert_equal "#E0E0E0", (@obj.fgcolor = "#E0E0E0")
      assert_equal "#E0E0E0", @obj.fgcolor

      assert_equal "#FFFFFF", (@obj.fgcolor = "#FFFFFF")
      assert_equal "#FFFFFF", @obj.fgcolor

      assert_equal "#FFFFFF", @obj.graphics[-1].fgcolor
      @obj.graphics[-1].fgcolor = "#99CCFF"
      assert_equal "#99CCFF", @obj.fgcolor
    end

    def test_bgcolor=()
      assert_equal "#E0E0E0", (@obj.bgcolor = "#E0E0E0")
      assert_equal "#E0E0E0", @obj.bgcolor

      assert_equal "#FFFFFF", (@obj.bgcolor = "#FFFFFF")
      assert_equal "#FFFFFF", @obj.bgcolor

      assert_equal "#FFFFFF", @obj.graphics[-1].bgcolor
      @obj.graphics[-1].bgcolor = "#99CCFF"
      assert_equal "#99CCFF", @obj.bgcolor
    end
  end #class TestKGMLEntrySetterDeprecated

  class TestKGMLEntry1234 < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr).entries[0]
    end

    def test_id
      assert_equal 1234, @obj.id
    end

    def test_name
      assert_equal 'cpd:C99999', @obj.name
    end

    def test_type
      assert_equal 'compound', @obj.type
    end

    def test_link
      assert_equal 'http://example.com/dbget-bin/www_bget?C99999', @obj.link
    end

    def test_reaction
      assert_equal nil, @obj.reaction
    end

    def test_graphics__size
      assert_equal 1, @obj.graphics.size
    end

    def test_components
      assert_equal nil, @obj.components
    end
  end #class TestKGMLEntry1234

  class TestKGMLEntry1 < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr).entries[1]
    end

    def test_id
      assert_equal 1, @obj.id
    end

    def test_name
      assert_equal 'ec:1.1.1.1', @obj.name
    end

    def test_type
      assert_equal 'enzyme', @obj.type
    end

    def test_link
      assert_equal 'http://example.com/dbget-bin/www_bget?1.1.1.1', @obj.link
    end

    def test_reaction
      assert_equal 'rn:R99999', @obj.reaction
    end

    def test_graphics__size
      assert_equal 2, @obj.graphics.size
    end

    def test_components
      assert_equal nil, @obj.components
    end
  end #class TestKGMLEntry1

  # for deprecated methods/attributes
  class TestKGMLEntry1Deprecated < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr).entries[1]
    end

    def test_entry_id
      assert_equal 1, @obj.entry_id
    end

    def test_category
      assert_equal 'enzyme', @obj.category
    end

    def test_label=()
      assert_equal '1.1.1.1', @obj.label
      assert_equal '1.2.3.4', (@obj.label = '1.2.3.4')
      assert_equal '1.2.3.4', @obj.label
      assert_equal '1.2.3.4', @obj.graphics[-1].name
      assert_equal '9.8.7.6', (@obj.graphics[-1].name = '9.8.7.6')
      assert_equal '9.8.7.6', @obj.label
      # check if it doesn't modify graphics[0]
      assert_equal '1.1.1.1', @obj.graphics[0].name
    end

    def test_shape=()
      assert_equal 'line', @obj.shape
      assert_equal 'circle', (@obj.shape = 'circle')
      assert_equal 'circle', @obj.shape
      assert_equal 'circle', @obj.graphics[-1].type
      assert_equal 'rectangle', (@obj.graphics[-1].type = 'rectangle')
      assert_equal 'rectangle', @obj.shape
      # check if it doesn't modify graphics[0]
      assert_equal 'line', @obj.graphics[0].type
    end

    def test_x=()
      assert_equal 0, @obj.x

      assert_equal 123, (@obj.x = 123)
      assert_equal 123, @obj.x

      assert_equal 456, (@obj.x = 456)
      assert_equal 456, @obj.x

      assert_equal 456, @obj.graphics[-1].x
      @obj.graphics[-1].x = 789
      assert_equal 789, @obj.x

      # check if it doesn't modify graphics[0]
      assert_equal 0, @obj.graphics[0].x
    end

    def test_y=()
      assert_equal 0, @obj.y

      assert_equal 123, (@obj.y = 123)
      assert_equal 123, @obj.y

      assert_equal 456, (@obj.y = 456)
      assert_equal 456, @obj.y

      assert_equal 456, @obj.graphics[-1].y
      @obj.graphics[-1].y = 789
      assert_equal 789, @obj.y

      # check if it doesn't modify graphics[0]
      assert_equal 0, @obj.graphics[0].y
    end

    def test_width=()
      assert_equal 0, @obj.width

      assert_equal 123, (@obj.width = 123)
      assert_equal 123, @obj.width

      assert_equal 456, (@obj.width = 456)
      assert_equal 456, @obj.width

      assert_equal 456, @obj.graphics[-1].width
      @obj.graphics[-1].width = 789
      assert_equal 789, @obj.width

      # check if it doesn't modify graphics[0]
      assert_equal 0, @obj.graphics[0].width
    end

    def test_height=()
      assert_equal 0, @obj.height

      assert_equal 123, (@obj.height = 123)
      assert_equal 123, @obj.height

      assert_equal 456, (@obj.height = 456)
      assert_equal 456, @obj.height

      assert_equal 456, @obj.graphics[-1].height
      @obj.graphics[-1].height = 789
      assert_equal 789, @obj.height

      # check if it doesn't modify graphics[0]
      assert_equal 0, @obj.graphics[0].height
    end

    def test_fgcolor=()
      assert_equal '#FF99CC', @obj.fgcolor

      assert_equal "#E0E0E0", (@obj.fgcolor = "#E0E0E0")
      assert_equal "#E0E0E0", @obj.fgcolor

      assert_equal "#E0E0E0", @obj.graphics[-1].fgcolor
      @obj.graphics[-1].fgcolor = "#C0C0C0"
      assert_equal "#C0C0C0", @obj.fgcolor

      # check if it doesn't modify graphics[0]
      assert_equal "#99CCFF", @obj.graphics[0].fgcolor
    end

    def test_bgcolor=()
      assert_equal "#CC99FF", @obj.bgcolor

      assert_equal "#E0E0E0", (@obj.bgcolor = "#E0E0E0")
      assert_equal "#E0E0E0", @obj.bgcolor

      assert_equal "#E0E0E0", @obj.graphics[-1].bgcolor
      @obj.graphics[-1].bgcolor = "#C0C0C0"
      assert_equal "#C0C0C0", @obj.bgcolor

      # check if it doesn't modify graphics[0]
      assert_equal "#FFFFFF", @obj.graphics[0].bgcolor
    end
  end #class TestKGMLEntry1Deprecated

  class TestKGMLEntry567 < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr).entries[2]
    end

    def test_id
      assert_equal 567, @obj.id
    end

    def test_name
      assert_equal 'undefined', @obj.name
    end

    def test_type
      assert_equal 'group', @obj.type
    end

    def test_link
      assert_equal nil, @obj.link
    end

    def test_reaction
      assert_equal nil, @obj.reaction
    end

    def test_graphics__size
      assert_equal 1, @obj.graphics.size
    end

    def test_components
      assert_equal [ 34, 56, 78, 90 ], @obj.components
    end
  end #class TestKGMLEntry567

  class TestKGMLGraphicsSetter < Test::Unit::TestCase
    def setup
      @obj = Bio::KEGG::KGML::Graphics.new
    end

    def test_name=()
      assert_equal '1.1.1.1', (@obj.name = '1.1.1.1')
      assert_equal '1.1.1.1', @obj.name
      assert_equal 'C99999', (@obj.name = 'C99999')
      assert_equal 'C99999', @obj.name
    end

    def test_type=()
      assert_equal 'line', (@obj.type = 'line')
      assert_equal 'line', @obj.type
      assert_equal 'circle', (@obj.type = 'circle')
      assert_equal 'circle', @obj.type
    end

    def test_x=()
      assert_equal 123, (@obj.x = 123)
      assert_equal 123, @obj.x
      assert_equal 456, (@obj.x = 456)
      assert_equal 456, @obj.x
    end

    def test_y=()
      assert_equal 123, (@obj.y = 123)
      assert_equal 123, @obj.y
      assert_equal 456, (@obj.y = 456)
      assert_equal 456, @obj.y
    end

    def test_width=()
      assert_equal 123, (@obj.width = 123)
      assert_equal 123, @obj.width
      assert_equal 456, (@obj.width = 456)
      assert_equal 456, @obj.width
    end

    def test_height=()
      assert_equal 123, (@obj.height = 123)
      assert_equal 123, @obj.height
      assert_equal 456, (@obj.height = 456)
      assert_equal 456, @obj.height
    end

    def test_fgcolor=()
      assert_equal "#E0E0E0", (@obj.fgcolor = "#E0E0E0")
      assert_equal "#E0E0E0", @obj.fgcolor
      assert_equal "#FFFFFF", (@obj.fgcolor = "#FFFFFF")
      assert_equal "#FFFFFF", @obj.fgcolor
    end

    def test_bgcolor=()
      assert_equal "#E0E0E0", (@obj.bgcolor = "#E0E0E0")
      assert_equal "#E0E0E0", @obj.bgcolor
      assert_equal "#FFFFFF", (@obj.bgcolor = "#FFFFFF")
      assert_equal "#FFFFFF", @obj.bgcolor
    end

    def test_coords=()
      a = [[1, 2], [3, 4]]
      b = [[5, 6], [7, 8], [9, 10]]
      assert_equal a, (@obj.coords = a)
      assert_equal a, @obj.coords
      assert_equal b, (@obj.coords = b)
      assert_equal b, @obj.coords
    end
  end #class TestKGMLGraphicsSetter

  class TestKGMLGraphics1234 < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr).entries[0].graphics[0]
    end

    def test_name
      assert_equal 'C99999', @obj.name
    end

    def test_type
      assert_equal 'circle', @obj.type
    end

    def test_fgcolor
      assert_equal "#E0E0E0", @obj.fgcolor
    end

    def test_bgcolor
      assert_equal "#D0E0F0", @obj.bgcolor
    end

    def test_x
      assert_equal 1314, @obj.x
    end

    def test_y
      assert_equal 1008, @obj.y
    end

    def test_width
      assert_equal 14, @obj.width
    end

    def test_height
      assert_equal 28, @obj.height
    end

    def test_coords
      assert_equal nil, @obj.coords
    end
  end #class TestKGMLGraphics1234

  class TestKGMLGraphics1_0 < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr).entries[1].graphics[0]
    end

    def test_name
      assert_equal '1.1.1.1', @obj.name
    end

    def test_type
      assert_equal 'line', @obj.type
    end

    def test_fgcolor
      assert_equal "#99CCFF", @obj.fgcolor
    end

    def test_bgcolor
      assert_equal "#FFFFFF", @obj.bgcolor
    end

    def test_x
      assert_equal 0, @obj.x
    end

    def test_y
      assert_equal 0, @obj.y
    end

    def test_width
      assert_equal 0, @obj.width
    end

    def test_height
      assert_equal 0, @obj.height
    end

    def test_coords
      assert_equal [[314,159], [265,358], [979,323]], @obj.coords
    end
  end #class TestKGMLGraphics1_0

  class TestKGMLRelationSetter < Test::Unit::TestCase
    def setup
      @obj = Bio::KEGG::KGML::Relation.new
    end

    def test_entry1=()
      assert_nil @obj.entry1
      assert_equal 123, (@obj.entry1 = 123)
      assert_equal 123, @obj.entry1
      assert_equal 456, (@obj.entry1 = 456)
      assert_equal 456, @obj.entry1
    end

    def test_entry2=()
      assert_nil @obj.entry2
      assert_equal 123, (@obj.entry2 = 123)
      assert_equal 123, @obj.entry2
      assert_equal 456, (@obj.entry2 = 456)
      assert_equal 456, @obj.entry2
    end

    def test_type=()
      assert_nil @obj.type
      assert_equal "ECrel", (@obj.type = "ECrel")
      assert_equal "ECrel", @obj.type
      assert_equal "maplink", (@obj.type = "maplink")
      assert_equal "maplink", @obj.type
    end

    def test_name=()
      assert_nil @obj.name
      assert_equal "hidden compound", (@obj.name = "hidden compound")
      assert_equal "hidden compound", @obj.name
      assert_equal "indirect effect", (@obj.name = "indirect effect")
      assert_equal "indirect effect", @obj.name
    end

    def test_value=()
      assert_nil @obj.value
      assert_equal "123", (@obj.value = "123")
      assert_equal "123", @obj.value
      assert_equal "-->", (@obj.value = "-->")
      assert_equal "-->", @obj.value
    end
  end #class TestKGMLRelationSetter

  # for deprecated methods/attributes
  class TestKGMLRelationDeprecated < Test::Unit::TestCase
    def setup
      @obj = Bio::KEGG::KGML::Relation.new
    end

    def test_node1=()
      assert_nil @obj.node1
      assert_equal 123, (@obj.node1 = 123)
      assert_equal 123, @obj.node1
      assert_equal 456, (@obj.node1 = 456)
      assert_equal 456, @obj.node1

      assert_equal 456, @obj.entry1
      @obj.entry1 = 789
      assert_equal 789, @obj.node1
    end

    def test_node2=()
      assert_nil @obj.node2
      assert_equal 123, (@obj.node2 = 123)
      assert_equal 123, @obj.node2
      assert_equal 456, (@obj.node2 = 456)
      assert_equal 456, @obj.node2

      assert_equal 456, @obj.entry2
      @obj.entry2 = 789
      assert_equal 789, @obj.node2
    end

    def test_rel=()
      assert_nil @obj.rel
      assert_equal "ECrel", (@obj.rel = "ECrel")
      assert_equal "ECrel", @obj.rel
      assert_equal "maplink", (@obj.rel = "maplink")
      assert_equal "maplink", @obj.rel

      assert_equal "maplink", @obj.type
      @obj.type = "PCrel"
      assert_equal "PCrel", @obj.rel
    end

    def test_edge
      @obj.value = "123"
      assert_equal 123, @obj.edge
    end
  end #class TestKGMLRelationDeprecated

  class TestKGMLRelation < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr).relations[0]
    end

    def test_entry1
      assert_equal 109, @obj.entry1
    end

    def test_entry2
      assert_equal 87, @obj.entry2
    end

    def test_type
      assert_equal "ECrel", @obj.type
    end

    def test_name
      assert_equal "compound", @obj.name
    end

    def test_value
      assert_equal "100", @obj.value
    end
  end #class TestKGMLRelation

  class TestKGMLReactionSetter < Test::Unit::TestCase
    def setup
      @obj = Bio::KEGG::KGML::Reaction.new
    end

    def test_id=()
      assert_nil @obj.id
      assert_equal 1234, (@obj.id = 1234)
      assert_equal 1234, @obj.id
      assert_equal 4567, (@obj.id = 4567)
      assert_equal 4567, @obj.id
    end

    def test_name=()
      assert_nil @obj.name
      assert_equal 'rn:R99999 rn:R99998',
      (@obj.name = 'rn:R99999 rn:R99998')
      assert_equal 'rn:R99999 rn:R99998', @obj.name
      assert_equal 'rn:R98765 rn:R98764',
      (@obj.name = 'rn:R98765 rn:R98764')
      assert_equal 'rn:R98765 rn:R98764', @obj.name
    end

    def test_type=()
      assert_nil @obj.type
      assert_equal 'reversible', (@obj.type = 'reversible')
      assert_equal 'reversible', @obj.type
      assert_equal 'irreversible', (@obj.type = 'irreversible')
      assert_equal 'irreversible', @obj.type
    end

    def test_substraces=()
      assert_nil @obj.substrates
      a = [ nil, nil ]
      b = [ nil, nil, nil ]
      assert_equal a, (@obj.substrates = a)
      assert_equal a, @obj.substrates
      assert_equal b, (@obj.substrates = b)
      assert_equal b, @obj.substrates
    end

    def test_products=()
      assert_nil @obj.products
      a = [ nil, nil ]
      b = [ nil, nil, nil ]
      assert_equal a, (@obj.products = a)
      assert_equal a, @obj.products
      assert_equal b, (@obj.products = b)
      assert_equal b, @obj.products
    end

    # TODO: add tests for alt
  end #class TestKGMLReactionSetter

  class TestKGMLReactionSetterDeprecated < Test::Unit::TestCase
    def setup
      @obj = Bio::KEGG::KGML::Reaction.new
    end

    def test_entry_id=()
      assert_nil @obj.entry_id
      assert_equal "rn:R99999 rn:R99998",
      (@obj.entry_id = "rn:R99999 rn:R99998")
      assert_equal "rn:R99999 rn:R99998", @obj.entry_id
      assert_equal "rn:R99990 rn:R99991",
      (@obj.entry_id = "rn:R99990 rn:R99991")
      assert_equal "rn:R99990 rn:R99991", @obj.entry_id

      assert_equal "rn:R99990 rn:R99991", @obj.name
      @obj.name = "rn:R98765 rn:R98766"
      assert_equal "rn:R98765 rn:R98766", @obj.entry_id
    end

    def test_direction=()
      assert_nil @obj.direction
      assert_equal 'reversible', (@obj.direction = 'reversible')
      assert_equal 'reversible', @obj.direction
      assert_equal 'irreversible', (@obj.direction = 'irreversible')
      assert_equal 'irreversible', @obj.direction

      assert_equal 'irreversible', @obj.type
      @obj.type = 'this is test'
      assert_equal 'this is test', @obj.direction
    end
  end #class TestKGMLReactionSetterDreprecated

  class TestKGMLReaction < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj = Bio::KEGG::KGML.new(xmlstr).reactions[0]
    end

    def test_id
      assert_equal 3, @obj.id
    end

    def test_name
      assert_equal "rn:R99999 rn:R99998", @obj.name
    end

    def test_type
      assert_equal "reversible", @obj.type
    end

    def test_substrates
      assert_equal [ "cpd:C99990", "cpd:C99991" ],
      @obj.substrates.collect { |x| x.name }

      assert_equal [ 3330, 3331 ],
      @obj.substrates.collect { |x| x.id }
    end

    def test_products
      assert_equal [ "cpd:C99902", "cpd:C99903" ],
      @obj.products.collect { |x| x.name }

      assert_equal [ 3332, 3333 ],
      @obj.products.collect { |x| x.id }
    end
  end #class TestKGMLReaction

  class TestKGMLSubstrate < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj0 = Bio::KEGG::KGML.new(xmlstr).reactions[0].substrates[0]
      @obj1 = Bio::KEGG::KGML.new(xmlstr).reactions[0].substrates[1]
    end

    def test_id
      assert_equal 3330, @obj0.id
      assert_equal 3331, @obj1.id
    end

    def test_name
      assert_equal 'cpd:C99990', @obj0.name
      assert_equal 'cpd:C99991', @obj1.name
    end
  end #class TestKGMLSubstrate

  class TestKGMLProduct < Test::Unit::TestCase
    def setup
      xmlstr = KGMLTestXMLstr
      @obj0 = Bio::KEGG::KGML.new(xmlstr).reactions[0].products[0]
      @obj1 = Bio::KEGG::KGML.new(xmlstr).reactions[0].products[1]
    end

    def test_id
      assert_equal 3332, @obj0.id
      assert_equal 3333, @obj1.id
    end

    def test_name
      assert_equal 'cpd:C99902', @obj0.name
      assert_equal 'cpd:C99903', @obj1.name
    end
  end #class TestKGMLProduct

  module TestKGMLSubstrateProductSetterMethods
    def test_initialize_0
      assert_nil @obj.id
      assert_nil @obj.name
    end

    def test_initialize_1
      obj = Bio::KEGG::KGML::SubstrateProduct.new(123)
      assert_equal 123, obj.id
      assert_nil obj.name
    end

    def test_initialize_2
      obj = Bio::KEGG::KGML::SubstrateProduct.new(123, 'test')
      assert_equal 123, obj.id
      assert_equal 'test', obj.name
    end

    def test_id=()
      assert_nil @obj.id
      assert_equal 123, (@obj.id = 123)
      assert_equal 123, @obj.id
      assert_equal 456, (@obj.id = 456)
      assert_equal 456, @obj.id
    end

    def test_name=()
      assert_nil @obj.name
      assert_equal "cpd:C99990", (@obj.name = "cpd:C99990")
      assert_equal "cpd:C99990", @obj.name
      assert_equal "cpd:C99902", (@obj.name = "cpd:C99902")
      assert_equal "cpd:C99902", @obj.name
    end
  end #module TestKGMLSubstrateProductSetterMethods

  class TestKGMLSubstrateProductSetter < Test::Unit::TestCase
    include TestKGMLSubstrateProductSetterMethods
    def setup
      @obj = Bio::KEGG::KGML::SubstrateProduct.new
    end
  end # class TestKGMLSubstrateProductSetter

  class TestKGMLSubstrateSetter < Test::Unit::TestCase
    include TestKGMLSubstrateProductSetterMethods
    def setup
      @obj = Bio::KEGG::KGML::Substrate.new
    end
  end # class TestKGMLSubstrateSetter

  class TestKGMLProductSetter < Test::Unit::TestCase
    include TestKGMLSubstrateProductSetterMethods
    def setup
      @obj = Bio::KEGG::KGML::Product.new
    end
  end # class TestKGMLProductSetter

end; end #module TestKeggKGML; #module Bio

