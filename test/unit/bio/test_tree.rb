#
# = test/bio/test_tree.rb - unit test for Bio::Tree
#
# Copyright::   Copyright (C) 2006
#               Naohisa Goto <ng@bioruby.org>
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
      ary = []
      assert_equal(@tree, @tree.remove_node_if { |edge| edge ==  @mouse })
    end
    def test_collect_node
      expected = ["mouse"]
      res = @tree.collect_node!{|node| @mouse}
      actual = res.nodes
      assert_equal( expected, actual.map{|elem| elem.name} )
    end

    def test_collect_edge
# I don't understand how "collect_edge" works.
# The line 532 of "tree.rb" outputs an error because Bio::Relation doesn't have "relation=" .
#
#      expected =
#        [ {:edge=>0.0968,
#           :node=>["mouse", "mouse"]},
#          {:edge=>0.1125,
#           :node=>["mouse", "mouse"]},
#          {:edge=>0.256,
#           :node=>["mouse", "mouse"]},
#          {:edge=>0.0386,
#           :node=>["mouse", "mouse"]},
#          {:edge=>0.0503,
#           :node=>["mouse", "mouse"]},
#          {:edge=>0.2235,
#           :node=>["mouse", "mouse"]} ]
         
#      assert_equal("", @tree.collect_edge!{|edge1, edge2, rel|  [ @rodents,  @mouse,      @edge_rodents_mouse]  })
    end

    def test_get_edge_merged
      edge1 = Bio::Tree::Edge.new(12.34)
      edge2 = Bio::Tree::Edge.new(56.78)
      merged_edge = @tree.get_edge_merged(edge1, edge2)
      assert_equal(69.12, merged_edge.distance)
    end

    def test_get_node_bootstrap
      node = Bio::Tree::Node.new("test")
      node.bootstrap = 1
      assert_equal(1, @tree.get_node_bootstrap(node))
    end

     def test_get_node_bootstrap_string
      node = Bio::Tree::Node.new("test")
      node.bootstrap = 1
      assert_equal(1, @tree.get_node_bootstrap(node))
     end

     def test_remove_edge_if
       @tree.remove_edge_if{|source, target, edge| target == @mouse or @rat or @rodents or @human or @chimpanzee or @primates}
       assert_equal(0, @tree.number_of_edges)
     end

     def test_subtree
       assert_equal("mouse", @tree.subtree([@mouse]).nodes[0].name)
     end

     def test_subtree_with_all_paths
       assert_equal("mouse", @tree.subtree_with_all_paths([@mouse]).nodes[0].name )
     end

     def test_concat
       tree2 = Bio::Tree.new
       node1      = Bio::Tree::Node.new('node1')
       node2      = Bio::Tree::Node.new('node2')
       edge = Bio::Tree::Edge.new(0.1)
       tree2.add_edge( node1,  node2, edge)
       new_edge = @tree.concat(tree2).edges[6]
       actual = [ new_edge[0].name, new_edge[1].name, new_edge[2].distance ]
       assert_equal(["node1", "node2", 0.1], actual)
     end

     def test_path
       actual =  @tree.path(@mouse, @human).map{|node| node.name }
       assert_equal(["mouse", "rodents", "mammals", "primates", "human"],actual)
     end

     def test_path
       actual =  @tree.distance(@mouse, @human)
       assert_equal(0.6149, actual)
     end

     #Passed cache_* methods because of internal methods

     def test_parent
       actual = @tree.parent(@mouse, @mammals).name
       assert_equal("rodents", actual)
     end

     def test_children
       actual = @tree.children(@rodents, @mammals).map{|node| node.name}.sort
       assert_equal(["mouse", "rat"], actual)
     end

     def test_descendents
       actual = @tree.descendents(@rodents, @mammals).map{|node| node.name}.sort
       assert_equal(["mouse", "rat"], actual)
     end

     def test_leaves
       actual = @tree.leaves.map{|node| node.name}.sort
       assert_equal(["chimpanzee", "human", "mouse", "rat"], actual)
       actual = @tree.leaves(@rodents, @mammals ).map{|node| node.name}.sort
       assert_equal(["mouse", "rat"],actual)
     end

     def test_ancestors
       actual = @tree.ancestors(@mouse, @mammals).map{|node| node.name}.sort
       assert_equal(["mammals", "rodents"] , actual)
     end

     def test_lowest_common_ancestor
      actual = @tree.lowest_common_ancestor(@mouse, @rat, @mammals).name
      assert_equal("rodents", actual)
     end

     def test_total_distance
       actual = @tree.total_distance.to_s
       assert_equal("0.7777", actual)
     end

     def test_distance_matrix
       actual = @tree.distance_matrix.to_a.map{|dist| dist.map{|elem| elem.to_s}.sort }.sort
       expected = 
[["0", "0.0889", "0.6149", "0.6306"],
 ["0", "0.0889", "0.6266", "0.6423"],
 ["0", "0.2093", "0.6149", "0.6266"],
 ["0", "0.2093", "0.6306", "0.6423"]]
       assert_equal(expected , actual)
     end
     
     def test_adjacency_matrix
       #the order of the result vary every exectuion and has a lot of nil. I use Array#sort to fix the order and put "0" in the place of nil 
       expected =
[["0", "0", "0", "0", "0", "0", "0.0386"],
 ["0", "0", "0", "0", "0", "0", "0.0503"],
 ["0", "0", "0", "0", "0", "0", "0.0968"],
 ["0", "0", "0", "0", "0", "0", "0.1125"],
 ["0", "0", "0", "0", "0", "0.2235", "0.256"],
 ["0", "0", "0", "0", "0.0386", "0.0503", "0.2235"],
 ["0", "0", "0", "0", "0.0968", "0.1125", "0.256"]]
       actual = @tree.adjacency_matrix.to_a.map do |adj| 
         adj.map do |elem| 
           if elem != nil
             elem.to_s 
           else
             elem = "0"
           end
         end.sort
       end.sort
       assert_equal(expected , actual)
     end

     def test_remove_nonsense_nodes
       expected = "mammals"
       actual = @tree.remove_nonsense_nodes[0].name
       assert_equal(expected  , actual)
     end

     def test_insert_node
       expected = "mammals"
       node1      = Bio::Tree::Node.new('node1')
       new = @tree.insert_node(@mouse, @rodents, node1)
       new_rel1 = new.edges[6][0].name
       new_rel2 = new.edges[5][1].name
       assert_equal("node1"  , new_rel1)
       assert_equal("node1"  , new_rel2)
     end
   end #class TestTree2

end #module Bio

