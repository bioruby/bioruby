#!/usr/bin/env ruby
#
# gb2fasta.rb - convert GenBank entry into FASTA format (nuc)
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
#  $Id: gb2fasta.rb,v 0.1 2001/06/21 08:22:54 katayama Exp $
#

require 'bio/db/genbank'
require 'bio/util/fold'

while gets(GenBank::DELIMITER)
  gb = GenBank.new($_)

  puts ">gb:#{gb.id} #{gb.definition}"
  puts gb.naseq.fold(70)
end

