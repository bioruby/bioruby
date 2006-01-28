#
# test/unit/bio/io/test_fastacmd.rb - Unit test for Bio::Blast::Fastacmd.
#
#   Copyright (C) 2006 Mitsuteru Nakao <n@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: test_fastacmd.rb,v 1.1 2006/01/28 08:05:52 nakao Exp $
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
