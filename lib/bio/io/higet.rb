#
# bio/io/higet.rb - SOAP interface for HGC HiGet
#
#   Copyright (C) 2005 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: higet.rb,v 1.2 2005/09/26 13:00:08 k Exp $
#

require 'bio/io/soapwsdl'

module Bio
class HGC

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


=begin

= Bio::HGC::HiGet

* ((<URL:http://higet.hgc.jp/>))

== HiGet#hifind
== HiGet#higet
== HiGet#higet_in_fasta
== HiGet#higet_in_xml

=end

