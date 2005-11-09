#
# bio/db/kegg/genes.rb - KEGG/GENES database class
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
#  $Id: genes.rb,v 0.22 2005/11/09 12:30:07 k Exp $
#

require 'bio/db'

module Bio

  class KEGG

    class GENES < KEGGDB

      DELIMITER	= RS = "\n///\n"
      TAGSIZE	= 12

      def initialize(entry)
        super(entry, TAGSIZE)
      end


      def entry
        unless @data['ENTRY']
          hash = Hash.new('')
          if get('ENTRY').length > 30
            e = get('ENTRY')
            hash['id']       = e[12..29].strip
            hash['division'] = e[30..39].strip
            hash['organism'] = e[40..80].strip
          end
          @data['ENTRY'] = hash
        end
        @data['ENTRY']
      end

      def entry_id
        entry['id']
      end

      def division
        entry['division']			# CDS, tRNA etc.
      end

      def organism
        entry['organism']			# H.sapiens etc.
      end

      def name
        field_fetch('NAME')
      end

      def genes
        name.split(', ')
      end

      def gene
        genes.first
      end

      def definition
        field_fetch('DEFINITION')
      end

      def eclinks
#       definition.slice(/\[EC:(.*?)\]/, 1)	# ruby >= 1.7
#       definition.scan(/\[EC:(.*?)\]/).flatten
        if /\[EC:(.*?)\]/.match(definition)
          $1.split(/\s+/)
        else
          []
        end
      end

      def splinks
#       definition.slice(/\[SP:(.*?)\]/, 1)	# ruby >= 1.7
#       definition.scan(/\[SP:(.*?)\]/).flatten
        if /\[SP:(.*?)\]/.match(definition)
          $1.split(/\s+/)
        else
          []
        end
      end

      def keggclass
        field_fetch('CLASS')
      end

      def pathways
        keggclass.scan(/\[PATH:(.*?)\]/).flatten
      end

      def position
        unless @data['POSITION']
          @data['POSITION'] = fetch('POSITION').gsub(/\s/, '')
        end
        @data['POSITION']
      end

      def gbposition
        position.sub(/.*?:/, '')
      end

      def chromosome
        if position =~ /:/
          position.sub(/:.*/, '')
        else
          nil
        end
      end

      def dblinks
        unless @data['DBLINKS']
          hash = {}
          get('DBLINKS').scan(/(\S+):\s*(.*)\n?/).each do |db, str|
            id_array = str.strip.split(/\s+/)
            hash[db] = id_array
          end
          @data['DBLINKS'] = hash
        end
        @data['DBLINKS']		# Hash of Array of DB IDs in DBLINKS
      end

      def codon_usage(codon = nil)
        unless @data['CODON_USAGE']
          ary = []
          get('CODON_USAGE').sub(/.*/,'').each_line do |line|	# cut 1st line
            line.chomp.sub(/^.{11}/, '').scan(/..../) do |cu|
              ary.push(cu.to_i)
            end
          end
          @data['CODON_USAGE'] = ary
        end

        if codon
          h = { 't' => 0, 'c' => 1, 'a' => 2, 'g' => 3 }
          x, y, z = codon.downcase.scan(/\w/)
          codon_num = h[x] * 16 + h[y] * 4 + h[z]
          @data['CODON_USAGE'][codon_num]	# CODON_USAGE of the codon
        else
          return @data['CODON_USAGE']	# Array of CODON_USAGE (default)
        end
      end

      def cu
        hash = Hash.new
        list = codon_usage
        base = %w(t c a g)
        base.each_with_index do |x, i|
          base.each_with_index do |y, j|
            base.each_with_index do |z, k|
              hash["#{x}#{y}#{z}"] = list[i*16 + j*4 + k]
            end
          end
        end
        return hash
      end

      def aaseq
        unless @data['AASEQ']
          @data['AASEQ'] = Sequence::AA.new(fetch('AASEQ').gsub(/[\s\d\/]+/, ''))
        end
        @data['AASEQ']
      end

      def aalen
        @data['AALEN'] = aaseq.length
      end

      def ntseq
        unless @data['NTSEQ']
          @data['NTSEQ'] = Sequence::NA.new(fetch('NTSEQ').gsub(/[\s\d\/]+/, ''))
        end
        @data['NTSEQ']
      end
      alias naseq ntseq

      def ntlen
        @data['NTLEN'] = ntseq.length
      end
      alias nalen ntlen

    end

  end

end



if __FILE__ == $0

  require 'bio/io/fetch'

  e = Bio::Fetch.query('genes', 'b0002')
  g = Bio::KEGG::GENES.new(e)

  p g.entry
  p g.entry_id
  p g.division
  p g.name
  p g.gene
  p g.definition
  p g.keggclass
  p g.position
  p g.dblinks
  p g.codon_usage
  p g.cu
  p g.aaseq
  p g.aalen
  p g.naseq
  p g.nalen
  p g.eclinks
  p g.splinks
  p g.pathways

end


=begin

= Bio::KEGG::GENES

=== Initialize

--- Bio::KEGG::GENES.new

=== ENTRY

--- Bio::KEGG::GENES#entry -> Hash
--- Bio::KEGG::GENES#entry_id -> String
--- Bio::KEGG::GENES#division -> String
--- Bio::KEGG::GENES#organism -> String

=== NAME

--- Bio::KEGG::GENES#name -> String
--- Bio::KEGG::GENES#genes -> Array
--- Bio::KEGG::GENES#gene -> String

=== DEFINITION

--- Bio::KEGG::GENES#definition -> String
--- Bio::KEGG::GENES#eclinks -> Array
--- Bio::KEGG::GENES#splinks -> Array

=== CLASS

--- Bio::KEGG::GENES#keggclass -> String
--- Bio::KEGG::GENES#pathways -> Array

=== POSITION

--- Bio::KEGG::GENES#position -> String

=== DBLINKS

--- Bio::KEGG::GENES#dblinks -> Hash

=== CODON_USAGE

--- Bio::KEGG::GENES#codon_usage(codon = nil) -> Array or Fixnum
--- Bio::KEGG::GENES#cu -> Hash

=== AASEQ

--- Bio::KEGG::GENES#aaseq -> Bio::Sequence::AA
--- Bio::KEGG::GENES#aalen -> Fixnum

=== NTSEQ

--- Bio::KEGG::GENES#ntseq -> Bio::Sequence::NA
--- Bio::KEGG::GENES#naseq -> Bio::Sequence::NA
--- Bio::KEGG::GENES#ntlen -> Fixnum
--- Bio::KEGG::GENES#nalen -> Fixnum

=end
