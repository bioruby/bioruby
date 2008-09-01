#
# test/unit/bio/util/restriction_enzyme.rb - Unit test for Bio::RestrictionEnzyme
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id:$
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme.rb'

module Bio; module TestRestrictionEnzyme #:nodoc:

class TestRestrictionEnzyme < Test::Unit::TestCase #:nodoc:

  def setup
    @t = Bio::RestrictionEnzyme
  end
  
  def test_rebase
    assert_equal(@t.rebase.respond_to?(:enzymes), true)
    assert_not_nil @t.rebase['AarI']
    assert_nil @t.rebase['blah']
  end
  
  def test_enzyme_name
    assert_equal(@t.enzyme_name?('AarI'), true)
    assert_equal(@t.enzyme_name?('atgc'), false)
    assert_equal(@t.enzyme_name?('aari'), true)
    assert_equal(@t.enzyme_name?('EcoRI'), true)
    assert_equal(@t.enzyme_name?('EcoooRI'), false)
  end

end

end; end
