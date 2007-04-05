#
# = bio/io/registry.rb - OBDA BioRegistry module
#
# Copyright::   Copyright (C) 2002, 2003, 2004, 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: registry.rb,v 1.19 2007/04/05 23:35:41 trevor Exp $
#
# == Description
#
# BioRegistry read the OBDA (Open Bio Database Access) configuration file
# (seqdatabase.ini) and create a registry object.  OBDA is created during
# the BioHackathon held in Tucson and South Africa in 2002 as a project
# independent set of protocols to access biological databases.  The spec
# is refined in the BioHackathon 2003 held in Singapore.
#
# By using the OBDA, user can access to the database by get_database method
# without knowing where and how the database is stored, and each database
# has the get_by_id method to obtain a sequence entry.
#
# Sample configuration file is distributed with BioRuby package which
# consists of stanza format entries as following:
#
#   VERSION=1.00
#
#   [myembl]
#   protocol=biofetch
#   location=http://www.ebi.ac.uk/cgi-bin/dbfetch
#   dbname=embl
#
#   [mysp]
#   protocol=biosql
#   location=db.bioruby.org
#   dbname=biosql
#   driver=mysql
#   user=root
#   pass= 
#   biodbname=swissprot
#
# The first line means that this configration file is version 1.00.
#
# The [myembl] line defines a user defined database name 'myembl' and
# following block indicates how the database can be accessed.
# In this example, the 'myembl' database is accecced via the OBDA's
# BioFetch protocol to the dbfetch server at EBI, where the EMBL
# database is accessed by the name 'embl' on the server side.
#
# The [mysp] line defines another database 'mysp' which accesses the
# RDB (Relational Database) at the db.bioruby.org via the OBDA's
# BioSQL protocol.  This BioSQL server is running MySQL database as
# its backend and stores the SwissProt database by the name 'swissprot'
# and which can be accessed by 'root' user without password.
# Note that the db.bioruby.org server is a dummy for the explanation.
#
# The configuration file is searched by the following order.
#
# 1. Local file name given to the Bio::Registry.new(filename).
#
# 2. Remote or local file list given by the environmenetal variable
#    'OBDA_SEARCH_PATH', which is a '+' separated string of the
#    remote (HTTP) and/or local files.
#
#      e.g. OBDA_SEARCH_PATH="http://example.org/obda.ini+$HOME/lib/myobda.ini"
#
# 3. Local file "$HOME/.bioinformatics/seqdatabase.ini" in the user's
#    home directory.
#
# 4. Local file "/etc/bioinformatics/seqdatabase.ini" in the system
#    configuration directry.
#
# All these configuration files are loaded.  If there are database
# definitions having the same name, the first one is used.
#
# If none of these files can be found, Bio::Registry.new will try
# to use http://www.open-bio.org/registry/seqdatabase.ini file.
#
# == References
# 
# * http://obda.open-bio.org/
# * http://cvs.open-bio.org/cgi-bin/viewcvs/viewcvs.cgi/obda-specs/?cvsroot=obf-common
# * http://www.open-bio.org/registry/seqdatabase.ini
#

require 'uri'
require 'net/http'
require 'bio/command'


module Bio

autoload :Fetch,          'bio/io/fetch'
autoload :SQL,            'bio/io/sql'
autoload :FlatFile,       'bio/io/flatfile'
autoload :FlatFileIndex,  'bio/io/flatfile/index'

class Registry

  def initialize(file = nil)
    @spec_version = nil
    @databases = Array.new
    read_local(file) if file
    env_path = ENV['OBDA_SEARCH_PATH']
    if env_path and env_path.size > 0
      read_env(env_path)
    else
      read_local("#{ENV['HOME']}/.bioinformatics/seqdatabase.ini")
      read_local("/etc/bioinformatics/seqdatabase.ini")
      if @databases.empty?
        read_remote("http://www.open-bio.org/registry/seqdatabase.ini")
      end
    end
  end

  # Version string of the first configulation file
  attr_reader :spec_version

  # List of databases (Array of Bio::Registry::DB)
  attr_reader :databases

  # Returns a dababase handle (Bio::SQL, Bio::Fetch etc.) or nil
  # if not found (case insensitive).
  # The handles should have get_by_id method.
  def get_database(dbname)
    @databases.each do |db|
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
  alias db get_database

  # Returns a Registry::DB object corresponding to the first dbname
  # entry in the registry records (case insensitive).
  def query(dbname)
    @databases.each do |db|
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
      stanza = File.read(file)
      parse_stanza(stanza)
    end
  end

  def read_remote(url)
    schema, user, host, port, reg, path, = URI.split(url)
    Bio::Command.start_http(host, port) do |http|
      response, = http.get(path)
      parse_stanza(response.body)
    end
  end

  def parse_stanza(stanza)
    return unless stanza
    if stanza[/.*/] =~ /VERSION\s*=\s*(\S+)/
      @spec_version ||= $1	# for internal use (may differ on each file)
      stanza[/.*/] = ''	        # remove VERSION line
    end
    stanza.each_line do |line|
      case line
      when /^\[(.*)\]/
        dbname = $1.downcase
        db = Bio::Registry::DB.new($1)
        @databases.push(db)
      when /=/
        tag, value = line.chomp.split(/\s*=\s*/)
        @databases.last[tag] = value
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

end # class Registry

end # module Bio



if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
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


