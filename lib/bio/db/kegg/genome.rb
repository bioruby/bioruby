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
#  $Id: genome.rb,v 0.8 2001/11/08 16:47:30 nakao Exp $
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
      def entry
	field_fetch('ENTRY')
      end
      alias id entry # It should eliminate, conflicting Object#id (n)
      
      ##
      # NAME (1 per entry)
      def name
	field_fetch('NAME')
      end

      ##
      # DEFINITION (1 per entry)
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
      # CHROMOSOME 
      #   SEQUENCE
      #   LEGNTH
      #
      def chromosome(num = nil, tag = nil)
	unless @data['CHROMOSOME']
	  field_multi_sub('CHROMOSOME')
	  @data['CHROMOSOME'] += field_multi_sub('MITOCHON')
	  @data['CHROMOSOME'] += field_multi_sub('PLASMID')
	end
  
	if block_given?
	  @data['CHROMOSOME'].each do |chr|
	    yield(chr)			    # Hash of each CHROMOSOME
	  end				    #   obj.chromosome do |c| p c end
	elsif num
	  if tag  # ::= (LENGTH|SEQUENCE)
	    @data['CHROMOSOME'][num-1][tag] # tag contents of num'th CHROMOSOME
	  else				#   obj.chromosome(2, 'LENGTH') -> 2nd
	    @data['CHROMOSOME'][num-1]	# Hash of num'th CHROMOSOME
	  end				#   obj.chromosome(3) -> 3rd CHROMOSOME
	else
	  @data['CHROMOSOME']		# Array of Hash of CHROMOSOME (default)
	end				#   obj.chromosome
      end


      ##
      # CHROMOSOME (>=1 pre entry)
      # MITOCHON (>=0 per entry)
      # PLASMID (>=0 per entry)
      #
      # * Backward compativility
      #   old GENOME#chromosome
      #    == GENOME#chromosome + GENOME#plasmid + GENOME#mitochon
      #   old GENOME#chromosome(num)
      #    == GENOME#chromosome(num)
      #   old GENOME#chromosome(tag)
      #    == GENOME#chromosome(tag)
      #   old GENOME#chromosome {}
      #    == (GENOME#chromosome + GENOME#plasmid + GENOME#mitochon).each {}
      # 
      def chromosomes(type = nil, num = nil, tag = nil)
	unless @data['CHROMOSOMES']
	  @data['CHROMOSOMES'] = Hash.new
	  @data['CHROMOSOMES']['CHROMOSOME'] = field_multi_sub('CHROMOSOME')
	  @data['CHROMOSOMES']['MITOCHON'] = field_multi_sub('MITOCHON')
	  @data['CHROMOSOMES']['PLASMID'] = field_multi_sub('PLASMID')
	end
	if block_given?
	  @data['CHROMOSOMES'].each do |type,chr|
	    yield(type,chr)		    # Type=>Hash of each CHROMOSOME
	  end
	elsif num and type
	  if tag  # ::= (LENGTH|SEQUENCE|#{type})
	    @data['CHROMOSOMES'][type][num-1][tag] # tag contents of 
	                                           # num'th CHROMOSOME
	  else
	    @data['CHROMOSOMES'][type][num-1]	# Hash of num'th CHROMOSOMES
	  end
	elsif type
	  @data['CHROMOSOMES'][type]    # Array of Hash 
	else
	  @data['CHROMOSOMES']          # Array of Hash of CHROMOSOMES(default)
	end				
      end
      protected :chromosomes
      
      ##
      # CHROMOSOME (>=1 pre entry)
      #   SEQUENCE
      #   LEGNTH
      #
      def chromosome(num = nil, tag = nil)
	if block_given?
	  chromnosomes('CHROMOSOME').each do |chr|
	    yield(chr)		         # Hash of each CHROMOSOME
	  end
	elsif num
	  if tag # ::= (LENGTH|SEQUENCE|CHROMOSOME)
	    chromosomes('CHROMOSOME', num, tag)
	  else
	    chromosomes('CHROMOSOME', num)
	  end
	else
	  #[{'LENGTH'=>str, 'SEQUENCE'=>str, 'CHROMOSOME'=>str}]
	  chromosomes('CHROMOSOME') 
	end
      end

      ##
      # PLASMID (>=0 per entry)
      #   SEQUENCE
      #   LEGNTH
      # 
      def plasmid(num = nil, tag = nil)
	if block_given?
	  chromnosomes('PLASMID').each do |chr|
	    yield(chr)		         # Hash of each PLASMID
	  end
	pppelsif num
	  if tag # ::= (LENGTH|SEQUENCE|PLASMID)
	    chromosomes('PLASMID', num, tag)
	  else
	    chromosomes('PLASMID', num)
	  end
	else
	  #[{'LENGTH'=>str, 'SEQUENCE'=>str, 'PLASMID'=>str}]
	  chromosomes('PLASMID')
	end
      end

      ##
      # MITOCHON (>=0 per entry)
      #   SEQUENCE
      #   LEGNTH
      #
      def mitochon(num = nil, tag = nil)
	if block_given?
	  chromnosomes('MITOCHON').each do |chr|
	    yield(chr)		         # Hash of each MITOCHON
	  end
	elsif num
	  if tag # ::= (LENGTH|SEQUENCE|MITOCHON)
	    chromosomes('MITOCHON', num, tag)
	  else
	    chromosomes('MITOCHON', num)
	  end
	else
	  #[{'LENGTH'=>str, 'SEQUENCE'=>str, 'MITOCHON'=>str}]
	  chromosomes('MITOCHON')
	end
      end
      alias mitochondorion mitochon


      ##
      # STATISTICS (0 or 1 per entry)
      # STATISTICS  Number of nucleotides:             N
      #     Number of protein genes:           N
      #     Number of RNA genes:               N
      #     G+C content:                    NN.N%
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
      alias length nalen
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
      def genomemap
	field_fetch('GENOMEMAP')
      end

      ##
      # GENECATALOG (1 per entry)
      def genecatalog
	field_fetch('GENECATALOG')
      end
      
    end
    
  end				# class KEGG

