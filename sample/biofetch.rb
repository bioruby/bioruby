#!/usr/local/bin/ruby

# Copyright 2002 (c) Katayama Toshiaki <k@bioruby.org> during BioHackathon :)

# TODO:
#   Error codes

require 'bio'
require 'cgi-lib'


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
          "This page allows you to retrieve up to 50 entries at the time from various up-to-date biological databases."
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


def print_not_found(query_id)
  CGI::print {
    "#{query_id} not found"
  }
end

def print_too_many(num)
  CGI::print {
    "You wants too many at once (#{num} > 50)"
  }
end


def print_result_page(query)

  db = query['db'].downcase
# id = query['id'].split(',')
  id = query['id'].split(/\W/)

  if id.length > 50
    print_too_many(id.length)
    return
  end

  if query['style'] =~ /html/
    id = id.join('%2B')
    print "Location: http://genome.jp/dbget-bin/www_bget?#{db}+#{id}\n\n"
    return
  end

  format = /fasta/i.match(query['format']) ? "-f" : ""

  entry = ""

  id.each do |query_id|
    begin
      result = Bio::DBGET.bget("#{db} #{query_id} #{format}")
    rescue
      print_not_found(query_id)
      return
    end
    entry += result
  end

  print "Content-type: text/plain; charset=UTF-8\n\n"
  puts entry

end


begin
  query = CGI.new
  if query['id'].nil?
    print_query_page
  else
    print_result_page(query)
  end
end


