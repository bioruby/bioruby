#!/usr/bin/env ruby
#
# genome2rb.rb - used to generate contents of the bio/data/keggorg.rb
#
#  Usage:
#
#    % genome2rb.rb genome | sort
#
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: genome2rb.rb,v 1.1 2002/03/04 08:14:45 katayama Exp $
#

require 'bio'

Bio::FlatFile.new(Bio::KEGG::GENOME,ARGF).each do |x|
  puts "    '#{x.entry_id}' => [ '#{x.name}', '#{x.definition}' ],"
end

