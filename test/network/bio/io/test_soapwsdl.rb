#
# test/functional/bio/io/test_soapwsdl.rb - Functional test for SOAP/WSDL
#
# Copyright::   Copyright (C) 2005,2007
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id:$ 
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
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

