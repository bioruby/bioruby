#!/usr/local/bin/ruby
#
# biofetch.rb : BioFetch interface to GenomeNet/DBGET
#               (created during BioHackathon, AZ :)
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
#  $Id: biofetch.rb,v 1.3 2002/02/05 07:42:30 katayama Exp $
#

require 'bio'
require 'cgi-lib'

MAX_ID_NUM = 50

def print_query_page
  CGI::print {
    CGI::tag('html') {
      CGI::tag('head') {
        CGI::tag('title') {
          "BioFetch interface to GenomeNet/DBGET"
        } +
        CGI::tag('link', {'rel'=>'icon', 'href'=>'http://bioruby.org/icon/1.png', 'type'=>'image/png'})
      } + 
      CGI::tag('body', {'bgcolor'=>'#ffffff'}) {
        CGI::tag('h1') {
          CGI::tag('img', {'src'=>'http://bioruby.org/icon/big.png', 'align'=>'middle'}) +
          "BioFetch interface to " +
          CGI::tag('a', {'href'=>'http://www.genome.ad.jp/dbget/'}) {
            "GenomeNet/DBGET"
          }
        } +
	CGI::tag('p') {
          "This page allows you to retrieve up to #{MAX_ID_NUM} entries at the time from various up-to-date biological databases."
	} +
        CGI::tag('hr') +
        CGI::tag('form', {'action'=>'biofetch.rb', 'method'=>'GET'}) {
						# test POST
          CGI::tag('select', {'name'=>'db'}) {
            CGI::tag('option', {'value'=>'embl-today'}) { "EMBL" } +
            CGI::tag('option', {'value'=>'genbank-today'}) { "GenBank" } +
            CGI::tag('option', {'value'=>'refseq-today'}) { "RefSeq" } +
            CGI::tag('option', {'value'=>'swissprot-today'}) { "Swiss-Prot" } +
            CGI::tag('option', {'value'=>'pir'}) { "PIR" } +
            CGI::tag('option', {'value'=>'prf'}) { "PRF" } +
            CGI::tag('option', {'value'=>'pdb-today'}) { "PDB" } +
            CGI::tag('option', {'value'=>'pdbstr-today'}) { "PDBSTR" } +
            CGI::tag('option', {'value'=>'epd'}) { "EPD" } +
            CGI::tag('option', {'value'=>'transfac'}) { "TRANSFAC" } +
            CGI::tag('option', {'value'=>'prosite'}) { "PROSITE" } +
            CGI::tag('option', {'value'=>'pmd'}) { "PMD" } +
            CGI::tag('option', {'value'=>'litdb'}) { "LITDB" } +
            CGI::tag('option', {'value'=>'omim'}) { "OMIM" } +
            CGI::tag('option', {'value'=>'ligand'}) { "KEGG/LIGAND" } +
            CGI::tag('option', {'value'=>'pathway'}) { "KEGG/PATHWAY" } +
            CGI::tag('option', {'value'=>'brite'}) { "KEGG/BRITE" } +
            CGI::tag('option', {'value'=>'genes'}) { "KEGG/GENES" } +
            CGI::tag('option', {'value'=>'genome'}) { "KEGG/GENOME" } +
            CGI::tag('option', {'value'=>'linkdb'}) { "LinkDB" } +
            CGI::tag('option', {'value'=>'aaindex'}) { "AAindex" }
          } +
          CGI::tag('input', {'type'=>'text', 'name'=>'id', 'size'=>'40', 'maxlength'=>'1000'}) +
          CGI::tag('select', {'name'=>'format'}) {
            CGI::tag('option', {'value'=>'default'}) { "Default" } +
            CGI::tag('option', {'value'=>'fasta'}) { "Fasta" }
          } +
          CGI::tag('select', {'name'=>'style'}) {
            CGI::tag('option', {'value'=>'raw'}) { "Raw" } +
            CGI::tag('option', {'value'=>'html'}) { "HTML" }
          } +
          CGI::tag('input', {'type'=>'submit'})
        } +
        CGI::tag('hr') +
        CGI::tag('h2') {
          "Direct access"
        } +
	CGI::tag('p') {
          "http://bioruby.org/cgi-bin/biofetch.rb?format=(default|fasta|...);style=(html|raw);db=(embl|genbank|...);id=ID[,ID,ID,...]"
        } +
	CGI::tag('p') {
          "(NOTE: the option separator ';' can be '&')"
        } +
	CGI::tag('dl') {
	  CGI::tag('dt') + CGI::tag('u') { "format" } + " (optional)" +
          CGI::tag('dd') + "default|fasta|..." +
	  CGI::tag('dt') + CGI::tag('u') { "style" } + " (required)" +
          CGI::tag('dd') + "html|raw" +
	  CGI::tag('dt') + CGI::tag('u') { "db" } + " (required)" +
          CGI::tag('dd') + "embl-today|embl|genbank-today|genbank|refseq-today|refseq|swissprot-today|swissprot|pir|prf|pdb-today|pdb|pdbstr-today|pdbstr|epd|transfac|prosite|pmd|litdb|omim|ligand|pathway|brite|genes|genome|linkdb|aaindex|..." +
	  CGI::tag('dt') + CGI::tag('u') { "id" } + " (required)" +
          CGI::tag('dd') + "comma separated list of IDs"
        } +
	CGI::tag('p') {
          "See the BioFetch specification for more details. "
        } +
        CGI::tag('h2') {
          "Examples"
        } +
        CGI::tag('dl') {
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=refseq-today;id=NC_000844'}) { "rs:NC_000844" } + " (default/raw)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=refseq-today;id=NC_000844" +
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=fasta;style=raw;db=refseq-today;id=NC_000844'}) { "rs:NC_000844" } + " (fasta/raw)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=fasta;style=raw;db=refseq-today;id=NC_000844" +
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=html;db=refseq-today;id=NC_000844'}) { "rs:NC_000844" } + " (default/html)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=html;db=refseq-today;id=NC_000844" +
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=refseq-today;id=NC_000844,NC_000846'}) { "rs:NC_000844,NC_000846" } + " (default/raw, multiple)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=refseq-today;id=NC_000844,NC_000846" +
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=embl-today;id=BUM'}) { "embl:BUM" } + " (default/raw)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=embl-today;id=BUM" +
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=swissprot-today;id=CYC_BOVIN'}) { "sp:CYC_BOVIN" } + " (default/raw)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=swissprot-today;id=CYC_BOVIN" +
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=fasta;style=raw;db=swissprot-today;id=CYC_BOVIN'}) { "sp:CYC_BOVIN" } + " (fasta/raw)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=fasta;style=raw;db=swissprot-today;id=CYC_BOVIN" +
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=genes;id=b0015'}) { "genes:b0015" } + " (default/raw)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=genes;id=b0015" +
          CGI::tag('dt') + CGI::tag('a', {'href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=prosite;id=PS00028'}) { "ps:PS00028" } + " (default/raw)" +
          CGI::tag('dd') + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=prosite;id=PS00028"
#         CGI::tag('dt') + CGI::tag('a', {'href'=>''}) { "" } +
#         CGI::tag('dd') + ""
        } +
        CGI::tag('h2') {
          "Other BioFetch implementations"
        } +
        CGI::tag('a', {'href'=>'http://www.ebi.ac.uk/cgi-bin/dbfetch'}) {
          "dbfetch at EBI"
        } +
        CGI::tag('hr') +
        CGI::tag('div', {'align'=>'right'}) {
          CGI::tag('a', {'href'=>'http://bioruby.org'}) {
            CGI::tag('img', {'border'=>'0', 'src'=>'http://bioruby.org/button/1.gif'})
          }
        }
      }
    }
  }
