#
# test/unit/bio/db/embl/test_uniprot.rb - Unit test for Bio::UniProt
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
#  $Id: test_uniprot.rb,v 1.3 2005/12/18 17:43:51 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/embl/uniprot'

module Bio
  class TestUniProt < Test::Unit::TestCase

    def setup
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      data = File.open(File.join(bioruby_root, 'test', 'data', 'uniprot', 'p53_human.uniprot')).read
      @obj = Bio::UniProt.new(data)
    end

    def test_gene_name
      assert_equal('TP53', @obj.gene_name)
    end

  end
end
