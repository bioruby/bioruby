#
# = bio/appl/blast/rpsblast.rb - NCBI RPS Blast default output parser
# 
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#
# == Description
#
# NCBI RPS Blast (Reversed Position Specific Blast) default
# (-m 0 option) output parser class, Bio::Blast::RPSBlast::Report
# and related classes/modules.
#
# == References
#
# * Altschul, Stephen F., Thomas L. Madden, Alejandro A. Schaffer,
#   Jinghui Zhang, Zheng Zhang, Webb Miller, and David J. Lipman (1997),
#   "Gapped BLAST and PSI-BLAST: a new generation of protein database search
#   programs", Nucleic Acids Res. 25:3389-3402.
# * ftp://ftp.ncbi.nih.gov/blast/documents/rpsblast.html
# * http://www.ncbi.nlm.nih.gov/Structure/cdd/cdd_help.shtml
#

require 'bio/appl/blast/format0'
require 'bio/io/flatfile'

module Bio
class Blast

  # NCBI RPS Blast (Reversed Position Specific Blast) namespace.
  # Currently, this module is existing only for separating namespace.
  # To parse RPSBlast results, see Bio::Blast::RPSBlast::Report documents.
  module RPSBlast

    # Flatfile splitter for RPS-BLAST reports.
    # It is internally used when reading RPS-BLAST report.
    # Normally, users do not need to use it directly.
    #
    # Note for Windows: RPS-BLAST results generated in Microsoft Windows
    # may not be parsed correctly due to the line feed code problem.
    # For a workaroud, convert line feed codes from Windows(DOS) to UNIX.
    #
    class RPSBlastSplitter < Bio::FlatFile::Splitter::Template

      # Separator used to distinguish start of each report
      ReportHead =  /\A\n*(RPS\-BLAST|Query\=)/
        
      # Delimiter used for IO#gets
      Delimiter = "\n\n"

      # creates a new splitter object
      def initialize(klass, bstream)
        super(klass, bstream)
        @entry_head = nil
      end

      # Skips leader of the entry.
      # In this class, only skips space characters.
      def skip_leader
        stream.skip_spaces
        return nil
      end

      # Rewinds the stream
      def rewind
        @entry_head = nil
        super
      end
        
      # gets an entry
      def get_entry
        p0 = stream_pos()
        pieces = []
        flag_head = false # reached to start of header
        flag_body = false # reached to start of body (Query=...)
        while x = stream.gets(Delimiter)
          if ReportHead =~ x then
            case $1
            when 'RPS-BLAST'
              if pieces.empty? then
                @entry_head = nil
                flag_head = true
              else
                stream.ungets(x)
                break
              end
            when 'Query='
              if flag_body then
                stream.ungets(x)
                break
              else
                @entry_head = pieces.join('') if flag_head
                flag_body = true
              end
            else
              raise 'Bug: should not reach here'
            end
          end #if ReportHead...
          pieces.push x
        end #while
        p1 = stream_pos()

        self.entry_start_pos = p0
        self.entry = 
          if pieces.empty? then
            nil
          elsif !flag_head and @entry_head then
            @entry_head + pieces.join('')
          else
            pieces.join('')
          end
        self.entry_ended_pos = p1
        return self.entry
      end
    end #class RPSBlastSplitter

    # NCBI RPS Blast (Reversed Position Specific Blast)
    # default output parser.
    #
    # It supports defalut (-m 0 option) output of the "rpsblast" command.
    #
    # Because this class inherits Bio::Blast::Default::Report,
    # almost all methods are eqaul to Bio::Blast::Default::Report.
    # Only DELIMITER (and RS) and few methods are different.
    #
    # By using Bio::FlatFile, (for example, Bio::FlatFile.open),
    # rpsblast result generated from multiple query sequences is
    # automatically splitted into multiple 
    # Bio::BLast::RPSBlast::Report objects corresponding to
    # query sequences.
    #
    # Note for multi-fasta results WITH using Bio::FlatFile:
    # Each splitted result is concatenated with header of the
    # result which describes RPS-BLAST version and database
    # information, if possible.
    #
    # Note for multi-fasta results WITHOUT using Bio::FlatFile:
    # When parsing an output of rpsblast command running with
    # multi-fasta sequences WITHOUT using Bio::FlatFile,
    # each query's result is stored as an "iteration" of PSI-Blast.
    # This behavior may be changed in the future.
    #
    # Note for nucleotide results: This class is not tested with
    # nucleotide query and/or nucleotide databases.
    #
    class Report < Bio::Blast::Default::Report
      # Delimter of each entry for RPS-BLAST.
      DELIMITER = RS = "\nRPS-BLAST"

      # (Integer) excess read size included in DELIMITER.
      DELIMITER_OVERRUN = 9 # "RPS-BLAST"

      # splitter for Bio::FlatFile support
      FLATFILE_SPLITTER = RPSBlastSplitter

      # Creates a new Report object from a string.
      #
      # Using Bio::FlatFile.open (or some other methods)
      # is recommended instead of using this method directly.
      # Refer Bio::Blast::RPSBlast::Report document for more information.
      #
      # Note for multi-fasta results WITHOUT using Bio::FlatFile:
      # When parsing an output of rpsblast command running with
      # multi-fasta sequences WITHOUT using Bio::FlatFile,
      # each query's result is stored as an "iteration" of PSI-Blast.
      # This behavior may be changed in the future.
      #
      # Note for nucleotide results: This class is not tested with
      # nucleotide query and/or nucleotide databases.
      #
      def initialize(str)
        str = str.sub(/\A\s+/, '')
        # remove trailing entries for sure
        str.sub!(/\n(RPS\-BLAST.*)/m, "\n") 
        @entry_overrun = $1
        @entry = str
        data = str.split(/(?:^[ \t]*\n)+/)

        if data[0] and /\AQuery\=/ !~ data[0] then
          format0_split_headers(data)
        end
        @iterations = format0_split_search(data)
        format0_split_stat_params(data)
      end

      # Returns definition of the query.
      # For a result of multi-fasta input, the first query's definition
      # is returned (The same as <tt>iterations.first.query_def</tt>).
      def query_def
        iterations.first.query_def
      end

      # Returns length of the query.
      # For a result of multi-fasta input, the first query's length
      # is returned (The same as <tt>iterations.first.query_len</tt>).
      def query_len
        iterations.first.query_len
      end

      private

      # Splits headers into the first line, reference, query line and
      # database line.
      def format0_split_headers(data)
        @f0header = data.shift
        @f0references = []
        while data[0] and /\ADatabase\:/ !~ data[0]
          @f0references.push data.shift
        end
        @f0database = data.shift
        # In special case, a void line is inserted after database name.
        if /\A +[\d\,]+ +sequences\; +[\d\,]+ total +letters\s*\z/ =~ data[0] then
          @f0database.concat "\n"
          @f0database.concat data.shift
        end
      end

      # Splits the search results.
      def format0_split_search(data)
        iterations = []
        dummystr = 'Searching..................................................done'
        if r = data[0] and /^Searching/ =~ r then
          dummystr = data.shift
        end
        while r = data[0] and /^Query\=/ =~ r
          iterations << Iteration.new(data, dummystr)
        end
        iterations
      end

      # Iteration class for RPS-Blast.
      # Though RPS-Blast does not iterate like PSI-BLAST, 
      # it aims to store a result of single query sequence.
      #
      # Normally, the instance of the class is generated
      # by Bio::Blast::RPSBlast::Report object.
      # 
      class Iteration < Bio::Blast::Default::Report::Iteration
        # Creates a new Iteration object.
        # It is designed to be called only internally from
        # the Bio::Blast::RPSBlast::Report class.
        # Users shall not use the method directly.
        def initialize(data, dummystr)
          if /\AQuery\=/ =~ data[0] then
            sc = StringScanner.new(data.shift)
            sc.skip(/\s*/)
            if sc.skip_until(/Query\= */) then
              q = []
              begin
                q << sc.scan(/.*/)
                sc.skip(/\s*^ ?/)
              end until !sc.rest or r = sc.skip(/ *\( *([\,\d]+) *letters *\)\s*\z/)
              @query_len = sc[1].delete(',').to_i if r
              @query_def = q.join(' ')
            end
          end
          data.unshift(dummystr)
          
          super(data)
        end

        # definition of the query
        attr_reader :query_def

        # length of the query sequence
        attr_reader :query_len
        
      end #class Iteration
      
    end #class Report

  end #module RPSBlast

end #module Blast
end #module Bio

