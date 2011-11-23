#
# test/functional/bio/io/test_ddbjrest.rb - Functional test for Bio::DDBJ::REST
#
# Copyright::   Copyright (C) 2011
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'bio/io/ddbjrest'
require 'test/unit'

module Bio
module NetTestDDBJREST

  class TestDDBJ < Test::Unit::TestCase

    def setup
      @obj = Bio::DDBJ::REST::DDBJ.new
    end

    def test_countBasePair
      text = @obj.countBasePair("AF237819")
      expected = {
        "a" => 47,
        "t" => 38,
        "g" => 48,
        "c" => 38
      }
      h = {}
      text.each_line do |line|
        base, count, percent = line.split(/\t/)
        count = count.to_i
        h[base] = count if count > 0
      end
      assert_equal(expected, h)
    end

  end #class TestDDBJ

end #module NetTestDDBJREST
end #module Bio
