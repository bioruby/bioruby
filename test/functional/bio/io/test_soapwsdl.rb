#
# test/functional/bio/io/test_soapwsdl.rb - Functional test for SOAP/WSDL
#
# Copyright::   Copyright (C) 2005,2007
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id: test_soapwsdl.rb,v 1.4 2007/04/05 23:35:42 trevor Exp $ 
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

