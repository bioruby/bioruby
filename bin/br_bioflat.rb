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
#  $Id: br_bioflat.rb,v 1.3 2002/08/26 06:08:20 k Exp $ 
# 

require 'bio'

def create_index(is_bdb, dbname, format, *files)
  case format
  when /genbank/i
    dbclass = Bio::GenBank
    add_secondary = nil
  when /genpept/i
    dbclass = Bio::GenPept
    add_secondary = nil
  when /embl/i
    dbclass = Bio::EMBL
    add_secondary = [ 'DR' ]
  when /sptr/i
    dbclass = Bio::SPTR
    add_secondary = [ 'DR' ]
  else
    raise "Unsupported format : #{format}"
  end
  if is_bdb then
    Bio::FlatFileIndex::Indexer::makeindexBDB(dbname, dbclass, nil, nil, add_secondary, *files)
  else
    Bio::FlatFileIndex::Indexer::makeindexFlat(dbname, dbclass, nil, nil, add_secondary, *files)
  end
end


def do_index
  is_bdb = (/bdb/i).match(ARGV[0]) ? Bio::FlatFileIndex::MAGIC_BDB : nil
  dbname = ARGV[1]
  format = ARGV[3]
  files  = ARGV[4..-1]
  files.shift if files[0] == '--files'
  create_index(is_bdb, dbname, format, *files)
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
  print "#{$0} --makeindex DBNAME --format CLASS [--files] FILENAME...\n"
  print "#{$0} --makeindexBDB DBNAME --format CLASS [--files] FILENAME...\n"
  print "Search: \n"
  print "#{$0} [--search] DBNAME KEYWORD...\n"
end


if ARGV.size > 1
  case ARGV[0]
  when /--make/
    do_index
  when /--search/
    do_search
  else #default is search
    do_search
  end
else
  usage
end

