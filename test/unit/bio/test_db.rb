#
# test/unit/bio/test_db.rb - Unit test for Bio::DB
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_db.rb,v 1.4 2007/04/05 23:35:42 trevor Exp $
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
      assert_equal(["TAG"], @obj.tags)
    end
    
    def test_exists
      assert_equal(true, @obj.exists?("TAG"))
    end

    def test_get
      assert_equal("TAG value1\n    value2", @obj.get("TAG"))
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
      assert_equal('locus', @obj.fetch("LOCUS"))
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
      assert_equal('id', @obj.fetch("ID"))
      assert_equal('cc1 cc2', @obj.fetch("CC"))
    end

    def test_p_entry2hash
    end
  end
end
