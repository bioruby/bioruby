#
# bio/io/brdb.rb - BioRuby-DB access module
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
#  $Id: brdb.rb,v 1.2 2002/06/26 00:12:29 k Exp $
#

begin
  require 'dbi'
rescue LoadError
end

module Bio

  class BRDB

    def initialize(*args)
      @brdb = args
    end

    def fetch(db_table, entry_id)
      DBI.connect(*@brdb) do |dbh|
	query = "select * from #{db_table} where id = ?"
	dbh.execute(query, entry_id).fetch_all
      end
    end

    def insert(db_table, values)
      if values.is_a?(Array)
	values = values.map{ |x| '"' + DBI.quote(x) + '"' }.join(",")
      end
      DBI.connect(*@brdb) do |dbh|
	query = "insert into #{db_table} values (?);"
	dbh.execute(query, values)
      end
    end

    def update(db_table, entry_id, values)
      if values.is_a?(Hash)
	values = values.to_a.map{ |k, v| "#{k}='#{DBI.quote(v)}'" }.join(',')
      end
      DBI.connect(*@brdb) do |dbh|
	query = "update #{db_table} set ? where id = ?"
	dbh.execute(query, values, entry_id)
      end
    end

    def search(db_table, field, keyword)
    end

  end

end


if __FILE__ == $0
  begin
    require 'pp'
    alias :p :pp
  rescue LoadError
  end

  db    = 'dbi:Mysql:host=db.bioruby.org;database=genbank'
  user  = 'root'

  serv = Bio::BRDB.new(db, user)

  serv.fetch('ent', 'AA2CG').each do |row|
    p row.to_h
  end
  serv.fetch('ft', 'AA2CG').each do |row|
    p row.to_h
  end
end


=begin

= Bio::BRDB

--- Bio::BRDB.new(*args)

--- Bio::BRDB#close
--- Bio::BRDB#fetch(db_table, entry_id)
--- Bio::BRDB#update(db_table, entry_id, hash)
--- Bio::BRDB#insert(db_table, ary)

=end
