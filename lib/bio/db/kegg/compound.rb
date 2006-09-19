#
# = bio/db/kegg/compound.rb - KEGG COMPOUND database class
#
# Copyright::  Copyright (C) 2001, 2002, 2004 Toshiaki Katayama <k@bioruby.org>
# License::    Ruby's
#
# $Id: compound.rb,v 0.12 2006/09/19 05:51:29 k Exp $
#

require 'bio/db'

module Bio
class KEGG

class COMPOUND < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  def entry_id
    unless @data['ENTRY']
      @data['ENTRY'] = fetch('ENTRY').split(/\s+/).first
    end
    @data['ENTRY']
  end

  # NAME
  def names
    lines_fetch('NAME') 
  end
  def name
    names[0]
  end

  # FORMULA
  def formula
    field_fetch('FORMULA')
  end

  # MASS
  def mass
    field_fetch('MASS').to_f
  end

  # REACTION
  def reactions
    unless @data['REACTION']
      @data['REACTION'] = fetch('REACTION').split(/\s+/)
    end
    @data['REACTION']
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
      field = fetch('ENZYME')
      if /\(/.match(field)	# old version
        @data['ENZYME'] = field.scan(/\S+ \(\S+\)/)
      else
        @data['ENZYME'] = field.scan(/\S+/)
      end
    end
    @data['ENZYME']
  end

  # DBLINKS
  def dblinks
    lines_fetch('DBLINKS')
  end

  # ATOM, BOND
  def kcf
    return "#{get('ATOM')}#{get('BOND')}"
  end

end # COMPOUND

end # KEGG
end # Bio


if __FILE__ == $0
  entry = ARGF.read
  cpd = Bio::KEGG::COMPOUND.new(entry)
  p cpd.entry_id
  p cpd.names
  p cpd.name
  p cpd.formula
  p cpd.mass
  p cpd.reactions
  p cpd.rpairs
  p cpd.pathways
  p cpd.enzymes
  p cpd.dblinks
  p cpd.kcf
end

