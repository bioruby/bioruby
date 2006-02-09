#!/usr/bin/env ruby
#
# = biofetch - BioFetch client
#
# Copyright::   Copyright (C) 2002
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: br_biofetch.rb,v 1.3 2006/02/09 16:29:41 k Exp $
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


