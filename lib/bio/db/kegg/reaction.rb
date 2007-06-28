#
# = bio/db/kegg/reaction.rb - KEGG REACTION database class
#
# Copyright::  Copyright (C) 2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: reaction.rb,v 1.6 2007/06/28 11:27:24 k Exp $
#

require 'bio/db'

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
      @data['RPAIR'] = fetch('RPAIR').split(/\s+/)
    end
    @data['RPAIR']
  end

  # PATHWAY
  def pathways
    lines_fetch('PATHWAY') 
  end

  # ENZYME
  def enzymes
    unless @data['ENZYME']
      @data['ENZYME'] = fetch('ENZYME').scan(/\S+/)
    end
    @data['ENZYME']
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
end

