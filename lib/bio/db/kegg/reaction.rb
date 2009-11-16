#
# = bio/db/kegg/reaction.rb - KEGG REACTION database class
#
# Copyright::  Copyright (C) 2004 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License
#
# $Id: reaction.rb,v 1.6 2007/06/28 11:27:24 k Exp $
#

require 'bio/db'
require 'enumerator'

module Bio
class KEGG

class REACTION < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # NAME
  def name
    field_fetch('NAME')
  end

  # DEFINITION
  def definition
    field_fetch('DEFINITION')
  end

  # EQUATION
  def equation
    field_fetch('EQUATION')
  end

  # RPAIR
  def rpairs
    unless @data['RPAIR']
      rps = []
      fetch('RPAIR').split(/\s+/).each_slice(4) do |rp|
        rps.push({"entry" => rp[1], "name" => rp[2], "type" => rp[3]})
      end
      @data['RPAIR'] = rps
    end
    @data['RPAIR']
  end

  # PATHWAY
  def pathways
    maps = []
    lines_fetch('PATHWAY').each do |map|
      entry = map.scan(/rn[0-9]{5}/)[0]
      name = map.split("  ")[1]
      maps.push({"entry" => entry, "name" => name})
    end
    @data['PATHWAY'] = maps
  end

  # ENZYME
  def enzymes
    unless @data['ENZYME']
      @data['ENZYME'] = fetch('ENZYME').scan(/\S+/)
    end
    @data['ENZYME']
  end

  # ORTHOLOGY
  def orthologies
    unless @data['ORTHOLOGY']
      kos = []
      lines_fetch('ORTHOLOGY').each do |ko|
        entry = ko.scan(/K[0-9]{5}/)[0]
        definition = ko.split("  ")[1]
        kos.push({"entry" => entry, "definition" => definition})
      end
      @data['ORTHOLOGY'] = kos
    end
    @data['ORTHOLOGY']
  end

end # REACTION

end # KEGG
end # Bio


if __FILE__ == $0
  entry = ARGF.read
  rn = Bio::KEGG::REACTION.new(entry)
  p rn.entry_id
  p rn.name
  p rn.definition
  p rn.equation
  p rn.rpairs
  p rn.pathways
  p rn.enzymes
  p rn.orthologies
end

