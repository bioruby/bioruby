#
# bio/dbget.rb - DBGET client module
#
#  Interface to GenomeNet DBGET system - http://www.genome.ad.jp/dbget/
#
#   Copyright (C) 2000 Mitsuteru S. Nakao <n@bioruby.org>
#   Copyright (C) 2000, 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: dbget.rb,v 1.1 2001/08/21 13:48:33 katayama Exp $
#
#  ChangeLog:
#    2000/11/20 v0.1 (n) initial version
#    2000/11/24 v0.2 (k) clean up rewrite
#    2001/01/29 v1.0 (k) change class to module
#    2001/02/20 v1.1 (k) LGPL
#

require 'socket'

module DBGET

  def dbget(com, arg)

    addr="dbgetserv.genome.ad.jp"	# default DBGET server address
    port="3266"				# default DBGET port number

    if ENV["DBGET"] =~ /:/		# overwrite DBGET serv/port
      addr, port = ENV["DBGET"].split(':')
    end

    query = "#{com} #{arg}\n"		# DBGET query string
    result = ''				# DBGET result

    sock = TCPSocket.open("#{addr}", "#{port}")

    sock.write(query)			# submit query
    sock.flush				# buffer flush

    while sock.gets
      next if /^\+/
      next if /^\#/
      next if /^\*Request-IDent/
      result << $_
    end

    sock.close

    return result
  end
  module_function :dbget


  ### optional module functions (in alphabetical order)

  # alink("db entry")	- print relations
  def alink(arg) 
    dbget("alink", arg)
  end
  module_function :alink

  # bacc("db entry")	- get accession(s)

  # bent("db entry")	- get entry name

  # bfind("db keyword")	- search entris by keyword
  def bfind(arg)
    dbget("bfind", arg)
  end
  module_function :bfind

  # bget("<options> [<dbname>:][<id> ..]") - get entry by ID 
  #
  # options:
  #   -f      in FASTA format
  #     -n 1  return Amino Acid sequence
  #     -n 2  return Nucleic Acid sequence
  #   -h      print help message
  #   -V      print version
  #
  def bget(arg)
    dbget("bget", arg)
  end
  module_function :bget

  # binfo("db")		- get database information
  def binfo(arg)
    dbget("binfo", arg)
  end
  module_function :binfo

  # blink("db entry")	- print link informations
  def blink(arg)
    dbget("blink", arg)
  end
  module_function :blink

  # bman ("db entry")	- print manual page
  def bman(arg)
    dbget("bman", arg)
  end
  module_function :bman

  # bref("db entry")	- get references and authors
  def bref(arg) 
    dbget("bref", arg)
  end
  module_function :bref

  # btab ("db entry")	- get/generate database alias table
  def btab(arg) 
    dbget("btab", arg)
  end
  module_function :btab

  # btit("db entry ..")	- get entry definition
  def btit(arg) 
    dbget("btit", arg)
  end
  module_function :btit

  # lmarge ("db entry")

end

