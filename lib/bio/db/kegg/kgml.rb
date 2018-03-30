#
# = bio/db/kegg/kgml.rb - KEGG KGML parser class
#
# Copyright::	Copyright (C) 2005
# 		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#

require 'rexml/document'

module Bio
class KEGG

# == KGML (KEGG XML) parser
#
# See http://www.genome.jp/kegg/xml/ for more details on KGML.
#
# === Note for older version users
# * Most of incompatible attribute names with KGML tags are now deprecated.
#   Use the names of KGML tags instead of old incompatible names that will
#   be removed in the future.
#   * Bio::KGML::Entry#id (entry_id is deprecated)
#   * Bio::KGML::Entry#type (category is deprecated)
#   * Bio::KGML::Relation#entry1 (node1 is deprecated)
#   * Bio::KGML::Relation#entry2 (node2 is deprecated)
#   * Bio::KGML::Relation#type (rel is deprecated)
#   * Bio::KGML::Reaction#name (entry_id is deprecated)
#   * Bio::KGML::Reaction#type (direction is deprecated)
# * New class Bio::KGML::Graphics and new method Bio::KGML::Entry#graphics.
#   Because two or more graphics elements may exist, following attribute
#   methods in Bio::KGML::Entry are now deprecated and will be removed
#   in the future. See rdoc of these methods for details.
#   * Bio::KEGG::KGML::Entry#label
#   * Bio::KEGG::KGML::Entry#shape
#   * Bio::KEGG::KGML::Entry#x
#   * Bio::KEGG::KGML::Entry#y
#   * Bio::KEGG::KGML::Entry#width
#   * Bio::KEGG::KGML::Entry#height
#   * Bio::KEGG::KGML::Entry#fgcolor
#   * Bio::KEGG::KGML::Entry#bgcolor
# * Incompatible changes: Bio::KEGG::KGML::Reaction#substrates now returns
#   an array containing Bio::KEGG::KGML::Substrate objects, and 
#   Bio::KEGG::KGML::Reaction#products now returns an array containing
#   Bio::KEGG::KGML::Product objects. The changes enable us to get id of
#   substrates and products.
#
# === Incompatible attribute names with KGML tags
#
#  <entry>
#  :map -> :pathway
#  names()
#  <subtype>
#  edge()
#
# === Examples
#
#  file = File.read("kgml/hsa/hsa00010.xml")
#  kgml = Bio::KEGG::KGML.new(file)
#
#  # <pathway> attributes
#  puts kgml.name
#  puts kgml.org
#  puts kgml.number
#  puts kgml.title
#  puts kgml.image
#  puts kgml.link
#
#  kgml.entries.each do |entry|
#    # <entry> attributes
#    puts entry.id
#    puts entry.name
#    puts entry.type
#    puts entry.link
#    puts entry.reaction
#    # <graphics> attributes
#    entry.graphics.each do |graphics|
#      puts graphics.name
#      puts graphics.type
#      puts graphics.x
#      puts graphics.y
#      puts graphics.width
#      puts graphics.height
#      puts graphics.fgcolor
#      puts graphics.bgcolor
#    end
#    # <component> attributes
#    puts entry.components
#    # methood
#    puts entry.names
#  end
#
#  kgml.relations.each do |relation|
#    # <relation> attributes
#    puts relation.entry1
#    puts relation.entry2
#    puts relation.type
#    # <subtype> attributes
#    puts relation.name
#    puts relation.value
#  end
#
#  kgml.reactions.each do |reaction|
#    # <reaction> attributes
#    puts reaction.name
#    puts reaction.type
#    # <substrate> attributes
#    reaction.substrates.each do |substrate|
#      puts substrate.id
#      puts substrate.name
#      # <alt> attributes
#      altnames = reaction.alt[entry_id]
#      altnames.each do |name|
#        puts name
#      end
#    end
#    # <product> attributes
#    reaction.products.each do |product|
#      puts product.id
#      puts product.name
#      # <alt> attributes
#      altnames = reaction.alt[entry_id]
#      altnames.each do |name|
#        puts name
#      end
#    end
#  end
#
# === References
#
# * http://www.genome.jp/kegg/xml/docs/
#
class KGML

  # Creates a new KGML object.
  # 
  # ---
  # *Arguments*:
  # * (required) _str_: String containing xml data
  # *Returns*:: Bio::KEGG::KGML object
  def initialize(xml)
    dom = REXML::Document.new(xml)
    parse_root(dom)
    parse_entry(dom)
    parse_relation(dom)
    parse_reaction(dom)
  end

  # KEGG-style ID string of this pathway map (String or nil)
  # ('pathway' element)
  attr_reader :name

  # "ko" (KEGG Orthology), "ec" (KEGG ENZYME),
  # or the KEGG 3-letter organism code (String or nil)
  # ('pathway' element)
  attr_reader :org

  # map number (String or nil)
  # ('pathway' element)
  attr_reader :number

  # title (String or nil)
  # ('pathway' element)
  attr_reader :title

  # image URL of this pathway map (String or nil)
  # ('pathway' element)
  attr_reader :image

  # information URL of this pathway map (String or nil)
  # ('pathway' element)
  attr_reader :link

  # entry elements (Array containing KGML::Entry objects, or nil)
  attr_accessor :entries

  # relation elements (Array containing KGML::Relations objects, or nil)
  attr_accessor :relations

  # reaction elements (Array containing KGML::Reactions objects, or nil)
  attr_accessor :reactions

  # Bio::KEGG:Entry contains an entry element in the KGML.
  class Entry

    # ID of this entry in this pathway map (Integer or nil).
    # ('id' attribute in 'entry' element)
    attr_accessor :id

    alias entry_id  id
    alias entry_id= id=

    # KEGG-style ID string of this entry (String or nil)
    attr_accessor :name

    # type of this entry (String or nil).
    # Normally one of the following:
    # * "ortholog"
    # * "enzyme"
    # * "reaction"
    # * "gene"
    # * "group"
    # * "compound"
    # * "map"
    # See http://www.genome.jp/kegg/xml/docs/ for details.
    # ('type' attribute in 'entry' element)
    attr_accessor :type

    alias category  type
    alias category= type=

    # URL pointing information about this entry (String or nil)
    attr_accessor :link

    # KEGG-style ID string of this reaction (String or nil)
    attr_accessor :reaction

    # (Deprecated?) ('map' attribute in 'entry' element)
    attr_accessor :pathway

    # (private) get an attribute value in the graphics[-1] object
    def _graphics_attr(attr)
      if self.graphics then
        g = self.graphics[-1]
        g ? g.__send__(attr) : nil
      else
        nil
      end
    end
    private :_graphics_attr

    # (private) get an attribute value in the graphics[-1] object
    def _graphics_set_attr(attr, val)
      self.graphics ||= []
      unless g = self.graphics[-1] then
        g = Graphics.new
        self.graphics.push(g)
      end
      g.__send__(attr, val)
    end
    private :_graphics_set_attr

    # Deprecated.
    # Same as self.graphics[-1].name (additional nil checks may be needed).
    # 
    # label of the 'graphics' element (String or nil)
    # ('name' attribute in 'graphics' element)
    def label
      _graphics_attr(:name)
    end

    # Deprecated.
    # Same as self.graphics[-1].name= (additional nil checks may be needed).
    #
    def label=(val)
      _graphics_set_attr(:name=, val)
    end

    # Deprecated.
    # Same as self.graphics[-1].type (additional nil checks may be needed).
    #
    # shape of the 'graphics' element (String or nil)
    # Normally one of the following:
    # * "rectangle"
    # * "circle"
    # * "roundrectangle"
    # * "line"
    # If not specified, "rectangle" is the default value.
    # ('type' attribute in 'graphics' element)
    def shape
      _graphics_attr(:type)
    end

    # Deprecated.
    # Same as self.graphics[-1].type= (additional nil checks may be needed).
    #
    def shape=(val)
      _graphics_set_attr(:type=, val)
    end

    # Deprecated.
    # Same as self.graphics[-1].x (additional nil checks may be needed).
    #
    # X axis position (Integer or nil) ('graphics' element)
    def x
      _graphics_attr(:x)
    end

    # Deprecated.
    # Same as self.graphics[-1].x= (additional nil checks may be needed).
    #
    def x=(val)
      _graphics_set_attr(:x=, val)
    end

    # Deprecated.
    # Same as self.graphics[-1].y (additional nil checks may be needed).
    #
    # Y axis position (Integer or nil) ('graphics' element)
    def y
      _graphics_attr(:y)
    end

    # Deprecated.
    # Same as self.graphics[-1].y= (additional nil checks may be needed).
    #
    def y=(val)
      _graphics_set_attr(:y=, val)
    end

    # Deprecated.
    # Same as self.graphics[-1].width (additional nil checks may be needed).
    #
    # width (Integer or nil) ('graphics' element)
    def width
      _graphics_attr(:width)
    end

    # Deprecated.
    # Same as self.graphics[-1].width= (additional nil checks may be needed).
    #
    def width=(val)
      _graphics_set_attr(:width=, val)
    end

    # Deprecated.
    # Same as self.graphics[-1].height (additional nil checks may be needed).
    #
    # height (Integer or nil) ('graphics' element)
    def height
      _graphics_attr(:height)
    end

    # Deprecated.
    # Same as self.graphics[-1].height= (additional nil checks may be needed).
    #
    def height=(val)
      _graphics_set_attr(:height=, val)
    end

    # Deprecated.
    # Same as self.graphics[-1].fgcolor (additional nil checks may be needed).
    #
    # foreground color (String or nil) ('graphics' element)
    def fgcolor
      _graphics_attr(:fgcolor)
    end

    # Deprecated.
    # Same as self.graphics[-1].fgcolor= (additional nil checks may be needed).
    #
    def fgcolor=(val)
      _graphics_set_attr(:fgcolor=, val)
    end

    # Deprecated.
    # Same as self.graphics[-1].bgcolor (additional nil checks may be needed).
    #
    # background color (String or nil) ('graphics' element)
    def bgcolor
      _graphics_attr(:bgcolor)
    end

    # Deprecated.
    # Same as self.graphics[-1].bgcolor= (additional nil checks may be needed).
    #
    def bgcolor=(val)
      _graphics_set_attr(:bgcolor=, val)
    end

    # graphics elements included in this entry
    # (Array containing Graphics objects, or nil)
    attr_accessor :graphics

    # component elements included in this entry
    # (Array containing Integer objects, or nil)
    attr_accessor :components

    # the "name" attribute may contain multiple names separated
    # with space characters. This method returns the names
    # as an array. (Array containing String objects)
    def names
      @name.split(/\s+/)
    end
  end

  # Bio::KEGG::KGML::Graphics contains a 'graphics' element in the KGML.
  class Graphics
    # label of the 'graphics' element (String or nil)
    attr_accessor :name

    # shape of the 'graphics' element (String or nil)
    # Normally one of the following:
    # * "rectangle"
    # * "circle"
    # * "roundrectangle"
    # * "line"
    # If not specified, "rectangle" is the default value.
    attr_accessor :type

    # X axis position (Integer or nil)
    attr_accessor :x

    # Y axis position (Integer or nil)
    attr_accessor :y

    # polyline coordinates
    # (Array containing Array of [ x, y ] pair of Integer values)
    attr_accessor :coords

    # width (Integer or nil)
    attr_accessor :width

    # height (Integer or nil)
    attr_accessor :height

    # foreground color (String or nil)
    attr_accessor :fgcolor

    # background color (String or nil)
    attr_accessor :bgcolor
  end #class Graphics

  # Bio::KEGG::KGML::Relation contains a relation element in the KGML.
  class Relation

    # the first entry of the relation (Integer or nil)
    # ('entry1' attribute in 'relation' element)
    attr_accessor :entry1

    alias node1  entry1
    alias node1= entry1=

    # the second entry of the relation (Integer or nil)
    # ('entry2' attribute in 'relation' element)
    attr_accessor :entry2

    alias node2  entry2
    alias node2= entry2=

    # type of this relation (String or nil).
    # Normally one of the following:
    # * "ECrel"
    # * "PPrel"
    # * "GErel"
    # * "PCrel"
    # * "maplink"
    # ('type' attribute in 'relation' element)
    attr_accessor :type

    alias rel  type
    alias rel= type=

    # interaction and/or relation type (String or nil).
    # See http://www.genome.jp/kegg/xml/docs/ for details.
    # ('name' attribute in 'subtype' element)
    attr_accessor :name

    # interaction and/or relation information (String or nil).
    # See http://www.genome.jp/kegg/xml/docs/ for details.
    # ('value' attribute in 'subtype' element)
    attr_accessor :value

    # (Deprecated?)
    def edge
      @value.to_i
    end
  end

  # Bio::KEGG::KGML::Reaction contains a reaction element in the KGML.
  class Reaction

    # ID of this reaction (Integer or nil)
    attr_accessor :id

    # KEGG-stype ID string of this reaction (String or nil)
    # ('name' attribute in 'reaction' element)
    attr_accessor :name

    alias entry_id  name
    alias entry_id= name=

    # type of this reaction (String or nil).
    # Normally "reversible" or "irreversible".
    # ('type' attribute in 'reaction' element)
    attr_accessor :type

    alias direction  type
    alias direction= type=

    # Substrates. Each substrate name is the KEGG-style ID string.
    # (Array containing String objects, or nil)
    attr_accessor :substrates

    # Products. Each product name is the KEGG-style ID string.
    # (Array containing String objects, or nil)
    attr_accessor :products

    # alt element (Hash)
    attr_accessor :alt
  end

  # Bio::KEGG::KGML::SubstrateProduct contains a substrate element
  # or a product element in the KGML.
  #
  # Please do not use SubstrateProduct directly.
  # Instead, please use Substrate or Product class.
  class SubstrateProduct
    # ID of this substrate or product (Integer or nil)
    attr_accessor :id

    # name of this substrate or product (String or nil)
    attr_accessor :name

    # Creates a new object
    def initialize(id = nil, name = nil)
      @id ||= id
      @name ||= name
    end
  end #class SubstrateProduct

  # Bio::KEGG::KGML::Substrate contains a substrate element in the KGML.
  class Substrate < SubstrateProduct
  end

  # Bio::KEGG::KGML::Product contains a product element in the KGML.
  class Product < SubstrateProduct
  end

  private

  def parse_root(dom)
    root    = dom.root.attributes
    @name   = root["name"]
    @org    = root["org"]
    @number = root["number"]
    @title  = root["title"]
    @image  = root["image"]
    @link   = root["link"]
  end

  def parse_entry(dom)
    @entries = Array.new

    dom.elements.each("/pathway/entry") { |node|
      attr = node.attributes
      entry = Entry.new
      entry.id   = attr["id"].to_i
      entry.name = attr["name"]
      entry.type = attr["type"]
      # implied
      entry.link     = attr["link"]
      entry.reaction = attr["reaction"]
      entry.pathway  = attr["map"]

      node.elements.each("graphics") { |graphics|
        g = Graphics.new
        attr = graphics.attributes
        g.x       = attr["x"].to_i
        g.y       = attr["y"].to_i
        g.type    = attr["type"]
        g.name    = attr["name"]
        g.width    = attr["width"].to_i
        g.height   = attr["height"].to_i
        g.fgcolor  = attr["fgcolor"]
        g.bgcolor  = attr["bgcolor"]
        if str = attr["coords"] then
          coords = []
          tmp = str.split(',')
          tmp.collect! { |n| n.to_i }
          while xx = tmp.shift
            yy = tmp.shift
            coords.push [ xx, yy ]
          end
          g.coords = coords
        else
          g.coords = nil
        end
        entry.graphics ||= []
        entry.graphics.push g
      }

      node.elements.each("component") { |component|
        attr = component.attributes
        entry.components ||= []
        entry.components << attr["id"].to_i
      }

      @entries << entry
    }
  end

  def parse_relation(dom)
    @relations = Array.new

    dom.elements.each("/pathway/relation") { |node|
      attr = node.attributes
      relation = Relation.new
      relation.entry1 = attr["entry1"].to_i
      relation.entry2 = attr["entry2"].to_i
      relation.type   = attr["type"]

      node.elements.each("subtype") { |subtype|
        attr = subtype.attributes
        relation.name  = attr["name"]
        relation.value = attr["value"]
      }
      @relations << relation
    }
  end

  def parse_reaction(dom)
    @reactions = Array.new

    dom.elements.each("/pathway/reaction") { |node|
      attr = node.attributes
      reaction = Reaction.new
      reaction.id   = attr["id"].to_i
      reaction.name = attr["name"]
      reaction.type = attr["type"]

      substrates = Array.new
      products   = Array.new
      hash        = Hash.new

      node.elements.each("substrate") { |substrate|
        id = substrate.attributes["id"].to_i
        name = substrate.attributes["name"]
        substrates << Substrate.new(id, name)
        substrate.elements.each("alt") { |alt|
          hash[name] ||= Array.new
          hash[name] << alt.attributes["name"]
        }
      }
      node.elements.each("product") { |product|
        id = product.attributes["id"].to_i
        name = product.attributes["name"]
        products << Product.new(id, name)
        product.elements.each("alt") { |alt|
          hash[name] ||= Array.new
          hash[name] << alt.attributes["name"]
        }
      }
      reaction.substrates = substrates
      reaction.products = products
      reaction.alt = hash

      @reactions << reaction
    }
  end

end # KGML

end # KEGG
end # Bio


