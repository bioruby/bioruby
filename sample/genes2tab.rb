#!/usr/bin/env ruby
#
# genes2tab.rb - convert KEGG/GENES into tab delimited data for MySQL
#
#  Usage:
#
#    % genes2tab.rb /bio/db/kegg/genes/e.coli > genes_eco.tab
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
#  $Id: genes2tab.rb,v 0.5 2002/06/23 20:21:56 k Exp $
#

require 'bio/db/kegg/genes'

include Bio

while entry = gets(KEGG::GENES::DELIMITER)

  genes = KEGG::GENES.new(entry)

  db = genes.dblinks.inspect

  if genes.codon_usage.length == 64
    cu = genes.codon_usage.join(' ')
  else
    cu = '\N'
  end

  ary = [
    genes.entry_id,
    genes.division,
    genes.organism,
    genes.name,
    genes.definition,
    genes.keggclass,
    genes.position,
    db,
    cu,
    genes.aalen,
    genes.aaseq,
    genes.nalen,
    genes.naseq
  ]

  puts ary.join("\t")

end

=begin

CREATE DATABASE IF NOT EXISTS db_name;
CREATE TABLE IF NOT EXISTS db_name.genes (
	id		varchar(30)	not NULL,	# ENTRY ID
	division	varchar(30),			# CDS, tRNA etc.
	organism	varchar(255),
	gene		varchar(255),
	definition	varchar(255),
	keggclass	varchar(255),
	position	varchar(255),
	dblinks		varchar(255),
	codon_usage	text,
	aalen		integer,
	aaseq		text,
	nalen		integer,
	naseq		text
);
LOAD DATA LOCAL INFILE 'genes.tab' INTO TABLE db_name.genes;

=end

