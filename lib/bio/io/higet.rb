#
# = bio/io/higet.rb - SOAP interface for HGC HiGet
#
# Copyright::  Copyright (C) 2005 Toshiaki Katayama <k@bioruby.org>
#
# $Id: higet.rb,v 1.3 2006/09/19 05:46:22 k Exp $
#

require 'bio/io/soapwsdl'

module Bio
class HGC

# == Description
#
# Interface for the HiGet service provided by Human Genome Center (HGC), Japan.
# HiGet performs full-text search against various biological databases.
#
# == References
#
# * http://higet.hgc.jp/
#
class HiGet < Bio::SOAPWSDL

  SERVER_URI = "http://higet.hgc.jp/soap/higet.wsdl"

  def initialize(wsdl = nil)
    super(wsdl || SERVER_URI)
  end

  def higet_in_fasta(db, entries)
    self.higet(db, entries, "-d fasta")
  end

  def higet_in_xml(db, entries)
    self.higet(db, entries, "-d xml")
  end

end

end # HGC
end # Bio


if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  puts ">>> Bio::HGC::HiGet"
  serv = Bio::HGC::HiGet.new
  serv.log = STDERR

  puts "### HiFind"
  puts serv.hifind("genbank", "human kinase", "-l 10")

  puts "### HiGet"
  puts serv.higet("genbank", "S40289", "")

  puts "### HiGet (FASTA)"
  puts serv.higet("genbank", "S40289", "-d fasta")

  puts "### HiGet higet_in_fasta"
  puts serv.higet_in_fasta("genbank", "S40289")

  puts "### HiGet higet_in_xml"
  puts serv.higet_in_xml("genbank", "S40289")

end

