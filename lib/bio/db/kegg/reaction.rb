#
# = bio/db/kegg/reaction.rb - KEGG REACTION database class
#
# Copyright::  Copyright (C) 2004 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/db'
require 'bio/db/kegg/common'
require 'enumerator'

module Bio
class KEGG

class REACTION < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  include PathwaysAsHash
  # Returns a Hash of the pathway ID and name in PATHWAY field.
  def pathways_as_hash; super; end if false #dummy for RDoc

  include OrthologsAsHash
  # Returns a Hash of the orthology ID and definition in ORTHOLOGY field.
  def orthologs_as_hash; super; end if false #dummy for RDoc

  # Creates a new Bio::KEGG::REACTION object.
  # ---
  # *Arguments*:
  # * (required) _entry_: (String) single entry as a string
  # *Returns*:: Bio::KEGG::REACTION object
  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # NAME
  def name
    field_fetch('NAME')
  end

  # DEFINITION
  def definition
    field_fetch('DEFINITION')
  end

  # EQUATION
  def equation
    field_fetch('EQUATION')
  end

  # RPAIR
  def rpairs
    unless @data['RPAIR']
      rps = []
      fetch('RPAIR').split(/\s+/).each_slice(4) do |rp|
        rps.push({"entry" => rp[1], "name" => rp[2], "type" => rp[3]})
      end
      @data['RPAIR'] = rps
    end
    @data['RPAIR']
  end

  # PATHWAY
  def pathways
    lines_fetch('PATHWAY')
  end

  # ENZYME
  def enzymes
    unless @data['ENZYME']
      @data['ENZYME'] = fetch('ENZYME').scan(/\S+/)
    end
    @data['ENZYME']
  end

  # ORTHOLOGY
  def orthologs
    lines_fetch('ORTHOLOGY')
  end

end # REACTION

end # KEGG
end # Bio

