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

module Bio

# Bio::Fastq is a parser for FASTQ format.
#
class Fastq

  # Splitter for Bio::FlatFile
  FLATFILE_SPLITTER = Bio::FlatFile::Splitter::LineOriented

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
      @definition = line.sub(/\A\@/, '')
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
      if line[0, 1] == "+" then
        @definition2 = line[1..-1]
        return self
      else
        @sequence_string.concat line
        return self
      end
    end
    raise "Bug: should not reach here!"
  end

  # entry_overrun
  attr_reader :entry_overrun

  # Creates a new Fastq object from formatted text string.
  #
  #
  # ---
  # *Arguments*:
  # * _str_: Formatted string (String)
  def initialize(str = nil)
    return unless str
    sc = StringScanner.new(str)
    while line = sc.scan(/.*(?:\n|\r|\r\n)?/)
      break unless add_header_line(line)
    end
    add_line(line) if line
    while line = sc.scan(/.*(?:\n|\r|\r\n)?/)
      break unless add_line(line)
    end
    sc.unscan if line
    @entry_overrun = sc.rest
  end

  # definition
  attr_reader :definition

  # quality as a string
  attr_reader :quality_string

  # raw sequence data as a String object
  attr_reader :sequence_string

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

  # Phred quality
  def phred_quality
    unless defined? @phred_quality then
      q = @quality_string.enum_for(:each_byte).collect do |x|
        x - 33
      end
      @phred_quality = q
    end
    @phred_quality
  end

  # Solexa quality
  def solexa_quality
    unless defined? @solexa_quality then
      q = @quality_string.enum_for(:each_byte).collect do |x|
        10 * Math.log10(1 + 10 ** (x - 64) / 10.0)
      end
      @solexa_quality = q
    end
    @solexa_quality
  end

  # Returns sequence as a Bio::Sequence object.
  #
  # Note: If you modify the returned Bio::Sequence object,
  # the sequence or definition in this Fastq object
  # might also be changed (but not always be changed)
  # because of efficiency.
  # 
  def to_biosequence
    #Bio::Sequence.adapter(self, Bio::Sequence::Adapter::Fastq)
  end

end #class Fastq

end #module Bio
