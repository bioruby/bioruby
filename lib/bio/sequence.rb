#
# = bio/sequence.rb - biological sequence class
#
# Copyright::   Copyright (C) 2000-2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Yoshinori K. Okuji <okuji@enbug.org>,
#               Naohisa Goto <ng@bioruby.org>,
#               Ryan Raaum <ryan@raaum.org>,
#               Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::     The Ruby License
#
# $Id: sequence.rb,v 0.58 2007/04/05 23:35:39 trevor Exp $
#

require 'bio/sequence/compat'

module Bio

# = DESCRIPTION
# Bio::Sequence objects represent annotated sequences in bioruby.
# A Bio::Sequence object is a wrapper around the actual sequence, 
# represented as either a Bio::Sequence::NA or a Bio::Sequence::AA object.
# For most users, this encapsulation will be completely transparent.
# Bio::Sequence responds to all methods defined for Bio::Sequence::NA/AA
# objects using the same arguments and returning the same values (even though 
# these methods are not documented specifically for Bio::Sequence).
#
# = USAGE
#   # Create a nucleic or amino acid sequence
#   dna = Bio::Sequence.auto('atgcatgcATGCATGCAAAA')
#   rna = Bio::Sequence.auto('augcaugcaugcaugcaaaa')
#   aa = Bio::Sequence.auto('ACDEFGHIKLMNPQRSTVWYU')
# 
#   # Print it out
#   puts dna.to_s
#   puts aa.to_s
# 
#   # Get a subsequence, bioinformatics style (first nucleotide is '1')
#   puts dna.subseq(2,6)
# 
#   # Get a subsequence, informatics style (first nucleotide is '0')
#   puts dna[2,6]
# 
#   # Print in FASTA format
#   puts dna.output(:fasta)
# 
#   # Print all codons
#   dna.window_search(3,3) do |codon|
#     puts codon
#   end
# 
#   # Splice or otherwise mangle your sequence
#   puts dna.splicing("complement(join(1..5,16..20))")
#   puts rna.splicing("complement(join(1..5,16..20))")
# 
#   # Convert a sequence containing ambiguity codes into a 
#   # regular expression you can use for subsequent searching
#   puts aa.to_re
# 
#   # These should speak for themselves
#   puts dna.complement
#   puts dna.composition
#   puts dna.molecular_weight
#   puts dna.translate
#   puts dna.gc_percent
class Sequence

  autoload :Common,  'bio/sequence/common'
  autoload :NA,      'bio/sequence/na'
  autoload :AA,      'bio/sequence/aa'
  autoload :Generic, 'bio/sequence/generic'
  autoload :Format,  'bio/sequence/format'

  # Create a new Bio::Sequence object
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s                                  #=> 'atgc'
  #
  # Note that this method does not intialize the contained sequence
  # as any kind of bioruby object, only as a simple string
  #
  #   puts s.seq.class                        #=> String
  #
  # See Bio::Sequence#na, Bio::Sequence#aa, and Bio::Sequence#auto 
  # for methods to transform the basic String of a just created 
  # Bio::Sequence object to a proper bioruby object
  # ---
  # *Arguments*:
  # * (required) _str_: String or Bio::Sequence::NA/AA object
  # *Returns*:: Bio::Sequence object
  def initialize(str)
    @seq = str
  end

  # Pass any unknown method calls to the wrapped sequence object.  see
  # http://www.rubycentral.com/book/ref_c_object.html#Object.method_missing
  def method_missing(sym, *args, &block) #:nodoc:
    @seq.send(sym, *args, &block)
  end
  
  # The sequence identifier.  For example, for a sequence
  # of Genbank origin, this is the accession number.
  attr_accessor :entry_id
  
  # A String with a description of the sequence
  attr_accessor :definition
  
  # An Array of Bio::Feature objects
  attr_accessor :features
  
  # An Array of Bio::Reference objects
  attr_accessor :references
  
  # A comment String
  attr_accessor :comments
  
  # Date from sequence source. Often date of deposition.
  attr_accessor :date
  
  # An Array of Strings
  attr_accessor :keywords
  
  # An Array of Strings; links to other database entries.
  attr_accessor :dblinks
  
  # A taxonomy String
  attr_accessor :taxonomy
  
  # Bio::Sequence::NA/AA
  attr_accessor :moltype
  
  # The sequence object, usually Bio::Sequence::NA/AA, 
  # but could be a simple String
  attr_accessor :seq
  
  # Using Bio::Sequence::Format, return a String with the Bio::Sequence
  # object formatted in the given style.
  #
  # Formats currently implemented are: 'fasta', 'genbank', and 'embl'
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s.output(:fasta)                   #=> "> \natgc\n"
  #
  # The style argument is given as a Ruby 
  # Symbol(http://www.ruby-doc.org/core/classes/Symbol.html)
  # ---
  # *Arguments*: 
  # * (required) _style_: :fasta, :genbank, *or* :embl
  # *Returns*:: String object
  def output(style)
    extend Bio::Sequence::Format
    case style
    when :fasta
      format_fasta
    when :gff
      format_gff
    when :genbank
      format_genbank
    when :embl
      format_embl
    end
  end

  # Guess the type of sequence, Amino Acid or Nucleic Acid, and create a 
  # new sequence object (Bio::Sequence::AA or Bio::Sequence::NA) on the basis
  # of this guess.  This method will change the current Bio::Sequence object.
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s.seq.class                        #=> String
  #   s.auto
  #   puts s.seq.class                        #=> Bio::Sequence::NA
  # ---
  # *Returns*:: Bio::Sequence::NA/AA object
  def auto
    @moltype = guess
    if @moltype == NA
      @seq = NA.new(@seq)
    else
      @seq = AA.new(@seq)
    end
  end

  # Given a sequence String, guess its type, Amino Acid or Nucleic Acid, and
  # return a new Bio::Sequence object wrapping a sequence of the guessed type
  # (either Bio::Sequence::AA or Bio::Sequence::NA)
  # 
  #   s = Bio::Sequence.auto('atgc')
  #   puts s.seq.class                        #=> Bio::Sequence::NA
  # ---
  # *Arguments*:
  # * (required) _str_: String *or* Bio::Sequence::NA/AA object
  # *Returns*:: Bio::Sequence object
  def self.auto(str)
    seq = self.new(str)
    seq.auto
    return seq
  end

  # Guess the class of the current sequence.  Returns the class
  # (Bio::Sequence::AA or Bio::Sequence::NA) guessed.  In general, used by
  # developers only, but if you know what you are doing, feel free.
  # 
  #   s = Bio::Sequence.new('atgc')
  #   puts s.guess                            #=> Bio::Sequence::NA
  #
  # There are three parameters: `threshold`, `length`, and `index`.  
  #
  # The `threshold` value (defaults to 0.9) is the frequency of 
  # nucleic acid bases [AGCTUagctu] required in the sequence for this method
  # to produce a Bio::Sequence::NA "guess".  In the default case, if less
  # than 90% of the bases (after excluding [Nn]) are in the set [AGCTUagctu],
  # then the guess is Bio::Sequence::AA.
  # 
  #   s = Bio::Sequence.new('atgcatgcqq')
  #   puts s.guess                            #=> Bio::Sequence::AA
  #   puts s.guess(0.8)                       #=> Bio::Sequence::AA
  #   puts s.guess(0.7)                       #=> Bio::Sequence::NA
  #
  # The `length` value is how much of the total sequence to use in the
  # guess (default 10000).  If your sequence is very long, you may 
  # want to use a smaller amount to reduce the computational burden.
  #
  #   s = Bio::Sequence.new(A VERY LONG SEQUENCE)
  #   puts s.guess(0.9, 1000)  # limit the guess to the first 1000 positions
  #
  # The `index` value is where to start the guess.  Perhaps you know there
  # are a lot of gaps at the start...
  #
  #   s = Bio::Sequence.new('-----atgcc')
  #   puts s.guess                            #=> Bio::Sequence::AA
  #   puts s.guess(0.9,10000,5)               #=> Bio::Sequence::NA
  # ---
  # *Arguments*:
  # * (optional) _threshold_: Float in range 0,1 (default 0.9)
  # * (optional) _length_: Fixnum (default 10000)
  # * (optional) _index_: Fixnum (default 1)
  # *Returns*:: Bio::Sequence::NA/AA
  def guess(threshold = 0.9, length = 10000, index = 0)
    str = @seq.to_s[index,length].to_s.extend Bio::Sequence::Common
    cmp = str.composition

    bases = cmp['A'] + cmp['T'] + cmp['G'] + cmp['C'] + cmp['U'] +
            cmp['a'] + cmp['t'] + cmp['g'] + cmp['c'] + cmp['u']

    total = str.length - cmp['N'] - cmp['n']

    if bases.to_f / total > threshold
      return NA
    else
      return AA
    end
  end 

  # Guess the class of a given sequence.  Returns the class
  # (Bio::Sequence::AA or Bio::Sequence::NA) guessed.  In general, used by
  # developers only, but if you know what you are doing, feel free.
  # 
  #   puts .guess('atgc')        #=> Bio::Sequence::NA
  #
  # There are three optional parameters: `threshold`, `length`, and `index`.  
  #
  # The `threshold` value (defaults to 0.9) is the frequency of 
  # nucleic acid bases [AGCTUagctu] required in the sequence for this method
  # to produce a Bio::Sequence::NA "guess".  In the default case, if less
  # than 90% of the bases (after excluding [Nn]) are in the set [AGCTUagctu],
  # then the guess is Bio::Sequence::AA.
  # 
  #   puts Bio::Sequence.guess('atgcatgcqq')      #=> Bio::Sequence::AA
  #   puts Bio::Sequence.guess('atgcatgcqq', 0.8) #=> Bio::Sequence::AA
  #   puts Bio::Sequence.guess('atgcatgcqq', 0.7) #=> Bio::Sequence::NA
  #
  # The `length` value is how much of the total sequence to use in the
  # guess (default 10000).  If your sequence is very long, you may 
  # want to use a smaller amount to reduce the computational burden.
  #
  #   # limit the guess to the first 1000 positions
  #   puts Bio::Sequence.guess('A VERY LONG SEQUENCE', 0.9, 1000)  
  #
  # The `index` value is where to start the guess.  Perhaps you know there
  # are a lot of gaps at the start...
  #
  #   puts Bio::Sequence.guess('-----atgcc')             #=> Bio::Sequence::AA
  #   puts Bio::Sequence.guess('-----atgcc',0.9,10000,5) #=> Bio::Sequence::NA
  # ---
  # *Arguments*:
  # * (required) _str_: String *or* Bio::Sequence::NA/AA object
  # * (optional) _threshold_: Float in range 0,1 (default 0.9)
  # * (optional) _length_: Fixnum (default 10000)
  # * (optional) _index_: Fixnum (default 1)
  # *Returns*:: Bio::Sequence::NA/AA
  def self.guess(str, *args)
    self.new(str).guess(*args)
  end

  # Transform the sequence wrapped in the current Bio::Sequence object
  # into a Bio::Sequence::NA object.  This method will change the current
  # object.  This method does not validate your choice, so be careful!
  #
  #   s = Bio::Sequence.new('RRLE')
  #   puts s.seq.class                        #=> String
  #   s.na
  #   puts s.seq.class                        #=> Bio::Sequence::NA !!!
  #
  # However, if you know your sequence type, this method may be 
  # constructively used after initialization,
  #
  #   s = Bio::Sequence.new('atgc')
  #   s.na
  # ---
  # *Returns*:: Bio::Sequence::NA
  def na
    @seq = NA.new(@seq)
    @moltype = NA
  end

  # Transform the sequence wrapped in the current Bio::Sequence object
  # into a Bio::Sequence::NA object.  This method will change the current
  # object.  This method does not validate your choice, so be careful!
  #
  #   s = Bio::Sequence.new('atgc')
  #   puts s.seq.class                        #=> String
  #   s.aa
  #   puts s.seq.class                        #=> Bio::Sequence::AA !!!
  #
  # However, if you know your sequence type, this method may be 
  # constructively used after initialization,
  #
  #   s = Bio::Sequence.new('RRLE')
  #   s.aa
  # ---
  # *Returns*:: Bio::Sequence::AA
  def aa
    @seq = AA.new(@seq)
    @moltype = AA
  end
  
end # Sequence


end # Bio


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
  p na.gc_percent
  p rna.gc_percent

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


