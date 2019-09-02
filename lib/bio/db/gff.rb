# coding: US-ASCII
#
# = bio/db/gff.rb - GFF format class
#
# Copyright::  Copyright (C) 2003, 2005
#              Toshiaki Katayama <k@bioruby.org>
#              2006  Jan Aerts <jan.aerts@bbsrc.ac.uk>
#              2008  Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#
require 'uri'
require 'strscan'
require 'enumerator'
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
      attr_accessor :comment

      # "comments" is deprecated. Instead, use "comment".
      def comments
        #warn "#{self.class.to_s}#comments is deprecated. Instead, use \"comment\"." if $VERBOSE
        self.comment
      end

      # "comments=" is deprecated. Instead, use "comment=".
      def comments=(str)
        #warn "#{self.class.to_s}#comments= is deprecated. Instead, use \"comment=\"." if $VERBOSE
        self.comment = str
      end

      # Creates a Bio::GFF::Record object. Is typically not called directly, but
      # is called automatically when creating a Bio::GFF object.
      # ---
      # *Arguments*:
      # * _str_: a tab-delimited line in GFF format
      def initialize(str)
        @comment = str.chomp[/#.*/]
        return if /^#/.match(str)
        @seqname, @source, @feature, @start, @end, @score, @strand, @frame,
          attributes, = str.chomp.split("\t")
        @attributes = parse_attributes(attributes) if attributes
      end

      private

      def parse_attributes(attributes)
        hash = Hash.new

        sc = StringScanner.new(attributes)
        attrs = []
        token = ''
        while !sc.eos?
          if sc.scan(/[^\\\;\"]+/) then
            token.concat sc.matched
          elsif sc.scan(/\;/) then
            attrs.push token unless token.empty?
            token = ''
          elsif sc.scan(/\"/) then
            origtext = sc.matched
            while !sc.eos?
              if sc.scan(/[^\\\"]+/) then
                origtext.concat sc.matched
              elsif sc.scan(/\"/) then
                origtext.concat sc.matched
                break
              elsif sc.scan(/\\([\"\\])/) then
                origtext.concat sc.matched
              elsif sc.scan(/\\/) then
                origtext.concat sc.matched
              else
                raise 'Bug: should not reach here'
              end
            end
            token.concat origtext
          elsif sc.scan(/\\\;/) then
            token.concat sc.matched
          elsif sc.scan(/\\/) then
            token.concat sc.matched
          else
            raise 'Bug: should not reach here'
          end #if
        end #while
        attrs.push token unless token.empty?

        attrs.each do |x|
          key, value = x.split(' ', 2)
          key.strip!
          value.strip! if value
          hash[key] = value
        end
        hash
      end

    end #Class Record

    # = DESCRIPTION
    # Represents version 2 of GFF specification.
    # Its behavior is somehow different from Bio::GFF,
    # especially for attributes.
    #
    class GFF2 < GFF
      VERSION = 2

      # string representation of the whole entry.
      def to_s
        ver = @gff_version || VERSION.to_s
        ver = ver.gsub(/[\r\n]+/, ' ')
        ([ "##gff-version #{ver}\n" ] +
         @metadata.collect { |m| m.to_s } +
         @records.collect{ |r| r.to_s }).join('')
      end

      # Private methods for GFF2 escaping characters.
      # Internal only. Users should not use this module directly.
      module Escape
        # unsafe characters to be escaped
        UNSAFE_GFF2 = /[^-_.!~*'()a-zA-Z\d\/?:@+$\[\] \x80-\xfd><;=,%^&\|`]/n

        # GFF2 standard identifier
        IDENTIFIER_GFF2 = /\A[A-Za-z][A-Za-z0-9_]*\z/n

        # GFF2 numeric value
        NUMERIC_GFF2 = /\A[-+]?([0-9]+|[0-9]*\.[0-9]*)([eE][+-]?[0-9]+)?\z/n

        # List of 1-letter special backslash code.
        # The letters other than listed here are the same as
        # those of without backslash, except for "x" and digits.
        # (Note that \u (unicode) is not supported.)
        BACKSLASH = {
          't'  => "\t",
          'n'  => "\n",
          'r'  => "\r",
          'f'  => "\f",
          'b'  => "\b",
          'a'  => "\a",
          'e'  => "\e",
          'v'  => "\v",
          # 's'  => " ",
        }.freeze

        # inverted hash of BACKSLASH
        CHAR2BACKSLASH = BACKSLASH.invert.freeze

        # inverted hash of BACKSLASH, including double quote and backslash
        CHAR2BACKSLASH_EXTENDED =
          CHAR2BACKSLASH.merge({ '"' => '"', "\\" => "\\" }).freeze

        # prohibited characters in GFF2 columns
        PROHIBITED_GFF2_COLUMNS = /[\t\r\n\x00-\x08\x0b\x0c\x0e-\x1f\x7f\xfe\xff]/

        # prohibited characters in GFF2 attribute tags
        PROHIBITED_GFF2_TAGS = /[\s\"\;\x00-\x08\x0e-\x1f\x7f\xfe\xff]/

        private
        # (private) escapes GFF2 free text string
        def escape_gff2_freetext(str)
          '"' + str.gsub(UNSAFE_GFF2) do |x|
            "\\" + (CHAR2BACKSLASH_EXTENDED[x] || char2octal(x))
          end + '"'
        end

        # (private) "x" => "\\oXXX"
        # "x" must be a letter.
        # If "x" is consisted of two bytes or more, joined with "\\".
        def char2octal(x)
          x.enum_for(:each_byte).collect { |y|
            sprintf("%03o", y) }.join("\\")
        end
 
        # (private) escapes GFF2 attribute value string
        def escape_gff2_attribute_value(str)
          freetext?(str) ? escape_gff2_freetext(str) : str
        end

        # (private) check if the given string is a free text to be quoted
        # by double-qoute.
        def freetext?(str)
          if IDENTIFIER_GFF2 =~ str or
              NUMERIC_GFF2 =~ str then
            false
          else
            true
          end
        end

        # (private) escapes normal columns in GFF2
        def gff2_column_to_s(str)
          str = str.to_s
          str = str.empty? ? '.' : str
          str = str.gsub(PROHIBITED_GFF2_COLUMNS) do |x|
            "\\" + (CHAR2BACKSLASH[x] || char2octal(x))
          end
          if str[0, 1] == '#' then
            str[0, 1] = "\\043"
          end
          str
        end

        # (private) escapes GFF2 attribute tag string
        def escape_gff2_attribute_tag(str)
          str = str.to_s
          str = str.empty? ? '.' : str
          str = str.gsub(PROHIBITED_GFF2_TAGS) do |x|
            "\\" + (CHAR2BACKSLASH[x] || char2octal(x))
          end
          if str[0, 1] == '#' then
            str[0, 1] = "\\043"
          end
          str
        end

        # (private) dummy method, will be redefined in GFF3.
        def unescape(str)
          str
        end
      end #module Escape

      # Stores GFF2 record.
      class Record < GFF::Record

        include Escape

        # Stores GFF2 attribute's value.
        class Value

          include Escape

          # Creates a new Value object.
          # Note that the given array _values_ is directly stored in
          # the object.
          #
          # ---
          # *Arguments*:
          # * (optional) _values_: Array containing String objects.
          # *Returns*:: Value object.
          def initialize(values = [])
            @values = values
          end

          # Returns string representation of this Value object.
          # ---
          # *Returns*:: String
          def to_s
            @values.collect do |str|
              escape_gff2_attribute_value(str)
            end.join(' ')
          end

          # Returns all values in this object.
          #
          # Note that modification of the returned array would affect
          # original Value object.
          # ---
          # *Returns*:: Array
          def values
            @values
          end
          alias to_a values

          # Returns true if other == self.
          # Otherwise, returns false.
          def ==(other)
            return false unless other.kind_of?(self.class) or
              self.kind_of?(other.class)
            self.values == other.values rescue super(other)
          end
        end #class Value


        # Parses a GFF2-formatted line and returns a new
        # Bio::GFF::GFF2::Record object.
        def self.parse(str)
          ret = self.new
          ret.parse(str)
          ret
        end
       
        # Creates a Bio::GFF::GFF2::Record object.
        # Is typically not called directly, but
        # is called automatically when creating a Bio::GFF::GFF2 object.
        #
        # ---
        # *Arguments*:
        # * _str_: a tab-delimited line in GFF2 format
        # *Arguments*:
        # * _seqname_: seqname (String or nil)
        # * _source_: source (String or nil)
        # * _feature_: feature type (String)
        # * _start_position_: start (Integer)
        # * _end_position_: end (Integer)
        # * _score_: score (Float or nil)
        # * _strand_: strand (String or nil)
        # * _frame_: frame (Integer or nil)
        # * _attributes_: attributes (Array or nil)
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
          @attributes ||= []
        end

        # Comment for the GFF record
        attr_accessor :comment

        # "comments" is deprecated. Instead, use "comment".
        def comments
          warn "#{self.class.to_s}#comments is deprecated. Instead, use \"comment\"."
          self.comment
        end

        # "comments=" is deprecated. Instead, use "comment=".
        def comments=(str)
          warn "#{self.class.to_s}#comments= is deprecated. Instead, use \"comment=\"."
          self.comment = str
        end

        # Parses a GFF2-formatted line and stores data from the string.
        # Note that all existing data is wiped out.
        def parse(string)
          if /^\s*\#/ =~ string then
            @comment = string[/\#(.*)/, 1].chomp
            columns = []
          else
            columns = string.chomp.split("\t", 10)
            @comment = columns[9][/\#(.*)/, 1].chomp if columns[9]
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

        # Returns true if the entry is empty except for comment.
        # Otherwise, returns false.
        def comment_only?
          if !@seqname and
              !@source and
              !@feature and
              !@start and
              !@end and
              !@score and
              !@strand and
              !@frame and
              @attributes.empty? then
            true
          else
            false
          end
        end

        # Return the record as a GFF2 compatible string
        def to_s
          cmnt = if defined?(@comment) and @comment and
                     !@comment.to_s.strip.empty? then
                   @comment.gsub(/[\r\n]+/, ' ')
                 else
                   false
                 end
          return "\##{cmnt}\n" if self.comment_only? and cmnt
          [
           gff2_column_to_s(@seqname),
           gff2_column_to_s(@source),
           gff2_column_to_s(@feature),
           gff2_column_to_s(@start),
           gff2_column_to_s(@end),
           gff2_column_to_s(@score),
           gff2_column_to_s(@strand),
           gff2_column_to_s(@frame),
           attributes_to_s(@attributes)
          ].join("\t") + 
            (cmnt ? "\t\##{cmnt}\n" : "\n")
        end
        
        # Returns true if self == other. Otherwise, returns false.
        def ==(other)
          super ||
            ((self.class == other.class and
              self.seqname == other.seqname and
              self.source  == other.source and
              self.feature == other.feature and
              self.start   == other.start and
              self.end     == other.end and
              self.score   == other.score and
              self.strand  == other.strand and
              self.frame   == other.frame and
              self.attributes == other.attributes) ? true : false)
        end

        # Gets the attribute value for the given tag.
        #
        # Note that if two or more tag-value pairs with the same name found,
        # only the first value is returned.
        # ---
        # *Arguments*:
        # * (required) _tag_: String
        # *Returns*:: String, Bio::GFF::GFF2::Record::Value object, or nil.
        def get_attribute(tag)
          ary = @attributes.assoc(tag)
          ary ? ary[1] : nil
        end
        alias attribute get_attribute

        # Gets the attribute values for the given tag.
        # This method always returns an array.
        # ---
        # *Arguments*:
        # * (required) _tag_: String
        # *Returns*:: Array containing String or \
        # Bio::GFF::GFF2::Record::Value objects.
        def get_attributes(tag)
          ary = @attributes.find_all do |x|
            x[0] == tag
          end
          ary.collect! { |x| x[1] }
          ary
        end

        # Sets value for the given tag.
        # If the tag exists, the value of the tag is replaced with _value_.
        # Note that if two or more tag-value pairs with the same name found,
        # only the first tag-value pair is replaced.
        #
        # If the tag does not exist, the tag-value pair is newly added.
        # ---
        # *Arguments*:
        # * (required) _tag_: String
        # * (required) _value_: String or Bio::GFF::GFF2::Record::Value object.
        # *Returns*:: _value_
        def set_attribute(tag, value)
          ary = @attributes.find do |x|
            x[0] == tag
          end
          if ary then
            ary[1] = value
          else
            ary = [ String.new(tag), value ]
            @attributes.push ary
          end
          value
        end

        # Replaces values for the given tags with new values.
        # Existing values for the tag are completely wiped out and
        # replaced by new tag-value pairs.
        # If the tag does not exist, the tag-value pairs are newly added.
        #
        # ---
        # *Arguments*:
        # * (required) _tag_: String
        # * (required) _values_: String or Bio::GFF::GFF2::Record::Value objects.
        # *Returns*:: _self_
        def replace_attributes(tag, *values)
          i = 0
          @attributes.reject! do |x|
            if x[0] == tag then
              if i >= values.size then
                true
              else
                x[1] = values[i]
                i += 1
                false
              end
            else
              false
            end
          end
          (i...(values.size)).each do |j|
            @attributes.push [ String.new(tag), values[j] ]
          end
          self
        end

        # Adds a new tag-value pair.
        # ---
        # *Arguments*:
        # * (required) _tag_: String
        # * (required) _value_: String or Bio::GFF::GFF2::Record::Value object.
        # *Returns*:: _value_
        def add_attribute(tag, value)
          @attributes.push([ String.new(tag), value ])
        end

        # Removes a specific tag-value pair.
        #
        # Note that if two or more tag-value pairs found,
        # only the first tag-value pair is removed.
        #
        # ---
        # *Arguments*:
        # * (required) _tag_: String
        # * (required) _value_: String or Bio::GFF::GFF2::Record::Value object.
        # *Returns*:: if removed, _value_. Otherwise, nil.
        def delete_attribute(tag, value)
          removed = nil
          if i = @attributes.index([ tag, value ]) then
            ary = @attributes.delete_at(i)
            removed = ary[1]
          end
          removed
        end

        # Removes all attributes with the specified tag.
        #
        # ---
        # *Arguments*:
        # * (required) _tag_: String
        # *Returns*:: if removed, self. Otherwise, nil.
        def delete_attributes(tag)
          @attributes.reject! do |x|
            x[0] == tag
          end ? self : nil
        end

        # Sorts attributes order by given tag name's order.
        # If a block is given, the argument _tags_ is ignored, and
        # yields two tag names like Array#sort!.
        #
        # ---
        # *Arguments*:
        # * (required or optional) _tags_: Array containing String objects
        # *Returns*:: _self_
        def sort_attributes_by_tag!(tags = nil)
          h = {}
          s = @attributes.size
          @attributes.each_with_index { |x, i|  h[x] = i }
          if block_given? then
            @attributes.sort! do |x, y|
              r = yield x[0], y[0]
              if r == 0 then
                r = (h[x] || s) <=> (h[y] || s)
              end
              r
            end
          else
            unless tags then
              raise ArgumentError, 'wrong number of arguments (0 for 1) or wrong argument value'
            end
            @attributes.sort! do |x, y|
              r = (tags.index(x[0]) || tags.size) <=> 
                (tags.index(y[0]) || tags.size)
              if r == 0 then
                r = (h[x] || s) <=> (h[y] || s)
              end
              r
            end
          end
          self
        end

        # Returns hash representation of attributes.
        #
        # Note: If two or more tag-value pairs with same tag names exist,
        # only the first tag-value pair is used for each tag.
        #
        # ---
        # *Returns*:: Hash object
        def attributes_to_hash
          h = {}
          @attributes.each do |x|
            key, val = x
            h[key] = val unless h[key]
          end
          h
        end

        private

        # (private) Parses attributes.
        # Returns arrays
        def parse_attributes(str)
          return [] if !str or str == '.'
          attr_pairs = parse_attributes_string(str)
          attr_pairs.collect! do |x|
            key = x.shift
            val = (x.size == 1) ? x[0] : Value.new(x)
            [ key, val ]
          end
          attr_pairs
        end

        # (private) Parses attributes string.
        # Returns arrays
        def parse_attributes_string(str)
          sc = StringScanner.new(str)
          attr_pairs = []
          tokens = []
          cur_token = ''
          while !sc.eos?
            if sc.scan(/[^\\\;\"\s]+/) then
              cur_token.concat sc.matched
            elsif sc.scan(/\s+/) then
              tokens.push cur_token unless cur_token.empty?
              cur_token = ''
            elsif sc.scan(/\;/) then
              tokens.push cur_token unless cur_token.empty?
              cur_token = ''
              attr_pairs.push tokens
              tokens = []
            elsif sc.scan(/\"/) then
              tokens.push cur_token unless cur_token.empty?
              cur_token = ''
              freetext = ''
              while !sc.eos?
                if sc.scan(/[^\\\"]+/) then
                  freetext.concat sc.matched
                elsif sc.scan(/\"/) then
                  break
                elsif sc.scan(/\\([\"\\])/) then
                  freetext.concat sc[1]
                elsif sc.scan(/\\x([0-9a-fA-F][0-9a-fA-F])/n) then
                  chr = sc[1].to_i(16).chr
                  freetext.concat chr
                elsif sc.scan(/\\([0-7][0-7][0-7])/n) then
                  chr = sc[1].to_i(8).chr
                  freetext.concat chr
                elsif sc.scan(/\\([^x0-9])/n) then
                  chr = Escape::BACKSLASH[sc[1]] || sc.matched
                  freetext.concat chr
                elsif sc.scan(/\\/) then
                  freetext.concat sc.matched
                else
                  raise 'Bug: should not reach here'
                end
              end
              tokens.push freetext
              #p freetext
            # # disabled support for \; out of freetext
            #elsif sc.scan(/\\\;/) then
            #  cur_token.concat sc.matched
            elsif sc.scan(/\\/) then
              cur_token.concat sc.matched
            else
              raise 'Bug: should not reach here'
            end #if
          end #while
          tokens.push cur_token unless cur_token.empty?
          attr_pairs.push tokens unless tokens.empty?
          return attr_pairs
        end

        # (private) string representation of attributes
        def attributes_to_s(attr)
          attr.collect do |a|
            tag, val = a
            if Escape::IDENTIFIER_GFF2 !~ tag then
              warn "Illegal GFF2 attribute tag: #{tag.inspect}" if $VERBOSE
            end
            tagstr = gff2_column_to_s(tag)
            valstr = if val.kind_of?(Value) then
                       val.to_s
                     else
                       escape_gff2_attribute_value(val)
                     end
            "#{tagstr} #{valstr}"
          end.join(' ; ')
        end
      end #class Record

      # Stores GFF2 meta-data.
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

      # (private) parses metadata
      def parse_metadata(directive, line)
        case directive
        when 'gff-version'
          @gff_version ||= line.split(/\s+/)[1]
        else
          @metadata.push MetaData.parse(line)
        end
        true
      end
      private :parse_metadata

      # Creates a Bio::GFF::GFF2 object by building a collection of
      # Bio::GFF::GFF2::Record (and metadata) objects.
      # 
      # ---
      # *Arguments*:
      # * _str_: string in GFF format
      # *Returns*:: Bio::GFF::GFF2 object
      def initialize(str = nil)
        @gff_version = nil
        @records = []
        @metadata = []
        parse(str) if str
      end

      # GFF2 version string (String or nil). nil means "2".
      attr_reader :gff_version

      # Metadata (except "##gff-version").
      # Must be an array of Bio::GFF::GFF2::MetaData objects.
      attr_accessor :metadata

      # Parses a GFF2 entries, and concatenated the parsed data.
      # 
      # ---
      # *Arguments*:
      # * _str_: string in GFF format
      # *Returns*:: self
      def parse(str)
        # parses GFF lines
        str.each_line do |line|
          if /^\#\#([^\s]+)/ =~ line then
            parse_metadata($1, line)
          else
            @records << GFF2::Record.new(line)
          end
        end
        self
      end

    end #class GFF2

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
      # Bio::GFF::GFF3::Record (and metadata) objects.
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
        ver = @gff_version || VERSION.to_s
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

        if URI.const_defined?(:Parser) then
          # (private) URI::Parser object for escape/unescape GFF3 columns
          URI_PARSER = URI::Parser.new

          # (private) the same as URI::Parser#escape(str, unsafe)
          def _escape(str, unsafe)
            URI_PARSER.escape(str, unsafe)
          end

          # (private) the same as URI::Parser#unescape(str)
          def _unescape(str)
            URI_PARSER.unescape(str)
          end
        else
          # (private) the same as URI.escape(str, unsafe)
          def _escape(str, unsafe)
            URI.escape(str, unsafe)
          end

          # (private) the same as URI.unescape(str)
          def _unescape(str)
            URI.unescape(str)
          end
        end

        # Return the string corresponding to these characters unescaped
        def unescape(string)
          _unescape(string)
        end

        # Escape a column according to the specification at
        # http://song.sourceforge.net/gff3.shtml.
        def escape(string)
          _escape(string, UNSAFE)
        end

        # Escape seqid column according to the specification at
        # http://song.sourceforge.net/gff3.shtml.
        def escape_seqid(string)
          _escape(string, UNSAFE_SEQID)
        end
        
        # Escape attribute according to the specification at
        # http://song.sourceforge.net/gff3.shtml.
        # In addition to the normal escape rule, the following characters
        # are escaped: ",=;".
        # Returns the string corresponding to these characters escaped.
        def escape_attribute(string)
          _escape(string, UNSAFE_ATTRIBUTE)
        end
      end #module Escape

      include Escape

      # Stores meta-data "##sequence-region seqid start end".
      class SequenceRegion
        include Escape
        extend Escape
        
        # creates a new SequenceRegion class
        def initialize(seqid, start, endpos)
          @seqid = seqid
          @start = start ? start.to_i : nil
          @end = endpos ? endpos.to_i : nil
        end

        # parses given string and returns SequenceRegion class
        def self.parse(str)
          _, seqid, start, endpos =
            str.chomp.split(/\s+/, 4).collect { |x| unescape(x) }
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
      class Record < GFF2::Record

        include GFF3::Escape

        # shortcut to the ID attribute
        def id
          get_attribute('ID')
        end

        # set ID attribute
        def id=(str)
          set_attribute('ID', str)
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
        # * _phase_: phase (Integer or nil)
        # * _attributes_: attributes (Array or nil)
        def initialize(*arg)
          super(*arg)
        end

        # Parses a GFF3-formatted line and stores data from the string.
        # Note that all existing data is wiped out.
        def parse(string)
          super
        end

        # Return the record as a GFF3 compatible string
        def to_s
          cmnt = if defined?(@comment) and @comment and
                     !@comment.to_s.strip.empty? then
                   @comment.gsub(/[\r\n]+/, ' ')
                 else
                   false
                 end
          return "\##{cmnt}\n" if self.comment_only? and cmnt
          [
           escape_seqid(column_to_s(@seqname)),
           escape(column_to_s(@source)),
           escape(column_to_s(@feature)),
           escape(column_to_s(@start)),
           escape(column_to_s(@end)),
           escape(column_to_s(@score)),
           escape(column_to_s(@strand)),
           escape(column_to_s(@frame)),
           attributes_to_s(@attributes)
          ].join("\t") + 
            (cmnt ? "\t\##{cmnt}\n" : "\n")
        end
        
        # Bio:GFF::GFF3::Record::Target is a class to store
        # data of "Target" attribute.
        class Target
          include GFF3::Escape
          extend GFF3::Escape

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
              str.split(/ +/, 4).collect { |x| unescape(x) }
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
            data_ref.each do |r|
              len += r.length if r.code == :M
            end
            data.push Code.new(:D, len) if len > 0

            # rest of data_tgt
            len = 0
            data_tgt.each do |t|
              len += t.length if t.code == :M
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
          return [] if !string or string == '.'
          attr_pairs = []
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
            attr_pairs.concat values.collect { |v| [ key, v ] }
          end
          return attr_pairs
        end # method parse_attributes

        # Return the attributes as a string as it appears at the end of
        # a GFF3 line
        def attributes_to_s(attr)
          return '.' if !attr or attr.empty?
          keys = []
          hash = {}
          attr.each do |pair|
            key = pair[0]
            val = pair[1]
            keys.push key unless hash[key]
            hash[key] ||= []
            hash[key].push val
          end
          keys.collect do |key|
            values = hash[key]
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

      # stores GFF3 MetaData
      MetaData = GFF2::MetaData

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

