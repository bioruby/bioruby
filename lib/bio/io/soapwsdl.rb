#
# bio/io/soapwsdl.rb - SOAP/WSDL interface class
#
#   Copyright (C) 2004 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: soapwsdl.rb,v 1.1 2004/06/23 14:32:15 k Exp $
#

begin
  require 'soap/wsdlDriver'
rescue LoadError
end

module Bio

class SOAPWSDL

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

end # SOAP

end # Bio

