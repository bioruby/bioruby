#
# = sample/demo_aminoacid.rb - demonstration of Bio::AminoAcid
#
# Copyright::	Copyright (C) 2001, 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#
# == Description
#
# Demonstration of Bio::AminoAcid, the class for amino acid data.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_aminoacid.rb
#
# == Development information
#
# The code was moved from lib/bio/data/aa.rb.
#

require 'bio'

#if __FILE__ == $0

  puts "### aa = Bio::AminoAcid.new"
  aa = Bio::AminoAcid.new

  puts "# Bio::AminoAcid['A']"
  p Bio::AminoAcid['A']
  puts "# aa['A']"
  p aa['A']

  puts "# Bio::AminoAcid.name('A'), Bio::AminoAcid.name('Ala')"
  p Bio::AminoAcid.name('A'), Bio::AminoAcid.name('Ala')
  puts "# aa.name('A'), aa.name('Ala')"
  p aa.name('A'), aa.name('Ala')

  puts "# Bio::AminoAcid.to_1('alanine'), Bio::AminoAcid.one('alanine')"
  p Bio::AminoAcid.to_1('alanine'), Bio::AminoAcid.one('alanine')
  puts "# aa.to_1('alanine'), aa.one('alanine')"
  p aa.to_1('alanine'), aa.one('alanine')
  puts "# Bio::AminoAcid.to_1('Ala'), Bio::AminoAcid.one('Ala')"
  p Bio::AminoAcid.to_1('Ala'), Bio::AminoAcid.one('Ala')
  puts "# aa.to_1('Ala'), aa.one('Ala')"
  p aa.to_1('Ala'), aa.one('Ala')
  puts "# Bio::AminoAcid.to_1('A'), Bio::AminoAcid.one('A')"
  p Bio::AminoAcid.to_1('A'), Bio::AminoAcid.one('A')
  puts "# aa.to_1('A'), aa.one('A')"
  p aa.to_1('A'), aa.one('A')

  puts "# Bio::AminoAcid.to_3('alanine'), Bio::AminoAcid.three('alanine')"
  p Bio::AminoAcid.to_3('alanine'), Bio::AminoAcid.three('alanine')
  puts "# aa.to_3('alanine'), aa.three('alanine')"
  p aa.to_3('alanine'), aa.three('alanine')
  puts "# Bio::AminoAcid.to_3('Ala'), Bio::AminoAcid.three('Ala')"
  p Bio::AminoAcid.to_3('Ala'), Bio::AminoAcid.three('Ala')
  puts "# aa.to_3('Ala'), aa.three('Ala')"
  p aa.to_3('Ala'), aa.three('Ala')
  puts "# Bio::AminoAcid.to_3('A'), Bio::AminoAcid.three('A')"
  p Bio::AminoAcid.to_3('A'), Bio::AminoAcid.three('A')
  puts "# aa.to_3('A'), aa.three('A')"
  p aa.to_3('A'), aa.three('A')

  puts "# Bio::AminoAcid.one2three('A')"
  p Bio::AminoAcid.one2three('A')
  puts "# aa.one2three('A')"
  p aa.one2three('A')

  puts "# Bio::AminoAcid.three2one('Ala')"
  p Bio::AminoAcid.three2one('Ala')
  puts "# aa.three2one('Ala')"
  p aa.three2one('Ala')

  puts "# Bio::AminoAcid.one2name('A')"
  p Bio::AminoAcid.one2name('A')
  puts "# aa.one2name('A')"
  p aa.one2name('A')

  puts "# Bio::AminoAcid.name2one('alanine')"
  p Bio::AminoAcid.name2one('alanine')
  puts "# aa.name2one('alanine')"
  p aa.name2one('alanine')

  puts "# Bio::AminoAcid.three2name('Ala')"
  p Bio::AminoAcid.three2name('Ala')
  puts "# aa.three2name('Ala')"
  p aa.three2name('Ala')

  puts "# Bio::AminoAcid.name2three('alanine')"
  p Bio::AminoAcid.name2three('alanine')
  puts "# aa.name2three('alanine')"
  p aa.name2three('alanine')

  puts "# Bio::AminoAcid.to_re('BZACDEFGHIKLMNPQRSTVWYU')"
  p Bio::AminoAcid.to_re('BZACDEFGHIKLMNPQRSTVWYU')

#end

