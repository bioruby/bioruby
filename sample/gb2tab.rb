#!/usr/bin/env ruby
#
# gb2tab.rb - convert GenBank into tab delimited data for MySQL
#
#  Usage:
#
#    % gb2tab.rb gb*.seq > gb.tab
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
#  $Id: gb2tab.rb,v 0.1 2001/06/21 08:23:18 katayama Exp $
#

require 'bio/db/genbank'

while entry = gets(GenBank::DELIMITER)

  gb = GenBank.new(entry)

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

  puts ary.join("\t")

end

=begin

CREATE DATABASE IF NOT EXISTS db_name;
CREATE TABLE IF NOT EXISTS db_name.gb (
	id		varchar(30)	not NULL,
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
	naseq		text
);
LOAD DATA LOCAL INFILE 'gb.tab' INTO TABLE db_name.gb;

=end

