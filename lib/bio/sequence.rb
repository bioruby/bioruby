#
# bio/sequence.rb - biological sequence class
#
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: sequence.rb,v 0.13 2001/11/15 14:28:38 nakao Exp $
#

require 'bio/data/na'
require 'bio/data/aa'
require 'bio/data/codontable'
require 'bio/location'
#require 'mt'

module Bio

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

    # Sequence Randomize method
    #
    # Bio::Sequence#random -> str
    # Bio::Sequence#random {|i| }
    def random(_count = nil)
      if _count
	count = _count.clone     # .clone trap (--;
      else
	count = self.counts
      end

      length = 0
      labels = count.keys
      labels.each do |l| # sum of lc
	length += count[l]
      end
      tmp = Hash.new
#      r = Math::RNG::MT19937.new(4637)
      if block_given?
	length.times do 
	  labels.each do |l|
	    tmp[l] = count[l]  * rand           # N * [0..1)
#	    tmp[l] = count[l]  * r.rando        # N * [0..1)
	  end
	  lmax = tmp.sort{|a,b| a[1] <=> b[1]}  # comparison
	  count[lmax.last[0]] -= 1

	  yield lmax.last[0]
	end
      else
	
	rseq = ''
	length.times do 
	  labels.each do |l|
	    tmp[l] = count[l]  * rand           # N * [0..1)
#	    tmp[l] = count[l]  * r.rando        # N * [0..1)
	  end
	  lmax = tmp.sort{|a,b| a[1] <=> b[1]}  # comparison
	  count[lmax.last[0]] -= 1

	  rseq += lmax.last[0]
	end
	return rseq
      end
    end

    # randomize, class method version
    def Sequence.random(count, labels = nil)
      # labels check
      if labels        
	count.keys.each do |c|
	  unless labels.index(c)
	    raise "\nInvalid counts, #{count.inspect} \n #{labels.inspect}"
	  end
	end
      end
      # little /ad hoc/ solution (--;
      # Sequence#new(str = nil) ?
      if block_given?
	Sequence.new('').random(count) do |i|
	  yield i
	end
      else
	return  Sequence.new('').random(count)
      end
    end


    # Nucleic Acid sequence

    class NA < Sequence

      def initialize(str)
	super
	self.downcase!
	self.tr!('u', 't')
	self.tr!(" \t\n\r",'')
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

      # Counts bases 
      def base_composition
	count = Hash.new(0)
	self.scan(/./) do |base|
	  count[base] += 1
	end
	return count
      end
      alias counts base_composition

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

      def randomize
	if block_given?
	  Sequence.random(self.counts, NucleicAcid.keys) do |i|
	    yield i
	  end
	else
	  return NA.new( Sequence.random(self.counts, NucleicAcid.keys) )
	end
      end

      # class method version of Sequence::NA#randomize
      # count is Hash like {'a'=>2345, 'c'=>2321, 'g'=>1234, 't'=>1234} format
      def NA.randomize(count)
	if block_given?
	  Sequence.random(count, NucleicAcid.keys) do |i|
	    yield i
	  end
	else
	  return NA.new( Sequence.random(count, NucleicAcid.keys) )
	end

      end
    end


    # Amino Acid sequence

    class AA < Sequence

      def initialize(str)
	super
	self.upcase!
	self.tr!(" \t\n\r",'')
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

      # Counts residues
      def counts
	count = Hash.new(0)
	self.scan(/./) do |aa|
	  count[aa] += 1
	end
	return count
      end
      alias aa_composition counts
      alias residue_composition counts

      # Sequence#randomize
      # [Q] Should it return 'M' at the first residue ?
      def randomize
	if block_given?
	  Sequence.random(self.counts, AminoAcid.keys) do |i|
	    yield i
	  end
	else
	  return AA.new(Sequence.random(self.counts, AminoAcid.keys))
	end
      end

      # class method version of Sequence#randomize
      # [Q] Should it return 'M' at the first residue ?
      def AA.randomize(count)
	if block_given?
	  Sequence.random(count, AminoAcid.keys) do |i|
	    yield i
	  end
	else
	  return AA.new(Sequence.random(count, AminoAcid.keys))
	end
      end

    end

  end

end


# Testing code
if __FILE__ == $0

  puts "\n == Test: Bio::Sequence.random(counts) =="
  counts = {'a'=>30,'c'=>24,'g'=>40,'t'=>30}
  s = Bio::Sequence.random(counts)
  p s
  p s.type

  puts "\n == Test: Bio::Sequence::NA#randomize ==" 
  seq = 'gtcgcacatgactgcttgctaatcgtatcagtgatcgatgatcacgatgaacgctagctag'
  s = Bio::Sequence::NA.new(seq)
  puts "Counts: #{s.counts.inspect}"
  print "Orginal:    "
  puts s
  print "Randomized: "
  s.randomize do |b|
    print b
  end
  puts 
  puts "Randomized: #{s.randomize}"
  puts "Randomized: #{s.randomize}"
  puts "Randomized: #{s.randomize}"
  puts "Randomized: #{s.randomize}"
  puts "Randomized: #{s.randomize}"
  p s.randomize.type

  puts "\n == Test: Bio::Sequence::NA.randomize(counts) =="
  counts = {'a'=>30,'c'=>24,'g'=>40,'t'=>30}
  puts "counts: #{counts.inspect}"
  Bio::Sequence::NA.randomize(counts) do |i|
    print i
  end
  puts
  rd = Bio::Sequence::NA.randomize(counts) 
  puts rd
  p rd.type


  puts "\n == Test: Bio::Sequence::AA#randomize =="
  aaseq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDA'
  s = Bio::Sequence::AA.new(aaseq)
  print "Orginal:    "
  puts s
  puts "Randomized: #{s.randomize}"
  puts "Randomized: #{s.randomize}"
  puts "Randomized: #{s.randomize}"
  puts "Randomized: #{s.randomize}"
  puts "Randomized: #{s.randomize}"
  p s.type


  counts = s.counts
  puts "\n == Test: Bio::Sequence::AA.randomize(counts) =="
  print "counts: "
  p counts
  ra = Bio::Sequence::AA.randomize(counts)
  p ra
  p ra.type
  Bio::Sequence::AA.randomize(counts) {|h|
    print h
  }
  puts 
  ra = Bio::Sequence::AA.randomize(counts)
  p ra.type



end


=begin

= Bio::Sequence

--- Bio::Sequence#subseq(start = 1, end = length)
--- Bio::Sequence#window_search(window_size)
--- Bio::Sequence#total(hash)
--- Bio::Sequence#random

      Returns a randomized sequence of keeping the base/residue counts. 
      In the block from, a base/residue is passed as in a parameter upto
      the length.

--- Bio::Sequence.random(counts, labels = nil)

      Returns a randomized sequence (String) in given base/residue 
      counts. 
      In the block from, a base/residue is passed as in a parameter upto
      the sum of the counts.
      This method allows any keys in the counts Hash.



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

--- Bio::Sequence::NA#randomize

      NA version of Bio::Sequence.randomize.

--- Bio::Sequence::NA.randomize(counts)

      Class method version of NA#randomize.

= Bio::Sequence::AA

--- Bio::Sequence::AA#new(str)

--- Bio::Sequence::AA#to_a(short)
--- Bio::Sequence::AA#molecular_weight(hash)
--- Bio::Sequence::AA#counts

      Returns a Hash of the count for each residue,
      cf) "{'A' => 20, ... }".

--- Bio::Sequence::AA#randomize

      AA version of Bio::Sequence.randomize.

--- Bio::Sequence::AA.randomize(counts)

      Class method version of AA#randomize.
=end

