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
#  $Id: brdb.rb,v 1.1 2001/12/19 12:20:19 katayama Exp $
#

begin
  require 'mysql'
rescue LoadError
  module Bio; class BRDB; end; end
end

module Bio

  class BRDB

    def initialize(host = 'db.bioruby.org', user = 'bioruby',
		   passwd = nil, db = 'brdb', *args)
      @brdb = Mysql.new(host, user, passwd, db, *args)
    end

    def close
      @brdb.close
    end

    def self.get(*args)
      db = self.new
      db.get(*args)
    end

    def get(db_table, entry_id)
      query = "select * from #{db_table} where id = \'#{entry_id}\'"
      @brdb.query(query).fetch_hash
    end

    def insert(db_table, ary)
      values = ary.map {|x| '"' + x + '"'}.join(",")
      query = "insert into #{db_table} values (#{values});"
      @brdb.query(query)
    end

    def update(db_table, entry_id, hash)
      values = []
      hash.each do |k,v|
	val = Mysql.quote(v)
	values.push("#{k}='#{val}'")
      end
      values = values.join(',')
      query = "update #{db_table} set #{values} where id = #{entry_id}"
      @brdb.query(query)
    end

  end

end


if __FILE__ == $0
end


=begin

= Bio::BRDB

--- Bio::BRDB.new(*args)

      The arguments are passed through to the Mysql.new(host=nil, user=nil,
      passwd=nil, db=nil, port=nil, sock=nil, flag=nil).

--- Bio::BRDB.close

--- Bio::BRDB.get(db_table, entry_id)
--- Bio::BRDB#get(db_table, entry_id)
--- Bio::BRDB#insert(db_table, ary)
--- Bio::BRDB#update(db_table, hash)

=end
