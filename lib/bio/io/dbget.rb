#
# dbget: DBGET client library
#
#        - interface to GenomeNet DBGET system -
# 
#   Copyright (C) 2000 Mitsuteru Nakao, KATAYAMA Toshiaki
#
#   ChangeLog:
#     2000/11/20 Mitsuteru S. Nakao, <n@bioruby.org>
#     2000/11/24 KATAYAMA Toshiaki, <k@bioruby.org>
#

require "socket"

class DBGET

  def initialize(addr="dbgetserv.genome.ad.jp", port="3266")
    if ENV["DBGET"] =~ /:/
      addr, port = ENV["DBGET"].split(':')
    end
    @addr = addr			# DBGET server address
    @port = port			# DBGET port number
  end

  def DBGET(arg) 
    query = arg + "\n";			# Query string
    result = Array.new			# Result

    sock = TCPSocket.open("#{@addr}", "#{@port}")

    sock.write(query);			# Submit query
    sock.flush;				# Buffer flush

    while sock.gets
      next if /^\+/
      next if /^\#/
      next if /^\*Request-IDent/
      result.push($_)
    end

    sock.close;				# Close TCP connection

    return result
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
  def bget(arg) 
    arg = "bget " + arg
    return DBGET(arg)
  end

  # btit("db entry ..")	- get entry definition
  def btit(arg) 
    arg = "btit " + arg
    return DBGET(arg)
  end

  # bref("db entry")	- get reference(s) and author(s)
  def bref(arg) 
    arg = "bref " + arg
    return DBGET(arg)
  end

  # bacc("db entry")	- get accession(s)
  def bacc(arg) 
    arg = "bacc " + arg
    return DBGET(arg)
  end

  # bent("db entry")	- get entry name
  def bent(arg) 
    arg = "bent " + arg
    return DBGET(arg)
  end

  # bfind("db keyword")	- search entris by keyword
  def bfind(arg) 
    arg = "bfind " + arg
    return DBGET(arg)
  end

  # binfo("db")		- get database information
  def binfo(arg) 
    arg = "binfo " + arg
    return DBGET(arg)
  end

  # blink("db entry")	- print link informations
  def blink(arg) 
    arg = "blink " + arg
    return DBGET(arg)
  end

  # alink("db entry")	- print relations
  def alink(arg) 
    arg = "alink " + arg
    return DBGET(arg)
  end

  # bman ("db entry")	- print manual page
  def bman(arg) 
    arg = "bman " + arg
    return DBGET(arg)
  end

  # btab ("db entry")
  def btab(arg) 
    arg = "btab " + arg
    return DBGET(arg)
  end

  # lmarge ("db entry")
  def lmarge(arg) 
    arg = "lmarge " + arg
    return DBGET(arg)
  end

end	
