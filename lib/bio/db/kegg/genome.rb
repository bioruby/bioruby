#
# bio/db/kegg/genome.rb - KEGG/GENOME database class
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: genome.rb,v 0.3 2001/06/25 06:57:53 katayama Exp $
#

require 'bio/db'

class GENOME < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  def entry
    field_fetch('ENTRY')
  end
  alias id entry

  def name
    field_fetch('NAME')
  end

  def definition
    field_fetch('DEFINITION')
  end
  alias organism definition

  def taxid
    field_sub('TAXONOMY')
    return @data['TAXONOMY']['TAXONOMY']
  end

  def lineage
    field_sub('TAXONOMY')
    return @data['TAXONOMY']['LINEAGE']
  end
  alias taxonomy lineage

  def morphology
    field_fetch('MORPHOLOGY')
  end

  def physiology
    field_fetch('PHYSIOLOGY')
  end

  def environment
    field_fetch('ENVIRONMENT')
  end

  def comment
    field_fetch('COMMENT')
  end

  def reference(num = nil, tag = nil)
    field_multi_sub('REFERENCE')

    if block_given?
      @data['REFERENCE'].each do |ref|
	yield(ref)			# Hash of each REFERENCE
      end				#   obj.reference do |r| r['TITLE'] end
    elsif num
      if tag
	@data['REFERENCE'][num-1][tag]	# tag contents of num'th REFERENCE
      else				#   obj.reference(1, 'JOURNAL') -> 1st
	@data['REFERENCE'][num-1]	# Hash of num'th REFERENCE
      end				#   obj.reference(2) -> 2nd REFERENCE
    else
      @data['REFERENCE']		# Array of Hash of REFERENCE (default)
    end					#   obj.reference
  end

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
	@data['CHROMOSOME'][num-1][tag]	# tag contents of num'th CHROMOSOME
      else				#   obj.chromosome(2, 'LENGTH') -> 2nd
	@data['CHROMOSOME'][num-1]	# Hash of num'th CHROMOSOME
      end				#   obj.chromosome(3) -> 3rd CHROMOSOME
    else
      @data['CHROMOSOME']		# Array of Hash of CHROMOSOME (default)
    end					#   obj.chromosome
  end

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
    statistics(0).to_i
  end
  def num_gene
    statistics(1).to_i
  end
  def num_rna
    statistics(2).to_i
  end
  def gc
    statistics(3).to_f
  end

  def genomemap
    field_fetch('GENOMEMAP')
  end

  def genecatalog
    field_fetch('GENECATALOG')
  end

end
