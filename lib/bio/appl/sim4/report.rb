#
# bio/appl/sim4/report.rb - sim4 result parser
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
#  $Id: report.rb,v 1.2 2004/10/10 14:54:23 ngoto Exp $
#

module Bio
  class Sim4

    class Report #< DB
      # format: A=0, A=3, or A=4
      DELIMITER = RS = nil # 1 entry 1 file

      def initialize(text)
        @hits = []
        @all_hits = []
        overrun = ''
        text.each("\n\nseq1 = ") do |str|
          str = str.sub(/\A\s+/, '')
          str.sub!(/\n(^seq1 \= .*)/m, "\n") # remove trailing hits for sure
          tmp = $1.to_s
          hit = Hit.new(overrun + str)
          overrun = tmp
          unless hit.instance_eval { @data.empty? } then
            @hits << hit
          end
          @all_hits << hit
        end
        @seq1 = @all_hits[0].seq1
      end
      attr_reader :hits, :all_hits, :seq1

      class SeqDesc
        # description/definitions of a sequence
        def initialize(seqid, seqdef, len, filename)
          @entry_id   = seqid
          @definition = seqdef
          @len        = len
          @filename   = filename
        end
        attr_reader :entry_id, :definition, :len, :filename

        def self.parse(str, str2 = nil)
	  /^seq[12] \= (.*)(?: \((.*)\))?\,\s*(\d+)\s*bp\s*$/ =~ str
          seqid = $2
          filename = $1
          len = $3.to_i
          if str2 then
            seqdef = str2.sub(/^\>\s*/, '')
            seqid  =seqdef.split(/\s+/, 2)[0] unless seqid
          else
            seqdef = (seqid or filename)
            seqid = filename unless seqid
          end
          self.new(seqid, seqdef, len, filename)
        end
      end #class SeqDesc

      class SegmentPair
        # segment pair (like Bio::BLAST::*::Report::HSP)
        def initialize(seq1, seq2, midline = nil,
                       percent_identity = nil, direction = nil)
          @seq1 = seq1
          @seq2 = seq2
          @midline = midline
          @percent_identity = percent_identity
          @direction = direction
        end
        attr_reader :seq1, :seq2, :midline,
        :percent_identity, :direction

        def self.parse(str, aln)
	  /^(\d+)\-(\d+)\s*\((\d+)\-(\d+)\)\s*([\d\.]+)\%\s*([\-\<\>]*)/ =~ str
	  self.new(Segment.new($1, $2, aln[0]),
                   Segment.new($3, $4, aln[2]),
                   aln[1], $5, $6)
        end

        def self.seq1_intron(prev_e, e, aln)
          self.new(Segment.new(prev_e.seq1.to+1, e.seq1.from-1, aln[0]),
                   Segment.new(nil, nil, aln[2]),
                   aln[1])
        end

        def self.seq2_intron(prev_e, e, aln)
          self.new(Segment.new(nil, nil, aln[0]),
                   Segment.new(prev_e.seq2.to+1, e.seq2.from-1, aln[2]),
                   aln[1])
        end

        # Bio::BLAST::*::Report::Hsp compatible methods
        #   Methods already defined: midline, percent_identity
        def query_from; @seq1.from; end
        def query_to;   @seq1.to;   end
        def qseq;       @seq1.seq;  end
        def hit_from;   @seq2.from; end
        def hit_to;     @seq2.to;   end
        def hseq;       @seq2.seq;  end

        def align_len
          (@midline and @seq1.seq and @seq2.seq) ? @midline.length : nil
        end
      end #class SegmentPair
      
      class Segment
        # the segment of a sequence
        def initialize(pos_st, pos_ed, seq = nil)
          @from = pos_st.to_i
          @to   = pos_ed.to_i
          @seq  = seq
        end
        attr_reader :from, :to, :seq
      end #class Segment

      class Hit
        def initialize(str)
          @data = str.split(/\n(?:\r?\n)+/)
          parse_seqdesc
        end

        # seq1: query, seq2: target(hit)
        def parse_seqdesc
          a0 = @data.shift.split(/\r?\n/)
          if @data[0].to_s =~ /^\>/ then
            a1 = @data.shift.split(/\r?\n/)
          else
            a1 = []
          end
          @seq1 = SeqDesc.parse(a0[0], a1[0])
          @seq2 = SeqDesc.parse(a0[1], a1[1])
          
          if @data[0].to_s.sub!(/\A\(complement\)\s*$/, '') then
            @complement = true
            @data.shift if @data[0].strip.empty?
          else
            @complement = nil
          end
        end
        private :parse_seqdesc
        attr_reader :seq1, :seq2

        def complement?
          @complement
        end

        def parse_segmentpairs
          aln = (self.align ? self.align.dup : [])
          exo = [] #exons
          itr = [] #introns
          sgp = [] #segmentpairs
          prev_e = nil
          return unless @data[0]
          @data[0].split(/\r?\n/).each do |str|
            ai = (prev_e ? aln.shift : nil)
            a = (aln.shift or [])
            e = SegmentPair.parse(str, a)
            exo << e
            if ai then
              # intron data in alignment
              if ai[2].strip.empty? then
                i = SegmentPair.seq1_intron(prev_e, e, ai)
              else
                i = SegmentPair.seq2_intron(prev_e, e, ai)
              end
              itr << i
              sgp << i
            end
            sgp << e
            prev_e = e
          end
          @exons        = exo
          @introns      = itr
          @segmentpairs = sgp
        end
        private :parse_segmentpairs

        def parse_align
          s1 = []; ml = []; s2 = []
          dat = @data[1..-1]
          return unless dat
          dat.each do |str|
            a = str.split(/\r?\n/)
            a.shift
            if /^(\s*\d+\s*)(.+)$/ =~ a[0] then
              range = ($1.length)..($1.length + $2.strip.length - 1)
              a.collect! { |x| x[range] }
              s1 << a.shift
              ml << a.shift
              s2 << a.shift
            end
          end #each
          alx  = ml.join('').split(/([\<\>]+\.+[\<\>]+)/)
          seq1 = s1.join(''); seq2 = s2.join('')
          i = 0
          alx.collect! do |x|
            len = x.length
            y = [ seq1[i, len], x, seq2[i, len] ]
            i += len
            y
          end
          @align = alx
        end
        private :parse_align
        
        def exons
          unless defined?(@exons); parse_segmentpairs; end
          @exons
        end

        def segmentpairs
          unless defined?(@segmentpairs); parse_segmentpairs; end
          @segmentpairs
        end

        def introns
          unless defined?(@introns); parse_segmentpairs; end
          @introns
        end

        def align
          unless defined?(@align); parse_align; end
          @align
        end

        # Bio::BLAST::*::Report::Hit compatible methods
        def query_len;  seq1.len;        end
        def query_id;   seq1.entry_id;   end
        def query_def;  seq1.definition; end

        def target_len; seq2.len;        end
        def target_id;  seq2.entry_id;   end
        def target_def; seq2.definition; end

        alias hit_id     target_id
        alias len        target_len
        alias definition target_def

        alias hsps exons
        def each(&x); exons.each(&x); end
      end #class Hit

      #Bio::BLAST::*::Report compatible methods
      def num_hits;     @hits.size;     end
      def each_hit(&x); @hits.each(&x); end
      alias each each_hit
      def query_def; @seq1.definition; end
      def query_id;  @seq1.entry_id;   end
      def query_len; @seq1.len;        end
    end #class Report

  end #class Sim4
