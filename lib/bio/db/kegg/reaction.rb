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

  include Common::PathwaysAsHash
  # Returns a Hash of the pathway ID and name in PATHWAY field.
  def pathways_as_hash; super; end if false #dummy for RDoc
  alias pathways pathways_as_hash

  include Common::OrthologsAsHash
  # Returns a Hash of the orthology ID and definition in ORTHOLOGY field.
  def orthologs_as_hash; super; end if false #dummy for RDoc
  alias orthologs orthologs_as_hash

  # Creates a new Bio::KEGG::REACTION object.
  # ---
  # *Arguments*:
  # * (required) _entry_: (String) single entry as a string
  # *Returns*:: Bio::KEGG::REACTION object
  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ID of the entry, described in the ENTRY line.
  # ---
  # *Returns*:: String
  def entry_id
    field_fetch('ENTRY')[/\S+/]
  end

  # Name of the reaction, described in the NAME line.
  # ---
  # *Returns*:: String
  def name
    field_fetch('NAME')
  end

  # Definition of the reaction, described in the DEFINITION line.
  # ---
  # *Returns*:: String
  def definition
    field_fetch('DEFINITION')
  end

  # Chemical equation, described in the EQUATION line.
  # ---
  # *Returns*:: String
  def equation
    field_fetch('EQUATION')
  end

  # KEGG RPAIR (ReactantPair) information, described in the RPAIR lines.
  # ---
  # *Returns*:: Array containing String
  def rpairs_as_strings
    lines_fetch('RPAIR')
  end

  # KEGG RPAIR (ReactantPair) information, described in the RPAIR lines.
  # Returns a hash of RPair IDs and [ name, type ] informations, for example,
  #   { "RP12733" => [ "C00022_C00900", "trans" ],
  #     "RP05698" => [ "C00011_C00022", "leave" ],
  #     "RP00440" => [ "C00022_C00900", "main" ]
  #   }
  # ---
  # *Returns*:: Hash
  def rpairs_as_hash
    unless defined? @rpairs_as_hash
      rps = {}
      rpairs_as_strings.each do |line|
        _, entry_id, name, rptype = line.split(/\s+/)
        rps[entry_id] = [ name, rptype ]
      end
      @rpairs_as_hash = rps
    end
    @rpairs_as_hash
  end

  alias rpairs rpairs_as_hash

  # Returns the content of the RPAIR entry as tokens
  # (RPair signature, RPair ID, , RPair type).
  # ---
  # *Returns*:: Array containing String
  def rpairs_as_tokens
    fetch('RPAIR').split(/\s+/)
  end

  # Pathway information, described in the PATHWAY lines.
  # ---
  # *Returns*:: Array containing String
  def pathways_as_strings
    lines_fetch('PATHWAY')
  end

  # Enzymes described in the ENZYME line.
  # ---
  # *Returns*:: Array containing String
  def enzymes
    unless @data['ENZYME']
      @data['ENZYME'] = fetch('ENZYME').scan(/\S+/)
    end
    @data['ENZYME']
  end

  # Orthologs described in the ORTHOLOGY lines.
  # ---
  # *Returns*:: Array containing String
  def orthologs_as_strings
    lines_fetch('ORTHOLOGY')
  end

end # REACTION

end # KEGG
end # Bio

