#
# dbget: Interface to GenomeNet DBGET system (http://www.genome.ad.jp/)
#
#   Copyright (C) 2000, 2001 Mitsuteru Nakao, KATAYAMA Toshiaki
#
#   ChangeLog:
#     2000/11/20 Mitsuteru S. Nakao, <n@bioruby.org>
#     2000/11/24 KATAYAMA Toshiaki, <k@bioruby.org>
#     2001/01/26 KATAYAMA Toshiaki, <k@bioruby.org>
#     2001/01/29 KATAYAMA Toshiaki, <k@bioruby.org>
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

  def dbget(arg) 
    query = arg + "\n"			# Query string
    result = []				# Result

    sock = TCPSocket.open("#{@addr}", "#{@port}")

    sock.write(query)			# Submit query
    sock.flush				# Buffer flush

    while sock.gets
      next if /^\+/
      next if /^\#/
      next if /^\*Request-IDent/
      result.push($_)
    end

    sock.close				# Close TCP connection

    return result
  end

end

