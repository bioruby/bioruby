#
# bio/db/kegg/compound.rb - KEGG/COMPOUND database class
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
#  $Id: compound.rb,v 0.1 2001/06/25 07:13:32 katayama Exp $
#

require 'bio/db'

class COMPOUND < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # ENTRY
  # NAME
  # FORMULA
  # PATHWAY
  # ENZYME
  # DBLINKS

end
