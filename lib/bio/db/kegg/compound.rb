#
# = bio/db/kegg/compound.rb - KEGG COMPOUND database class
#
# Copyright::  Copyright (C) 2001, 2002, 2004, 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'

module Bio
class KEGG

# == Description
#
# Bio::KEGG::COMPOUND is a parser class for the KEGG COMPOUND database entry.
# KEGG COMPOUND is a chemical structure database.
#
# == References
# 
# * http://www.genome.jp/kegg/compound/
#
class COMPOUND < KEGGDB

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
  def names
    field_fetch('NAME').split(/\s*;\s*/)
  end

  # The first name recorded in the NAME field.
  def name
    names.first
  end

  # FORMULA
  def formula
    field_fetch('FORMULA')
  end

  # MASS
  def mass
    field_fetch('MASS').to_f
  end

  # REMARK
  def remark
    field_fetch('REMARK')
  end

  # GLYCAN
  def glycans
    unless @data['GLYCAN']
      @data['GLYCAN'] = fetch('GLYCAN').split(/\s+/)
    end
    @data['GLYCAN']
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

  # COMMENT
  def comment
    field_fetch('COMMENT')
  end

end # COMPOUND

end # KEGG
end # Bio

