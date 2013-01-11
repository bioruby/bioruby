#!/usr/bin/env ruby
# coding: utf-8
#
# biofetch.rb : BioFetch server (interface to TogoWS)
#
#   Copyright (C) 2002-2004 KATAYAMA Toshiaki <k@bioruby.org>
#                 2013      GOTO Naohisa <ng@bioruby.org>
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
#

require 'cgi'
require 'erb'
require 'open-uri'
require 'fileutils'
require 'tempfile'

MAX_ID_NUM = 50

# script name
SCRIPT_NAME = File.basename(__FILE__)

# full URL for this CGI
BASE_URL = "http://bioruby.org/cgi-bin/#{SCRIPT_NAME}"

# cache directory for metadata
# Note: The cache is only for metadata (database list and format list).
# Data entries are NOT cached.
CACHE_DIR = '/tmp/biofetch_rb.cache'

# cache lifetime
CACHE_LIFETIME = 60 * 60 # 1 hour

module TogoWS
  TOGOWS_URL = 'http://togows.dbcls.jp/'

  def togows_database_complete_list
    result = togows_get_cached('/entry/')
    result.to_s.split(/\n/).collect {|x| x.split(/\t/) }
  end

  def togows_database_formats(db)
    db = CGI.escape(db)
    result = togows_get_cached("/entry/#{db}/?formats")
  end

  def togows_get(path)
    uristr = TOGOWS_URL + path
    begin
      result = OpenURI.open_uri(uristr).read
    rescue OpenURI::HTTPError
      result = nil
    end
    result
  end

  private

  def togows_get_cached(path)
    filepath = path.sub(/\A\//, '').sub(/\/\z/, '')
    filepath = filepath.gsub(/\//, " ")
    filepath = filepath.sub(/\?/, '_')
    filepath = File.join(CACHE_DIR, filepath)
    result = nil
    begin
      if Time.now - File.mtime(filepath) > CACHE_LIFETIME
        # delete expired cache file
        File.delete(filepath)
      end
      result = File.read(filepath)
    rescue IOError, SystemCallError
      result = nil
    end
    unless result then
      # valid cache is not found
      result = togows_get(path)
      if result then
        # create cache directory if not found
        FileUtils.mkdir_p(CACHE_DIR, :mode => 0700)
        # simple security check for the cache dir
        if File.stat(CACHE_DIR).mode & 0022 != 0 then
          raise SecurityError, "CACHE_DIR #{CACHE_DIR} is writeable by others"
        end

        # write to temporary file
        tmp = Tempfile.open('temp', CACHE_DIR)
        tmp.print result
        tmp.close
        # create a hard link from the temporary to the cache file
        begin
          File.link(tmp.path, filepath)
        rescue IOError, SystemCallError
        end
        # the temporay file will be automatically removed at exit
      end
    end
    result
  end

end #module TogoWS

module BioFetchError

  def print_text_page(str)
    print "Content-type: text/plain; charset=UTF-8\n\n"
    puts str
    exit
  end

  def print_html_page(str)
    print "Content-type: text/html; charset=UTF-8\n\n"
    print "<pre>", CGI.escapeHTML(str), "</pre>\n"
    exit
  end

  def error1(db)
    db = CGI.escapeHTML(db.to_s) # to avoid potential XSS with old IE
    str = "ERROR 1 Unknown database [#{db}]."
    print_text_page(str)
  end

  def error2(style)
    style = CGI.escapeHTML(style.to_s) # to avoid potential XSS with old IE
    str = "ERROR 2 Unknown style [#{style}]."
    print_text_page(str)
  end

  def error3(format, db)
    # to avoid potential XSS with old IE which ignores Content-Type
    db = CGI.escapeHTML(db.to_s)
    format = CGI.escapeHTML(format.to_s)
    str = "ERROR 3 Format [#{format}] not known for database [#{db}]."
    print_text_page(str)
  end

  def error4(entry_id, db)
    # to avoid potential XSS with old IE which ignores Content-Type
    entry_id = CGI.escapeHTML(entry_id.to_s)
    db = CGI.escapeHTML(db.to_s)
    str = "ERROR 4 ID [#{entry_id}] not found in database [#{db}]."
    print_text_page(str)
  end

  def error5(count)
    # to avoid potential XSS with old IE which ignores Content-Type
    count = CGI.escapeHTML(count.to_s)
    str = "ERROR 5 Too many IDs [#{count}]. Max [#{MAX_ID_NUM}] allowed."
    print_text_page(str)
  end

  def error6(info)
    # to avoid potential XSS with old IE which ignores Content-Type
    count = CGI.escapeHTML(info.to_s)
    str = "ERROR 6 Illegal information request [#{info}]."
    print_text_page(str)
  end

end



module ApiBridge

  include BioFetchError
  include TogoWS

  def list_databases_with_synonyms
    togows_database_complete_list
  end

  def list_databases
    list_databases_with_synonyms.flatten
  end

  def bget(db, id_list, format)
    case format
    when 'fasta'
      format = '.fasta'
    else
      format = ''
    end
    db = CGI.escape(db)
    
    results = ''
    id_list.each do |query_id|
      query_id = CGI.escape(query_id)
      path = "/entry/#{db}/#{query_id}#{format}"
      result = togows_get(path)

      if !result or result.empty? or /\AError\: / =~ result then
        error4(query_id, db)
      else
        results << result
      end
    end
    return results
  end

  def check_fasta_ok?(db)
    result = togows_database_formats(db)
    /^fasta$/ =~ result.to_s
  end

end #module ApiBridge

module BioFetchCheck

  include ApiBridge

  private

  def check_style(style)
    style = style.to_s.downcase
    error2(style) unless /\A(html|raw)\z/.match(style)
    style
  end

  def check_format(format, db)
    fmt = format ? format.to_s.downcase : nil
    case fmt
    when 'fasta'
      db = check_dbname(db)
      fmt = nil unless check_fasta_ok?(db)
    when 'default'
      # do nothing
    when nil
      fmt = 'default'
    else
      fmt = nil
    end

    error3(format, db) unless fmt
    fmt
  end

  def check_number_of_id(num)
    error5(num) if num > MAX_ID_NUM
  end

  def check_dbname(db)
    db = db.to_s.downcase
    error1(db) unless list_databases.include?(db)
    db
  end

end #module BioFetchCheck

class BioFetch

  include BioFetchCheck
  include BioFetchError
  include ApiBridge

  def initialize(db, id_list, style, format)
    style = check_style(style)
    format = check_format(format, db)
    check_number_of_id(id_list.length)
    db = check_dbname(db)

    entries = bget(db, id_list, format)

    if style == 'html' then
      print_html_page(entries)
    else
      print_text_page(entries)
    end

  end

end #class BioFetch



class BioFetchInfo

  include BioFetchCheck
  include BioFetchError
  include ApiBridge

  def initialize(info, db)
    @db = db

    begin
      check_info(info) ? __send__(info) : raise
    rescue
      error6(info)
    end
  end

  private

  def check_info(meth_name)
    /\A(dbs|formats|maxids)\z/ =~ meth_name
  end

  def dbs
    str = list_databases.sort.join(' ')
    print_text_page(str)
  end

  def formats
    db = check_dbname(@db)
    fasta = " fasta" if check_fasta_ok?(db)
    str = "default#{fasta}"
    print_text_page(str)
  end

  def maxids
    str = MAX_ID_NUM.to_s
    print_text_page(str)
  end

end #class BioFetchInfo



class BioFetchCGI

  include ApiBridge

  def initialize(cgi)
    @cgi = cgi
    show_page
  end

  private

  def show_page
    if info.empty?
      if id_list.empty?
        show_query_page
      else
        show_result_page(db, id_list, style, format)
      end
    else
      show_info_page(info, db)
    end
  end

  def show_query_page
    html = ERB.new(DATA.read)
    max_id_num = MAX_ID_NUM
    databases_with_synonyms = list_databases_with_synonyms
    databases = list_databases
    script_name = SCRIPT_NAME
    base_url = BASE_URL
    @cgi.out({ "type" => "text/html", "charset" => "utf-8" }) do
      html.result(binding)
    end
  end

  def show_result_page(db, id_list, style, format)
    BioFetch.new(db, id_list, style, format)
  end

  def show_info_page(info, db)
    BioFetchInfo.new(info, db)
  end

  def info
    @cgi['info'].downcase
  end

  def db
    @cgi['db'].downcase
  end

  def id_list
    @cgi['id'].strip.split(/[\,\s]+/)
  end

  def style
    s = @cgi['style'].downcase
    return s.empty? ? "html" : s
  end

  def format
    f = @cgi['format'].downcase
    return f.empty? ? "default" : f
  end

end



BioFetchCGI.new(CGI.new)



=begin

This program was created during BioHackathon 2002, Tucson and updated
in Cape Town :)

Rewrited in 2013 to use TogoWS API as the bioruby.org server left from The
University of Tokyo and the old SOAP-based KEGG API is discontinued.

=end


__END__

<HTML>
<HEAD>
  <LINK href="http://bioruby.org/img/favicon.png" rel="icon" type="image/png">
  <LINK href="http://bioruby.org/css/bioruby.css" rel="stylesheet" type="text/css">
  <TITLE>BioFetch interface to TogoWS</TITLE>
</HEAD>

<BODY bgcolor="#ffffff">

<H1>
<IMG src="http://bioruby.org/img/ruby.png" align="middle">
BioFetch interface to
<A href="http://togows.dbcls.jp/">TogoWS</A>
</H1>

<P>This page allows you to retrieve up to <%= max_id_num %> entries at a time from various up-to-date biological databases.</P>

<HR>

<FORM METHOD="post" ENCTYPE="application/x-www-form-urlencoded" action="<%= script_name %>">

<SELECT name="db">
<% databases_with_synonyms.each do |dbs|
     a = dbs[1..-1]
     synonyms = unless a.empty? then
                  " (abbr: " + a.join(", ") + ")"
                else
                  ""
                end
%>
<OPTION value="<%= dbs[0] %>"><%= dbs[0] %><%= synonyms %></OPTION>
<% end %>
</SELECT>

<INPUT name="id" size="40" type="text" maxlength="1000">

<SELECT name="format">
<OPTION value="default">Default</OPTION>
<OPTION value="fasta">Fasta</OPTION>
</SELECT>

<SELECT name="style">
<OPTION value="raw">Raw</OPTION>
<OPTION value="html">HTML</OPTION>
</SELECT>

<INPUT type="submit">

</FORM>

<HR>

<H2>Direct access</H2>

<P><%= base_url %>?format=(default|fasta|...);style=(html|raw);db=(nuccore|embl|...);id=ID[,ID,ID,...]</P>
<P>(NOTE: the option separator ';' can be '&')</P>

<DL>
  <DT> <U>format</U> (optional)
  <DD> default|fasta|...

  <DT> <U>style</U> (required)
  <DD> html|raw

  <DT> <U>db</U> (required)
  <DD> <%= databases.join('|') %>

  <DT> <U>id</U> (required)
  <DD> comma separated list of IDs
</DL>

<P>See the <A href="http://obda.open-bio.org/">BioFetch specification</A> for more details.</P>

<H2>Server informations</H2>

<DL>
  <DT> <A href="?info=dbs">What databases are available?</A>
  <DD> <%= base_url %>?info=dbs

  <DT> <A href="?info=formats;db=embl">What formats does the database X have?</A>
  <DD> <%= base_url %>?info=formats;db=embl

  <DT> <A href="?info=maxids">How many entries can be retrieved simultaneously?</A>
  <DD> <%= base_url %>?info=maxids
</DL>

<H2>Examples</H2>

<DL>
  <DT> <A href="?format=default;style=raw;db=nuccore;id=AJ617376">nuccore/AJ617376</A> (default/raw)
  <DD> <%= base_url %>?format=default;style=raw;db=nuccore;id=AJ617376

  <DT> <A href="?format=fasta;style=raw;db=nuccore;id=AJ617376">nuccore/AJ617376</A> (fasta/raw)
  <DD> <%= base_url %>?format=fasta;style=raw;db=nuccore;id=AJ617376

  <DT> <A href="?format=default;style=html;db=nuccore;id=AJ617376">nuccore/AJ617376</A> (default/html)
  <DD> <%= base_url %>?format=default;style=html;db=nuccore;id=AJ617376

  <DT> <A href="?format=default;style=raw;db=nuccore;id=AJ617376,AJ617377">nuccore/AJ617376,AJ617377</A> (default/raw, multiple)
  <DD> <%= base_url %>?format=default;style=raw;db=nuccore;id=AJ617376,AJ617377

  <DT> <A href="?format=default;style=raw;db=embl;id=J00231">embl/J00231</A> (default/raw)
  <DD> <%= base_url %>?format=default;style=raw;db=embl;id=J00231

  <DT> <A href="?format=default;style=raw;db=uniprot;id=CYC_BOVIN">uniprot/CYC_BOVIN</A> (default/raw)
  <DD> <%= base_url %>?format=default;style=raw;db=uniprot;id=CYC_BOVIN

  <DT> <A href="?format=fasta;style=raw;db=uniprot;id=CYC_BOVIN">uniprot/CYC_BOVIN</A> (fasta/raw)
  <DD> <%= base_url %>?format=fasta;style=raw;db=uniprot;id=CYC_BOVIN

  <DT> <A href="?format=default;style=raw;db=genes;id=eco%3Ab0015">genes/eco:b0015</A> (default/raw)
  <DD> <%= base_url %>?format=default;style=raw;db=genes;id=eco%3Ab0015
  <DD> <%= base_url %>?format=default;style=raw;db=genes;id=eco:b0015

</DL>

<H2>Errors</H2>

<DL>
  <DT> <A href="?format=default;style=raw;db=nonexistent;id=AJ617376">Error1</A> sample : DB not found
  <DD> <%= base_url %>?format=default;style=raw;db=nonexistent;id=AJ617376

  <DT> <A href="?format=default;style=nonexistent;db=nuccore;id=AJ617376">Error2</A> sample : unknown style
  <DD> <%= base_url %>?format=default;style=nonexistent;db=nuccore;id=AJ617376

  <DT> <A href="?format=nonexistent;style=raw;db=nuccore;id=AJ617376">Error3</A> sample : unknown format
  <DD> <%= base_url %>?format=nonexistent;style=raw;db=nuccore;id=AJ617376

  <DT> <A href="?format=default;style=raw;db=nuccore;id=nonexistent">Error4</A> sample : ID not found
  <DD> <%= base_url %>?format=default;style=raw;db=nuccore;id=nonexistent

  <DT> <A href="?style=raw;db=genes;id=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51">Error5</A> sample : too many IDs
  <DD> <%= base_url %>?style=raw;db=genes;id=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51

  <DT> <A href="?info=nonexistent">Error6</A> sample : unknown info
  <DD> <%= base_url %>?info=nonexistent"
</DL>

<H2>Other BioFetch implementations</H2>

<UL>
  <LI> <A href="http://www.ebi.ac.uk/cgi-bin/dbfetch">dbfetch at EBI</A>
</UL>

<HR>

<DIV align=right>
<I>
staff@Bio<span class="ruby">Ruby</span>.org
</I>
<BR>
<BR>
<A href="http://bioruby.org/"><IMG border=0 src="/img/banner.gif"></A>
</DIV>

</BODY>
</HTML>
