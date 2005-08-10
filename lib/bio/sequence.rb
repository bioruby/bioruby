#
# bio/sequence.rb - biological sequence class
#
#   Copyright (C) 2000-2005 KATAYAMA Toshiaki <k@bioruby.org>
#   Copyright (C) 2001 Yoshinori K. Okuji <o@bioruby.org>
#   Copyright (C) 2003 GOTO Naohisa <ng@bioruby.org>
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
#  $Id: sequence.rb,v 0.40 2005/08/10 12:53:02 k Exp $
#

require 'bio/data/na'
require 'bio/data/aa'
require 'bio/data/codontable'
require 'bio/location'

module Bio

  # Nucleic/Amino Acid sequence

  class Sequence < String

    def to_s
      "%s" % self
    end
    alias :to_str :to_s

    def seq
      self.class.new(self)
    end

    def normalize!
      initialize(self)
      self
    end
    alias :seq! :normalize!

    def <<(*arg)
      super(self.class.new(*arg))
    end
    alias :concat :<<

    def +(*arg)
      self.class.new(super(*arg))
    end


    def subseq(s = 1, e = self.length)
      return nil if s < 1 or e < 1
      s -= 1
      e -= 1
      self[s..e]
    end

    def to_fasta(header = '', width = nil)
      ">#{header}\n" +
      if width
	self.to_s.gsub(Regexp.new(".{1,#{width}}"), "\\0\n")
      else
	self.to_s + "\n"
      end
    end

    def fasta(factory, header = nil)
      factory.query(self.to_fasta(header))
    end

    def blast(factory, header = nil)
      factory.query(self.to_fasta(header))
    end

    def window_search(window_size, step_size = 1)
      i = 0
      0.step(self.length - window_size, step_size) do |i| 
        yield self[i, window_size]                        
      end                          
      return self[i + window_size .. -1] 
    end

    def total(hash)
      hash.default = 0.0 unless hash.default
      sum = 0.0
      self.each_byte do |x|
	begin
	  sum += hash[x.chr]
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
      return self.class.new(seq)
    end

    def self.randomize(*arg, &block)
      self.new('').randomize(*arg, &block)
    end

    # This method depends on Locations class, see bio/location.rb
    def splicing(position)
      unless position.is_a?(Locations) then
	position = Locations.new(position)
      end
      s = ''
      position.each do |location|
	if location.sequence
	  s << location.sequence
	else
	  exon = self.subseq(location.from, location.to)
	  begin
	    exon.complement! if location.strand < 0
	  rescue NameError
	  end
	  s << exon
	end
      end
      return self.class.new(s)
    end


    # Nucleic Acid sequence

    class NA < Sequence

      def initialize(str)
	super
	self.downcase!
	self.tr!(" \t\n\r",'')
      end

      # This method depends on Locations class, see bio/location.rb
      def splicing(position)
	mRNA = super
	if mRNA.rna?
	  mRNA.tr!('t', 'u')
	else
	  mRNA.tr!('u', 't')
	end
	mRNA
      end

      def complement
	s = self.class.new(self)
	s.complement!
	s
      end

      def complement!
	if self.rna?
	  self.reverse!
	  self.tr!('augcrymkdhvbswn', 'uacgyrkmhdbvswn')
	else
	  self.reverse!
	  self.tr!('atgcrymkdhvbswn', 'tacgyrkmhdbvswn')
	end
	self
      end

      def translate(frame = 1, table = 1, unknown = 'X')
        if table.is_a?(Bio::CodonTable)
	  ct = table
        else
          ct = Bio::CodonTable[table]
        end
	naseq = self.dna
	case frame
	when 1, 2, 3
	  frame -= 1
	when 4, 5, 6
	  frame -= 4
	  naseq.complement!
	when -1, -2, -3
	  frame = -1 - frame
	  naseq.complement!
	else
	  frame = 0
	end
        nalen = naseq.length - (naseq.length - frame) % 3
	aaseq = naseq[frame, nalen].gsub(/.{3}/) {|codon| ct[codon] or unknown}
	return Bio::Sequence::AA.new(aaseq)
      end

      def gc_percent
	count = self.composition
	at = count['a'] + count['t'] + count['u']
	gc = count['g'] + count['c']
	gc = format("%.1f", gc.to_f / (at + gc) * 100)
	return gc.to_f
      end
      alias :gc :gc_percent

      def illegal_bases
	self.scan(/[^atgcu]/).sort.uniq
      end

      # NucleicAcid is defined in bio/data/na.rb
      def molecular_weight
        if self.rna?
          NucleicAcid.weight(self, true)
        else
          NucleicAcid.weight(self)
        end
      end

      def to_re
	if self.rna?
          NucleicAcid.to_re(self.dna, true)
        else
          NucleicAcid.to_re(self)
        end
      end

      def names
	array = []
	self.each_byte do |x|
	  array.push(NucleicAcid.names[x.chr.upcase])
	end
	return array
      end

      def dna
        self.tr('u', 't')
      end

      def dna!
        self.tr!('u', 't')
      end

      def rna
        self.tr('t', 'u')
      end

      def rna!
        self.tr!('t', 'u')
      end

      def rna?
	self.index('u')
      end
      protected :rna?

      def pikachu
	self.dna.tr("atgc", "pika")	# joke, of course :-)
      end

    end


    # Amino Acid sequence

    class AA < Sequence

      def initialize(str)
	super
	self.upcase!
	self.tr!(" \t\n\r",'')
      end

      # AminoAcid is defined in bio/data/aa.rb
      def molecular_weight
        AminoAcid.weight(self)
      end

      def to_re
	AminoAcid.to_re(self)
      end

      def codes
	array = []
	self.each_byte do |x|
	  array.push(AminoAcid.names[x.chr])
	end
	return array
      end

      def names
	self.codes.map do |x|
	  AminoAcid.names[x]
	end
      end

    end

  end


  class Seq < Sequence
    attr_accessor :entry_id, :definition, :features, :references, :comments,
      :date, :keywords, :dblinks, :taxonomy, :moltype
  end

