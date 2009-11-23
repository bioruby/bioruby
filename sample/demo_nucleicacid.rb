#
# = sample/demo_nucleicacid.rb - demonstration of Bio::NucleicAcid
#
# Copyright::	Copyright (C) 2001, 2005
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#
# == Description
#
# Demonstration of Bio::NucleicAcid, data related to nucleic acids.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_nucleicacid.rb
#
# == Development information
#
# The code was moved from lib/bio/data/na.rb.
#

require 'bio'

#if __FILE__ == $0

  puts "### na = Bio::NucleicAcid.new"
  na = Bio::NucleicAcid.new

  puts "# na.to_re('yrwskmbdhvnatgc')"
  p na.to_re('yrwskmbdhvnatgc')

  puts "# Bio::NucleicAcid.to_re('yrwskmbdhvnatgc')"
  p Bio::NucleicAcid.to_re('yrwskmbdhvnatgc')

  puts "# na.weight('A')"
  p na.weight('A')

  puts "# Bio::NucleicAcid.weight('A')"
  p Bio::NucleicAcid.weight('A')

  puts "# na.weight('atgc')"
  p na.weight('atgc')

  puts "# Bio::NucleicAcid.weight('atgc')"
  p Bio::NucleicAcid.weight('atgc')

#end