end #module Bio

=begin

= Bio::Sim4::Report

--- Bio::Sim4::Report.new(text)

    Creates new Bio::Sim4::Report object from String.
    You can use Bio::FlatFile to read a file.
  
    Currently, format A=0, A=3, and A=4 are supported.
    (A=1, A=2, A=5 are NOT supported yet.)

    Note that 'seq1' in sim4 result is always regarded as 'query',
    and 'seq2' is always regarded as 'subject'(target, hit).

    Note that first 'seq1' informations are used for
    Bio::Sim4::Report#query_id, #query_def, #query_len, and #seq1 methods.

--- Bio::Sim4::Report#hits

    Returns an Array of Bio::Sim4::Report::Hit objects.

--- Bio::Sim4::Report#all_hits

    Returns an Array of Bio::Sim4::Report::Hit objects.
    Unlike Bio::Sim4::Report#hits, the method returns
    results of all trials of pairwise alignment.
    This would be a Bio::Sim4 specific method.

--- Bio::Sim4::Report#each_hit
--- Bio::Sim4::Report#each

    Iterates over each Bio::Sim4::Report::Hit object.
    Same as hits.each.

--- Bio::Sim4::Report#num_hits

    Returns number of hits.
    Same as hits.size.

--- Bio::Sim4::Report#query_id

    Returns the identifier of query sequence.
    The value will be filename or (first word of) sequence definition
    according to sim4 run-time options.

--- Bio::Sim4::Report#query_def

    Returns the definition of query sequence.
    The value will be filename or (first word of) sequence definition
    according to sim4 run-time options.

--- Bio::Sim4::Report#query_len

    Returns the length of query sequence.

--- Bio::Sim4::Report#seq1

    Returns sequence informations of 'seq1'.
    Returns a Bio::Sim4::Report::SeqDesc object.
    This would be a Bio::Sim4 specific method.

== Bio::Sim4::Report::Hit

    Hit object of sim4 result.
    Similar to Bio::Blast::Report::Hit but lacks many methods.

--- Bio::Sim4::Report::Hit#hit_id
--- Bio::Sim4::Report::Hit#target_id

    Returns the identifier of subject sequence.
    The value will be filename or (first word of) sequence definition
    according to sim4 run-time options.

