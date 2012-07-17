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
# === Incompatible attribute names with KGML tags
#
# <entry>
#  :id -> :entry_id
#  :type -> :category
#  :map -> :pathway
#  names()
#  <graphics>
#  :name -> :label
#  :type -> :shape
# <relation>
#  :entry1 -> :node1
#  :entry2 -> :node2
#  :type -> :rel
#  <subtype>
#  edge()
# <reaction>
#  :name -> :entry_id
#  :type -> :direction
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
#    puts entry.entry_id
#    puts entry.name
#    puts entry.category
#    puts entry.link
#    puts entry.reaction
#    puts entry.pathway
#    # <graphics> attributes
#    puts entry.label	      # name
#    puts entry.shape         # type
#    puts entry.x
#    puts entry.y
#    puts entry.width
#    puts entry.height
#    puts entry.fgcolor
#    puts entry.bgcolor
#    # <component> attributes
#    puts entry.components
#    # methood
#    puts entry.names
#  end
#
#  kgml.relations.each do |relation|
#    # <relation> attributes
#    puts relation.node1      # entry1
#    puts relation.node2      # entry2
#    puts relation.rel        # type
#    # method
#    puts relation.edge
#    # <subtype> attributes
#    puts relation.name
#    puts relation.value
#  end
#
#  kgml.reactions.each do |reaction|
#    # <reaction> attributes
#    puts reaction.entry_id   # name
#    puts reaction.direction  # type
#    # <substrate> attributes
#    reaction.substrates.each do |entry_id|
#      puts entry_id
#      # <alt> attributes
#      altnames = reaction.alt[entry_id]
#      altnames.each do |name|
#        puts name
#      end
#    end
#    # <product> attributes
#    reaction.products.each do |entry_id|
#      puts entry_id
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

  # KEGG-style ID string of this pathway map (String)
  attr_reader :name

  # "ko" (KEGG Orthology), "ec" (KEGG ENZYME),
  # or the KEGG 3-letter organism code (String)
  attr_reader :org

  # map number (String)
  attr_reader :number

  # title (String)
  attr_reader :title

  # image URL of this pathway map (String)
  attr_reader :image

  # general information URL of this pathway map (String)
  attr_reader :link

  # contains KGML::Entry objects
  attr_accessor :entries

  # contains KGML::Relations objects
  attr_accessor :relations

  # contains KGML::Reactions objects
  attr_accessor :reactions

  # Bio::KEGG:Entry contains an entry element in the KGML.
  class Entry

    # ID of this entry in this pathway map (Integer).
    # ('id' attribute in 'entry' element)
    attr_accessor :entry_id

    # KEGG-style ID string of this entry (String)
    attr_accessor :name

    # type of this entry (String).
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
    attr_accessor :category

    # URL pointing information about this entry (String)
    attr_accessor :link

    # KEGG-style ID string of this reaction (String)
    attr_accessor :reaction

    # (Deprecated?) ('map' attribute in 'entry' element)
    attr_accessor :pathway

    # label of the 'graphics' element (String)
    # ('name' attribute in 'graphics' element)
    attr_accessor :label

    # shape of the 'graphics' element (String)
    # Normally one of the following:
    # * "rectangle"
    # * "circle"
    # * "roundrectangle"
    # * "line"
    # If not specified, "rectangle" is the default value.
    # ('type' attribute in 'graphics' element)
    attr_accessor :shape

    # X axis position (Integer) ('graphics' element)
    attr_accessor :x

    # Y axis position (Integer) ('graphics' element)
    attr_accessor :y

    # width (Integer) ('graphics' element)
    attr_accessor :width

    # height (Integer) ('graphics' element)
    attr_accessor :height

    # foreground color (String) ('graphics' element)
    attr_accessor :fgcolor

    # background color (String) ('graphics' element)
    attr_accessor :bgcolor

    # components included in this entry
    # (Array containing Integer objects, or nil)
    attr_accessor :components

    # (Deprecated?) names (Array)
    def names
      @name.split(/\s+/)
    end
  end

  # Bio::KEGG::KGML::Relation contains a relation element in the KGML.
  class Relation

    # the first entry of the relation (String)
    # ('entry1' attribute in 'relation' element)
    attr_accessor :node1

    # the second entry of the relation (String)
    # ('entry2' attribute in 'relation' element)
    attr_accessor :node2

    # type of this relation (String).
    # Normally one of the following:
    # * "ECrel"
    # * "PPrel"
    # * "GErel"
    # * "PCrel"
    # * "maplink"
    # ('type' attribute in 'relation' element)
    attr_accessor :rel

    # interaction and/or relation type (String).
    # See http://www.genome.jp/kegg/xml/docs/ for details.
    # ('name' attribute in 'subtype' element)
    attr_accessor :name

    # interaction and/or relation information (String).
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

    # KEGG-stype ID string of this reaction (String)
    # ('name' attribute in 'reaction' element)
    attr_accessor :entry_id

    # type of this reaction (String).
    # Normally "reversible" or "irreversible".
    # ('type' attribute in 'reaction' element)
    attr_accessor :direction

    # Substrates. Each substrate name is the KEGG-style ID string.
    # (Array containing String objects)
    attr_accessor :substrates

    # Products. Each product name is the KEGG-style ID string.
    # (Array containing String objects)
    attr_accessor :products

    # (Deprecated?) (Hash)
    attr_accessor :alt
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
      entry.entry_id = attr["id"].to_i
      entry.name     = attr["name"]
      entry.category = attr["type"]
      # implied
      entry.link     = attr["link"]
      entry.reaction = attr["reaction"]
      entry.pathway  = attr["map"]

      node.elements.each("graphics") { |graphics|
        attr = graphics.attributes
        entry.x        = attr["x"].to_i
        entry.y        = attr["y"].to_i
        entry.shape    = attr["type"]
        entry.label    = attr["name"]
        entry.width    = attr["width"].to_i
        entry.height   = attr["height"].to_i
        entry.fgcolor  = attr["fgcolor"]
        entry.bgcolor  = attr["bgcolor"]
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
      relation.node1   = attr["entry1"].to_i
      relation.node2   = attr["entry2"].to_i
      relation.rel     = attr["type"]

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
      reaction.entry_id  = attr["name"]
      reaction.direction = attr["type"]

      substrates = Array.new
      products   = Array.new
      hash        = Hash.new

      node.elements.each("substrate") { |substrate|
        name = substrate.attributes["name"]
        substrates << name
        substrate.elements.each("alt") { |alt|
          hash[name] ||= Array.new
          hash[name] << alt.attributes["name"]
        }
      }
      node.elements.each("product") { |product|
        name = product.attributes["name"]
        products << name
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


