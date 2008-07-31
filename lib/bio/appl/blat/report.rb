#
# = bio/appl/blat/report.rb - BLAT result parser
#
# Copyright:: Copyright (C) 2004 GOTO Naohisa <ng@bioruby.org>
# License:: The Ruby License
#
#  $Id: report.rb,v 1.13 2007/04/05 23:35:39 trevor Exp $
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
# * http://genome.ucsc.edu/goldenPath/help/blatSpec.html

require 'bio'

module Bio
  class Blat

    # Bio::Blat::Report is a BLAT report parser class.
    # Its object may contain some Bio::Blat::Report::Hits objects.
    #
    # In BLAT results, the start position of a sequnece is numbered as 0.
    # On the other hand, in many other homology search programs,
    # the start position of a sequence is numbered as 1.
    # To keep compatibility, the BLAT parser adds 1 to every position number
    # except Bio::Blat::Report::Seqdesc and some Bio::Blat specific methods.
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

      # Splitter for Bio::FlatFile
      FLATFILE_SPLITTER = Bio::FlatFile::Splitter::LineOriented

      # Creates a new Bio::Blat::Report object from BLAT result text (String).
      # You can use Bio::FlatFile to read a file.
      # Currently, results created with options -out=psl (default) or
      # -out=pslx are supported.
      def initialize(text = '')
        flag = false
        head = []
        @hits = []
        text.each_line do |line|
          if flag then
            @hits << Hit.new(line)
          else
            # for headerless data
            if /^\d/ =~ line then
              flag = true
              redo
            end
            line = line.chomp
            if /\A\-+\s*\z/ =~ line
              flag = true
            else
              head << line
            end
          end
        end
        @columns = parse_header(head) unless head.empty?
      end

      # Adds a header line if the header data is not yet given and
      # the given line is suitable for header.
      # Returns self if adding header line is succeeded.
      # Otherwise, returns false (the line is not added).
      def add_header_line(line)
        return false if defined? @columns
        line = line.chomp
        case line
        when /^\d/
          @columns = defined? @header_lines ? parse_header(@header_lines) : []
          return false
        when /\A\-+\s*\z/
          @columns = defined? @header_lines ? parse_header(@header_lines) : []
          return self
        else
          @header_lines ||= []
          @header_lines.push line
        end
      end

      # Adds a line to the entry if the given line is regarded as
      # a part of the current entry.
      # If the current entry (self) is empty, or the line has the same
      # query name, the line is added and returns self.
      # Otherwise, returns false (the line is not added).
      def add_line(line)
        if /\A\s*\z/ =~ line then
          return @hits.empty? ? self : false
        end
        hit = Hit.new(line.chomp)
        if @hits.empty? or @hits.first.query.name == hit.query.name then
          @hits.push hit
          return self
        else
          return false
        end
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
        while x = ary.shift
          if /psLayout version (\S+)/ =~ x then
            @psl_version = $1
            break
          elsif !(x.strip.empty?)
            ary.unshift(x)
            break
          end
        end
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

      # version of the psl format (String or nil).
      attr_reader :psl_version

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
        def initialize(query_len, target_len, strand,
                       blksize, qstart, tstart, qseq, tseq,
                       protein_flag)
          @blocksize  = blksize
          @qseq       = qseq
          @hseq       = hseq
          @hit_strand   = 'plus'
          w = (protein_flag ? 3 : 1) # 3 means query=protein target=dna
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
            @hit_to     = tstart + blksize * w # - 1 + 1
          when '+-'
            # hit is minus strand
            @query_strand = 'plus'
            @hit_strand = 'minus'
            # To keep compatibility, with other homology search programs,
            # we add 1 to each position number.
            @query_from   = qstart + 1
            @query_to     = qstart + blksize # - 1 + 1
            # convert positions
            @hit_from     = target_len - tstart
            @hit_to       = target_len - tstart - blksize * w + 1
          else #when '+', '++'
            @query_strand = 'plus'
            # To keep compatibility with other homology search programs,
            # we add 1 to each position number.
            @query_from = qstart + 1
            @query_to   = qstart + blksize # - 1 + 1
            @hit_from   = tstart + 1
            @hit_to     = tstart + blksize * w # - 1 + 1
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

        # "rep. match".
        # Number of bases that match but are part of repeats.
        # Note that current version of BLAT always set 0.
        def rep_match;   @data[2].to_i;  end

        # "N's". Number of 'N' bases.
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
            pflag = self.protein?
            @blocks = (0...block_count).collect do |i|
              SegmentPair.new(query.size, target.size, strand, bs[i],
                              qst[i], tst[i], qseqs[i], tseqs[i],
                              pflag)
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

        #--
        # methods described in the BLAT FAQ at the UCSC genome browser.
        # (http://genome.ucsc.edu/FAQ/FAQblat#blat4)
        #++

        # Calculates the pslCalcMilliBad value defined in the
        # BLAT FAQ (http://genome.ucsc.edu/FAQ/FAQblat#blat4).
        #
        # The algorithm is taken from the BLAT FAQ
        # (http://genome.ucsc.edu/FAQ/FAQblat#blat4).
        def milli_bad
          w = (self.protein? ? 3 : 1)
          qalen = w * (self.query.end - self.query.start)
          talen = self.target.end - self.target.start
          alen = (if qalen < talen then qalen; else talen; end)
          return 0 if alen <= 0
          d = qalen - talen
          d = 0 if d < 0
          total = w * (self.match + self.rep_match + self.mismatch)
          return 0 if total == 0
          return (1000 * (self.mismatch * w + self.query.gap_count +
                            (3 * Math.log(1 + d)).round) / total)
        end

        # Calculates the percent identity compatible with the BLAT web server
        # as described in the BLAT FAQ
        # (http://genome.ucsc.edu/FAQ/FAQblat#blat4).
        #
        # The algorithm is taken from the BLAT FAQ
        # (http://genome.ucsc.edu/FAQ/FAQblat#blat4).
        def percent_identity
          100.0 - self.milli_bad * 0.1
        end

        # When the output data comes from the protein query, returns true.
        # Otherwise (nucleotide query), returns false.
        # It returns nil if this cannot be determined.
        #
        # The algorithm is taken from the BLAT FAQ
        # (http://genome.ucsc.edu/FAQ/FAQblat#blat4).
        #
        # Note: It seems that it returns true only when protein query
        # with nucleotide database (blat options: -q=prot -t=dnax).
        def protein?
          return nil if self.block_sizes.empty?
          case self.strand[1,1]
          when '+'
            if self.target.end == self.target.starts[-1] +
                3 * self.block_sizes[-1] then
              true
            else
              false
            end
          when '-'
            if self.target.start == self.target.size -
                self.target.starts[-1] - 3 * self.block_sizes[-1] then
              true
            else
              false
            end
          else
            nil
          end
        end

        # Calculates the score compatible with the BLAT web server
        # as described in the BLAT FAQ
        # (http://genome.ucsc.edu/FAQ/FAQblat#blat4).
        #
        # The algorithm is taken from the BLAT FAQ
        # (http://genome.ucsc.edu/FAQ/FAQblat#blat4).
        def score
          w = (self.protein? ? 3 : 1)
          w * (self.match + (self.rep_match >> 1)) -
            w * self.mismatch - self.query.gap_count - self.target.gap_count
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
