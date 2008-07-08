#
# = bio/db/gff.rb - GFF format class
#
# Copyright::  Copyright (C) 2003, 2005
#              Toshiaki Katayama <k@bioruby.org>
#              2006  Jan Aerts <jan.aerts@bbsrc.ac.uk>
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
