#
# bio/appl/blat/report.rb - BLAT result parser
#
#   Copyright (C) 2004 GOTO Naohisa <ng@bioruby.org>
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
#  $Id: report.rb,v 1.1 2004/10/13 16:52:26 ngoto Exp $
#

require 'bio'

module Bio
  class Blat
    class Report #< DB
      DELIMITER = RS = nil # 1 file 1 entry

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
      attr_reader :hits, :columns

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

      class SeqDesc
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
	attr_reader :gap_count, :gap_bases,
	  :name, :size, :start, :end, :starts, :seqs
      end #class SeqDesc

      class SegmentPair
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
	attr_reader :query_from, :query_to, :qseq, :query_strand
        attr_reader :hit_from,   :hit_to,   :hseq, :hit_strand
        attr_reader :blocksize

        def align_len
          @qseq ? @qseq.size : nil
        end
      end #class SegmentPair

      class Hit
        def initialize(str)
          @data = str.chomp.split(/\t/)
        end
        attr_reader :data

        def split_comma(str)
          str.to_s.sub(/\s*\,+\s*\z/, '').split(/\s*\,\s*/)
        end
        private :split_comma

        def query
          unless defined?(@query)
            d = @data
            @query = SeqDesc.new(d[4], d[5], d[9], d[10], d[11], d[12],
                                 split_comma(d[19]), split_comma(d[21]))
          end
          @query
        end

        def target
          unless defined?(@target)
            d = @data
            @target = SeqDesc.new(d[6], d[7], d[13], d[14], d[15], d[16],
                                  split_comma(d[20]), split_comma(d[22]))
          end
          @target
        end

        def match;       @data[0].to_i;  end
        def mismatch;    @data[1].to_i;  end
        def rep_match;   @data[2].to_i;  end
        def n_s;         @data[3].to_i;  end

        def strand;      @data[8];       end
        def block_count; @data[17].to_i; end

        def block_sizes
          unless defined?(@block_sizes) then
            @block_sizes = split_comma(@data[18]).collect { |x| x.to_i }
          end
	  @block_sizes
        end

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

        # Bio::BLAST::*::Report::Hit compatible methods
        def query_len;  query.size;  end
        def query_def;  query.name;  end
        alias query_id query_def

        def target_len; target.size; end
        def target_def; target.name; end
        alias target_id target_def

        alias len        target_len
        alias definition target_def

        alias hsps blocks
        def each(&x); exons.each(&x); end
      end #class Hit

      #Bio::BLAST::*::Report compatible methods
      def num_hits;     @hits.size;     end
      def each_hit(&x); @hits.each(&x); end
      alias each each_hit
      def query_def; (x = @hits.first) ? x.query_def : nil; end
      def query_len; (x = @hits.first) ? x.query_len : nil; end
      alias query_id query_def
    end #class Report

  end #class Blat
end #module Bio

=begin

= Bio::Blat::Report

  BLAT result parser. (psl / pslx format)

--- Bio::Blat::Report.new(text)

    Creates new Bio::Blat::Report object from String.
    You can use Bio::FlatFile to read a file.
  
    Currently, results created with options -out=psl (default) or
    -out=pslx are supported.

--- Bio::Blat::Report#hits

    Returns an Array of Bio::Blat::Report::Hit objects.

--- Bio::Blat::Report#each_hit
--- Bio::Blat::Report#each

    Iterates over each Bio::Blat::Report::Hit object.
    Same as hits.each.

--- Bio::Blat::Report#num_hits

    Returns number of hits.
    Same as hits.size.

--- Bio::Blat::Report#query_id

    Returns the identifier of query sequence.
    This method is alias of query_def method.
    CAUTION: query_* methods simply return first hit's query_*.
             If multiple query sequences are given, these values
             will be incorrect.

--- Bio::Blat::Report#query_def

    Returns the name of query sequence.
    CAUTION: query_* methods simply return first hit's query_*.
             If multiple query sequences are given, these values
             will be incorrect.

--- Bio::Blat::Report#query_len

    Returns the length of query sequence.
    CAUTION: query_* methods simply return first hit's query_*.
             If multiple query sequences are given, these values
             will be incorrect.

