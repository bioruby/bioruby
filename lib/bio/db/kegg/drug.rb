#
# = bio/db/kegg/drug.rb - KEGG DRUG database class
#
# Copyright::  Copyright (C) 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'

module Bio
class KEGG

# == Description
#
# Bio::KEGG::DRUG is a parser class for the KEGG DRUG database entry.
# KEGG DRUG is a drug information database.
#
# == References
# 
# * http://www.genome.jp/kegg/drug/
#
class DRUG < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  # Creates a new Bio::KEGG::DRUG object.
  # ---
  # *Arguments*:
  # * (required) _entry_: (String) single entry as a string
  # *Returns*:: Bio::KEGG::DRUG object
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
    lines_fetch('PATHWAY')
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

