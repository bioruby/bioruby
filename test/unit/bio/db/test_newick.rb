#
# = test/bio/db/newick.rb - Unit test for Bio::Newick
#
# Copyright::   Copyright (C) 2004-2006
#               Daniel Amelang <dan@amelang.net>
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
# $Id: test_newick.rb,v 1.6 2007/12/12 16:06:22 ngoto Exp $
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
      leaf = tree.get_node_by_name('HexFLZ83')
      assert_equal(3, tree.ancestors(leaf).size)
      assert_equal(tree.path(tree.root, leaf)[1], tree.ancestors(leaf)[1])
      assert_equal(0.00217, tree.get_edge(leaf, tree.parent(leaf)).distance)
      assert_equal("HexFLZ83", leaf.name)
    end

  end #class TestNewick

  class TestNewick2 < Test::Unit::TestCase

    TREE_STRING = <<-END_OF_TREE_STRING
    (
      (
        'this is test':0.0625,
        'test2 (abc, def)':0.125
      ) 'internal node''s name' : 0.25,
      (
        '''':0.03125,
        (
          'ABCAC_HUMAN [ABC superfamily]':0.015625,
          hypothetical_protein:0.5
        ) ABC : 0.25 [99]
      ) test3 :0.5
    )root;
    END_OF_TREE_STRING

    def test_string_tree
      newick = Bio::Newick.new(TREE_STRING)
      tree = newick.tree
      assert_equal('root', tree.root.name)
      assert_equal([ 
                    "this is test",
                    "test2 (abc, def)",
                    "internal node\'s name",
                    "\'",
                    "ABCAC_HUMAN [ABC superfamily]",
                    "hypothetical protein",
                    "ABC",
                    "test3",
                    "root"
                   ].sort,
                   tree.nodes.collect { |x| x.name }.sort)

      assert_equal(tree.children(tree.root).collect { |x| x.name }.sort,
                   [ "internal node\'s name", "test3" ])

      node = tree.get_node_by_name('ABC')
      assert_equal(99, node.bootstrap)

      assert_equal(1.5625,
                   tree.distance(tree.get_node_by_name('hypothetical protein'),
                                 tree.get_node_by_name('this is test')))
    end

  end #class TestNewick2

  class TestNewickPrivate < Test::Unit::TestCase
    def setup
      @newick = Bio::Newick.new('') # dummy data
    end

    def test_parse_newick_leaf
      leaf_tokens = [ "A:B _C(D,E)F\'s G[H]", :":", '0.5', :"[",
                      "&&NHX", :":", "S=human", :":", "E=1.1.1.1", :"]" ]
      node = Bio::Tree::Node.new
      edge = Bio::Tree::Edge.new
      options = {}

      assert_equal(true,
                   @newick.instance_eval do
                     __parse_newick_leaf(leaf_tokens, node, edge, options)
                   end)

      assert_equal(:nhx, @newick.options[:original_format])
      assert_equal("A:B _C(D,E)F\'s G[H]", node.name)
      assert_equal("human", node.scientific_name)
      assert_equal("1.1.1.1", node.ec_number)
      assert_equal(0.5, edge.distance)
    end

    def test_parse_newick_get_tokens_for_leaf
      input = [ "A:B _C(D,E)F\'s G[H]", :":", '0.5', :"[",
                "&&NHX", :":", "S=human", :":", "E=1.1.1.1", :"]",
                :",", :"(", "bbb", :":", "0.2", :")" ]
      leaf_should_be = [ "A:B _C(D,E)F\'s G[H]", :":", '0.5', :"[",
                "&&NHX", :":", "S=human", :":", "E=1.1.1.1", :"]" ]
      rest_should_be = [ :",", :"(", "bbb", :":", "0.2", :")" ]

      assert_equal(leaf_should_be, 
                   @newick.instance_eval do
                     __parse_newick_get_tokens_for_leaf(input)
                   end)

      assert_equal(rest_should_be, input)
    end

    def test_parse_newick_tokenize
      examples =
        [
         [ 
          '(a,b);', # input
          [ :"(", 'a', :",", 'b', :")" ], # normal parser result
          [ :"(", 'a', :",", 'b', :")" ], # naive parser result
         ],
         [
          # input
          "(\'A:B _C(D,E)F\'\'s G[H]\':0.5[&&NHX:S=human:E=1.1.1.1], \n(bbb:0.2, c_d_e[&&NHX:B=100]);",
            # normal parser result
            [ :"(", "A:B _C(D,E)F\'s G[H]", :":", '0.5', :"[",
            "&&NHX", :":", "S=human", :":", "E=1.1.1.1", :"]",
            :",", :"(", "bbb", :":", "0.2", :",", 
            "c d e", :"[", "&&NHX", :":", "B=100", :"]", :")" ],
            # naive parser result
            [ :"(", "\'A", :":", "B _C", :"(", "D", :",", "E",
            :")", "F\'\'s G", :"[", "H", :"]", "\'", :":", '0.5', :"[",
            "&&NHX", :":", "S=human", :":", "E=1.1.1.1", :"]",
            :",", :"(", "bbb", :":", "0.2", :",", 
            "c_d_e", :"[", "&&NHX", :":", "B=100", :"]", :")" ]
          ]
        ]

      examples.each do |a|
        # normal parser
        assert_equal(a[1],
                     @newick.instance_eval do
                       __parse_newick_tokenize(a[0], {})
                     end)

        # naive parser
        assert_equal(a[2],
                     @newick.instance_eval do
                       __parse_newick_tokenize(a[0], { :parser => :naive })
                     end)
      end
    end
  end #class TestNewickPrivate

  class TestBioTreeOutputPrivate < Test::Unit::TestCase

    def setup
      @tree = Bio::Tree.new
    end

    def test_to_newick_format_label
      # unquoted_label
      assert_equal('ABC', @tree.instance_eval do
                     __to_newick_format_label('ABC', {})
                   end)

      # unquoted_label, replaces blank to underscore
      assert_equal('A_B_C', @tree.instance_eval do
                     __to_newick_format_label('A B C', {})
                   end)

      # quoted_label example 1
      assert_equal("\'A B_C\'", @tree.instance_eval do
                     __to_newick_format_label('A B_C', {})
                   end)

      # quoted_label example 2
      assert_equal("\'A(B),C\'", @tree.instance_eval do
                     __to_newick_format_label('A(B),C', {})
                   end)

      # normal formatter
      assert_equal("\'A_B_C\'", @tree.instance_eval do
                     __to_newick_format_label('A_B_C', {})
                   end)
      # naive formatter
      assert_equal("A_B_C", @tree.instance_eval do
                     __to_newick_format_label('A_B_C',
                                              { :parser => :naive })
                   end)
    end


    def test_to_newick_format_leaf
      node = Bio::Tree::Node.new('ABC')
      edge = Bio::Tree::Edge.new(0.5)

      assert_equal('ABC:0.5', @tree.instance_eval do
                     __to_newick_format_leaf(node, edge, {})
                   end)

      # disable branch length
      assert_equal('ABC', @tree.instance_eval do
                     __to_newick_format_leaf(node, edge,
                                             { :branch_length_style =>
                                               :disabled })
                   end)

      node.bootstrap = 98
      # default: molphy style bootstrap
      assert_equal('ABC:0.5[98]', @tree.instance_eval do
                     __to_newick_format_leaf(node, edge, {})
                   end)
      # force molphy style bootstrap
      assert_equal('ABC:0.5[98]', @tree.instance_eval do
                     __to_newick_format_leaf(node, edge,
                                             { :bootstrap_style => :molphy })
                   end)
      # disable bootstrap output
      assert_equal('ABC:0.5', @tree.instance_eval do
                     __to_newick_format_leaf(node, edge,
                                             { :bootstrap_style =>
                                               :disabled })
                   end)

      # force traditional bootstrap style
      assert_equal('ABC98:0.5', @tree.instance_eval do
                     __to_newick_format_leaf(node, edge,
                                             { :bootstrap_style =>
                                               :traditional })
                   end)
      # normally, when traditional style, no node name allowed for the node
      node2 = Bio::Tree::Node.new
      node2.bootstrap = 98
      assert_equal('98:0.5', @tree.instance_eval do
                     __to_newick_format_leaf(node2, edge,
                                             { :bootstrap_style =>
                                               :traditional })
                   end)
      
    end

    def test_to_newick_format_leaf_NHX
      node = Bio::Tree::Node.new('ADH')
      edge = Bio::Tree::Edge.new(0.5)
      node.bootstrap = 98
      node.ec_number = '1.1.1.1'
      node.scientific_name = 'human'
      node.taxonomy_id = '9606'
      node.events.push :gene_duplication
      edge.log_likelihood = 1.5
      edge.width = 3

      str = 'ADH:0.5[&&NHX:B=98:D=Y:E=1.1.1.1:L=1.5:S=human:T=9606:W=3]'
      assert_equal(str, @tree.instance_eval do
                     __to_newick_format_leaf_NHX(node, edge, {})
                   end)
    end

  end #class TestBioTreeOutputPrivate

end #module Bio
