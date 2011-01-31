#
# = bio/db/kegg/enzyme.rb - KEGG/ENZYME database class
#
# Copyright::  Copyright (C) 2001, 2002, 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'
require 'bio/db/kegg/common'

module Bio
class KEGG

class ENZYME < KEGGDB

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

  include Common::OrthologsAsHash
  # Returns a Hash of the orthology ID and definition in ORTHOLOGY field.
  def orthologs_as_hash; super; end if false #dummy for RDoc
  alias orthologs orthologs_as_hash

  include Common::GenesAsHash
  # Returns a Hash of the organism ID and an Array of entry IDs in GENES field.
  def genes_as_hash; super; end if false #dummy for RDoc
  alias genes genes_as_hash

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  def entry
    field_fetch('ENTRY')
  end

  def entry_id
    entry[/EC (\S+)/, 1]
  end

  def obsolete?
    entry[/Obsolete/] ? true : false
  end

  # NAME
  def names
    field_fetch('NAME').split(/\s*;\s*/)
  end

  def name
    names.first
  end

  # CLASS
  def classes
    lines_fetch('CLASS')
  end

  # SYSNAME
  def sysname
    field_fetch('SYSNAME')
  end

  # REACTION
  def reaction
    field_fetch('REACTION')
  end

  # ALL_REAC ';'
  def all_reac
    field_fetch('ALL_REAC')
  end

  def iubmb_reactions
    all_reac.sub(/;\s*\(other\).*/, '').split(/\s*;\s*/)
  end

  def kegg_reactions
    reac = all_reac
    if reac[/\(other\)/]
      reac.sub(/.*\(other\)\s*/, '').split(/\s*;\s*/)
    else
      []
    end
  end
  
  # SUBSTRATE
  def substrates
    field_fetch('SUBSTRATE').split(/\s*;\s*/)
  end

  # PRODUCT
  def products
    field_fetch('PRODUCT').split(/\s*;\s*/)
  end

  # INHIBITOR
  def inhibitors
    field_fetch('INHIBITOR').split(/\s*;\s*/)
  end

  # COFACTOR
  def cofactors
    field_fetch('COFACTOR').split(/\s*;\s*/)
  end

  # COMMENT
  def comment
    field_fetch('COMMENT')
  end

  # PATHWAY
  def pathways_as_strings
    lines_fetch('PATHWAY')
  end

  # ORTHOLOGY
  def orthologs_as_strings
    lines_fetch('ORTHOLOGY')
  end

  # GENES
  def genes_as_strings
    lines_fetch('GENES')
  end

  # DISEASE
  def diseases
    lines_fetch('DISEASE')
  end

  # MOTIF
  def motifs
    lines_fetch('MOTIF')
  end

  # STRUCTURES
  def structures
    unless @data['STRUCTURES']
      @data['STRUCTURES'] = fetch('STRUCTURES').sub(/(PDB: )*/,'').split(/\s+/)
    end
    @data['STRUCTURES']
  end

  # REFERENCE

  # DBLINKS
  def dblinks_as_strings
    lines_fetch('DBLINKS')
  end

end # ENZYME

end # KEGG
end # Bio

