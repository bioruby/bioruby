#
# bio/db/genbank/common.rb - Common methods for GenBank style database classes
#
#   Copyright (C) 2004 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: common.rb,v 1.9 2005/12/07 11:23:51 k Exp $
#

require 'bio/db'

module Bio
class NCBIDB
module Common

  DELIMITER	= RS = "\n//\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # LOCUS  -- Locus class must be defined in child classes

  # DEFINITION
  def definition
    field_fetch('DEFINITION')
  end


  # ACCESSION
  def accessions
    accession.split(/\s+/)
  end


  # VERSION
  def versions
    @data['VERSION'] ||= fetch('VERSION').split(/\s+/)
  end

  def acc_version
    versions.first.to_s
  end

  def accession
    acc_version.split(/\./).first.to_s
  end

  def version
    acc_version.split(/\./).last.to_i
  end

  def gi
    versions.last
  end


  # NID
  def nid
    field_fetch('NID')
  end


  # KEYWORDS
  def keywords
    @data['KEYWORDS'] ||= fetch('KEYWORDS').chomp('.').split(/; /)
  end


  # SEGMENT
  def segment
    @data['SEGMENT'] ||= fetch('SEGMENT').scan(/\d+/).join("/")
  end


  # SOURCE
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


  # REFERENCE
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


  # COMMENT
  def comment
    field_fetch('COMMENT')
  end


  # FEATURES
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


  # ORIGIN
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


=begin

= Bio::GenBank::Common

This module defines a common framework among GenBank, GenPept, RefSeq, and
DDBJ.  For more details, see the documentations in each genbank/*.rb files.


== SEE ALSO

* ((<URL:ftp://ftp.ncbi.nih.gov/genbank/gbrel.txt>))
* ((<URL:http://www.ncbi.nlm.nih.gov/collab/FT/index.html>))

=end



