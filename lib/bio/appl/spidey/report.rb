#
# = bio/appl/spidey/report.rb - SPIDEY result parser
#
# Copyright:: Copyright (C) 2004 GOTO Naohisa <ng@bioruby.org>
# License::   The Ruby License
#
#  $Id: report.rb,v 1.10 2007/04/05 23:35:40 trevor Exp $
#
# NCBI Spidey result parser.
# Currently, output of default (-p 0 option) or -p 1 option are supported.
#
# == Notes
#
# The mRNA sequence is regarded as a query, and
# the enomic sequence is regarded as a target (subject, hit).
#
# == References
#
# * Wheelan, S.J., et al., Spidey: a tool for mRNA-to-genomic alignments,
#   Genome Research, 11, 1952--1957, 2001.
#   http://www.genome.org/cgi/content/abstract/11/11/1952
# * http://www.ncbi.nlm.nih.gov/spidey/
#

require 'bio'

module Bio
  class Spidey

    # Spidey report parser class.
    # Please see bio/appl/spidey/report.rb for details.
    #
    # Its object may contain some Bio::Spidey::Report::Hit objects.
    class Report #< DB
      #--
      # File format: -p 0 (default) or -p 1 options
      #++

      # Delimiter of each entry. Bio::FlatFile uses it.
      DELIMITER = RS = "\n--SPIDEY "

      # (Integer) excess read size included in DELIMITER.
      DELIMITER_OVERRUN = 9 # "--SPIDEY ".length

      # Creates a new Bio::Spidey::Report object from String.
      # You can use Bio::FlatFile to read a file.
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
      # piece of next entry. Bio::FlatFile uses it.
      attr_reader :entry_overrun

      # Returns an Array of Bio::Spidey::Report::Hit objects.
      # Because current version of SPIDEY supports only 1 genomic sequences,
      # the number of hits is 1 or 0.
      attr_reader :hits

      # Returns an Array of Bio::Spidey::Report::Hit objects.
      # Unlike Bio::Spidey::Report#hits, the method returns
      # results of all trials of pairwise alignment.
      # This would be a Bio::Spidey specific method.
      attr_reader :all_hits

      # SeqDesc stores sequence information of query or subject.
      class SeqDesc
        #--
        # description/definitions of a sequence
        #++

        # Creates a new SeqDesc object.
        # It is designed to be called from Bio::Spidey::Report::* classes.
        # Users shall not call it directly.
        def initialize(seqid, seqdef, len)
          @entry_id   = seqid
          @definition = seqdef
          @len        = len
        end

        # Identifier of the sequence.
        attr_reader :entry_id

        # Definition of the sequence.
        attr_reader :definition

        # Length of the sequence.
        attr_reader :len

        # Parses piece of Spidey result text and creates a new SeqDesc object.
        # It is designed to be called from Bio::Spidey::Report::* classes.
        # Users shall not call it directly.
        def self.parse(str)
          /^(Genomic|mRNA)\:\s*(([^\s]*) (.+))\, (\d+) bp\s*$/ =~ str.to_s
          seqid  = $3
          seqdef = $2
          len    = ($5 ? $5.to_i : nil)
          self.new(seqid, seqdef, len)
        end
      end #class SeqDesc

      # Sequence segment pair of Spidey result.
      # Similar to Bio::Blast::Report::Hsp but lacks many methods.
      # For mRNA-genome mapping programs, unlike other homology search
      # programs, the class is used not only for exons but also for introns.
      # (Note that intron data would not be available according to run-time
      # options of the program.)
      class SegmentPair
        #--
        # segment pair (like Bio::BLAST::*::Report::Hsp)
        #++

        # Creates a new SegmentPair object.
        # It is designed to be called from Bio::Spidey::Report::* classes.
        # Users shall not call it directly.
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

        # Returns segment informations of the 'Genomic'.
        # Returns a Bio::Spidey::Report::Segment object.
        # This would be a Bio::Spidey specific method.
        attr_reader :genomic

        # Returns segment informations of the 'mRNA'.
        # Returns a Bio::Spidey::Report::Segment object.
        # This would be a Bio::Spidey specific method.
        attr_reader :mrna

        # Returns the middle line of the alignment of the segment pair.
        # Returns nil if no alignment data are available.
        attr_reader :midline

        # Returns amino acide sequence in alignment.
        # Returns String, because white spaces is also important.
        # Returns nil if no alignment data are available.
        attr_reader :aaseqline

        # Returns percent identity of the segment pair.
        attr_reader :percent_identity

        # Returns mismatches.
        attr_reader :mismatches
        alias mismatch_count mismatches

        # Returns gaps.
        attr_reader :gaps

        # Returns splice site information.
        # Returns a hash which contains :d and :a for keys and
        # 0, 1, or nil for values.
        # This would be a Bio::Spidey specific methods.
        attr_reader :splice_site

        # Returns alignment length of the segment pair.
        # Returns nil if no alignment data are available.
        attr_reader :align_len

        # Creates a new SegmentPair object when the segment pair is an intron.
        # It is designed to be called internally from
        # Bio::Spidey::Report::* classes.
        # Users shall not call it directly.
        def self.new_intron(from, to, strand, aln)
          genomic   = Segment.new(from, to, strand, aln[0])
          mrna      = Segment.new(nil, nil, nil,    aln[2])
          midline   = aln[1]
          aaseqline = aln[3]
          self.new(genomic, mrna, midline, aaseqline,
                   nil, nil, nil, nil, nil)
        end

        # Parses a piece of Spidey result text and creates a new
        # SegmentPair object.
        # It is designed to be called internally from
        # Bio::Spidey::Report::* classes.
        # Users shall not call it directly.
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

        #--
        # Bio::BLAST::*::Report::Hsp compatible methods
        #   Methods already defined: midline, percent_identity, 
        #     gaps, align_len, mismatch_count
        #++

        # Returns start position of the mRNA (query) (the first position is 1).
        def query_from;   @mrna.from;       end

        # Returns end position (including its position) of the mRNA (query).
        def query_to;     @mrna.to;         end

        # Returns the sequence (with gaps) of the mRNA (query).
        def qseq;         @mrna.seq;        end

        # Returns strand information of the mRNA (query).
        # Returns 'plus', 'minus', or nil.
        def query_strand; @mrna.strand;     end

        # Returns start position of the genomic (target, hit)
        # (the first position is 1).
        def hit_from;     @genomic.from;    end

        # Returns end position (including its position) of the
        # genomic (target, hit).
        def hit_to;       @genomic.to;      end

        # Returns the sequence (with gaps) of the genomic (target, hit).
        def hseq;         @genomic.seq;     end

        # Returns strand information of the genomic (target, hit).
        # Returns 'plus', 'minus', or nil.
        def hit_strand;   @genomic.strand;  end
      end #class SegmentPair

      # Segment informations of a segment pair.
      class Segment
        # Creates a new Segment object.
        # It is designed to be called internally from
        # Bio::Spidey::Report::* classes.
        # Users shall not call it directly.
        def initialize(pos_st, pos_ed, strand = nil, seq = nil)
          @from   = pos_st ? pos_st.to_i : nil
          @to     = pos_ed ? pos_ed.to_i : nil
          @strand = strand
          @seq    = seq
        end

        # start position
        attr_reader :from

        # end position
        attr_reader :to

        # strand information
        attr_reader :strand

        # sequence data
        attr_reader :seq
      end #class Segment

      # Hit object of Spidey result.
      # Similar to Bio::Blast::Report::Hit but lacks many methods.
      class Hit
        # Creates a new Hit object.
        # It is designed to be called internally from
        # Bio::Spidey::Report::* classes.
        # Users shall not call it directly.
        def initialize(data, d0)
          @data = data
          @d0 = d0
        end

        # Fetches fields.
        def field_fetch(t, ary)
          reg = Regexp.new(/^#{Regexp.escape(t)}\:\s*(.+)\s*$/)
          if ary.find { |x| reg =~ x }
            $1.strip
          else
            nil
          end
        end
        private :field_fetch

        # Parses information about strand.
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

        # Returns strand information of the hit.
        # Returns 'plus', 'minus', or nil.
        # This would be a Bio::Spidey specific method.
        def strand
          unless defined?(@strand); parse_strand; end
          @strand
        end

        # Returns true if the result reports 'Reverse complement'.
        # Otherwise, return false or nil.
        # This would be a Bio::Spidey specific method.
        def complement?
          unless defined?(@complement); parse_strand; end
          @complement
        end

        # Returns number of exons in the hit.
        def number_of_exons
          unless defined?(@number_of_exons)
            @number_of_exons = field_fetch('Number of exons', @d0).to_i
          end
          @number_of_exons
        end

        # Returns number of splice sites of the hit.
        def number_of_splice_sites
          unless defined?(@number_of_splice_sites)
            @number_of_splice_sites = 
              field_fetch('Number of splice sites', @d0).to_i
          end
          @number_of_splice_sites
        end

        #  Returns overall percent identity of the hit.
        def percent_identity
          unless defined?(@percent_identity)
            x = field_fetch('overall percent identity', @d0)
            @percent_identity = 
              (/([\d\.]+)\s*\%/ =~ x.to_s) ? $1 : nil
          end
          @percent_identity
        end

        # Returns missing mRNA ends of the hit.
        def missing_mrna_ends
          unless defined?(@missing_mrna_ends)
            @missing_mrna_ends = field_fetch('Missing mRNA ends', @d0)
          end
          @missing_mrna_ends
        end

        # Returns sequence informations of the 'Genomic'.
        # Returns a Bio::Spidey::Report::SeqDesc object.
        # This would be a Bio::Spidey specific method.
        def genomic
          unless defined?(@genomic)
            @genomic = SeqDesc.parse(@d0.find { |x| /^Genomic\:/ =~ x })
          end
          @genomic
        end
        
        # Returns sequence informations of the mRNA.
        # Returns a Bio::Spidey::Report::SeqDesc object.
        # This would be a Bio::Spidey specific method.
        def mrna
          unless defined?(@mrna)
            @mrna = SeqDesc.parse(@d0.find { |x| /^mRNA\:/ =~ x })
          end
          @mrna
        end

        # Parses segment pairs.
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
            #p x
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

        # Returns exons of the hit.
        # Returns an array of Bio::Spidey::Report::SegmentPair object.
        def exons
          unless defined?(@exons); parse_segmentpairs; end
          @exons
        end

        # Returns introns of the hit.
        # Some of them would contain untranscribed regions.
        # Returns an array of Bio::Spidey::Report::SegmentPair objects.
        # (Note that intron data is not always available
        # according to run-time options of the program.)
        def introns
          unless defined?(@introns); parse_segmentpairs; end
          @introns
        end

        # Returns segment pairs (exons and introns) of the hit.
        # Each segment pair is a Bio::Spidey::Report::SegmentPair object.
        # Returns an array of Bio::Spidey::Report::SegmentPair objects.
        # (Note that intron data is not always available
        # according to run-time options of the program.)
        def segmentpairs
          unless defined?(@segmentparis); parse_segmentpairs; end
          @segmentpairs
        end

        # Returns alignments.
        # Returns an Array of arrays.
        # This would be a Bio::Spidey specific method.
        def align
          unless defined?(@align); parse_align; end
          @align
        end

        # Parses alignment lines.
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

        # Parses alignments.
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

        #--
        # Bio::BLAST::*::Report::Hit compatible methods
        #++

        # Length of the mRNA (query) sequence.
        # Same as Bio::Spidey::Report#query_len.
        def query_len;  mrna.len;        end

        # Identifier of the mRNA (query).
        # Same as Bio::Spidey::Report#query_id.
        def query_id;   mrna.entry_id;   end

        # Definition of the mRNA (query).
        # Same as Bio::Spidey::Report#query_def.
        def query_def;  mrna.definition; end

        # The genomic (target) sequence length.
        def target_len; genomic.len;        end

        # Identifier of the genomic (target) sequence.
        def target_id;  genomic.entry_id;   end

        # Definition of the genomic (target) sequence.
        def target_def; genomic.definition; end

        alias hit_id     target_id
        alias len        target_len
        alias definition target_def

        alias hsps exons

        # Iterates over each exon of the hit.
        # Yields Bio::Spidey::Report::SegmentPair object.
        def each(&x) #:yields: segmentpair
          exons.each(&x)
        end
      end #class Hit

      # Returns sequence informationsof the mRNA.
      # Returns a Bio::Spidey::Report::SeqDesc object.
      # This would be a Bio::Spidey specific method.
      def mrna; @hit.mrna; end

      #--
      #Bio::BLAST::*::Report compatible methods
      #++

      # Returns number of hits.
      # Same as hits.size.
      def num_hits;     @hits.size;     end

      # Iterates over each hits.
      # Same as hits.each.
      # Yields a Bio::Spidey::Report::Hit object.
      def each_hit(&x) #:yields: hit
        @hits.each(&x)
      end
      alias each each_hit

      # Returns definition of the mRNA (query) sequence.
      def query_def; @hit.mrna.definition; end

      # Returns identifier of the mRNA (query) sequence.
      def query_id;  @hit.mrna.entry_id;   end

      # Returns the length of the mRNA (query) sequence.
      def query_len; @hit.mrna.len;        end
    end #class Report

  end #class Spidey
end #module Bio

