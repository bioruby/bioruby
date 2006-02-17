#!/usr/bin/env ruby
#
# any2fasta.rb - convert input file into FASTA format using a regex
#                filter
#
#   Copyright (C) 2006 Pjotr Prins <p@bioruby.org>
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
#  $Id: any2fasta.rb,v 1.1 2006/02/17 14:59:27 pjotr Exp $
#

require 'bio/io/flatfile'

include Bio

usage = <<USAGE

Usage: any2fasta.rb [regex] infiles

  Examples:

    Output all sequences containing GATC or GATT ignoring case:
		
	  any2fasta.rb "/GAT[CT]/i" *.seq > reduced.fasta
		
USAGE

if ARGV.size == 0
  print usage
	exit 1
end

# ---- Valid regular expression - if it is not a file
regex = ARGV[0]
if regex=~/^\// and !File.exist?(regex)
  ARGV.shift
else
  regex = nil
end

ARGV.each do | fn |
  ff = Bio::FlatFile.auto(fn)
  ff.each_entry do |entry|
	  if regex != nil
		  next if eval("entry.seq !~ #{regex}")
		end
  	print entry.seq.to_fasta(entry.definition,70)
	end
end

