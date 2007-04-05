#
# test/unit/bio/io/test_fastacmd.rb - Unit test for Bio::Blast::Fastacmd.
#
# Copyright::  Copyright (C) 2006 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_fastacmd.rb,v 1.3 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/io/fastacmd'

module Bio

class TestFastacmd < Test::Unit::TestCase

  def setup
    @obj = Bio::Blast::Fastacmd.new("/tmp/test")
  end

  def test_database
    assert_equal("/tmp/test", @obj.database)
  end

  def test_fastacmd
    assert_equal("fastacmd", @obj.fastacmd)
  end

  def test_methods
    method_list = ['get_by_id', 'fetch', 'each_entry', 'each']
    method_list.each do |method|
      assert(@obj.methods.include?(method))
    end
  end

end
end
