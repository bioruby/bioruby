#
# = bio/appl/bl2seq/report.rb - bl2seq (BLAST 2 sequences) parser
# 
# Copyright:: Copyright (C) 2005 Naohisa Goto <ng@bioruby.org>
# License::   The Ruby License
#
#
# Bio::Blast::Bl2seq::Report is a NCBI bl2seq (BLAST 2 sequences) output parser.
#
# = Acknowledgements
#
# Thanks to Tomoaki NISHIYAMA <tomoakin __at__ kenroku.kanazawa-u.ac.jp> 
# for providing bl2seq parser patches based on
# lib/bio/appl/blast/format0.rb.
#

module Bio

require 'bio/appl/blast' unless const_defined?(:Blast)

class Blast

  class Bl2seq

    # Bio::Blast::Bl2seq::Report is a NCBI bl2seq (BLAST 2 sequences) output parser.
    # It inherits Bio::Blast::Default::Report.
    # Most of its methods are the same as Bio::Blast::Default::Report,
    # but it lacks many methods.
    class Report < Bio::Blast::Default::Report

      # Delimiter of each entry. Bio::FlatFile uses it.
      # In Bio::Blast::Bl2seq::Report, it it nil (1 entry 1 file).
      DELIMITER = RS = nil
      DELIMITER_OVERRUN = nil

      undef format0_parse_header
      undef program, version, version_number, version_date,
        message, converged?, reference, db

      # Splits headers.
      def format0_split_headers(data)
        @f0query = data.shift
      end
      private :format0_split_headers

      # Splits the search results.
      def format0_split_search(data)
        iterations = []
        while r = data[0] and /^\>/ =~ r
          iterations << Iteration.new(data)
        end
        if iterations.size <= 0 then
          iterations << Iteration.new(data)
        end
        iterations
      end
      private :format0_split_search

      # Stores format0 database statistics.
      # Internal use only. Users must not use the class.
      class F0dbstat < Bio::Blast::Default::Report::F0dbstat #:nodoc:
        # Returns number of sequences in database.
        def db_num
          unless defined?(@db_num)
            parse_params
            @db_num = @hash['Number of Sequences'].to_i
          end
          @db_num
        end

        # Returns number of letters in database.
        def db_len
          unless defined?(@db_len)
            parse_params
            @db_len = @hash['length of database'].to_i
          end
          @db_len
        end
      end #class F0dbstat

      # Bio::Blast::Bl2seq::Report::Iteration stores information about
      # a iteration.
      # Normally, it may contain some Bio::Blast::Bl2seq::Report::Hit objects.
      #
      # Note that its main existance reason is to keep complatibility
      # between Bio::Blast::Default::Report::* classes.
      class Iteration < Bio::Blast::Default::Report::Iteration
        # Creates a new Iteration object.
        # It is designed to be called only internally from
        # the Bio::Blast::Default::Report class.
        # Users shall not use the method directly.
        def initialize(data)
          @f0stat = []
          @f0dbstat = Bio::Blast::Default::Report::AlwaysNil.instance
          @hits = []
          @num = 1
          while r = data[0] and /^\>/ =~ r
            @hits << Hit.new(data)
          end
        end

        # Returns the hits of the iteration.
        # It returns an array of Bio::Blast::Bl2seq::Report::Hit objects.
        def hits; @hits; end

        undef message, pattern_in_database, 
          pattern, pattern_positions, hits_found_again,
          hits_newly_found, hits_for_pattern, parse_hitlist,
          converged?
      end #class Iteration

      # Bio::Blast::Bl2seq::Report::Hit contains information about a hit.
      # It may contain some Bio::Blast::Default::Report::HSP objects.
      # All methods are the same as Bio::Blast::Default::Report::Hit class.
      # Please refer to Bio::Blast::Default::Report::Hit.
      class Hit < Bio::Blast::Default::Report::Hit
      end #class Hit

      # Bio::Blast::Bl2seq::Report::HSP holds information about the hsp
      # (high-scoring segment pair).
      # NOTE that the HSP class below is NOT used because
      # Ruby's constants namespace are normally statically determined
      # and HSP object is created in Bio::Blast::Default::Report::Hit class.
      # Please refer to Bio::Blast::Default::Report::HSP.
      class HSP < Bio::Blast::Default::Report::HSP
      end #class HSP

    end #class Report
  end #class Bl2seq

end #class Blast
end #module Bio

######################################################################

=begin

= Bio::Blast::Bl2seq::Report

    NCBI bl2seq (BLAST 2 sequences) output parser

=end

