#!/usr/bin/env ruby
#
# enzymes.rb - cut input file using enzyme on command line
#
#   Copyright (C) 2006 Pjotr Prins <p@bioruby.org> and Trevor Wennblom <trevor@corevx.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  $Id: enzymes.rb,v 1.1 2006/03/03 15:31:06 pjotr Exp $
#

require 'bio/io/flatfile'
require 'bio/util/restriction_enzyme'

include Bio

usage = <<USAGE

Usage: enzymes.rb enzyme1 [enzyme2] infiles

  Examples:

    Output the primary sequences cut using both BstYI and MseI:
		
	    ./enzymes.rb BstYI MseI *.seq

    or using the actual formats

	    ./enzymes.rb "r^gatcy" "t^taa" *.seq
		
USAGE

if ARGV.size < 2
  print usage
	exit 1
end

enzyme1 = ARGV.shift
# ---- Fetch enzyme2 if it is not a file
arg2 = ARGV[0]
if arg2 and !File.exist?(arg2)
  enzyme2 = ARGV.shift 
end

re1 = Bio::RestrictionEnzyme::DoubleStranded.new(enzyme1)
puts "Enzyme #{enzyme1}: " + re1.primary.with_cut_symbols # e.g. r^gatcy
if (enzyme2)
  re2 = Bio::RestrictionEnzyme::DoubleStranded.new(enzyme2)
  puts "Enzyme #{enzyme2}: " + re2.primary.with_cut_symbols # e.g. t^taa
end

ARGV.each do | fn |
  ff = Bio::FlatFile.auto(fn)
  ff.each_entry do |entry|
    seq = Bio::Sequence::NA.new(entry.seq)
    # puts seq.inspect
    seq.cut_with_enzyme(enzyme1).each do | frag1 |
      frag = frag1
      if enzyme2
        seq = Bio::Sequence::NA.new(frag1.primary)
        frags2 = seq.cut_with_enzyme(enzyme2)
        next if frags2.size == 0
        frag = frags2.shift  # pick up first fragment
      end
      print '> '+entry.definition+"\n"
      print frag.primary,"\n"
    end
	end
end

