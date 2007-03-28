#
# test/functional/bio/io/test_soapwsdl.rb - Functional test for SOAP/WSDL
#
# Copyright::   Copyright (C) 2005,2007
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     Ruby's
#
#  $Id: test_soapwsdl.rb,v 1.3 2007/03/28 20:48:11 nakao Exp $ 
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/io/soapwsdl'

module Bio

class FuncTestSOAPWSDL < Test::Unit::TestCase

  def setup
    @wsdl = 'http://www.ebi.ac.uk/xembl/XEMBL.wsdl'
    @obj = Bio::SOAPWSDL.new(@wsdl)
  end

  def test_wsdl
    assert_equal(@wsdl, @obj.wsdl)
  end
  
  def test_set_wsdl
    @obj.wsdl = 'http://soap.genome.jp/KEGG.wsdl'
    assert_equal('http://soap.genome.jp/KEGG.wsdl', @obj.wsdl)
  end

  def test_log
    assert_equal(nil, @obj.log)
  end

  def test_set_log
    require 'stringio'
    io = StringIO.new
    @obj.log = io

    assert_equal(StringIO, @obj.log.class)
  end

end

end

