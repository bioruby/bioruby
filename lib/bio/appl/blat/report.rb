#
# = bio/appl/blat/report.rb - BLAT result parser
#
# Copyright:: Copyright (C) 2004 GOTO Naohisa <ng@bioruby.org>
# License:: LGPL
#
#--
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
#++
#
#  $Id: report.rb,v 1.6 2005/12/18 15:58:39 k Exp $
#
# BLAT result parser (psl / pslx format).
#
# == Important Notes
#
# In BLAT results, the start position of a sequnece is numbered as 0.
# On the other hand, in many other homology search programs,
# the start position of a sequence is numbered as 1.
# To keep compatibility, the BLAT parser adds 1 to every position number.
#
# == References
#
# * Kent, W.J., BLAT--the BLAST-like alignment tool,
#   Genome Research, 12, 656--664, 2002.
#   http://www.genome.org/cgi/content/abstract/12/4/656
# 

require 'bio'

module Bio
  class Blat

    # Bio::Blat::Report is a BLAT report parser class.
    # Its object may contain some Bio::Blat::Report::Hits objects.
    #
    # In BLAT results, the start position of a sequnece is numbered as 0.
    # On the other hand, in many other homology search programs,
    # the start position of a sequence is numbered as 1.
    # To keep compatibility, the BLAT parser adds 1 to every position number.
    #
    # Note that Bio::Blat::Report#query_def, #query_id, #query_len  methods
    # simply return first hit's query_*.
    # If multiple query sequences are given, these values
    # will be incorrect.
    #
    class Report #< DB
      # Delimiter of each entry. Bio::FlatFile uses it.
      # In Bio::Blat::Report, it it nil (1 entry 1 file).
      DELIMITER = RS = nil # 1 file 1 entry

      # Creates a new Bio::Blat::Report object from BLAT result text (String).
      # You can use Bio::FlatFile to read a file.
      # Currently, results created with options -out=psl (default) or
      # -out=pslx are supported.
      def initialize(text)
        flag = false
        head = []
        @hits = []
        text.each do |line|
          if flag then
            @hits << Hit.new(line)
          else
            line = line.chomp
            if /\A\-+\s*\z/ =~ line
              flag = true
            else
              head << line
            end
          end
        end
        @columns = parse_header(head)
      end

      # hits of the result.
      # Returns an Array of Bio::Blat::Report::Hit objects.
      attr_reader :hits

      # Returns descriptions of columns.
      # Returns an Array.
      # This would be a Bio::Blat specific method.
      attr_reader :columns

      # Parses headers.
      def parse_header(ary)
        ary.shift # first line is removed
        a0 = ary.collect { |x| x.split(/\t/) }
        k = []
        a0.each do |x|
          x.each_index do |i|
            y = x[i].strip
            k[i] = k[i].to_s + (y.sub!(/\-\z/, '') ? y : y + ' ')
          end
        end
        k.each { |x| x.strip! }
        k
      end
      private :parse_header

      # Bio::Blat::Report::SeqDesc stores sequence information of
      # query or subject of the BLAT report.
      # It also includes some hit information.
      class SeqDesc
        # Creates a new SeqDesc object.
        # It is designed to be called internally from Bio::Blat::Report class.
        # Users shall not use it directly.
        def initialize(gap_count, gap_bases, name, size,
                       st, ed, starts, seqs)
          @gap_count = gap_count.to_i
          @gap_bases = gap_bases.to_i
          @name = name
          @size = size.to_i
          @start = st.to_i
          @end = ed.to_i
          @starts = starts.collect { |x| x.to_i }
          @seqs = seqs
        end
        # gap count
        attr_reader :gap_count
        # gap bases
        attr_reader :gap_bases
        # name of the sequence
        attr_reader :name
        # length of the sequence
        attr_reader :size
        # start position of the first segment
        attr_reader :start
        # end position of the final segment
        attr_reader :end
        # start positions of segments.
        # Returns an array of numbers.
        attr_reader :starts
        # sequences of segments.
        # Returns an array of String.
        # Returns nil if there are no sequence data.
        attr_reader :seqs
      end #class SeqDesc

      # Sequence segment pair of BLAT result.
      # Similar to Bio::Blast::Report::Hsp but lacks many methods.
      class SegmentPair
        # Creates a new SegmentPair object.
        # It is designed to be called internally from Bio::Blat::Report class.
        # Users shall not use it directly.
        def initialize(query_len, strand,
                       blksize, qstart, tstart, qseq, tseq)
          @blocksize  = blksize
          @qseq       = qseq
          @hseq       = hseq
          @hit_strand   = 'plus'
          case strand
          when '-'
            # query is minus strand
            @query_strand = 'minus'
            # convert positions
            @query_from = query_len - qstart
            @query_to   = query_len - qstart - blksize + 1
            # To keep compatibility, with other homology search programs,
            # we add 1 to each position number.
            @hit_from   = tstart + 1
            @hit_to     = tstart + blksize # - 1 + 1
          else #when '+'
            @query_strand = 'plus'
            # To keep compatibility with other homology search programs,
            # we add 1 to each position number.
            @query_from = qstart + 1
            @query_to   = qstart + blksize # - 1 + 1
            @hit_from   = tstart + 1
            @hit_to     = tstart + blksize # - 1 + 1
          end
        end
        # Returns query start position.
        # CAUTION: In Blat's raw result(psl format), first position is 0.
        # To keep compatibility, the parser add 1 to the position.
        attr_reader :query_from

        # Returns query end position.
        # CAUTION: In Blat's raw result(psl format), first position is 0.
        # To keep compatibility, the parser add 1 to the position.
        attr_reader :query_to

        # Returns query sequence.
        # If sequence data is not available, returns nil.
        attr_reader :qseq

        # Returns strand information of the query.
        # Returns 'plus' or 'minus'.
        attr_reader :query_strand

        # Returns target (subject, hit) start position.
        # CAUTION: In Blat's raw result(psl format), first position is 0.
        # To keep compatibility, the parser add 1 to the position.
        attr_reader :hit_from

        # Returns target (subject, hit) end position.
        # CAUTION: In Blat's raw result(psl format), first position is 0.
        # To keep compatibility, the parser add 1 to the position.
        attr_reader :hit_to

        # Returns the target (subject, hit) sequence.
        # If sequence data is not available, returns nil.
        attr_reader :hseq

        # Returns strand information of the target (subject, hit).
        # Returns 'plus' or 'minus'.
        attr_reader :hit_strand

        # Returns block size (length) of the segment pair.
        # This would be a Bio::Blat specific method.
       attr_reader :blocksize

        # Returns alignment length of the segment pair.
        # Returns nil if no alignment data are available.
        def align_len
          @qseq ? @qseq.size : nil
        end
      end #class SegmentPair

      # Hit class for the BLAT result parser.
      # Similar to Bio::Blast::Report::Hit but lacks many methods.
      # Its object may contain some Bio::Blat::Report::SegmentPair objects.
      class Hit
        # Creates a new Hit object from a piece of BLAT result text.
        # It is designed to be called internally from Bio::Blat::Report object.
        # Users shall not use it directly.
        def initialize(str)
          @data = str.chomp.split(/\t/)
        end

        # Raw data of the hit.
        # (Note that it doesn't add 1 to position numbers.)
        attr_reader :data

        # split comma-separeted text
        def split_comma(str)
          str.to_s.sub(/\s*\,+\s*\z/, '').split(/\s*\,\s*/)
        end
        private :split_comma

        # Returns sequence informations of the query.
        # Returns a Bio::Blat::Report::SeqDesc object.
        # This would be Bio::Blat specific method.
        def query
          unless defined?(@query)
            d = @data
            @query = SeqDesc.new(d[4], d[5], d[9], d[10], d[11], d[12],
                                 split_comma(d[19]), split_comma(d[21]))
          end
          @query
        end

        # Returns sequence informations of the target(hit).
        # Returns a Bio::Blat::Report::SeqDesc object.
        # This would be Bio::Blat specific method.
        def target
          unless defined?(@target)
            d = @data
            @target = SeqDesc.new(d[6], d[7], d[13], d[14], d[15], d[16],
                                  split_comma(d[20]), split_comma(d[22]))
          end
          @target
        end

        # Match nucleotides.
        def match;       @data[0].to_i;  end
        # Mismatch nucleotides.
        def mismatch;    @data[1].to_i;  end
        # rep. match (???)
        def rep_match;   @data[2].to_i;  end
        # N's (???)
        def n_s;         @data[3].to_i;  end

        # Returns strand information of the hit.
        # Returns '+' or '-'.
        # This would be a Bio::Blat specific method.
        def strand;      @data[8];       end

        # Number of blocks(exons, segment pairs).
        def block_count; @data[17].to_i; end

        # Sizes of all blocks(exons, segment pairs).
        # Returns an array of numbers.
        def block_sizes
          unless defined?(@block_sizes) then
            @block_sizes = split_comma(@data[18]).collect { |x| x.to_i }
          end
          @block_sizes
        end

        # Returns blocks(exons, segment pairs) of the hit.
        # Returns an array of Bio::Blat::Report::SegmentPair objects.
        def blocks
          unless defined?(@blocks)
            bs    = block_sizes
            qst   = query.starts
            tst   = target.starts
            qseqs = query.seqs
            tseqs = target.seqs
            @blocks = (0...block_count).collect do |i|
              SegmentPair.new(query.size, strand, bs[i],
                              qst[i], tst[i], qseqs[i], tseqs[i])
            end
          end
          @blocks
        end
        alias exons blocks

        #--
        # Bio::BLAST::*::Report::Hit compatible methods
        #++
        alias hsps blocks

        # Returns the length of query sequence.
        def query_len;  query.size;  end

        # Returns the name of query sequence.
        def query_def;  query.name;  end
        alias query_id query_def

        # Returns the length of the target(subject) sequence.
        def target_len; target.size; end
        alias len target_len

        # Returns the name of the target(subject) sequence.
        def target_def; target.name; end
        alias target_id target_def
        alias definition target_def

        #Iterates over each block(exon, segment pair) of the hit.
        # Yields a Bio::Blat::Report::SegmentPair object.
        def each(&x) #:yields: segmentpair
          exons.each(&x)
        end
      end #class Hit

      #--
      #Bio::BLAST::*::Report compatible methods
      #++

      # Returns number of hits.
      # Same as hits.size.
      def num_hits;     @hits.size;     end

      # Iterates over each Bio::Blat::Report::Hit object.
      # Same as hits.each.
      def each_hit(&x) #:yields: hit
        @hits.each(&x)
      end
      alias each each_hit

      # Returns the name of query sequence.
      # CAUTION: query_* methods simply return first hit's query_*.
      # If multiple query sequences are given, these values
      # will be incorrect.
      def query_def; (x = @hits.first) ? x.query_def : nil; end

      # Returns the length of query sequence.
      # CAUTION: query_* methods simply return first hit's query_*.
      # If multiple query sequences are given, these values
      # will be incorrect.
      def query_len; (x = @hits.first) ? x.query_len : nil; end
      alias query_id query_def
    end #class Report

  end #class Blat
end #module Bio

=begin

= Bio::Blat::Report

  BLAT result parser. (psl / pslx format)

= References

* ((<URL:http://www.genome.org/cgi/content/abstract/12/4/656>))
  Kent, W.J., BLAT--the BLAST-like alignment tool,
  Genome Research, 12, 656--664, 2002.

=end
