#
# bio/io/ddbjxml.rb - DDBJ SOAP server access class
#
#   Copyright (C) 2003 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: ddbjxml.rb,v 1.2 2003/06/14 01:12:35 k Exp $
#

require 'bio/db/genbank/ddbj'

begin
  require 'soap/wsdlDriver'
rescue LoadError
end

module Bio
  class DDBJ

    class XML

      SERVER_URI = 'http://xml.nig.ac.jp/wsdl/'

      def initialize(wsdl_path = '', log = nil)
	wsdl = Bio::DDBJ::XML::SERVER_URI + wsdl_path
	@driver = SOAP::WSDLDriverFactory.new(wsdl).createDriver
	@driver.generateEncodeType = true
	if log
	  @driver.setWireDumpFileBase(log)
	end
      end

      def method_missing(*arg)
	@driver.send(*arg)
      end

      class Blast < XML
	def initialize(log = nil)
	  super('Blast.wsdl', log)
	end
      end
      class ClustalW < XML
	def initialize(log = nil)
	  super('ClustalW.wsdl', log)
	end
      end
      class DDBJ < XML
	def initialize(log = nil)
	  super('DDBJ.wsdl', log)
	end
      end
      class Fasta < XML
	def initialize(log = nil)
	  super('Fasta.wsdl', log)
	end
      end
      class GetEntry < XML
	def initialize(log = nil)
	  super('GetEntry.wsdl', log)
	end
      end
      class SRS < XML
	def initialize(log = nil)
	  super('SRS.wsdl', log)
	end
      end
      class TxSearch < XML
	def initialize(log = nil)
	  super('TxSearch.wsdl', log)
	end
      end

    end
  end
end


if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp
  rescue LoadError
  end

  puts ">>> DDBJ/DDBJ"
  driver = Bio::DDBJ::XML::DDBJ.new

  puts "### getFFEntry('AB000050')"
  p driver.getFFEntry('AB000050')

  puts ">>> DDBJ/GetEntry"
  driver = Bio::DDBJ::XML::GetEntry.new

  puts "### getDDBJEntry('AB000050')"
  p driver.getDDBJEntry('AB000050')

end


=begin

= Bio::DDBJ::SOAP

This class access the DDBJ web services by SOAP/WSDL.
For more informations, see:

  * ((<URL:http://xml.nig.ac.jp/>))

You need ((<RAA:SOAP4R>)) version >= 1.4.8.1 to use this module.
Currently, the WSDL::WSDLParser::UnknownElementError error occured
and seems be not working (WSDL format problem?).

== Blast
== ClustalW
== DDBJ
== Fasta
== GetEntry
== SRS
== TxSearch

=end

