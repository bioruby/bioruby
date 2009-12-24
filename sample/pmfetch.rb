#!/usr/bin/env ruby 
#
# pmfetch.rb - generate BibTeX format reference list by PubMed ID list
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
#  $Id:$
#

require 'bio' 

Bio::NCBI.default_email = 'staff@bioruby.org'

if ARGV[0] =~ /\A\-f/
  ARGV.shift
  form = ARGV.shift
else
  form = 'bibtex'
end

ARGV.each do |id| 
  entries = Bio::PubMed.efetch(id) 
  if entries and entries.size == 1 then
    entry = entries[0]
  else
    # dummy entry if not found or possibly incorrect result
    entry = 'PMID- '
  end
  case form
  when 'medline'
    puts entry
  else
    puts Bio::MEDLINE.new(entry).reference.__send__(form.intern)
  end
  print "\n"
end 

