#
# bio/io/ddbjxml.rb - DDBJ SOAP server access class
#
#   Copyright (C) 2003, 2004 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: ddbjxml.rb,v 1.4 2004/06/23 08:24:59 k Exp $
#

require 'bio/db/genbank/ddbj'

begin
  require 'soap/wsdlDriver'
rescue LoadError
end

module Bio
class DDBJ

class XML

  BASE_URI = "http://xml.nig.ac.jp/wsdl/"

  def initialize(wsdl = nil)
    @wsdl = wsdl
    @log = nil
    create_driver
  end

  attr_reader :wsdl, :log

  def create_driver
    @driver = SOAP::WSDLDriverFactory.new(@wsdl).create_driver
    @driver.generate_explicit_type = true	# Ruby obj <-> SOAP obj
  end

  def wsdl=(url)
    @wsdl = url
    create_driver
  end

  def log=(io)
    @log = io
    @driver.wiredump_dev = @log
  end

  def method_missing(*arg)
    @driver.send(*arg)
  end

  class Blast < XML
    SERVER_URI = BASE_URI + "Blast.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end

  class ClustalW < XML
    SERVER_URI = BASE_URI + "ClustalW.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class DDBJ < XML
    SERVER_URI = BASE_URI + "DDBJ.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class Fasta < XML
    SERVER_URI = BASE_URI + "Fasta.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class GetEntry < XML
    SERVER_URI = BASE_URI + "GetEntry.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class SRS < XML
    SERVER_URI = BASE_URI + "SRS.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end
  
  class TxSearch < XML
    SERVER_URI = BASE_URI + "TxSearch.wsdl"
    def initialize(wsdl = nil)
      super(wsdl || SERVER_URI)
    end
  end

end # XML

end # DDBJ
end # Bio


if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp
  rescue LoadError
  end

  puts ">>> Bio::DDBJ::XML::DDBJ"
  serv = Bio::DDBJ::XML::DDBJ.new
  serv.log = STDERR

  puts "### getFFEntry('AB000050')"
  puts serv.getFFEntry('AB000050')

  puts ">>> Bio::DDBJ::XML::GetEntry"
  serv = Bio::DDBJ::XML::GetEntry.new

  puts "### getDDBJEntry('AB000050')"
  puts serv.getDDBJEntry('AB000050')

end


=begin

= Bio::DDBJ::XML

This class access the DDBJ web services by SOAP/WSDL.
For more informations, see:

  * ((<URL:http://xml.nig.ac.jp/>))

You need ((<RAA:SOAP4R>)) version >= 1.4.8.1 to use this module.
Currently, the WSDL::WSDLParser::UnknownElementError error occured
and seems to be not working (WSDL format problem?).

2004/05/01 It is now working, need to add samples in testcode

== Blast
== ClustalW
== DDBJ
== Fasta
== GetEntry
== SRS
== TxSearch

=end

