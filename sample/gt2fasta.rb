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
#  $Id: gt2fasta.rb,v 0.2 2001/10/17 14:43:10 katayama Exp $
#

require 'bio/db/genbank'
require 'bio/util/fold'

include Bio

while gets(GenBank::DELIMITER)
  gb = GenBank.new($_)

  orf = 0
  gb.features do |f|
    aaseq = f['translation']
    if aaseq.length > 0
      orf += 1
      definition = ">gp:#{gb.id}_#{orf} "
      ary = [ f['gene'], f['product'], f['note'], f['function'] ]
      ary.each do |d|
	if d.length > 0
	  definition += "#{d}, "
	end
      end
      definition += "[#{gb.organism}]"

      puts definition
      puts aaseq.fold(70)
    end
  end

end
