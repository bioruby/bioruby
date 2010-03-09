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
  # ---
  # *Returns*:: Array containing String objects
  def pathway_modules_as_strings
    lines_fetch('MODULE')
  end

  # Returns MODULE field as a Hash. Each key of the hash is Pathway Module ID,
  # and each value is the name of the Pathway Module.
  # ---
  # *Returns*:: Hash
  def pathway_modules_as_hash
    unless defined? @pathway_modules_s_as_hash then
      hash = {}
      pathway_modules_as_strings.each do |line|
        entry_id, name = line.split(/\s+/, 2)
        hash[entry_id] = name
      end
      @pathway_modules_as_hash = hash
    end
    @pathway_modules_as_hash
  end
  alias pathway_modules pathway_modules_as_hash

  # Returns REL_PATHWAY field of the entry.
  # ---
  # *Returns*:: Array containing String objects
  def rel_pathways_as_strings
    lines_fetch('REL_PATHWAY')
  end

  # Returns REL_PATHWAY field as a Hash. Each key of the hash is
  # Pathway ID, and each value is the name of the pathway.
  # ---
  # *Returns*:: Hash
  def rel_pathways_as_hash
    unless defined? @rel_pathways_as_hash then
      hash = {}
      rel_pathways_as_strings.each do |line|
        entry_id, name = line.split(/\s+/, 2)
        hash[entry_id] = name
      end
      @rel_pathways_as_hash = hash
    end
    @rel_pathways_as_hash
  end
  alias rel_pathways rel_pathways_as_hash

end # PATHWAY

end # KEGG
end # Bio
