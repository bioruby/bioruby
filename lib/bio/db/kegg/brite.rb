#
# bio/db/kegg/brite.rb - KEGG/BRITE database class
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: brite.rb,v 0.2 2001/10/17 14:43:11 katayama Exp $
#

module Bio

require 'bio/db'

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

end

end				# module Bio

