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
#  $Id: gb2tab.rb,v 0.7 2002/03/27 05:46:14 katayama Exp $
#

require 'bio'

include Bio

ARGV.each do |gbkfile|

  gbk  = open("#{gbkfile}")
  body = open("#{gbkfile}.tab", "w")
  ft   = open("#{gbkfile}.ft.tab", "w")
  ref  = open("#{gbkfile}.ref.tab", "w")
  seq  = open("#{gbkfile}.seq.tab", "w")
  
  while entry = gbk.gets(GenBank::DELIMITER)
  
    gb = GenBank.new(entry)
  
    ### MAIN BODY

    versions = gb.versions.inspect
    kw = gb.keywords.inspect
    seg = gb.segment.inspect
    bc = gb.basecount.inspect
  
    ary = [
      gb.entry_id,
      gb.nalen,
      gb.strand,
      gb.natype,
      gb.circular,
      gb.division,
      gb.date,
      gb.definition,
      gb.accession,
      versions,
      kw,
      seg,
      gb.common_name,
      gb.organism,
      gb.taxonomy,
      gb.comment,
      bc,
      gb.origin,
    ]
  
    body.puts ary.join("\t")
  
    ### FEATURES
  
    num = 0
  
    gb.features.each do |f|
      num += 1
  
      f.each do |q|
	ary = [
	  gb.entry_id,
	  num,
	  q.type,
	  q.value,
	]
	ft.puts ary.join("\t")
      end
  
    end

    ### REFERENCE
  
    num = 0

    gb.references.each do |r|
      num += 1
  
      ary = [
	gb.entry_id,
	num,
	r.authors,
	r.title,
	r.journal,
	r.medline,
	r.pubmed,
      ]
  
      ref.puts ary.join("\t")
    end

    ### SEQUENCE

    maxlen = 16 * 10 ** 6

    num = 0

    0.step(gb.nalen, maxlen) do |i|
      num += 1

      ary = [
	gb.entry_id,
	num,
	gb.naseq[i, maxlen]
      ]

      seq.puts ary.join("\t")

    end

  end

  gbk.close
  body.close
  ft.close
  ref.close
  seq.close

end

=begin

Example usage in zsh:

  % gb2tab.rb *.gbk
  % for i in *.gbk
  > do
  >   base=`basename $i .gbk`
  >   ruby -pe "gsub(/_HOGE_/,'$base')" gb2tab.sql | mysql
  > done

gb2tab.sql:

CREATE DATABASE IF NOT EXISTS genbank;
USE genbank;

CREATE TABLE IF NOT EXISTS _HOGE_ (
	id		varchar(16)	NOT NULL PRIMARY KEY,
	nalen		integer,
	strand		varchar(5),
	natype		varchar(5),
	circular	varchar(10),
	division	varchar(5),
	date		varchar(10),
	definition	varchar(255),
	accession	varchar(30),
	versions	varchar(30),
	keywords	varchar(255),
	segment		varchar(255),
	source		varchar(255),
	organism	varchar(255),
	taxonomy	varchar(255),
	comment		text,
	basecount	varchar(255),
	origin		varchar(255),
	KEY (division),
	KEY (accession),
	KEY (organism)
);
LOAD DATA LOCAL INFILE '_HOGE_.gbk.tab' INTO TABLE _HOGE_;

CREATE TABLE IF NOT EXISTS _HOGE_ft (
	id		varchar(16)	NOT NULL,
	num		integer,
	qualifier	varchar(30),
	value		text,
	KEY (id)
);
LOAD DATA LOCAL INFILE '_HOGE_.gbk.ft.tab' INTO TABLE _HOGE_ft;

CREATE TABLE IF NOT EXISTS _HOGE_ref (
	id		varchar(16)	NOT NULL,
	num		integer,
	authors		text,
	title		text,
	journal		text,
	medline		varchar(255),
	pubmed		varchar(255),
	KEY (id),
	KEY (medline)
);
LOAD DATA LOCAL INFILE '_HOGE_.gbk.ref.tab' INTO TABLE _HOGE_ref;

CREATE TABLE IF NOT EXISTS _HOGE_seq (
	id		varchar(16)	NOT NULL,
	num		integer,
	naseq		mediumtext,
	KEY (id)
);
LOAD DATA LOCAL INFILE '_HOGE_.gbk.seq.tab' INTO TABLE _HOGE_seq;


gbmerge.sql sample:

CREATE TABLE IF NOT EXISTS gb (
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

CREATE TABLE IF NOT EXISTS gbft (
	id		varchar(16)	NOT NULL,
	num		integer,
	qualifier	varchar(30),
	value		text,
	KEY (id)
) TYPE=MERGE UNION=(
	gbbct1ft,
	gbbct2ft,
	...,		# list up all ft tables
	gbvrtft
);

CREATE TABLE IF NOT EXISTS gbref (
	id		varchar(16)	NOT NULL,
	reference	varchar(255),
	authors		text,
	title		text,
	journal		text,
	medline		varchar(255),
	pubmed		varchar(255),
	KEY (id),
	KEY (medline)
) TYPE=MERGE UNION=(
	gbbct1ref,
	gbbct2ref,
	...,		# list up all ref tables
	gbvrtref
);

=end

