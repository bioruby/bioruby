#
# bio/sequence.rb - biological sequence class
#
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
#   Copyright (C) 2001  Yoshinori K. Okuji <o@bioruby.org>
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
#  $Id: sequence.rb,v 0.16 2001/12/15 03:29:07 okuji Exp $
#

require 'bio/data/na'
require 'bio/data/aa'
require 'bio/data/codontable'
require 'bio/location'

module Bio

  # Nucleic/Amino Acid sequence

  class Sequence

    # Should use the Forwardable module, but it doesn't work well with
    # some methods (e.g. []), so use our own hack at the moment. Maybe
    # a Ruby's bug.
    STRING_METHODS = [:to_str]
    def method_missing(name, *args, &block)
      s = @str.__send__(name, *args, &block)
      if not s.kind_of? String or STRING_METHODS.include? name
	s
      else
	type.new s
      end
    end

    def initialize(str)
      @str = str
    end
    
    def subseq(s = 1, e = self.length)
      s -= 1
      e -= 1
      self[s..e]
    end

    def to_fasta(header = '', width = nil)
      ">#{header}\n" +
	if width
	  self.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
	else
	  self + "\n"
	end
    end

    def fasta(factory, header = '')
      factory.query(self.to_fasta(header))
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

    def composition
      count = Hash.new(0)
      self.scan(/./) do |x|
	count[x] += 1
      end
      return count
    end


    def randomize(hash = nil)
      length = self.length
      if hash
	count = hash.clone
	count.each_value {|x| length += x}
      else
	count = self.composition
      end

      seq = ''
      tmp = {}
      length.times do 
	count.each do |k, v|
	  tmp[k] = v * rand
	end
	max = tmp.max {|a, b| a[1] <=> b[1]}
	count[max.first] -= 1

	if block_given?
	  yield max.first
	else
	  seq += max.first
	end
      end
      return seq
    end


    # Nucleic Acid sequence

    class NA < Sequence

      def initialize(str)
	super
	self.downcase!
	self.tr!('u', 't')
	self.tr!(" \t\n\r",'')
      end

      # This method depends on Locations class, see bio/location.rb
      def splicing(position)
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
	str.tr!('atgcrymkdhvbswn', 'tacgyrkmhdbvswn')
	NA.new(str)
      end

      # CodonTable is defined in bio/data/codontable.rb
      def codon_table(table = 1, codon = nil)
	if codon
	  CodonTable[table][codon]
	else
	  CodonTable[table]
	end
      end

      def translate(frame = 1, table = 1)
	ct = self.codon_table(table)
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

      def gc_percent
	count = self.composition
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

      def randomize(*arg, &block)
	NA.new(super(*arg, &block))
      end

      def NA.randomize(*arg, &block)
	NA.new('').randomize(*arg, &block)
      end

    end


    # Amino Acid sequence

    class AA < Sequence

      def initialize(str)
	super
	self.upcase!
	self.tr!(" \t\n\r",'')
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

      def randomize(*arg, &block)
	AA.new(super(*arg, &block))
      end

      def AA.randomize(*arg, &block)
	AA.new('').randomize(*arg, &block)
      end

    end

  end

end


if __FILE__ == $0

  puts "== Test Bio::Sequence::NA.new"
  p Bio::Sequence::NA.new('')
  p na = Bio::Sequence::NA.new('aaaatttggccggtttaaaa')

  puts "== Test Bio::Sequence::NA#[]"
  p na[0,5]

  puts "== Test Bio::Sequence::NA#splicing"
  p na.splicing("complement(join(1..5,16..20))")

  puts "== Test Bio::Sequence::NA#complement"
  p Bio::Sequence::NA.new('tacgyrkmhdbvswn').complement



  puts "\n == Test: Bio::Sequence.random(counts) =="
  counts = {'a'=>30,'c'=>24,'g'=>40,'t'=>30}
  s = Bio::Sequence::NA.randomize(counts)
  p s
  p s.type

  puts "\n == Test: Bio::Sequence::NA#randomize ==" 
  seq = 'gtcgcacatgactgcttgctaatcgtatcagtgatcgatgatcacgatgaacgctagctag'
  s = Bio::Sequence::NA.new(seq)
  puts "Counts: #{s.composition.inspect}"
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
  p counts
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


  counts = s.composition
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

