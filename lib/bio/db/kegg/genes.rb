#
# bio/db/kegg/genes.rb - KEGG/GENES database class
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: genes.rb,v 0.11 2001/12/15 02:48:31 katayama Exp $
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
	  hash = {}
	  if @orig['ENTRY'].length > 30
	    hash['id']       = @orig['ENTRY'][12..29].strip
	    hash['division'] = @orig['ENTRY'][30..39].strip
	    hash['organism'] = @orig['ENTRY'][40..80].strip
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

      def gene
	name.split(', ')
      end

      def definition
	field_fetch('DEFINITION')
      end

      def keggclass
	field_fetch('CLASS')
      end

      def position
	unless @data['POSITION']
	  @data['POSITION'] = field_fetch('POSITION').gsub(/\s/, '')
	end
	@data['POSITION']
      end

      def dblinks
	unless @data['DBLINKS']
	  hash = {}
	  @orig['DBLINKS'].scan(/(\S+):\s*(\S+)\n/).each do |k, v|
	    hash[k] = v
	  end
	  @data['DBLINKS'] = hash
	end
	@data['DBLINKS']		# Hash of DB:ID in DBLINKS
      end

      def codon_usage(codon = nil)
	unless @data['CODON_USAGE']
	  ary = []
	  @orig['CODON_USAGE'].sub(/.*/,'').each_line do |line|	# cut 1st line
	    line.scan(/\d+/).each do |cu|
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

      def aaseq
	unless @data['AASEQ']
	  @data['AASEQ'] = Sequence::AA.new(field_fetch('AASEQ').gsub(/[\s\d\/]+/, ''))
	end
	@data['AASEQ']
      end

      def aalen
	@data['AALEN'] = aaseq.length
      end

      def ntseq
	unless @data['NTSEQ']
	  @data['NTSEQ'] = Sequence::NA.new(field_fetch('NTSEQ').gsub(/[\s\d\/]+/, ''))
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
  require 'bio/io/dbget'

  e = Bio::DBGET.bget('eco b0010')
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
  p g.aaseq
  p g.aalen
  p g.naseq
  p g.nalen
end


=begin

= Bio::KEGG::GENES

--- Bio::KEGG::GENES.new
--- Bio::KEGG::GENES#entry
--- Bio::KEGG::GENES#entry_id
--- Bio::KEGG::GENES#division
--- Bio::KEGG::GENES#name
--- Bio::KEGG::GENES#gene
--- Bio::KEGG::GENES#definition
--- Bio::KEGG::GENES#keggclass
--- Bio::KEGG::GENES#position
--- Bio::KEGG::GENES#dblinks
--- Bio::KEGG::GENES#codon_usage
--- Bio::KEGG::GENES#aaseq
--- Bio::KEGG::GENES#aalen
--- Bio::KEGG::GENES#ntseq
--- Bio::KEGG::GENES#ntlen
--- Bio::KEGG::GENES#naseq
--- Bio::KEGG::GENES#nalen

=end
