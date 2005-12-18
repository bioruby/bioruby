#
# bio/pathway.rb - Binary relations and Graph algorithms
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#                      KAWASHIMA Shuichi <s@bioruby.org>
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
#  $Id: pathway.rb,v 1.34 2005/12/18 16:50:56 k Exp $
#

require 'matrix'

module Bio

  class Pathway

    # Initial graph (adjacency list) generation from the list of Relation
    def initialize(relations, undirected = false)
      @undirected = undirected
      @relations = relations
      @graph = {}		# adjacency list expression of the graph
      @index = {}		# numbering each node in matrix
      @label = {}		# additional information on each node
      self.to_list		# generate adjacency list
    end
    attr_reader :relations, :graph, :index
    attr_accessor :label

    def directed?
      @undirected ? false : true
    end

    def undirected?
      @undirected ? true : false
    end

    def directed
      if undirected?
	@undirected = false
	self.to_list
      end
    end

    def undirected
      if directed?
	@undirected = true
	self.to_list
      end
    end

    # clear @relations to reduce the memory usage
    def clear_relations!
      @relations.clear
    end

    # reconstruct @relations from the adjacency list @graph
    def to_relations
      @relations.clear
      @graph.each_key do |from|
        @graph[from].each do |to, w|
          @relations << Relation.new(from, to, w)
        end
      end
      return @relations
    end


    # Graph (adjacency list) generation from the Relations
    def to_list
      @graph.clear
      @relations.each do |rel|
	append(rel, false)	# append to @graph without push to @relations
      end
    end

    def append(rel, add_rel = true)
      @relations.push(rel) if add_rel
      if @graph[rel.from].nil?
	@graph[rel.from] = {}
      end
      if @graph[rel.to].nil?
	@graph[rel.to] = {}
      end
      @graph[rel.from][rel.to] = rel.relation
      @graph[rel.to][rel.from] = rel.relation if @undirected
    end

    def delete(rel)
      @relations.delete_if do |x|
	x === rel
      end
      @graph[rel.from].delete(rel.to)
      @graph[rel.to].delete(rel.from) if @undirected
    end

    def nodes
      @graph.keys.length
    end

    def edges
      edges = 0
      @graph.each_value do |v|
	edges += v.size
      end
      edges
    end


    # Convert adjacency list to adjacency matrix
    def to_matrix(default_value = nil, diagonal_value = nil)

      # Note: following code only fills the outer Array with the reference
      # to the same inner Array object.
      #
      #   matrix = Array.new(nodes, Array.new(nodes))
      #
      # so create a new Array object for each row as follows:

      matrix = Array.new
      nodes.times do
	matrix.push(Array.new(nodes, default_value))
      end

      if diagonal_value
	nodes.times do |i|
	  matrix[i][i] = diagonal_value
	end
      end

      # assign index number for each node
      @graph.keys.each_with_index do |k, i|
	@index[k] = i
      end

      if @relations.empty?		# only used after clear_relations!
	@graph.each do |from, hash|
	  hash.each do |to, relation|
	    x = @index[from]
	    y = @index[to]
	    matrix[x][y] = relation
	  end
	end
      else
	@relations.each do |rel|
	  x = @index[rel.from]
	  y = @index[rel.to]
	  matrix[x][y] = rel.relation
	  matrix[y][x] = rel.relation if @undirected
	end
      end
      Matrix[*matrix]
    end


    # pretty printer of the adjacency matrix
    def dump_matrix(*arg)
      matrix = self.to_matrix(*arg)
      sorted = @index.sort {|a,b| a[1] <=> b[1]}
      "[# " + sorted.collect{|x| x[0]}.join(", ") + "\n" +
	matrix.to_a.collect{|row| ' ' + row.inspect}.join(",\n") + "\n]"
    end

    # pretty printer of the adjacency list
    def dump_list
      list = ""
      @graph.each do |from, hash|
	list << "#{from} => "
	a = []
	hash.each do |to, relation|
	  a.push("#{to} (#{relation})")
	end
	list << a.join(", ") + "\n"
      end
      list
    end


    # Select labeled nodes and generate subgraph
    def subgraph(list = nil)
      if list
	@label.clear
	list.each do |node|
	  @label[node] = true
	end
      end
      sub_graph = Pathway.new([], @undirected)
      @graph.each do |from, hash|
	next unless @label[from]
	hash.each do |to, relation|
	  next unless @label[to]
	  sub_graph.append(Relation.new(from, to, relation))
	end
      end
      return sub_graph
    end


    def common_subgraph(graph)
      raise NotImplementedError
    end


    def clique
      raise NotImplementedError
    end


    # Returns completeness of the edge density among the surrounded nodes
    def cliquishness(node)
      neighbors = @graph[node].keys
      sg = subgraph(neighbors)
      if sg.graph.size != 0
        edges = sg.edges / 2.0
        nodes = sg.nodes
        complete = (nodes * (nodes - 1)) / 2.0
        return edges/complete
      else
        return 0.0
      end
    end


    # Returns frequency of the nodes having same number of edges as hash
    def small_world
      freq = Hash.new(0)
      @graph.each_value do |v|
	freq[v.size] += 1
      end
      return freq
    end


    # Breadth first search solves steps and path to the each node and forms
    # a tree contains all reachable vertices from the root node.
    def breadth_first_search(root)
      visited = {}
      distance = {}
      predecessor = {}

      visited[root] = true
      distance[root] = 0
      predecessor[root] = nil

      queue = [ root ]

      while from = queue.shift
	next unless @graph[from]
	@graph[from].each_key do |to|
	  unless visited[to]
	    visited[to] = true
	    distance[to] = distance[from] + 1
	    predecessor[to] = from
	    queue.push(to)
	  end
	end
      end
      return distance, predecessor
    end
    alias bfs breadth_first_search


    def bfs_shortest_path(node1, node2)
      distance, route = breadth_first_search(node1)
      step = distance[node2]
      node = node2
      path = [ node2 ]
      while node != node1 and route[node]
	node = route[node]
	path.unshift(node)
      end
      return step, path
    end


    # Depth first search yields much information about the structure of the
    # graph especially on the classification of the edges.
    def depth_first_search
      visited = {}
      timestamp = {}
      tree_edges = {}
      back_edges = {}
      cross_edges = {}
      forward_edges = {}
      count = 0

      dfs_visit = Proc.new { |from|
	visited[from] = true
	timestamp[from] = [count += 1]
	@graph[from].each_key do |to|
	  if visited[to]
	    if timestamp[to].size > 1
	      if timestamp[from].first < timestamp[to].first
		# forward edge (black)
		p "#{from} -> #{to} : forward edge" if $DEBUG
		forward_edges[from] = to
	      else
		# cross edge (black)
		p "#{from} -> #{to} : cross edge" if $DEBUG
		cross_edges[from] = to
	      end
	    else
	      # back edge (gray)
	      p "#{from} -> #{to} : back edge" if $DEBUG
	      back_edges[from] = to
	    end
	  else
	    # tree edge (white)
	    p "#{from} -> #{to} : tree edge" if $DEBUG
	    tree_edges[to] = from
	    dfs_visit.call(to)
	  end
	end
	timestamp[from].push(count += 1)
      }

      @graph.each_key do |node|
	unless visited[node]
	  dfs_visit.call(node)
	end
      end
      return timestamp, tree_edges, back_edges, cross_edges, forward_edges
    end
    alias dfs depth_first_search


    def dfs_topological_sort
      # sorted by finished time reversely and collect node names only
      timestamp, = self.depth_first_search
      timestamp.sort {|a,b| b[1][1] <=> a[1][1]}.collect {|x| x.first }
    end


    # Dijkstra method to solve the shortest path problem in the weighted graph.
    def dijkstra(root)
      distance, predecessor = initialize_single_source(root)
      @graph[root].each do |k, v|
        distance[k] = v
        predecessor[k] = root
      end
      queue = distance.dup
      queue.delete(root)

      while queue.size != 0
	min = queue.min {|a, b| a[1] <=> b[1]}
	u = min[0]		# extranct a node having minimal distance
        @graph[u].each do |k, v|
	  # relaxing procedure of root -> 'u' -> 'k'
          if distance[k] > distance[u] + v
            distance[k] = distance[u] + v
            predecessor[k] = u
          end
        end
	queue.delete(u)
      end
      return distance, predecessor
    end


    # Bellman-Ford method for solving the single-source shortest-paths
    # problem in the graph in which edge weights can be negative.
    def bellman_ford(root)
      distance, predecessor = initialize_single_source(root)
      for i in 1 ..(self.nodes - 1) do
        @graph.each_key do |u|
          @graph[u].each do |v, w|
	    # relaxing procedure of root -> 'u' -> 'v'
            if distance[v] > distance[u] + w
              distance[v] = distance[u] + w
              predecessor[v] = u
            end
          end
        end
      end
      # negative cyclic loop check
      @graph.each_key do |u|
        @graph[u].each do |v, w|
          if distance[v] > distance[u] + w
            return false
          end
        end
      end
      return distance, predecessor
    end


    # Floyd-Wardshall alogrithm for solving the all-pairs shortest-paths
    # problem on a directed graph G = (V, E).
    def floyd_warshall
      inf = 1 / 0.0

      m = self.to_matrix(inf, 0)
      d = m.dup
      n = self.nodes
      for k in 0 .. n - 1 do
        for i in 0 .. n - 1 do
          for j in 0 .. n - 1 do
            if d[i, j] > d[i, k] + d[k, j]
              d[i, j] = d[i, k] + d[k, j]
            end
          end
        end
      end
      return d
    end
    alias floyd floyd_warshall


    # Kruskal method for finding minimam spaninng trees
    def kruskal
      # initialize
      rel = self.to_relations.sort{|a, b| a <=> b}
      index = []
      for i in 0 .. (rel.size - 1) do
        for j in (i + 1) .. (rel.size - 1) do
          if rel[i] == rel[j]
            index << j
          end
        end
      end
      index.sort{|x, y| y<=>x}.each do |i|
        rel[i, 1] = []
      end
      mst = []
      seen = Hash.new()
      @graph.each_key do |x|
        seen[x] = nil
      end
      i = 1
      # initialize end

      rel.each do |r|
        if seen[r.node[0]] == nil
          seen[r.node[0]] = 0
        end
        if seen[r.node[1]] == nil
          seen[r.node[1]] = 0
        end
        if seen[r.node[0]] == seen[r.node[1]] && seen[r.node[0]] == 0
          mst << r
          seen[r.node[0]] = i
          seen[r.node[1]] = i
        elsif seen[r.node[0]] != seen[r.node[1]]
          mst << r
          v1 = seen[r.node[0]].dup
          v2 = seen[r.node[1]].dup
          seen.each do |k, v|
            if v == v1 || v == v2
              seen[k] = i
            end
          end
        end
        i += 1
      end
      return Pathway.new(mst)
    end


    private


    def initialize_single_source(root)
      inf = 1 / 0.0				# inf.infinite? -> true

      distance = {}
      predecessor = {}

      @graph.each_key do |k|
        distance[k] = inf
        predecessor[k] = nil
      end
      distance[root] = 0
      return distance, predecessor
    end

  end



  class Relation

    def initialize(node1, node2, edge)
      @node = [node1, node2]
      @edge = edge
    end
    attr_accessor :node, :edge

    def from
      @node[0]
    end

    def to
      @node[1]
    end

    def relation
      @edge
    end

    def hash
      @node.sort.push(@edge).hash
    end

    def ===(rel)
      if self.edge == rel.edge
	if self.node[0] == rel.node[0] and self.node[1] == rel.node[1]
	  return true
	elsif self.node[0] == rel.node[1] and self.node[1] == rel.node[0]
	  return true
	else
	  return false
	end
      else
	return false
      end
    end
    alias eql? ===

    def <=>(rel)
      unless self.edge.kind_of? Comparable
	raise "[Error] edges are not comparable"
      end
      if self.edge > rel.edge
        return 1
      elsif self.edge < rel.edge
        return -1
      elsif self.edge == rel.edge
        return 0
      end
    end

  end

