#
# test/unit/bio/util/restriction_enzyme/test_integer.rb - Unit test for Bio::RestrictionEnzyme::Integer
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: test_integer.rb,v 1.2 2006/12/31 18:46:14 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/restriction_enzyme/integer'

module Bio #:nodoc:

class TestCutLocationsInEnzymeNotation < Test::Unit::TestCase #:nodoc:

  def test_negative?
    assert_equal(false, 1.negative?)
    assert_equal(false, 0.negative?)
    assert_equal(true, -1.negative?)
  end

end

end
