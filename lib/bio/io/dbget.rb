#
# bio/io/dbget.rb - DBGET client module
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
#  $Id: dbget.rb,v 1.3 2001/10/17 14:43:12 katayama Exp $
#

module Bio

require 'socket'

class DBGET

  SERV = "dbgetserv.genome.ad.jp"	# default DBGET server address
  PORT = "3266"				# default DBGET port number

  def DBGET.dbget(com, arg, serv = nil, port = nil)

    unless serv or port			# if both of serv and port are nil
      if ENV["DBGET"] =~ /:/		# and ENV["DBGET"] exists
	serv, port = ENV["DBGET"].split(':')
      end
    end
    serv = serv ? serv : SERV
    port = port ? port : PORT

    query = "#{com} #{arg}\n"		# DBGET query string
    result = ''				# DBGET result

    sock = TCPSocket.open("#{serv}", "#{port}")

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


  ### Individual DBGET functions (in alphabetical order)

  # alink("db entry")	- print relations
  def DBGET.alink(arg) 
    dbget("alink", arg)
  end

  # bacc("db entry")	- get accession(s)

  # bent("db entry")	- get entry name

  # bfind("db keyword")	- search entries by keyword
  def DBGET.bfind(arg)
    dbget("bfind", arg)
  end

  # bget("<options> [<dbname>:][<id> ..]") - get entry by ID 
  #
  # options:
  #   -f      in FASTA format
  #     -n 1  return Amino Acid sequence
  #     -n 2  return Nucleic Acid sequence
  #   -h      print help message
  #   -V      print version
  #
  def DBGET.bget(arg)
    dbget("bget", arg)
  end

  # binfo("db")		- get database information
  def DBGET.binfo(arg)
    dbget("binfo", arg)
  end

  # blink("db entry")	- print link informations
  def DBGET.blink(arg)
    dbget("blink", arg)
  end

  # bman ("db entry")	- print manual page
  def DBGET.bman(arg)
    dbget("bman", arg)
  end

  # bref("db entry")	- get references and authors
  def DBGET.bref(arg) 
    dbget("bref", arg)
  end

  # btab ("db entry")	- get/generate database alias table
  def DBGET.btab(arg) 
    dbget("btab", arg)
  end

  # btit("db entry ..")	- get entry definition
  def DBGET.btit(arg) 
    dbget("btit", arg)
  end

  # lmarge ("db entry")

end

end				# module Bio

