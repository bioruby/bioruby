#
# = bio/db/kegg/enzyme.rb - KEGG/ENZYME database class
#
# Copyright::  Copyright (C) 2001, 2002 Toshiaki Katayama <k@bioruby.org>
# License::    Ruby's
#
# $Id: enzyme.rb,v 0.9 2006/09/19 05:52:05 k Exp $
#

require 'bio/db'

module Bio
class KEGG

class ENZYME < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  def entry_id
    field_fetch('ENTRY')
  end

  # NAME
  def names
    lines_fetch('NAME')
  end
  def name
    names[0]
  end

  # CLASS
  def classes
    lines_fetch('CLASS')
  end

  # SYSNAME
  def sysname
    field_fetch('SYSNAME')
  end

  # REACTION ';'
  def reaction
    field_fetch('REACTION')
  end
  
  # SUBSTRATE
  def substrates
    lines_fetch('SUBSTRATE')
  end

  # PRODUCT
  def products
    lines_fetch('PRODUCT')
  end

  # COFACTOR
  def cofactors
    lines_fetch('COFACTOR')
  end

  # COMMENT
  def comment
    field_fetch('COMMENT')
  end

  # PATHWAY
  def pathways
    lines_fetch('PATHWAY')
  end

  # GENES
  def genes
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
      @data['STRUCTURES'] =
        fetch('STRUCTURES').sub(/(PDB: )*/,'').split(/\s+/)
    end
    @data['STRUCTURES']
  end

  # DBLINKS
  def dblinks
    lines_fetch('DBLINKS')
  end

end # ENZYME

end # KEGG
end # Bio

