#
# = bio/io/soapwsdl.rb - SOAP/WSDL interface class
#
# Copyright::   Copyright (C) 2004 
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: soapwsdl.rb,v 1.7 2007/04/05 23:35:41 trevor Exp $
#
begin
  require 'soap/wsdlDriver'
rescue LoadError
end

module Bio

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
#
# Set the value of this variable to 'on'.
#
# --- http_proxy
#
# Set the URL of your proxy server (http://myproxy.com:8080 etc.).
#
# === Example to use HTTP proxy
# 
# % export soap_use_proxy=on
# % export http_proxy=http://localhost:8080
#
class SOAPWSDL

  # Returns URL of the current WSDL file.
  attr_reader :wsdl

  # Returns current logging IO.
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


  # Change the URL for WSDL file
  #
  #   serv = Bio::SOAPWSDL.new("http://soap.genome.jp/KEGG.wsdl")
  #
  # or
  # 
  #   serv = Bio::SOAPWSDL.new
  #   serv.wsdl = "http://soap.genome.jp/KEGG.wsdl"
  #
  # Note that you can't read two or more different WSDL files at once.
  # In that case, create Bio::SOAPWSDL object for each.
  #
  def wsdl=(url)
    @wsdl = url
    create_driver
  end


  # Change the IO for logging.  The argument is passed to wiredump_dev method
  # of the SOAP4R, thus
  #
  #   serv = Bio::SOAPWSDL.new
  #   serv.log = STDERR
  #
  # will print all the SOAP transactions in standard error.
  # This feature is especially useful for debug.
  #
  def log=(io)
    @log = io
    @driver.wiredump_dev = @log
  end


  # List of methods defined by WSDL
  def list_methods
    @driver.methods(false)
  end


  def method_missing(*arg)
    @driver.send(*arg)
  end
  private :method_missing

end # SOAPWSDL

end # Bio

