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
#  $Id: pathway.rb,v 1.1 2001/10/04 07:32:45 katayama Exp $
#

require 'bio/matrix'

class BioPathway

=begin
  def initialize(list)
    # [directed] [weighted] graph generation from the list of BioRelation
    @node = Hash.new([])	# hash of array of nodes (V:vertices)
    @edge = Hash.new([])	# hash of array of edge  (E:edges)
    list.each do |x|
      @node[x.from].push(x.to)
      @edge[x.to].push(x.relation)
    end
  end
=end

  def initialize(list)
    # [directed] [weighted] graph generation from the list of BioRelation
    @graph = Hash.new([])
    list.each do |x|
      @graph[x.from].push([x.to, x.relation])
    end
  end

  def to_matrix
    # convert adjacency list to adjacency matrix (BioMatrix)
    matrix = Array.new([])
    @graph.each do |key,val|
      x = key
      y = val.shift
      r = val.shift		# relation (weight)
      matrix[x][y] = r
    end
    return matrix
  end

  def breadth_first_search(root)
  end
  alias bfs breadth_first_search

  def reach(node1, node2)
  end

  def label(hash)
  end

  def dijkstra
  end

  def floyd
  end

  def common_subgraph(graph)
  end

end


class BioRelation

  def initialize(node1, node2, edge)
    @node = [node1, node2]
    @edge = edge
  end
  attr_accessor :node, :edge

  def from
    @node.shift
  end

  def to
    @node.pop
  end

  def relation
    @edge
  end

end
