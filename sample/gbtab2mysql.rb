#!/usr/bin/env ruby
#
# gbtab2mysql.rb - load tab delimited GenBank data files into MySQL
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
#  $Id: gbtab2mysql.rb,v 1.3 2002/06/25 19:30:26 k Exp $
#

require 'dbi'

$schema_ent = <<END
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
END

$schema_ft = <<END
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
END

$schema_ref = <<END
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
END

$schema_seq = <<END
	id		varchar(16)	NOT NULL,
	num		integer,
	naseq		mediumtext,
	KEY (id)
END


def create_table(dbh, table)
  $stderr.puts("create tables on #{table}") if $DEBUG

  query = "CREATE TABLE IF NOT EXISTS #{table} ( #{$schema_ent} )"
  dbh.execute(query)
  query = "CREATE TABLE IF NOT EXISTS #{table}ft ( #{$schema_ft} )"
  dbh.execute(query)
  query = "CREATE TABLE IF NOT EXISTS #{table}ref ( #{$schema_ref} )"
  dbh.execute(query)
  query = "CREATE TABLE IF NOT EXISTS #{table}seq ( #{$schema_seq} )"
  dbh.execute(query)
end


def load_tab(dbh, base, table)
  $stderr.puts("load #{base} into #{table}") if $DEBUG

  query = "LOAD DATA LOCAL INFILE '#{base}.seq.ent.tab' INTO TABLE #{table}"
  dbh.execute(query)
  query = "LOAD DATA LOCAL INFILE '#{base}.seq.ft.tab' INTO TABLE #{table}ft"
  dbh.execute(query)
  query = "LOAD DATA LOCAL INFILE '#{base}.seq.ref.tab' INTO TABLE #{table}ref"
  dbh.execute(query)
  query = "LOAD DATA LOCAL INFILE '#{base}.seq.seq.tab' INTO TABLE #{table}seq"
  dbh.execute(query)
end


def merge_table(dbh, tables)
  query = "CREATE TABLE IF NOT EXISTS ent ( #{$schema_ent} )" +
		" TYPE=MERGE UNION=( #{tables.join(', ')} )"
  dbh.execute(query)
  query = "CREATE TABLE IF NOT EXISTS ft ( #{$schema_ft} )" +
		" TYPE=MERGE UNION=( #{tables.join('ft, ') + 'ft' } )"
  dbh.execute(query)
  query = "CREATE TABLE IF NOT EXISTS ref ( #{$schema_ref} )" +
		" TYPE=MERGE UNION=( #{tables.join('ref, ') + 'ref' } )"
  dbh.execute(query)
  query = "CREATE TABLE IF NOT EXISTS seq ( #{$schema_seq} )" +
		" TYPE=MERGE UNION=( #{tables.join('seq, ') + 'seq' } )"
  dbh.execute(query)
end


$stderr.puts Time.now

DBI.connect('dbi:Mysql:genbank:localhost', 'root') do |dbh|
  tables = Array.new

  Dir.glob("*.seq").sort.each do |gbk|
    base = File.basename(gbk, '.seq')

    div = base[/gb.../]
    num = base[/\d+/].to_i

    table = div
    table = "%s%d" % [ div, (num - 1) / 20 + 1 ] if num > 20

    unless dbh.tables.include?(table)
      create_table(dbh, table)
      tables.push(table)
    end

    load_tab(dbh, base, table)
  end

  merge_table(dbh, tables)
end

$stderr.puts Time.now


