#!/usr/local/bin/ruby
#
# biofetch.rb : BioFetch server (interface to GenomeNet/DBGET)
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
#  $Id: biofetch.rb,v 1.6 2002/03/04 08:07:36 katayama Exp $
#

require 'cgi'
require 'bio/io/dbget'

MAX_ID_NUM = 50

def print_query_page(cgi)
  cgi.out do
    cgi.html do
      cgi.head do
        cgi.title {
          "BioFetch interface to GenomeNet/DBGET"
        } +
        cgi.link('rel'=>'icon', 'href'=>'http://bioruby.org/icon/1.png', 'type'=>'image/png')
      end + 
      cgi.body('bgcolor'=>'#ffffff') do
        cgi.h1 {
          cgi.img('src'=>'http://bioruby.org/icon/big.png', 'align'=>'middle') +
          "BioFetch interface to " +
          cgi.a('href'=>'http://www.genome.ad.jp/dbget/') {
            "GenomeNet/DBGET"
          }
        } +
	cgi.p {
          "This page allows you to retrieve up to #{MAX_ID_NUM} entries at the time from various up-to-date biological databases."
	} +
        cgi.hr +
        cgi.form('action'=>'biofetch.rb') {
          cgi.select('name'=>'db') {
            cgi.option('value'=>'embl-today') { "EMBL" } +
            cgi.option('value'=>'genbank-today') { "GenBank" } +
            cgi.option('value'=>'refseq-today') { "RefSeq" } +
            cgi.option('value'=>'swissprot-today') { "Swiss-Prot" } +
            cgi.option('value'=>'pir') { "PIR" } +
            cgi.option('value'=>'prf') { "PRF" } +
            cgi.option('value'=>'pdb-today') { "PDB" } +
            cgi.option('value'=>'pdbstr-today') { "PDBSTR" } +
            cgi.option('value'=>'epd') { "EPD" } +
            cgi.option('value'=>'transfac') { "TRANSFAC" } +
            cgi.option('value'=>'prosite') { "PROSITE" } +
            cgi.option('value'=>'pmd') { "PMD" } +
            cgi.option('value'=>'litdb') { "LITDB" } +
            cgi.option('value'=>'omim') { "OMIM" } +
            cgi.option('value'=>'ligand') { "KEGG/LIGAND" } +
            cgi.option('value'=>'pathway') { "KEGG/PATHWAY" } +
            cgi.option('value'=>'brite') { "KEGG/BRITE" } +
            cgi.option('value'=>'genes') { "KEGG/GENES" } +
            cgi.option('value'=>'genome') { "KEGG/GENOME" } +
            cgi.option('value'=>'linkdb') { "LinkDB" } +
            cgi.option('value'=>'aaindex') { "AAindex" }
          } +
          cgi.input('type'=>'text', 'name'=>'id', 'size'=>'40', 'maxlength'=>'1000') +
          cgi.select('name'=>'format') {
            cgi.option('value'=>'default') { "Default" } +
            cgi.option('value'=>'fasta') { "Fasta" }
          } +
          cgi.select('name'=>'style') {
            cgi.option('value'=>'raw') { "Raw" } +
            cgi.option('value'=>'html') { "HTML" }
          } +
          cgi.input('type'=>'submit')
        } +
        cgi.hr +
        cgi.h2 {
          "Direct access"
        } +
	cgi.p {
          "http://bioruby.org/cgi-bin/biofetch.rb?format=(default|fasta|...);style=(html|raw);db=(embl|genbank|...);id=ID[,ID,ID,...]"
        } +
	cgi.p {
          "(NOTE: the option separator ';' can be '&')"
        } +
	cgi.dl {
	  cgi.dt + cgi.u { "format" } + " (optional)" +
          cgi.dd + "default|fasta|..." +
	  cgi.dt + cgi.u { "style" } + " (required)" +
          cgi.dd + "html|raw" +
	  cgi.dt + cgi.u { "db" } + " (required)" +
          cgi.dd + "embl-today|embl|genbank-today|genbank|refseq-today|refseq|swissprot-today|swissprot|pir|prf|pdb-today|pdb|pdbstr-today|pdbstr|epd|transfac|prosite|pmd|litdb|omim|ligand|pathway|brite|genes|genome|linkdb|aaindex|..." +
	  cgi.dt + cgi.u { "id" } + " (required)" +
          cgi.dd + "comma separated list of IDs"
        } +
	cgi.p {
          "See the BioFetch specification for more details. "
        } +
        cgi.h2 {
          "Examples"
        } +
        cgi.dl {
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=refseq-today;id=NC_000844') { "rs:NC_000844" } + " (default/raw)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=refseq-today;id=NC_000844" +
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=fasta;style=raw;db=refseq-today;id=NC_000844') { "rs:NC_000844" } + " (fasta/raw)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=fasta;style=raw;db=refseq-today;id=NC_000844" +
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=html;db=refseq-today;id=NC_000844') { "rs:NC_000844" } + " (default/html)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=html;db=refseq-today;id=NC_000844" +
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=refseq-today;id=NC_000844,NC_000846') { "rs:NC_000844,NC_000846" } + " (default/raw, multiple)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=refseq-today;id=NC_000844,NC_000846" +
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=embl-today;id=BUM') { "embl:BUM" } + " (default/raw)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=embl-today;id=BUM" +
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=swissprot-today;id=CYC_BOVIN') { "sp:CYC_BOVIN" } + " (default/raw)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=swissprot-today;id=CYC_BOVIN" +
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=fasta;style=raw;db=swissprot-today;id=CYC_BOVIN') { "sp:CYC_BOVIN" } + " (fasta/raw)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=fasta;style=raw;db=swissprot-today;id=CYC_BOVIN" +
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=genes;id=b0015') { "genes:b0015" } + " (default/raw)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=genes;id=b0015" +
          cgi.dt + cgi.a('href'=>'http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=prosite;id=PS00028') { "ps:PS00028" } + " (default/raw)" +
          cgi.dd + "http://bioruby.org/cgi-bin/biofetch.rb?format=default;style=raw;db=prosite;id=PS00028"
#         cgi.dt + cgi.a('href'=>'') { "" } +
#         cgi.dd + ""
        } +
        cgi.h2 {
          "Other BioFetch implementations"
        } +
        cgi.a('href'=>'http://www.ebi.ac.uk/cgi-bin/dbfetch') {
          "dbfetch at EBI"
        } +
        cgi.hr +
        cgi.div('align'=>'right') {
          cgi.a('href'=>'http://bioruby.org') {
            cgi.img('border'=>'0', 'src'=>'http://bioruby.org/button/1.gif')
          }
        }
      end
    end
  end
