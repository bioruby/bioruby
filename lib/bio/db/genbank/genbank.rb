#
# bio/db/genbank.rb - GenBank database class
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
#  $Id: genbank.rb,v 0.21 2002/03/04 07:56:58 katayama Exp $
#

require 'bio/db'

module Bio

  class GenBank < NCBIDB

    DELIMITER	= RS = "\n//\n"
    TAGSIZE	= 12

    def initialize(entry)
      super(entry, TAGSIZE)
    end


    # LOCUS
    class Locus
      def initialize(locus_line)
        if locus_line.length > 75 			# after Rel 126.0
	  @entry_id = locus_line[12..30].strip
	  @seq_len  = locus_line[31..41].to_i
	  @strand   = locus_line[46..48].strip
	  @natype   = locus_line[49..54].strip
	  @circular = locus_line[55..63].strip
	  @division = locus_line[64..67].strip
	  @date     = locus_line[68..78].strip
        else
	  @entry_id = locus_line[12..21].strip
	  @seq_len  = locus_line[22..29].to_i
	  @strand   = locus_line[33..35].strip
	  @natype   = locus_line[36..39].strip
	  @circular = locus_line[42..51].strip
	  @division = locus_line[52..54].strip
	  @date     = locus_line[62..72].strip
        end
      end
      attr_accessor :entry_id, :seq_len, :strand, :natype, :circular,
	:division, :date
    end

    def locus
      @data['LOCUS'] = Locus.new(get('LOCUS')) unless @data['LOCUS']
      @data['LOCUS']
    end

    def entry_id
      locus.entry_id
    end

    def nalen
      locus.seq_len
    end

    def strand
      locus.strand
    end

    def natype
      locus.natype
    end

    def circular
      locus.circular
    end

    def division
      locus.division
    end

    def date
      locus.date
    end


    # DEFINITION
    def definition
      field_fetch('DEFINITION')
    end


    # ACCESSION
    def accession
      field_fetch('ACCESSION')
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
    alias varnacular_name common_name

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

    def each_cds
      features.each do |feature|
        if feature.type == 'CDS'
          yield(feature)
        end
      end
    end

    def each_gene
      features.each do |feature|
        if feature.type == 'gene'
          yield(feature)
        end
      end
    end


    # BASE COUNT
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

    def gc
      num_gc = basecount('g') + basecount('c')
      num_at = basecount('a') + basecount('t')
      return format("%.1f", num_gc * 100.0 / (num_at + num_gc)).to_f
    end


    # ORIGIN
    def origin
      unless @data['ORIGIN']
        ori = get('ORIGIN')[/.*/]			# 1st line
        seq = get('ORIGIN').sub(/.*/, '')		# sequence lines
        @data['ORIGIN']   = truncate(tag_cut(ori))
        @data['SEQUENCE'] = Sequence::NA.new(seq.tr('^a-z', ''))
      end
      @data['ORIGIN']
    end

    def naseq
      unless @data['SEQUENCE']
        origin
      end
      @data['SEQUENCE']
    end


    ### private methods

    private

    def parse_qualifiers(ary)
      feature = Feature.new

      feature.type = ary.shift
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



if __FILE__ == $0

  begin
    require 'pp'
    def p(arg); pp(arg); end
  rescue LoadError
  end

  require 'bio/io/dbget'

  puts "### GenBank"
  if ARGV.size > 0
    gb = Bio::GenBank.new(ARGF.read)
  else
#   gb = Bio::GenBank.new(Bio::DBGET.bget('gb LPATOVGNS'))
    gb = Bio::GenBank.new(Bio::DBGET.bget('gb IRO125195'))
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
  p gb.varnacular_name
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
  p gb.gc

  puts "## ORIGIN"
  p gb.origin
  p gb.naseq

end


=begin

= Bio::GenBank

=== Initialize

--- Bio::GenBank.new(entry)

=== LOCUS

--- Bio::GenBank#locus -> Bio::Locus

      Returns contents of the LOCUS record as a Bio::GenBank::Locus object.

--- Bio::GenBank#entry_id -> String
--- Bio::GenBank#nalen -> Fixnum
--- Bio::GenBank#strand -> String
--- Bio::GenBank#natype -> String
--- Bio::GenBank#circular -> String
--- Bio::GenBank#division -> String
--- Bio::GenBank#date -> String

      Access methods for the contents of the LOCUS record.

=== DEFINITION

--- Bio::GenBank#definition -> String

      Returns contents of the DEFINITION record as a String.

=== ACCESSION

--- Bio::GenBank#accession -> String

      Returns contents of the ACCESSION record as a String.

=== VERSION

--- Bio::GenBank#versions -> Array

      Returns contents of the VERSION record as an Array of Strings.

--- Bio::GenBank#version -> String
--- Bio::GenBank#gi -> String

      Access methods for the contents of the VERSION record.

      The 'version' method returns the first part of the VERSION record
      as a "ACCESSION.VERSION" String, and the 'gi' method returns the
      second part of the VERSION record as a "GI:#######" String.

=== NID

--- Bio::GenBank#nid -> String

      Returns contents of the NID record as a String.

=== KEYWORDS

--- Bio::GenBank#keywords -> Array

      Returns contents of the KEYWORDS record as an Array of Strings.

=== SEGMENT

--- Bio::GenBank#segment -> String

      Returns contents of the SEGMENT record as a "m/n" form String.

=== SOURCE

--- Bio::GenBank#source -> Hash

      Returns contents of the SOURCE record as a Hash.

--- Bio::GenBank#common_name -> String
--- Bio::GenBank#varnacular_name -> String
--- Bio::GenBank#organism -> String
--- Bio::GenBank#taxonomy -> String

      Access methods for the contents of the SOURCE record.

      The 'common_name' method is same as source['common_name'].
      The 'varnacular_name' method is an alias for the 'common_name'.
      The 'organism' method is same as source['organism'].
      The 'taxonomy' method is same as source['taxonomy'].

=== REFERENCE

--- Bio::GenBank#references -> Array

      Returns contents of the REFERENCE records as an Array of Bio::Reference
      objects.

=== COMMENT

--- Bio::GenBank#comment -> String

      Returns contents of the COMMENT record as a String.

=== FEATURES

--- Bio::GenBank#features -> Bio::Features

      Returns contents of the FEATURES record as a Bio::Features object.

--- Bio::GenBank#each_cds -> Array

      Iterate only for the 'CDS' portion of the Bio::Features.

--- Bio::GenBank#each_gene -> Array

      Iterate only for the 'gene' portion of the Bio::Features.

=== BASE COUNT

--- Bio::GenBank#basecount(base = nil) -> Hash or Fixnum

      Returns the BASE COUNT as a Hash.  When the base is specified, returns
      count of the base as a Fixnum.  The base can be one of 'a', 't', 'g',
      'c', and 'o' (others).

--- Bio::GenBank#gc -> Float

      Returns the average G+C% content of the sequence as a Float.

=== ORIGIN

--- Bio::GenBank#origin -> String

      Returns contents of the ORIGIN record as a String.

--- Bio::GenBank#naseq -> Bio::Sequence::NA

      Returns DNA sequence in the ORIGIN record as a Bio::Sequence::NA object.

== SEE ALSO

  ftp://ftp.ncbi.nih.gov/genbank/gbrel.txt
  http://www.ncbi.nlm.nih.gov/collab/FT/index.html

=end



