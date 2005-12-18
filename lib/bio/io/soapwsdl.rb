#
# = bio/io/soapwsdl.rb - SOAP/WSDL interface class
#
# Copyright::   Copyright (C) 2004 
#               KATAYAMA Toshiaki <k@bioruby.org>
# License::     LGPL
#
# $Id: soapwsdl.rb,v 1.3 2005/12/18 16:51:18 nakao Exp $
#
# SOAP/WSDL 
#
#
# == Examples
# 
# class API < Bio::SOAPWSDL
#   def initialize
#     @wsdl = 'http://example.com/example.wsdl'
#     @log = File.new("soap_log", 'w')
#     create_driver
#   end
# end
#
# == Use HTTP proxy
#
# You need to set following two environmental variables
# (case might be insensitive) as required by SOAP4R.
#
# --- soap_use_proxy
# Set the value of this variable to 'on'.
#
# --- http_proxy
# Set the URL of your proxy server (http://myproxy.com:8080 etc.).
#
# === Example
# 
# % export soap_use_proxy=on
# % export http_proxy=http://localhost:8080
#
#--
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
#++
#

begin
  require 'soap/wsdlDriver'
rescue LoadError
end

module Bio

class SOAPWSDL

  # WSDL URL
  attr_reader :wsdl

  # log IO
  attr_reader :log


  def initialize(wsdl = nil)
    @wsdl = wsdl
    @log = nil
    create_driver
  end


  def create_driver
    if RUBY_VERSION > "1.8.2"
      @driver = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
    else
      @driver = SOAP::WSDLDriverFactory.new(@wsdl).create_driver
    end
    @driver.generate_explicit_type = true	# Ruby obj <-> SOAP obj
  end
  private :create_driver


  # Set a WSDL URL.
  def wsdl=(url)
    @wsdl = url
    create_driver
  end


  # Set log IO
  def log=(io)
    @log = io
    @driver.wiredump_dev = @log
  end


  def method_missing(*arg)
    @driver.send(*arg)
  end
  private :method_missing

end # SOAP

end # Bio

