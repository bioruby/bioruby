#!/usr/bin/env ruby
#
# gb2fasta.rb - convert GenBank entry into FASTA format (nuc)
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#   Copyright (C) 2002 Yoshinori K. Okuji <o@bioruby.org>
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
#  $Id: gb2fasta.rb,v 0.3 2002/03/25 19:53:09 okuji Exp $
#

require 'bio/db/genbank'
require 'bio/util/fold'

include Bio

while gets(GenBank::DELIMITER)
  gb = GenBank.new($_)

  print gb.naseq.to_fasta("gb:#{gb.entry_id} #{gb.definition}", 70)
end

