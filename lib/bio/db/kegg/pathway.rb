#
# = bio/db/kegg/pathway.rb - KEGG PATHWAY database class
#
# Copyright::  Copyright (C) 2010 Kozo Nishida <kozo-ni@is.naist.jp>
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
# Bio::KEGG::PATHWAY is a parser class for the KEGG PATHWAY database entry.
#
# == References
#
# * http://www.genome.jp/kegg/pathway.html
# * ftp://ftp.genome.jp/pub/kegg/pathway/pathway
#
class PATHWAY < KEGGDB

  DELIMITER = RS = "\n///\n"
  TAGSIZE = 12

  # Creates a new Bio::KEGG::PATHWAY object.
  # ---
  # *Arguments*:
  # * (required) _entry_: (String) single entry as a string
  # *Returns*:: Bio::KEGG::PATHWAY object
  def initialize(entry)
   	super(entry, TAGSIZE)
  end

  # Return the ID of the pathway, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # Return the name of the pathway, described in the NAME line.
  # ---
  # *Returns*:: String
  def name
   	field_fetch('NAME')
  end

  # Return the name of the KEGG class, described in the CLASS line.
  # ---
  # *Returns*:: String
  def keggclass
    field_fetch('CLASS')
  end

  # Returns MODULE field of the entry.
  def keggmodules
    lines_fetch('MODULE')
  end

  # Returns REL_PATHWAY field of the entry.
  def rel_pathways
    lines_fetch('REL_PATHWAY')
  end

end # PATHWAY

end # KEGG
end # Bio
