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
#  $Id: gb2tab.rb,v 0.11 2002/04/22 09:10:10 k Exp $
#

require 'bio'

$stderr.puts Time.now

ARGV.each do |gbkfile|

  gbk = open("#{gbkfile}")
  ent = open("#{gbkfile}.ent.tab", "w")
  ft  = open("#{gbkfile}.ft.tab", "w")
  ref = open("#{gbkfile}.ref.tab", "w")
  seq = open("#{gbkfile}.seq.tab", "w")
  
  while entry = gbk.gets(Bio::GenBank::DELIMITER)
  
    gb = Bio::GenBank.new(entry)
  
    ### MAIN BODY

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
      gb.versions.inspect,
      gb.keywords.inspect,
      gb.segment.inspect,
      gb.common_name,
      gb.organism,
      gb.taxonomy,
      gb.comment,
      gb.basecount.inspect,
      gb.origin,
    ]
  
    ent.puts ary.join("\t")
  
    ### FEATURES
  
    num = 0
  
    gb.features.each do |f|
      num += 1

      span_min, span_max = f.locations.span

      if f.qualifiers.empty?
	ary = [
	    gb.entry_id,
	    num,
	    f.feature,
	    f.position,
	    span_min,
	    span_max,
	    '',
	    '',
	]
	ft.puts ary.join("\t")
      else
	f.each do |q|
	  ary = [
	    gb.entry_id,
	    num,
	    f.feature,
	    f.position,
	    span_min,
	    span_max,
	    q.qualifier,
	    q.value,
	  ]
	  ft.puts ary.join("\t")
	end
      end

    end

    ### REFERENCE
  
    num = 0

    gb.references.each do |r|
      num += 1
  
      ary = [
	gb.entry_id,
	num,
	r.authors.inspect,
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
  ent.close
  ft.close
  ref.close
  seq.close

end

$stderr.puts Time.now

=begin

Example usage in zsh:

  % gb2tab.rb *.seq
  % for i in *.seq
  > do
  >   base=`basename $i .seq`
  >   ruby -pe "gsub(/%HOGE%/,'$base')" gb2tab.sql | mysql
  > done

gb2tab.sql:

CREATE DATABASE IF NOT EXISTS genbank;
USE genbank;

CREATE TABLE IF NOT EXISTS %HOGE% (
	id		varchar(16)	NOT NULL PRIMARY KEY,
	nalen		integer,
	strand		varchar(5),
	natype		varchar(5),
	circular	varchar(10),
	division	varchar(5),
	date		varchar(12),
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
	KEY (nalen),
	KEY (division),
	KEY (accession),
	KEY (organism),
	KEY (taxonomy)
);
LOAD DATA LOCAL INFILE '%HOGE%.seq.ent.tab' INTO TABLE %HOGE%;

CREATE TABLE IF NOT EXISTS %HOGE%ft (
	id		varchar(16)	NOT NULL,
	num		integer,
	feature		varchar(30),
	position	text,
	span_min	integer,
	span_max	integer,
	qualifier	varchar(30),
	value		text,
	KEY (id),
	KEY (num),
	KEY (feature),
	KEY (span_min),
	KEY (span_max),
	KEY (qualifier)
);
LOAD DATA LOCAL INFILE '%HOGE%.seq.ft.tab' INTO TABLE %HOGE%ft;

CREATE TABLE IF NOT EXISTS %HOGE%ref (
	id		varchar(16)	NOT NULL,
	num		integer,
	authors		text,
	title		text,
	journal		text,
	medline		varchar(255),
	pubmed		varchar(255),
	KEY (id),
	KEY (medline),
	KEY (pubmed)
);
LOAD DATA LOCAL INFILE '%HOGE%.seq.ref.tab' INTO TABLE %HOGE%ref;

CREATE TABLE IF NOT EXISTS %HOGE%seq (
	id		varchar(16)	NOT NULL,
	num		integer,
	naseq		mediumtext,
	KEY (id)
);
LOAD DATA LOCAL INFILE '%HOGE%.seq.seq.tab' INTO TABLE %HOGE%seq;


gbmerge.sql sample:

CREATE TABLE IF NOT EXISTS ent (
	id		varchar(16)	NOT NULL PRIMARY KEY,
	nalen		integer,
	strand		varchar(5),
	natype		varchar(5),
	circular	varchar(10),
	division	varchar(5),
	date		varchar(12),
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
	KEY (nalen),
	KEY (division),
	KEY (accession),
	KEY (organism),
	KEY (taxonomy)
) TYPE=MERGE UNION=(
	gbbct1,
	gbbct2,
	...,		# list up all tables by yourself
	gbvrt
);

CREATE TABLE IF NOT EXISTS ft (
	id		varchar(16)	NOT NULL,
	num		integer,
	feature		varchar(30),
	position	text,
	span_min	integer,
	span_max	integer,
	qualifier	varchar(30),
	value		text,
	KEY (id),
	KEY (num),
	KEY (feature),
	KEY (span_min),
	KEY (span_max),
	KEY (qualifier)
) TYPE=MERGE UNION=(
	gbbct1ft,
	gbbct2ft,
	...,		# list up all ft tables by yourself
	gbvrtft
);

CREATE TABLE IF NOT EXISTS ref (
	id		varchar(16)	NOT NULL,
	num		integer,
	authors		text,
	title		text,
	journal		text,
	medline		varchar(255),
	pubmed		varchar(255),
	KEY (id),
	KEY (medline),
	KEY (pubmed)
) TYPE=MERGE UNION=(
	gbbct1ref,
	gbbct2ref,
	...,		# list up all ref tables by yourself
	gbvrtref
);

CREATE TABLE IF NOT EXISTS seq (
	id		varchar(16)	NOT NULL,
	num		integer,
	naseq		mediumtext,
	KEY (id)
) TYPE=MERGE UNION=(
	gbbct1seq,
	gbbct2seq,
	...,		# list up all seq tables by yourself
	gbvrtseq
);

=end

