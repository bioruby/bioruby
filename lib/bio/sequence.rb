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
#  $Id: sequence.rb,v 0.6 2001/08/06 19:26:49 katayama Exp $
#

require 'bio/data/na'
require 'bio/data/aa'
require 'bio/data/codontable'
require 'bio/location'

# Nucleic/Amino Acid sequence

class Sequence < String

  include NucleicAcids
  include AminoAcids
  include CodonTable

  def subseq(s, e)
    s -= 1
    e -= 1
    self[s..e]
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
    mRNA
  end

  def subseq(s = 1, e = self.length)
    NAseq.new(super)
  end

  def complement
    str = self.reverse
    str.tr!('atgc', 'tacg')
    NAseq.new(str)
  end

  def translate(frame = 1, table = 1)
    frame -= 1
    aaseq = AAseq.new('')
    frame.step(self.length - 3, 3) do |i|
      codon = self[i,3]
      if ct(codon, table)
	aaseq << ct(codon, table)
      else
	aaseq << "X"
      end
    end
    aaseq
  end

  def gc_percent
    count = Hash.new(0)
    self.scan(/./) do |b|
      count[b] += 1
    end
    at = count['a'] + count['t']
    gc = count['g'] + count['c']
    gc = format("%.1f", gc.to_f / (at + gc) * 100)
    gc.to_f
  end
  alias gc gc_percent

  def illegal_bases
    self.scan(/[^atgc]/).sort.uniq
  end
  alias ib illegal_bases

  def to_re
    re = ''
    self.each_byte do |x|
      if na(x.chr)
	re << na(x.chr)
      else
	re << '.'
      end
    end
    /#{re}/
  end

  def to_list
    array = []
    self.each_byte do |x|
      array.push(na(x.chr.upcase))
    end
    array
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

  def subseq(s = 1, e = self.length)
    AAseq.new(super)
  end

  def to_3
    array = []
    self.each_byte do |x|
      array.push(aa(x.chr))
    end
    array
  end

  def to_list
    to_3.collect do |a|
      a = aa(a)
    end
  end

end

