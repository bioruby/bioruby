#!/usr/bin/env ruby
#
# = biofetch - BioFetch client
#
# Copyright::   Copyright (C) 2002
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
#

require 'bio/io/fetch'

def usage
  default_url = Bio::Fetch::EBI::URL
  another_url = "http://localhost/cgi-bin/biofetch.rb"
  puts "#{$0} [-s[erver] #{another_url}] db id [style] [format]"
  puts "  server : URL of the BioFetch CGI (default is #{default_url})"
  puts "      db : database name (embl, uniprot, etc.)"
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
  serv = Bio::Fetch::ebi.new
  puts serv.fetch(*ARGV)
when /^--?r/				# BioRuby server
  warn "BioRuby BioFetch server (http://bioruby.org/cgi-bin/biofetch.rb) is deprecated."
  exit(1)
else					# Default server
  puts Bio::Fetch::EBI.query(*ARGV)
end


