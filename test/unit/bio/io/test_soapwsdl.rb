#
# test/unit/bio/io/test_soapwsdl.rb - Unit test for SOAP/WSDL
#
# Copytight::   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id:$ 
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/io/soapwsdl'

module Bio

class TestSOAPWSDL < Test::Unit::TestCase

  def setup
    @obj = Bio::SOAPWSDL
  end

  def test_methods
    methods = ['list_methods','wsdl', 'wsdl=', 'log', 'log=']
    assert_equal(methods.sort, (@obj.instance_methods - Object.methods).sort.collect { |x| x.to_s })
  end

end
end
