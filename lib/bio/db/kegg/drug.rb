#
# = bio/db/kegg/drug.rb - KEGG DRUG database class
#
# Copyright::  Copyright (C) 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: drug.rb,v 1.3 2007/06/28 11:27:24 k Exp $
#

require 'bio/db'

module Bio
class KEGG

class DRUG < KEGGDB

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

  # ACTIVITY
  def activity
    field_fetch('ACTIVITY')
  end

  # REMARK
  def remark
    field_fetch('REMARK')
  end

  # COMMENT
  def comment
    field_fetch('COMMENT')
  end

  # PATHWAY
  def pathways
    lines_fetch('DBLINKS')
  end

  # DBLINKS
  def dblinks
    lines_fetch('DBLINKS')
  end

  # ATOM, BOND
  def kcf
    return "#{get('ATOM')}#{get('BOND')}"
  end

end # DRUG

end # KEGG
end # Bio


if __FILE__ == $0
  entry = ARGF.read	# dr:D00001
  dr = Bio::KEGG::DRUG.new(entry)
  p dr.entry_id
  p dr.names
  p dr.name
  p dr.formula
  p dr.mass
  p dr.activity
  p dr.remark
  p dr.comment
  p dr.dblinks
  p dr.kcf
end

