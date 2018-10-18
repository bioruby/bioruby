#
# = bio/io/togows.rb - REST interface for TogoWS
#
# Copyright::  Copyright (C) 2009 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#
# Bio::TogoWS is a set of clients for the TogoWS web services
# (http://togows.dbcls.jp/).
#
# * Bio::TogoWS::REST is a REST client for the TogoWS.
# * Bio::TogoWS::SOAP will be implemented in the future.
#

require 'uri'
require 'cgi'
require 'bio/version'
require 'bio/command'

module Bio

  # Bio::TogoWS is a namespace for the TogoWS web services.
  module TogoWS

    # Internal Use Only.
    #
    # Bio::TogoWS::AccessWait is a module to implement a
    # private method for access.
    module AccessWait

      # common default access wait for TogoWS services
      TOGOWS_ACCESS_WAIT = 1

      # Maximum waiting time to avoid dead lock.
      # When exceeding this value, (max/2) + rand(max) is used,
      # to randomize access.
      # This means real maximum waiting time is (max * 1.5).
      TOGOWS_ACCESS_WAIT_MAX = 60

      # Sleeping if needed. 
      # It sleeps about TOGOWS_ACCESS_WAIT * (number of waiting processes).
      #
      # ---
      # *Returns*:: (Numeric) sleeped time
      def togows_access_wait
        w_min = TOGOWS_ACCESS_WAIT
        debug = defined?(@debug) && @debug

        # initializing class variable
        @@togows_last_access ||= nil

        # determines waiting time
        wait = 0
        if last = @@togows_last_access then
          elapsed = Time.now - last
          if elapsed < w_min then
            wait = w_min - elapsed
          end
        end

        # If wait is too long, truncated to TOGOWS_ACCESS_WAIT_MAX.
        if wait > TOGOWS_ACCESS_WAIT_MAX then
          orig_wait = wait
          wait = TOGOWS_ACCESS_WAIT_MAX
          wait = wait / 2 + rand(wait)
          if debug then
            $stderr.puts "TogoWS: sleeping time #{orig_wait} is too long and set to #{wait} to avoid dead lock."
          end
          newlast = Time.now + TOGOWS_ACCESS_WAIT_MAX
        else
          newlast = Time.now + wait
        end

        # put expected end time of sleeping
        if !@@togows_last_access or @@togows_last_access < newlast then
          @@togows_last_access = newlast
        end

        # sleeping if needed
        if wait > 0 then
          $stderr.puts "TogoWS: sleeping #{wait} second" if debug
          sleep(wait)
        end
        # returns waited time
        wait
      end
      private :togows_access_wait

      # (private) resets last access.
      # Should be used only for debug purpose.
      def reset_togows_access_wait
        @@togows_last_access = nil
      end
      private :reset_togows_access_wait

    end #module AccessWait

    # == Description
    #
    # Bio::TogoWS::REST is a REST client for the TogoWS web service.
    #
    # Details of the service are desribed in the following URI.
    #
    # * http://togows.dbcls.jp/site/en/rest.html
    #
    # == Examples
    # 
    # For light users, class methods can be used.
    #
    #   print Bio::TogoWS::REST.entry('ncbi-nucleotide', 'AF237819')
    #   print Bio::TogoWS::REST.search('uniprot', 'lung cancer')
    #
    # For heavy users, an instance of the REST class can be created, and
    # using the instance is more efficient than using class methods.
    #
    #   t = Bio::TogoWS::REST.new
    #   print t.entry('ncbi-nucleotide', 'AF237819')
    #   print t.search('uniprot', 'lung cancer')
    #
    # == References
    #
    # * http://togows.dbcls.jp/site/en/rest.html
    #
    class REST

      include AccessWait

      # URI of the TogoWS REST service
      BASE_URI = 'http://togows.dbcls.jp/'.freeze

      # preset default databases used by the retrieve method.
      #
      DEFAULT_RETRIEVAL_DATABASES =
        %w( genbank uniprot embl ddbj dad )

      # Creates a new object.
      # ---
      # *Arguments*:
      # * (optional) _uri_: String or URI object
      # *Returns*:: new object
      def initialize(uri = BASE_URI)
        uri = URI.parse(uri) unless uri.kind_of?(URI)
        @pathbase = uri.path
        @pathbase = '/' + @pathbase unless /\A\// =~ @pathbase
        @pathbase = @pathbase + '/' unless /\/\z/ =~ @pathbase
        @http = Bio::Command.new_http(uri.host, uri.port)
        @header = {
          'User-Agent' => "BioRuby/#{Bio::BIORUBY_VERSION_ID}"
        }
        @debug = false
      end

      # If true, shows debug information to $stderr.
      attr_accessor :debug

      # Debug purpose only.
      # Returns Net::HTTP object used inside the object.
      # The method will be changed in the future if the implementation
      # of this class is changed.
      def internal_http
        @http
      end

      # Intelligent version of the entry method.
      # If two or more databases are specified, sequentially tries
      # them until valid entry is obtained.
      #
      # If database is not specified, preset default databases are used. 
      # See DEFAULT_RETRIEVAL_DATABASES for details.
      #
      # When multiple IDs and multiple databases are specified, sequentially
      # tries each IDs. Note that results with no hits found or with server
      # errors are regarded as void strings. Also note that data format of
      # the result entries can be different from entries to entries.
      # 
      # ---
      # *Arguments*:
      # * (required) _ids_: (String) an entry ID, or
      #   (Array containing String) IDs. Note that strings containing ","
      # * (optional) _hash_: (Hash) options below can be passed as a hash.
      #   * (optional) <I>:database</I>: (String) database name, or
      #     (Array containing String) database names.
      #   * (optional) <I>:format</I>: (String) format
      #   * (optional) <I>:field</I>: (String) gets only the specified field
      # *Returns*:: String or nil
      def retrieve(ids, hash = {})
        begin
          a = ids.to_ary
        rescue NoMethodError
          ids = ids.to_s
        end
        ids = a.join(',') if a
        ids = ids.split(',')

        dbs = hash[:database] || DEFAULT_RETRIEVAL_DATABASES
        begin
          dbs.to_ary
        rescue NoMethodError
          dbs = dbs.to_s.empty? ? [] : [ dbs.to_s ]
        end
        return nil if dbs.empty? or ids.empty?

        if dbs.size == 1 then
          return entry(dbs[0], ids, hash[:format], hash[:field])
        end

        results = []
        ids.each do |idstr|
          dbs.each do |dbstr|
            r = entry(dbstr, idstr, hash[:format], hash[:field])
            if r and !r.strip.empty? then
              results.push r
              break
            end
          end #dbs.each
        end #ids.each
        
        results.join('')
      end #def retrieve

      # Retrieves entries corresponding to the specified IDs.
      #
      # Example:
      #   t = Bio::TogoWS::REST.new
      #   kuma = t.entry('ncbi-nucleotide', 'AF237819')
      #   # multiple IDs at a time
      #   misc = t.entry('ncbi-nucleotide', [ 'AF237819', 'AF237820' ])
      #   # with format change
      #   p53 = t.entry('uniprot', 'P53_HUMAN', 'fasta')
      #
      # ---
      # *Arguments*:
      # * (required) _database_: (String) database name
      # * (required) _ids_: (String) an entry ID, or
      #   (Array containing String) IDs. Note that strings containing ","
      #   are regarded as multiple IDs.
      # * (optional) _format_: (String) format. nil means the default format
      #   (differs depending on the database).
      # * (optional) _field_: (String) gets only the specified field if not nil
      # *Returns*:: String or nil
      def entry(database, ids, format = nil, field = nil)
        begin
          a = ids.to_ary
        rescue NoMethodError
          ids = ids.to_s
        end

        arg = [ 'entry', database ]
        if a then
          b = a.dup
          (a.size - 1).downto(1) { |i| b.insert(i, :",") }
          arg.concat b
        else
          arg.push ids
        end

        arg.push field if field
        arg[-1] = "#{arg[-1]}.#{format}" if format
        response = get(*arg)

        prepare_return_value(response)
      end

      # Database search.
      # Format of the search term string follows the Common Query Language.
      # * http://en.wikipedia.org/wiki/Common_Query_Language
      #
      # Example:
      #   t = Bio::TogoWS::REST.new
      #   print t.search('uniprot', 'lung cancer')
      #   # only get the 10th and 11th hit ID
      #   print t.search('uniprot', 'lung cancer', 10, 2)
      #   # with json format
      #   print t.search('uniprot', 'lung cancer', 10, 2, 'json')
      #
      # ---
      # *Arguments*:
      # * (required) _database_: (String) database name
      # * (required) _query_: (String) query string
      # * (optional) _offset_: (Integer) offset in search results.
      # * (optional) _limit_: (Integer) max. number of returned results.
      #   If offset is not nil and the limit is nil, it is set to 1.
      # * (optional) _format_: (String) format. nil means the default format.
      # *Returns*:: String or nil
      def search(database, query, offset = nil, limit = nil, format = nil)
        arg = [ 'search', database, query ]
        if offset then
          limit ||= 1
          arg.concat [ "#{offset}", :",", "#{limit}" ]
        end
        arg[-1] = "#{arg[-1]}.#{format}" if format
        response = get(*arg)

        prepare_return_value(response)
      end

      # Data format conversion.
      #
      # Example:
      #   t = Bio::TogoWS::REST.new
      #   blast_string = File.read('test.blastn')
      #   t.convert(blast_string, 'blast', 'gff')
      #
      # ---
      # *Arguments*:
      # * (required) _text_: (String) input data
      # * (required) _inputformat_: (String) data source format
      # * (required) _format_: (String) output format
      # *Returns*:: String or nil
      def convert(data, inputformat, format)
        response = post_data(data, 'convert', "#{inputformat}.#{format}")

        prepare_return_value(response)
      end

      # Returns list of available databases in the entry service.
      # ---
      # *Returns*:: Array containing String
      def entry_database_list
        database_list('entry')
      end

      # Returns list of available databases in the search service.
      # ---
      # *Returns*:: Array containing String
      def search_database_list
        database_list('search')
      end

      #--
      # class methods
      #++

      # The same as Bio::TogoWS::REST#entry.
      def self.entry(*arg)
        self.new.entry(*arg)
      end

      # The same as Bio::TogoWS::REST#search.
      def self.search(*arg)
        self.new.search(*arg)
      end

      # The same as Bio::TogoWS::REST#convert.
      def self.convert(*arg)
        self.new.convert(*arg)
      end

      # The same as Bio::TogoWS::REST#retrieve.
      def self.retrieve(*arg)
        self.new.retrieve(*arg)
      end

      # The same as Bio::TogoWS::REST#entry_database_list
      def self.entry_database_list(*arg)
        self.new.entry_database_list(*arg)
      end

      # The same as Bio::TogoWS::REST#search_database_list
      def self.search_database_list(*arg)
        self.new.search_database_list(*arg)
      end

      private

      # Access to the TogoWS by using GET method.
      #
      # Example 1:
      #   get('entry', 'ncbi-nucleotide', AF209156')
      # Example 2:
      #   get('search', 'uniprot', 'lung cancer')
      #
      # ---
      # *Arguments*:
      # * (optional) _path_: String
      # *Returns*:: Net::HTTPResponse object
      def get(*paths)
        path = make_path(paths)
        if @debug then
          $stderr.puts "TogoWS: HTTP#get(#{path.inspect}, #{@header.inspect})"
        end
        togows_access_wait
        @http.get(path, @header)
      end

      # Access to the TogoWS by using GET method. 
      # Always adds '/' at the end of the path.
      #
      # Example 1:
      #   get_dir('entry')
      #
      # ---
      # *Arguments*:
      # * (optional) _path_: String
      # *Returns*:: Net::HTTPResponse object
      def get_dir(*paths)
        path = make_path(paths)
        path += '/' unless /\/\z/ =~ path
        if @debug then
          $stderr.puts "TogoWS: HTTP#get(#{path.inspect}, #{@header.inspect})"
        end
        togows_access_wait
        @http.get(path, @header)
      end

      # Access to the TogoWS by using POST method.
      # Mime type is 'application/octet-stream'.
      # ---
      # *Arguments*:
      # * (required) _data_: String
      # * (optional) _path_: String
      # *Returns*:: Net::HTTPResponse object
      def post_data(data, *paths)
        path = make_path(paths)
        if @debug then
          $stderr.puts "TogoWS: Bio::Command.http_post(#{path.inspect}, data(#{data.size} bytes), #{@header.inspect})"
        end
        togows_access_wait
        Bio::Command.http_post(@http, path, data, @header)
      end

      # Generates path string from the given paths.
      # Symbol objects are not URL-escaped.
      # String objects are joined with '/'.
      # Symbol objects are joined directly without '/'.
      #
      # ---
      # *Arguments*:
      # * (required) _paths_: Array containing String or Symbol objects
      # *Returns*:: String
      def make_path(paths)
        flag_sep = false
        a = paths.collect do |x|
          case x
          when Symbol
            # without URL escape
            flag_sep = false
            str = x.to_s
          else
            str = CGI.escape(x.to_s)
            str = '/' + str if flag_sep
            flag_sep = true
          end
          str
        end
        @pathbase + a.join('')
      end

      # If response.code == "200", returns body as a String.
      # Otherwise, returns nil.
      def prepare_return_value(response)
        if @debug then
          $stderr.puts "TogoWS: #{response.inspect}"
        end
        if response.code == "200" then
          response.body
        else
          nil
        end
      end

      # Returns list of available databases
      # ---
      # *Arguments*:
      # * (required) _service_: String
      # *Returns*:: Array containing String
      def database_list(service)
        response = get_dir(service)
        str = prepare_return_value(response)
        if str then
          str.chomp.split(/\r?\n/)
        else
          raise 'Unexpected server response'
        end
      end

    end #class REST

  end #module TogoWS

end #module Bio
