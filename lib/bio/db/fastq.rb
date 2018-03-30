#
# = bio/db/fastq.rb - FASTQ format parser class
#
# Copyright::  Copyright (C) 2009
#              Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# == Description
# 
# FASTQ format parser class.
#
# Be careful that it is for the fastQ format, not for the fastA format.
#
# == Examples
#
# See documents of Bio::Fastq class.
#
# == References
#
# * FASTQ format specification
#   http://maq.sourceforge.net/fastq.shtml
#

require "strscan"
require "singleton"

require 'bio/sequence'
require 'bio/io/flatfile'

module Bio

# Bio::Fastq is a parser for FASTQ format.
#
class Fastq

  # Bio::Fastq::FormatData is a data class to store Fastq format parameters
  # and quality calculation methods.
  # Bio::Fastq internal use only. 
  class FormatData

    # Format name. Should be redefined in subclass.
    NAME = nil

    # Offset. Should be redefined in subclass.
    OFFSET = nil

    # Range of score. Should be redefined in subclass.
    # The range must not exclude end value, i.e. it must be X..Y,
    # and must not be X...Y.
    SCORE_RANGE = nil

    def initialize
      @name = self.class::NAME
      @symbol = @name.gsub(/\-/, '_').to_sym
      @offset = self.class::OFFSET
      @score_range = self.class::SCORE_RANGE
    end

    # Format name
    attr_reader :name

    # Format name symbol.
    # Note that "-" in the format name is substituted to "_" because
    # "-" in a symbol is relatively difficult to handle.
    attr_reader :symbol

    # Offset when converting a score to a character
    attr_reader :offset

    # Allowed range of a score value
    attr_reader :score_range

    # Type of quality scores. Maybe one of :phred or :solexa.
    attr_reader :quality_score_type if false # for RDoc

    # Converts quality string to scores.
    # No overflow/underflow checks will be performed.
    # ---
    # *Arguments*:
    # * (required) _c_: (String) quality string
    # *Returns*:: (Array containing Integer) score values
    def str2scores(str)
      a = str.unpack('C*')
      a.collect! { |i| i - @offset }
      a
    end

    # Converts scores to a string.
    # Overflow/underflow checks will be performed. 
    # If a block is given, when overflow/underflow detected,
    # the score value is passed to the block, and uses returned value
    # as the score. If no blocks, silently truncated.
    #
    # ---
    # *Arguments*:
    # * (required) _a_: (Array containing Integer) score values
    # *Returns*:: (String) quality string
    def scores2str(a)
      if block_given? then
        tmp = a.collect do |i|
          i = yield(i) unless @score_range.include?(i)
          i + @offset
        end
      else
        min = @score_range.begin
        max = @score_range.end
        tmp = a.collect do |i|
          if i < min then
            i = min
          elsif i > max then
            i = max
          end
          i + @offset
        end
      end
      tmp.pack('C*')
    end

    # Format information for "fastq-sanger".
    # Bio::Fastq internal use only.
    class FASTQ_SANGER < FormatData
      include Singleton

      include Bio::Sequence::QualityScore::Phred

      # format name
      NAME = 'fastq-sanger'.freeze
      # offset 
      OFFSET = 33
      # score range
      SCORE_RANGE = 0..93

    end #class FASTQ_SANGER

    # Format information for "fastq-solexa"
    # Bio::Fastq internal use only.
    class FASTQ_SOLEXA < FormatData
      include Singleton

      include Bio::Sequence::QualityScore::Solexa

      # format name
      NAME = 'fastq-solexa'.freeze
      # offset 
      OFFSET = 64
      # score range
      SCORE_RANGE = (-5)..62

    end #class FASTQ_SOLEXA

    # Format information for "fastq-illumina"
    # Bio::Fastq internal use only.
    class FASTQ_ILLUMINA < FormatData
      include Singleton

      include Bio::Sequence::QualityScore::Phred

      # format name
      NAME = 'fastq-illumina'.freeze
      # offset 
      OFFSET = 64
      # score range
      SCORE_RANGE = 0..62

    end #class FASTQ_ILLUMINA

  end #class FormatData


  # Available format names.
  FormatNames = {
    "fastq-sanger"   => FormatData::FASTQ_SANGER,
    "fastq-solexa"   => FormatData::FASTQ_SOLEXA,
    "fastq-illumina" => FormatData::FASTQ_ILLUMINA
  }.freeze

  # Available format name symbols.
  Formats = {
    :fastq_sanger   => FormatData::FASTQ_SANGER,
    :fastq_solexa   => FormatData::FASTQ_SOLEXA,
    :fastq_illumina => FormatData::FASTQ_ILLUMINA
  }.freeze

  # Default format name
  DefaultFormatName = 'fastq-sanger'.freeze

  # Splitter for Bio::FlatFile
  FLATFILE_SPLITTER = Bio::FlatFile::Splitter::LineOriented


  # Basic exception class of all Bio::Fastq::Error:XXXX.
  # Bio::Fastq internal use only.
  class Error < RuntimeError

    private
    # default error message for this exception
    def default_message(i)
      "FASTQ error #{i}"
    end

    # Creates a new object.
    # If error message is not given, default error message is stored.
    # If error message is a Integer value, it is treated as the
    # position inside the sequence or the quality, and default
    # error message including the position is stored.
    # ---
    # *Arguments*:
    # * (optional) <em>error_message</em>: error message (see above)
    def initialize(error_message = nil)
      if !error_message or error_message.kind_of?(Integer) then
        error_message = default_message(error_message)
      end
      super(error_message)
    end

    # Error::No_atmark  -- the first identifier does not begin with "@"
    class No_atmark < Error
      private
      # default error message for this exception
      def default_message(i)
        'the first identifier does not begin with "@"'
      end
    end

    # Error::No_ids     -- sequence identifier not found
    class No_ids < Error
      private
      # default error message for this exception
      def default_message(i)
        'sequence identifier not found'
      end
    end

    # Error::Diff_ids   -- the identifier in the two lines are different
    class Diff_ids < Error
      private
      # default error message for this exception
      def default_message(i)
        'the identifier in the two lines are different'
      end
    end

    # Error::Long_qual  -- length of quality is longer than the sequence
    class Long_qual < Error
      private
      # default error message for this exception
      def default_message(i)
        'length of quality is longer than the sequence'
      end
    end

    # Error::Short_qual -- length of quality is shorter than the sequence
    class Short_qual < Error
      private
      # default error message for this exception
      def default_message(i)
        'length of quality is shorter than the sequence'
      end
    end

    # Error::No_qual    -- no quality characters found
    class No_qual < Error
      private
      # default error message for this exception
      def default_message(i)
        'no quality characters found'
      end
    end

    # Error::No_seq     -- no sequence found
    class No_seq < Error
      private
      # default error message for this exception
      def default_message(i)
        'no sequence found'
      end
    end

    # Error::Qual_char  -- invalid character in the quality
    class Qual_char < Error
      private
      # default error message for this exception
      def default_message(i)
        pos = i ? " at [#{i}]" : ''
        "invalid character in the quality#{pos}"
      end
    end

    # Error::Seq_char   -- invalid character in the sequence
    class Seq_char < Error
      private
      # default error message for this exception
      def default_message(i)
        pos = i ? " at [#{i}]" : ''
        "invalid character in the sequence#{pos}"
      end
    end

    # Error::Qual_range -- quality score value out of range
    class Qual_range < Error
      private
      # default error message for this exception
      def default_message(i)
        pos = i ? " at [#{i}]" : ''
        "quality score value out of range#{pos}"
      end
    end

    # Error::Skipped_unformatted_lines -- the parser skipped unformatted
    # lines that could not be recognized as FASTQ format
    class Skipped_unformatted_lines < Error
      private
      # default error message for this exception
      def default_message(i)
        "the parser skipped unformatted lines that could not be recognized as FASTQ format"
      end
    end
  end #class Error

  # Adds a header line if the header data is not yet given and
  # the given line is suitable for header.
  # Returns self if adding header line is succeeded.
  # Otherwise, returns false (the line is not added).
  def add_header_line(line)
    @header ||= ""
    if line[0,1] == "@" then
      false
    else
      @header.concat line
      self
    end
  end

  # misc lines before the entry (String or nil)
  attr_reader :header

  # Adds a line to the entry if the given line is regarded as
  # a part of the current entry.
  def add_line(line)
    line = line.chomp
    if !defined? @definition then
      if line[0, 1] == "@" then
        @definition = line[1..-1]
      else
        @definition = line
        @parse_errors ||= []
        @parse_errors.push Error::No_atmark.new
      end
      return self
    end
    if defined? @definition2 then
      @quality_string ||= ''
      if line[0, 1] == "@" and
          @quality_string.size >= @sequence_string.size then
        return false
      else
        @quality_string.concat line
        return self
      end
    else
      @sequence_string ||= ''
      if line[0, 1] == '+' then
        @definition2 = line[1..-1]
      else
        @sequence_string.concat line
      end
      return self
    end
    raise "Bug: should not reach here!"
  end

  # entry_overrun
  attr_reader :entry_overrun

  # Creates a new Fastq object from formatted text string.
  #
  # The format of quality scores should be specified later
  # by using <tt>format=</tt> method.
  #
  # ---
  # *Arguments*:
  # * _str_: Formatted string (String)
  def initialize(str = nil)
    return unless str
    sc = StringScanner.new(str)
    while !sc.eos? and line = sc.scan(/.*(?:\n|\r|\r\n)?/)
      unless add_header_line(line) then
        sc.unscan
        break
      end
    end
    while !sc.eos? and line = sc.scan(/.*(?:\n|\r|\r\n)?/)
      unless add_line(line) then
        sc.unscan
        break
      end
    end
    @entry_overrun = sc.rest
  end

  # definition; ID line (begins with @)
  attr_reader :definition

  # quality as a string
  attr_reader :quality_string

  # raw sequence data as a String object
  attr_reader :sequence_string

  # Returns Fastq formatted string constructed from instance variables.
  # The string will always be consisted of four lines without wrapping of
  # the sequence and quality string, and the third-line is always only
  # contains "+". This may be different from initial entry.
  #
  # Note that use of the method may be inefficient and may lose performance
  # because new string object is created every time it is called.
  # For showing an entry as-is, consider using Bio::FlatFile#entry_raw.
  # For output with various options, use Bio::Sequence#output(:fastq).
  #
  def to_s
    "@#{@definition}\n#{@sequence_string}\n+\n#{@quality_string}\n"
  end

  # returns Bio::Sequence::NA
  def naseq
    unless defined? @naseq then
      @naseq = Bio::Sequence::NA.new(@sequence_string)
    end
    @naseq
  end

  # length of naseq
  def nalen
    naseq.length
  end

  # returns Bio::Sequence::Generic
  def seq
    unless defined? @seq then
      @seq = Bio::Sequence::Generic.new(@sequence_string)
    end
    @seq
  end

  # Identifier of the entry. Normally, the first word of the ID line.
  def entry_id
    unless defined? @entry_id then
      eid = @definition.strip.split(/\s+/)[0] || @definition
      @entry_id = eid
    end
    @entry_id
  end

  # (private) reset internal state
  def reset_state
    if defined? @quality_scores then
      remove_instance_variable(:@quality_scores)
    end
    if defined? @error_probabilities then
      remove_instance_variable(:@error_probabilities)
    end
  end
  private :reset_state

  # Specify the format. If the format is not found, raises RuntimeError.
  #
  # Available formats are:
  #   "fastq-sanger" or :fastq_sanger
  #   "fastq-solexa" or :fastq_solexa
  #   "fastq-illumina" or :fastq_illumina
  # 
  # ---
  # *Arguments*:
  # * (required) _name_: format name (String or Symbol).
  # *Returns*:: (String) format name
  def format=(name)
    if name then
      f = FormatNames[name] || Formats[name]
      if f then
        reset_state
        @format = f.instance
        self.format
      else
        raise "unknown format"
      end
    else
      reset_state
      nil
    end
  end

  # Format name.
  # One of "fastq-sanger", "fastq-solexa", "fastq-illumina",
  # or nil (when not specified).
  # ---
  # *Returns*:: (String or nil) format name
  def format
    ((defined? @format) && @format) ? @format.name : nil
  end


  # The meaning of the quality scores.
  # It may be one of :phred, :solexa, or nil.
  def quality_score_type
    self.format ||= self.class::DefaultFormatName
    @format.quality_score_type
  end

  # Quality score for each base.
  # For "fastq-sanger" or "fastq-illumina", it is PHRED score.
  # For "fastq-solexa", it is Solexa score.
  #
  # ---
  # *Returns*:: (Array containing Integer) quality score values
  def quality_scores
    unless defined? @quality_scores then
      self.format ||= self.class::DefaultFormatName
      s = @format.str2scores(@quality_string)
      @quality_scores = s
    end
    @quality_scores
  end

  alias qualities quality_scores

  # Estimated probability of error for each base.
  # ---
  # *Returns*:: (Array containing Float) error probability values
  def error_probabilities
    unless defined? @error_probabilities then
      self.format ||= self.class::DefaultFormatName
      a = @format.q2p(self.quality_scores)
      @error_probabilities = a
    end
    @error_probabilities
  end

  # Format validation.
  #
  # If an array is given as the argument, when errors are found,
  # error objects are pushed to the array.
  # Currently, following errors may be added to the array.
  # (All errors are under the Bio::Fastq namespace, for example,
  # Bio::Fastq::Error::Diff_ids).
  #
  # Error::Diff_ids   -- the identifier in the two lines are different
  # Error::Long_qual  -- length of quality is longer than the sequence
  # Error::Short_qual -- length of quality is shorter than the sequence
  # Error::No_qual    -- no quality characters found
  # Error::No_seq     -- no sequence found
  # Error::Qual_char  -- invalid character in the quality
  # Error::Seq_char   -- invalid character in the sequence
  # Error::Qual_range -- quality score value out of range
  # Error::No_ids     -- sequence identifier not found
  # Error::No_atmark  -- the first identifier does not begin with "@"
  # Error::Skipped_unformatted_lines -- the parser skipped unformatted lines that could not be recognized as FASTQ format
  #
  # ---
  # *Arguments*:
  # * (optional) _errors_: (Array or nil) an array for pushing error messages. The array should be empty.
  # *Returns*:: true:no error, false: containing error.
  def validate_format(errors = nil)
    err = []

    # if header exists, the format might be broken.
    if defined? @header and @header and !@header.strip.empty? then
      err.push Error::Skipped_unformatted_lines.new
    end

    # if parse errors exist, adding them
    if defined? @parse_errors and @parse_errors then
      err.concat @parse_errors
    end

    # check if identifier exists, and identifier matches
    if !defined?(@definition) or !@definition then
      err.push Error::No_ids.new
    elsif defined?(@definition2) and
        !@definition2.to_s.empty? and
        @definition != @definition2 then
      err.push Error::Diff_ids.new
    end

    # check if sequence exists
    has_seq  = true
    if !defined?(@sequence_string) or !@sequence_string then
      err.push Error::No_seq.new
      has_seq = false
    end

    # check if quality exists
    has_qual = true
    if !defined?(@quality_string) or !@quality_string then
      err.push Error::No_qual.new
      has_qual = false
    end

    # sequence and quality length check
    if has_seq and has_qual then
      slen = @sequence_string.length
      qlen = @quality_string.length
      if slen > qlen then
        err.push Error::Short_qual.new
      elsif qlen > slen then
        err.push Error::Long_qual.new
      end
    end

    # sequence character check
    if has_seq then
      sc = StringScanner.new(@sequence_string)
      while sc.scan_until(/[ \x00-\x1f\x7f-\xff]/n)
        err.push Error::Seq_char.new(sc.pos - sc.matched_size)
      end
    end

    # sequence character check
    if has_qual then
      fmt = if defined?(@format) and @format then
              @format.name
            else
              nil
            end
      re = case fmt
           when 'fastq-sanger'
             /[^\x21-\x7e]/n
           when 'fastq-solexa'
             /[^\x3b-\x7e]/n
           when 'fastq-illumina'
             /[^\x40-\x7e]/n
           else
             /[ \x00-\x1f\x7f-\xff]/n
           end
      sc = StringScanner.new(@quality_string)
      while sc.scan_until(re)
        err.push Error::Qual_char.new(sc.pos - sc.matched_size)
      end
    end

    # if "errors" is given, set errors
    errors.concat err if errors
    # returns true if no error; otherwise, returns false
    err.empty? ? true : false
  end

  # Returns sequence as a Bio::Sequence object.
  #
  # Note: If you modify the returned Bio::Sequence object,
  # the sequence or definition in this Fastq object
  # might also be changed (but not always be changed)
  # because of efficiency.
  # 
  def to_biosequence
    Bio::Sequence.adapter(self, Bio::Sequence::Adapter::Fastq)
  end

  # Masks low quality sequence regions.
  # For each sequence position, if the quality score is smaller than
  # the threshold, the sequence in the position is replaced with
  # <em>mask_char</em>.
  #
  # Note: This method does not care quality_score_type.
  # ---
  # *Arguments*:
  # * (required) <em>threshold</em> : (Numeric) threshold
  # * (optional) <em>mask_char</em> : (String) character used for masking
  # *Returns*:: Bio::Sequence object
  def mask(threshold, mask_char = 'n')
    to_biosequence.mask_with_quality_score(threshold, mask_char)
  end

end #class Fastq

end #module Bio
