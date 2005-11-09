#
# test/unit/bio/db/kegg/test_genes.rb - Unit test for Bio::KEGG::GENES
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
#  $Id: test_genes.rb,v 1.3 2005/11/09 13:20:09 nakao Exp $
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
