#!/usr/bin/env ruby
#
# fastasort: Sorts a FASTA file (in fact it can use any flat file input supported
#            by BIORUBY) while modifying the definition of each record in the
#            process.
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
#  $Id: fastasort.rb,v 1.1 2008/05/19 11:23:56 pjotr Exp $
#

require 'bio'

include Bio

table = Hash.new   # table to sort objects
ARGV.each do | fn |
  Bio::FlatFile.auto(fn).each do | item |
    # strip JALView extension from definition e.g. .../1-212
    if item.definition =~ /\/\d+-\d+$/
      item.definition = $`
    end
    table[item.definition] = item.data
  end
end

# Output sorted table
table.sort.each do | definition, data |
  rec = Bio::FastaFormat.new('> '+definition.strip+"\n"+data)
  print rec
end

