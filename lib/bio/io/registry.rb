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
#  $Id: registry.rb,v 1.12 2004/02/15 01:44:02 k Exp $
#

require 'uri'
require 'net/http'
require 'bio/io/sql'
require 'bio/io/fetch'
require 'bio/io/flatfile/index'
require 'bio/io/flatfile/bdb'
#require 'bio/io/corba'
#require 'bio/io/xembl'

module Bio

  class Registry

    def initialize(file = nil)
      @registry = Array.new
      read_local(file) if file
      env_path = ENV['OBDA_SEARCH_PATH']
      if env_path and env_path.size > 0
	read_env(env_path)
      else
	read_local("#{ENV['HOME']}/.bioinformatics/seqdatabase.ini")
	read_local("/etc/bioinformatics/seqdatabase.ini")
	if @registry.empty?
	  read_remote("http://www.open-bio.org/registry/seqdatabase.ini")
	end
      end
    end

    def get_database(dbname)
      @registry.each do |db|
	if db.database == dbname.downcase
	  case db.protocol
	  when 'biofetch'
	    return serv_biofetch(db)
	  when 'biosql'
	    return serv_biosql(db)
	  when 'flat', 'index-flat', 'index-berkeleydb'
	    return serv_flat(db)
	  when 'bsane-corba', 'biocorba'
	    raise NotImplementedError
	  when 'xembl'
	    raise NotImplementedError
	  end
	end
      end
      return nil
    end
    alias :db :get_database

    def query(dbname)
      @registry.each do |db|
	return db if db.database == dbname.downcase
      end
    end

    private

    def read_env(path)
      path.split('+').each do |elem|
	if /:/.match(elem)
	  read_remote(elem)
	else
	  read_local(elem)
	end
      end
    end

    def read_local(file)
      if File.readable?(file)
	stanza = File.open(file).read
	parse_stanza(stanza)
      end
    end

    def read_remote(url)
      schema, user, host, port, reg, path, = URI.split(url)
      Net::HTTP.start(host, port) do |http|
	response, = http.get(path)
	parse_stanza(response.body)
      end
    end

    def parse_stanza(stanza)
      return unless stanza
      if stanza[/.*/] =~ /VERSION\s*=\s*(\S+)/
	@spec_version = $1	# for internal use (may differ on each file)
	stanza[/.*/] = ''	# remove VERSION line
      end
      stanza.each_line do |line|
	case line
	when /^\[(.*)\]/
          dbname = $1.downcase
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
      serv.database = db.dbname
      return serv
    end

    def serv_biosql(db)
      location, port = db.location.split(':')
      port = db.port unless port

      case db.driver
      when /mysql/i
	driver = 'Mysql'
      when /pg|postgres/i
	driver = 'Pg'
      when /oracle/
      when /sybase/
      when /sqlserver/
      when /access/
      when /csv/
      when /informix/
      when /odbc/
      when /rdb/
      end

      dbi = [ "dbi", driver, db.dbname, location ].compact.join(':')
      dbi += ';port=' + port if port
      serv = Bio::SQL.new(dbi, db.user, db.pass)

      # We can not manage biodbname (for name space) in BioSQL yet.
      # use db.biodbname here!!

      return serv
    end

    def serv_flat(db)
      path = db.location
      path = File.join(path, db.dbname) if db.dbname
      serv = Bio::FlatFileIndex.open(path)
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
  begin
    require 'pp'
    alias :p :pp
  rescue
  end

  # Usually, you don't need to pass ARGV.
  reg = Bio::Registry.new(ARGV[0])

  p reg
  p reg.query('genbank_biosql')

  serv = reg.get_database('genbank_biofetch')
  puts serv.get_by_id('AA2CG')

  serv = reg.get_database('genbank_biosql')
  puts serv.get_by_id('AA2CG')

  serv = reg.get_database('swissprot_biofetch')
  puts serv.get_by_id('CYC_BOVIN')

  serv = reg.get_database('swissprot_biosql')
  puts serv.get_by_id('CYC_BOVIN')
end


=begin

= Bio::Registry

--- Bio::Registry.new(file = nil)

--- Bio::Registry#get_database(dbname)
--- Bio::Registry#db(dbname)

      Returns a dababase handle (Bio::SQL, Bio::Fetch etc.) or nil
      if not found (case insensitive).
      The handles should have get_by_id method.

--- Bio::Registry#query(dbname)

      Returns a Registry::DB object corresponding to the first dbname
      entry in the registry records (case insensitive).

== Bio::Registry::DB

--- Bio::Registry::DB.new(dbname)

--- Bio::Registry::DB#database

== SEE ALSO

* ((<URL:http://obda.open-bio.org/>))
* ((<URL:http://cvs.open-bio.org/cgi-bin/viewcvs/viewcvs.cgi/obda-specs/?cvsroot=obf-common>))
* ((<URL:http://www.open-bio.org/registry/seqdatabase.ini>))

=end

