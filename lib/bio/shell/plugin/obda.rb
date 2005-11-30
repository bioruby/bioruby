#
# = bio/shell/plugin/obda.rb - plugin for OBDA
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	LGPL
#
# $Id: obda.rb,v 1.8 2005/11/30 02:01:04 k Exp $
#
#--
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
#++
#

module Bio::Shell

  private

  def obda
    @obda ||= Bio::Registry.new
  end

  def obdaentry(dbname, entry_id)
    db = obda.get_database(dbname)
    unless db
      warn "Error: No such database (#{dbname})"
      return
    end
    entry = db.get_by_id(entry_id)
    if block_given?
      yield entry
    else
      return entry
    end
  end

  def obdadbs
    result = obda.databases.map {|db| db.database}
    return result
  end

  def biofetch(db, id, style = 'raw', format = 'default')
    serv = Bio::Fetch.new("http://www.ebi.ac.uk/cgi-bin/dbfetch")
    result = serv.fetch(db, id, style, format)
    return result
  end

end

