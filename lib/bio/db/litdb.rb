#
# bio/db/litdb.rb - LITDB database class
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: litdb.rb,v 0.3 2001/11/06 16:58:52 okuji Exp $
#

module Bio

require 'bio/db'

class LITDB < NCBIDB

  DELIMITER	= RS = "\nEND\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # CODE
  def id
    field_fetch('CODE')
  end

  # TITLE
  def title
    field_fetch('TITLE')
  end

  # FIELD
  def field
    field_fetch('FIELD')
  end

  # JOURNAL
  def journal
    field_fetch('JOURNAL')
  end

  # VOLUME
  def journal
    field_fetch('VOLUME')
  end

  # KEYWORD ';;'
  def journal
    unless @data['KEYWORD']
      @data['KEYWORD'] = fetch('KEYWORD').split(/;;\s*/)
    end
    @data['KEYWORD']
  end

  # AUTHOR
  def journal
    field_fetch('AUTHOR')
  end

end

end				# module Bio

