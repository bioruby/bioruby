#
# = bio/appl/sim4/report.rb - sim4 result parser
#
# Copyright:: Copyright (C) 2004 GOTO Naohisa <ng@bioruby.org>
# License::   The Ruby License
#
#  $Id: report.rb,v 1.9 2007/04/05 23:35:40 trevor Exp $
#
# The sim4 report parser classes.
#
# == References
#
# * Florea, L., et al., A Computer program for aligning a cDNA sequence
#   with a genomic DNA sequence, Genome Research, 8, 967--974, 1998.
#   http://www.genome.org/cgi/content/abstract/8/9/967
#

module Bio
  class Sim4

    # Bio::Sim4::Report is the sim4 report parser class.
    # Its object may contain some Bio::Sim4::Report::Hit objects.
    class Report #< DB
      #--
      # format: A=0, A=3, or A=4
      #++

      # Delimiter of each entry. Bio::FlatFile uses it.
      # In Bio::Sim4::Report, it it nil (1 entry 1 file).
      DELIMITER = RS = nil # 1 entry 1 file

      # Creates new Bio::Sim4::Report object from String.
      # You can use Bio::FlatFile to read a file.
      # Currently, format A=0, A=3, and A=4 are supported.
      # (A=1, A=2, A=5 are NOT supported yet.)
      #
      # Note that 'seq1' in sim4 result is always regarded as 'query',
      # and 'seq2' is always regarded as 'subject'(target, hit).
      #
      # Note that first 'seq1' informations are used for
      # Bio::Sim4::Report#query_id, #query_def, #query_len, and #seq1 methods.
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

      # Returns hits of the entry.
      # Unlike Bio::Sim4::Report#all_hits, it returns
      # hits which have alignments.
      # Returns an Array of Bio::Sim4::Report::Hit objects.
      attr_reader :hits

      # Returns all hits of the entry.
      # Unlike Bio::Sim4::Report#hits, it returns
      # results of all trials of pairwise alignment.
      # This would be a Bio::Sim4 specific method.
      # Returns an Array of Bio::Sim4::Report::Hit objects.
      attr_reader :all_hits

      # Returns sequence informations of 'seq1'.
      # Returns a Bio::Sim4::Report::SeqDesc object.
      # This would be a Bio::Sim4 specific method.
      attr_reader :seq1

      # Bio::Sim4::Report::SeqDesc stores sequence information of
      # query or subject of sim4 report.
      class SeqDesc
        #--
        # description/definitions of a sequence
        #++

        # Creates a new object.
        # It is designed to be called internally from Bio::Sim4::Report object.
        # Users shall not use it directly.
        def initialize(seqid, seqdef, len, filename)
          @entry_id   = seqid
          @definition = seqdef
          @len        = len
          @filename   = filename
        end
        # identifier of the sequence
        attr_reader :entry_id
        # definition of the sequence
        attr_reader :definition
        # sequence length of the sequence
        attr_reader :len
        # filename of the sequence
        attr_reader :filename

        # Parses part of sim4 result text and creates new SeqDesc object.
        # It is designed to be called internally from Bio::Sim4::Report object.
        # Users shall not use it directly.
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


      # Sequence segment pair of the sim4 result.
      # Similar to Bio::Blast::Report::HSP but lacks many methods.
      # For mRNA-genome mapping programs,
      # unlike other homology search programs,
      # the class is used not only for exons but also for introns.
      # (Note that intron data would not be available according to run-time
      # options of the program.)
      class SegmentPair
        #--
        # segment pair (like Bio::BLAST::*::Report::HSP)
        #++

        # Creates a new SegmentPair object.
        # It is designed to be called internally from
        # Bio::Sim4::Report::Hit object.
        # Users shall not use it directly.
        def initialize(seq1, seq2, midline = nil,
                       percent_identity = nil, direction = nil)
          @seq1 = seq1
          @seq2 = seq2
          @midline = midline
          @percent_identity = percent_identity
          @direction = direction
        end
        # Returns segment informations of 'seq1'.
        # Returns a Bio::Sim4::Report::Segment object.
        # These would be Bio::Sim4 specific methods.
        attr_reader :seq1
        # Returns segment informations of 'seq2'.
        # Returns a Bio::Sim4::Report::Segment object.
        # These would be Bio::Sim4 specific methods.
        attr_reader :seq2

        # Returns the "midline" of the segment pair.
        # Returns nil if no alignment data are available.
        attr_reader :midline

        # Returns percent identity of the segment pair.
        attr_reader :percent_identity

        # Returns directions of mapping.
        # Maybe one of "->", "<-" or "" or nil.
        # This would be a Bio::Sim4 specific method.
        attr_reader :direction

        # Parses part of sim4 result text and creates a new SegmentPair object.
        # It is designed to be called internally from
        # Bio::Sim4::Report::Hit class.
        # Users shall not use it directly.
        def self.parse(str, aln)
          /^(\d+)\-(\d+)\s*\((\d+)\-(\d+)\)\s*([\d\.]+)\%\s*([\-\<\>]*)/ =~ str
          self.new(Segment.new($1, $2, aln[0]),
                   Segment.new($3, $4, aln[2]),
                   aln[1], $5, $6)
        end

        # Parses part of sim4 result text and creates a new SegmentPair
        # object when the seq1 is a intron.
        # It is designed to be called internally from
        # Bio::Sim4::Report::Hit class.
        # Users shall not use it directly.
        def self.seq1_intron(prev_e, e, aln)
          self.new(Segment.new(prev_e.seq1.to+1, e.seq1.from-1, aln[0]),
                   Segment.new(nil, nil, aln[2]),
                   aln[1])
        end

        # Parses part of sim4 result text and creates a new SegmentPair
        # object when seq2 is a intron.
        # It is designed to be called internally from
        # Bio::Sim4::Report::Hit class.
        # Users shall not use it directly.
        def self.seq2_intron(prev_e, e, aln)
          self.new(Segment.new(nil, nil, aln[0]),
                   Segment.new(prev_e.seq2.to+1, e.seq2.from-1, aln[2]),
                   aln[1])
        end

        #--
        # Bio::BLAST::*::Report::Hsp compatible methods
        #   Methods already defined: midline, percent_identity
        #++

        # start position of the query (the first position is 1)
        def query_from; @seq1.from; end

        # end position of the query (including its position)
        def query_to;   @seq1.to;   end

        # query sequence (with gaps) of the alignment of the segment pair.
        def qseq;       @seq1.seq;  end

        # start position of the hit(target) (the first position is 1)
        def hit_from;   @seq2.from; end

        # end position of the hit(target) (including its position)
        def hit_to;     @seq2.to;   end

        # hit(target) sequence (with gaps) of the alignment
        # of the segment pair.
        def hseq;       @seq2.seq;  end

        # Returns alignment length of the segment pair.
        # Returns nil if no alignment data are available.
        def align_len
          (@midline and @seq1.seq and @seq2.seq) ? @midline.length : nil
        end
      end #class SegmentPair
      
      # Segment informations of a segment pair.
      class Segment
        #--
        # the segment of a sequence
        #++

        # Creates a new Segment object.
        # It is designed to be called internally from
        # Bio::Sim4::Report::SegmentPair class.
        # Users shall not use it directly.
        def initialize(pos_st, pos_ed, seq = nil)
          @from = pos_st.to_i
          @to   = pos_ed.to_i
          @seq  = seq
        end
        # start position of the segment (the first position is 1)
        attr_reader :from
        # end position of the segment (including its position)
        attr_reader :to
        # sequence (with gaps) of the segment
        attr_reader :seq
      end #class Segment

      # Hit object of the sim4 result.
      # Similar to Bio::Blast::Report::Hit but lacks many methods.
      class Hit

        # Parses part of sim4 result text and creates a new Hit object.
        # It is designed to be called internally from Bio::Sim4::Report class.
        # Users shall not use it directly.
        def initialize(str)
          @data = str.split(/\n(?:\r?\n)+/)
          parse_seqdesc
        end

        # Parses sequence descriptions.
        def parse_seqdesc
          # seq1: query, seq2: target(hit)
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

        # Returns sequence informations of 'seq1'.
        # Returns a Bio::Sim4::Report::SeqDesc object.
        # This would be Bio::Sim4 specific method.
        attr_reader :seq1

        # Returns sequence informations of 'seq2'.
        # Returns a Bio::Sim4::Report::SeqDesc object.
        # This would be Bio::Sim4 specific method.
        attr_reader :seq2

        # Returns true if the hit reports '-'(complemental) strand
        # search result.
        # Otherwise, return false or nil.
        # This would be a Bio::Sim4 specific method.
        def complement?
          @complement
        end

        # Parses segment pair.
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

        # Parses alignment.
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

        # Returns exons of the hit.
        # Each exon is a Bio::Sim4::Report::SegmentPair object.
        def exons
          unless defined?(@exons); parse_segmentpairs; end
          @exons
        end

        # Returns segment pairs (exons and introns) of the hit.
        # Each segment pair is a Bio::Sim4::Report::SegmentPair object.
        # Returns an array of Bio::Sim4::Report::SegmentPair objects.
        # (Note that intron data is not always available
        # according to run-time options of the program.)
        def segmentpairs
          unless defined?(@segmentpairs); parse_segmentpairs; end
          @segmentpairs
        end

        # Returns introns of the hit.
        # Some of them would contain untranscribed regions.
        # Returns an array of Bio::Sim4::Report::SegmentPair objects.
        # (Note that intron data is not always available
        # according to run-time options of the program.)
        def introns
          unless defined?(@introns); parse_segmentpairs; end
          @introns
        end

        # Returns alignments.
        # Returns an Array of arrays.
        # Each array contains sequence of seq1, midline, sequence of seq2,
        # respectively.
        # This would be a Bio::Sim4 specific method.
        def align
          unless defined?(@align); parse_align; end
          @align
        end

        #--
        # Bio::BLAST::*::Report::Hit compatible methods
        #++

        # Length of the query sequence.
        # Same as Bio::Sim4::Report#query_len.
        def query_len;  seq1.len;        end

        # Identifier of the query sequence.
        # Same as Bio::Sim4::Report#query_id.
        def query_id;   seq1.entry_id;   end

        # Definition of the query sequence
        # Same as Bio::Sim4::Report#query_def.
        def query_def;  seq1.definition; end

        # length of the hit(target) sequence
        def target_len; seq2.len;        end

        # Identifier of the hit(target) sequence
        def target_id;  seq2.entry_id;   end

        # Definition of the hit(target) sequence
        def target_def; seq2.definition; end

        alias hit_id     target_id
        alias len        target_len
        alias definition target_def

        alias hsps exons

        # Iterates over each exon of the hit.
        # Yields a Bio::Sim4::Report::SegmentPair object.
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

      # Iterates over each hits of the sim4 result.
      # Same as hits.each.
      # Yields a Bio::Sim4::Report::Hit object.
      def each_hit(&x) #:yields: hit
        @hits.each(&x)
      end
      alias each each_hit

      # Returns the definition of query sequence.
      # The value will be filename or (first word of) sequence definition
      # according to sim4 run-time options.
      def query_def; @seq1.definition; end

      # Returns the identifier of query sequence.
      # The value will be filename or (first word of) sequence definition
      # according to sim4 run-time options.
      def query_id;  @seq1.entry_id;   end

      # Returns the length of query sequence.
      def query_len; @seq1.len;        end
    end #class Report

  end #class Sim4
end #module Bio

=begin

= Bio::Sim4::Report

= References

* ((<URL:http://www.genome.org/cgi/content/abstract/8/9/967>))
  Florea, L., et al., A Computer program for aligning a cDNA sequence
  with a genomic DNA sequence, Genome Research, 8, 967--974, 1998.

=end