end



def print_result_page(cgi)

  db = cgi['db'].first.downcase
  id = cgi['id'].first.split(/\W/)		# not only ','
  style = cgi['style'].first
  format = cgi['format'].first

  if id.length > MAX_ID_NUM
    error_5(id.length)
  end

  case style
  when /html/i
    id = id.join('%2B')
    print "Location: http://genome.jp/dbget-bin/www_bget?#{db}+#{id}\n\n"
    exit
  when /raw/i
    ;
  else
    error_2(style)
  end

  case format
  when /fasta/i
    format = '-f'
  when /default/i
    format = ''
  when nil
    ;
  else
    error_3(format, db)
  end


  entry = ''

  id.each do |query_id|
    begin
      result = Bio::DBGET.bget("#{db} #{query_id} #{format}")
    rescue
      error_4(query_id, db)
    end

    if result =~ /No such entry/
      error_4(query_id, db)
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
  print "Content-type: text/plain; charset=UTF-8\n\n"
  puts str
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

def error_3(format, db)
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
  cgi = CGI.new('html3')
  if cgi['id'].empty?
    print_query_page(cgi)
  else
    print_result_page(cgi)
  end
end


=begin

This program is created during BioHackathon 2002, Tucson and updated
in Cape Town :)

You can not run this CGI program without having internally accessible
DBGET server.

=end



