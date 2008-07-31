#
# = bio/db/gff.rb - GFF format class
#
# Copyright::  Copyright (C) 2003, 2005
#              Toshiaki Katayama <k@bioruby.org>
#              2006  Jan Aerts <jan.aerts@bbsrc.ac.uk>
#              2008  Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: gff.rb,v 1.9 2007/05/18 15:23:42 k Exp $
#
require 'uri'
require 'strscan'
require 'bio/db/fasta'

module Bio
  # == DESCRIPTION
  # The Bio::GFF and Bio::GFF::Record classes describe data contained in a 
  # GFF-formatted file. For information on the GFF format, see 
  # http://www.sanger.ac.uk/Software/formats/GFF/. Data are represented in tab- 
  # delimited format, including
  # * seqname
  # * source
  # * feature
  # * start
  # * end
  # * score
  # * strand
  # * frame
  # * attributes (optional)
  # 
  # For example:
  #  SEQ1     EMBL        atg       103   105     .       +       0
  #  SEQ1     EMBL        exon      103   172     .       +       0
  #  SEQ1     EMBL        splice5   172   173     .       +       .
  #  SEQ1     netgene     splice5   172   173     0.94    +       .
  #  SEQ1     genie       sp5-20    163   182     2.3     +       .
  #  SEQ1     genie       sp5-10    168   177     2.1     +       .
  #  SEQ1     grail       ATG       17    19      2.1     -       0
  #
  # The Bio::GFF object is a container for Bio::GFF::Record objects, each 
  # representing a single line in the GFF file.
  class GFF
    # Creates a Bio::GFF object by building a collection of Bio::GFF::Record
    # objects.
    # 
    # Create a Bio::GFF object the hard way
    #  this_gff =  "SEQ1\tEMBL\tatg\t103\t105\t.\t+\t0\n"
    #  this_gff << "SEQ1\tEMBL\texon\t103\t172\t.\t+\t0\n"
    #  this_gff << "SEQ1\tEMBL\tsplice5\t172\t173\t.\t+\t.\n"
    #  this_gff << "SEQ1\tnetgene\tsplice5\t172\t173\t0.94\t+\t.\n"
    #  this_gff << "SEQ1\tgenie\tsp5-20\t163\t182\t2.3\t+\t.\n"
    #  this_gff << "SEQ1\tgenie\tsp5-10\t168\t177\t2.1\t+\t.\n"
    #  this_gff << "SEQ1\tgrail\tATG\t17\t19\t2.1\t-\t0\n"
    #  p Bio::GFF.new(this_gff)
    #  
    # or create one based on a GFF-formatted file:
    #  p Bio::GFF.new(File.open('my_data.gff')
    # ---
    # *Arguments*:
    # * _str_: string in GFF format
    # *Returns*:: Bio::GFF object
    def initialize(str = '')
      @records = Array.new
      str.each_line do |line|
        @records << Record.new(line)
      end
    end

    # An array of Bio::GFF::Record objects.
    attr_accessor :records

    # Represents a single line of a GFF-formatted file. See Bio::GFF for more
    # information.
    class Record

      # Name of the reference sequence
      attr_accessor :seqname
    
      # Name of the source of the feature (e.g. program that did prediction)
      attr_accessor :source
    
      # Name of the feature
      attr_accessor :feature
    
      # Start position of feature on reference sequence
      attr_accessor :start
    
      # End position of feature on reference sequence
      attr_accessor :end
    
      # Score of annotation (e.g. e-value for BLAST search)
      attr_accessor :score
    
      # Strand that feature is located on
      attr_accessor :strand
    
      # For features of type 'exon': indicates where feature begins in the reading frame
      attr_accessor :frame
    
      # List of tag=value pairs (e.g. to store name of the feature: ID=my_id)
      attr_accessor :attributes
    
      # Comments for the GFF record
      attr_accessor :comments

      # Creates a Bio::GFF::Record object. Is typically not called directly, but
      # is called automatically when creating a Bio::GFF object.
      # ---
      # *Arguments*:
      # * _str_: a tab-delimited line in GFF format
      def initialize(str)
        @comments = str.chomp[/#.*/]
        return if /^#/.match(str)
        @seqname, @source, @feature, @start, @end, @score, @strand, @frame,
          attributes, = str.chomp.split("\t")
        @attributes = parse_attributes(attributes) if attributes
      end

      private

      def parse_attributes(attributes)
        hash = Hash.new
        scanner = StringScanner.new(attributes)
        while scanner.scan(/(.*[^\\])\;/) or scanner.scan(/(.+)/)
          key, value = scanner[1].split(' ', 2)
          key.strip!
          value.strip! if value
          hash[key] = value
        end
        hash
      end

    end #Class Record

    # = DESCRIPTION
    # Represents version 2 of GFF specification. Is completely implemented by the
    # Bio::GFF class.
    class GFF2 < GFF
      VERSION = 2
    end

    # = DESCRIPTION
    # Represents version 3 of GFF specification.
    # For more information on version GFF3, see
    # http://song.sourceforge.net/gff3.shtml
    #--
    # obsolete URL:
    # http://flybase.bio.indiana.edu/annot/gff3.html
    #++
    class GFF3 < GFF
      VERSION = 3
      
      # Creates a Bio::GFF::GFF3 object by building a collection of
      # Bio::GFF::GFF3::Record objects.
      # 
      # ---
      # *Arguments*:
      # * _str_: string in GFF format
      # *Returns*:: Bio::GFF object
      def initialize(str = nil)
        @gff_version = nil
        @records = []
        @sequence_regions = []
        @metadata = []
        @sequences = []
        @in_fasta = false
        parse(str) if str
      end

      # GFF3 version string (String or nil). nil means "3".
      attr_reader :gff_version

      # Metadata of "##sequence-region".
      # Must be an array of Bio::GFF::GFF3::SequenceRegion objects.
      attr_accessor :sequence_regions

      # Metadata (except "##sequence-region", "##gff-version", "###").
      # Must be an array of Bio::GFF::GFF3::MetaData objects.
      attr_accessor :metadata

      # Sequences bundled within GFF3.
      # Must be an array of Bio::Sequence objects.
      attr_accessor :sequences

      # Parses a GFF3 entries, and concatenated the parsed data.
      #
      # Note that after "##FASTA" line is given,
      # only fasta-formatted text is accepted.
      # 
      # ---
      # *Arguments*:
      # * _str_: string in GFF format
      # *Returns*:: self
      def parse(str)
        # if already after the ##FASTA line, parses fasta format and return
        if @in_fasta then
          parse_fasta(str)
          return self
        end

        if str.respond_to?(:gets) then
          # str is a IO-like object
          fst = nil
        else
          # str is a String
          gff, sep, fst = str.split(/^(\>|##FASTA.*)/n, 2)
          fst = sep + fst if sep == '>' and fst
          str = gff
        end

        # parses GFF lines
        str.each_line do |line|
          if /^\#\#([^\s]+)/ =~ line then
            parse_metadata($1, line)
            parse_fasta(str) if @in_fasta
          elsif /^\>/ =~ line then
            @in_fasta = true
            parse_fasta(str, line)
          else
            @records << GFF3::Record.new(line)
          end
        end

        # parses fasta format when str is a String and fasta data exists
        if fst then
          @in_fasta = true
          parse_fasta(fst)
        end

        self
      end

      # parses fasta formatted data
      def parse_fasta(str, line = nil)
        str.each_line("\n>") do |seqstr|
          if line then seqstr = line + seqstr; line = nil; end
          x = seqstr.strip
          next if x.empty? or x == '>'
          fst = Bio::FastaFormat.new(seqstr)
          seq = fst.to_seq
          seq.entry_id =
            unescape(fst.definition.strip.split(/\s/, 2)[0].to_s)
          @sequences.push seq
        end
      end
      private :parse_fasta

      # string representation of whole entry.
      def to_s
        ver = @gff_version || '3'
        if @sequences.size > 0 then
          seqs = "##FASTA\n" +
            @sequences.collect { |s| s.to_fasta(s.entry_id, 70) }.join('')
        else
          seqs = ''
        end

        ([ "##gff-version #{escape(ver)}\n" ] +
         @metadata.collect { |m| m.to_s } +
         @sequence_regions.collect { |m| m.to_s } +
         @records.collect{ |r| r.to_s }).join('') + seqs
      end

      # Private methods for escaping characters.
      # Internal only. Users should not use this module directly.
      module Escape
        # unsafe characters to be escaped for normal columns
        UNSAFE = /[^-_.!~*'()a-zA-Z\d\/?:@+$\[\] "\x80-\xfd><;=,]/n

        # unsafe characters to be escaped for seqid columns
        # and target_id of the "Target" attribute
        UNSAFE_SEQID = /[^-a-zA-Z0-9.:^*$@!+_?|]/n

        # unsafe characters to be escaped for attribute columns
        UNSAFE_ATTRIBUTE = /[^-_.!~*'()a-zA-Z\d\/?:@+$\[\] "\x80-\xfd><]/n

        private

        # If str is empty, returns '.'. Otherwise, returns str.
        def column_to_s(str)
          str = str.to_s
          str.empty? ? '.' : str
        end

        # Return the string corresponding to these characters unescaped
        def unescape(string)
          URI.unescape(string)
        end

        # Escape a column according to the specification at
        # http://song.sourceforge.net/gff3.shtml.
        def escape(string)
          URI.escape(string, UNSAFE)
        end

        # Escape seqid column according to the specification at
        # http://song.sourceforge.net/gff3.shtml.
        def escape_seqid(string)
          URI.escape(string, UNSAFE_SEQID)
        end
        
        # Escape attribute according to the specification at
        # http://song.sourceforge.net/gff3.shtml.
        # In addition to the normal escape rule, the following characters
        # are escaped: ",=;".
        # Returns the string corresponding to these characters escaped.
        def escape_attribute(string)
          URI.escape(string, UNSAFE_ATTRIBUTE)
        end
      end #module Escape

      include Escape

      # Stores meta-data "##sequence-region seqid start end".
      class SequenceRegion
        include Escape
        
        # creates a new SequenceRegion class
        def initialize(seqid, start, endpos)
          @seqid = seqid
          @start = start ? start.to_i : nil
          @end = endpos ? endpos.to_i : nil
        end

        # parses given string and returns SequenceRegion class
        def self.parse(str)
          dummy, seqid, start, endpos =
            str.chomp.split(/\s+/, 4).collect { |x| URI.unescape(x) }
          self.new(seqid, start, endpos)
        end

        # sequence ID
        attr_accessor :seqid

        # start position
        attr_accessor :start

        # end position
        attr_accessor :end

        # string representation
        def to_s
          i = escape_seqid(column_to_s(@seqid))
          s = escape_seqid(column_to_s(@start))
          e = escape_seqid(column_to_s(@end))
          "##sequence-region #{i} #{s} #{e}\n"
        end

        # Returns true if self == other. Otherwise, returns false.
        def ==(other)
          if other.class == self.class and
              other.seqid == self.seqid and
              other.start == self.start and
              other.end == self.end then
            true
          else
            false
          end
        end
      end #class SequenceRegion

      # Represents a single line of a GFF3-formatted file.
      # See Bio::GFF::GFF3 for more information.
      class Record < GFF::Record

        include GFF3::Escape

        # shortcut to the ID attribute
        def id
          @attributes['ID']
        end

        # set ID attribute
        def id=(str)
          @attributes['ID'] = str
        end

        # aliases for Column 1 (formerly "seqname")
        alias seqid seqname
        alias seqid= seqname=

        # aliases for Column 3 (formerly "feature").
        # In the GFF3 document http://song.sourceforge.net/gff3.shtml,
        # column3 is called "type", but we used "feature_type"
        # because "type" is already used by Ruby itself.
        alias feature_type feature
        alias feature_type= feature=

        # aliases for Column 8
        alias phase frame
        alias phase= frame=

        # Parses a GFF3-formatted line and returns a new
        # Bio::GFF::GFF3::Record object.
        def self.parse(str)
          self.new.parse(str)
        end
       
        # Creates a Bio::GFF::GFF3::Record object.
        # Is typically not called directly, but
        # is called automatically when creating a Bio::GFF::GFF3 object.
        #
        # ---
        # *Arguments*:
        # * _str_: a tab-delimited line in GFF3 format
        # *Arguments*:
        # * _seqid_: sequence ID (String or nil)
        # * _source_: source (String or nil)
        # * _feature_type_: type of feature (String)
        # * _start_position_: start (Integer)
        # * _end_position_: end (Integer)
        # * _score_: score (Float or nil)
        # * _strand_: strand (String or nil)
        # * _phase_: phase (String or nil)
        # * _attributes_: attributes (Hash or nil)
        def initialize(*arg)
          if arg.size == 1 then
            parse(arg[0])
          else
            @seqname, @source, @feature,
            start, endp, @score, @strand, frame,
            @attributes = arg
            @start = start ? start.to_i : nil
            @end   = endp  ? endp.to_i : nil
            @score = score ? score.to_f : nil
            @frame = frame ? frame.to_i : nil
          end
          @attributes ||= {}
        end

        # Parses a GFF3-formatted line and stores data from the string.
        # Note that all existing data is wiped out.
        def parse(string)
          if /^\s*\#/ =~ string then
            @comments = string[/\#.*/]
            columns = []
          else
            columns = string.chomp.split("\t", 10)
            @comments = columns[9][/\#.*/] if columns[9]
          end

          @seqname, @source, @feature,
          start, endp, score, @strand, frame =
            columns[0, 8].collect { |x|
            str = unescape(x)
            str == '.' ? nil : str
          }
          @start = start ? start.to_i : nil
          @end   = endp  ? endp.to_i : nil
          @score = score ? score.to_f : nil
          @frame = frame ? frame.to_i : nil

          @attributes = parse_attributes(columns[8])
        end

        # Return the record as a GFF3 compatible string
        def to_s
          [
           escape(column_to_s(@seqname)),
           escape(column_to_s(@source)),
           escape(column_to_s(@feature)),
           escape(column_to_s(@start)),
           escape(column_to_s(@end)),
           escape(column_to_s(@score)),
           escape(column_to_s(@strand)),
           escape(column_to_s(@frame)),
           attributes_to_s(@attributes)
          ].join("\t") + "\n"
        end
        
        # Returns true if self == other. Otherwise, returns false.
        def ==(other)
          if self.class == other.class and
              self.seqname == other.seqname and
              self.source  == other.source and
              self.feature == other.feature and
              self.start   == other.start and
              self.end     == other.end and
              self.score   == other.score and
              self.strand  == other.strand and
              self.frame   == other.frame and
              self.attributes == other.attributes then
            true
          else
            false
          end
        end

        # Bio:GFF::GFF3::Record::Target is a class to store
        # data of "Target" attribute.
        class Target
          include GFF3::Escape

          # Creates a new Target object.
          def initialize(target_id, start, endpos, strand = nil)
            @target_id = target_id
            @start = start ? start.to_i : nil
            @end = endpos ? endpos.to_i : nil
            @strand = strand
          end

          # target ID
          attr_accessor :target_id

          # start position
          attr_accessor :start

          # end position
          attr_accessor :end

          # strand (optional). Normally, "+" or "-", or nil.
          attr_accessor :strand

          # parses "target_id start end [strand]"-style string
          # (for example, "ABC789 123 456 +")
          # and creates a new Target object.
          #
          def self.parse(str)
            target_id, start, endpos, strand =
              str.split(/ +/, 4).collect { |x| URI.unescape(x) }
            self.new(target_id, start, endpos, strand)
          end

          # returns a string
          def to_s
            i = escape_seqid(column_to_s(@target_id))
            s = escape_attribute(column_to_s(@start))
            e = escape_attribute(column_to_s(@end))
            strnd = escape_attribute(@strand.to_s)
            strnd = " " + strnd unless strnd.empty?
            "#{i} #{s} #{e}#{strnd}"
          end

          # Returns true if self == other. Otherwise, returns false.
          def ==(other)
            if other.class == self.class and
                other.target_id == self.target_id and
                other.start == self.start and
                other.end == self.end and
                other.strand == self.strand then
              true
            else
              false
            end
          end
        end #class Target

        # Bio:GFF::GFF3::Record::Gap is a class to store
        # data of "Gap" attribute.
        class Gap

          # Code is a class to store length of single-letter code.
          Code = Struct.new(:code, :length)

          # Code is a class to store length of single-letter code.
          class Code
            # 1-letter code (Symbol). One of :M, :I, :D, :F, or :R is expected.
            attr_reader :code if false #dummy for RDoc

            # length (Integer)
            attr_reader :length if false #dummy for RDoc
 
            def to_s
              "#{code}#{length}"
            end
          end #class code

          # Creates a new Gap object.
          # 
          # ---
          # *Arguments*:
          # * _str_: a formatted string, or nil.
          def initialize(str = nil)
            if str then
              @data = str.split(/ +/).collect do |x|
                if /\A([A-Z])([0-9]+)\z/ =~ x.strip then
                  Code.new($1.intern, $2.to_i)
                else
                  warn "ignored unknown token: #{x}.inspect" if $VERBOSE
                  nil
                end
              end
              @data.compact!
            else
              @data = []
            end
          end

          # Same as new(str).
          def self.parse(str)
            self.new(str)
          end

          # (private method)
          # Scans gaps and returns an array of Code objects
          def __scan_gap(str, gap_regexp = /[^a-zA-Z]/,
                         code_i = :I, code_m = :M)
            sc = StringScanner.new(str)
            data = []
            while len = sc.skip_until(gap_regexp)
              mlen = len - sc.matched_size
              data.push Code.new(code_m, mlen) if mlen > 0
              g = Code.new(code_i, sc.matched_size)
              while glen = sc.skip(gap_regexp)
                g.length += glen
              end
              data.push g
            end
            if sc.rest_size > 0 then
              m = Code.new(code_m, sc.rest_size)
              data.push m
            end
            data
          end
          private :__scan_gap

          # (private method)
          # Parses given reference-target sequence alignment and
          # initializes self. Existing data will be erased.
          def __initialize_from_sequences_na(reference, target,
                                             gap_regexp = /[^a-zA-Z]/)
            
            data_ref = __scan_gap(reference, gap_regexp, :I, :M)
            data_tgt = __scan_gap(target,    gap_regexp, :D, :M)
            data = []

            while !data_ref.empty? and !data_tgt.empty?
              ref = data_ref.shift
              tgt = data_tgt.shift
              if ref.length > tgt.length then
                x = Code.new(ref.code, ref.length - tgt.length)
                data_ref.unshift x
                ref.length = tgt.length
              elsif ref.length < tgt.length then
                x = Code.new(tgt.code, tgt.length - ref.length)
                data_tgt.unshift x
                tgt.length = ref.length
              end
              case ref.code
              when :M
                if tgt.code == :M then
                  data.push ref
                elsif tgt.code == :D then
                  data.push tgt
                else
                  raise 'Bug: should not reach here.'
                end
              when :I
                if tgt.code == :M then
                  data.push ref
                elsif tgt.code == :D then
                  # This site is ignored,
                  # because both reference and target are gap
                else
                  raise 'Bug: should not reach here.'
                end
              end
            end #while

            # rest of data_ref
            len = 0
            data_ref.each do |ref|
              len += ref.length if ref.code == :M
            end
            data.push Code.new(:D, len) if len > 0

            # rest of data_tgt
            len = 0
            data_tgt.each do |tgt|
              len += tgt.length if tgt.code == :M
            end
            data.push Code.new(:I, len) if len > 0

            @data = data
            true
          end
          private :__initialize_from_sequences_na

          # Creates a new Gap object from given sequence alignment.
          #
          # Note that sites of which both reference and target are gaps
          # are silently removed.
          #
          # ---
          # *Arguments*:
          # * _reference_: reference sequence (nucleotide sequence)
          # * _target_: target sequence (nucleotide sequence)
          # * <I>gap_regexp</I>: regexp to identify gap
          def self.new_from_sequences_na(reference, target,
                                         gap_regexp = /[^a-zA-Z]/)
            gap = self.new
            gap.instance_eval { 
              __initialize_from_sequences_na(reference, target,
                                             gap_regexp)
            }
            gap
          end

          # (private method)
          # scans a codon or gap in reference sequence
          def __scan_codon(sc_ref, 
                           gap_regexp, space_regexp,
                           forward_frameshift_regexp,
                           reverse_frameshift_regexp)
            chars = []
            gap_count = 0
            fs_count = 0

            while chars.size < 3 + fs_count and char = sc_ref.scan(/./mn)
              case char
              when space_regexp
                # ignored
              when forward_frameshift_regexp
                # next char is forward frameshift
                fs_count += 1
              when reverse_frameshift_regexp
                # next char is reverse frameshift
                fs_count -= 1
              when gap_regexp
                chars.push char
                gap_count += 1
              else
                chars.push char
              end
            end #while
            if chars.size < (3 + fs_count) then
              gap_count += (3 + fs_count) - chars.size
            end
            return gap_count, fs_count
          end
          private :__scan_codon
              
          # (private method)
          # internal use only
          def __push_code_to_data(cur, data, code, len)
            if cur and cur.code == code then
              cur.length += len
            else
              cur = Code.new(code, len)
              data.push cur
            end
            return cur
          end
          private :__push_code_to_data

          # (private method)
          # Parses given reference(nuc)-target(amino) sequence alignment and
          # initializes self. Existing data will be erased.
          def __initialize_from_sequences_na_aa(reference, target,
                                                gap_regexp = /[^a-zA-Z]/,
                                                space_regexp = /\s/,
                                                forward_frameshift_regexp =
                                                /\>/,
                                                reverse_frameshift_regexp =
                                                /\</)

            data = []
            sc_ref = StringScanner.new(reference)
            sc_tgt = StringScanner.new(target)

            re_one = /./mn

            while !sc_tgt.eos?
              if len = sc_tgt.skip(space_regexp) then
                # ignored
              elsif len = sc_tgt.skip(forward_frameshift_regexp) then
                cur = __push_code_to_data(cur, data, :F, len)
                len.times { sc_ref.scan(re_one) }

              elsif len = sc_tgt.skip(reverse_frameshift_regexp) then
                cur = __push_code_to_data(cur, data, :R, len)
                pos = sc_ref.pos
                pos -= len
                if pos < 0 then
                  warn "Incorrect reverse frameshift" if $VERBOSE
                  pos = 0
                end
                sc_ref.pos = pos

              elsif len = sc_tgt.skip(gap_regexp) then
                len.times do
                  ref_gaps, ref_fs = __scan_codon(sc_ref,
                                                  gap_regexp,
                                                  space_regexp,
                                                  forward_frameshift_regexp,
                                                  reverse_frameshift_regexp)
                  case ref_gaps
                  when 3
                    # both ref and tgt are gap. ignored the site
                  when 2, 1
                    # forward frameshift inserted
                    ref_fs += (3 - ref_gaps)
                  when 0
                    cur = __push_code_to_data(cur, data, :D, 1)
                  else
                    raise 'Bug: should not reach here'
                  end
                  if ref_fs < 0 then
                    cur = __push_code_to_data(cur, data, :R, -ref_fs)
                  elsif ref_fs > 0 then
                    cur = __push_code_to_data(cur, data, :F, ref_fs)
                  end
                end #len.times
              elsif len = sc_tgt.skip(re_one) then
                # always 1-letter
                ref_gaps, ref_fs = __scan_codon(sc_ref,
                                                gap_regexp,
                                                space_regexp,
                                                forward_frameshift_regexp,
                                                reverse_frameshift_regexp)
                case ref_gaps
                when 3
                  cur = __push_code_to_data(cur, data, :I, 1)
                when 2, 1, 0
                  # reverse frameshift inserted when gaps exist
                  ref_fs -= ref_gaps
                  # normal site
                  cur = __push_code_to_data(cur, data, :M, 1)
                else
                  raise 'Bug: should not reach here'
                end
                if ref_fs < 0 then
                  cur = __push_code_to_data(cur, data, :R, -ref_fs)
                elsif ref_fs > 0 then
                  cur = __push_code_to_data(cur, data, :F, ref_fs)
                end
              else
                raise 'Bug: should not reach here'
              end
            end #while

            if sc_ref.rest_size > 0 then
              rest = sc_ref.scan(/.*/mn)
              rest.gsub!(space_regexp, '')
              rest.gsub!(forward_frameshift_regexp, '')
              rest.gsub!(reverse_frameshift_regexp, '')
              rest.gsub!(gap_regexp, '')
              len = rest.length.div(3)
              cur = __push_code_to_data(cur, data, :D, len) if len > 0
              len = rest.length % 3
              cur = __push_code_to_data(cur, data, :F, len) if len > 0
            end

            @data = data
            self
          end
          private :__initialize_from_sequences_na_aa

          # Creates a new Gap object from given sequence alignment.
          #
          # Note that sites of which both reference and target are gaps
          # are silently removed.
          #
          # For incorrect alignments that break 3:1 rule,
          # gap positions will be moved inside codons,
          # unwanted gaps will be removed, and
          # some forward or reverse frameshift will be inserted.
          # 
          # For example,
          #    atgg-taagac-att
          #    M  V  K  -  I  
          # is treated as:
          #    atggt<aagacatt
          #    M  V  K  >>I  
          #
          # Incorrect combination of frameshift with frameshift or gap
          # may cause undefined behavior.
          #
          # Forward frameshifts are recomended to be indicated in the
          # target sequence.
          # Reverse frameshifts can be indicated in the reference sequence
          # or the target sequence.
          #
          # Priority of regular expressions:
          #   space > forward/reverse frameshift > gap
          # 
          # ---
          # *Arguments*:
          # * _reference_: reference sequence (nucleotide sequence)
          # * _target_: target sequence (amino acid sequence)
          # * <I>gap_regexp</I>: regexp to identify gap
          # * <I>space_regexp</I>: regexp to identify space character which is completely ignored
          # * <I>forward_frameshift_regexp</I>: regexp to identify forward frameshift
          # * <I>reverse_frameshift_regexp</I>: regexp to identify reverse frameshift
          def self.new_from_sequences_na_aa(reference, target,
                                            gap_regexp = /[^a-zA-Z]/,
                                            space_regexp = /\s/,
                                            forward_frameshift_regexp = /\>/,
                                            reverse_frameshift_regexp = /\</)
            gap = self.new
            gap.instance_eval { 
              __initialize_from_sequences_na_aa(reference, target,
                                                gap_regexp,
                                                space_regexp,
                                                forward_frameshift_regexp,
                                                reverse_frameshift_regexp)
            }
            gap
          end

          # string representation
          def to_s
            @data.collect { |x| x.to_s }.join(" ")
          end

          # Internal data. Users must not use it.
          attr_reader :data
          # @data can be read by other Gap instances
          protected :data

          # If self == other, returns true.
          # otherwise, returns false.
          def ==(other)
            if other.class == self.class and
                @data == other.data then
              true
            else
              false
            end
          end

          # duplicates sequences
          def dup_seqs(*arg)
            arg.collect do |s|
              begin
                s = s.seq
              rescue NoMethodError
              end
              s.dup
            end
          end
          private :dup_seqs

          # (private method)
          # insert gaps refers to the gap rule inside the object
          def __process_sequences(s_ref, s_tgt,
                                  ref_gap, tgt_gap,
                                  ref_increment, tgt_increment,
                                  forward_frameshift,
                                  reverse_frameshift)
            p_ref = 0
            p_tgt = 0
            @data.each do |c|
              #$stderr.puts c.inspect
              #$stderr.puts "p_ref=#{p_ref} s_ref=#{s_ref.inspect}"
              #$stderr.puts "p_tgt=#{p_tgt} s_tgt=#{s_tgt.inspect}"
              case c.code
              when :M # match
                p_ref += c.length * ref_increment
                p_tgt += c.length * tgt_increment
              when :I # insert a gap into the reference sequence
                begin
                  s_ref[p_ref, 0] = ref_gap * c.length
                rescue IndexError
                  raise 'reference sequence too short'
                end
                p_ref += c.length * ref_increment
                p_tgt += c.length * tgt_increment
              when :D # insert a gap into the target (delete from reference)
                begin
                  s_tgt[p_tgt, 0] =  tgt_gap * c.length
                rescue IndexError
                  raise 'target sequence too short'
                end
                p_ref += c.length * ref_increment
                p_tgt += c.length * tgt_increment
              when :F # frameshift forward in the reference sequence
                begin
                  s_tgt[p_tgt, 0] = forward_frameshift * c.length
                rescue IndexError
                  raise 'target sequence too short'
                end
                p_ref += c.length
                p_tgt += c.length
              when :R # frameshift reverse in the reference sequence
                p_rev_frm = p_ref - c.length
                if p_rev_frm < 0 then
                  raise 'too short reference sequence, or too many reverse frameshifts'
                end
                begin
                  s_ref[p_rev_frm, 0] = reverse_frameshift * c.length
                rescue IndexError
                  raise 'reference sequence too short'
                end
                
              else
                warn "ignored #{c.to_s.inspect}" if $VERBOSE
              end
            end

            if s_ref.length < p_ref then
              raise 'reference sequence too short'
            end
            if s_tgt.length < p_tgt then
              raise 'target sequence too short'
            end
            return s_ref, s_tgt
          end
          private :__process_sequences

          # Processes nucleotide sequences and
          # returns gapped sequences as an array of sequences.
          #
          # Note for forward/reverse frameshift:
          # Forward/Reverse_frameshift is simply treated as
          # gap insertion to the target/reference sequence.
          #
          # ---
          # *Arguments*:
          # * _reference_: reference sequence (nucleotide sequence)
          # * _target_: target sequence (nucleotide sequence)
          # * <I>gap_char</I>: gap character
          def process_sequences_na(reference, target, gap_char = '-')
            s_ref, s_tgt = dup_seqs(reference, target)

            s_ref, s_tgt = __process_sequences(s_ref, s_tgt,
                                               gap_char, gap_char,
                                               1, 1,
                                               gap_char, gap_char)

            if $VERBOSE and s_ref.length != s_tgt.length then
              warn "returned sequences not equal length"
            end
            return s_ref, s_tgt
          end

          # Processes sequences and
          # returns gapped sequences as an array of sequences.
          # reference must be a nucleotide sequence, and
          # target must be an amino acid sequence.
          #
          # Note for reverse frameshift:
          # Reverse_frameshift characers are inserted in the 
          # reference sequence.
          # For example, alignment of "Gap=M3 R1 M2" is:
          #     atgaagat<aatgtc
          #     M  K  I  N  V  
          # Alignment of "Gap=M3 R3 M3" is:
          #     atgaag<<<attaatgtc
          #     M  K  I  I  N  V  
          #
          # ---
          # *Arguments*:
          # * _reference_: reference sequence (nucleotide sequence)
          # * _target_: target sequence (amino acid sequence)
          # * <I>gap_char</I>: gap character
          # * <I>space_char</I>: space character inserted to amino sequence for matching na-aa alignment
          # * <I>forward_frameshift</I>: forward frameshift character
          # * <I>reverse_frameshift</I>: reverse frameshift character
          def process_sequences_na_aa(reference, target,
                                      gap_char = '-',
                                      space_char = ' ',
                                      forward_frameshift = '>',
                                      reverse_frameshift = '<')
            s_ref, s_tgt = dup_seqs(reference, target)
            s_tgt = s_tgt.gsub(/./, "\\0#{space_char}#{space_char}")
            ref_increment = 3
            tgt_increment = 1 + space_char.length * 2
            ref_gap = gap_char * 3
            tgt_gap = "#{gap_char}#{space_char}#{space_char}"
            return __process_sequences(s_ref, s_tgt,
                                       ref_gap, tgt_gap,
                                       ref_increment, tgt_increment,
                                       forward_frameshift,
                                       reverse_frameshift)
          end
        end #class Gap
        
        private
        def parse_attributes(string)
          hash = Hash.new
          return hash if !string or string == '.'
          string.split(';').each do |pair|
            key, value = pair.split('=', 2)
            key = unescape(key)
            values = value.to_s.split(',')
            case key
            when 'Target'
              values.collect! { |v| Target.parse(v) }
            when 'Gap'
              values.collect! { |v| Gap.parse(v) }
            else
              values.collect! { |v| unescape(v) }
            end
            hash[key] = (values.size <= 1 ? values[0] : values)
          end
          return hash
        end # method parse_attributes

        # Priority of attributes when output. 
        # Smaller value, high priority.
        # Default value for unlisted attribute is 999.
        ATTRIBUTES_PRIORITY = {
          'ID'            => 0,
          'Name'          => 1,
          'Alias'         => 2,
          'Parent'        => 3,
          'Target'        => 4,
          'Gap'           => 5,
          'Derives_from'  => 6,
          'Note'          => 7,
          'Dbxref'        => 8,
          'Ontology_term' => 9
        }
        ATTRIBUTES_PRIORITY.default = 999
        
        # Return the attributes as a string as it appears at the end of
        # a GFF3 line
        def attributes_to_s(attr)
          return '.' if !attr or attr.empty?
          keys = attr.keys.sort! do |x, y|
            z = ATTRIBUTES_PRIORITY[x] <=> ATTRIBUTES_PRIORITY[y]
            z != 0 ? z : x <=> y
          end
          keys.collect do |key|
            values = attr[key]
            unless values.kind_of?(Array) then
              values = [ values ]
            end
            val = values.collect do |v|
              if v.kind_of?(Target) then
                v.to_s
              else
                escape_attribute(v.to_s)
              end
            end.join(',')
            "#{escape_attribute(key)}=#{val}"
          end.join(';')
        end

      end # class GFF3::Record

      # This is a dummy record corresponding to the "###" metadata.
      class RecordBoundary < GFF3::Record
        def initialize(*arg)
          super(*arg)
          self.freeze
        end

        def to_s
          "###\n"
        end
      end #class RecordBoundary

      # Stores meta-data.
      class MetaData
        # Creates a new MetaData object
        def initialize(directive, data = nil)
          @directive = directive
          @data = data
        end

        # Directive. Usually, one of "feature-ontology", "attribute-ontology",
        # or "source-ontology".
        attr_accessor :directive

        # data of this entry
        attr_accessor :data

        # parses a line
        def self.parse(line)
          directive, data = line.chomp.split(/\s+/, 2)
          directive = directive.sub(/\A\#\#/, '') if directive
          self.new(directive, data)
        end

        # string representation of this meta-data
        def to_s
          d = @directive.to_s.gsub(/[\r\n]+/, ' ')
          v = ' ' + @data.to_s.gsub(/[\r\n]+/, ' ') unless @data.to_s.empty?
          "\#\##{d}#{v}\n"
        end

        # Returns true if self == other. Otherwise, returns false.
        def ==(other)
          if self.class == other.class and
              self.directive == other.directive and
              self.data == other.data then
            true
          else
            false
          end
        end
      end #class MetaData

      # parses metadata
      def parse_metadata(directive, line)
        case directive
        when 'gff-version'
          @gff_version ||= line.split(/\s+/)[1]
        when 'FASTA'
          @in_fasta = true
        when 'sequence-region'
          @sequence_regions.push SequenceRegion.parse(line)
        when '#' # "###" directive
          @records.push RecordBoundary.new
        else
          @metadata.push MetaData.parse(line)
        end
        true
      end
      private :parse_metadata

    end #class GFF3
    
  end # class GFF

end # module Bio


if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  this_gff =  "SEQ1\tEMBL\tatg\t103\t105\t.\t+\t0\n"
  this_gff << "SEQ1\tEMBL\texon\t103\t172\t.\t+\t0\n"
  this_gff << "SEQ1\tEMBL\tsplice5\t172\t173\t.\t+\t.\n"
  this_gff << "SEQ1\tnetgene\tsplice5\t172\t173\t0.94\t+\t.\n"
  this_gff << "SEQ1\tgenie\tsp5-20\t163\t182\t2.3\t+\t.\n"
  this_gff << "SEQ1\tgenie\tsp5-10\t168\t177\t2.1\t+\t.\n"
  this_gff << "SEQ1\tgrail\tATG\t17\t19\t2.1\t-\t0\n"
  p Bio::GFF.new(this_gff)
end
