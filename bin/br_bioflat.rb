#!/usr/bin/env ruby
# 
# = bioflat - OBDA flat file indexer (executable)
# 
# Copyright::   Copyright (C) 2002
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
# $Id: br_bioflat.rb,v 1.17 2007/04/05 23:35:39 trevor Exp $ 
# 

require 'bio'

def usage
  print <<EOM
Search:
  #{$0} [--search] [options...] [DIR/]DBNAME KEYWORDS
or
  #{$0} [--search] --location DIR --dbname DBNAME [options...] KEYWORDS

Search options:
  --namespace NAME       set serch namespace to NAME
  (or --name NAME)         You can set this option many times to specify
                           more than one namespace.

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
                         (default: /usr/bin/sort or BUILTIN)
  --env=/path/to/env     use env program to run sort (default: /usr/bin/env)
  --env-arg=XXXXXX       argument given to the env program (default: LC_ALL=C)
                         (multiple --env-arg=XXXXXX can be specified)

Options only valid for --update:
  --renew                re-read all flatfiles and update whole index

Backward compatibility:
  --makeindex DIR/DBNAME
      same as --create --type flat --location DIR --dbname DBNAME
  --makeindexBDB DIR/DBNAME
      same as --create --type bdb  --location DIR --dbname DBNAME
  --format=CLASS
      instead of genbank|embl|fasta, specifing a class name is allowed

Show namespaces:
  #{$0} --show-namespaces [--location DIR --dbname DBNAME] [DIR/DBNAME]
or
  #{$0} --show-namespaces [--format=CLASS]
or
  #{$0} --show-namespaces --files file

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

    when /^\-\-?format$/
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

    when /^\-\-?env\=(.*)/i
      options['env_program'] = $1

    when /^\-\-?env-arg(?:ument)?\=(.*)/i
      options['env_program_arguments'] ||= []
      options['env_program_arguments'].push $1

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

    when /^\-\-?renew/
      options['renew'] = true

    else
      $stderr.print "Warning: ignoring invalid option #{x.inspect}\n"
    end
  end

  dbpath = File.join(location, dbname) unless dbpath
  if mode == :update then
    Bio::FlatFileIndex::update_index(dbpath, format, options, *args)
  else
    Bio::FlatFileIndex::makeindex(is_bdb, dbpath, format, options, *args)
  end
end


def do_search
  dbname = nil
  location = nil
  names = []
  while x = ARGV.shift
    case x
    when /\A\-\-?search/i
      #do nothing
    when /\A\-\-?location/i
      location = ARGV.shift.to_s.chomp('/')
    when /\A\-\-?dbname/i
      dbname = ARGV.shift
    when /\A\-\-?name(?:space)?(?:\=(.+))?/i
      if $1 then
	names << $1
      elsif x = ARGV.shift
	names << x
      end
    else
      ARGV.unshift x
      break
    end
  end
  dbname = ARGV.shift unless dbname
  dbname = File.join(location, dbname) unless location.to_s.empty?
  db = Bio::FlatFileIndex.open(dbname)
  ARGV.each do |key|
    $stderr.print "Searching for \'#{key}\'...\n"
    #r = db.search(key)
    #$stderr.print "OK, #{r.size} entry found\n"
    #if r.size > 0 then
    #  print r
    #end
    begin
      if names.empty? then
	r = db.include?(key)
      else
	r = db.include_in_namespaces?(key, *names)
      end
    rescue RuntimeError
      $stderr.print "ERROR: #{$!}\n"
      next
    end
    r = [] unless r
    $stderr.print "OK, #{r.size} entry found\n"
    r.each do |i|
      print db.search_primary(i)
    end
  end
  db.close
end


def do_show_namespaces
  dbname = nil
  location = nil
  files = nil
  format = nil
  names = []
  while x = ARGV.shift
    case x
    when /\A\-\-?(show\-)?name(space)?s/i
      #do nothing
    when /\A\-\-?location/i
      location = ARGV.shift.to_s.chomp('/')
    when /\A\-\-?dbname/i
      dbname = ARGV.shift
    when /\A\-\-?format(?:\=(.+))?/i
      if $1 then
	format = $1
      elsif x = ARGV.shift
	format = x
      end
    when /\A\-\-?files/i
      files = ARGV
      break
    else
      ARGV.unshift x
      break
    end
  end
  if files then
    k = nil
    files.each do |x|
      k = Bio::FlatFile.autodetect_file(x)
      break if k
    end
    if k then
      $stderr.print "Format: #{k.to_s}\n"
      format = k
    else
      $stderr.print "ERROR: couldn't determine file format\n"
      return
    end
  end
  $stderr.print "Namespaces: (first line: primary namespace)\n"
  if format then
    parser = Bio::FlatFileIndex::Indexer::Parser.new(format)
    print parser.primary.name, "\n"
    puts parser.secondary.keys
  else
    dbname = ARGV.shift unless dbname
    dbname = File.join(location, dbname) unless location.to_s.empty?
    db = Bio::FlatFileIndex.open(dbname)
    puts db.namespaces
    db.close
  end
end

if ARGV.size > 1
  case ARGV[0]
  when /--make/, /--create/
    Bio::FlatFileIndex::DEBUG.out = true
    do_index
  when /--update/
    Bio::FlatFileIndex::DEBUG.out = true
    do_index(:update)
  when /\A\-\-?(show\-)?name(space)?s/i
    do_show_namespaces
  when /--search/
    do_search
  else #default is search
    do_search
  end
else
  usage
end

