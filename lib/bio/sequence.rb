#
# bio/sequence.rb - biological sequence class
#
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: sequence.rb,v 0.10 2001/11/02 10:35:51 katayama Exp $
#

=begin

= Bio::Sequence

--- Bio::Sequence#subseq(start = 1, end = length)
--- Bio::Sequence#window_search(window_size)
--- Bio::Sequence#total(hash)

= Bio::Sequence::NA

--- Bio::Sequence::NA#new(str)

--- Bio::Sequence::NA#splicing(position)
--- Bio::Sequence::NA#complement
--- Bio::Sequence::NA#codon_table(table = 1, codon = nil)
--- Bio::Sequence::NA#translate(frame = 1, table = 1)
--- Bio::Sequence::NA#base_composition
--- Bio::Sequence::NA#gc_percent
--- Bio::Sequence::NA#illegal_bases
--- Bio::Sequence::NA#molecular_weight(hash)
--- Bio::Sequence::NA#to_re
--- Bio::Sequence::NA#to_a
--- Bio::Sequence::NA#rna
--- Bio::Sequence::NA#pikachu

= Bio::Sequence::AA

--- Bio::Sequence::AA#new(str)

--- Bio::Sequence::AA#to_a(short)
--- Bio::Sequence::AA#molecular_weight(hash)

=end


module Bio

require 'bio/data/na'
require 'bio/data/aa'
require 'bio/data/codontable'
require 'bio/location'

# Nucleic/Amino Acid sequence

class Sequence < String

  def subseq(s = 1, e = self.length)
    s -= 1
    e -= 1
    self[s..e]
  end

  def window_search(window_size)
    0.upto(self.length - window_size) do |i|
      yield self[i, window_size]
    end
  end

  def total(hash)
    sum = 0.0
    self.each_byte do |x|
      begin
	sum += hash[x.chr]
      rescue
	raise "[Error] illegal character : #{x.chr}"
      end
    end
    return sum
  end

  def to_fasta(header = '', width = nil)
    ">#{header}\n" +
      if width
        self.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
      else
        self + "\n"
      end
  end


  # Nucleic Acid sequence

  class NA < Sequence

    def initialize(str)
      if str
	str.downcase!
	str.tr!('u', 't')
	str.tr!(" \t\n\r",'')
	super
      end
    end

    def [](*arg)
      a = super(*arg)
      a.is_a?(String) ? NA.new(a) : a
    end

    # bio/location.rb
    def splicing(position)	# see Locations class
      mRNA = NA.new('')
      Locations.new(position).each do |location|
	if location.sequence
	  mRNA << location.sequence
	else
	  exon = subseq(location.from,location.to)
	  exon = exon.complement if location.strand < 0
	  mRNA << exon
	end
      end
      return mRNA
    end

    def complement
      str = self.reverse
      str.tr!('atgc', 'tacg')
      NA.new(str)
    end

    # bio/data/codontable.rb
    def codon_table(table = 1, codon = nil)
      if codon
	CodonTable[table][codon]
      else
	CodonTable[table]
      end
    end

    def translate(frame = 1, table = 1)
      ct = codon_table(table)
      frame -= 1
      aaseq = AA.new('')
      frame.step(self.length - 3, 3) do |i|
	codon = self[i,3]
	if ct[codon]
	  aaseq << ct[codon]
	else
	  aaseq << "X"
	end
      end
      return aaseq
    end

    def base_composition
      count = Hash.new(0)
      self.scan(/./) do |base|
	count[base] += 1
      end
      return count
    end

    def gc_percent
      count = base_composition
      at = count['a'] + count['t']
      gc = count['g'] + count['c']
      gc = format("%.1f", gc.to_f / (at + gc) * 100)
      return gc.to_f
    end
    alias gc gc_percent

    def illegal_bases
      self.scan(/[^atgc]/).sort.uniq
    end

    def molecular_weight(hash = nil)
      hash = NucleicAcid_weight unless hash
      total(hash)
    end

    def to_re
      re = ''
      self.each_byte do |x|
	if NucleicAcid[x.chr]
	  re << NucleicAcid[x.chr]
	else
	  re << '.'
	end
      end
      return /#{re}/
    end

    def to_a
      array = []
      self.each_byte do |x|
	array.push(NucleicAcid[x.chr.upcase])
      end
      return array
    end

    def rna
      self.tr('t', 'u')
    end

    def pikachu
      self.tr("atgc", "pika")	# joke, of cource :-)
    end

  end


  # Amino Acid sequence

  class AA < Sequence

    def initialize(str)
      if str
	str.upcase!
	str.tr!(" \t\n\r",'')
	super
      end
    end

    def [](*arg)
      a = super(*arg)
      a.is_a?(String) ? AA.new(a) : a
    end

    def to_a(short = nil)
      array = []
      self.each_byte do |x|
	if short
	  array.push(AminoAcid[x.chr])
	else
	  array.push(AminoAcid[AminoAcid[x.chr]])
	end
      end
      return array
    end

    def molecular_weight(hash = nil)
      hash = AminoAcid_weight unless hash
      total(hash)
    end

  end

end

end				# module Bio

