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
#  $Id: genes.rb,v 0.10 2001/11/06 16:58:52 okuji Exp $
#

module Bio

require 'bio/db'

class KEGG

class GENES < KEGGDB

  DELIMITER	= RS = "\n///\n"
  TAGSIZE	= 12

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  def entry(key = nil)
    unless @data['ENTRY']
      hash = {}
      if @orig['ENTRY'].length > 30
	hash['id']       = @orig['ENTRY'][12..29].strip
	hash['division'] = @orig['ENTRY'][30..39].strip
	hash['organism'] = @orig['ENTRY'][40..80].strip
      end
      @data['ENTRY'] = hash
    end

    if block_given?
      @data['ENTRY'].each do |k, v|
        yield(k, v)			# each contents of ENTRY
      end
    elsif key
      @data['ENTRY'][key]		# contents of key's ENTRY
    else
      @data['ENTRY']			# Hash of ENTRY
    end
  end
  def id
    entry('id')				# ENTRY ID
  end
  def division
    entry('division')			# CDS, tRNA etc.
  end
  def organism
    entry('organism')			# H.sapiens etc.
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

  def dblinks(db = nil)
    unless @data['DBLINKS']
      hash = {}
      @orig['DBLINKS'].scan(/(\S+):\s*(\S+)\n/).each do |k, v|
	hash[k] = v
      end
      @data['DBLINKS'] = hash
    end

    if block_given?
      @data['DBLINKS'].each do |k, v|
        yield(k, v)			# each DB:ID pair in DBLINKS
      end
    elsif db
      @data['DBLINKS'][db]		# ID of the DB
    else
      @data['DBLINKS']			# Hash of DB:ID in DBLINKS (default)
    end
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

    if block_given?
      @data['CODON_USAGE'].each do |cu|
        yield(cu)			# each CODON_USAGE
      end
    elsif codon
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

end				# class KEGG

end				# module Bio

