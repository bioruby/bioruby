#
# bio/db/kegg/genome.rb - KEGG/GENOME database class
#
#   Copyright (C) 2001, 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: genome.rb,v 0.14 2005/09/08 01:22:11 k Exp $
#

require 'bio/db'

module Bio

  class KEGG

    class GENOME < KEGGDB

      DELIMITER	= RS = "\n///\n"
      TAGSIZE	= 12

      def initialize(entry)
        super(entry, TAGSIZE)
      end


      # ENTRY
      def entry_id
        field_fetch('ENTRY')
      end
      
      # NAME
      def name
        field_fetch('NAME')
      end

      # DEFINITION
      def definition
        field_fetch('DEFINITION')
      end
      alias organism definition

      # TAXONOMY
      def taxonomy
        unless @data['TAXONOMY']
          taxid, lineage = subtag2array(get('TAXONOMY'))
          taxid   = taxid   ? truncate(tag_cut(taxid))   : ''
          lineage = lineage ? truncate(tag_cut(lineage)) : ''
          @data['TAXONOMY'] = {
            'taxid'	=> taxid,
            'lineage'	=> lineage,
          }
          @data['TAXONOMY'].default = ''
        end
        @data['TAXONOMY']
      end

      def taxid
        taxonomy['taxid']
      end

      def lineage
        taxonomy['lineage']
      end

      # COMMENT
      def comment
        field_fetch('COMMENT')
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
                authors[-1] = authors[-1].split(/\s+and\s+/)
                authors = authors.flatten.map { |a| a.sub(',', ', ') }
                hash['authors']	= authors
              when /TITLE/
                hash['title']	= truncate(tag_cut(field))
              when /JOURNAL/
                journal = truncate(tag_cut(field))
                if journal =~ /(.*) (\d+):(\d+)-(\d+) \((\d+)\) \[UI:(\d+)\]$/
                  hash['journal']	= $1
                  hash['volume']	= $2
                  hash['pages']		= $3
                  hash['year']		= $5
                  hash['medline']	= $6
                else
                  hash['journal'] = journal
                end
              end
            end
            ary.push(Reference.new(hash))
          end
          @data['REFERENCE'] = References.new(ary)
        end
        @data['REFERENCE']
      end

      # CHROMOSOME
      def chromosomes
        unless @data['CHROMOSOME']
          @data['CHROMOSOME'] = []
          toptag2array(get('CHROMOSOME')).each do |chr|
            hash = Hash.new('')
            subtag2array(chr).each do |field|
              hash[tag_get(field)] = truncate(tag_cut(field))
            end
            @data['CHROMOSOME'].push(hash)
          end
        end
        @data['CHROMOSOME']
      end

      # PLASMID
      def plasmids
        unless @data['PLASMID']
          @data['PLASMID'] = []
          toptag2array(get('PLASMID')).each do |chr|
            hash = Hash.new('')
            subtag2array(chr).each do |field|
              hash[tag_get(field)] = truncate(tag_cut(field))
            end
            @data['PLASMID'].push(hash)
          end
        end
        @data['PLASMID']
      end

      # SCAFFOLD
      def scaffolds
        unless @data['SCAFFOLD']
          @data['SCAFFOLD'] = []
          toptag2array(get('SCAFFOLD')).each do |chr|
            hash = Hash.new('')
            subtag2array(chr).each do |field|
              hash[tag_get(field)] = truncate(tag_cut(field))
            end
            @data['SCAFFOLD'].push(hash)
          end
        end
        @data['SCAFFOLD']
      end

      # STATISTICS
      def statistics
        unless @data['STATISTICS']
          hash = Hash.new(0.0)
          get('STATISTICS').each_line do |line|
            case line
            when /nucleotides:\s+(\d+)/
              hash['nalen'] = $1.to_i
            when /protein genes:\s+(\d+)/
              hash['num_gene'] = $1.to_i
            when /RNA genes:\s+(\d+)/
              hash['num_rna'] = $1.to_i
            when /G\+C content:\s+(\d+.\d+)/
              hash['gc'] = $1.to_f
            end
          end
          @data['STATISTICS'] = hash
        end
        @data['STATISTICS']
      end

      def nalen
        statistics['nalen']
      end
      alias length nalen

      def num_gene
        statistics['num_gene']
      end

      def num_rna
        statistics['num_rna']
      end

      def gc
        statistics['gc']
      end

      # GENOMEMAP
      def genomemap
        field_fetch('GENOMEMAP')
      end

    end
    
  end

