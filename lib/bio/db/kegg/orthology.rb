#
# = bio/db/kegg/orthology.rb - KEGG ORTHOLOGY database class
#
# Copyright::  Copyright (C) 2003-2007 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2003 Masumi Itoh <m@bioruby.org>
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
# KO (KEGG Orthology) entry parser.
#
# == References
#
# * http://www.genome.jp/dbget-bin/get_htext?KO
# * ftp://ftp.genome.jp/pub/kegg/genes/ko
#
class ORTHOLOGY < KEGGDB
  
  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  include Common::DblinksAsHash
  # Returns a Hash of the DB name and an Array of entry IDs in DBLINKS field.
  def dblinks_as_hash; super; end if false #dummy for RDoc
  alias dblinks dblinks_as_hash

  include Common::GenesAsHash
  # Returns a Hash of the organism ID and an Array of entry IDs in GENES field.
  def genes_as_hash; super; end if false #dummy for RDoc
  alias genes genes_as_hash

  # Reads a flat file format entry of the KO database.
  def initialize(entry)
    super(entry, TAGSIZE)
  end
  
  # Returns ID of the entry.
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # Returns NAME field of the entry.
  def name
    field_fetch('NAME')
  end

  # Returns an Array of names in NAME field.
  def names
    name.split(', ')
  end

  # Returns DEFINITION field of the entry.
  def definition
    field_fetch('DEFINITION')
  end

  # Returns CLASS field of the entry.
  def keggclass
    field_fetch('CLASS')
  end

  # Returns an Array of biological classes in CLASS field.
  def keggclasses
    keggclass.gsub(/ \[[^\]]+/, '').split(/\] ?/)
  end

  # Returns an Array of KEGG/PATHWAY ID in CLASS field.
  def pathways
    keggclass.scan(/\[PATH:(.*?)\]/).flatten
  end
  
  # Returns an Array of a database name and entry IDs in DBLINKS field.
  def dblinks_as_strings
    lines_fetch('DBLINKS')
  end

  # Returns an Array of the organism ID and entry IDs in GENES field.
  def genes_as_strings
    lines_fetch('GENES')
  end

end # ORTHOLOGY
    
end # KEGG
end # Bio


