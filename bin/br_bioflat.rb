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
#  $Id: br_bioflat.rb,v 1.7 2002/09/13 14:47:46 ng Exp $ 
# 

require 'bio'


def do_index
  is_bdb = (/bdb/i).match(ARGV[0]) ? Bio::FlatFileIndex::MAGIC_BDB : nil
  dbname = ARGV[1]
  format = nil
  files  = ARGV[2..-1]
  options = {}

  while files[0] =~ /^\-/
    x = files.shift
    case x
    when /^\-\-?files/i
      break

    when /^\-\-?format\=(.*)/i
      format = $1
    when /^\-\-?format/i
      format = files.shift

    when /^\-\-?sort\=(.*)/i
      files.shift
      y = $1
      y = true if y.length <= 0
      options['external_sort_program'] = y
    when /^\-\-?sort\-internal/i
      options['external_sort_program'] = nil
      options['onmemory'] = nil
    when /^\-\-?no\-?te?mp/i
      options['onmemory'] = true

    when /^\-\-?primary.*\=(.*)/i
      options['primary_namespace'] = $1

    when /^\-\-?add-secondary.*\=(.*)/i
      unless options['additional_secondary_namespaces'] then
	options['additional_secondary_namespaces'] = []
      end
      options['additional_secondary_namespaces'] << $1 if $1.length > 0

    when /^\-\-?secondary.*\=(.*)/i
      unless options['secondary_namespaces'] then
	options['secondary_namespaces'] = []
      end
      options['secondary_namespaces'] << $1 if $1.length > 0

    else
      STDERR.print "Warning: ignoring invalid option #{x.inspect}\n"
    end
  end

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
  print "Search: \n"
  print "#{$0} [--search] DBNAME KEYWORD...\n"
  print "Create index: \n"
  print "#{$0} --makeindex DBNAME [--format CLASS] [options...] [--files] FILENAME...\n"
  print "#{$0} --makeindexBDB DBNAME [--format CLASS] [options...] [--files] FILENAME...\n"
  print <<EOM

Create index options:
  --primary=UNIQUE       set primary namespece to UNIQUE
                           Default primary/secondary namespaces depend on
                           each format of flatfiles.
  --secondary=KEY        set secondary namespaces.
                           You may use this option many times to specify
                           more than one namespace.
  --add-secondary=KEY    add secondary namespaces to default specification.
                           You can use this option many times.
Options only valid for --makeindex:
  --sort-internal        using internal sort routine (default)
  --sort=PROGRAM         set external sort program (e.g. /usr/bin/sort)
  --no-temporary-files   do everything on memory

EOM

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

