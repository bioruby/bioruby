#
# test/unit/bio/test_db.rb - Unit test for Bio::DB
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
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
#  $Id: test_db.rb,v 1.1 2005/09/24 23:23:00 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db'

module Bio
  class TestDB < Test::Unit::TestCase
    def setup
      
     @obj = Bio::DB.new
      @obj.instance_eval { @orig = {"TAG" => "TAG value1\n    value2"} }
    end

    def test_open
      assert(Bio::DB.respond_to?(:open))
    end
 
    def test_entry_id
      assert_raises(NotImplementedError) { @obj.entry_id }
    end

    def test_tags
      assert_equal(@obj.tags, ["TAG"])
    end
    
    def test_exists
      assert_equal(@obj.exists?("TAG"), true)
    end

    def test_get
      assert_equal(@obj.get("TAG"), "TAG value1\n    value2")
    end

    def test_fetch
      assert(@obj.fetch("TAG"))
      assert(@obj.fetch("TAG", 1))
    end
  end


  class TestNCBIDB < Test::Unit::TestCase
    def setup
      entry =<<END
LOCUS     locus
END
      @obj = Bio::NCBIDB.new(entry, 10)
    end

    def test_fetch
      assert_equal(@obj.fetch("LOCUS"), 'locus')
    end

    def test_p_toptag2array
    end

    def test_p_subtag2array
    end

    def test_p_entry2hash
    end
  end

#  class TestKEGGDB < Test::Unit::TestCase
#  end
  
  class TestEMBLDB < Test::Unit::TestCase
    def setup
      @entry =<<END
ID id
XX
CC cc1
CC cc2
END
      @obj = Bio::EMBLDB.new(@entry, 2)
    end

    def test_fetch
      assert_equal(@obj.fetch("ID"), 'id')
      assert_equal(@obj.fetch("CC"), 'cc1 cc2')
    end

    def test_p_entry2hash
    end
  end
end
