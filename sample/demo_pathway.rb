#
# = sample/demo_pathway.rb - demonstration of Bio::Pathway
#
# Copyright:    Copyright (C) 2001
#               Toshiaki Katayama <k@bioruby.org>,
#               Shuichi Kawashima <shuichi@hgc.jp>
# License::     The Ruby License
#
#
# == Description
#
# Demonstration of Bio::Pathway, an implementation of the graph data structure
# and graph algorithms.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_pathway.rb
#
# == Development information
#
# The code was moved from lib/bio/pathway.rb.
#

require 'bio'

#if __FILE__ == $0

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

#end

