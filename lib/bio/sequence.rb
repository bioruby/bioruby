#
# = bio/sequence.rb - biological sequence class
#
# Copyright::   Copyright (C) 2000-2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Yoshinori K. Okuji <okuji@enbug.org>,
#               Naohisa Goto <ng@bioruby.org>
# License::     Ruby's
#
# $Id: sequence.rb,v 0.56 2006/02/17 17:15:08 k Exp $
#

require 'bio/sequence/compat'

module Bio

class Sequence

  autoload :Common,  'bio/sequence/common'
  autoload :NA,      'bio/sequence/na'
  autoload :AA,      'bio/sequence/aa'
  autoload :Generic, 'bio/sequence/generic'
  autoload :Format,  'bio/sequence/format'

  def initialize(str)
    @seq = str
  end

  def method_missing(*arg)
    @seq.send(*arg)
  end

  attr_accessor :entry_id, :definition, :features, :references, :comments,
    :date, :keywords, :dblinks, :taxonomy, :moltype, :seq

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

  def auto
    @moltype = guess
    if @moltype == NA
      @seq = NA.new(@seq)
    else
      @seq = AA.new(@seq)
    end
  end

  def self.auto(str)
    seq = self.new(str)
    seq.auto
    return seq
  end

  def guess(threshold = 0.9, length = 10000, index = 0)
    str = @seq.to_s[index,length].to_s.extend Bio::Sequence::Common
    cmp = str.composition

    bases = cmp['A'] + cmp['T'] + cmp['G'] + cmp['C'] + 
            cmp['a'] + cmp['t'] + cmp['g'] + cmp['c']

    total = @seq.length - cmp['N'] - cmp['n']

    if bases.to_f / total > threshold
      return NA
    else
      return AA
    end
  end 

  def self.guess(str, *args)
    self.new(str).guess(*args)
  end

  def na
    @seq = NA.new(@seq)
    @moltype = NA
  end

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


