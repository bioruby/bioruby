#!/usr/bin/env ruby  
# 
# bioflat - OBDA flat file indexer (executable)
# 
#   Copyright (C) 2002 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp> 
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
#  $Id: br_bioflat.rb,v 1.6 2002/09/11 11:37:34 ng Exp $ 
# 

require 'bio'


def do_index
  is_bdb = (/bdb/i).match(ARGV[0]) ? Bio::FlatFileIndex::MAGIC_BDB : nil
  dbname = ARGV[1]
  if ARGV[2] =~ /^\-\-?format/
    format = ARGV[3]
    files  = ARGV[4..-1]
  else
    format = nil
    files  = ARGV[2..-1]
  end

  options = {}
  if files[0] =~ /^\-\-?sort\=(.*)/i then
    files.shift
    options['external_sort_program'] = $1
  elsif files[0] =~ /^\-\-?sort\-internal/i then
    files.shift
  elsif files[0] =~ /^\-\-?no\-?te?mp/i then
    files.shift
    options['onmemory'] = true
  end

  files.shift if files[0] == '--files'

  Bio::FlatFileIndex::makeindex(is_bdb, dbname, format, options, *files)
end


def do_search
  ARGV.shift if ARGV[0] == '--search'
  dbname = ARGV.shift
  db = Bio::FlatFileIndex.open(dbname)
  ARGV.each do |key|
    STDERR.print "Searching for \'#{key}\'...\n"
    r = db.search(key)
    STDERR.print "OK, #{r.size} entry found\n"
    if r.size > 0 then
      print r
    end
  end
  db.close
end


def usage
  print "Create index: \n"
  print "#{$0} --makeindex DBNAME [--format CLASS] [--sort=PROGRAM|--sort-internal|--no-temporary-files] [--files] FILENAME...\n"
  print "#{$0} --makeindexBDB DBNAME [--format CLASS] [--files] FILENAME...\n"
  print "Search: \n"
  print "#{$0} [--search] DBNAME KEYWORD...\n"
end


if ARGV.size > 1
  case ARGV[0]
  when /--make/
    Bio::FlatFileIndex::DEBUG.out = true
    do_index
  when /--search/
    do_search
  else #default is search
    do_search
  end
else
  usage
end

