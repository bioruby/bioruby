#
# = bio/io/biofetch.rb - BioFetch access module
#
# Copyright::	Copyright (C) 2002, 2005 Toshiaki Katayama <k@bioruby.org>,
#               Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
# == DESCRIPTION
#
# Using EBI Dbfetch server
#
#   ebi_server = Bio::Fetch::EBI.new
#   puts ebi_server.fetch('embl', 'J00231')
#   puts ebi_server.fetch('embl', 'J00231', 'raw')
#   puts ebi_server.fetch('embl', 'J00231', 'html')
#
# Getting metadata from EBI Dbfetch server
#
#   puts ebi_server.databases
#   puts ebi_server.formats('embl')
#   puts ebi_server.maxids
#
# Using EBI Dbfetch server without creating a Bio::Fetch::EBI instance
#
#   puts Bio::Fetch::EBI.query('ena_sequence', 'J00231')
#   puts Bio::Fetch::EBI.query('ena_sequence', 'J00231', 'raw', 'fasta')
#
# Using a BioFetch server with specifying URL
#
#   server = Bio::Fetch.new('http://www.ebi.ac.uk/Tools/dbfetch/dbfetch')
#   puts server.fetch('ena_sequence', 'J00231')
#   puts server.fetch('ena_sequence', 'J00231', 'raw', 'fasta')
# 

require 'uri'
require 'cgi'
require 'bio/command'

