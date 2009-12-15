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

  # ID of the entry, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # Names described in the NAME line.
  # ---
  # *Returns*:: Array containing String objects
  def names
    field_fetch('NAME').split(/\s*;\s*/)
  end

  # The first name recorded in the NAME field.
  # ---
  # *Returns*:: String
  def name
    names.first
  end

  # Chemical formula described in the FORMULA line.
  # ---
  # *Returns*:: String
  def formula
    field_fetch('FORMULA')
  end

  # Molecular weight described in the MASS line.
  # ---
  # *Returns*:: Float
  def mass
    field_fetch('MASS').to_f
  end

  # Biological or chemical activity described in the ACTIVITY line.
  # ---
  # *Returns*:: String
  def activity
    field_fetch('ACTIVITY')
  end

  # REMARK lines.
  # ---
  # *Returns*:: String
  def remark
    field_fetch('REMARK')
  end

  # List of KEGG Pathway IDs with short descriptions,
  # described in the PATHWAY lines.
  # ---
  # *Returns*:: Array containing String objects
  def pathways_as_strings
    lines_fetch('PATHWAY') 
  end

  # List of database names and IDs, described in the DBLINKS lines.
  # ---
  # *Returns*:: Array containing String objects
  def dblinks_as_strings
    lines_fetch('DBLINKS')
  end

  # ATOM, BOND lines.
  # ---
  # *Returns*:: String
  def kcf
    return "#{get('ATOM')}#{get('BOND')}"
  end

  # COMMENT lines.
  # ---
  # *Returns*:: String
  def comment
    field_fetch('COMMENT')
  end

  # Product names described in the PRODUCTS lines.
  # ---
  # *Returns*:: Array containing String objects
  def products
    lines_fetch('PRODUCTS')
  end

end # DRUG

end # KEGG
end # Bio

