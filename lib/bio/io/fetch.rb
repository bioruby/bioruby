#
# bio/io/biofetch.rb - BioFetch access module
#
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: fetch.rb,v 1.2 2004/02/21 19:40:34 k Exp $
#

require 'uri'
require 'net/http'

module Bio

  class Fetch

    def initialize(url = 'http://bioruby.org/cgi-bin/biofetch.rb')
      schema, user, @host, @port, reg, @path, = URI.split(url)
    end
    attr_accessor :database

    def get_by_id(id)
      fetch(@database, id)
    end

    def fetch(db, id, style = 'raw', format = nil)
      data = [ "db=#{db}", "id=#{id}", "style=#{style}" ]
      data.push("format=#{format}") if format
      data = data.join('&')

      responce, result = Net::HTTP.new(@host, @port).post(@path, data)
      return result
    end

    def self.query(*args)
      self.new.fetch(*args)
    end

  end

end



if __FILE__ == $0

# bfserv = Bio::Fetch.new('http://www.ebi.ac.uk:80/cgi-bin/dbfetch')
  bfserv = Bio::Fetch.new('http://www.ebi.ac.uk/cgi-bin/dbfetch')
  puts "# test 1"
  puts bfserv.fetch('embl', 'J00231', 'raw')
  puts "# test 2"
  puts bfserv.fetch('embl', 'J00231', 'html')

  puts "# test 3"
  puts Bio::Fetch.query('genbank', 'J00231')
  puts "# test 4"
  puts Bio::Fetch.query('genbank', 'J00231', 'raw', 'fasta')

end


=begin

= Bio::Fetch

--- Bio::Fetch.new(url = 'http://bioruby.org/cgi-bin/biofetch.rb')

      Use Bio::Fetch.new('http://www.ebi.ac.uk/cgi-bin/dbfetch') to connect
      to EBI BioFetch server.

--- Bio::Fetch#fetch(db, id, style = 'raw', format = nil)

      Fetch a database entry as specified by database (db), entry id (id),
      'raw' text or 'html' (style), and format.  When using BioRuby's
      BioFetch server, value for the format should not be set.

--- Bio::Fetch#database=(dbname)

      Set default database to dbname (prepare for get_by_id).

--- Bio::Fetch#get_by_id(id)

      Get raw database entry by id (mainly used by Bio::Registry).

--- Bio::Fetch.query(db, id, style = 'raw', format = nil)

      Short cut for using BioRuby's BioFetch server.  You can fetch an entry
      without creating instance of BioFetch server.

=end

