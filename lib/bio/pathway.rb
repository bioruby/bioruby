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
#  $Id: pathway.rb,v 1.16 2001/11/14 09:15:51 shuichi Exp $
#

require 'bio/matrix'

module Bio

  class Pathway

    # Graph (adjacency list) generation from the list of Relation
    def initialize(list, undirected = nil)
      @undirected = undirected
      @graph = {}
      @index = {}		# numbering each node in matrix
      @label = {}		# additional information on each node
      list.each do |rel|
	append(rel)
      end
    end
    attr_reader :graph, :index
    attr_accessor :label

    def append(rel)
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
      @graph.keys.each_with_index do |k, i|
	@index[k] = i
      end

      # note: following code only makes references to the same [] object
      #
      #   matrix = Array.new(nodes, Array.new(nodes))
      #
      # so create each Array object as follows:

      matrix = Array.new
      nodes.times do |i|
	matrix.push(Array.new(nodes, default_value))
      end

      if diagonal_value
	nodes.times do |i|
	  matrix[i][i] = diagonal_value
	end
      end

      @graph.each do |from, hash|
	hash.each do |to, relation|
	  x = @index[from]
	  y = @index[to]
	  matrix[x][y] = relation
	end
      end
      Matrix[*matrix]
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


    # Returns frequency of the nodes having same number of edges as hash
    def small_world
      freq = Hash.new(0)
      @graph.each_value do |v|
	freq[v.size] += 1
      end
      return freq
    end


    # Breadth first search solves steps and path to the each node
    def breadth_first_search(root)
      seen = {}
      distance = {}
      predecessor = {}

      seen[root] = true
      distance[root] = 0
      predecessor[root] = nil

      queue = [ root ]

      while from = queue.shift
	@graph[from].keys.each do |to|
	  unless seen[to]
	    seen[to] = true
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


    # Dijkstra method to solve sortest path for weighted graph
    def dijkstra(root)
      distance, predecessor = initialize_single_source(root)
      @graph[root].each do |k, v|
        distance[k] = v
        predecessor[k] = root
      end
      queue = distance.dup
      queue.delete(root)

      while queue.size != 0
	sorted = queue.to_a.sort{|a, b| a[1] <=> b[1]}
	u = sorted[0][0]	# extranct a node having minimal distance
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
    # problem on a directed graph G = (V, E)
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

    private


    def initialize_single_source(root)
      inf = 1 / 0.0				# inf.infinite? -> true

      distance = {}
      predecessor = {}

      @graph.keys.each do |k|
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

  puts "--- Labeling some nodes"
  list = { 'q' => "L1", 's' => "L2", 'v' => "L3", 'w' => "L4" }
  graph.label = list
  p graph

  puts "--- Extract subgraph by label"
  p graph.subgraph

  puts "--- Extract subgraph by list"
  p graph.subgraph(['q', 't', 'x', 'y', 'z'])

  puts "--- Test small_world histgram"
  p graph.small_world

  puts "--- Test breadth_first_search method"
  dist, pred = graph.breadth_first_search('q')
  p dist
  p pred

  puts "--- Test bfs_shortest_path method"
  step, path = graph.bfs_shortest_path('y', 'w')
  p step
  p path

  puts "--- Test dijkstra method"
  dist, pred = graph.dijkstra('q')
  p dist
  p pred

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

--- Bio::Pathway#label
--- Bio::Pathway#label=(hash)
--- Bio::Pathway#graph
--- Bio::Pathway#index

--- Bio::Pathway#append(rel)
--- Bio::Pathway#nodes
--- Bio::Pathway#edges
--- Bio::Pathway#to_matrix
--- Bio::Pathway#subgraph(list = nil)
--- Bio::Pathway#common_subgraph(graph)
--- Bio::Pathway#clique
--- Bio::Pathway#small_world
--- Bio::Pathway#breadth_first_search(root)
--- Bio::Pathway#bfs(root)
--- Bio::Pathway#bfs_shortest_path(node1, node2)
--- Bio::Pathway#dijkstra(root)
--- Bio::Pathway#bellman_ford(root)
--- Bio::Pathway#floyd_warshall

= Bio::Relation

--- Bio::Relation#new(node1, node2, edge)

--- Bio::Relation#node
--- Bio::Relation#edge

--- Bio::Relation#from
--- Bio::Relation#to
--- Bio::Relation#relation

--- Bio::Relation#===(rel)

=end

