#!/usr/bin/env ruby
#
# fsplit.rb - split FASTA file by each n entries
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
#  $Id: fsplit.rb,v 0.1 2001/06/21 08:22:29 katayama Exp $
#

if ARGV.length != 2

  print <<-USAGE
  fsplit.rb - split FASTA file by each n entries
 
   Usage :
 
     % ./fsplit.rb 2000 seq.f
 
     This will produce seq.f.1, seq.f.2, ... with containing 2000 sequences
     in each file.

  USAGE
  exit 1

end

count = ARGV.shift.to_i

i = -1

while gets
  if /^>/
    i += 1
    if i % count == 0 
      n = i / count
      out = File.new("#{$FILENAME}.#{n+1}", "w+")
    end
  end
  out.print
end

