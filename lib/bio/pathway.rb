#
# bio/pathway.rb - Binary relations and Graph algorithms
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: pathway.rb,v 1.22 2001/11/17 06:55:24 katayama Exp $
#

require 'bio/matrix'

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

    # clear @relations to reduce the usage of memory
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
      nodes.times do |i|
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


    # pretty printer of the adjacency matrix (format depends on Matrix#dump)
    def matrix_dump(*arg)
      matrix = self.to_matrix(*arg)
      sorted = @index.sort {|a,b| a[1] <=> b[1]}
      index  = "# " + sorted.collect{|x| x[0]}.join(", ")
      matrix.dump(index)
    end

    # pretty printer of the adjacency list
    def list_dump
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
      a = @graph[node].keys
      sg = subgraph(a)
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


    # simple application of bfs
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


    # Depth first search yields much information about the structure of a graph
    # and the predecessor subgraph form a forest of trees.
    def depth_first_search
      visited = {}
      distance = {}
      predecessor = {}
      count = 0

      dfs_visit = Proc.new { |from|
	visited[from] = true
	distance[from] = [count += 1]
	@graph[from].each_key do |to|
	  unless visited[to]
	    predecessor[to] = from
	    dfs_visit.call(to)
	  end
	end
	distance[from].push(count += 1)
      }

      @graph.each_key do |node|
	unless visited[node]
	  dfs_visit.call(node)
	end
      end
      return distance, predecessor
    end
    alias dfs depth_first_search


    # Dijkstra method to solve the sortest path problem in the weighted graph.
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

    def ===(rel)
      if self.edge == rel.edge and
	 self.node[0] == rel.node[1] and
	 self.node[1] == rel.node[0]
	return true
      else
	return false
      end
    end

    def <=>(rel)
      unless self.edge.kind_of? Comparable
	raise "[Error] edge is not comparable"
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
  p r1 === r2
  p r1 === r3
# p [ r1, r2, r3 ].uniq

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

  puts "--- Test matrix_dump method"
  puts graph.matrix_dump(0)

  puts "--- Test list_dump method"
  puts graph.list_dump

  puts "--- Labeling some nodes"
  list = { 'q' => "L1", 's' => "L2", 'v' => "L3", 'w' => "L4" }
  graph.label = list
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
  distance, predecessor = graph.depth_first_search
  p distance
  p predecessor

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

--- Bio::Pathway#new(list, undirected = nil)

--- Bio::Pathway#relations
--- Bio::Pathway#graph
--- Bio::Pathway#index

--- Bio::Pathway#label
--- Bio::Pathway#label=(hash)

--- Bio::Pathway#directed?
--- Bio::Pathway#undirected?
--- Bio::Pathway#directed
--- Bio::Pathway#undirected

--- Bio::Pathway#clear_relations!
--- Bio::Pathway#to_relations

--- Bio::Pathway#to_list
--- Bio::Pathway#append(rel, add_rel = true)
--- Bio::Pathway#nodes
--- Bio::Pathway#edges

--- Bio::Pathway#to_matrix(default_value = nil, diagonal_value = nil)

--- Bio::Pathway#matrix_dump(default_value = nil, diagonal_value = nil)
--- Bio::Pathway#list_dump

--- Bio::Pathway#subgraph(list = nil)
--- Bio::Pathway#common_subgraph(graph)
--- Bio::Pathway#clique
--- Bio::Pathway#cliquishness(node)
--- Bio::Pathway#small_world

--- Bio::Pathway#breadth_first_search(root)
--- Bio::Pathway#bfs(root)
--- Bio::Pathway#bfs_shortest_path(node1, node2)
--- Bio::Pathway#depth_first_search
--- Bio::Pathway#dfs

--- Bio::Pathway#dijkstra(root)
--- Bio::Pathway#bellman_ford(root)
--- Bio::Pathway#floyd_warshall
--- Bio::Pathway#floyd
--- Bio::Pathway#kruskal


--- Bio::Pathway#initialize_single_source(root)

= Bio::Relation

--- Bio::Relation#new(node1, node2, edge)

--- Bio::Relation#node
--- Bio::Relation#edge

--- Bio::Relation#from
--- Bio::Relation#to
--- Bio::Relation#relation

--- Bio::Relation#===(rel)
--- Bio::Relation#<=>(rel)

=end

