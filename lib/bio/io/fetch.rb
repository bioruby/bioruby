#
# = bio/io/biofetch.rb - BioFetch access module
#
# Copyright::	Copyright (C) 2002, 2005 Toshiaki Katayama <k@bioruby.org>,
#               Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
#  $Id: fetch.rb,v 1.10 2007/04/05 23:35:41 trevor Exp $
#
# == DESCRIPTION
#
# Using BioRuby BioFetch server
#
#   br_server = Bio::Fetch.new()
#   puts br_server.databases
#   puts br_server.formats('embl')
#   puts br_server.maxids
#
# Using EBI BioFetch server
#
#   ebi_server = Bio::Fetch.new('http://www.ebi.ac.uk/cgi-bin/dbfetch')
#   puts ebi_server.fetch('embl', 'J00231', 'raw')
#   puts ebi_server.fetch('embl', 'J00231', 'html')
#   puts Bio::Fetch.query('genbank', 'J00231')
#   puts Bio::Fetch.query('genbank', 'J00231', 'raw', 'fasta')
# 

require 'uri'
require 'bio/command'

module Bio
  # = DESCRIPTION
  # The Bio::Fetch class provides an interface to dbfetch servers. Given
  # a database name and an accession number, these servers return the associated
  # record. For example, for the embl database on the EBI, that would be a
  # nucleic or amino acid sequence.
  #
  # Possible dbfetch servers include:
  # * http://bioruby.org/cgi-bin/biofetch.rb (default)
  # * http://www.ebi.ac.uk/cgi-bin/dbfetch
  #
  # If you're behind a proxy server, be sure to set your HTTP_PROXY
  # environment variable accordingly.
  #
  # = USAGE
  #  require 'bio'
  #
  #  # Retrieve the sequence of accession number M33388 from the EMBL
  #  # database.
  #  server = Bio::Fetch.new()  #uses default server
  #  puts server.fetch('embl','M33388')
  #  
  #  # Do the same thing without creating a Bio::Fetch object. This method always
  #  # uses the default dbfetch server: http://bioruby.org/cgi-bin/biofetch.rb
  #  puts Bio::Fetch.query('embl','M33388')
  #
  #  # To know what databases are available on the bioruby dbfetch server:
  #  server = Bio::Fetch.new()
  #  puts server.databases
  #
  #  # Some databases provide their data in different formats (e.g. 'fasta',
  #  # 'genbank' or 'embl'). To check which formats are supported by a given
  #  # database:
  #  puts server.formats('embl')
  #
  class Fetch
  
    # Create a new Bio::Fetch server object that can subsequently be queried
    # using the Bio::Fetch#fetch method
    # ---
    # *Arguments*:
    # * _url_: URL of dbfetch server (default = 'http://bioruby.org/cgi-bin/biofetch.rb')
    # *Returns*:: Bio::Fetch object
    def initialize(url = 'http://bioruby.org/cgi-bin/biofetch.rb')
      @url = url
      schema, user, @host, @port, reg, @path, = URI.split(@url)
    end
  
    # The default database to query
    #--
    # This will be used by the get_by_id method
    #++
    attr_accessor :database
  
    # Get raw database entry by id. This method lets the Bio::Registry class
    # use Bio::Fetch objects.
    def get_by_id(id)
      fetch(@database, id)
    end
  
    # Fetch a database entry as specified by database (db), entry id (id),
    # 'raw' text or 'html' (style), and format.  When using BioRuby's
    # BioFetch server, value for the format should not be set.
    # Examples:
    #   server = Bio::Fetch.new('http://www.ebi.ac.uk/cgi-bin/dbfetch')
    #   puts server.fetch('embl','M33388','raw','fasta')
    #   puts server.fetch('refseq','NM_12345','html','embl')
    # ---
    # *Arguments*:
    # * _database_: name of database to query (see Bio::Fetch#databases to get list of supported databases)
    # * _id_: single ID or ID list separated by commas or white space
    # * _style_: [raw|html] (default = 'raw')
    # * _format_: name of output format (see Bio::Fetch#formats)
    def fetch(db, id, style = 'raw', format = nil)
      query = [ "db=#{db}", "id=#{id}", "style=#{style}" ]
      query.push("format=#{format}") if format
      query = query.join('&')
  
      Bio::Command.read_uri(@url + '?' + URI.escape(query))
    end
  
    # Shortcut for using BioRuby's BioFetch server. You can fetch an entry
    # without creating an instance of BioFetch server. This method uses the 
    # default dbfetch server, which is http://bioruby.org/cgi-bin/biofetch.rb
    # 
    # Example:
    #   puts Bio::Fetch.query('refseq','NM_12345')
    #
    # ---
    # *Arguments*:
    # * _database_: name of database to query (see Bio::Fetch#databases to get list of supported databases)
    # * _id_: single ID or ID list separated by commas or white space
    # * _style_: [raw|html] (default = 'raw')
    # * _format_: name of output format (see Bio::Fetch#formats)
    def self.query(*args)
      self.new.fetch(*args)
    end
  
    # Using this method, the user can ask a dbfetch server what databases
    # it supports. This would normally be the first step you'd take when
    # you use a dbfetch server for the first time.
    # Example:
    #  server = Bio::Fetch.new()
    #  puts server.databases # returns "aa aax bl cpd dgenes dr ec eg emb ..."
    #
    # This method only works for the bioruby dbfetch server. For a list
    # of databases available from the EBI, see the EBI website at 
    # http://www.ebi.ac.uk/cgi-bin/dbfetch/
    # ---
    # *Returns*:: array of database names
    def databases
      query = "info=dbs"

      Bio::Command.read_uri(@url + '?' + URI.escape(query)).strip.split(/\s+/)
    end
  
    # Lists the formats that are available for a given database. Like the
    # Bio::Fetch#databases method, this method is only available on 
    # the bioruby dbfetch server.
    # Example:
    #  server = Bio::Fetch.new()
    #  puts server.formats('embl') # returns "default fasta"
    # ---
    # *Arguments*:
    # * _database_:: name of database you want the supported formats for
    # *Returns*:: array of formats
    def formats(database = @database)
      if database
        query = "info=formats;db=#{database}"

        Bio::Command.read_uri(@url + '?' + URI.escape(query)).strip.split(/\s+/)
      end
    end
  
    # A dbfetch server will only return entries up to a given maximum number.
    # This method retrieves that number from the server. As for the databases
    # and formats methods, the maxids method only works for the bioruby
    # dbfetch server.
    # ---
    # *Arguments*: none
    # *Returns*:: number
    def maxids
      query = "info=maxids"

      Bio::Command.read_uri(@url + '?' + URI.escape(query)).to_i
    end
  
  end

end # module Bio

