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
#  $Id: br_biogetseq.rb,v 1.1 2003/02/19 04:31:57 k Exp $
# 

require 'bio'

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
db = reg.get_databasse(dbname)
if namespace
  db['namespace'] = namespace
end
ARGV.each do |entry|
  puts db.get_by_id(entry)
end