end


if __FILE__ == $0

  puts "== Test Bio::Sequence::NA.new"
  p Bio::Sequence::NA.new('')
  p na = Bio::Sequence::NA.new('atgcatgcATGCATGCAAAA')
  p rna = Bio::Sequence::NA.new('augcaugcaugcaugcaaaa')

  puts "\n== Test Bio::Sequence::AA.new"
  p Bio::Sequence::AA.new('')
  p aa = Bio::Sequence::AA.new('ACDEFGHIKLMNPQRSTVWYU')

  puts "\n== Test Bio::Sequence#to_s"
  p na.to_s
  p aa.to_s

  puts "\n== Test Bio::Sequence#subseq(2,6)"
  p na
  p na.subseq(2,6)

  puts "\n== Test Bio::Sequence#[2,6]"
  p na
  p na[2,6]

  puts "\n== Test Bio::Sequence#to_fasta('hoge', 8)"
  puts na.to_fasta('hoge', 8)

  puts "\n== Test Bio::Sequence#window_search(15)"
  p na
  na.window_search(15) {|x| p x}

  puts "\n== Test Bio::Sequence#total({'a'=>0.1,'t'=>0.2,'g'=>0.3,'c'=>0.4})"
  p na.total({'a'=>0.1,'t'=>0.2,'g'=>0.3,'c'=>0.4})

  puts "\n== Test Bio::Sequence#composition"
  p na
  p na.composition
  p rna
  p rna.composition

  puts "\n== Test Bio::Sequence::NA#splicing('complement(join(1..5,16..20))')"
  p na
  p na.splicing("complement(join(1..5,16..20))")
  p rna
  p rna.splicing("complement(join(1..5,16..20))")

  puts "\n== Test Bio::Sequence::NA#complement"
  p na.complement
  p rna.complement
  p Bio::Sequence::NA.new('tacgyrkmhdbvswn').complement
  p Bio::Sequence::NA.new('uacgyrkmhdbvswn').complement

  puts "\n== Test Bio::Sequence::NA#translate"
  p na
  p na.translate
  p rna
  p rna.translate

  puts "\n== Test Bio::Sequence::NA#gc_percent"
  p na.gc
  p rna.gc

  puts "\n== Test Bio::Sequence::NA#illegal_bases"
  p na.illegal_bases
  p Bio::Sequence::NA.new('tacgyrkmhdbvswn').illegal_bases
  p Bio::Sequence::NA.new('abcdefghijklmnopqrstuvwxyz-!%#$@').illegal_bases

  puts "\n== Test Bio::Sequence::NA#molecular_weight"
  p na
  p na.molecular_weight
  p rna
  p rna.molecular_weight

  puts "\n== Test Bio::Sequence::NA#to_re"
  p Bio::Sequence::NA.new('atgcrymkdhvbswn')
  p Bio::Sequence::NA.new('atgcrymkdhvbswn').to_re
  p Bio::Sequence::NA.new('augcrymkdhvbswn')
  p Bio::Sequence::NA.new('augcrymkdhvbswn').to_re

  puts "\n== Test Bio::Sequence::NA#names"
  p na.names

  puts "\n== Test Bio::Sequence::NA#pikachu"
  p na.pikachu

  puts "\n== Test Bio::Sequence::NA#randomize"
  print "Orig  : "; p na
  print "Rand  : "; p na.randomize
  print "Rand  : "; p na.randomize
  print "Rand  : "; p na.randomize.randomize
  print "Block : "; na.randomize do |x| print x end; puts

  print "Orig  : "; p rna
  print "Rand  : "; p rna.randomize
  print "Rand  : "; p rna.randomize
  print "Rand  : "; p rna.randomize.randomize
  print "Block : "; rna.randomize do |x| print x end; puts

  puts "\n== Test Bio::Sequence::NA.randomize(counts)"
  print "Count : "; p counts = {'a'=>10,'c'=>20,'g'=>30,'t'=>40}
  print "Rand  : "; p Bio::Sequence::NA.randomize(counts)
  print "Count : "; p counts = {'a'=>10,'c'=>20,'g'=>30,'u'=>40}
  print "Rand  : "; p Bio::Sequence::NA.randomize(counts)
  print "Block : "; Bio::Sequence::NA.randomize(counts) {|x| print x}; puts

  puts "\n== Test Bio::Sequence::AA#codes"
  p aa
  p aa.codes

  puts "\n== Test Bio::Sequence::AA#names"
  p aa
  p aa.names

  puts "\n== Test Bio::Sequence::AA#molecular_weight"
  p aa.subseq(1,20)
  p aa.subseq(1,20).molecular_weight

  puts "\n== Test Bio::Sequence::AA#randomize"
  aaseq = 'MRVLKFGGTSVANAERFLRVADILESNARQGQVATVLSAPAKITNHLVAMIEKTISGQDA'
  s = Bio::Sequence::AA.new(aaseq)
  print "Orig  : "; p s
  print "Rand  : "; p s.randomize
  print "Rand  : "; p s.randomize
  print "Rand  : "; p s.randomize.randomize
  print "Block : "; s.randomize {|x| print x}; puts

  puts "\n== Test Bio::Sequence::AA.randomize(counts)"
  print "Count : "; p counts = s.composition
  print "Rand  : "; puts Bio::Sequence::AA.randomize(counts)
  print "Block : "; Bio::Sequence::AA.randomize(counts) {|x| print x}; puts

