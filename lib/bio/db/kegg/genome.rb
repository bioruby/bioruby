#
# bio/db/kegg/genome.rb - KEGG/GENOME database class
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
#  $Id: genome.rb,v 0.7 2001/11/08 06:10:34 nakao Exp $
#


module Bio

  require 'bio/db'

  class KEGG

    class GENOME < KEGGDB

      DELIMITER	= RS = "\n///\n"
      TAGSIZE	= 12

      ##
      #
      def initialize(entry)
	super(entry, TAGSIZE)
      end

      ##
      # ENTRY (1 per entry)
      #
      def entry
	field_fetch('ENTRY')
      end
      alias id entry # It should eliminate, conflicting Object#id (n)
      
      ##
      # NAME (1 per entry)
      #
      def name
	field_fetch('NAME')
      end

      ##
      # DEFINITION (1 per entry)
      #
      def definition
	field_fetch('DEFINITION')
      end
      alias organism definition

      ##
      # TAXONOMY(1 per entry)
      def taxid
	field_sub('TAXONOMY')
	return @data['TAXONOMY']['TAXONOMY']
      end
      
      ##
      # TAXONOMY/LINEAGE (1 per entry)
      def lineage
	field_sub('TAXONOMY')
	return @data['TAXONOMY']['LINEAGE']
      end
      alias taxonomy lineage

      ##
      # MORPHOLOGY (1 per entry)
      def morphology
	field_fetch('MORPHOLOGY')
      end
      
      ##
      # PHYSIOLOGY (0 or 1 per entry)
      def physiology
	field_fetch('PHYSIOLOGY')
      end
      
      ##
      # ENVIRONMENT (0 or 1 per entry)
      def environment
	field_fetch('ENVIRONMENT')
      end

      ##
      # COMMENT (0 or 1 per entry)
      #
      def comment
	field_fetch('COMMENT')
      end
      
      ##
      # REFERENCE (1 per entry)
      # REFERENCE/AUTHOR (>=1 per entry)
      #
      def reference(num = nil, tag = nil)
	field_multi_sub('REFERENCE')

	if block_given?
	  @data['REFERENCE'].each do |ref|
	    yield(ref)			# Hash of each REFERENCE
	  end				#   obj.reference do |r| r['TITLE'] end
	elsif num
	  if tag
	    @data['REFERENCE'][num-1][tag]# tag contents of num'th REFERENCE
	  else				#   obj.reference(1, 'JOURNAL') -> 1st
	    @data['REFERENCE'][num-1]	# Hash of num'th REFERENCE
	  end				#   obj.reference(2) -> 2nd REFERENCE
	else
	  @data['REFERENCE']		# Array of Hash of REFERENCE (default)
	end				#   obj.reference
      end

      ##
      # CHROMOSOME (>=1 pre entry)
      #
      def chromosome(num = nil, tag = nil)
	unless @data['CHROMOSOME']
	  field_multi_sub('CHROMOSOME')
	  @data['CHROMOSOME'] += field_multi_sub('MITOCHON')
	  @data['CHROMOSOME'] += field_multi_sub('PLASMID')
	end

	if block_given?
	  @data['CHROMOSOME'].each do |chr|
	    yield(chr)			# Hash of each CHROMOSOME
	  end				#   obj.chromosome do |c| p c end
	elsif num
	  if tag
	    @data['CHROMOSOME'][num-1][tag]# tag contents of num'th CHROMOSOME
	  else				#   obj.chromosome(2, 'LENGTH') -> 2nd
	    @data['CHROMOSOME'][num-1]	# Hash of num'th CHROMOSOME
	  end				#   obj.chromosome(3) -> 3rd CHROMOSOME
	else
	  @data['CHROMOSOME']		# Array of Hash of CHROMOSOME (default)
	end				#   obj.chromosome
      end

      ##
      # STATISTICS (0 or 1 per entry)
      #
      def statistics(num = nil)
	unless @data['STATISTICS']
	  # Array of num of nucleotides, num of protein genes, num of RNAs, GC%
	  @data['STATISTICS'] = fetch('STATISTICS').scan(/[\d\.]+/)
	end

	if num
	  @data['STATISTICS'][num]
	else
	  @data['STATISTICS']
	end
      end
      def nalen
	if statistics(0)
	  statistics(0).to_i 
	else
	  nil
	end
      end
      def num_gene
	if statistics(1)
	  statistics(1).to_i
	else
	  nil
	end
      end
      def num_rna
	if statistics(2)
	  statistics(2).to_i
	else
	  nil
	end
      end
      def gc
	if statistics(3)
	  statistics(3).to_f
	else
	  nil
	end
      end

      ##
      # GENOMEMAP (1 per entry)
      #
      def genomemap
	field_fetch('GENOMEMAP')
      end

      ##
      # GENECATALOG (1 per entry)
      #
      def genecatalog
	field_fetch('GENECATALOG')
      end
      
    end
    
  end				# class KEGG

end				# module Bio

# Tasting codes
if __FILE__ == $0
end



=begin

The BioRuby Project

= Bio::DB::KEGG::GENOME

--- Bio::DB::KEGG::GENOME#new(entry)

--- Bio::DB::KEGG::GENOME#entry
--- Bio::DB::KEGG::GENOME#name
--- Bio::DB::KEGG::GENOME#definition
--- Bio::DB::KEGG::GENOME#organism
--- Bio::DB::KEGG::GENOME#taxid
--- Bio::DB::KEGG::GENOME#lineage
--- Bio::DB::KEGG::GENOME#taxonomy
--- Bio::DB::KEGG::GENOME#morphology
--- Bio::DB::KEGG::GENOME#physiology
--- Bio::DB::KEGG::GENOME#environment
--- Bio::DB::KEGG::GENOME#comment
--- Bio::DB::KEGG::GENOME#chromosome(num = nil, tag = nil)
--- Bio::DB::KEGG::GENOME#statistics(num = nil)
--- Bio::DB::KEGG::GENOME#nalen
--- Bio::DB::KEGG::GENOME#num_gene
--- Bio::DB::KEGG::GENOME#num_rna
--- Bio::DB::KEGG::GENOME#gc
--- Bio::DB::KEGG::GENOME#genomemap
--- Bio::DB::KEGG::GENOME#genecatalog



= See also.
  ftp://ftp.genome.ad.jp/pub/kegg/genomes/genome


=end
