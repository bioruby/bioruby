#!/usr/bin/env ruby
# 
# biogetseq - OBDA sequence data retrieval (executable)
# 
#   Copyright (C) 2003 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: br_biogetseq.rb,v 1.2 2003/02/21 02:44:22 k Exp $
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

