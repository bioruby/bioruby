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
#  $Id: br_bioflat.rb,v 1.11 2003/02/28 10:29:40 ng Exp $ 
# 

require 'bio'

def usage
  print <<EOM
Search:
  #{$0} [--search] [DIR/]DBNAME KEYWORDS
Create index:
  #{$0} --create --location DIR --dbname DBNAME [--format <genbank|embl|fasta>] [options...] [--files] FILES
Update index:
  #{$0} --update --location DIR --dbname DBNAME [options...] [--files] FILES

Create index options:
  --primary=UNIQUE       set primary namespece to UNIQUE
                           Default primary/secondary namespaces depend on
                           each format of flatfiles.
  --secondary=KEY        set secondary namespaces.
                           You may use this option many times to specify
                           more than one namespace.
  --add-secondary=KEY    add secondary namespaces to default specification.
                           You can use this option many times.

Options only valid for --create (or --update) --type flat:
  --sort=/path/to/sort   use external sort program (e.g. /usr/bin/sort)
  --sort=BUILTIN         use builtin sort routine

Backward compatibility:
  --makeindex DIR/DBNAME
      same as --create --type flat --location DIR --dbname DBNAME
  --makeindexBDB DIR/DBNAME
      same as --create --type bdb  --location DIR --dbname DBNAME
  --format=CLASS
      instead of genbank|embl|fasta, specifing a class name is allowed
EOM

end


def do_index(mode = :create)
  case ARGV[0]
  when /^\-\-?make/
    dbpath = ARGV[1]
    args = ARGV[2..-1]
    is_bdb = nil
  when /^\-\-?make.*bdb/i
    dbname = ARGV[1]
    args = ARGV[2..-1]
    is_bdb = Bio::FlatFileIndex::MAGIC_BDB
  when /^\-\-create/, /^\-\-update/
    args = ARGV[1..-1]
  else
    usage
  end

  options = {}

  while args.first =~ /^\-/
    case x = args.shift

    # OBDA stuff

    when /^\-\-?format/
      args.shift
      format = nil		# throw this f*ckin' mess for auto detect :)
    when /^\-\-?location/
      location = args.shift.chomp('/')
    when /^\-\-?dbname/
      dbname = args.shift
    when /^\-\-?(index)?type/
      indextype = args.shift
      case indextype
      when /bdb/
	is_bdb = Bio::FlatFileIndex::MAGIC_BDB
      when /flat/
	is_bdb = nil
      else
	usage
      end

    # BioRuby extension

    when /^\-\-?files/i
      break

    when /^\-\-?format\=(.*)/i
      format = $1

    when /^\-\-?sort\=(.*)/i
      options['sort_program'] = $1
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

  dbpath = "#{location}/#{dbname}" unless dbpath
  if mode == :update then
    Bio::FlatFileIndex::update_index(dbpath, format, options, *args)
  else
    Bio::FlatFileIndex::makeindex(is_bdb, dbpath, format, options, *args)
  end
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


if ARGV.size > 1
  case ARGV[0]
  when /--make/, /--create/
    Bio::FlatFileIndex::DEBUG.out = true
    do_index
  when /--update/
    Bio::FlatFileIndex::DEBUG.out = true
    do_index(:update)
  when /--search/
    do_search
  else #default is search
    do_search
  end
else
  usage
end

