#
# bio/appl/spidey/report.rb - SPIDEY result parser
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
#  $Id: report.rb,v 1.2 2004/10/13 16:53:03 ngoto Exp $
#

require 'bio'

module Bio
  class Spidey

    class Report #< DB
      # 
      # File format: -p 0 (default) or -p 1 options

      DELIMITER = RS = "\n--SPIDEY "

      def initialize(str)
	str = str.sub(/\A\s+/, '')
	str.sub!(/\n(^\-\-SPIDEY .*)/m, '')  # remove trailing entries for sure
	@entry_overrun = $1
	data = str.split(/\r?\n(?:\r?\n)+/)
	d0 = data.shift.to_s.split(/\r?\n/)
        @hit = Hit.new(data, d0)
        @all_hits = [ @hit ]
        if d0.empty? or /\ANo alignment found\.\s*\z/ =~ d0[-1] then
          @hits = []
        else
          @hits = [ @hit ]
        end
      end
      attr_reader :entry_overrun
      attr_reader :hits, :all_hits

      class SeqDesc
        # description/definitions of a sequence
        def initialize(seqid, seqdef, len)
          @entry_id   = seqid
          @definition = seqdef
          @len        = len
        end
        attr_reader :entry_id, :definition, :len

	def self.parse(str)
	  /^(Genomic|mRNA)\:\s*(([^\s]*) (.+))\, (\d+) bp\s*$/ =~ str.to_s
	  seqid  = $3
          seqdef = $2
	  len    = ($5 ? $5.to_i : nil)
          self.new(seqid, seqdef, len)
	end
      end #class SeqDesc

      class SegmentPair
        # segment pair (like Bio::BLAST::*::Report::HSP)
        def initialize(genomic, mrna, midline, aaseqline,
                       percent_identity, mismatches, gaps, splice_site,
                       align_len)
          @genomic   = genomic
          @mrna      = mrna
          @midline   = midline
          @aaseqline = aaseqline
          @percent_identity = percent_identity
          @mismaches        = mismatches
          @gaps             = gaps
          @splice_site      = splice_site
          @align_len        = align_len
        end
        attr_reader :genomic, :mrna, :midline, :aaseqline,
        :percent_identity, :mismatches, :gaps,
        :splice_site, :align_len

        def self.new_intron(from, to, strand, aln)
          genomic   = Segment.new(from, to, strand, aln[0])
          mrna      = Segment.new(nil, nil, nil,    aln[2])
	  midline   = aln[1]
	  aaseqline = aln[3]
          self.new(genomic, mrna, midline, aaseqline,
                   nil, nil, nil, nil, nil)
        end
        
        def self.parse(str, strand, complement, aln)
	  /\AExon\s*\d+(\(\-\))?\:\s*(\d+)\-(\d+)\s*\(gen\)\s+(\d+)\-(\d+)\s*\(mRNA\)\s+id\s*([\d\.]+)\s*\%\s+mismatches\s+(\d+)\s+gaps\s+(\d+)\s+splice site\s*\(d +a\)\s*\:\s*(\d+)\s+(\d+)/ =~ str
          if strand == 'minus' then
            genomic = Segment.new($3, $2, strand, aln[0])
          else
            genomic = Segment.new($2, $3, 'plus', aln[0])
          end
          if complement then
            mrna    = Segment.new($4, $5, 'minus', aln[2])
          else
            mrna    = Segment.new($4, $5, 'plus',  aln[2])
          end
	  percent_identity = $6
	  mismatches = ($7 ? $7.to_i : nil)
	  gaps = ($8 ? $8.to_i : nil)
	  splice_site = {
	    :d => ($9  ? $9.to_i  : nil),
	    :a => ($10 ? $10.to_i : nil)
	  }
	  midline   = aln[1]
	  aaseqline = aln[3]
          self.new(genomic, mrna, midline, aaseqline,
                   percent_identity, mismatches, gaps, splice_site,
                   (midline ? midline.length : nil))
	end

        # Bio::BLAST::*::Report::Hsp compatible methods
        #   Methods already defined: midline, percent_identity, 
        #     gaps, align_len
        alias mismatch_count mismatches
        def query_from;   @mrna.from;       end
        def query_to;     @mrna.to;         end
        def qseq;         @mrna.seq;        end
        def query_strand; @mrna.strand;     end
        def hit_from;     @genomic.from;    end
        def hit_to;       @genomic.to;      end
        def hseq;         @genomic.seq;     end
        def hit_strand;   @genomic.strand;  end
      end #class SegmentPair

      class Segment
        def initialize(pos_st, pos_ed, strand = nil, seq = nil)
          @from   = pos_st ? pos_st.to_i : nil
          @to     = pos_ed ? pos_ed.to_i : nil
          @strand = strand
          @seq    = seq
        end
        attr_reader :from, :to, :strand, :seq
      end #class Segment

      class Hit
        def initialize(data, d0)
          @data = data
          @d0 = d0
        end

        def field_fetch(t, ary)
          reg = Regexp.new(/^#{Regexp.escape(t)}\:\s*(.+)\s*$/)
          if ary.find { |x| reg =~ x }
            $1.strip
          else
            nil
          end
        end
        private :field_fetch

        def parse_strand
          x = field_fetch('Strand', @d0)
          if x =~ /^(.+)Reverse +complement\s*$/ then
            @strand = $1.strip
            @complement = true
          else
            @strand = x
            @complement = nil
          end
        end
        private :parse_strand

        def strand
          unless defined?(@strand); parse_strand; end
          @strand
        end

        def complement?
          unless defined?(@complement); parse_strand; end
          @complement
        end

        def number_of_exons
          unless defined?(@number_of_exons)
            @number_of_exons = field_fetch('Number of exons', @d0).to_i
          end
          @number_of_exons
        end

        def number_of_splice_sites
          unless defined?(@number_of_splice_sites)
            @number_of_splice_sites = 
              field_fetch('Number of splice sites', @d0).to_i
          end
          @number_of_splice_sites
        end

        def percent_identity
          unless defined?(@percent_identity)
            x = field_fetch('overall percent identity', @d0)
            @percent_identity = 
              (/([\d\.]+)\s*\%/ =~ x.to_s) ? $1 : nil
          end
          @percent_identity
        end

        def missing_mrna_ends
          unless defined?(@missing_mrna_ends)
            @missing_mrna_ends = field_fetch('Missing mRNA ends', @d0)
          end
          @missing_mrna_ends
        end

        def genomic
          unless defined?(@genomic)
            @genomic = SeqDesc.parse(@d0.find { |x| /^Genomic\:/ =~ x })
          end
          @genomic
        end
        
        def mrna
          unless defined?(@mrna)
            @mrna = SeqDesc.parse(@d0.find { |x| /^mRNA\:/ =~ x })
          end
          @mrna
        end

        def parse_segmentpairs
          aln = self.align.dup
          ex = []
          itr = []
          segpairs = []
          cflag  = self.complement?
          strand = self.strand
          if strand == 'minus' then
            d_to = 1;  d_from = -1
          else
            d_to = -1; d_from = 1
          end
          @d0.each do |x|
            p x
            if x =~ /^Exon\s*\d+(\(.*\))?\:/ then
              if a = aln.shift then
                y = SegmentPair.parse(x, strand, cflag, a[1])
                ex << y
                if a[0][0].to_s.length > 0 then
                  to = y.genomic.from + d_to
                  i0 = SegmentPair.new_intron(nil, to, strand, a[0])
                  itr << i0
                  segpairs << i0
                end
                segpairs << y
                if a[2][0].to_s.length > 0 then
                  from = y.genomic.to + d_from
                  i2 = SegmentPair.new_intron(from, nil, strand, a[2])
                  itr << i2
                  segpairs << i2
                end
              else
                y = SegmentPair.parse(x, strand, cflag, [])
                ex << y
                segpairs << y
              end
            end
          end
          @exons = ex
          @introns = itr
          @segmentpairs = segpairs
        end
        private :parse_segmentpairs
        
        def exons
          unless defined?(@exons); parse_segmentpairs; end
          @exons
        end

        def introns
          unless defined?(@introns); parse_segmentpairs; end
          @introns
        end

        def segmentpairs
          unless defined?(@segmentparis); parse_segmentpairs; end
          @segmentpairs
        end

        def align
          unless defined?(@align); parse_align; end
          @align
        end

        def parse_align_lines(data)
          misc = [ [], [], [], [] ]
          data.each do |x|
            a = x.split(/\r?\n/)
            if g = a.shift then
              misc[0] << g
              (1..3).each do |i|
                if y = a.shift then
                  if y.length < g.length
                    y << ' ' * (g.length - y.length)
                  end
                  misc[i] << y
                else
                  misc[i] << ' ' * g.length
                end
              end
            end
          end
          misc.collect! { |x| x.join('') }
          left = []
          if /\A +/ =~ misc[2] then
            len = $&.size
            left = misc.collect { |x| x[0, len] }
            misc.each { |x| x[0, len] = '' }
          end
          right = []
          if / +\z/ =~ misc[2] then
            len = $&.size
            right = misc.collect { |x| x[(-len)..-1] }
            misc.each { |x| x[(-len)..-1] = '' }
          end
          body = misc
          [ left, body, right ]
        end
        private :parse_align_lines

        def parse_align
          r = []
          data = @data
          while !data.empty?
            a = []
            while x = data.shift and !(x =~ /^(Genomic|Exon\s*\d+)\:/)
              a.push x
            end
            r.push parse_align_lines(a) unless a.empty?
          end
          @align = r
        end
        private :parse_align

        # Bio::BLAST::*::Report::Hit compatible methods
        def query_len;  @mrna.len;        end
        def query_id;   @mrna.entry_id;   end
        def query_def;  @mrna.definition; end

        def target_len; @genomic.len;        end
        def target_id;  @genomic.entry_id;   end
        def target_def; @genomic.definition; end

        alias hit_id     target_id
        alias len        target_len
        alias definition target_def

        alias hsps exons
        def each(&x); exons.each(&x); end
      end #class Hit

      def mrna; @hit.mrna; end

      #Bio::BLAST::*::Report compatible methods
      def num_hits;     @hits.size;     end
      def each_hit(&x); @hits.each(&x); end
      alias each each_hit
      def query_def; @hit.mrna.definition; end
      def query_id;  @hit.mrna.entry_id;   end
      def query_len; @hit.mrna.len;        end
    end #class Report

  end #class Spidey
end #module Bio

=begin

= Bio::Spidey::Report

--- Bio::Spidey::Report.new(text)

    Creates new Bio::Spidey::Report object from String.
    You can use Bio::FlatFile to read a file.
  
    Currently, result created with options -p 0 (default) or -p 1 
    are supported.

    Note that "mRNA" is always regarded as "query" and
    "Genomic" is always regarded as "subject"(target, hit).

--- Bio::Spidey::Report#hits

    Returns an Array of Bio::Spidey::Report::Hit objects.
    Because current version of SPIDEY supports only 1 genomic sequences,
    the number of hits is 1 or 0.

--- Bio::Spidey::Report#all_hits

    Returns an Array of Bio::Spidey::Report::Hit objects.
    Unlike Bio::Spidey::Report#hits, the method returns
    results of all trials of pairwise alignment.
    This would be a Bio::Spidey specific method.

--- Bio::Spidey::Report#each_hit
--- Bio::Spidey::Report#each

    Iterates over each Bio::Spidey::Report::Hit object.
    Same as hits.each.

--- Bio::Spidey::Report#num_hits

    Returns number of hits.
    Same as hits.size.

--- Bio::Spidey::Report#query_id

    Returns the identifier of query sequence.

--- Bio::Spidey::Report#query_def

    Returns the definition of query sequence.

--- Bio::Spidey::Report#query_len

    Returns the length of query sequence.

--- Bio::Spidey::Report#mrna

    Returns sequence informations of "mRNA".
    Returns a Bio::Spidey::Report::SeqDesc object.
    This would be a Bio::Spidey specific method.

== Bio::Spidey::Report::Hit

    Hit object of SPIDEY result.
    Similar to Bio::Blast::Report::Hit but lacks many methods.

--- Bio::Spidey::Report::Hit#hit_id
--- Bio::Spidey::Report::Hit#target_id

    Returns the identifier of subject sequence.

--- Bio::Spidey::Report::Hit#definition
--- Bio::Spidey::Report::Hit#target_def

    Returns the identifier of subject sequence.

--- Bio::Spidey::Report::Hit#len
--- Bio::Spidey::Report::Hit#target_len

    Returns the length of subject sequence.

--- Bio::Spidey::Report::Hit#query_id
--- Bio::Spidey::Report::Hit#query_def
--- Bio::Spidey::Report::Hit#query_len

    Same as Bio::Spidey::Report#(query_id|query_def|query_len).

--- Bio::Spidey::Report::Hit#exons

    Returns exons of the hit.
    Each exon is a Bio::Spidey::Report::SegmentPair object.

--- Bio::Spidey::Report::Hit#hsps

    Same as Bio::Spidey::Report#exons
    The method aims to provide compatibility between
    other homology search program's result objects.

--- Bio::Spidey::Report::Hit#each

    Iterates over each exon (Bio::Spidey::Report::SegmentPair object)
    of the hit.

--- Bio::Spidey::Report::Hit#segmentpairs

    Returns segment pairs (exons and introns) of the hit.
    Each segment pair is a Bio::Spidey::Report::SegmentPair object.
    Returns an array of Bio::Spidey::Report::SegmentPair objects.
    (Note that intron data is not always available
    according to run-time options of the program.)

--- Bio::Spidey::Report::Hit#introns

    Returns introns of the hit.
    Some of them would contain untranscribed regions.
    Returns an array of Bio::Spidey::Report::SegmentPair objects.
    (Note that intron data is not always available
    according to run-time options of the program.)

--- Bio::Spidey::Report::Hit#mrna
--- Bio::Spidey::Report::Hit#genomic

    Returns sequence informations of "mRNA" or "Genomic", respectively.
    Returns a Bio::Spidey::Report::SeqDesc object.
    These would be Bio::Spidey specific methods.

--- Bio::Spidey::Report::Hit#strand

    Returns strand information of the hit.
    Returns 'plus', 'minus', or nil.
    This would be a Bio::Spidey specific method.

--- Bio::Spidey::Report::Hit#complement?

    Returns true if the result reports 'Reverse complement'.
    Otherwise, return false or nil.
    This would be a Bio::Spidey specific method.

--- Bio::Spidey::Report::Hit#align

    Returns alignments.
    Returns an Array of arrays.
    This would be a Bio::Spidey specific method.

== Bio::Spidey::Report::SegmentPair

    Sequence segment pair of SPIDEY result.
    Similar to Bio::Blast::Report::HSP but lacks many methods.
    For mRNA-genome mapping programs, unlike other homology search programs,
    the class is used not only for exons but also for introns.
    (Note that intron data would not be available according to run-time
    options of the program.)

--- Bio::Spidey::Report::SegmentPair#query_from
--- Bio::Spidey::Report::SegmentPair#query_to
--- Bio::Spidey::Report::SegmentPair#qseq

--- Bio::Spidey::Report::SegmentPair#hit_from
--- Bio::Spidey::Report::SegmentPair#hit_to
--- Bio::Spidey::Report::SegmentPair#hseq

--- Bio::Spidey::Report::SegmentPair#query_strand
--- Bio::Spidey::Report::SegmentPair#hit_strand

    Returns strand information of query or hit, respectively.
    Returns 'plus', 'minus', or nil.

--- Bio::Spidey::Report::SegmentPair#gaps

    Returns gaps.

--- Bio::Spidey::Report::SegmentPair#mismatches
--- Bio::Spidey::Report::SegmentPair#mismatch_count

    Returns mismatches.

--- Bio::Spidey::Report::SegmentPair#midline

    Returns the "midline" of the segment pair.
    Returns nil if no alignment data are available.

--- Bio::Spidey::Report::SegmentPair#percent_identity

    Returns percent identity of the segment pair.

--- Bio::Spidey::Report::SegmentPair#align_len

    Returns alignment length of the segment pair.
    Returns nil if no alignment data are available.

--- Bio::Spidey::Report::SegmentPair#aaseqline

    Returns amino acide sequence in alignment.
    Returns String, because white spaces in the result is also important.
    Returns nil if no alignment data are available.
    This would be a Bio::Spidey specific methods.

--- Bio::Spidey::Report::SegmentPair#splice_site

    Returns splice site information.
    Returns a hash which contains :d and :a for keys and
    0, 1, or nil for values.
    This would be a Bio::Spidey specific methods.

--- Bio::Spidey::Report::SegmentPair#mrna
--- Bio::Spidey::Report::SegmentPair#genomic

    Returns segment informations of 'mRNA' or 'Genomic', respectively.
    Returns a Bio::Spidey::Report::Segment object.
    These would be Bio::Spidey specific methods.

== Bio::Spidey::Report::Segment

    Segment informations of a segment pair.

--- Bio::Spidey::Report::Segment#from
--- Bio::Spidey::Report::Segment#to
--- Bio::Spidey::Report::Segment#seq
--- Bio::Spidey::Report::Segment#strand

== Bio::Spidey::Report::SeqDesc

    Sequence information of query or subject.

--- Bio::Spidey::Report::SeqDesc#entry_id
--- Bio::Spidey::Report::SeqDesc#definition
--- Bio::Spidey::Report::SeqDesc#len

= References

* ((<URL:http://www.genome.org/cgi/content/abstract/11/11/1952>))
  Wheelan, S.J., et al., Spidey: a tool for mRNA-to-genomic alignments,
  Genome Research, 11, 1952--1957, 2001.

=end
