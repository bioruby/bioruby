#
# = bio/db/kegg/module.rb - KEGG MODULE database class
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
# Bio::KEGG::MODULE is a parser class for the KEGG MODULE database entry.
#
# == References
#
# * http://www.kegg.jp/kegg-bin/get_htext?ko00002.keg
# * ftp://ftp.genome.jp/pub/kegg/pathway/module
#
class MODULE < KEGGDB

  DELIMITER = RS = "\n///\n"
  TAGSIZE = 12

  # Creates a new Bio::KEGG::MODULE object.
  # ---
  # *Arguments*:
  # * (required) _entry_: (String) single entry as a string
  # *Returns*:: Bio::KEGG::MODULE object
  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # Return the ID, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # Name of the module, described in the NAME line.
  # ---
  # *Returns*:: String
  def name
    field_fetch('NAME')
  end

  # Name of the KEGG class, described in the CLASS line.
  # ---
  # *Returns*:: String
  def keggclass
    field_fetch('CLASS')
  end

  # Returns PATHWAY field of the entry.
  def pathway
    field_fetch('PATHWAY')
  end

  # Returns MODULE field of the entry.
  def orthologies
    lines_fetch('ORTHOLOGY')
  end

  # Returns REACTION field of the entry.
  def reactions
    lines_fetch('REACTION')
  end

  # Returns COMPOUND field of the entry.
  def compounds
    lines_fetch('COMPOUND')
  end

end # MODULE

end # KEGG
end # Bio
