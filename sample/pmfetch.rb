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
#  $Id: pmfetch.rb,v 1.1 2002/06/25 19:30:00 k Exp $
#

require 'bio' 

ARGV.each do |id| 
  entry = Bio::PubMed.query(id) 
  puts Bio::MEDLINE.new(entry).reference.bibtex
end 

