#!/usr/bin/ruby
# test program
# Mitsuteru S. Nakao, <nakao@kuicr.kyoto-u.ac.jp>
# 20 Nov 2000
#




=begin
== NAME

DBGET.rb - Yet another DBGET client class

Version 0.1

Copyright (C) 2000 Mitsuteru Nakao, <nakao@kuicr.kyoto-u.ac.jp>

== EXAMPLE

=== bget genes b0001

  require "DBGET"
  d = DNGET.new
  print d.bget("genes b0001")

=end

# load "TCPSocket" class
require "socket"

#module DBGET
class DBGET

  # Global variables
  DBGET_SERVER = {
    "addr" => 'dbgetserv.genome.ad.jp',   ## Address of DBGetServ
    "port" => '3266'                      ## Port num of DBGetServ
  }

=begin
== METHODS
=end

=begin
=== bget - get entry by accession form database
  bget ("<options> [<dbname>:][<id> ..]")

  options:
    -f      FastA format
    -S      Stanford format
     -n 1     in AA sequence
     -n 2     in NT sequence
    -h      help print
    -V      version print

  <dbname>, see also btab 
  
=end

  def bget (cmd) 
    cmd = "bget " + cmd
    return DBGET (cmd)
  end

=begin
=== btit - get entry definition
  btit ("db entry ..")
=end

  def btit (cmd) 
    cmd = "btit " + cmd
    return DBGET (cmd)
  end

=begin
=== bref - get reference(s) and author(s)
  bref ("db entry")
=end 

  def bref (cmd) 
    cmd = "bref " + cmd
    return DBGET (cmd)
  end

=begin
=== bacc - get accession(s)
  bacc ("db entry")
=end 

  def bacc (cmd) 
    cmd = "bacc " + cmd
    return DBGET (cmd)
  end

=begin
=== bent - get entry name
  bent ("db entry")
=end 

  def bent (cmd) 
    cmd = "bent " + cmd
    return DBGET (cmd)
  end

=begin
=== bfind - search entris by keyword
  bfind ("db keyword")
=end

  def bfind (cmd) 
    cmd = "bfind " + cmd
    return DBGET (cmd)
  end

=begin
=== binfo - get database information
  binfo ("db")
=end

  def binfo (cmd) 
    cmd = "binfo " + cmd
    return DBGET (cmd)
  end

=begin
=== blink - print lint relations
  blink ("db entry")
=end 

  def blink (cmd) 
    cmd = "blink " + cmd
    return DBGET (cmd)
  end

=begin
=== alink - print relations
  alink ("db entry")
=end 

  def alink (cmd) 
    cmd = "alink " + cmd
    return DBGET (cmd)
  end

=begin
=== bman
  bman ("db entry")
=end 

  def bman (cmd) 
    cmd = "bman " + cmd
    return DBGET (cmd)
  end

=begin
=== btab
  btab ("db entry")
=end 

  def btab (cmd) 
    cmd = "btab " + cmd
    return DBGET (cmd)
  end

=begin
=== lmarge
  lmarge ("db entry")
=end 

  def lmarge (cmd) 
    cmd = "lmarge " + cmd
    return DBGET (cmd)
  end

=begin
== DBGET (cmd)
=end

  def DBGET (cmd) 
    query = cmd + "\n";      ## Query string
    result = Array.new(0);   ## Array for returns

    ## Connect and open the server
    soc = TCPSocket.open(DBGET_SERVER["addr"], DBGET_SERVER["port"])

    soc.write(query);   # Submit query
    soc.flush;          # Buffer flush

    while soc.gets      ## output 
      if (/^\#/) 
        next
      elsif (/^\*Request-IDent/) 
        while soc.gets  ## 
          result.push($_);
          soc.flush;
        end
      end
    end

    soc.close;          ## Close TCP connection

    return result
  end
end	



0;
#

