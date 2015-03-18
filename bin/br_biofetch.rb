#!/usr/bin/env ruby
#
# = biofetch - BioFetch client
#
# Copyright::   Copyright (C) 2002
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
#

begin
  require 'rubygems'
rescue LoadError
end

require 'bio/io/fetch'

def require_bio_old_biofetch_emulator(mandatory = true)
  begin
    require 'bio-old-biofetch-emulator'
  rescue LoadError
    if mandatory then
      $stderr.puts "Error: please install bio-old-biofetch-emulator gem."
      exit 1
    end
  end
end

def default_url
  'http://bioruby.org/cgi-bin/biofetch.rb'
end

def another_url
  'http://www.ebi.ac.uk/cgi-bin/dbfetch'
end

def usage
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
  require_bio_old_biofetch_emulator(false)
  ARGV.shift
  serv = Bio::Fetch.new(ARGV.shift)
  puts serv.fetch(*ARGV)
when /^--?e/				# EBI server
  ARGV.shift
  serv = Bio::Fetch.new(another_url)
  puts serv.fetch(*ARGV)
when /^--?r/				# BioRuby server
  require_bio_old_biofetch_emulator
  ARGV.shift
  serv = Bio::Fetch.new(default_url)
  puts serv.fetch(*ARGV)
else					# Default server
  require_bio_old_biofetch_emulator
  puts Bio::Fetch.query(*ARGV)
end