end



if __FILE__ == $0

  begin
    require 'pp'
    def p(arg); pp(arg); end
  rescue LoadError
  end

  require 'bio/io/flatfile'

  ff = Bio::FlatFile.new(Bio::KEGG::GENOME, ARGF)

  ff.each do |genome|

    puts "### Tags"
    p genome.tags

    [
      %w( ENTRY entry_id ),
      %w( NAME name ),
      %w( DEFINITION definition ),
      %w( TAXONOMY taxonomy taxid lineage ),
      %w( REFERENCE references ),
      %w( CHROMOSOME chromosomes ),
      %w( PLASMID plasmids ),
      %w( SCAFFOLD plasmids ),
      %w( STATISTICS statistics nalen num_gene num_rna gc ),
      %w( GENOMEMAP genomemap ),
    ].each do |x|
      puts "### " + x.shift
      x.each do |m|
        p genome.send(m)
      end
    end

  end

end


=begin

= Bio::KEGG::GENOME

=== Initialize

--- Bio::KEGG::GENOME.new(entry)

=== ENTRY

--- Bio::KEGG::GENOME#entry_id -> String

      Returns contents of the ENTRY record as a String.

=== NAME

--- Bio::KEGG::GENOME#name -> String

      Returns contents of the NAME record as a String.

=== DEFINITION

--- Bio::KEGG::GENOME#definition -> String

      Returns contents of the DEFINITION record as a String.

--- Bio::KEGG::GENOME#organism -> String

      Alias for the 'definition' method.

=== TAXONOMY

--- Bio::KEGG::GENOME#taxonomy -> Hash

      Returns contents of the TAXONOMY record as a Hash.

--- Bio::KEGG::GENOME#taxid -> String

      Returns NCBI taxonomy ID from the TAXONOMY record as a String.

--- Bio::KEGG::GENOME#lineage -> String

      Returns contents of the TAXONOMY/LINEAGE record as a String.

=== COMMENT

--- Bio::KEGG::GENOME#comment -> String

      Returns contents of the COMMENT record as a String.

=== REFERENCE

--- Bio::GenBank#references -> Array

      Returns contents of the REFERENCE records as an Array of Bio::Reference
      objects.

=== CHROMOSOME

--- Bio::KEGG::GENOME#chromosomes -> Array

      Returns contents of the CHROMOSOME records as an Array of Hash.

=== PLASMID

--- Bio::KEGG::GENOME#plasmids -> Array

      Returns contents of the PLASMID records as an Array of Hash.

=== SCAFFOLD

--- Bio::KEGG::GENOME#scaffolds -> Array

      Returns contents of the SCAFFOLD records as an Array of Hash.

=== STATISTICS

--- Bio::KEGG::GENOME#statistics -> Hash

      Returns contents of the STATISTICS record as a Hash.

--- Bio::KEGG::GENOME#nalen -> Fixnum

      Returns number of nucleotides from the STATISTICS record as a Fixnum.

--- Bio::KEGG::GENOME#num_gene -> Fixnum

      Returns number of protein genes from the STATISTICS record as a Fixnum.

--- Bio::KEGG::GENOME#num_rna -> Fixnum

      Returns number of rna from the STATISTICS record as a Fixnum.

--- Bio::KEGG::GENOME#gc -> Float

      Returns G+C content from the STATISTICS record as a Float.

=== GENOMEMAP

--- Bio::KEGG::GENOME#genomemap -> String

      Returns contents of the GENOMEMAP record as a String.

== SEE ALSO

  ftp://ftp.genome.jp/pub/kegg/genomes/genome

=end
