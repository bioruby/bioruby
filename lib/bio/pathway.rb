#
# bio/pathway.rb - Binary relations and Graph algorithms
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: pathway.rb,v 1.2 2001/10/17 14:43:11 katayama Exp $
#

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
	matrix[x][y] = relation		# Bug: matrix[x][y] == matrix[x+1][y] !
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
  end

  def clique
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
  end

  def floyd
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

