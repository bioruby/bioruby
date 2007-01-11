#
# = test/bio/db/newick.rb - Unit test for Bio::Newick
#
# Copyright::   Copyright (C) 2004-2006
#               Daniel Amelang <dan@amelang.net>
#               Naohisa Goto <ng@bioruby.org>
# License::     Ruby's
#
# $Id: test_newick.rb,v 1.3 2007/01/11 14:35:32 ngoto Exp $
#

require 'test/unit'

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), [".."] * 4, "lib")).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio'
require 'bio/tree'
require 'bio/db/newick'

module Bio
  class TestNewick < Test::Unit::TestCase

    TREE_STRING = <<-END_OF_TREE_STRING
    (
      (
        HexLEZ35:0.00263,
        HexMCZ42:0.00788
      ):0.00854,
      (
        HexFLZ48:0.00457,
        (
          HexFLZ83:0.00217,
          HexFLZ13:0.00574
        ):0.00100
      ):0.04692,
      HexLEZ73:0.00268
    )[0.1250];
    END_OF_TREE_STRING

    def test_string_tree
      newick = Bio::Newick.new(TREE_STRING)
      tree = newick.tree
      assert_equal(3, tree.children(tree.root).size)
      assert_equal(9, tree.descendents(tree.root).size)
      assert_equal(6, tree.leaves.size)
      leaf = tree.nodes.find { |x| x.name == 'HexFLZ83' }
      assert_equal(3, tree.ancestors(leaf).size)
      assert_equal(tree.path(tree.root, leaf)[1], tree.ancestors(leaf)[1])
      assert_equal(0.00217, tree.get_edge(leaf, tree.parent(leaf)).distance)
      assert_equal("HexFLZ83", leaf.name)
    end

  end #class TestNewick
end #module Bio
