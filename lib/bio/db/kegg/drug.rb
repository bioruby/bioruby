#
# = bio/db/kegg/drug.rb - KEGG DRUG database class
#
# Copyright::  Copyright (C) 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'
require 'bio/db/kegg/common'

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

  include Common::DblinksAsHash
  # Returns a Hash of the DB name and an Array of entry IDs in DBLINKS field.
  def dblinks_as_hash; super; end if false #dummy for RDoc
  alias dblinks dblinks_as_hash

  include Common::PathwaysAsHash
  # Returns a Hash of the pathway ID and name in PATHWAY field.
  def pathways_as_hash; super; end if false #dummy for RDoc
  alias pathways pathways_as_hash

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

  # PATHWAY
  def pathways_as_strings
    lines_fetch('PATHWAY') 
  end

  # DBLINKS
  def dblinks_as_strings
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

end # DRUG

end # KEGG
end # Bio

