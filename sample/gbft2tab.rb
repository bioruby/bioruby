#!/usr/bin/env ruby
#
# gbft2tab.rb - convert GenBank FEATURES into tab delimited data for MySQL
#
#  Usage:
#
#    % gbft2tab.rb gb*.seq > gbft.tab
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
#  $Id: gbft2tab.rb,v 0.1 2001/06/21 08:23:40 katayama Exp $
#

require 'bio/db/genbank'

while entry = gets(GenBank::DELIMITER)

  gb = GenBank.new(entry)

  num = 0

  gb.features do |f|
    num += 1

    f.each do |qualifier, value|
      next if qualifier =~ /(feature|position)/

      if qualifier == 'db_xref'
        value = f['db_xref'].inspect
      end

      ary = [
	gb.id,
	num,
	f['feature'],
	f['position'],
	qualifier,
	value,
      ]
      puts ary.join("\t")
    end

  end

end

=begin

CREATE DATABASE IF NOT EXISTS db_name;
CREATE TABLE IF NOT EXISTS db_name.gbft (
	id		varchar(30)	not NULL,
	num		integer,
	feature		varchar(30),
	position	text,
	qualifier	varchar(30),
	value		text
);
LOAD DATA LOCAL INFILE 'gbft.tab' INTO TABLE db_name.gbft;

=end

