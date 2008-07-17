#
# = bio/db/genbank/genbank.rb - GenBank database class
#
# Copyright::  Copyright (C) 2000-2005 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: genbank.rb,v 0.40.2.4 2008/06/17 15:56:18 ngoto Exp $
#

require 'date'
require 'bio/db'
require 'bio/db/genbank/common'
require 'bio/sequence'
require 'bio/sequence/dblink'

module Bio

# == Description
#
# Parses a GenBank formatted database entry
#
# == Example
#
#   # entry is a string containing only one entry contents
#   gb = Bio::GenBank.new(entry)
#
class GenBank < NCBIDB

  include Bio::NCBIDB::Common

  # Parses the LOCUS line and returns contents of the LOCUS record
  # as a Bio::GenBank::Locus object.  Locus object is created automatically
  # when Bio::GenBank#locus, entry_id etc. methods are called.
  class Locus
    def initialize(locus_line)
      if locus_line.empty?
        # do nothing (just for empty or incomplete entry string)
      elsif locus_line.length > 75 			# after Rel 126.0
        @entry_id = locus_line[12..27].strip
        @length   = locus_line[29..39].to_i
        @strand   = locus_line[44..46].strip
        @natype   = locus_line[47..52].strip
        @circular = locus_line[55..62].strip
        @division = locus_line[63..66].strip
        @date     = locus_line[68..78].strip
      else
        @entry_id = locus_line[12..21].strip
        @length   = locus_line[22..29].to_i
        @strand   = locus_line[33..35].strip
        @natype   = locus_line[36..39].strip
        @circular = locus_line[42..51].strip
        @division = locus_line[52..54].strip
        @date     = locus_line[62..72].strip
      end
    end
    attr_accessor :entry_id, :length, :strand, :natype, :circular,
      :division, :date
  end

  # Accessor methods for the contents of the LOCUS record.

  def locus
    @data['LOCUS'] ||= Locus.new(get('LOCUS'))
  end

  def entry_id;  locus.entry_id;  end
  def length;    locus.length;    end
  def circular;  locus.circular;  end
  def division;  locus.division;  end
  def date;      locus.date;      end

  def strand;    locus.strand;    end
  def natype;    locus.natype;    end


  # FEATURES -- Iterate only for the 'CDS' portion of the Bio::Features.
  def each_cds
    features.each do |feature|
      if feature.feature == 'CDS'
        yield(feature)
      end
    end
  end

  # FEATURES -- Iterate only for the 'gene' portion of the Bio::Features.
  def each_gene
    features.each do |feature|
      if feature.feature == 'gene'
        yield(feature)
      end
    end
  end


  # BASE COUNT (this field is obsoleted after GenBank release 138.0) --
  # Returns the BASE COUNT as a Hash.  When the base is specified, returns
  # count of the base as a Fixnum.  The base can be one of 'a', 't', 'g',
  # 'c', and 'o' (others).
  def basecount(base = nil)
    unless @data['BASE COUNT']
      hash = Hash.new(0)
      get('BASE COUNT').scan(/(\d+) (\w)/).each do |c, b|
        hash[b] = c.to_i
      end
      @data['BASE COUNT'] = hash
    end

    if base
      base.downcase!
      @data['BASE COUNT'][base]
    else
      @data['BASE COUNT']
    end
  end

  # ORIGIN -- Returns DNA sequence in the ORIGIN record as a
  # Bio::Sequence::NA object.
  def seq
    unless @data['SEQUENCE']
      origin
    end
    Bio::Sequence::NA.new(@data['SEQUENCE'])
  end
  alias naseq seq
  alias nalen length

  # (obsolete???) length of the sequence
  def seq_len
    seq.length
  end

  # modified date. Returns Date object, String or nil.
  def date_modified
    begin
      Date.parse(self.date)
    rescue ArgumentError, TypeError, NoMethodError, NameError
      self.date
    end
  end

  # Taxonomy classfication. Returns an array of strings.
  def classification
    self.taxonomy.to_s.sub(/\.\z/, '').split(/\s*\;\s*/)
  end

  # Strandedness. Returns one of 'single', 'double', 'mixed', or nil.
  def strandedness
    case self.strand.to_s.downcase
    when 'ss-'; 'single'
    when 'ds-'; 'double'
    when 'ms-'; 'mixed'
    else nil; end
  end

  # converts Bio::GenBank to Bio::Sequence
  # ---
  # *Arguments*: 
  # *Returns*:: Bio::Sequence object
  def to_biosequence
    Bio::Sequence.adapter(self, Bio::Sequence::Adapter::GenBank)
  end

end # GenBank
end # Bio



if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  puts "### GenBank"
  if ARGV.size > 0
    gb = Bio::GenBank.new(ARGF.read)
  else
    require 'bio/io/fetch'
    gb = Bio::GenBank.new(Bio::Fetch.query('gb', 'LPATOVGNS'))
  end

  puts "## LOCUS"
  puts "# GenBank.locus"
  p gb.locus
  puts "# GenBank.entry_id"
  p gb.entry_id
  puts "# GenBank.nalen"
  p gb.nalen
  puts "# GenBank.strand"
  p gb.strand
  puts "# GenBank.natype"
  p gb.natype
  puts "# GenBank.circular"
  p gb.circular
  puts "# GenBank.division"
  p gb.division
  puts "# GenBank.date"
  p gb.date

  puts "## DEFINITION"
  p gb.definition

  puts "## ACCESSION"
  p gb.accession

  puts "## VERSION"
  p gb.versions
  p gb.version
  p gb.gi

  puts "## NID"
  p gb.nid

  puts "## KEYWORDS"
  p gb.keywords

  puts "## SEGMENT"
  p gb.segment

  puts "## SOURCE"
  p gb.source
  p gb.common_name
  p gb.vernacular_name
  p gb.organism
  p gb.taxonomy

  puts "## REFERENCE"
  p gb.references

  puts "## COMMENT"
  p gb.comment

  puts "## FEATURES"
  p gb.features

  puts "## BASE COUNT"
  p gb.basecount
  p gb.basecount('a')
  p gb.basecount('A')

  puts "## ORIGIN"
  p gb.origin
  p gb.naseq

end



