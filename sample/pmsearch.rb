#!/usr/bin/env ruby
#
# pmsearch.rb - generate BibTeX format reference list by PubMed keyword search
#
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#  $Id: pmsearch.rb,v 1.2 2002/07/23 04:52:03 k Exp $
#

require 'bio'

if ARGV[0] =~ /-f/
  ARGV.shift
  form = ARGV.shift
else
  form = 'bibtex'
end

entries = Bio::PubMed.search(ARGV.join(' '))
entries.each do |entry| 
  case form
  when 'medline'
    puts entry
  else
    puts Bio::MEDLINE.new(entry).reference.send(form)
  end
end

