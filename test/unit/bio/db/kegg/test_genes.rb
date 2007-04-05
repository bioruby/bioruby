#
# test/unit/bio/db/kegg/test_genes.rb - Unit test for Bio::KEGG::GENES
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_genes.rb,v 1.5 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/kegg/genes'

module Bio
  class TestGenesDblinks < Test::Unit::TestCase

    def setup
      entry =<<END
DBLINKS     TIGR: At3g05560
            NCBI-GI: 15230008  42572267
END
      @obj = Bio::KEGG::GENES.new(entry)
    end

    def test_data
      str = "DBLINKS     TIGR: At3g05560\n            NCBI-GI: 15230008  42572267"
      assert_equal(str, @obj.instance_eval('get("DBLINKS")'))
    end

    def test_dblinks_0
      assert_equal(Hash, @obj.dblinks.class)
    end

    def test_dblinks_1
      assert_equal(['At3g05560'], @obj.dblinks['TIGR'])
    end

    def test_dblinks_2
      assert_equal(['15230008', '42572267'], @obj.dblinks['NCBI-GI'])
    end
  end
end