end


=begin

= Bio::Sequence

You can use Bio::Seq instead of Bio::Sequence for short.

--- Bio::Sequence#seq

      Force self to re-initialize for clean up (remove white spaces,
      case unification).

--- Bio::Sequence#seq!
--- Bio::Sequence#normalize!

      Similar to the 'seq' method, but changes the self object destructively.

--- Bio::Sequence#subseq(start = 1, end = self.length)

      Returns the subsequence of the self string.

--- Bio::Sequence#to_fasta(header = '', width = nil)

      Output the FASTA format string of the sequence.  The 1st argument is
      used as the comment string.  If the 2nd option is given, the output
      sequence will be folded.

--- Bio::Sequence#fasta(factory, header = '')

      Execute fasta by the factory (Bio::Fasta object) and returns
      Bio::Fasta::Report object.  See Bio::Fasta for more details.

--- Bio::Sequence#blast(factory, header = '')

      Execute blast by the factory (Bio::Blast object) and returns
      Bio::Blast::Report object.  See Bio::Blast for more details.

--- Bio::Sequence#splicing(position)

      Receive a GenBank style position string and convert it to the Locations
      objects to splice the sequence itself.  See also: bio/location.rb

--- Bio::Sequence#window_search(window_size, step_size = 1)

      This method iterates on sub string with specified length 'window_size'.
      By specifing 'step_size', codon sized shifting or spliting genome
      sequence with ovelapping each end can easily be yielded.

      The remainder sequence at the terminal end will be returned.

      Example:
        # prints average GC% on each 100bp
        seq.window_search(100) do |subseq|
          puts subseq.gc
        end
        # prints every translated peptide (length 5aa) in the same frame
        seq.window_search(15, 3) do |subseq|
          puts subseq.translate
        end
        # split genome sequence by 10000bp with 1000bp overlap in fasta format
        i = 1
        remainder = seq.window_search(10000, 9000) do |subseq|
          puts subseq.to_fasta("segment #{i}", 60)
          i += 1
        end
        puts remainder.to_fasta("segment #{i}", 60)

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

