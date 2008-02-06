#!/usr/bin/env ruby
#
# translate.rb - translate any NA input into AA FASTA format
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
#  $Id: na2aa.rb,v 1.1 2008/02/06 16:25:53 pjotr Exp $
#

require 'bio'
require 'pp'

include Bio

ARGV.each do | fn |
  Bio::FlatFile.auto(fn).each do | item |
    seq = Sequence::NA.new(item.data)
    aa = seq.translate
    aa.gsub!(/X/,'-')
    rec = Bio::FastaFormat.new('> '+item.definition+"\n"+aa)
    print rec
  end
end

