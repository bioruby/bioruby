#
# bio/db/kegg/cell.rb - KEGG/CELL database class
#
#   Copyright (C) 2001 KAWASHIMA Shuichi <s@bioruby.org>
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
#  $Id: cell.rb,v 1.2 2001/09/14 13:26:54 shuichi Exp $
#

require "bio/db"

class CELL < KEGGDB

  DELIMITER     = RS = "\n///\n"
  TAGSIZE       = 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  def ent
    field_fetch('ENTRY')
  end
  alias entry ent

  def definition
    field_fetch('DEFINITION')
  end
  alias def definition

  def org
    field_fetch('ORGANISM')
  end
  alias organism org 
  def mother
    field_fetch('MOTHER')
  end

  def daughter
    field_fetch('DAUGHTER').gsub(/ /, '').split(/,/)
  end

  def sister
    field_fetch('SISTER')
  end

  def fate
    field_fetch('CELL_FATE').gsub(/ /, '').split(/,/)
  end

  def contact
    field_fetch('CONTACT').gsub(/ /, '').split(/,/)
  end

  def expression
    field_fetch('EXPRESSION')
  end

  def fig
    field_fetch('FIGURE')
  end

  def ref
    field_fetch('REFERENCE')
  end

end