module Bio
  # = DESCRIPTION
  # The Bio::Fetch class provides an interface to dbfetch servers. Given
  # a database name and an accession number, these servers return the associated
  # record. For example, for the embl database on the EBI, that would be a
  # nucleic or amino acid sequence.
  #
  # Possible dbfetch servers include:
  # * http://www.ebi.ac.uk/Tools/dbfetch/dbfetch
  #
  # Note that old URL http://www.ebi.ac.uk/cgi-bin/dbfetch still alives
  # probably because of compatibility, but using the new URL is recommended.
  #
  # Historically, there were other dbfetch servers including:
  # * http://bioruby.org/cgi-bin/biofetch.rb (default before BioRuby 1.4)
  # But they are unavailable now.
  #
  #
  # If you're behind a proxy server, be sure to set your HTTP_PROXY
  # environment variable accordingly.
  #
  # = USAGE
  #  require 'bio'
  #  
  #  # Retrieve the sequence of accession number M33388 from the EMBL
  #  # database.
  #  server = Bio::Fetch::EBI.new  #uses EBI server
  #  puts server.fetch('ena_sequence','M33388')
  #
  #  # database name "embl" can also be used though it is not officially listed
  #  puts server.fetch('embl','M33388')
  #
  #  # Do the same thing with explicitly giving the URL.
  #  server = Bio::Fetch.new(Bio::Fetch::EBI::URL)  #uses EBI server
  #  puts server.fetch('ena_sequence','M33388')
  #
  #  # Do the same thing without creating a Bio::Fetch::EBI object.
  #  puts Bio::Fetch::EBI.query('ena_sequence','M33388')
  #
  #  # To know what databases are available on the dbfetch server:
  #  server = Bio::Fetch::EBI.new
  #  puts server.databases
  #
  #  # Some databases provide their data in different formats (e.g. 'fasta',
  #  # 'genbank' or 'embl'). To check which formats are supported by a given
  #  # database:
  #  puts server.formats('embl')
  #
  class Fetch
  
    # Bio::Fetch::EBI is a client of EBI Dbfetch
    # (http://www.ebi.ac.uk/Tools/dbfetch/dbfetch).
    #
    # An instance of this class works the same as:
    #  obj = Bio::Fetch.new("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch")
    #  obj.database = "ena_sequence"
    #
    # See the documents of Bio::Fetch for more details.
    class EBI < Fetch

      # EBI Dbfetch server URL
      URL = "http://www.ebi.ac.uk/Tools/dbfetch/dbfetch".freeze

      # For the usage, see the document of Bio::Fetch.new.
      def initialize(url = URL)
        @database = "ena_sequence"
        super
      end

      # Shortcut for using EBI Dbfetch server. You can fetch an entry
      # without creating an instance of Bio::Fetch::EBI. This method uses
      # EBI Dbfetch server http://www.ebi.ac.uk/Tools/dbfetch/dbfetch .
      # 
      # Example:
      #   puts Bio::Fetch::EBI.query('refseq','NM_123456')
      #   puts Bio::Fetch::EBI.query('ena_sequence','J00231')
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
    end #class EBI

    # Create a new Bio::Fetch server object that can subsequently be queried
    # using the Bio::Fetch#fetch method.
    #
    # You must specify _url_ of a server.
    # The preset default server is deprecated.
    #
    # If you want to use a server without explicitly specifying the URL,
    # use Bio::Fetch::EBI.new that uses EBI Dbfetch server.
    #
    # ---
    # *Arguments*:
    # * _url_: URL of dbfetch server. (no default value)
    # *Returns*:: Bio::Fetch object
    def initialize(url = nil)
      unless url then
        raise ArgumentError, "No server URL is given in Bio::Fetch.new. The default server URL value have been deprecated. You must explicitly specify the url or use Bio::Fetch::EBI for using EBI Dbfetch."
      end
      @url = url
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
    # 'raw' text or 'html' (style), and format.
    #
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
      query = [ [ 'db',    db ],
                [ 'id',    id ],
                [ 'style', style ] ]
      query.push([ 'format', format ]) if format
  
      _get(query)
    end
  
    # Using this method, the user can ask a dbfetch server what databases
    # it supports. This would normally be the first step you'd take when
    # you use a dbfetch server for the first time.
    # Example:
    #  server = Bio::Fetch.new()
    #  puts server.databases # returns "aa aax bl cpd dgenes dr ec eg emb ..."
    #
    # This method works for EBI Dbfetch server (and for the bioruby dbfetch
    # server). Not all servers support this method.
    # ---
    # *Returns*:: array of database names
    def databases
      _get_single('info', 'dbs').strip.split(/\s+/)
    end
  
    # Lists the formats that are available for a given database. Like the
    # Bio::Fetch#databases method, not all servers support this method.
    # This method is available on the EBI Dbfetch server (and on the bioruby
    # dbfetch server).
    #
    # Example:
    #  server = Bio::Fetch::EBI.new()
    #  puts server.formats('embl') # returns [ "default", "annot", ... ]
    # ---
    # *Arguments*:
    # * _database_:: name of database you want the supported formats for
    # *Returns*:: array of formats
    def formats(database = @database)
      if database
        query = [ [ 'info', 'formats' ],
                  [ 'db',   database  ] ]
        _get(query).strip.split(/\s+/)
      end
    end
  
    # A dbfetch server will only return entries up to a given maximum number.
    # This method retrieves that number from the server. As for the databases
    # and formats methods, not all servers support the maxids method.
    # This method is available on the EBI Dbfetch server (and on the bioruby
    # dbfetch server).
    #
    # Example:
    #  server = Bio::Fetch::EBI.new
    #  puts server.maxids # currently returns 200
    # ---
    # *Arguments*: none
    # *Returns*:: number
    def maxids
      _get_single('info', 'maxids').to_i
    end

    private
    # (private) query to the server.
    # ary must be nested array, e.g. [ [ key0, val0 ], [ key1, val1 ], ... ]
    def _get(ary)
      query = ary.collect do |a|
        "#{CGI.escape(a[0])}=#{CGI.escape(a[1])}"
      end.join('&')
      Bio::Command.read_uri(@url + '?' + query)
    end

    # (private) query with single parameter
    def _get_single(key, val)
      query = "#{CGI.escape(key)}=#{CGI.escape(val)}"
      Bio::Command.read_uri(@url + '?' + query)
    end

  end

end # module Bio

