#
# bio/db/genbank/genbank.rb - GenBank database class
#
#   Copyright (C) 2000-2005 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: genbank.rb,v 0.38 2005/12/07 11:23:51 k Exp $
#

require 'bio/db'
require 'bio/db/genbank/common'

module Bio
class GenBank < NCBIDB

  include Bio::NCBIDB::Common

  # LOCUS
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

  def locus
    @data['LOCUS'] ||= Locus.new(get('LOCUS'))
  end
  def entry_id;		locus.entry_id;		end
  def length;		locus.length;		end
  def circular;		locus.circular;		end
  def division;		locus.division;		end
  def date;		locus.date;		end

  def strand;		locus.strand;		end
  def natype;		locus.natype;		end


  # ORIGIN
  def seq
    unless @data['SEQUENCE']
      origin
    end
    Bio::Sequence::NA.new(@data['SEQUENCE'])
  end
  alias naseq seq
  alias nalen length

  def seq_len
    seq.length
  end


  # FEATURES
  def each_cds
    features.each do |feature|
      if feature.feature == 'CDS'
        yield(feature)
      end
    end
  end

  def each_gene
    features.each do |feature|
      if feature.feature == 'gene'
        yield(feature)
      end
    end
  end


  # BASE COUNT : obsoleted after GenBank release 138.0
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

--- Bio::GenBank#accessions -> Array

Returns contents of the ACCESSION record as an Array.

=== VERSION

--- Bio::GenBank#versions -> Array

Returns contents of the VERSION record as an Array of Strings.

--- Bio::GenBank#acc_version -> String
--- Bio::GenBank#accession -> String
--- Bio::GenBank#version -> Fixnum
--- Bio::GenBank#gi -> String

Access methods for the contents of the VERSION record.

The 'acc_version' method returns the first part of the VERSION record
as a "ACCESSION.VERSION" String, 'accession' method returns the ACCESSION
part of the acc_version, 'version' method returns the VERSION part of the
acc_version as a Fixnum, and the 'gi' method returns the second part of
the VERSION record as a "GI:#######" String.

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
--- Bio::GenBank#vernacular_name -> String
--- Bio::GenBank#organism -> String
--- Bio::GenBank#taxonomy -> String

Access methods for the contents of the SOURCE record.

The 'common_name' method is same as source['common_name'].
The 'vernacular_name' method is an alias for the 'common_name'.
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

=== ORIGIN

--- Bio::GenBank#origin -> String

Returns contents of the ORIGIN record as a String.

--- Bio::GenBank#naseq -> Bio::Sequence::NA
--- Bio::GenBank#seq -> Bio::Sequence::NA

Returns DNA sequence in the ORIGIN record as a Bio::Sequence::NA object.

== SEE ALSO

* ((<URL:ftp://ftp.ncbi.nih.gov/genbank/gbrel.txt>))
* ((<URL:http://www.ncbi.nlm.nih.gov/collab/FT/index.html>))

=end



