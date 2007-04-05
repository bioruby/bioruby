#
# = bio/db/genbank/common.rb - Common methods for GenBank style database classes
#
# Copyright::  Copyright (C) 2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: common.rb,v 1.11 2007/04/05 23:35:40 trevor Exp $
#

require 'bio/db'

module Bio
class NCBIDB

# == Description
# 
# This module defines a common framework among GenBank, GenPept, RefSeq, and
# DDBJ.  For more details, see the documentations in each genbank/*.rb files.
# 
# == References
# 
# * ftp://ftp.ncbi.nih.gov/genbank/gbrel.txt
# * http://www.ncbi.nlm.nih.gov/collab/FT/index.html
#
module Common

  DELIMITER	= RS = "\n//\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # LOCUS -- Locus class must be defined in child classes.
  def locus
    # must be overrided in each subclass
  end

  # DEFINITION -- Returns contents of the DEFINITION record as a String.
  def definition
    field_fetch('DEFINITION')
  end


  # ACCESSION -- Returns contents of the ACCESSION record as an Array.
  def accessions
    accession.split(/\s+/)
  end


  # VERSION -- Returns contents of the VERSION record as an Array of Strings.
  def versions
    @data['VERSION'] ||= fetch('VERSION').split(/\s+/)
  end

  # Returns the first part of the VERSION record as "ACCESSION.VERSION" String.
  def acc_version
    versions.first.to_s
  end

  # Returns the ACCESSION part of the acc_version.
  def accession
    acc_version.split(/\./).first.to_s
  end

  # Returns the VERSION part of the acc_version as a Fixnum
  def version
    acc_version.split(/\./).last.to_i
  end

  # Returns the second part of the VERSION record as a "GI:#######" String.
  def gi
    versions.last
  end


  # NID -- Returns contents of the NID record as a String.
  def nid
    field_fetch('NID')
  end


  # KEYWORDS -- Returns contents of the KEYWORDS record as an Array of Strings.
  def keywords
    @data['KEYWORDS'] ||= fetch('KEYWORDS').chomp('.').split(/; /)
  end


  # SEGMENT -- Returns contents of the SEGMENT record as a "m/n" form String.
  def segment
    @data['SEGMENT'] ||= fetch('SEGMENT').scan(/\d+/).join("/")
  end


  # SOURCE -- Returns contents of the SOURCE record as a Hash.
  def source
    unless @data['SOURCE']
      name, org = get('SOURCE').split('ORGANISM')
      org ||= ""
      if org[/\S+;/]
        organism = $`
        taxonomy = $& + $'
      elsif org[/\S+\./]				# rs:NC_001741
        organism = $`
        taxonomy = $& + $'
      else
        organism = org
        taxonomy = ''
      end
      @data['SOURCE'] = {
        'common_name'	=> truncate(tag_cut(name)),
        'organism'	=> truncate(organism),
        'taxonomy'	=> truncate(taxonomy),
      }
      @data['SOURCE'].default = ''
    end
    @data['SOURCE']
  end

  def common_name
    source['common_name']
  end
  alias vernacular_name common_name

  def organism
    source['organism']
  end

  def taxonomy
    source['taxonomy']
  end


  # REFERENCE -- Returns contents of the REFERENCE records as an Array of
  # Bio::Reference objects.
  def references
    unless @data['REFERENCE']
      ary = []
      toptag2array(get('REFERENCE')).each do |ref|
        hash = Hash.new('')
        subtag2array(ref).each do |field|
          case tag_get(field)
          when /AUTHORS/
            authors = truncate(tag_cut(field))
            authors = authors.split(/, /)
            authors[-1] = authors[-1].split(/\s+and\s+/) if authors[-1]
            authors = authors.flatten.map { |a| a.sub(/,/, ', ') }
            hash['authors']	= authors
          when /TITLE/
            hash['title']	= truncate(tag_cut(field)) + '.'
          when /JOURNAL/
            journal = truncate(tag_cut(field))
            if journal =~ /(.*) (\d+) \((\d+)\), (\d+-\d+) \((\d+)\)$/
      	hash['journal']	= $1
      	hash['volume']	= $2
      	hash['issue']	= $3
      	hash['pages']	= $4
      	hash['year']	= $5
            else
      	hash['journal'] = journal
            end
          when /MEDLINE/
            hash['medline']	= truncate(tag_cut(field))
          when /PUBMED/
            hash['pubmed']	= truncate(tag_cut(field))
          end
        end
        ary.push(Reference.new(hash))
      end
      @data['REFERENCE'] = References.new(ary)
    end
    if block_given?
      @data['REFERENCE'].each do |r|
        yield r
      end
    else
      @data['REFERENCE']
    end
  end


  # COMMENT -- Returns contents of the COMMENT record as a String.
  def comment
    field_fetch('COMMENT')
  end


  # FEATURES -- Returns contents of the FEATURES record as a Bio::Features
  # object.
  def features
    unless @data['FEATURES']
      ary = []
      in_quote = false
      get('FEATURES').each_line do |line|
        next if line =~ /^FEATURES/

        # feature type  (source, CDS, ...)
        head = line[0,20].to_s.strip

        # feature value (position or /qualifier=)
        body = line[20,60].to_s.chomp

        # sub-array [ feature type, position, /q="data", ... ]
        if line =~ /^ {5}\S/
          ary.push([ head, body ])

        # feature qualifier start (/q="data..., /q="data...", /q=data, /q)
        elsif body =~ /^ \// and not in_quote		# gb:IRO125195
          ary.last.push(body)
          
          # flag for open quote (/q="data...)
          if body =~ /="/ and body !~ /"$/
            in_quote = true
          end

        # feature qualifier continued (...data..., ...data...")
        else
          ary.last.last << body

          # flag for closing quote (/q="data... lines  ...")
          if body =~ /"$/
            in_quote = false
          end
        end
      end

      ary.collect! do |subary|
        parse_qualifiers(subary)
      end

      @data['FEATURES'] = Features.new(ary)
    end
    if block_given?
      @data['FEATURES'].each do |f|
        yield f
      end
    else
      @data['FEATURES']
    end
  end


  # ORIGIN -- Returns contents of the ORIGIN record as a String.
  def origin
    unless @data['ORIGIN']
      ori, seqstr = get('ORIGIN').split("\n", 2)
      seqstr ||= ""
      @data['ORIGIN'] = truncate(tag_cut(ori))
      @data['SEQUENCE'] = seqstr.tr("0-9 \t\n\r\/", '')
    end
    @data['ORIGIN']
  end


  ### private methods

  private

  def parse_qualifiers(ary)
    feature = Feature.new

    feature.feature = ary.shift
    feature.position = ary.shift.gsub(/\s/, '')

    ary.each do |f|
      if f =~ %r{/([^=]+)=?"?([^"]*)"?}
        qualifier, value = $1, $2

        case qualifier
        when 'translation'
          value = Sequence::AA.new(value)
        when 'codon_start'
          value = value.to_i
        else
          value = true if value.empty?
        end

        feature.append(Feature::Qualifier.new(qualifier, value))
      end
    end

    return feature
  end

end # Common 

end # GenBank
end # Bio


