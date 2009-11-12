#
# test/unit/bio/util/test_color_scheme.rb - Unit test for Bio::ColorScheme
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/util/color_scheme'

module Bio #:nodoc:
  class TestColorScheme < Test::Unit::TestCase #:nodoc:

    def test_buried
      s = Bio::ColorScheme::Buried
      assert_equal('00DC22', s['A'])
      assert_equal('00BF3F', s[:c])
      assert_equal(nil, s[nil])
      assert_equal('FFFFFF', s['-'])
      assert_equal('FFFFFF', s[7])
      assert_equal('FFFFFF', s['junk'])
      assert_equal('00CC32', s['t'])
    end

  end
end
