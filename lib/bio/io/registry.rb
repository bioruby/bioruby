#
# bio/io/registry.rb - BioDirectory Registry module
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
#  $Id: registry.rb,v 1.3 2002/03/04 08:20:16 katayama Exp $
#

require 'net/http'
require 'bio/io/sql'
require 'bio/io/fetch'
#require 'bio/io/flatfile'
#require 'bio/io/bdb'
#require 'bio/io/xembl'
#require 'bio/io/corba'

module Bio

  class Registry

    def initialize(file = nil)
      @registry = Array.new

      read_local(file) if file
      read_local("#{ENV['HOME']}/.bioinformatics/seqdatabase.ini")
      read_local("/etc/bioinformatics/seqdatabase.ini")

      read_remote if @registry.empty?
    end

    def get_database(dbname)
      @registry.each do |db|
	if db.database == dbname
	  case db.protocol
	  when 'biofetch'
	    return serv_biofetch(db)
	  when 'biosql'
	    return serv_biosql(db)
	  when 'bsane-corba'
	  when 'index-berkeleydb'
	  when 'index-flat'
	  when 'xembl'
	  end
	end
      end
    end
    alias db get_database

    def query(dbname)
      @registry.each do |db|
	return db if db.database == dbname
      end
    end

    private

    def read_local(file)
      if File.readable?(file)
	stanza = File.open(file).read
	parse(stanza)
      end
    end

    def read_remote(host='www.open-bio.org', path='/registry/seqdatabase.ini')
      Net::HTTP.start(host, 80) do |http|
	response, = http.get(path)
	parse(response.body)
      end
    end

    def parse(stanza)
      stanza.each_line do |line|
	case line
	when /^\[(.*)\]/
	  db = Bio::Registry::DB.new($1)
	  @registry.push(db)
	when /=/
	  tag, value = line.chomp.split(/\s*=\s*/)
	  @registry.last[tag] = value
	end
      end
    end

    def serv_biofetch(db)
      serv = Bio::Fetch.new(db.location)
      serv.database = db.biodbname
      return serv
    end

    def serv_biosql(db)
      case db.driver
      when /mysql/i
	driver = 'Mysql'
      when /pg|postgres/i
	driver = 'Pg'
      end

      dbi = [ "dbi", driver, db.dbname, db.location ].compact.join(':')
      dbi += ';port=' + db.port if db.port
      serv = Bio::SQL.new(dbi, db.user, db.pass)

      # We can not manage biodbname (for name space) in BioSQL yet.
      #db.biodbname

      return serv
    end


    class DB

      def initialize(dbname)
	@database = dbname
	@property = Hash.new
      end
      attr_reader :database

      def method_missing(meth_id)
	@property[meth_id.id2name]
      end

      def []=(tag, value)
	@property[tag] = value
      end

    end

  end

end



if __FILE__ == $0

  require 'pp'

  if ARGV[0]
    reg = Bio::Registry.new(ARGV[0])	# Usually, you don't need to pass ARGV.
  else
    reg = Bio::Registry.new
  end

  pp reg

  pp reg.query('embl_biosql')

  serv = reg.get_database('embl_biosql')
  puts serv.get_by_id('AB000098')

#  serv = reg.get_database('embl_postgres')
#  puts serv.get_by_id('AB000098')

  serv = reg.get_database('swissprot_biofetch')
  puts serv.get_by_id('CYC_BOVIN')

end


=begin

= Bio::Registry

--- Bio::Registry.new(file = nil)

--- Bio::Registry#get_database(dbname), db(dbname)

      Returns dababase handle (i.e. Bio::SQL, Bio::Fetch etc.) and they should
      have get_by_id method.

--- Bio::Registry#query(dbname)

      Returns a Registry::DB object corresponding to the first dbname entry
      in the registry records.

== Bio::Registry::DB

--- Bio::Registry::DB.new(dbname)

--- Bio::Registry::DB#database

== SEE ALSO

  http://www.open-bio.org/registry/seqdatabase.ini

=end

