#!/usr/bin/env ruby
#
# biofetch - BioFetch client
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
#  $Id: br_biofetch.rb,v 1.2 2002/12/03 18:54:43 k Exp $
#

require 'bio/io/fetch'

def usage
  default_url = 'http://bioruby.org/cgi-bin/biofetch.rb'
  another_url = 'http://www.ebi.ac.uk/cgi-bin/dbfetch'
  puts "#{$0} [-s[erver] #{another_url}] db id [style] [format]"
  puts "  server : URL of the BioFetch CGI (default is #{default_url})"
  puts "      db : database name (embl, genbank, etc.)"
  puts "      id : entry id"
  puts "   style : 'raw' or 'html' (default is 'raw')"
  puts "  format : change the output format ('default', 'fasta', etc.)"
end

if ARGV.empty? or ARGV[0] =~ /^--?h/
  usage
  exit 1
end

case ARGV[0]
when /^--?s/				# User specified server
  ARGV.shift
  serv = Bio::Fetch.new(ARGV.shift)
  puts serv.fetch(*ARGV)
when /^--?e/				# EBI server
  ARGV.shift
  serv = Bio::Fetch.new('http://www.ebi.ac.uk/cgi-bin/dbfetch')
  puts serv.fetch(*ARGV)
when /^--?r/				# BioRuby server
  ARGV.shift
  serv = Bio::Fetch.new('http://bioruby.org/cgi-bin/biofetch.rb')
  puts serv.fetch(*ARGV)
else					# Default server
  puts Bio::Fetch.query(*ARGV)
end


