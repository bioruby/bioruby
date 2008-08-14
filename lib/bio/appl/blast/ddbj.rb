#
# = bio/appl/blast/ddbj.rb - Remote BLAST wrapper using DDBJ web service
# 
# Copyright::  Copyright (C) 2008       Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/appl/blast/remote'
require 'bio/io/ddbjxml'

module Bio::Blast::Remote

  # Remote BLAST factory using DDBJ Web API for Biology
  # (http://xml.nig.ac.jp/).
  #
  module DDBJ

    # Creates a remote BLAST factory using DDBJ.
    # Returns Bio::Blast object.
    #
    # Note for future improvement: In the future, it might return
    # Bio::Blast::Remote::DDBJ or other object. 
    #
    def self.new(program, db, options = [])
      Bio::Blast.new(program, db, options, 'ddbj')
    end

    # Information about DDBJ BLAST.
    module Information

      include Bio::Blast::Remote::Information

      # (private) parse database information
      def _parse_databases
        if defined? @parse_databases
          return nil if @parse_databases
        end
        drv = Bio::DDBJ::XML::Blast.new
        str = drv.getSupportDatabaseList

        databases = {}
        dbdescs = {}
        key = 'blastn'
        prefix = ''
        databases[key] ||= []
        dbdescs[key] ||= {}
        str.each_line do |line|
          a = line.strip.split(/\s*\-\s*/, 2)
          case a.size
          when 1
            prefix = a[0].to_s.strip
            prefix += ': ' unless prefix.empty?
            key = 'blastn'
            next #each_line
          when 0
            prefix = ''
            key = 'blastp'
            databases[key] ||= []
            dbdescs[key] ||= {}
            next #each_line
          end
          name = a[0].to_s.strip.freeze
          desc = (prefix + a[1].to_s.strip).freeze
          databases[key].push name
          dbdescs[key][name] = desc
        end

        databases['blastp'] ||= []
        dbdescs['blastp'] ||= []

        databases['blastn'].freeze
        databases['blastp'].freeze

        databases['blastx']  = databases['blastp']
        dbdescs['blastx']    = dbdescs['blastp']
        databases['tblastn'] = databases['blastn']
        dbdescs['tblastn']   = dbdescs['blastn']
        databases['tblastx'] = databases['blastn']
        dbdescs['tblastx']   = dbdescs['blastn']

        @databases = databases
        @database_descriptions = dbdescs
        @parse_databases = true
        true
      end
      private :_parse_databases

    end #module Information

    extend Information

    # executes BLAST and returns result as a string
    def exec_ddbj(query)
      options = make_command_line_options
      opt = Bio::Blast::NCBIOptions.new(options)

      # SOAP objects are cached
      @ddbj_remote_blast ||= Bio::DDBJ::XML::Blast.new
      #@ddbj_request_manager ||= Bio::DDBJ::XML::RequestManager.new
      # always use REST version to prevent warning messages
      @ddbj_request_manager ||= Bio::DDBJ::XML::RequestManager::REST.new

      program = opt.delete('-p')
      db = opt.delete('-d')
      optstr = Bio::Command.make_command_line_unix(opt.options)

      # using searchParamAsync 
      qid = @ddbj_remote_blast.searchParamAsync(program, db, query, optstr)
      @output = qid

      sleeptime = 2
      flag = true
      while flag
        if $VERBOSE then
          $stderr.puts "DDBJ BLAST: ID: #{qid} -- waitng #{sleeptime} sec."
        end
        sleep(sleeptime)

        result = @ddbj_request_manager.getAsyncResult(qid)
        case result.to_s
        when /The search and analysis service by WWW is very busy now/
          raise result.to_s.strip + '(Alternatively, wrong options may be given.)'
        when /Your job has not completed yet/
          sleeptime = 5
        else
          flag = false
        end
      end while flag

      @output = result
      return @output
    end

  end #module DDBJ

  # for lazy load DDBJ module
  Ddbj = DDBJ

end #module Bio::Blast::Remote