--- Bio::Sequence#subseq(start = 1, end = self.length)

      Returns the subsequence of the self string.

--- Bio::Sequence#to_fasta(header = '', width = nil)

      Output the FASTA format string of the sequence.  The 1st argument is
      used as the comment string.  If the 2nd option is given, the output
      sequence will be folded.

--- Bio::Sequence#fasta(factory, header = '')

      Execute fasta by the factory (Bio::Fasta object) and returns
      Bio::Fasta::Report object.  See Bio::Fasta for more details.

--- Bio::Sequence#window_search(window_size)

      This method yields a window search along with the self sequence with
      the size 'window_size' window.

--- Bio::Sequence#total(hash)

      This method receive a hash of residues/bases to the particular values,
      and sum up the value along with the self sequence.  Especially useful
      to use with the window_search method and amino acid indices etc.

--- Bio::Sequence#composition

      Returns a hash of the occurrence counts for each residue or base.

--- Bio::Sequence#randomize(count = nil)

      Returns a randomized sequence keeping its composition by default.
      The argument is required when generating a random sequence from the empty
      sequence (used by the class methods NA.randomize, AA.randomize).
      If the block is given, yields for each random residue/base.

== Bio::Sequence::NA

--- Bio::Sequence::NA.new(str)

      Generate a nucleic acid sequence object from a string.

--- Bio::Sequence::NA#[](*arg)

      Replacement for the String#[].

--- Bio::Sequence::NA#splicing(position)

      Receive a GenBank style position string and convert it to the Location
      objects to splice the self sequence.  See bio/location.rb, too.

--- Bio::Sequence::NA#complement

      Returns a reverse complement sequence (including the universal codes).

--- Bio::Sequence::NA#codon_table(table = 1, codon = nil)

      Look up the codon table or select a codon table from the list.

--- Bio::Sequence::NA#translate(frame = 1, table = 1)

      Translate into the amino acid sequence from the given frame and the
      selected codon table.

--- Bio::Sequence::NA#gc_percent
--- Bio::Sequence::NA#gc

      Calculate the ratio of GC / ATGC bases in percent.

--- Bio::Sequence::NA#illegal_bases

      Show abnormal bases other than 'atgcu'.

--- Bio::Sequence::NA#molecular_weight(hash)

      Estimate the weight of this biological string molecule.

--- Bio::Sequence::NA#to_re

      Convert the universal code string into the regular expression.

--- Bio::Sequence::NA#to_a

      Convert the self string into the list of the names of the each base.

--- Bio::Sequence::NA#rna

      Output a RNA character string simply by the substitution of 't' to 'u'.

--- Bio::Sequence::NA#randomize

      Randomize the nucleotide sequence.

--- Bio::Sequence::NA.randomize(composition)

      Generate a new random sequence with the given frequency of the bases.
      The sequence length is determined by the sum of each base occurences.

== Bio::Sequence::AA

--- Bio::Sequence::AA.new(str)

      Generate a amino acid sequence object from a string.

--- Bio::Sequence::AA#to_a(short)

      Generate the list of the names of the each residue along with the
      sequence.  If the argument is given (and true), returns short names.

--- Bio::Sequence::AA#molecular_weight(hash)

      Estimate the weight of this protein.

--- Bio::Sequence::AA#randomize

      Randomize the amino acid sequence.

--- Bio::Sequence::AA.randomize(composition)

      Generate a new random sequence with the given frequency of the residues.
      The sequence length is determined by the sum of each residue occurences.

=end

