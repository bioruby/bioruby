#
# bio/io/dbget.rb - GenomeNet/DBGET client module
#
#   Copyright (C) 2000  Mitsuteru C. Nakao <n@bioruby.org>
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: dbget.rb,v 1.9 2004/08/24 00:05:58 k Exp $
#

require 'socket'

module Bio

  class DBGET

#   SERV = "dbgetserv.genome.jp"	# default DBGET server address
    SERV = "dbget.genome.jp"		# default DBGET server address
    PORT = "3266"			# default DBGET port number

    def DBGET.dbget(com, arg, serv = nil, port = nil)

      unless serv or port		# if both of serv and port are nil
	if ENV["DBGET"] =~ /:/		# and ENV["DBGET"] exists
	  serv, port = ENV["DBGET"].split(':')
	end
      end
      serv = serv ? serv : SERV
      port = port ? port : PORT

      if arg.empty?
	arg = "-h"			# DBGET help message
      end

      query = "#{com} #{arg}\n"		# DBGET query string

      sock = TCPSocket.open("#{serv}", "#{port}")

      sock.write(query)			# submit query
      sock.flush			# buffer flush

      sock.gets				# skip "+Helo DBgetServ ..."
      sock.gets				# skip "#If you see this message, ..."
      sock.gets				# skip "*Request-IDent"

      result = sock.read		# DBGET result

      sock.close

      return result
    end

    def DBGET.version
      dbget("bget", "-V")
    end


    ### Individual DBGET functions (in alphabetical order)

    # alink("db entry")		- print relations
    def DBGET.alink(arg)
      dbget("alink", arg)
    end

    # bacc("db entry")		- not supported : get accession(s)

    # bent("db entry")		- not supported : get entry name

    # bfind("db keyword")	- search entries by keyword
    def DBGET.bfind(arg)
      dbget("bfind", arg)
    end

    # bget("db entry")		- get entry by the entry name
    def DBGET.bget(arg)
      dbget("bget", arg)
    end
    def DBGET.seq(arg)
      dbget("bget", "-f -n 1 #{arg}")
    end
    def DBGET.seq2(arg)
      dbget("bget", "-f -n 2 #{arg}")
    end

    # binfo("db")		- get database information
    def DBGET.binfo(arg)
      dbget("binfo", arg)
    end

    # blink("db entry")		- print link informations
    def DBGET.blink(arg)
      dbget("blink", arg)
    end

    # bman ("db entry")		- print manual page
    def DBGET.bman(arg)
      dbget("bman", arg)
    end

    # bref("db entry")		- get references and authors
    def DBGET.bref(arg)
      dbget("bref", arg)
    end

    # btab ("db entry")		- get/generate database alias table
    def DBGET.btab(arg)
      dbget("btab", arg)
    end

    # btit("db entry ..")	- get entry definition
    def DBGET.btit(arg)
      dbget("btit", arg)
    end

    # lmarge("db entry")	- not supported

  end

end


if __FILE__ == $0
  puts "### DBGET version"
  p Bio::DBGET.version
  puts "### DBGET.dbget('bfind', 'sce tyrosin kinase')"
  puts Bio::DBGET.dbget('bfind', 'sce tyrosin kinase')
  puts "### DBGET.bfind('sce tyrosin kinase')"
  puts Bio::DBGET.bfind('sce tyrosin kinase')
  puts "### DBGET.bget('sce:YDL028C')"
  puts Bio::DBGET.bget('sce:YDL028C')
  puts "### DBGET.binfo('dbget')"
  puts Bio::DBGET.binfo('dbget')
end


=begin

= Bio::DBGET

Accessing the GenomeNet/DBGET data retrieval system
((<URL:http://www.genome.jp/dbget/>)).

--- Bio::DBGET.dbget(com, arg, serv = nil, port = nil)

      Main class method to access DBGET server.  Optionally, this method
      can be called with the alternative DBGET server address and the
      TCP/IP port number.

      'com' should be one of the following DBGET commands :

      * alink, bfind, bget, binfo, blink, bman, bref, btab, btit

      'arg' should be one of the following formats :

      * [options] db
        * specify the database name only for binfo, bman etc.
      * [options] db:entry
        * specify the database name and the entry name to retrieve.
      * [options] db entry1 entry2 ...
        * specify the database name and the list of entries to retrieve.

      Note that options in the above example can be omitted.  If 'arg' is
      empty, the help message with a list of options for 'com' will be
      shown by default.  Supported database names will be found at the
      GenomeNet DBGET web page ((<URL:http://www.genome.jp/dbget/>)).

--- BIO::DBGET.alink(arg)
--- Bio::DBGET.bfind(arg)
--- Bio::DBGET.bget(arg)
--- Bio::DBGET.binfo(arg)
--- Bio::DBGET.blink(arg)
--- Bio::DBGET.bman(arg)
--- Bio::DBGET.bref(arg)
--- Bio::DBGET.btab(arg)
--- Bio::DBGET.btit(arg)

      These class methods are shortcut for the dbget commands.  Actually,
      Bio::DBGET.((|com|))(arg) internally calls Bio::DBGET.dbget(com, arg).
      Most of these methods accept the argument "-h" for help.

--- Bio::DBGET.version

      Show the version information of the DBGET server.

--- Bio::DBGET.seq(arg)

      Shortcut to retrieve the sequence of the entry in FASTA format.
      This method is equivalent to Bio::DBGET.bget("-f -n 1 #{arg}") and
      'arg' should be the "db:entry" or "db entry1 entry2 ..." format.

--- Bio::DBGET.seq2(arg)

      Shortcut to retrieve the second sequence of the entry in FASTA format.
      This method is equivalent to Bio::DBGET.bget("-f -n 2 #{arg}").
      Only useful when treating the KEGG/GENES database entries which have
      both AASEQ and NTSEQ fields.

=end


