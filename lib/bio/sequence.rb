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
#  $Id: sequence.rb,v 0.7 2001/09/26 18:40:54 katayama Exp $
#

require 'bio/data/na'
require 'bio/data/aa'
require 'bio/data/codontable'
require 'bio/location'

# Nucleic/Amino Acid sequence

class Sequence < String

  include NucleicAcid
  include AminoAcid
  include CodonTable

  def initialize(str)
    str.tr!(" \t\n\r",'')
    super
  end

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

end


# Nucleic Acid sequence

class NAseq < Sequence

  def initialize(str)
    if str
      super.downcase!
      super.tr!('u', 't')
    end
  end

  def [](*arg)
    NAseq.new(super(*arg))
  end

  def splicing(position)	# see Locations class
    mRNA = NAseq.new('')
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
    NAseq.new(str)
  end

  def translate(frame = 1, table = 1)
    ct = codon_table(table)
    frame -= 1
    aaseq = AAseq.new('')
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

  def gc_percent
    count = Hash.new(0)
    self.scan(/./) do |base|
      count[base] += 1
    end
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
    hash = NA_weight unless hash
    total(hash)
  end

  def to_re
    re = ''
    self.each_byte do |x|
      if NA_name[x.chr]
	re << NA_name[x.chr]
      else
	re << '.'
      end
    end
    return /#{re}/
  end

  def to_a
    array = []
    self.each_byte do |x|
      array.push(NA_name[x.chr.upcase])
    end
    return array
  end

  def rna
    super.tr!('t', 'u')
  end

  def pikachu
    self.tr("atgc", "pika")	# joke, of cource :-)
  end

end


# Amino Acid sequence

class AAseq < Sequence

  def initialize(str)
    if str
      super.upcase!
    end
  end

  def [](*arg)
    AAseq.new(super(*arg))
  end

  def to_a(short = nil)
    array = []
    self.each_byte do |x|
      if short
	array.push(AA_name[x.chr])
      else
	array.push(AA_name[AA_name[x.chr]])
      end
    end
    return array
  end

  def molecular_weight(hash = nil)
    hash = AA_weight unless hash
    total(hash)
  end

end

