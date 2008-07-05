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
    # Represents version 3 of GFF specification. Is completely implemented by the
    # Bio::GFF class. For more information on version GFF3, see
    # http://flybase.bio.indiana.edu/annot/gff3.html
    class GFF3 < GFF
      VERSION = 3
      
      # Creates a Bio::GFF::GFF3 object by building a collection of
      # Bio::GFF::GFF3::Record objects.
      # 
      # ---
      # *Arguments*:
      # * _str_: string in GFF format
      # *Returns*:: Bio::GFF object
      def initialize(str = '')
        @records = Array.new
        str.each_line do |line|
          @records << GFF3::Record.new(line)
        end
      end

      # string representation
      def to_s
        return '' unless @records
        @records.collect{ |r| r.to_s }.join('')
      end

      # Represents a single line of a GFF3-formatted file.
      # See Bio::GFF::GFF3 for more information.
      class Record < GFF::Record

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
        
        # Creates a Bio::GFF::GFF3::Record object.
        # Is typically not called directly, but
        # is called automatically when creating a Bio::GFF::GFF3 object.
        # ---
        # *Arguments*:
        # * _str_: a tab-delimited line in GFF3 format
        def initialize(str = nil)
          parse(str) if str
          @attributes ||= {}
        end

        # Parses a GFF3-formatted line and stores data from the string.
        # Note that all existing data is wiped out.
        def parse(string)
          string, comments = string.chomp.split(/\#/, 2)
          columns = string.split("\t")
          @seqname, @source, @feature,
          start, endp, @score, @strand, @frame =
            columns[0, 8].collect { |x|
            str = unescape(x)
            str == '.' ? nil : str
          }
          @start = start ? start.to_i : nil
          @end   = endp  ? endp.to_i : nil

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

        # private methods for escaping characters
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

        # Bio:GFF::GFF3::Record::Target is a class to store
        # data of "Target" attribute.
        class Target
          include Record::Escape

          # Creates a new object.
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
            tid = escape_seqid(column_to_s(@target_id))
            st = escape_attribute(column_to_s(@start))
            ed = escape_attribute(column_to_s(@end))
            strnd = escape_attribute(@strand.to_s)
            strnd = " " + strnd unless strnd.empty?
            "#{tid} #{st} #{ed}#{strnd}"
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
          return '' unless attr
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