end



if __FILE__ == $0

  puts "--- Test === method true/false"
  r1 = Bio::Relation.new('a', 'b', 1)
  r2 = Bio::Relation.new('b', 'a', 1)
  r3 = Bio::Relation.new('b', 'a', 2)
  r4 = Bio::Relation.new('a', 'b', 1)
  p r1 === r2
  p r1 === r3
  p r1 === r4
  p [ r1, r2, r3, r4 ].uniq
  p r1.eql?(r2)
  p r3.eql?(r2)

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

  data = [
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

  ary = []

  puts "--- List of relations"
  data.each do |x|
    ary << Bio::Relation.new(*x)
  end
  p ary

  puts "--- Generate graph from list of relations"
  graph = Bio::Pathway.new(ary)
  p graph

  puts "--- Test to_matrix method"
  p graph.to_matrix

  puts "--- Test dump_matrix method"
  puts graph.dump_matrix(0)

  puts "--- Test dump_list method"
  puts graph.dump_list

  puts "--- Labeling some nodes"
  hash = { 'q' => "L1", 's' => "L2", 'v' => "L3", 'w' => "L4" }
  graph.label = hash
  p graph

  puts "--- Extract subgraph by label"
  p graph.subgraph

  puts "--- Extract subgraph by list"
  p graph.subgraph(['q', 't', 'x', 'y', 'z'])

  puts "--- Test cliquishness of the node 'q'"
  p graph.cliquishness('q')

  puts "--- Test cliquishness of the node 'q' (undirected)"
  u_graph = Bio::Pathway.new(ary, 'undirected')
  p u_graph.cliquishness('q')

  puts "--- Test small_world histgram"
  p graph.small_world

  puts "--- Test breadth_first_search method"
  distance, predecessor = graph.breadth_first_search('q')
  p distance
  p predecessor

  puts "--- Test bfs_shortest_path method"
  step, path = graph.bfs_shortest_path('y', 'w')
  p step
  p path

  puts "--- Test depth_first_search method"
  timestamp, tree, back, cross, forward = graph.depth_first_search
  p timestamp
  print "tree edges : "; p tree
  print "back edges : "; p back
  print "cross edges : "; p cross
  print "forward edges : "; p forward

  puts "--- Test dfs_topological_sort method"
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
  dag = Bio::Pathway.new([
    Bio::Relation.new("undeershorts", "pants", true),
    Bio::Relation.new("undeershorts", "shoes", true),
    Bio::Relation.new("socks", "shoes", true),
    Bio::Relation.new("watch", "watch", true),
    Bio::Relation.new("pants", "belt", true),
    Bio::Relation.new("pants", "shoes", true),
    Bio::Relation.new("shirt", "belt", true),
    Bio::Relation.new("shirt", "tie", true),
    Bio::Relation.new("tie", "jacket", true),
    Bio::Relation.new("belt", "jacket", true),
  ])
  p dag.dfs_topological_sort

  puts "--- Test dijkstra method"
  distance, predecessor = graph.dijkstra('q')
  p distance
  p predecessor

  puts "--- Test dijkstra method by weighted graph"
  #
  # 'a' --> 'b'
  #  |   1   | 3
  #  |5      v
  #  `----> 'c'
  #
  r1 = Bio::Relation.new('a', 'b', 1)
  r2 = Bio::Relation.new('a', 'c', 5)
  r3 = Bio::Relation.new('b', 'c', 3)
  w_graph = Bio::Pathway.new([r1, r2, r3])
  p w_graph
  p w_graph.dijkstra('a')

  puts "--- Test bellman_ford method by negative weighted graph"
  #
  # ,-- 'a' --> 'b'
  # |    |   1   | 3
  # |    |5      v
  # |    `----> 'c'
  # |            ^
  # |2           | -5
  # `--> 'd' ----'
  #
  r4 = Bio::Relation.new('a', 'd', 2)
  r5 = Bio::Relation.new('d', 'c', -5)
  w_graph.append(r4)
  w_graph.append(r5)
  p w_graph.bellman_ford('a')
  p graph.bellman_ford('q')

end


=begin

= Bio::Pathway

Bio::Pathway is a general graph object initially constructed by the list of
the ((<Bio::Relation>)) objects.  The basic concept of the Bio::Pathway object
is to store a graph as an adjacency list (in the instance variable @graph),
and converting the list into an adjacency matrix by calling to_matrix method
on demand.  However, in some cases, it is convenient to have the original list
of the ((<Bio::Relation>))s, Bio::Pathway object also stores the list (as the
instance variable @relations) redundantly.

Note: you can clear the @relations list by calling clear_relations! method to
reduce the memory usage, and the content of the @relations can be re-generated
from the @graph by to_relations method.

--- Bio::Pathway.new(list, undirected = false)

      Generate Bio::Pathway object from the list of Bio::Relation objects.
      If the second argument is true, undirected graph is generated.

        r1 = Bio::Relation.new('a', 'b', 1)
        r2 = Bio::Relation.new('a', 'c', 5)
        r3 = Bio::Relation.new('b', 'c', 3)
        list = [ r1, r2, r3 ]
        g = Bio::Pathway.new(list, 'undirected')

--- Bio::Pathway#relations

      Read-only accessor for the internal list of the Bio::Relation objects
      '@relations'.

--- Bio::Pathway#graph

      Read-only accessor for the adjacency list of the graph.

--- Bio::Pathway#index

      Read-only accessor for the row/column index (@index) of the adjacency
      matrix.  Contents of the hash @index is created by calling to_matrix
      method.

--- Bio::Pathway#label

      Accessor for the hash of the label assigned to the each node.  You can
      label some of the nodes in the graph by passing a hash to the label
      and select subgraphs which contain labeled nodes only by subgraph method.

        hash = { 1 => 'red', 2 => 'green', 5 => 'black' }
        g.label = hash
        g.label
        g.subgraph	# => new graph consists of the node 1, 2, 5 only

--- Bio::Pathway#directed?
--- Bio::Pathway#undirected?

      Returns true or false respond to the internal state of the graph.

--- Bio::Pathway#directed
--- Bio::Pathway#undirected

      Changes the internal state of the graph between 'directed' and
      'undirected' and re-generate adjacency list.  The undirected graph
      can be converted to directed graph, however, the edge between two
      nodes will be simply doubled to both ends.
      Note that these method can not be used without the list of the
      Bio::Relation objects (internally stored in @relations variable).
      Thus if you already called clear_relations! method, call
      to_relations first.

--- Bio::Pathway#clear_relations!
--- Bio::Pathway#to_relations

      Clear @relations array and re-generate @relations from @graph.
      Useful when you want to reduce the memory usage of the object.

--- Bio::Pathway#to_list

      Generate the adjcancecy list @graph from @relations (called by
      initialize and in some other cases when @relations has been changed).

--- Bio::Pathway#append(rel, add_rel = true)

      Add an Bio::Relation object 'rel' to the @graph and @relations.
      If the second argument is false, @relations is not modified (only
      useful when genarating @graph from @relations internally).

--- Bio::Pathway#delete(rel)

      Remove an edge indicated by the Bio::Relation object 'rel' from the
      @graph and the @relations.

--- Bio::Pathway#nodes
--- Bio::Pathway#edges

      Returns the number of the nodes or edges in the graph.

--- Bio::Pathway#to_matrix(default_value = nil, diagonal_value = nil)

      Returns the adjacency matrix expression of the graph as a Matrix object.
      If the first argument was assigned, the matrix will be filled with
      the given value.  The second argument indicates the value of the
      diagonal constituents of the matrix besides the above.

--- Bio::Pathway#dump_matrix(default_value = nil, diagonal_value = nil)
--- Bio::Pathway#dump_list

      These are pretty printer of the graph.  The dump_matrix method
      accepts the same arguments as to_matrix.  Useful when you want to
      check the internal state of the adjacency list or the matrix (for
      the debug etc.) easily.

--- Bio::Pathway#subgraph(list = nil)

      This method select some nodes and returns new Bio::Pathway object
      consists of selected nodes only.
      If the list of the nodes (as Array) is assigned as the argument,
      use the list to select the nodes from the graph.  If no argument
      is assigned, internal property of the graph @label is used to select
      the nodes.

         hash = { 'a' => 'secret', 'b' => 'important', 'c' => 'important' }
         g.label = hash
         g.subgraph

         list = [ 'a', 'b', 'c' ]
         g.subgraph(list)

--- Bio::Pathway#common_subgraph(graph)

      Not implemented yet.

--- Bio::Pathway#clique

      Not implemented yet.

--- Bio::Pathway#cliquishness(node)

      Calculates the value of cliquishness around the 'node'.  This value
      indicates completeness of the edge density among the surrounded nodes.

--- Bio::Pathway#small_world

      Calculates the frequency of the nodes having the same number of edges
      and returns the value as Hash.

--- Bio::Pathway#breadth_first_search(root)

      Breadth first search solves steps and path to the each node and forms
      a tree contains all reachable vertices from the root node.  This method
      returns the result in 2 hashes - 1st one shows the steps from root node
      and 2nd hash shows the structure of the tree.

      The weight of the edges are not considered in this method.

--- Bio::Pathway#bfs(root)

      Alias for the breadth_first_search method.

--- Bio::Pathway#bfs_shortest_path(node1, node2)

      Calculates the shortest path between two nodes by using
      breadth_first_search method and returns steps and the path as Array.

--- Bio::Pathway#depth_first_search

      Depth first search yields much information about the structure of the
      graph especially on the classification of the edges.  This method returns
      5 hashes - 1st one shows the timestamps of each node containing the first
      discoverd time and the search finished time in an array.  The 2nd, 3rd,
      4th, and 5th hashes contain 'tree edges', 'back edges', 'cross edges',
      'forward edges' respectively.

      If $DEBUG is true (e.g. ruby -d), this method prints the progression
      of the search.

      The weight of the edges are not considered in this method.

--- Bio::Pathway#dfs

      Alias for the depth_first_search method.

--- Bio::Pathway#dfs_topological_sort

      Topological sort of the directed acyclic graphs ("dags") by using
      depth_first_search.

--- Bio::Pathway#dijkstra(root)

      Dijkstra method solves the sortest path problem in the weighted graph.

--- Bio::Pathway#bellman_ford(root)

      Bellman-Ford method solves the single-source shortest-paths problem
      in the graph in which the edge weights can be negative.

--- Bio::Pathway#floyd_warshall

      Floyd-Wardshall alogrithm solves the all-pairs shortest-paths problem
      on a directed graph G = (V, E).

--- Bio::Pathway#floyd

      Alias for the floyd_warshall method.

--- Bio::Pathway#kruskal

      Kruskal method calculates the minimam spaninng trees.

--- Bio::Pathway#initialize_single_source(root)

      Private method used to initialize the distance by 'Infinity' and the
      path to the parent node by 'nil'.


= Bio::Relation

Bio::Relation is a simple object storing two nodes and the relation of them.
The nodes and the edge (relation) can be any Ruby object.  You can also
compare Bio::Relation objects if the edges have Comparable property.

--- Bio::Relation.new(node1, node2, edge)

      Create new binary relation object consists of the two object 'node1'
      and 'node2' with the 'edge' object as the relation of them.

--- Bio::Relation#node

      Accessor for the @node.

--- Bio::Relation#edge

      Accessor for the @edge.

--- Bio::Relation#from

      Returns one node.

--- Bio::Relation#to

      Returns another node.

--- Bio::Relation#relation

      Returns the edge.

--- Bio::Relation#===(rel)

      Compare with another Bio::Relation object whether havind same edges
      and same nodes.  The == method compares Bio::Relation object's id,
      however this case equality === method compares the internal property
      of the Bio::Relation object.

--- Bio::Relation#eql?(rel)
--- Bio::Relation#hash

      Method eql? is an alias of the === method and is used with hash method
      to make uniq arry of the Bio::Relation objects.

        a1 = Bio::Relation.new('a', 'b', 1)
        a2 = Bio::Relation.new('b', 'a', 1)
        a3 = Bio::Relation.new('b', 'c', 1)
        p [ a1, a2, a3 ].uniq

--- Bio::Relation#<=>(rel)

      Used by the each method to compare with another Bio::Relation object.
      This method is only usable when the edge objects have the property of
      the module Comparable.

=end

