#
# = bio/pathway.rb - Binary relations and Graph algorithms
#
# Copyright:    Copyright (C) 2001
#               Toshiaki Katayama <k@bioruby.org>,
#               Shuichi Kawashima <shuichi@hgc.jp>
# License::     The Ruby License
#
#  $Id:$
#

require 'matrix'

module Bio

# Bio::Pathway is a general graph object initially constructed by the
# list of the ((<Bio::Relation>)) objects.  The basic concept of the
# Bio::Pathway object is to store a graph as an adjacency list (in the
# instance variable @graph), and converting the list into an adjacency
# matrix by calling to_matrix method on demand.  However, in some
# cases, it is convenient to have the original list of the
# ((<Bio::Relation>))s, Bio::Pathway object also stores the list (as
# the instance variable @relations) redundantly.
# 
# Note: you can clear the @relations list by calling clear_relations!
# method to reduce the memory usage, and the content of the @relations
# can be re-generated from the @graph by to_relations method.
class Pathway

  # Initial graph (adjacency list) generation from the list of Relation.
  # 
  # Generate Bio::Pathway object from the list of Bio::Relation objects.
  # If the second argument is true, undirected graph is generated.
  #
  #   r1 = Bio::Relation.new('a', 'b', 1)
  #   r2 = Bio::Relation.new('a', 'c', 5)
  #   r3 = Bio::Relation.new('b', 'c', 3)
  #   list = [ r1, r2, r3 ]
  #   g = Bio::Pathway.new(list, 'undirected')
  #
  def initialize(relations, undirected = false)
    @undirected = undirected
    @relations = relations
    @graph = {}		# adjacency list expression of the graph
    @index = {}		# numbering each node in matrix
    @label = {}		# additional information on each node
    self.to_list		# generate adjacency list
  end

  # Read-only accessor for the internal list of the Bio::Relation objects
  attr_reader :relations

  # Read-only accessor for the adjacency list of the graph.
  attr_reader :graph

  # Read-only accessor for the row/column index (@index) of the
  # adjacency matrix.  Contents of the hash @index is created by
  # calling to_matrix method.
  attr_reader :index

  # Accessor for the hash of the label assigned to the each node.  You can
  # label some of the nodes in the graph by passing a hash to the label
  # and select subgraphs which contain labeled nodes only by subgraph method.
  #
  #   hash = { 1 => 'red', 2 => 'green', 5 => 'black' }
  #   g.label = hash
  #   g.label
  #   g.subgraph    # => new graph consists of the node 1, 2, 5 only
  #
  attr_accessor :label


  # Returns true or false respond to the internal state of the graph.
  def directed?
    @undirected ? false : true
  end

  # Returns true or false respond to the internal state of the graph.
  def undirected?
    @undirected ? true : false
  end

  # Changes the internal state of the graph from 'undirected' to
  # 'directed' and re-generate adjacency list.  The undirected graph
  # can be converted to directed graph, however, the edge between two
  # nodes will be simply doubled to both ends.
  #
  # Note: this method can not be used without the list of the
  # Bio::Relation objects (internally stored in @relations variable).
  # Thus if you already called clear_relations! method, call
  # to_relations first.
  def directed
    if undirected?
      @undirected = false
      self.to_list
    end
  end

  # Changes the internal state of the graph from 'directed' to
  # 'undirected' and re-generate adjacency list.
  # 
  # Note: this method can not be used without the list of the
  # Bio::Relation objects (internally stored in @relations variable).
  # Thus if you already called clear_relations! method, call
  # to_relations first.
  def undirected
    if directed?
      @undirected = true
      self.to_list
    end
  end

  # Clear @relations array to reduce the memory usage.
  def clear_relations!
    @relations.clear
  end

  # Reconstruct @relations from the adjacency list @graph.
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
  #
  # Generate the adjcancecy list @graph from @relations (called by
  # initialize and in some other cases when @relations has been changed).
  def to_list
    @graph.clear
    @relations.each do |rel|
      append(rel, false)	# append to @graph without push to @relations
    end
  end

  # Add an Bio::Relation object 'rel' to the @graph and @relations.
  # If the second argument is false, @relations is not modified (only
  # useful when genarating @graph from @relations internally).
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

  # Remove an edge indicated by the Bio::Relation object 'rel' from the
  # @graph and the @relations.
  def delete(rel)
    @relations.delete_if do |x|
      x === rel
    end
    @graph[rel.from].delete(rel.to)
    @graph[rel.to].delete(rel.from) if @undirected
  end

  # Returns the number of the nodes in the graph.
  def nodes
    @graph.keys.length
  end

  # Returns the number of the edges in the graph.
  def edges
    edges = 0
    @graph.each_value do |v|
      edges += v.size
    end
    edges
  end


  # Convert adjacency list to adjacency matrix
  # 
  # Returns the adjacency matrix expression of the graph as a Matrix
  # object.  If the first argument was assigned, the matrix will be
  # filled with the given value.  The second argument indicates the
  # value of the diagonal constituents of the matrix besides the above.
  #
  # The result of this method depends on the order of Hash#each
  # (and each_key, etc.), which may be variable with Ruby version
  # and Ruby interpreter variations (JRuby, etc.).
  # For a workaround to remove such dependency, you can use @index 
  # to set order of Hash keys. Note that this behavior might be
  # changed in the future. Be careful that @index is overwritten by
  # this method.
  # 
  def to_matrix(default_value = nil, diagonal_value = nil)

    #--
    # Note: following code only fills the outer Array with the reference
    # to the same inner Array object.
    #
    #   matrix = Array.new(nodes, Array.new(nodes))
    #
    # so create a new Array object for each row as follows:
    #++

    matrix = Array.new
    nodes.times do
      matrix.push(Array.new(nodes, default_value))
    end

    if diagonal_value
      nodes.times do |i|
        matrix[i][i] = diagonal_value
      end
    end

    # assign index number
    if @index.empty? then
      # assign index number for each node
      @graph.keys.each_with_index do |k, i|
        @index[k] = i
      end
    else
      # begin workaround removing depencency to order of Hash#each
      # assign index number from the preset @index
      indices = @index.to_a
      indices.sort! { |i0, i1| i0[1] <=> i1[1] }
      indices.collect! { |i0| i0[0] }
      @index.clear
      v = 0
      indices.each do |k, i|
        if @graph[k] and !@index[k] then
          @index[k] = v; v += 1
        end
      end
      @graph.each_key do |k|
        unless @index[k] then
          @index[k] = v; v += 1
        end
      end
      # end workaround removing depencency to order of Hash#each
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


  # Pretty printer of the adjacency matrix.
  #
  # The dump_matrix method accepts the same arguments as to_matrix.
  # Useful when you want to check the internal state of the matrix
  # (for debug purpose etc.) easily.
  #
  # This method internally calls to_matrix method.
  # Read documents of to_matrix for important informations.
  #
  def dump_matrix(*arg)
    matrix = self.to_matrix(*arg)
    sorted = @index.sort {|a,b| a[1] <=> b[1]}
    "[# " + sorted.collect{|x| x[0]}.join(", ") + "\n" +
      matrix.to_a.collect{|row| ' ' + row.inspect}.join(",\n") + "\n]"
  end

  # Pretty printer of the adjacency list.
  # 
  # Useful when you want to check the internal state of the adjacency
  # list (for debug purpose etc.) easily.
  #
  # The result of this method depends on the order of Hash#each
  # (and each_key, etc.), which may be variable with Ruby version
  # and Ruby interpreter variations (JRuby, etc.).
  # For a workaround to remove such dependency, you can use @index 
  # to set order of Hash keys. Note that this behavior might be
  # changed in the future. 
  # 
  def dump_list
    # begin workaround removing depencency to order of Hash#each
    if @index.empty? then
      pref = nil
      enum = @graph
    else
      pref = {}.merge(@index)
      i = pref.values.max
      @graph.each_key do |node|
        pref[node] ||= (i += 1)
      end
      graph_to_a = @graph.to_a
      graph_to_a.sort! { |x, y| pref[x[0]] <=> pref[y[0]] }
      enum = graph_to_a
    end
    # end workaround removing depencency to order of Hash#each

    list = ""
    enum.each do |from, hash|
      list << "#{from} => "
      # begin workaround removing depencency to order of Hash#each
      if pref then
        ary = hash.to_a
        ary.sort! { |x,y| pref[x[0]] <=> pref[y[0]] }
        hash = ary
      end
      # end workaround removing depencency to order of Hash#each
      a = []
      hash.each do |to, relation|
        a.push("#{to} (#{relation})")
      end
      list << a.join(", ") + "\n"
    end
    list
  end

  # Select labeled nodes and generate subgraph
  #
  # This method select some nodes and returns new Bio::Pathway object
  # consists of selected nodes only.  If the list of the nodes (as
  # Array) is assigned as the argument, use the list to select the
  # nodes from the graph.  If no argument is assigned, internal
  # property of the graph @label is used to select the nodes.
  #
  #   hash = { 'a' => 'secret', 'b' => 'important', 'c' => 'important' }
  #   g.label = hash
  #   g.subgraph
  #   list = [ 'a', 'b', 'c' ]
  #    g.subgraph(list)
  #
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
      sub_graph.graph[from] ||= {}
      hash.each do |to, relation|
        next unless @label[to]
        sub_graph.append(Relation.new(from, to, relation))
      end
    end
    return sub_graph
  end


  # Not implemented yet.
  def common_subgraph(graph)
    raise NotImplementedError
  end


  # Not implemented yet.
  def clique
    raise NotImplementedError
  end


  # Returns completeness of the edge density among the surrounded nodes.
  #
  # Calculates the value of cliquishness around the 'node'.  This value
  # indicates completeness of the edge density among the surrounded nodes.
  #
  # Note: cliquishness (clustering coefficient) for a directed graph
  # is also calculated.
  # Reference: http://en.wikipedia.org/wiki/Clustering_coefficient
  # 
  # Note: Cliquishness (clustering coefficient) for a node that has
  # only one neighbor node is undefined. Currently, it returns NaN,
  # but the behavior may be changed in the future.
  #
  def cliquishness(node)
    neighbors = @graph[node].keys
    sg = subgraph(neighbors)
    if sg.graph.size != 0
      edges = sg.edges
      nodes = neighbors.size
      complete = (nodes * (nodes - 1))
      return edges.quo(complete)
    else
      return 0.0
    end
  end

  # Returns frequency of the nodes having same number of edges as hash
  #
  # Calculates the frequency of the nodes having the same number of edges
  # and returns the value as Hash.
  def small_world
    freq = Hash.new(0)
    @graph.each_value do |v|
      freq[v.size] += 1
    end
    return freq
  end

  # Breadth first search solves steps and path to the each node and
  # forms a tree contains all reachable vertices from the root node.
  # This method returns the result in 2 hashes - 1st one shows the
  # steps from root node and 2nd hash shows the structure of the tree.
  #
  # The weight of the edges are not considered in this method.
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

  # Alias for the breadth_first_search method.
  alias bfs breadth_first_search


  # Calculates the shortest path between two nodes by using
  # breadth_first_search method and returns steps and the path as Array.
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


  # Depth first search yields much information about the structure of
  # the graph especially on the classification of the edges.  This
  # method returns 5 hashes - 1st one shows the timestamps of each
  # node containing the first discoverd time and the search finished
  # time in an array.  The 2nd, 3rd, 4th, and 5th hashes contain 'tree
  # edges', 'back edges', 'cross edges', 'forward edges' respectively.
  #
  # If $DEBUG is true (e.g. ruby -d), this method prints the progression
  # of the search.
  # 
  # The weight of the edges are not considered in this method.
  #
  # Note: The result of this method depends on the order of Hash#each
  # (and each_key, etc.), which may be variable with Ruby version
  # and Ruby interpreter variations (JRuby, etc.).
  # For a workaround to remove such dependency, you can use @index 
  # to set order of Hash keys. Note that this bahavior might be
  # changed in the future.
  def depth_first_search
    visited = {}
    timestamp = {}
    tree_edges = {}
    back_edges = {}
    cross_edges = {}
    forward_edges = {}
    count = 0

    # begin workaround removing depencency to order of Hash#each
    if @index.empty? then
      preference_of_nodes = nil
    else
      preference_of_nodes = {}.merge(@index)
      i = preference_of_nodes.values.max
      @graph.each_key do |node0|
        preference_of_nodes[node0] ||= (i += 1)
      end
    end
    # end workaround removing depencency to order of Hash#each

    dfs_visit = Proc.new { |from|
      visited[from] = true
      timestamp[from] = [count += 1]
      ary = @graph[from].keys
      # begin workaround removing depencency to order of Hash#each
      if preference_of_nodes then
        ary = ary.sort_by { |node0| preference_of_nodes[node0] }
      end
      # end workaround removing depencency to order of Hash#each
      ary.each do |to|
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

    ary = @graph.keys
    # begin workaround removing depencency to order of Hash#each
    if preference_of_nodes then
      ary = ary.sort_by { |node0| preference_of_nodes[node0] }
    end
    # end workaround removing depencency to order of Hash#each
    ary.each do |node|
      unless visited[node]
        dfs_visit.call(node)
      end
    end
    return timestamp, tree_edges, back_edges, cross_edges, forward_edges
  end

  # Alias for the depth_first_search method.
  alias dfs depth_first_search


  # Topological sort of the directed acyclic graphs ("dags") by using
  # depth_first_search.
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
    (self.nodes - 1).times do
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

  # Alias for the floyd_warshall method.
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
    index.sort{|x, y| y<=>x}.each do |idx|
      rel[idx, 1] = []
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

end # Pathway



# Bio::Relation is a simple object storing two nodes and the relation of them.
# The nodes and the edge (relation) can be any Ruby object.  You can also
# compare Bio::Relation objects if the edges have Comparable property.
class Relation

  # Create new binary relation object consists of the two object 'node1'
  # and 'node2' with the 'edge' object as the relation of them.
  def initialize(node1, node2, edge)
    @node = [node1, node2]
    @edge = edge
  end
  attr_accessor :node, :edge

  # Returns one node.
  def from
    @node[0]
  end

  # Returns another node.
  def to
    @node[1]
  end

  def relation
    @edge
  end

  # Used by eql? method
  def hash
    @node.sort.push(@edge).hash
  end

  # Compare with another Bio::Relation object whether havind same edges
  # and same nodes.  The == method compares Bio::Relation object's id,
  # however this case equality === method compares the internal property
  # of the Bio::Relation object.
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

  # Method eql? is an alias of the === method and is used with hash method
  # to make uniq arry of the Bio::Relation objects.
  #
  #   a1 = Bio::Relation.new('a', 'b', 1)
  #   a2 = Bio::Relation.new('b', 'a', 1)
  #   a3 = Bio::Relation.new('b', 'c', 1)
  # p [ a1, a2, a3 ].uniq
  alias eql? ===

  # Used by the each method to compare with another Bio::Relation object.
  # This method is only usable when the edge objects have the property of
  # the module Comparable.
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

end # Relation

end # Bio

