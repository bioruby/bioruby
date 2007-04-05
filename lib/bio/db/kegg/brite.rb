#
# = bio/db/kegg/brite.rb - KEGG/BRITE database class
#
# Copyright::  Copyright (C) 2001 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: brite.rb,v 0.8 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/db'

module Bio
class KEGG

# == Note
#
# This class is not completely implemented, but obsolete as the original
# database BRITE has changed it's meaning.
#
class BRITE < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  # DEFINITION
  # RELATION
  # FACTORS
  # INTERACTION
  # SOURCE
  # REFERENCE

end # BRITE

end # KEGG
end # Bio

