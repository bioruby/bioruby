#!/usr/bin/env ruby
#
# genes2nuc.rb - convert KEGG/GENES entry into FASTA format (nuc)
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
#  $Id: genes2pep.rb,v 0.4 2002/06/23 20:21:56 k Exp $
#

require 'bio/db/kegg/genes'
require 'bio/extend'

include Bio

while gets(KEGG::GENES::DELIMITER)
  genes = KEGG::GENES.new($_)

  next if genes.aalen == 0

  puts ">#{genes.entry_id}  #{genes.definition}"
  puts genes.aaseq.fold(60+12, 12)
end

