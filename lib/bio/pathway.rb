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
#  $Id: pathway.rb,v 1.5 2001/11/06 16:58:52 okuji Exp $
#

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
--- Bio::Pathway#subgraph
--- Bio::Pathway#common_subgraph(graph)
--- Bio::Pathway#clique
--- Bio::Pathway#small_world
--- Bio::Pathway#breadth_first_search(root)
--- Bio::Pathway#bfs(root)
--- Bio::Pathway#bfs_distance(root)
--- Bio::Pathway#shortest_path(node1, node2)
--- Bio::Pathway#dijkstra
--- Bio::Pathway#floyd

= Bio::Relation

--- Bio::Relation#new(node1, node2, edge)

--- Bio::Relation#node
--- Bio::Relation#edge

--- Bio::Relation#from
--- Bio::Relation#to
--- Bio::Relation#relation

=end


module Bio

require 'bio/matrix'

class Pathway

  # Graph (adjacency list) generation from the list of Relation
  def initialize(list, undirected = nil)
    @undirected = undirected
    @index = {}
    @label = {}
    @graph = {}
    list.each do |rel|
      append(rel)
    end
  end
  attr_accessor :label
  attr_reader :graph, :index

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
  def to_matrix
    @graph.keys.each_with_index do |k, i|
      @index[k] = i
    end

    # note : following code only makes reference to the same []
    #matrix = Array.new(nodes, Array.new(nodes))

    matrix = Array.new
    nodes.times do |i|
      matrix.push(Array.new(nodes))
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
  def subgraph
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

  def small_world
    freq = Hash.new(0)
    @graph.each_value do |v|
      freq[v.size] += 1
    end
    return freq
  end

  def breadth_first_search(root)
    white = -1; gray = 0; black = 1

    color = Hash.new(white)
    distance = {}
    predecessor = {}

    color[root] = gray
    distance[root] = 0
    predecessor[root] = nil

    queue = [ root ]

    while from = queue.shift
      @graph[from].keys.each do |to|
	if color[to] == white
	  color[to] = gray
	  distance[to] = distance[from] + 1
	  predecessor[to] = from
	  queue.push(to)
	end
      end
      color[from] = black
    end

    return distance, predecessor
  end
  alias bfs breadth_first_search

  def bfs_distance(root)
    seen = {}
    distance = {}

    seen[root] = true
    distance[root] = 0

    queue = [ root ]

    while from = queue.shift
      @graph[from].keys.each do |to|
	unless seen[to]
	  seen[to] = true
	  distance[to] = distance[from] + 1
	  queue.push(to)
	end
      end
    end
    return distance
  end

  def shortest_path(node1, node2)
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

  def dijkstra
    raise NotImplementedError
  end

  def floyd
    raise NotImplementedError
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

end

end				# module Bio

