#
# test/unit/bio/util/restriction_enzyme/test_cut_symbol.rb - Unit test for Bio::RestrictionEnzyme::CutSymbol
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/util/restriction_enzyme/cut_symbol'

# :nodoc:
module Bio
  module TestRestrictionEnzyme
    class TestCutSymbol < Test::Unit::TestCase # :nodoc:
      include Bio::RestrictionEnzyme::CutSymbol

      def setup; end

      def test_methods
        assert_equal('^', cut_symbol)
        assert_equal('|', set_cut_symbol('|'))
        assert_equal('|', cut_symbol)
        assert_equal('\\|', escaped_cut_symbol)
        assert_equal(/\|/, re_cut_symbol)
        assert_equal('^', set_cut_symbol('^'))

        assert_equal(3, 'abc^de' =~ re_cut_symbol)
        assert_equal(nil, 'abc^de' =~ re_cut_symbol_adjacent)
        assert_equal(3, 'abc^^de' =~ re_cut_symbol_adjacent)
        assert_equal(4, 'a^bc^^de' =~ re_cut_symbol_adjacent)
        assert_equal(nil, 'a^bc^de' =~ re_cut_symbol_adjacent)
      end
    end
  end
end
