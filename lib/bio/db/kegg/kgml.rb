#
# = bio/db/kegg/kgml.rb - KEGG KGML parser class
#
# Copyright::	Copyright (C) 2005
# 		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id: kgml.rb,v 1.7 2007/04/05 23:35:41 trevor Exp $
#

autoload :REXML, 'rexml/document'

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
class KGML

  def initialize(xml)
    dom = REXML::Document.new(xml)
    parse_root(dom)
    parse_entry(dom)
    parse_relation(dom)
    parse_reaction(dom)
  end
  attr_reader :name, :org, :number, :title, :image, :link
  attr_accessor :entries, :relations, :reactions

  class Entry
    attr_accessor :entry_id, :name, :category, :link, :reaction, :pathway
    attr_accessor :label, :shape, :x, :y, :width, :height, :fgcolor, :bgcolor
    attr_accessor :components
    def names
      @name.split(/\s+/)
    end
  end

  class Relation
    attr_accessor :node1, :node2, :rel
    attr_accessor :name, :value
    def edge
      @value.to_i
    end
  end

  class Reaction
    attr_accessor :entry_id, :direction
    attr_accessor :substrates, :products	# Array
    attr_accessor :alt				# Hash
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


