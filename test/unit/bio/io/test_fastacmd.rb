#
# test/unit/bio/io/test_fastacmd.rb - Unit test for Bio::Blast::Fastacmd.
#
# Copyright::  Copyright (C) 2006 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/io/fastacmd'

module Bio

class TestFastacmd < Test::Unit::TestCase

  def setup
    @obj = Bio::Blast::Fastacmd.new('/dev/null')
  end

  def test_database
    assert_equal('/dev/null', @obj.database)
  end

  def test_fastacmd
    assert_equal("fastacmd", @obj.fastacmd)
  end

  def test_methods
    method_list = [ :get_by_id, :fetch, :each_entry, :each ]
    method_list.each do |method|
      assert(@obj.respond_to?(method))
    end
  end

end
end
