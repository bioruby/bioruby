#
# bio/db/genbank.rb - Common methods for GenBank style database classes
#
#   Copyright (C) 2000-2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: genbank.rb,v 0.27 2002/11/22 22:58:46 k Exp $
#

require 'bio/db'

module Bio

  module GENBANK_COMMON

    DELIMITER	= RS = "\n//\n"
    TAGSIZE	= 12

    def initialize(entry)
      super(entry, TAGSIZE)
    end

    # LOCUS  -- locus is redefined in child classes
    def entry_id;	locus.entry_id		end
    def seq_len;	locus.seq_len		end
    def circular;	locus.circular		end
    def division;	locus.division		end
    def date;		locus.date		end


    # DEFINITION
    def definition
      field_fetch('DEFINITION')
    end


    # ACCESSION
    def accession
      field_fetch('ACCESSION')
    end

    def accessions
      accession.split(/\s+/)
    end


    # VERSION
    def versions
      unless @data['VERSION']
        @data['VERSION'] = fetch('VERSION').split(/\s+/)
      end
      @data['VERSION']
    end

    def version
      versions[0]
    end

    def gi
      versions[1]
    end


    # NID
    def nid
      field_fetch('NID')
    end


    # KEYWORDS
    def keywords
      unless @data['KEYWORDS']
        @data['KEYWORDS'] = fetch('KEYWORDS').chomp('.').split('; ')
      end
      @data['KEYWORDS']
    end


    # SEGMENT
    def segment
      unless @data['SEGMENT']
        @data['SEGMENT'] = fetch('SEGMENT').scan(/\d+/).join("/")
      end
      @data['SEGMENT']
    end


    # SOURCE
    def source
      unless @data['SOURCE']
        name, org = get('SOURCE').split('ORGANISM')
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
    alias :varnacular_name :common_name

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
	      authors = authors.split(', ')
	      authors[-1] = authors[-1].split('\s+and\s+')
	      authors = authors.flatten.map { |a| a.sub(',', ', ') }
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
      @data['REFERENCE']
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
	  head = line[0,20].strip

	  # feature value (position or /qualifier=)
	  body = line[20,60].chomp

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
      @data['FEATURES']
    end


    # ORIGIN
    def origin; end
    def seq
      unless @data['SEQUENCE']
        origin
      end
      @data['SEQUENCE']
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

	  if value.empty?
	    value = true
	  end

	  case qualifier
	  when 'translation'
	    value = Sequence::AA.new(value.gsub(/\s/, ''))
	  when 'codon_start'
	    value = value.to_i
	  end

	  feature.append(Feature::Qualifier.new(qualifier, value))
        end
      end

      return feature
    end

  end

end


=begin

= Bio::GENBANK_COMMON

This module defines a common framework among GenBank, GenPept, RefSeq, DDBJ.
For more details, see the documentations in each genbank/*.rb libraries.


== SEE ALSO

  ftp://ftp.ncbi.nih.gov/genbank/gbrel.txt
  http://www.ncbi.nlm.nih.gov/collab/FT/index.html

=end



