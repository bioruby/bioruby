#
# = sample/demo_locations.rb - demonstration of Bio::Locations
#
# Copyright::	Copyright (C) 2001, 2005 Toshiaki Katayama <k@bioruby.org>
#                             2006       Jan Aerts <jan.aerts@bbsrc.ac.uk>
#                             2008       Naohisa Goto <ng@bioruby.org>
# License::	The Ruby License
#
# == Description
#
# Demonstration of Bio::Locations, a parser class for the location string
# used in the INSDC Feature Table.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_locations.rb
#
# == Development information
#
# The code was moved from lib/bio/location.rb.
#

require 'bio'

#if __FILE__ == $0
  puts "Test new & span methods"
  [
    '450',
    '500..600',
    'join(500..550, 600..625)',
    'complement(join(500..550, 600..625))',
    'join(complement(500..550), 600..625)',
    '754^755',
    'complement(53^54)',
    'replace(4792^4793,"a")',
    'replace(1905^1906,"acaaagacaccgccctacgcc")',
    '157..(800.806)',
    '(67.68)..(699.703)',
    '(45934.45974)..46135',
    '<180..(731.761)',
    '(88.89)..>1122',
    'complement((1700.1708)..(1715.1721))',
    'complement(<22..(255.275))',
    'complement((64.74)..1525)',
    'join((8298.8300)..10206,1..855)',
    'replace((651.655)..(651.655),"")',
    'one-of(898,900)..983',
    'one-of(5971..6308,5971..6309)',
    '8050..one-of(10731,10758,10905,11242)',
    'one-of(623,627,632)..one-of(628,633,637)',
    'one-of(845,953,963,1078,1104)..1354',
    'join(2035..2050,complement(1775..1818),13..345,414..992,1232..1253,1024..1157)',
    'join(complement(1..61),complement(AP000007.1:252907..253505))',
    'complement(join(71606..71829,75327..75446,76039..76203))',
    'order(3..26,complement(964..987))',
    'order(L44135.1:(454.445)..>538,<1..181)',
    '<200001..<318389',
  ].each do |pos|
    p pos
#    p Bio::Locations.new(pos)
#    p Bio::Locations.new(pos).span
#    p Bio::Locations.new(pos).range
    Bio::Locations.new(pos).each do |location|
      puts "class=" + location.class.to_s
      puts "start=" + location.from.to_s + "\tend=" + location.to.to_s + "\tstrand=" + location.strand.to_s
    end

  end

  puts "Test rel2abs/abs2rel method"
  [
    '6..15',
    'join(6..10,16..30)',
    'complement(join(6..10,16..30))',
    'join(complement(6..10),complement(16..30))',
    'join(6..10,complement(16..30))',
  ].each do |pos|
    loc = Bio::Locations.new(pos)
    p pos
#   p loc
    (1..21).each do |x|
      print "absolute(#{x}) #=> ", y = loc.absolute(x), "\n"
      print "relative(#{y}) #=> ", y ? loc.relative(y) : y, "\n"
      print "absolute(#{x}, :aa) #=> ", y = loc.absolute(x, :aa), "\n"
      print "relative(#{y}, :aa) #=> ", y ? loc.relative(y, :aa) : y, "\n"
    end
  end

  pos = 'join(complement(6..10),complement(16..30))'
  loc = Bio::Locations.new(pos)
  print "pos         : "; p pos
  print "`- loc[1]   : "; p loc[1]
  print "   `- range : "; p loc[1].range

  puts Bio::Location.new('5').<=>(Bio::Location.new('3'))
#end

