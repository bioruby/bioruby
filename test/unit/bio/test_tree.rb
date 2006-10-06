#
# = test/bio/test_phylogenetictree.rb - unit test for Bio::PhylogeneticTree
#
# Copyright::   Copyright (C) 2006
#               Naohisa Goto <ng@bioruby.org>
# License::     Ruby's
#
# $Id: test_tree.rb,v 1.2 2006/10/06 14:18:51 ngoto Exp $
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
      @mouse      = Bio::PhylogeneticTree::Node.new('mouse')
      @rat        = Bio::PhylogeneticTree::Node.new('rat')
      @rodents    = Bio::PhylogeneticTree::Node.new('rodents')
      @human      = Bio::PhylogeneticTree::Node.new('human')
      @chimpanzee = Bio::PhylogeneticTree::Node.new('chimpanzee')
      @primates   = Bio::PhylogeneticTree::Node.new('primates')
      @mammals    = Bio::PhylogeneticTree::Node.new('mammals')
      @nodes =
        [ @mouse, @rat, @rodents, @human, @chimpanzee, @primates, @mammals ]
      @edge_rodents_mouse   = Bio::PhylogeneticTree::Edge.new(0.0968)
      @edge_rodents_rat     = Bio::PhylogeneticTree::Edge.new(0.1125)
      @edge_mammals_rodents = Bio::PhylogeneticTree::Edge.new(0.2560)
      @edge_primates_human  = Bio::PhylogeneticTree::Edge.new(0.0386)
      @edge_primates_chimpanzee = Bio::PhylogeneticTree::Edge.new(0.0503)
      @edge_mammals_primates    = Bio::PhylogeneticTree::Edge.new(0.2235)
      @edges = [
        [ @rodents,  @mouse,      @edge_rodents_mouse       ],
        [ @rodents,  @rat,        @edge_rodents_rat         ],
        [ @mammals,  @rodents,    @edge_mammals_rodents     ],
        [ @primates, @human,      @edge_primates_human      ],
        [ @primates, @chimpanzee, @edge_primates_chimpanzee ],
        [ @mammals,  @primates,   @edge_mammals_primates    ]
      ]
      @edges.each do |a|
        @tree.add_edge(*a)
      end

      @by_id = Proc.new { |a, b| a.__id__ <=> b.__id__ }
    end

    def test_clear
      assert_nothing_raised { @tree.clear }
      assert_equal(0, @tree.number_of_nodes)
      assert_equal(0, @tree.number_of_edges)
    end

    def test_nodes
      nodes = @nodes.sort(&@by_id)
      assert_equal(nodes, @tree.nodes.sort(&@by_id))
    end

    def test_number_of_nodes
      assert_equal(7, @tree.number_of_nodes)
    end

    def test_each_node
      @tree.each_node do |x|
        assert_not_nil(@nodes.delete(x))
      end
      assert_equal(true, @nodes.empty?)
    end

    def test_each_edge
      @tree.each_edge do |source, target, edge|
        assert_not_nil(@edges.delete([ source, target, edge ]))
      end
      assert_equal(true, @edges.empty?)
    end

    def test_edges
      edges = @edges.sort { |a, b| a[-1].distance <=> b[-1].distance }
      assert_equal(edges,
                   @tree.edges.sort {
                     |a, b| a[-1].distance <=> b[-1].distance })
    end

    def test_number_of_edges
      assert_equal(@edges.size, @tree.number_of_edges)
    end

    def test_adjacent_nodes
      assert_equal([ @rodents ], @tree.adjacent_nodes(@mouse))
      assert_equal([ @rodents ], @tree.adjacent_nodes(@rat))
      assert_equal([ @primates ], @tree.adjacent_nodes(@human))
      assert_equal([ @primates ], @tree.adjacent_nodes(@chimpanzee))
      assert_equal([ @mouse, @rat, @mammals ].sort(&@by_id),
                   @tree.adjacent_nodes(@rodents).sort(&@by_id))
      assert_equal([ @human, @chimpanzee, @mammals ].sort(&@by_id),
                   @tree.adjacent_nodes(@primates).sort(&@by_id))
      assert_equal([ @rodents, @primates ].sort(&@by_id),
                   @tree.adjacent_nodes(@mammals).sort(&@by_id))
      # test for not existed nodes
      assert_equal([], @tree.adjacent_nodes(Bio::PhylogeneticTree::Node.new))
    end

    def test_out_edges
      assert_equal([[ @mouse, @rodents, @edge_rodents_mouse ]],
                   @tree.out_edges(@mouse))
      assert_equal([[ @rat, @rodents, @edge_rodents_rat ]],
                   @tree.out_edges(@rat))
      assert_equal([[ @human, @primates, @edge_primates_human ]],
                   @tree.out_edges(@human))
      assert_equal([[ @chimpanzee, @primates, @edge_primates_chimpanzee ]],
                   @tree.out_edges(@chimpanzee))

      adjacents = [ @mouse, @rat, @mammals ]
      edges = [ @edge_rodents_mouse, @edge_rodents_rat, @edge_mammals_rodents ]
      @tree.out_edges(@rodents).each do |a|
        assert_equal(@rodents, a[0])
        assert_not_nil(i = adjacents.index(a[1]))
        assert_equal(edges[i], a[2])
        adjacents.delete_at(i)
        edges.delete_at(i)
      end
      assert_equal(true, adjacents.empty?)
      assert_equal(true, edges.empty?)

      adjacents = [ @human, @chimpanzee, @mammals ]
      edges = [ @edge_primates_human, @edge_primates_chimpanzee,
        @edge_mammals_primates ]
      @tree.out_edges(@primates).each do |a|
        assert_equal(@primates, a[0])
        assert_not_nil(i = adjacents.index(a[1]))
        assert_equal(edges[i], a[2])
        adjacents.delete_at(i)
        edges.delete_at(i)
      end
      assert_equal(true, adjacents.empty?)
      assert_equal(true, edges.empty?)

      adjacents = [ @rodents, @primates ]
      edges = [ @edge_mammals_rodents, @edge_mammals_primates ]
      @tree.out_edges(@mammals).each do |a|
        assert_equal(@mammals, a[0])
        assert_not_nil(i = adjacents.index(a[1]))
        assert_equal(edges[i], a[2])
        adjacents.delete_at(i)
        edges.delete_at(i)
      end
      assert_equal(true, adjacents.empty?)
      assert_equal(true, edges.empty?)

      # test for not existed nodes
      assert_equal([], @tree.out_edges(Bio::PhylogeneticTree::Node.new))
    end

    def test_each_out_edge
      flag = nil
      r = @tree.each_out_edge(@mouse) do |src, tgt, edge|
        assert_equal(@mouse, src)
        assert_equal(@rodents, tgt)
        assert_equal(@edge_rodents_mouse, edge)
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(true, flag)

      flag = nil
      r =  @tree.each_out_edge(@rat) do |src, tgt, edge|
        assert_equal(@rat, src)
        assert_equal(@rodents, tgt)
        assert_equal(@edge_rodents_rat, edge)
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(true, flag)

      flag = nil
      r = @tree.each_out_edge(@human) do |src, tgt, edge|
        assert_equal(@human, src)
        assert_equal(@primates, tgt)
        assert_equal(@edge_primates_human, edge)
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(true, flag)

      flag = nil
      r = @tree.each_out_edge(@chimpanzee) do |src, tgt, edge|
        assert_equal(@chimpanzee, src)
        assert_equal(@primates, tgt)
        assert_equal(@edge_primates_chimpanzee, edge)
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(true, flag)

      adjacents = [ @mouse, @rat, @mammals ]
      edges = [ @edge_rodents_mouse, @edge_rodents_rat, @edge_mammals_rodents ]
      @tree.each_out_edge(@rodents) do |src, tgt, edge|
        assert_equal(@rodents, src)
        assert_not_nil(i = adjacents.index(tgt))
        assert_equal(edges[i], edge)
        adjacents.delete_at(i)
        edges.delete_at(i)
      end
      assert_equal(true, adjacents.empty?)
      assert_equal(true, edges.empty?)

      adjacents = [ @human, @chimpanzee, @mammals ]
      edges = [ @edge_primates_human, @edge_primates_chimpanzee,
        @edge_mammals_primates ]
      @tree.each_out_edge(@primates) do |src, tgt, edge|
        assert_equal(@primates, src)
        assert_not_nil(i = adjacents.index(tgt))
        assert_equal(edges[i], edge)
        adjacents.delete_at(i)
        edges.delete_at(i)
      end
      assert_equal(true, adjacents.empty?)
      assert_equal(true, edges.empty?)

      adjacents = [ @rodents, @primates ]
      edges = [ @edge_mammals_rodents, @edge_mammals_primates ]
      @tree.each_out_edge(@mammals) do |src, tgt, edge|
        assert_equal(@mammals, src)
        assert_not_nil(i = adjacents.index(tgt))
        assert_equal(edges[i], edge)
        adjacents.delete_at(i)
        edges.delete_at(i)
      end
      assert_equal(true, adjacents.empty?)
      assert_equal(true, edges.empty?)

      # test for not existed nodes
      flag = nil
      node = Bio::PhylogeneticTree::Node.new
      r = @tree.each_out_edge(node) do |src, tgt, edge|
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(nil, flag)
    end

  end #class TestPhylogeneticTree2

end #module Bio

