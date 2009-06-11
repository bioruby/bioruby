#
# = sample/demo_sequence.rb - demonstration of sequence manipulation
#
# Copyright::   Copyright (C) 2000-2006
#               Toshiaki Katayama <k@bioruby.org>,
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id:$
#
# == Description
#
# Demonstration of biological sequence manipulation.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_sequence.rb
#
# == Development information
#
# The code was moved from lib/bio/sequence.rb.
#

require 'bio'

#if __FILE__ == $0

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

#end