--- Bio::Blat::Report#columns

    Returns descriptions of columns.
    Returns an Array.
    This would be a Bio::Blat specific method.

== Bio::Blat::Report::Hit

    Hit object.
    Similar to Bio::Blast::Report::Hit but lacks many methods.

--- Bio::Blat::Report::Hit#hit_id
--- Bio::Blat::Report::Hit#target_id

    Returns the identifier of subject sequence.
    This method is alias of target_def method.

--- Bio::Blat::Report::Hit#definition
--- Bio::Blat::Report::Hit#target_def

    Returns the name of subject sequence.

--- Bio::Blat::Report::Hit#len
--- Bio::Blat::Report::Hit#target_len

    Returns the length of subject sequence.

--- Bio::Blat::Report::Hit#query_id

    Returns the identifier of query sequence.
    This method is alias of query_def method.

--- Bio::Blat::Report::Hit#query_def

    Returns the name of query sequence.

--- Bio::Blat::Report::Hit#query_len

    Returns the length of query sequence.

--- Bio::Blat::Report::Hit#blocks
--- Bio::Blat::Report::Hit#exons

    Returns blocks(exons) of the hit.
    Each exon is a Bio::Blat::Report::SegmentPair object.

--- Bio::Blat::Report::Hit#hsps

    Same as Bio::Blat::Report#exons
    The method aims to provide compatibility between
    other homology search program's result objects.

--- Bio::Blat::Report::Hit#each

    Iterates over each exon (Bio::Blat::Report::SegmentPair object)
    of the hit.

--- Bio::Blat::Report::Hit#query
--- Bio::Blat::Report::Hit#target

    Returns sequence informations of "query" or "target", respectively.
    Returns a Bio::Blat::Report::SeqDesc object.
    These would be Bio::Blat specific methods.

--- Bio::Blat::Report::Hit#data

    Returns raw data.
    Returns an Array.
    These would be Bio::Blat specific methods.

--- Bio::Blat::Report::Hit#strand

    Returns strand information of the hit.
    Returns '+' or '-'.
    This would be a Bio::Blat specific method.

== Bio::Blat::Report::SegmentPair

    Sequence segment pair of BLAT result.
    Similar to Bio::Blast::Report::HSP but lacks many methods.

--- Bio::Blat::Report::SegmentPair#query_from

     Returns query start position.
     Note that first position is 1.
     CAUTION: In Blat's raw result(psl format), first position is 0.
              However, we add 1 to the position to keep compatibility.

--- Bio::Blat::Report::SegmentPair#query_to

     Returns query end position.

--- Bio::Blat::Report::SegmentPair#qseq

     Returns query sequence.

--- Bio::Blat::Report::SegmentPair#hit_from
--- Bio::Blat::Report::SegmentPair#hit_to
--- Bio::Blat::Report::SegmentPair#hseq

--- Bio::Blat::Report::SegmentPair#query_strand
--- Bio::Blat::Report::SegmentPair#hit_strand

    Returns strand information of query or hit, respectively.
    Returns 'plus' or 'minus'.

--- Bio::Blat::Report::SegmentPair#align_len

    Returns alignment length of the segment pair.
    Returns nil if no alignment data are available.

--- Bio::Blat::Report::SegmentPair#blocksize

    Returns block size (length) of the segment pair.
    This would be a Bio::Blat specific method.

== Bio::Blat::Report::SeqDesc

    Sequence information of query or target.
    It also includes some hit information.

--- Bio::Blat::Report::SeqDesc#gap_count
--- Bio::Blat::Report::SeqDesc#gap_bases
--- Bio::Blat::Report::SeqDesc#name
--- Bio::Blat::Report::SeqDesc#size
--- Bio::Blat::Report::SeqDesc#start
--- Bio::Blat::Report::SeqDesc#end
--- Bio::Blat::Report::SeqDesc#starts
--- Bio::Blat::Report::SeqDesc#seqs

= References

* ((<URL:http://www.genome.org/cgi/content/abstract/12/4/656>))
  Kent, W.J., BLAT--the BLAST-like alignment tool,
  Genome Research, 12, 656--664, 2002.

=end
