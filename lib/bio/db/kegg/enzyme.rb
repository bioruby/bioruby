#
# bio/db/kegg/enzyme.rb - KEGG/ENZYME database class
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
#  $Id: enzyme.rb,v 0.3 2001/10/24 02:45:32 katayama Exp $
#

module Bio

require 'bio/db'

class KEGG

class ENZYME < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  # NAME
  # CLASS
  # SYSNAME
  # REACTION ';'
  # SUBSTRATE
  # PRODUCT
  # COFACTOR
  # COMMENT
  # PATHWAY
  # GENES
  # DISEASE
  # MOTIF
  # STRUCTURES
  # DBLINKS

end

end				# class KEGG

end				# module Bio

