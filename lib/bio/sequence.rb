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

require 'bio/data/na'
require 'bio/data/aa'
require 'bio/data/codontable'

# Nucleic/Amino Acid sequence

class Sequence < String
  include NucleicAcids
  include AminoAcids
  include CodonTable

  def subseq(s, e)
    s -= 1;	s = 1 if s < 0
    e -= 1;	s = e if s > e
    self[s..e]
  end

  def count(char)
    num = 0
    self.each_byte do |x|
      num += 1 if x == char
    end
    num
  end

end


# Nucleic Acid sequence

class NAseq < Sequence

  def initialize(str)
    if str
      super.downcase!
      super.tr!('u', 't')
    else
      ""
    end
  end

  def subseq(s = 1, e = self.length)
    NAseq.new(super)
  end

  def count(base)
    super(base.downcase[0])
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
	re << 'X'
      end
    end
    /#{re}/
  end

  def to_list_long
    array = []
    self.each_byte do |x|
      array.push(na(x.chr.upcase))
    end
    array
  end
  alias to_list to_list_long

  def pikachu
    self.tr("atgc", "pika")	# joke, of cource :-)
  end

end


# Amino Acid sequence

class AAseq < Sequence

  def initialize(str)
    if str
      super.upcase!
    else
      ""
    end
  end

  def subseq(s = 1, e = self.length)
    AAseq.new(super)
  end

  def count(amino)
    super(amino.upcase[0])
  end

  def to_list
    array = []
    self.each_byte do |x|
      array.push(aa(x.chr))
    end
    array
  end

  def to_list_long
    array = to_list
    array.collect do |a|
      a = aa(a)
    end
  end

end

