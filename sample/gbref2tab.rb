#!/usr/bin/env ruby
#
# gbref2tab.rb - convert GenBank REFERENCE into tab delimited data for MySQL
#
#  Usage:
#
#    % gbref2tab.rb gb*.seq > gbref.tab
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
#  $Id: gbref2tab.rb,v 0.1 2001/06/21 08:23:56 katayama Exp $
#

require 'bio/db/genbank'

while entry = gets(GenBank::DELIMITER)

  gb = GenBank.new(entry)

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

    puts ary.join("\t")
  end

end

=begin

CREATE DATABASE IF NOT EXISTS db_name;
CREATE TABLE IF NOT EXISTS db_name.gbref (
	id		varchar(30)	not NULL,
	reference	varchar(255),
	authors		text,
	title		text,
	journal		text,
	medline		varchar(255),
	pubmed		varchar(255),
	remark		varchar(255)
);
LOAD DATA LOCAL INFILE 'gbref.tab' INTO TABLE db_name.gbref;

=end

