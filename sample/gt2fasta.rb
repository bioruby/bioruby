#!/usr/bin/env ruby
#
# gt2fasta.rb - convert GenBank translations into FASTA format (pep)
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: gt2fasta.rb,v 0.3 2002/04/15 03:06:17 k Exp $
#

require 'bio/io/flatfile'
require 'bio/feature'
require 'bio/db/genbank'

include Bio

ff = FlatFile.new(GenBank, ARGF)

while gb = ff.next_entry

  orf = 0
  gb.features.each do |f|
    f = f.assoc
    if aaseq = f['translation']
      orf += 1
      gene = [
        f['gene'],
        f['product'],
        f['note'],
        f['function']
      ].compact.join(', ')
      definition = "gp:#{gb.entry_id}_#{orf} #{gene} [#{gb.organism}]"
      print aaseq.to_fasta(definition, 70)
    end
  end

end

