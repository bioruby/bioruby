#!/usr/bin/env ruby
#
# gff2fasta: Writes GFF3 to FASTA when sequence information is available
#
#   Copyright (C) 2010 Pjotr Prins
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

require 'bio'

include Bio

usage = <<USAGE

Usage: gff2fasta.rb infile

USAGE

if ARGV.size == 0
  print usage
	exit 1
end

ARGV.each do | fn |
  Bio::GFF::GFF3.new(fn).each do | item |
    rec = Bio::FastaFormat.new('> '+item.definition.strip+"\n"+item.data)
    print rec
  end
end