end				# module Bio



# Tasting codes
if __FILE__ == $0

  genomes = 'genome'
  

  def puts_eval(code)
    if code =~ /^(p\w*) (.+)$/
      opt = $1
      script = $2
      case opt
      when 'p'
	print "\n  == p #{script}\n   #==> "
	p eval script
 
     when 'puts'
	print "\n  == p #{script}\n   #==> \n"
	puts eval script
      end
    end
  end

  begin 
    fio = File.open(genomes)
  rescue
    raise "
Error: No such file: 'genome' in the current directory.


Pseudo-test code for bio/db/kegg/genome.rb

Usage:
 $  cd /some/where/genome
 $ ruby /some/where/bio/db/kegg/genome/rb

File:
 genome  - KEGG/GENOME database flatfile 
           (ftp://ftp.genome.ad.jp/pub/kegg/genomes/genome)

"
  end

  while entry = fio.gets(Bio::KEGG::GENOME::DELIMITER)

    puts "\n\n== start entry =="
    $genome = nil
    $genome = Bio::KEGG::GENOME.new(entry)

    test_codes = [
      "puts $genome.get('ENTRY')",
      'p $genome.entry',
      "puts $genome.get('NAME')",
      'p $genome.name',
      "puts $genome.get('DEFINITION')",
      'p $genome.definition',
      "puts $genome.get('TAXONOMY')",
      'p $genome.taxid',
      'p $genome.lineage',

      "puts $genome.get('PHYSIOLOGY')",
      'p $genome.physiology',
      "puts $genome.get('MORPHOLOGY')",
      'p $genome.morphology',
      "puts $genome.get('ENVIRONMENT')",
      'p $genome.environment',
      
      "puts $genome.get('REFERENCE')",
      'p $genome.reference',

      "puts $genome.get('CHROMOSOME')",
#      'p $genome.chromosomes',
      'p $genome.chromosome',
      "puts $genome.get('PLASMID')",
      'p $genome.plasmid',
      "puts $genome.get('MITOCHON')",
      'p $genome.mitochon',

      "puts $genome.get('STATISTICS')",
      'p $genome.statistics',
      'p $genome.nalen',
      'p $genome.num_gene',
      'p $genome.num_rna',
      'p $genome.gc',
      
      "puts $genome.get('GENOMEMAP')",
      'p $genome.genomemap',
      "puts $genome.get('GENECATALOG')",
      'p $genome.genecatalog'


    ]

    test_codes.each do |code|
      puts_eval(code)
    end

    puts "\n== end entry ==\n"
  end

  fio.close


  puts "\n==  ==\n"
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
--- Bio::DB::KEGG::GENOME#plasmid(num = nil, tag = nil)
--- Bio::DB::KEGG::GENOME#mitochon(num = nil, tag = nil)


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
