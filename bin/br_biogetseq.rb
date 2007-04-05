#!/usr/bin/env ruby
# 
# = biogetseq - OBDA sequence data retrieval (executable)
# 
# Copyright::   Copyright (C) 2003
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: br_biogetseq.rb,v 1.4 2007/04/05 23:35:39 trevor Exp $
# 

require 'bio'

def usage
  print <<END
  #{$0} --dbname <dbname> [--namespace <namespace>] entry_id [entry_id]
END
  exit 1
end

if ARGV.size < 3
  usage
end

while ARGV.first =~ /^-/
  case ARGV.shift
  when /^\-\-format/
    ARGV.shift
    raise NotImplementedError
  when /^\-\-dbname/
    dbname = ARGV.shift
  when /^\-\-namespace/
    namespace = ARGV.shift
  end
end

reg = Bio::Registry.new
db = reg.get_database(dbname)
if namespace
  db['namespace'] = namespace
end
ARGV.each do |entry|
  puts db.get_by_id(entry)
end

