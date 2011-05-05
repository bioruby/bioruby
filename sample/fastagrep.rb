#!/usr/bin/env ruby
#
# fastagrep: Greps a FASTA file (in fact it can read any flat file input supported
#            by BioRuby) and outputs sorted FASTA
#
#   Copyright (C) 2008 KATAYAMA Toshiaki <k@bioruby.org> & Pjotr Prins
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
#  $Id: fastagrep.rb,v 1.1 2008/05/19 12:22:05 pjotr Exp $
#

require 'bio'

include Bio

usage = <<USAGE

Usage: fastagrep.rb [--skip] [regex] infiles

    -v     Invert the sense of matching, to select non-matching lines.

  Examples:

    Output all sequence descriptors containing 'Arabidopsis' or 'Drosophila'
    ignoring case
		
	    fastagrep.rb "/Arabidopsis|Drosophila/i" *.seq 

    As the result is a FASTA stream you could pipe it for sorting with
    fastasort:
		
	    fastagrep.rb "/Arabidopsis|Drosophila/i" *.seq | fastasort.rb

    Read all IDs from a file write a new FASTA file containing only those
    IDs (Unix style):

      for x in `cat ids.txt` ; do fastagrep.rb "/$x/" nt.fa ; done > nt2.fa

USAGE

if ARGV.size == 0
  print usage
	exit 1
end

skip = (ARGV[0] == '-v')
ARGV.shift if skip

# ---- Valid regular expression - if it is not a file
regex = ARGV[0]
if regex=~/^\// and !File.exist?(regex)
  ARGV.shift
else
  print usage
  exit 1
end

ARGV.each do | fn |
  Bio::FlatFile.auto(fn).each do | item |
    if skip
  		next if eval("item.definition =~ #{regex}")
    else
  		next if eval("item.definition !~ #{regex}")
    end
    rec = Bio::FastaFormat.new('> '+item.definition.strip+"\n"+item.data)
    print rec
  end
end


