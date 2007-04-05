#
# test/bio/tc_pathway.rb - Unit test for Bio::Pathway
#
# Copyright::  Copyright (C) 2004
#              Moses Hohman <mmhohman@northwestern.edu>
# License::    The Ruby License
#
#  $Id: test_pathway.rb,v 1.5 2007/04/05 23:35:42 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), [".."]*2, "lib")).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/pathway'

class Float
    NaN = 0/0.0
    Infinity = 1/0.0
end

class Array
    def sum
	inject { | sum, val | sum += val }
    end
end

module Bio
    class Pathway
	# bug in subgraph: does not include nodes w/o edges
	def subgraph(list = nil)
	    if list
		@label.clear
		list.each { |node| @label[node] = true }
	    end
	    sub_graph = Pathway.new([], @undirected)
	    @graph.each do |from, hash|
		next unless @label[from]
		sub_graph.graph[from] = {}
		hash.each do |to, relation|
		  next unless @label[to]
		  sub_graph.graph[from][to] = relation
		end
	    end
	    sub_graph
	end

	# bug in cliquishness: subgraph of neighbors does not include nodes w/o edges
	def subgraph_adjacency_matrix(nodes)
	    adjacency_matrix = to_matrix(0).to_a
	    node_indices = nodes.collect { |x| @index[x] }
	    subgraph = adjacency_matrix.values_at(*(node_indices))
	    subgraph.collect! { |row| row.values_at(*(node_indices)) }
	end

	# bug in cliquishness: subgraph of neighbors does not include nodes w/o edges
	# Throws exception if graph is directed
	def cliquishness(node)
	    raise "Cannot calculate cliquishness in directed graph" if not undirected?
	    neighbors = @graph[node].keys
	    return Float::NaN if neighbors.size==0
	    return 1 if neighbors.size==1
	    # divide by two to avoid double-counting
	    num_neighbor_edges = subgraph_adjacency_matrix(neighbors).flatten.sum/2
	    num_complete_edges = neighbors.size*(neighbors.size-1)/2
	    num_neighbor_edges.to_f / num_complete_edges.to_f
	end
    end

    class TestMyGraph < Test::Unit::TestCase
	def test_cliquishness
	    graph = Pathway.new([
		Relation.new(1, 3, 1),
		Relation.new(2, 3, 1),
		Relation.new(1, 5, 1),
		Relation.new(2, 6, 1),
		Relation.new(3, 6, 1),
		Relation.new(4, 6, 1),
		Relation.new(5, 6, 1),
	    ], true)
	    assert_equal(0, graph.cliquishness(1), "1's cliquishness wrong")
	    assert_equal(1, graph.cliquishness(2), "2's cliquishness wrong")
	    assert_in_delta(0.33, graph.cliquishness(3), 0.01, "3's cliquishness wrong")
	    assert_equal(1, graph.cliquishness(4), "4's cliquishness wrong")
	    assert_equal(0, graph.cliquishness(5), "5's cliquishness wrong")
	    assert_in_delta(0.16, graph.cliquishness(6), 0.01, "6's cliquishness wrong")
	end
    end

    class TestRelation < Test::Unit::TestCase
	def test_comparison_operator
	    r1 = Relation.new('a', 'b', 1)
	    r2 = Relation.new('b', 'a', 1)
	    r3 = Relation.new('b', 'a', 2)
	    r4 = Relation.new('a', 'b', 1)
	    assert(r1 === r2, "r1 === r2 not true, === not symmetric wrt nodes")
	    assert(!(r1 === r3), "r1 === r3 not false, === does not take edge into account")
	    assert(r1 === r4, "r1 === r4 not true, === is not reflexive wrt nodes")
	    assert_equal([r1, r3], [ r1, r2, r3, r4 ].uniq, "uniq did not have expected effect")
	    assert(r1.eql?(r2), "r1 not eql r2")
	    assert(!r3.eql?(r2), "r3 eql to r2")
	end
    end

    class TestSampleGraph < Test::Unit::TestCase
	    
	# Sample Graph :
	#                  +----------------+
	#                  |                |
	#                  v                |
	#       +---------(q)-->(t)------->(y)<----(r)
	#       |          |     |          ^       |
	#       v          |     v          |       |
	#   +--(s)<--+     |    (x)<---+   (u)<-----+
	#   |        |     |     |     |
	#   v        |     |     v     |
	#  (v)----->(w)<---+    (z)----+

	def setup
	    @data = [
		[ 'q', 's', 1, ],
		[ 'q', 't', 1, ],
		[ 'q', 'w', 1, ],
		[ 'r', 'u', 1, ],
		[ 'r', 'y', 1, ],
		[ 's', 'v', 1, ],
		[ 't', 'x', 1, ],
		[ 't', 'y', 1, ],
		[ 'u', 'y', 1, ],
		[ 'v', 'w', 1, ],
		[ 'w', 's', 1, ],
		[ 'x', 'z', 1, ],
		[ 'y', 'q', 1, ],
		[ 'z', 'x', 1, ],
	    ]

	    @graph = Pathway.new(@data.collect { |x| Relation.new(*x) })
	end

	def test_to_matrix
	    assert_equal(Matrix[
		    [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
		    [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
		    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
		    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
		    [0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
		    [0, 1, 0, 0, 0, 0, 0, 1, 1, 0],
		    [0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
		    [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		    [0, 0, 1, 1, 0, 0, 0, 0, 0, 0],
		    [0, 0, 0, 1, 0, 0, 0, 0, 0, 0]
		], @graph.to_matrix(0), "matrix wrong")
	    assert_equal({"v"=>0,"w"=>1,"x"=>2,"y"=>3,"z"=>4,"q"=>5,"r"=>6,"s"=>7,"t"=>8,"u"=>9}, @graph.index, "node --> matrix index order wrong")
	end

	def test_dump_matrix
	    dumped = "[" +
		"# v, w, x, y, z, q, r, s, t, u\n" +
		" [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],\n" + # v
		" [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],\n" + # w
		" [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],\n" + # x
		" [0, 0, 0, 0, 0, 1, 0, 0, 0, 0],\n" + # y
		" [0, 0, 1, 0, 0, 0, 0, 0, 0, 0],\n" + # z
		" [0, 1, 0, 0, 0, 0, 0, 1, 1, 0],\n" + # q
		" [0, 0, 0, 1, 0, 0, 0, 0, 0, 1],\n" + # r
		" [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],\n" + # s
		" [0, 0, 1, 1, 0, 0, 0, 0, 0, 0],\n" + # t
		" [0, 0, 0, 1, 0, 0, 0, 0, 0, 0]\n]"   # u
	    assert_equal(dumped, @graph.dump_matrix(0))
	end

	def test_dump_list
	    dumped = "v => w (1)\n" +
		"w => s (1)\n" +
		"x => z (1)\n" +
		"y => q (1)\n" +
		"z => x (1)\n" +
		"q => w (1), s (1), t (1)\n" +
		"r => y (1), u (1)\n" +
		"s => v (1)\n" +
		"t => x (1), y (1)\n" +
		"u => y (1)\n"
	    assert_equal(dumped, @graph.dump_list)
	end

	def test_extract_subgraph_by_label
	    hash = { 'q' => "L1", 's' => "L2", 'v' => "L3", 'w' => "L4" }
	    @graph.label = hash
	    dumped = 
		"v => w (1)\n" +
		"w => s (1)\n" +
		"q => w (1), s (1)\n" +
		"s => v (1)\n"
	    assert_equal(dumped, @graph.subgraph.dump_list)
	end

	def test_extract_subgraph_by_list
	    dumped =  
		"x => z (1)\n" +
		"y => q (1)\n" +
		"z => x (1)\n" +
		"q => t (1)\n" +
		"t => x (1), y (1)\n"
	    assert_equal(dumped, @graph.subgraph(['q', 't', 'x', 'y', 'z']).dump_list)
	end

	def test_extract_subgraph_retains_disconnected_nodes
	    assert_equal(4, @graph.subgraph(['r', 's', 'v', 'w']).nodes, "wrong number of nodes")
	end

	# Sample Graph :
	#                  +----------------+
	#                  |                |
	#                  v                |
	#       +---------(q)-->(t)------->(y)<----(r)
	#       |          |     |          ^       |
	#       v          |     v          |       |
	#   +--(s)<--+     |    (x)<---+   (u)<-----+
	#   |        |     |     |     |
	#   v        |     |     v     |
	#  (v)----->(w)<---+    (z)----+

	def test_cliquishness_raises_exception_for_directed_graph
	    assert_raises (RuntimeError) { @graph.cliquishness('q') }
	end

	def test_undirected_cliquishness
	    @graph.undirected
	    assert_in_delta(0.33, @graph.cliquishness('q'), 0.01)
	end

	def test_small_world_aka_node_degree_histogram
	    expected = {1=>7, 2=>2, 3=>1}
	    expected.default = 0
	    assert_equal(expected, @graph.small_world)
	end

	# Sample Graph :
	#                  +----------------+
	#                  |                |
	#                  v                |
	#       +---------(q)-->(t)------->(y)<----(r)
	#       |          |     |          ^       |
	#       v          |     v          |       |
	#   +--(s)<--+     |    (x)<---+   (u)<-----+
	#   |        |     |     |     |
	#   v        |     |     v     |
	#  (v)----->(w)<---+    (z)----+

	def test_breadth_first_search
	    distances, predecessors = @graph.breadth_first_search('q')
	    assert_equal({
		"v"=>2,
		"w"=>1,
		"x"=>2,
		"y"=>2,
		"z"=>3,
		"q"=>0,
		"s"=>1,
		"t"=>1}, distances, "distances wrong")
	    assert_equal({
		"v"=>"s",
		"w"=>"q",
		"x"=>"t",
		"y"=>"t",
		"z"=>"x",
		"q"=>nil,
		"s"=>"q",
		"t"=>"q"}, predecessors, "predecessors wrong")
	end

	def test_bfs_shortest_path
	    step, path = @graph.bfs_shortest_path('y', 'w')
	    assert_equal(2, step, "wrong # of steps")
	    assert_equal(["y", "q", "w"], path, "wrong path")
	end

	def test_depth_first_search
	    timestamp, tree, back, cross, forward = @graph.depth_first_search
	    assert_equal({
		"v"=>[1, 6],
		"w"=>[2, 5],
		"x"=>[7, 10],
		"y"=>[11, 16],
		"z"=>[8, 9],
		"q"=>[12, 15],
		"r"=>[17, 20],
		"s"=>[3, 4],
		"t"=>[13, 14],
		"u"=>[18, 19]}, timestamp, "timestamps wrong")
	    assert_equal({
		"w"=>"v",
		"z"=>"x",
		"q"=>"y",
		"s"=>"w",
		"t"=>"q",
		"u"=>"r"}, tree, "tree edges wrong")
	    assert_equal({
		"z"=>"x",
		"s"=>"v",
		"t"=>"y"}, back, "back edges wrong")
	    assert_equal({
		"q"=>"s",
		"r"=>"y",
		"t"=>"x",
		"u"=>"y"}, cross, "cross edges wrong")
	    assert_equal({}, forward, "forward edges wrong")
	end

	# Sample Graph :
	#                  +----------------+
	#                  |                |
	#                  v                |
	#       +---------(q)-->(t)------->(y)<----(r)
	#       |          |     |          ^       |
	#       v          |     v          |       |
	#   +--(s)<--+     |    (x)<---+   (u)<-----+
	#   |        |     |     |     |
	#   v        |     |     v     |
	#  (v)----->(w)<---+    (z)----+

	def test_dijkstra
	    distances, predecessors = @graph.dijkstra('q')
	    assert_equal({
		"v"=>2,
		"w"=>1,
		"x"=>2,
		"y"=>2,
		"z"=>3,
		"q"=>0,
		"r"=>Float::Infinity,
		"s"=>1,
		"t"=>1,
		"u"=>Float::Infinity}, distances, "distances wrong")
	    assert_equal({
		"v"=>"s",
		"w"=>"q",
		"x"=>"t",
		"y"=>"t",
		"z"=>"x",
		"q"=>nil,
		"r"=>nil,
		"s"=>"q",
		"t"=>"q",
		"u"=>nil}, predecessors, "predecessors wrong")
	end

	def test_bellman_ford
	    distances, predecessors = @graph.bellman_ford('q')
	    assert_equal({
		"v"=>2,
		"w"=>1,
		"x"=>2,
		"y"=>2,
		"z"=>3,
		"q"=>0,
		"r"=>Float::Infinity,
		"s"=>1,
		"t"=>1,
		"u"=>Float::Infinity}, distances, "distances wrong")
	    assert_equal({
		"v"=>"s",
		"w"=>"q",
		"x"=>"t",
		"y"=>"t",
		"z"=>"x",
		"q"=>nil,
		"r"=>nil,
		"s"=>"q",
		"t"=>"q",
		"u"=>nil}, predecessors, "predecessors wrong")
	end
    end

    class TestTopologicalSort < Test::Unit::TestCase

	#
	# Professor Bumstead topologically sorts his clothing when getting dressed.
	#
	#  "undershorts"       "socks"
	#     |      |            |
	#     v      |            v           "watch"
	#  "pants" --+-------> "shoes"
	#     |
	#     v
	#  "belt" <----- "shirt" ----> "tie" ----> "jacket"
	#     |                                       ^
	#     `---------------------------------------'
	#

	def test_dfs_topological_sort
	    dag = Pathway.new([
		Relation.new("undershorts", "pants", true),
		Relation.new("undershorts", "shoes", true),
		Relation.new("socks", "shoes", true),
		Relation.new("watch", "watch", true),
		Relation.new("pants", "belt", true),
		Relation.new("pants", "shoes", true),
		Relation.new("shirt", "belt", true),
		Relation.new("shirt", "tie", true),
		Relation.new("tie", "jacket", true),
		Relation.new("belt", "jacket", true),
	    ])
	    sorted = dag.dfs_topological_sort
	    assert(sorted.index("socks") < sorted.index("shoes"), "socks >= shoes")
	    assert(sorted.index("undershorts") < sorted.index("pants"), "undershorts >= pants")
	    assert(sorted.index("undershorts") < sorted.index("shoes"), "undershorts >= shoes")
	    assert(sorted.index("pants") < sorted.index("shoes"), "pants >= shoes")
	    assert(sorted.index("pants") < sorted.index("belt"), "pants >= belt")
	    assert(sorted.index("shirt") < sorted.index("belt"), "shirt >= belt")
	    assert(sorted.index("shirt") < sorted.index("tie"), "shirt >= tie")
	    assert(sorted.index("belt") < sorted.index("jacket"), "belt >= jacket")
	    assert(sorted.index("tie") < sorted.index("jacket"), "tie >= jacket")
	end
    end

    #TODO: verify the below
    class TestWeightedGraph < Test::Unit::TestCase

	#  'a' --> 'b'
	#   |   1   | 3
	#   |5      v
	#   `----> 'c'

	def setup
	    r1 = Relation.new('a', 'b', 1)
	    r2 = Relation.new('a', 'c', 5)
	    r3 = Relation.new('b', 'c', 3)
	    @w_graph = Pathway.new([r1, r2, r3])
	end

	def test_dijkstra_on_weighted_graph
	    distances, predecessors = @w_graph.dijkstra('a')
	    assert_equal({
		"a"=>0,
		"b"=>1,
		"c"=>4}, distances, "distances wrong")
	    assert_equal({
		"a"=>nil,
		"b"=>"a",
		"c"=>"b"}, predecessors, "predecessors wrong")
	end

	def test_bellman_ford_on_negative_weighted_graph
	     
	    #  ,-- 'a' --> 'b'
	    #  |    |   1   | 3
	    #  |    |5      v
	    #  |    `----> 'c'
	    #  |            ^
	    #  |2           | -5
	    #  `--> 'd' ----'
	     
	    r4 = Relation.new('a', 'd', 2)
	    r5 = Relation.new('d', 'c', -5)
	    @w_graph.append(r4)
	    @w_graph.append(r5)
	    distances, predecessors = @w_graph.bellman_ford('a')
	    assert_equal({
		"a"=>0,
		"b"=>1,
		"c"=>-3,
		"d"=>2}, distances, "distances wrong")
	    assert_equal({
		"a"=>nil,
		"b"=>"a",
		"c"=>"d",
		"d"=>"a"}, predecessors, "predecessors wrong")
	end
    end
end

