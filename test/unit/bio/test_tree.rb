#
# = test/bio/test_tree.rb - unit test for Bio::Tree
#
# Copyright::   Copyright (C) 2006, 2010
#               Naohisa Goto <ng@bioruby.org>
#               Copyright (C) 2010 Kazuhiro Hayashi <k.hayashi.info@gmail.com>
# License::     The Ruby License
#
# $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 2,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/tree'

module Bio
  class TestTreeEdge < Test::Unit::TestCase
    def setup
      @obj = Bio::Tree::Edge.new(123.45)
    end

    def test_initialize
      assert_nothing_raised { Bio::Tree::Edge.new }
      assert_equal(1.23, Bio::Tree::Edge.new(1.23).distance)
      assert_equal(12.3, Bio::Tree::Edge.new('12.3').distance)
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
  end #class TestTreeEdge

  class TestTreeNode < Test::Unit::TestCase
    def setup
      @obj = Bio::Tree::Node.new
    end

    def test_initialize
      assert_nothing_raised { Bio::Tree::Node.new }
      a = nil
      assert_nothing_raised { a = Bio::Tree::Node.new('mouse') }
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
  end #class TestTreeNode

  class TestTree < Test::Unit::TestCase
    def setup
      @tree  = Bio::Tree.new
    end

    def test_get_edge_distance
      edge = Bio::Tree::Edge.new
      assert_equal(nil, @tree.get_edge_distance(edge))
      edge = Bio::Tree::Edge.new(12.34)
      assert_equal(12.34, @tree.get_edge_distance(edge))
      assert_equal(12.34, @tree.get_edge_distance(12.34))
    end

    def test_get_edge_distance_string
      edge = Bio::Tree::Edge.new
      assert_equal(nil, @tree.get_edge_distance_string(edge))
      edge = Bio::Tree::Edge.new(12.34)
      assert_equal("12.34", @tree.get_edge_distance_string(edge))
      assert_equal("12.34", @tree.get_edge_distance_string(12.34))
    end

    def test_get_node_name
      node = Bio::Tree::Node.new
      assert_equal(nil, @tree.get_node_name(node))
      node.name = 'human'
      assert_equal('human', @tree.get_node_name(node))
    end

    def test_initialize
      assert_nothing_raised { Bio::Tree.new }
      assert_nothing_raised { Bio::Tree.new(@tree) }
    end

    def test_root
      assert_equal(nil, @tree.root)
    end

    def test_root=()
      assert_equal(nil, @tree.root)
      node = Bio::Tree::Node.new
      @tree.root = node
      assert_equal(node, @tree.root)
    end

    def test_options
      assert_equal({}, @tree.options)
      @tree.options[:bootstrap_style] = :traditional
      assert_equal(:traditional, @tree.options[:bootstrap_style])
    end

  end #class TestTree

  class TestTree2 < Test::Unit::TestCase
    def setup
      # Note that below data is NOT real. The distances are random.
      @tree = Bio::Tree.new
      @mouse      = Bio::Tree::Node.new('mouse')
      @rat        = Bio::Tree::Node.new('rat')
      @rodents    = Bio::Tree::Node.new('rodents')
      @human      = Bio::Tree::Node.new('human')
      @chimpanzee = Bio::Tree::Node.new('chimpanzee')
      @primates   = Bio::Tree::Node.new('primates')
      @mammals    = Bio::Tree::Node.new('mammals')
      @nodes =
        [ @mouse, @rat, @rodents, @human, @chimpanzee, @primates, @mammals ]
      @edge_rodents_mouse   = Bio::Tree::Edge.new(0.0968)
      @edge_rodents_rat     = Bio::Tree::Edge.new(0.1125)
      @edge_mammals_rodents = Bio::Tree::Edge.new(0.2560)
      @edge_primates_human  = Bio::Tree::Edge.new(0.0386)
      @edge_primates_chimpanzee = Bio::Tree::Edge.new(0.0503)
      @edge_mammals_primates    = Bio::Tree::Edge.new(0.2235)
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
    end

    def test_adjacent_nodes_nonexistent
      # test for not existed nodes
      assert_equal([], @tree.adjacent_nodes(Bio::Tree::Node.new))
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
    end

    def test_out_edges_rodents
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
    end

    def test_out_edges_primates
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
    end

    def test_out_edges_mammals
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
    end

    def test_out_edges_nonexistent
      # test for not existed nodes
      assert_equal([], @tree.out_edges(Bio::Tree::Node.new))
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
    end

    def test_each_out_edge_rat
      flag = nil
      r =  @tree.each_out_edge(@rat) do |src, tgt, edge|
        assert_equal(@rat, src)
        assert_equal(@rodents, tgt)
        assert_equal(@edge_rodents_rat, edge)
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(true, flag)
    end

    def test_each_out_edge_human
      flag = nil
      r = @tree.each_out_edge(@human) do |src, tgt, edge|
        assert_equal(@human, src)
        assert_equal(@primates, tgt)
        assert_equal(@edge_primates_human, edge)
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(true, flag)
    end

    def test_each_out_edge_chimpanzee
      flag = nil
      r = @tree.each_out_edge(@chimpanzee) do |src, tgt, edge|
        assert_equal(@chimpanzee, src)
        assert_equal(@primates, tgt)
        assert_equal(@edge_primates_chimpanzee, edge)
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(true, flag)
    end

    def test_each_out_edge_rodents
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
    end

    def test_each_out_edge_primates
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
    end

    def test_each_out_edge_mammals
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
    end

    def test_each_out_edge_nonexistent
      # test for not existed nodes
      flag = nil
      node = Bio::Tree::Node.new
      r = @tree.each_out_edge(node) do |src, tgt, edge|
        flag = true
      end
      assert_equal(@tree, r)
      assert_equal(nil, flag)
    end

    def test_out_degree
      assert_equal(1, @tree.out_degree(@mouse))
      assert_equal(1, @tree.out_degree(@rat))
      assert_equal(3, @tree.out_degree(@rodents))
      assert_equal(1, @tree.out_degree(@human))
      assert_equal(1, @tree.out_degree(@chimpanzee))
      assert_equal(3, @tree.out_degree(@primates))
      assert_equal(2, @tree.out_degree(@mammals))
    end

    def test_out_degree_nonexistent
      assert_equal(0, @tree.out_degree(Bio::Tree::Node.new))
    end

    def test_get_edge
      assert_not_nil(@tree.get_edge(@rodents, @mouse))
      assert_not_nil(@tree.get_edge(@mouse, @rodents))
      assert_equal(@edge_rodents_mouse, @tree.get_edge(@rodents, @mouse))
      assert_equal(@edge_rodents_mouse, @tree.get_edge(@mouse, @rodents))

      assert_not_nil(@tree.get_edge(@rodents, @rat))
      assert_not_nil(@tree.get_edge(@rat, @rodents))
      assert_equal(@edge_rodents_rat, @tree.get_edge(@rodents, @rat))
      assert_equal(@edge_rodents_rat, @tree.get_edge(@rat, @rodents))

      assert_not_nil(@tree.get_edge(@mammals, @rodents))
      assert_not_nil(@tree.get_edge(@rodents, @mammals))
      assert_equal(@edge_mammals_rodents, @tree.get_edge(@mammals, @rodents))
      assert_equal(@edge_mammals_rodents, @tree.get_edge(@rodents, @mammals))

      assert_not_nil(@tree.get_edge(@primates, @human))
      assert_not_nil(@tree.get_edge(@human, @primates))
      assert_equal(@edge_primates_human, @tree.get_edge(@primates, @human))
      assert_equal(@edge_primates_human, @tree.get_edge(@human, @primates))

      assert_not_nil(@tree.get_edge(@primates, @chimpanzee))
      assert_not_nil(@tree.get_edge(@chimpanzee, @primates))
      assert_equal(@edge_primates_chimpanzee, @tree.get_edge(@primates, @chimpanzee))
      assert_equal(@edge_primates_chimpanzee, @tree.get_edge(@chimpanzee, @primates))

      assert_not_nil(@tree.get_edge(@mammals, @primates))
      assert_not_nil(@tree.get_edge(@primates, @mammals))
      assert_equal(@edge_mammals_primates, @tree.get_edge(@mammals, @primates))
      assert_equal(@edge_mammals_primates, @tree.get_edge(@primates, @mammals))
    end

    def test_get_edge_indirect
      assert_nil(@tree.get_edge(@mouse, @rat))
      assert_nil(@tree.get_edge(@human, @chimpanzee))
    end

    def test_get_edge_nonexistent
      assert_nil(@tree.get_edge(@mouse, Bio::Tree::Node.new))
    end

    def test_get_node_by_name
      assert_not_nil(@tree.get_node_by_name('mouse'))
      assert_not_nil(@tree.get_node_by_name('rat'))
      assert_not_nil(@tree.get_node_by_name('human'))
      assert_not_nil(@tree.get_node_by_name('chimpanzee'))
      assert_equal(@mouse, @tree.get_node_by_name('mouse'))
      assert_equal(@rat, @tree.get_node_by_name('rat'))
      assert_equal(@human, @tree.get_node_by_name('human'))
      assert_equal(@chimpanzee, @tree.get_node_by_name('chimpanzee'))
    end

    def test_get_node_by_name_noexistent
      assert_nil(@tree.get_node_by_name('frog'))
    end

    def test_add_edge
      amphibian = Bio::Tree::Node.new('amphibian')
      edge = Bio::Tree::Edge.new(0.3123)
      assert_equal(edge, @tree.add_edge(@mammals, amphibian, edge))

      frog = Bio::Tree::Node.new('frog')
      newt = Bio::Tree::Node.new('newt')
      assert_instance_of(Bio::Tree::Edge, @tree.add_edge(frog, newt))
    end

    def test_add_node
      frog = Bio::Tree::Node.new('frog')
      # the node does not exist
      assert_nil(@tree.get_node_by_name('frog'))
      assert_equal(false, @tree.include?(frog))
      # add node
      assert_equal(@tree, @tree.add_node(frog))
      # the node exists
      assert_equal(frog, @tree.get_node_by_name('frog'))
      assert_equal(true, @tree.include?(frog))
    end

    def test_include?
      assert_equal(true, @tree.include?(@mouse))
      assert_equal(true, @tree.include?(@rat))
      assert_equal(true, @tree.include?(@rodents))
      assert_equal(true, @tree.include?(@human))
      assert_equal(true, @tree.include?(@chimpanzee))
      assert_equal(true, @tree.include?(@primates))
      assert_equal(true, @tree.include?(@mammals))
    end
      
    def test_include_nonexistent
      assert_equal(false, @tree.include?(Bio::Tree::Node.new))
    end

    def test_clear_node
      assert_equal(2, @tree.out_degree(@mammals))
      # clear node
      assert_equal(@tree, @tree.clear_node(@mammals))
      # checks
      assert_equal(true, @tree.include?(@mammals))
      assert_equal(0, @tree.out_degree(@mammals))
      assert_equal(2, @tree.out_degree(@rodents))
      assert_equal(2, @tree.out_degree(@primates))
    end

    def test_clear_node_nonexistent
      assert_raise(IndexError) { @tree.clear_node(Bio::Tree::Node.new) }
    end

    def test_remove_node
      assert_equal(2, @tree.out_degree(@mammals))
      # remove node
      assert_equal(@tree, @tree.remove_node(@mammals))
      # checks
      assert_equal(false, @tree.include?(@mammals))
      assert_equal(0, @tree.out_degree(@mammals))
      assert_equal(2, @tree.out_degree(@rodents))
      assert_equal(2, @tree.out_degree(@primates))
    end

    def test_remove_node_nonexistent
      assert_raise(IndexError) { @tree.remove_node(Bio::Tree::Node.new) }
    end

    def test_remove_node_if
      assert_equal(@tree, @tree.remove_node_if { |node| node == @mouse })
      assert_equal(false, @tree.include?(@mouse))
    end

    def test_remove_node_if_false
      ary = []
      assert_equal(@tree, @tree.remove_node_if { |node| ary << node; false })
      nodes = @nodes.sort(&@by_id)
      assert_equal(nodes, ary.sort(&@by_id))
      assert_equal(nodes, @tree.nodes.sort(&@by_id))
    end

    def test_remove_edge
      assert_not_nil(@tree.get_edge(@mouse, @rodents))
      assert_equal(@tree, @tree.remove_edge(@mouse, @rodents))
      assert_nil(@tree.get_edge(@mouse, @rodents))
    end

    def test_remove_edge_nonexistent
      assert_raise(IndexError) { @tree.remove_edge(@mouse, @rat) }
    end

    def test_remove_edge_if
      ret = nil
      assert_nothing_raised {
        ret = @tree.remove_edge_if do |source, target, edge|
          [ source.name, target.name ].sort == [ 'mouse', 'rodents' ]
        end
      }
      assert_equal(@tree, ret)
      assert_nil(@tree.get_edge(@mouse, @rodents))
    end

    def test_remove_edge_if_nothing_removed
      ret = nil
      by_id_2 = Proc.new { |x,y| x[2].__id__ <=> y[2].__id__ }
      orig_edges = @tree.edges.sort(&by_id_2)
      assert_nothing_raised {
        ret = @tree.remove_node_if { |edge| false }
      }
      assert_equal(@tree, ret)
      assert_equal(orig_edges, @tree.edges.sort(&by_id_2))
    end

    def test_collect_node!
      ret = nil
      newmouse = Bio::Tree::Node.new('MOUSE')
      newhuman = Bio::Tree::Node.new('HUMAN')
      assert_nothing_raised {
        ret = @tree.collect_node! do |node|
          case node.name
          when 'mouse'
            newmouse
          when 'human'
            newhuman
          else
            node
          end
        end
      }
      assert_equal(@tree, ret)
      assert(@tree.include?(newmouse))
      assert(!@tree.include?(@mouse))
      assert(@tree.include?(newhuman))
      assert(!@tree.include?(@human))
      nodes = [ newmouse, @rat, @rodents, newhuman,
                @chimpanzee, @primates, @mammals ].sort(&@by_id)
      assert_equal(nodes, @tree.nodes.sort(&@by_id))
    end

    def test_collect_edge!
      ret = nil
      newedge_rodents_mouse  = Bio::Tree::Edge.new(100.0)
      newedge_primates_human = Bio::Tree::Edge.new(200.0)
      assert_nothing_raised {
        ret = @tree.collect_edge! do |source, target, edge|
          case [ source.name, target.name ].sort
          when [ 'mouse', 'rodents' ]
            newedge_rodents_mouse
          when [ 'human', 'primates' ]
            newedge_primates_human
          else
            edge
          end
        end
      }
      assert_equal(@tree, ret)
      assert_equal(newedge_rodents_mouse, @tree.get_edge(@mouse, @rodents))
      assert_equal(newedge_primates_human, @tree.get_edge(@human, @primates))
      expected = [ newedge_rodents_mouse,
                   @edge_rodents_rat,
                   @edge_mammals_rodents,
                   newedge_primates_human,
                   @edge_primates_chimpanzee,
                   @edge_mammals_primates ].sort(&@by_id)
      assert_equal(expected, @tree.edges.collect { |x| x[-1] }.sort(&@by_id))
    end

    def test_get_edge_merged
      edge1 = Bio::Tree::Edge.new(12.34)
      edge2 = Bio::Tree::Edge.new(56.78)
      merged_edge = @tree.get_edge_merged(edge1, edge2)
      # struggle to avoid possible float problem
      expected = 12.34 + 56.78
      assert_equal(expected, merged_edge.distance)
    end

    def test_get_node_bootstrap
      node = Bio::Tree::Node.new("test")
      node.bootstrap = 1
      assert_equal(1, @tree.get_node_bootstrap(node))
    end

    def test_get_node_bootstrap_string=
      node = Bio::Tree::Node.new("test")
      node.bootstrap_string = "0.75"
      assert_equal(0.75, @tree.get_node_bootstrap(node))
    end

    def test_subtree
      newtree = nil
      assert_nothing_raised {
        newtree = @tree.subtree([ @mouse, @rodents, @human ])
      }
      assert_equal(3, newtree.number_of_nodes)
      assert_equal(1, newtree.number_of_edges)
      nodes = [ @mouse, @rodents, @human ].sort(&@by_id)
      assert_equal(nodes, newtree.nodes.sort(&@by_id))
      edges = [ @edge_rodents_mouse ].sort(&@by_id)
      assert_equal(edges, newtree.edges.collect { |x| x[-1] }.sort(&@by_id))
    end

    def test_subtree_with_all_paths
      newtree = nil
      assert_nothing_raised {
        newtree = @tree.subtree_with_all_paths([ @mouse, @rodents, @human ])
      }
      assert_equal(5, newtree.number_of_nodes)
      assert_equal(4, newtree.number_of_edges)
      nodes = [ @mouse, @rodents, @mammals, @primates, @human ].sort(&@by_id)
      assert_equal(nodes, newtree.nodes.sort(&@by_id))
      edges = [ @edge_rodents_mouse,
                @edge_mammals_rodents,
                @edge_mammals_primates,
                @edge_primates_human ].sort(&@by_id)
      assert_equal(edges, newtree.edges.collect { |x| x[-1] }.sort(&@by_id))
    end

    def test_concat
      tree2 = Bio::Tree.new
      node1 = Bio::Tree::Node.new('node1')
      node2 = Bio::Tree::Node.new('node2')
      edge0 = Bio::Tree::Edge.new(0.1)
      tree2.add_edge(node1, node2, edge0)
      ret = nil
      assert_nothing_raised {
        ret = @tree.concat(tree2)
      }
      assert_equal(@tree, ret)
      assert_equal(9, @tree.number_of_nodes)
      assert_equal(7, @tree.number_of_edges)
      nodes = (@nodes + [ node1, node2 ]).sort(&@by_id)
      assert_equal(nodes, @tree.nodes.sort(&@by_id))
      edges = (@edges.collect { |x| x[-1] } + [ edge0 ]).sort(&@by_id)
      assert_equal(edges, @tree.edges.collect { |x| x[-1] }.sort(&@by_id))
    end

    def test_path
      expected = [ @mouse, @rodents, @mammals, @primates, @human ]
      assert_equal(expected, @tree.path(@mouse, @human))
    end

    #Passed cache_* methods because of internal methods

    def test_parent
      assert_equal(@rodents, @tree.parent(@mouse, @mammals))
    end

    def test_children
      expected = [ @primates, @rodents ].sort(&@by_id)
      assert_equal(expected,
                   @tree.children(@mammals, @mammals).sort(&@by_id))
    end

    def test_descendents
      expected = [ @primates, @rodents, @human, @chimpanzee,
                   @mouse, @rat ].sort(&@by_id)
      assert_equal(expected,
                   @tree.descendents(@mammals, @mammals).sort(&@by_id))
    end

    def test_leaves_noargs
      expected = [ @chimpanzee, @human, @mouse, @rat ].sort(&@by_id)
      @tree.root = @mammals
      assert_equal(expected, @tree.leaves.sort(&@by_id))
    end

    def test_leaves
      expected = [ @chimpanzee, @human, @mouse, @rat ].sort(&@by_id)
      assert_equal(expected, @tree.leaves(@mammals, @mammals).sort(&@by_id))
    end

    def test_ancestors
      expected = [ @rodents, @mammals ].sort(&@by_id)
      assert_equal(expected, @tree.ancestors(@mouse, @mammals).sort(&@by_id))
    end

    def test_lowest_common_ancestor
      assert_equal(@rodents,
                   @tree.lowest_common_ancestor(@mouse, @rat, @mammals))
    end

    def test_total_distance
      assert_equal("0.7777", sprintf("%.4f", @tree.total_distance))
    end

    def test_distance_matrix
      mat = @tree.distance_matrix([ @mouse, @rat, @human, @chimpanzee ])
      assert_instance_of(Matrix, mat)
      assert_equal([ "0.0000", "0.2093", "0.6149", "0.6266" ],
                   mat.row(0).map { |x| sprintf("%.4f", x) }.to_a)
      assert_equal([ "0.2093", "0.0000", "0.6306", "0.6423" ],
                   mat.row(1).map { |x| sprintf("%.4f", x) }.to_a)
      assert_equal([ "0.6149", "0.6306", "0.0000", "0.0889" ],
                   mat.row(2).map { |x| sprintf("%.4f", x) }.to_a)
      assert_equal([ "0.6266", "0.6423", "0.0889", "0.0000" ],
                   mat.row(3).map { |x| sprintf("%.4f", x) }.to_a)
    end
     
    def test_adjacency_matrix
      a =
        [ [ 0,  nil, @edge_rodents_mouse, nil, nil, nil, nil ],
          [ nil, 0, @edge_rodents_rat, nil, nil, nil, nil ],
          [ @edge_rodents_mouse, @edge_rodents_rat, 0, nil,
            nil, nil, @edge_mammals_rodents ],
          [ nil, nil, nil, 0, nil, @edge_primates_human, nil ],
          [ nil, nil, nil, nil, 0, @edge_primates_chimpanzee, nil ],
          [ nil, nil, nil, @edge_primates_human,
            @edge_primates_chimpanzee, 0, @edge_mammals_primates ],
          [ nil, nil, @edge_mammals_rodents, nil,
            nil, @edge_mammals_primates, 0 ]
        ]
      expected = Matrix.rows(a, false)
      assert_equal(expected, @tree.adjacency_matrix(@nodes, nil, 0))
    end

    def test_adjacency_matrix_with_block
      a =
        [ [ 0,  nil, "0.0968", nil, nil, nil, nil ],
          [ nil, 0, "0.1125", nil, nil, nil, nil ],
          [ "0.0968", "0.1125", 0, nil, nil, nil, "0.256" ],
          [ nil, nil, nil, 0, nil, "0.0386", nil ],
          [ nil, nil, nil, nil, 0, "0.0503", nil ],
          [ nil, nil, nil, "0.0386", "0.0503", 0, "0.2235" ],
          [ nil, nil, "0.256", nil, nil, "0.2235", 0 ]
        ]
      expected = Matrix.rows(a, false)
      assert_equal(expected,
                   @tree.adjacency_matrix(@nodes, nil, 0) { |src, tgt, edge|
                     sprintf("%.15g", edge.distance)
                   })
    end

    def test_remove_nonsense_nodes
      assert_equal([ @mammals ], @tree.remove_nonsense_nodes)
    end

    def test_insert_node
      node1 = Bio::Tree::Node.new('node1')
      ret = nil
      assert_nothing_raised {
        ret = @tree.insert_node(@mouse, @rodents, node1, 0.0123)
      }
      assert_equal(@tree, ret)
      distance_mouse_node1 = @tree.get_edge(@mouse, node1).distance
      assert_equal("0.0123", sprintf("%.4f", distance_mouse_node1))
      distance_node1_rodents = @tree.get_edge(node1, @rodents).distance
      assert_equal("0.0845", sprintf("%.4f", distance_node1_rodents))
    end
  end #class TestTree2

end #module Bio

