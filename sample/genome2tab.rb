#!/usr/bin/env ruby
#
# genome2tab.rb - convert KEGG/GENOME into tab delimited data for MySQL
#
#  Usage:
#
#    % genome2tab.rb /bio/db/kegg/genome/genome > genome.tab
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
#  $Id: genome2tab.rb,v 0.1 2001/06/21 08:25:20 katayama Exp $
#

require 'bio/db/kegg/genome'

while entry = gets(GENOME::DELIMITER)

  genome = GENOME.new(entry)

  ref = genome.reference.inspect
  chr = genome.chromosome.inspect

  ary = [
    genome.id,
    genome.name,
    genome.definition,
    genome.taxid,
    genome.taxonomy,
    genome.morphology,
    genome.physiology,
    genome.environment,
    ref,
    chr,
    genome.nalen,
    genome.num_gene,
    genome.num_rna,
    genome.gc,
    genome.genomemap,
    genome.genecatalog,
  ]

  puts ary.join("\t")

end

=begin

CREATE DATABASE IF NOT EXISTS db_name;
CREATE TABLE IF NOT EXISTS db_name.genome (
	id		varchar(30)	not NULL,
	name		varchar(80),
	definition	varchar(255),
	taxid		varchar(30),
	taxonomy	varchar(255),
	morphology	varchar(255),
	physiology	varchar(255),
	environment	varchar(255),
	reference	text,
	chromosome	text,
	nalen		integer,
	num_gene	integer,
	num_rna		integer,
	gc		float,
	genomemap	varchar(30),
	genecatalog	varchar(30)
);
LOAD DATA LOCAL INFILE 'genome.tab' INTO TABLE db_name.genome;

=end

