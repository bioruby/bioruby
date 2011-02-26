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

  include Common::PathwaysAsHash
  # Returns a Hash of the pathway ID and name in PATHWAY field.
  def pathways_as_hash; super; end if false #dummy for RDoc
  alias pathways pathways_as_hash

  include Common::ModulesAsHash
  # Returns MODULE field as a Hash.
  # Each key of the hash is KEGG MODULE ID,
  # and each value is the name of the Pathway Module.
  # ---
  # *Returns*:: Hash
  def modules_as_hash; super; end if false #dummy for RDoc
  alias modules modules_as_hash

  include Common::References
  # REFERENCE -- Returns contents of the REFERENCE records as an Array of
  # Bio::Reference objects.
  # ---
  # *Returns*:: an Array containing Bio::Reference objects
  def references; super; end if false #dummy for RDoc

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

  # Pathways described in the PATHWAY field.
  # ---
  # *Returns*:: Array containing String
  def pathways_as_strings
    lines_fetch('PATHWAY')
  end

  # *OBSOLETE* Do not use this method.
  # Because KEGG ORTHOLOGY format is changed and PATHWAY field is added,
  # older "pathways" method is renamed and remain only for compatibility.
  # 
  # Returns an Array of KEGG/PATHWAY ID in CLASS field.
  def pathways_in_keggclass
    keggclass.scan(/\[PATH:(.*?)\]/).flatten
  end

  # Returns MODULE field of the entry.
  # ---
  # *Returns*:: Array containing String objects
  def modules_as_strings
    lines_fetch('MODULE')
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


