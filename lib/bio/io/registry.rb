#
# bio/io/registry.rb - BioDirectory Registry module
#
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: registry.rb,v 1.2 2002/03/04 08:17:27 katayama Exp $
#

require 'net/http'
require 'bio/io/sql'
require 'bio/io/fetch'
#require 'bio/io/flatfile'
#require 'bio/io/bdb'
#require 'bio/io/xembl'
#require 'bio/io/corba'

module Bio

  class Registry

    def initialize(file = nil)
      @registry = Hash.new
#     @registry = Array.new

      read_local(file) if file
      read_local("#{ENV['HOME']}/.bioinformatics/seqdatabase.ini")
      read_local("/etc/bioinformatics/seqdatabase.ini")

      read_remote if @registry.empty?
    end

    def get_database(db)
    end

    def query(db, tag)
      self.new unless @registry
      if @registry.is_a? Hash
	if @registry[db].is_a? Hash
	  @registry[db][tag]
	end
      end
    end

    def protocol(db)
      @registry[db]['protocol']
    end

    def location(db)
      @registry[db]['location']
    end

    def read_local(file)
      if File.readable?(file)
	stanza = File.open(file).read
	parse(stanza)
      end
    end

    def read_remote(host='www.open-bio.org', path='/registry/seqdatabase.ini')
      Net::HTTP.start(host, 80) do |http|
	response, = http.get(path)
	parse(response.body)
      end
    end

    private

    def parse(stanza)
      db = ''
      stanza.each_line do |line|
	case line
	when /^\[(.*)\]/
	  db = $1
	  @registry[db] = Hash.new unless @registry[db]
	when /=/
	  tag, value = line.chomp.split(/\s*=\s*/)
	  @registry[db][tag] = value unless @registry[db][tag]
	end
      end
    end

    class DB
    end

  end

end



if __FILE__ == $0

  require 'pp'

  reg = Bio::Registry.new(ARGV[0])	# Usually, you don't need to pass ARGV.
  pp reg

  pp reg.protocol('embl_biosql')
  pp reg.location('embl_biosql')

  pp reg.query('embl_biosql', 'biodbname')
  pp reg.query('embl_biosql', 'biodbname_')	# nil
  pp reg.query('embl_biosql_', 'biodbname_')	# nil

end


=begin

= Bio::Registry

--- Bio::Registry.new(file = nil)

--- Bio::Registry#query
--- Bio::Registry#db, get_database


== Bio::Registry::DB

--- Bio::Registry#protocol(db)
--- Bio::Registry#location(db)

=end

