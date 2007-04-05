#
# = bio/io/dbget.rb - GenomeNet/DBGET client module
#
# Copyright::	Copyright (C) 2000, 2001
#		Mitsuteru C. Nakao <n@bioruby.org>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
# $Id: dbget.rb,v 1.13 2007/04/05 23:35:41 trevor Exp $
#
# == DBGET
#
# Accessing the GenomeNet/DBGET data retrieval system
# http://www.genome.jp/dbget/ within the intranet.
#

require 'socket'

module Bio

class DBGET

  # default DBGET server address
# SERV = "dbgetserv.genome.jp"
  SERV = "dbget.genome.jp"
  # default DBGET port number
  PORT = "3266"

  # Main class method to access DBGET server.  Optionally, this method
  # can be called with the alternative DBGET server address and the
  # TCP/IP port number.
  #
  # 'com' should be one of the following DBGET commands:
  #
  # * alink, bfind, bget, binfo, blink, bman, bref, btab, btit
  #
  # These methods are shortcut for the dbget commands.  Actually,
  # Bio::DBGET.((|com|))(arg) internally calls Bio::DBGET.dbget(com, arg).
  # Most of these methods accept the argument "-h" for help.
  #
  # 'arg' should be one of the following formats :
  #
  # * [options] db
  #   * specify the database name only for binfo, bman etc.
  # * [options] db:entry
  #   * specify the database name and the entry name to retrieve.
  # * [options] db entry1 entry2 ...
  #   * specify the database name and the list of entries to retrieve.
  #
  # Note that options in the above example can be omitted.  If 'arg' is
  # empty, the help message with a list of options for 'com' will be
  # shown by default.  Supported database names will be found at the
  # GenomeNet DBGET web page http://www.genome.jp/dbget/.
  #
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

  # Show the version information of the DBGET server.
  def DBGET.version
    dbget("bget", "-V")
  end


  #--
  # bacc("db entry")	- not supported : get accession(s)
  # bent("db entry")	- not supported : get entry name
  # lmarge("db entry")	- not supported
  #++

  # alink("db entry") method returns relations
  def DBGET.alink(arg)
    dbget("alink", arg)
  end

  # bfind("db keyword")	method searches entries by keyword
  def DBGET.bfind(arg)
    dbget("bfind", arg)
  end

  # bget("db entry") method retrieves entries specified by the entry names
  def DBGET.bget(arg)
    dbget("bget", arg)
  end

  # seq("db entry") method retrieves the first sequence of the entry
  #
  # Shortcut to retrieve the sequence of the entry in FASTA format.
  # This method is equivalent to Bio::DBGET.bget("-f -n 1 #{arg}") and
  # 'arg' should be the "db:entry" or "db entry1 entry2 ..." format.
  def DBGET.seq(arg)
    dbget("bget", "-f -n 1 #{arg}")
  end

  # seq2("db entry") method retrieves the second sequence of the entry if any
  #
  # Shortcut to retrieve the second sequence of the entry in FASTA format.
  # This method is equivalent to Bio::DBGET.bget("-f -n 2 #{arg}").
  # Only useful when treating the KEGG GENES database entries which have
  # both AASEQ and NTSEQ fields. This method is obsolete and it is
  # recommended to use 'naseq' and 'aaseq' instead.
  def DBGET.seq2(arg)
    dbget("bget", "-f -n 2 #{arg}")
  end

  # naseq("db entry") method retrieves the nucleic acid sequence of the
  # entry if any.
  def DBGET.naseq(arg)
    dbget("bget", "-f -n n #{arg}")
  end

  # aaseq("db entry") method retrieves the amino acid sequence of the
  # entry if any.
  def DBGET.aaseq(arg)
    dbget("bget", "-f -n a #{arg}")
  end

  # binfo("db")	method retrieves the database information
  def DBGET.binfo(arg)
    dbget("binfo", arg)
  end

  # blink("db entry") method retrieves the link information
  def DBGET.blink(arg)
    dbget("blink", arg)
  end

  # bman ("db entry") method shows the manual page
  def DBGET.bman(arg)
    dbget("bman", arg)
  end

  # bref("db entry") method retrieves the references and authors
  def DBGET.bref(arg)
    dbget("bref", arg)
  end

  # btab ("db entry") method retrives (and generates) the database alias table
  def DBGET.btab(arg)
    dbget("btab", arg)
  end

  # btit("db entry ..")	method retrieves the entry definition
  def DBGET.btit(arg)
    dbget("btit", arg)
  end

end

end # module Bio


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


