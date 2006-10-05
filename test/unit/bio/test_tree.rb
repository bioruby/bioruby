#
# = test/bio/test_phylogenetictree.rb - unit test for Bio::PhylogeneticTree
#
# Copyright::   Copyright (C) 2006
#               Naohisa Goto <ng@bioruby.org>
# License::     Ruby's
#
# $Id: test_tree.rb,v 1.1 2006/10/05 13:38:22 ngoto Exp $
#

require 'test/unit'

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), [".."] * 3, "lib")).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio'
require 'bio/phylogenetictree'

module Bio
  class TestPhylogeneticTreeEdge < Test::Unit::TestCase
    def setup
      @obj = Bio::PhylogeneticTree::Edge.new(123.45)
    end

    def test_initialize
      assert_nothing_raised { Bio::PhylogeneticTree::Edge.new }
      assert_equal(1.23, Bio::PhylogeneticTree::Edge.new(1.23).distance)
      assert_equal(12.3, Bio::PhylogeneticTree::Edge.new('12.3').distance)
    end

    def test_distance
      assert_equal(123.45, @obj.distance)
    end

    def test_distance_string
      assert_equal("123.45", @obj.distance_string)
    end

    def test_distance=()
      @obj.distance = 678.9
      assert_equal(678.9, @obj.distance)
      assert_equal("678.9", @obj.distance_string)
      @obj.distance = nil
      assert_equal(nil, @obj.distance)
      assert_equal(nil, @obj.distance_string)
    end

    def test_distance_string=()
      @obj.distance_string = "678.9"
      assert_equal(678.9, @obj.distance)
      assert_equal("678.9", @obj.distance_string)
      @obj.distance_string = nil
      assert_equal(nil, @obj.distance)
      assert_equal(nil, @obj.distance_string)
    end

    def test_inspect
      assert_equal("<Edge distance=123.45>", @obj.inspect)
    end

    def test_to_s
      assert_equal("123.45", @obj.to_s)
    end
  end #class TestPhylogeneticTreeEdge

  class TestPhylogeneticTreeNode < Test::Unit::TestCase
    def setup
      @obj = Bio::PhylogeneticTree::Node.new
    end

    def test_initialize
      assert_nothing_raised { Bio::PhylogeneticTree::Node.new }
      a = nil
      assert_nothing_raised { a = Bio::PhylogeneticTree::Node.new('mouse') }
      assert_equal('mouse', a.name)
    end

    def test_name
      assert_equal(nil, @obj.name)
      @obj.name = 'human'
      assert_equal('human', @obj.name)
    end

    def test_bootstrap
      assert_equal(nil, @obj.bootstrap)
    end

    def test_bootstrap_string
      assert_equal(nil, @obj.bootstrap_string)
    end

    def test_bootstrap=()
      @obj.bootstrap = 98
      assert_equal(98, @obj.bootstrap)
      assert_equal('98', @obj.bootstrap_string)
      @obj.bootstrap = nil
      assert_equal(nil, @obj.bootstrap)
      assert_equal(nil, @obj.bootstrap_string)
    end

    def test_bootstrap_string=()
      @obj.bootstrap_string = '98'
      assert_equal(98, @obj.bootstrap)
      assert_equal('98', @obj.bootstrap_string)
      @obj.bootstrap_string = '99.98'
      assert_equal(99.98, @obj.bootstrap)
      assert_equal('99.98', @obj.bootstrap_string)
      @obj.bootstrap = nil
      assert_equal(nil, @obj.bootstrap)
      assert_equal(nil, @obj.bootstrap_string)
    end

    def test_inspect
      @obj.name = 'human'
      assert_equal('(Node:"human")', @obj.inspect)
      @obj.bootstrap = 99.98
      assert_equal('(Node:"human" bootstrap=99.98)', @obj.inspect)
    end

    def test_to_s
      @obj.name = 'human'
      assert_equal('human', @obj.to_s)
    end
  end #class TestPhylogeneticTreeNode

  class TestPhylogeneticTree < Test::Unit::TestCase
    def setup
      @tree  = Bio::PhylogeneticTree.new
    end

    def test_get_edge_distance
      edge = Bio::PhylogeneticTree::Edge.new
      assert_equal(nil, @tree.get_edge_distance(edge))
      edge = Bio::PhylogeneticTree::Edge.new(12.34)
      assert_equal(12.34, @tree.get_edge_distance(edge))
      assert_equal(12.34, @tree.get_edge_distance(12.34))
    end

    def test_get_edge_distance_string
      edge = Bio::PhylogeneticTree::Edge.new
      assert_equal(nil, @tree.get_edge_distance_string(edge))
      edge = Bio::PhylogeneticTree::Edge.new(12.34)
      assert_equal("12.34", @tree.get_edge_distance_string(edge))
      assert_equal("12.34", @tree.get_edge_distance_string(12.34))
    end

    def test_get_node_name
      node = Bio::PhylogeneticTree::Node.new
      assert_equal(nil, @tree.get_node_name(node))
      node.name = 'human'
      assert_equal('human', @tree.get_node_name(node))
    end

    def test_initialize
      assert_nothing_raised { Bio::PhylogeneticTree.new }
      assert_nothing_raised { Bio::PhylogeneticTree.new(@tree) }
    end

    def test_root
      assert_equal(nil, @tree.root)
    end

    def test_root=()
      assert_equal(nil, @tree.root)
      node = Bio::PhylogeneticTree::Node.new
      @tree.root = node
      assert_equal(node, @tree.root)
    end

    def test_options
      assert_equal({}, @tree.options)
      @tree.options[:bootstrap_style] = :traditional
      assert_equal(:traditional, @tree.options[:bootstrap_style])
    end

  end #class TestPhylogeneticTree

  class TestPhylogeneticTree2 < Test::Unit::TestCase
    def setup
      # Note that below data is NOT real. The distances are random.
      @tree = Bio::PhylogeneticTree.new
      mouse      = Bio::PhylogeneticTree::Node.new('mouse')
      rat        = Bio::PhylogeneticTree::Node.new('rat')
      rodents    = Bio::PhylogeneticTree::Node.new('rodents')
      human      = Bio::PhylogeneticTree::Node.new('human')
      chimpanzee = Bio::PhylogeneticTree::Node.new('chimpanzee')
      primates   = Bio::PhylogeneticTree::Node.new('primates')
      mammals    = Bio::PhylogeneticTree::Node.new('mammals')
      @tree.add_edge(rodents,  mouse,
                     Bio::PhylogeneticTree::Edge.new(0.0968))
      @tree.add_edge(rodents,  rat, 
                     Bio::PhylogeneticTree::Edge.new(0.1125))
      @tree.add_edge(mammals,  rodents, 
                     Bio::PhylogeneticTree::Edge.new(0.2560))
      @tree.add_edge(primates, human, 
                     Bio::PhylogeneticTree::Edge.new(0.0386))
      @tree.add_edge(primates, chimpanzee, 
                     Bio::PhylogeneticTree::Edge.new(0.0503))
      @tree.add_edge(mammals,  primates, 
                     Bio::PhylogeneticTree::Edge.new(0.2235))
      @nodes =
        [ mouse, rat, rodents, human, chimpanzee, primates, mammals ]
    end

    def test_clear
      assert_nothing_raised { @tree.clear }
      assert_equal(0, @tree.number_of_nodes)
      assert_equal(0, @tree.number_of_edges)
    end

    def test_nodes
      nodes = @nodes.sort { |a, b| a.__id__ <=> b.__id__ }
      assert_equal(nodes, @tree.nodes.sort { |a, b| a.__id__ <=> b.__id__ })
    end

    def test_number_of_nodes
      assert_equal(7, @tree.number_of_nodes)
    end

    def test_each_node
    end

  end #class TestPhylogeneticTree2

end #module Bio