--- Bio::Sim4::Report::Hit#definition
--- Bio::Sim4::Report::Hit#target_def

    Returns the identifier of subject sequence.
    The value will be filename or (first word of) sequence definition
    according to sim4 run-time options.

--- Bio::Sim4::Report::Hit#len
--- Bio::Sim4::Report::Hit#target_len

    Returns the length of subject sequence.

--- Bio::Sim4::Report::Hit#query_id
--- Bio::Sim4::Report::Hit#query_def
--- Bio::Sim4::Report::Hit#query_len

    Same as Bio::Sim4::Report#(query_id|query_def|query_len).

--- Bio::Sim4::Report::Hit#exons

    Returns exons of the hit.
    Each exon is a Bio::Sim4::Report::SegmentPair object.

--- Bio::Sim4::Report::Hit#hsps

    Same as Bio::Sim4::Report#exons
    The method aims to provide compatibility between
    other homology search program's result objects.

--- Bio::Sim4::Report::Hit#each

    Iterates over each exon (Bio::Sim4::Report::SegmentPair object)
    of the hit.

--- Bio::Sim4::Report::Hit#segmentpairs

    Returns segment pairs (exons and introns) of the hit.
    Each segment pair is a Bio::Sim4::Report::SegmentPair object.
    Returns an array of Bio::Sim4::Report::SegmentPair objects.
    (Note that intron data is not always available
    according to run-time options of the program.)

--- Bio::Sim4::Report::Hit#introns

    Returns introns of the hit.
    Some of them would contain untranscribed regions.
    Returns an array of Bio::Sim4::Report::SegmentPair objects.
    (Note that intron data is not always available
    according to run-time options of the program.)

--- Bio::Sim4::Report::Hit#seq1
--- Bio::Sim4::Report::Hit#seq2

    Returns sequence informations of 'seq1' or 'seq2', respectively.
    Returns a Bio::Sim4::Report::SeqDesc object.
    These would be Bio::Sim4 specific methods.

--- Bio::Sim4::Report::Hit#complement?

    Returns true if the hit reports '-'(complemental) strand search result.
    Otherwise, return false or nil.
    This would be a Bio::Sim4 specific method.

--- Bio::Sim4::Report::Hit#align

    Returns alignments.
    Returns an Array of arrays.
    Each array contains sequence of seq1, midline, sequence of seq2,
    respectively.
    This would be a Bio::Sim4 specific method.

== Bio::Sim4::Report::SegmentPair

    Sequence segment pair of sim4 result.
    Similar to Bio::Blast::Report::HSP but lacks many methods.
    For mRNA-genome mapping programs, unlike other homology search programs,
    the class is used not only for exons but also for introns.
    (Note that intron data would not be available according to run-time
    options of the program.)

--- Bio::Sim4::Report::SegmentPair#query_from
--- Bio::Sim4::Report::SegmentPair#query_to
--- Bio::Sim4::Report::SegmentPair#qseq

--- Bio::Sim4::Report::SegmentPair#hit_from
--- Bio::Sim4::Report::SegmentPair#hit_to
--- Bio::Sim4::Report::SegmentPair#hseq

--- Bio::Sim4::Report::SegmentPair#midline

    Returns the "midline" of the segment pair.
    Returns nil if no alignment data are available.

--- Bio::Sim4::Report::SegmentPair#percent_identity

    Returns percent identity of the segment pair.

--- Bio::Sim4::Report::SegmentPair#align_len

    Returns alignment length of the segment pair.
    Returns nil if no alignment data are available.

--- Bio::Sim4::Report::SegmentPair#direction

    Returns directions of mapping.
    Maybe one of "->", "<-" or "" or nil.
    This would be a Bio::Sim4 specific method.

--- Bio::Sim4::Report::SegmentPair#seq1
--- Bio::Sim4::Report::SegmentPair#seq2

    Returns segment informations of 'seq1' or 'seq2', respectively.
    Returns a Bio::Sim4::Report::Segment object.
    These would be Bio::Sim4 specific methods.

== Bio::Sim4::Report::Segment

    Segment informations of a segment pair.

--- Bio::Sim4::Report::Segment#from
--- Bio::Sim4::Report::Segment#to
--- Bio::Sim4::Report::Segment#seq

== Bio::Sim4::Report::SeqDesc

    Sequence information of query or subject.

--- Bio::Sim4::Report::SeqDesc#filename
--- Bio::Sim4::Report::SeqDesc#entry_id
--- Bio::Sim4::Report::SeqDesc#definition
--- Bio::Sim4::Report::SeqDesc#len

= References

* ((<URL:http://www.genome.org/cgi/content/abstract/8/9/967>))
  Florea, L., et al., A Computer program for aligning a cDNA sequence
  with a genomic DNA sequence, Genome Research, 8, 967--974, 1998.

=end
