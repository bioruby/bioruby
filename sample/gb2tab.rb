#!/usr/bin/env ruby
#
# gb2tab.rb - convert GenBank into tab delimited data for MySQL
#
#  Usage:
#
#    % gb2tab.rb gb*.seq
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: gb2tab.rb,v 0.6 2002/03/25 19:46:00 okuji Exp $
#

require 'bio/db/genbank'

include Bio

ARGV.each do |seqfile|

  seq  = open("#{seqfile}")
  body = open("#{seqfile}.tab", "w")
  ft   = open("#{seqfile}.ft.tab", "w")
  ref  = open("#{seqfile}.ref.tab", "w")
  
  while entry = seq.gets(GenBank::DELIMITER)
  
    gb = GenBank.new(entry)
  
    ### MAIN BODY
  
    kw = gb.keywords.inspect
    seg = gb.segment.inspect
    bc = gb.basecount.inspect
  
    ary = [
      gb.id,
      gb.nalen,
      gb.strand,
      gb.natype,
      gb.circular,
      gb.division,
      gb.date,
      gb.definition,
      gb.accession,
      gb.acc_version,
      gb.gi,
  #   gb.nid,
      kw,
      seg,
      gb.common_name,
      gb.organism,
      gb.taxonomy,
      gb.comment,
      bc,
      gb.origin,
      gb.naseq,
    ]
  
    body.puts ary.join("\t")
  
    ### FEATURES
  
    num = 0
  
    gb.features do |f|
      num += 1
  
      f.each do |qualifier, value|

	if qualifier == 'db_xref'
	  value = f['db_xref'].inspect
	end
  
	ary = [
	  gb.id,
	  num,
	  qualifier,
	  value,
	]
	ft.puts ary.join("\t")
      end
  
    end

    ### REFERENCE
  
    gb.reference do |r|
  
      ary = [
	gb.id,
	r['REFERENCE'],
	r['AUTHORS'],
	r['TITLE'],
	r['JOURNAL'],
	r['MEDLINE'],
	r['PUBMED'],
	r['REMARK'],
      ]
  
      ref.puts ary.join("\t")
    end
  
  end

  seq.close
  body.close
  ft.close
  ref.close

end

=begin

Example usage in zsh:

  % gb2tab.rb *.seq
  % for i in *.seq
  > do
  >   base=`basename $i .seq`
  >   ruby -pe "$_.gsub!(/_HOGE_/,'$base')" gb2tab.sql | mysql
  > done

gb2tab.sql:

CREATE DATABASE IF NOT EXISTS genbank;
CREATE TABLE IF NOT EXISTS genbank._HOGE_ (
	id		varchar(16)	NOT NULL PRIMARY KEY,
	nalen		integer,
	strand		varchar(5),
	natype		varchar(5),
	circular	varchar(10),
	division	varchar(5),
	date		varchar(10),
	definition	varchar(255),
	accession	varchar(30),
	acc_version	varchar(30),
	gi		varchar(30),
	keywords	varchar(255),
	segment		varchar(255),
	source		varchar(255),
	organism	varchar(255),
	taxonomy	varchar(255),
	comment		text,
	basecount	varchar(255),
	origin		varchar(255),
	naseq		mediumtext,
	INDEX idx (organism)
);
LOAD DATA LOCAL INFILE '_HOGE_.seq.tab' INTO TABLE genbank._HOGE_;

CREATE TABLE IF NOT EXISTS genbank._HOGE_ft (
	id		varchar(16)	NOT NULL,
	num		integer,
	qualifier	varchar(30),
	value		text,
	INDEX idx (id)
);
LOAD DATA LOCAL INFILE '_HOGE_.seq.ft.tab' INTO TABLE genbank._HOGE_ft;

CREATE TABLE IF NOT EXISTS genbank._HOGE_ref (
	id		varchar(16)	NOT NULL,
	reference	varchar(255),
	authors		text,
	title		text,
	journal		text,
	medline		varchar(255),
	pubmed		varchar(255),
	remark		varchar(255),
	INDEX idx (id, medline)
);
LOAD DATA LOCAL INFILE '_HOGE_.seq.ref.tab' INTO TABLE genbank._HOGE_ref;


gbmerge.sql sample:

CREATE TABLE IF NOT EXISTS genbank.gb (
	id		varchar(16)	NOT NULL PRIMARY KEY,
	nalen		integer,
	strand		varchar(5),
	natype		varchar(5),
	circular	varchar(10),
	division	varchar(5),
	date		varchar(10),
	definition	varchar(255),
	accession	varchar(30),
	acc_version	varchar(30),
	gi		varchar(30),
	keywords	varchar(255),
	segment		varchar(255),
	source		varchar(255),
	organism	varchar(255),
	taxonomy	varchar(255),
	comment		text,
	basecount	varchar(255),
	origin		varchar(255),
	naseq		mediumtext
) TYPE=MERGE UNION=(
	gbbct1,
	gbbct2,
	...,		# list up all tables
	gbvrt
);

CREATE TABLE IF NOT EXISTS genbank.gbft (
	id		varchar(16)	NOT NULL,
	num		integer,
	qualifier	varchar(30),
	value		text,
	INDEX idx (id)
) TYPE=MERGE UNION=(
	gbbct1ft,
	gbbct2ft,
	...,		# list up all ft tables
	gbvrtft
);

CREATE TABLE IF NOT EXISTS genbank.gbref (
	id		varchar(16)	NOT NULL,
	reference	varchar(255),
	authors		text,
	title		text,
	journal		text,
	medline		varchar(255),
	pubmed		varchar(255),
	remark		varchar(255),
	INDEX idx (id, medline)
) TYPE=MERGE UNION=(
	gbbct1ref,
	gbbct2ref,
	...,		# list up all ref tables
	gbvrtref
);

=end