--- Bio::Sequence.randomize(composition)

      Generate a new random sequence with the given frequency of bases
      or residues.  The sequence length is determined by the sum of each
      base/residue occurences.


== Bio::Sequence::NA

--- Bio::Sequence::NA.new(str)

      Generate a nucleic acid sequence object from a string.

--- Bio::Sequence::NA#complement
--- Bio::Sequence::NA#complement!

      Returns a reverse complement sequence (including the universal codes).

--- Bio::Sequence::NA#translate(frame = 1, table = 1, unknown = 'X')

      Translate into the amino acid sequence from the given frame and the
      selected codon table.  The table also can be a Bio::CodonTable object.
      The 'unknown' character is used for invalid/unknown codon (can be
      used for 'nnn' and/or gap translation in practice).

      Frame can be 1, 2 or 3 for the forward strand and -1, -2 or -3
      (4, 5 or 6 is also accepted) for the reverse strand.

--- Bio::Sequence::NA#gc_percent
--- Bio::Sequence::NA#gc

      Calculate the ratio of GC / ATGC bases in percent.

--- Bio::Sequence::NA#illegal_bases

      Show abnormal bases other than 'atgcu'.

--- Bio::Sequence::NA#molecular_weight

      Estimate the weight of this biological string molecule.

--- Bio::Sequence::NA#to_re

      Convert the universal code string into the regular expression.

--- Bio::Sequence::NA#names

      Convert the self string into the list of the names of the each base.

--- Bio::Sequence::NA#dna
--- Bio::Sequence::NA#dna!

      Output a DNA string by substituting 'u' to 't'.

--- Bio::Sequence::NA#rna
--- Bio::Sequence::NA#rna!

      Output a RNA string by substituting 't' to 'u'.


== Bio::Sequence::AA

--- Bio::Sequence::AA.new(str)

      Generate a amino acid sequence object from a string.

--- Bio::Sequence::AA#codes

      Generate the list of the names of the each residue along with the
      sequence (3 letters code).

--- Bio::Sequence::NA#names

      Similar to codes but returns long names.

--- Bio::Sequence::AA#molecular_weight

      Estimate the weight of this protein.

=end