end



def print_result_page(query)

  db = query['db'].downcase
  id = query['id'].split(/\W/)		# not only ','

  if id.length > MAX_ID_NUM
    error_5(id.length)
  end

  case query['style']
  when /html/i
    id = id.join('%2B')
    print "Location: http://genome.jp/dbget-bin/www_bget?#{db}+#{id}\n\n"
    exit
  when /raw/i
    ;
  else
    error_2(query['style'])
  end

  case query['format']
  when /fasta/i
    format = '-f'
  when /default/i
    format = ''
  else
    error_3(query['format'],db)
  end


  entry = ''

  id.each do |query_id|
    begin
      result = Bio::DBGET.bget("#{db} #{query_id} #{format}")
    rescue
      error_4(query_id,db)
    end

    if result =~ /No such database name in DBTAB/
      error_1(db)
    else
      entry += result
    end
  end

  print "Content-type: text/plain; charset=UTF-8\n\n"
  puts entry

end



def print_error_page(str)
  CGI::print {
    str
  }
  exit
end

def error_1(db)
  str = "ERROR 1 Unknown database [#{db}]."
  print_error_page(str)
end

def error_2(style)
  str = "ERROR 2 Unknown style [#{style}]."
  print_error_page(str)
end

def error_3(format,db)
  str = "ERROR 3 Format [#{format}] not known for database [#{db}]."
  print_error_page(str)
end

def error_4(id, db)
  str = "ERROR 4 ID [#{id}] not found in database [#{db}]."
  print_error_page(str)
end

def error_5(count)
  str = "ERROR 5 Too many IDs [#{count}]. Max [#{MAX_ID_NUM}] allowed."
  print_error_page(str)
end



begin
  query = CGI.new
  if query['id'].nil?
    print_query_page
  else
    print_result_page(query)
  end
end


