#!/usr/bin/env ruby
#
# ssearch2tab.rb - convert SSEARCH output into tab delimited data for MySQL
#
#  Usage:
#
#    % ssearch2tab.rb SSEARCH-output-file[s] > ssearch_results.tab
#    % mysql < ssearch_results.sql  (use sample at the end of this file)
#
#  Format accepted:
#
#    % ssearch3[3][_t] -Q -H -m 6 query.f target.f > SSEARCH-output-file
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
#  $Id: ssearch2tab.rb,v 0.1 2001/06/21 08:25:58 katayama Exp $
#

while gets

  # query
  if /^\S+: (\d+) aa$/
    q_len = $1
  end

  # each hit
  if /^>>([^>]\S+).*\((\d+) aa\)$/
    target = $1
    t_len = $2

    # d = dummy variable
    d, d, d, swopt, d, zscore, d, bits, d, evalue =
      gets.split(/\s+/)
    d, d, sw, ident, d, ugident, d, d, overlap, d, d, lap =
      gets.split(/\s+/)

    # query-hit pair
    print "#{$FILENAME}\t#{q_len}\t#{target}\t#{t_len}"

    # pick up values
    ary = [
      swopt,
      zscore,
      bits,
      evalue,
      sw,
      ident,
      ugident,
      overlap,
      lap
    ]

    # print values
    for i in ary
      i.tr!('^0-9.:e\-','')
      print "\t#{i}"
    end

    print "\n"

  end
end

=begin MySQL ssearch_results.sql sample

CREATE DATABASE IF NOT EXISTS db_name;
CREATE TABLE IF NOT EXISTS db_name.table_name (
	query	varchar(25)	not NULL,
	q_len	integer		unsigned default 0,
	target	varchar(25)	not NULL,
	t_len	integer		unsigned default 0,
	swopt	integer		unsigned default 0,
	zscore	float		default 0.0,
	bits	float		default 0.0,
	evalue	float		default 0.0,
	sw	integer		unsigned default 0,
	ident	float		default 0.0,
	ugident	float		default 0.0,
	overlap	integer		unsigned default 0,
	lap_at	varchar(25)	default NULL
);
LOAD DATA LOCAL INFILE 'ssearch_results.tab' INTO TABLE db_name.table_name;

=end


