#
# = bio/db/kegg/kgml.rb - KEGG KGML parser class
#
# Copyright::	Copyright (C) 2005
# 		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: kgml.rb,v 1.2 2005/11/05 08:29:53 k Exp $
#
# == KGML (KEGG XML) parser
#
# See http://www.genome.jp/kegg/xml/ for more details on KGML.
#
# === Examples
#
#  file = ARGF.read
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
#    puts entry.names
#    puts entry.type
#    puts entry.link
#    puts entry.reaction
#    puts entry.map
#    # <graphics> attributes
#    puts entry.label	# This is an accessor for <graphics name="">
#    puts entry.x
#    puts entry.y
#    puts entry.type
#    puts entry.width
#    puts entry.height
#    puts entry.fgcolor
#    puts entry.bgcolor
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
#    # or
#    relation.subtype.each do |value, name|
#      puts value, name
#    end
#  end
#
#  kgml.reactions.each do |reaction|
#    # <reaction> attributes
#    puts reaction.name
#    puts reaction.type
#    # <substrate> attributes
#    reaction.substrates.each do |name|
#      puts name
#      # <alt> attributes
#      altnames = reaction.alt[name]
#      altnames.each do |altname|
#        puts altname
#      end
#    end
#    # <product> attributes
#    reaction.products.each do |name|
#      puts name
#      # <alt> attributes
#      altnames = reaction.alt[name]
#      altnames.each do |altname|
#        puts altname
#      end
#    end
#  end
#
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#

require 'rexml/document'

module Bio
class KEGG

class KGML

  def initialize(xml)
    @dom = REXML::Document.new(xml)
    parse_root
    parse_entry
    parse_relation
    parse_reaction
  end
  attr_reader :name, :org, :number, :title, :image, :link
  attr_reader :entries, :relations, :reactions		# Array

  class Entry
    attr_accessor :id, :name, :names, :type, :link, :reaction, :map
    attr_accessor :label, :x, :y, :type, :width, :height, :fgcolor, :bgcolor
  end

  class Relation
    attr_accessor :entry1, :entry2, :type
    attr_accessor :name, :value
    attr_accessor :subtype      			# Hash
  end

  class Reaction
    attr_accessor :name, :type
    attr_accessor :substrates, :products		# Array
    attr_accessor :alt					# Hash
  end

  def parse_root
    root    = @dom.root.attributes
    @name   = root["name"]
    @org    = root["org"]
    @number = root["number"]
    @title  = root["title"]
    @image  = root["image"]
    @link   = root["link"]
  end

  def parse_entry
    @entries = Array.new

    @dom.elements.each("/pathway/entry") { |node|
      attr = node.attributes
      entry = Entry.new
      entry.id        = attr["id"].to_i
      entry.map       = attr["map"]
      entry.name      = attr["name"]
      entry.names     = entry.name.split(/\s+/)
      entry.type      = attr["type"]
      entry.link      = attr["link"]
      entry.reaction  = attr["reaction"]

      node.elements.each("graphics") { |graphics|
        attr = graphics.attributes
        entry.x       = attr["x"].to_i
        entry.y       = attr["y"].to_i
        entry.type    = attr["type"]
        entry.label   = attr["label"]	# name
        entry.width   = attr["width"].to_i
        entry.height  = attr["height"].to_i
        entry.fgcolor = attr["fgcolor"]
        entry.bgcolor = attr["bgcolor"]
      }
      @entries << entry
    }
  end

  def parse_relation
    @relations = Array.new

    @dom.elements.each("/pathway/relation") { |node|
      attr = node.attributes
      relation = Relation.new
      relation.entry1 = attr["entry1"].to_i
      relation.entry2 = attr["entry2"].to_i
      relation.type   = attr["type"]

      hash = Hash.new
      node.elements.each("subtype") { |subtype|
        attr = subtype.attributes
        relation.name  = name  = attr["name"]
        relation.value = value = attr["value"].to_i
        hash[value] = name
      }
      relation.subtype = hash
      @relations << relation
    }
  end

  def parse_reaction
    @reactions = Array.new

    @dom.elements.each("/pathway/reaction") { |node|
      attr = node.attributes
      reaction = Reaction.new
      reaction.name = attr["name"]
      reaction.type = attr["type"]

      substrates = Array.new
      products   = Array.new
      hash       = Hash.new

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
      reaction.products   = products
      reaction.alt        = hash

      @reactions << reaction
    }
  end

end # KGML
end # KEGG
end # Bio


if __FILE__ == $0
  require 'pp'
  xml = ARGF.read
  pp Bio::KEGG::KGML.new(xml)
end


=begin

# This is a test implementation which reflects original KGML data structure.

class KGML

  class Pathway
    attr_accessor :name, :org, :number, :title, :image, :link
    attr_accessor :entries, :relations, :reactions

    class Entry
      attr_accessor :id, :name, :type, :link, :reaction, :map
      attr_accessor :components, :graphics

      class Component
        attr_accessor :id
      end

      class Graphics
        attr_accessor :name, :x, :y, :type, :width, :height, :fgcolor, :bgcolor
      end
    end

    class Relation
      attr_accessor :entry1, :entry2, :type
      attr_accessor :

      class Subtype
        attr_accessor :name, :value
      end
    end

    class Reaction
      attr_accessor :name, :type

      class Substrate
        attr_accessor :name
      end

      class Product
        attr_accessor :name
      end

      class Alt
        attr_accessor :name
      end
    end
  end

end
=end
