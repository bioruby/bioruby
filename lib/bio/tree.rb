#
# = bio/tree.rb - phylogenetic tree data structure class
#
# Copyright::   Copyright (C) 2006
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
# $Id: tree.rb,v 1.8 2007/04/05 23:35:39 trevor Exp $
#

require 'matrix'
require 'bio/pathway'

module Bio

  # This is the class for phylogenetic tree.
  # It stores a phylogenetic tree.
  # 
  # Internally, it is based on Bio::Pathway class.
  # However, users cannot handle Bio::Pathway object directly.
  #
  # This is alpha version. Incompatible changes may be made frequently.
  class Tree

    # Error when there are no path between specified nodes
    class NoPathError < RuntimeError; end

    # Edge object of each node.
    # By default, the object doesn't contain any node information.
    class Edge

      # creates a new edge.
      def initialize(distance = nil)
        if distance.kind_of?(Numeric)
          self.distance = distance
        elsif distance
          self.distance_string = distance
        end
      end

      # evolutionary distance
      attr_reader :distance

      # evolutionary distance represented as a string
      attr_reader :distance_string

      # set evolutionary distance value
      def distance=(num)
        @distance = num
        @distance_string = (num ? num.to_s : num)
      end

      # set evolutionary distance value from a string
      def distance_string=(str)
        if str.to_s.strip.empty?
          @distance = nil
          @distance_string = str
        else
          @distance = str.to_f
          @distance_string = str
        end
      end

      # visualization of this object
      def inspect
        "<Edge distance=#{@distance.inspect}>"
      end

      # string representation of this object
      def to_s
        @distance_string.to_s
      end

      #---
      # methods for NHX (New Hampshire eXtended) and/or PhyloXML
      #+++

      # log likelihood value (:L in NHX)
      attr_accessor :log_likelihood

      # width of the edge
      # (<branch width="w"> of PhyloXML, or :W="w" in NHX)
      attr_accessor :width

      # Other NHX parameters. Returns a Hash.
      # Note that :L and :W
      # are not stored here but stored in the proper attributes in this class.
      # However, if you force to set these parameters in this hash,
      # the parameters in this hash are preferred when generating NHX.
      # In addition, If the same parameters are defined at Node object,
      # the parameters in the node are preferred.
      def nhx_parameters
        @nhx_parameters ||= {}
        @nhx_parameters
      end

    end #class Edge

    # Gets distance value from the given edge.
    # Returns float or any other numeric value or nil.
    def get_edge_distance(edge)
      begin
        dist = edge.distance
      rescue NoMethodError
        dist = edge
      end
      dist
    end

    # Gets distance string from the given edge.
    # Returns a string or nil.
    def get_edge_distance_string(edge)
      begin
        dist = edge.distance_string
      rescue NoMethodError
        dist = (edge ? edge.to_s : nil)
      end
      dist
    end

    # Returns edge1 + edge2
    def get_edge_merged(edge1, edge2)
      dist1 = get_edge_distance(edge1)
      dist2 = get_edge_distance(edge2)
      if dist1 and dist2 then
        Edge.new(dist1 + dist2)
      elsif dist1 then
        Edge.new(dist1)
      elsif dist2 then
        Edge.new(dist2)
      else
        Edge.new
      end
    end

    # Node object.
    class Node

      # Creates a new node.
      def initialize(name = nil)
        @name = name if name
      end

      # name of the node
      attr_accessor :name

      # bootstrap value
      attr_reader :bootstrap

      # bootstrap value as a string
      attr_reader :bootstrap_string

      # sets a bootstrap value
      def bootstrap=(num)
        @bootstrap_string = (num ? num.to_s : num)
        @bootstrap = num
      end

      # sets a bootstrap value from a string
      def bootstrap_string=(str)
        if str.to_s.strip.empty?
          @bootstrap = nil
          @bootstrap_string = str
        else
          i = str.to_i
          f = str.to_f
          @bootstrap = (i == f ? i : f)
          @bootstrap_string = str
        end
      end

      # visualization of this object
      def inspect
        if @name and !@name.empty? then
          str = "(Node:#{@name.inspect}"
        else
          str = sprintf('(Node:%x', (self.__id__ << 1) & 0xffffffff)
        end
        str += " bootstrap=#{@bootstrap.inspect}" if @bootstrap
        str += ")"
        str
      end

      # string representation of this object
      def to_s
        @name.to_s
      end

      # the order of the node
      # (lower value, high priority)
      attr_accessor :order_number

      #---
      # methods for NHX (New Hampshire eXtended) and/or PhyloXML
      #+++

      # Phylogenetic events.
      # Returns an Array of one (or more?) of the following symbols
      #   :gene_duplication
      #   :speciation
      def events
        @events ||= []
        @events
      end

      # EC number (EC_number in PhyloXML, or :E in NHX)
      attr_accessor :ec_number

      # scientific name (scientific_name in PhyloXML, or :S in NHX)
      attr_accessor :scientific_name

      # taxonomy identifier (taxonomy_identifier in PhyloXML, or :T in NHX)
      attr_accessor :taxonomy_id

      # Other NHX parameters. Returns a Hash.
      # Note that :D, :E, :S, and :T
      # are not stored here but stored in the proper attributes in this class.
      # However, if you force to set these parameters in this hash,
      # the parameters in this hash are preferred when generating NHX.
      def nhx_parameters
        @nhx_parameters ||= {}
        @nhx_parameters
      end

    end #class Node

    # Gets node name
    def get_node_name(node)
      begin
        node.name
      rescue NoMethodError
        node.to_s
      end
    end

    def get_node_bootstrap(node)
      begin
        node.bootstrap
      rescue NoMethodError
        nil
      end
    end

    def get_node_bootstrap_string(node)
      begin
        node.bootstrap_string
      rescue NoMethodError
        nil
      end
    end

    # Creates a new phylogenetic tree.
    # When no arguments are given, it creates a new empty tree.
    # When a Tree object is given, it copies the tree.
    # Note that the  new tree shares Node and Edge objects
    # with the given tree.
    def initialize(tree = nil)
      # creates an undirected adjacency list graph
      @pathway = Bio::Pathway.new([], true)
      @root = nil
      @options = {}
      self.concat(tree) if tree
    end

    # root node of this tree
    # (even if unrooted tree, it is used by some methods)
    attr_accessor :root

    # tree options; mainly used for tree output
    attr_accessor :options

    # Clears all nodes and edges.
    # Returns self.
    # Note that options and root are also cleared.
    def clear
      initialize
      self
    end

    # Returns all nodes as an array.
    def nodes
      @pathway.graph.keys
    end

    # Number of nodes.
    def number_of_nodes
      @pathway.nodes
    end

    # Iterates over each node of this tree.
    def each_node(&x) #:yields: node
      @pathway.graph.each_key(&x)
      self
    end

    # Iterates over each edges of this tree.
    def each_edge #:yields: source, target, edge
      @pathway.relations.each do |rel|
        yield rel.node[0], rel.node[1], rel.relation
      end
      self
    end

    # Returns all edges an array of [ node0, node1, edge ]
    def edges
      @pathway.relations.collect do |rel|
        [ rel.node[0], rel.node[1], rel.relation ]
      end
    end

    # Returns number of edges in the tree.
    def number_of_edges
      @pathway.relations.size
    end

    # Returns an array of adjacent nodes of the given node.
    def adjacent_nodes(node)
      h = @pathway.graph[node]
      h ? h.keys : []
    end

    # Returns all connected edges with adjacent nodes.
    # Returns an array of the array [ source, target, edge ].
    #
    # The reason why the method name is "out_edges" is that
    # it comes from the Boost Graph Library.
    def out_edges(source)
      h = @pathway.graph[source]
      if h
        h.collect { |key, val| [ source, key, val ] }
      else
        []
      end
    end

    # Iterates over each connected edges of the given node.
    # Returns self.
    #
    # The reason why the method name is "each_out_edge" is that
    # it comes from the Boost Graph Library.
    def each_out_edge(source) #:yields: source, target, edge
      h = @pathway.graph[source]
      h.each { |key, val| yield source, key, val } if h
      self
    end

    # Returns number of edges in the given node.
    #
    # The reason why the method name is "out_degree" is that
    # it comes from the Boost Graph Library.
    def out_degree(source)
      h = @pathway.graph[source]
      h ? h.size : 0
    end

    # Returns an edge from source to target.
    # If source and target are not adjacent nodes, returns nil.
    def get_edge(source, target)
      h = @pathway.graph[source]
      h ? h[target] : nil
    end

    # Adds a new edge to the tree.
    # Returns the newly added edge.
    # If the edge already exists, it is overwritten with new one.
    def add_edge(source, target, edge = Edge.new)
      @pathway.append(Bio::Relation.new(source, target, edge))
      edge
    end

    # Finds a node in the tree by given name and returns the node.
    # If the node does not found, returns nil.
    # If multiple nodes with the same name exist,
    # the result would be one of those (unspecified).
    def get_node_by_name(str)
      self.each_node do |node|
        if get_node_name(node) == str
          return node
        end
      end
      nil
    end

    # Adds a node to the tree.
    # Returns self.
    # If the node already exists, it does nothing.
    def add_node(node)
      @pathway.graph[node] ||= {}
      self
    end

    # If the node exists, returns true.
    # Otherwise, returns false.
    def include?(node)
      @pathway.graph[node] ? true : false
    end

    # Removes all edges connected with the node.
    # Returns self.
    # If the node does not exist, raises IndexError.
    def clear_node(node)
      unless self.include?(node)
        raise IndexError, 'the node does not exist'
      end
      @pathway.relations.delete_if do |rel|
        rel.node.include?(node)
      end
      @pathway.graph[node].each_key do |k|
        @pathway.graph[k].delete(node)
      end
      @pathway.graph[node].clear
      self
    end

    # Removes the given node from the tree.
    # All edges connected with the node are also removed.
    # Returns self.
    # If the node does not exist, raises IndexError.
    def remove_node(node)
      self.clear_node(node)
      @pathway.graph.delete(node)
      self
    end

    # Removes each node if the block returns not nil.
    # All edges connected with the removed nodes are also removed.
    # Returns self.
    def remove_node_if
      all = self.nodes
      all.each do |node|
        if yield node then
          self.clear_node(node)
          @pathway.graph.delete(node)
        end
      end
      self
    end

    # Removes an edge between source and target.
    # Returns self.
    # If the edge does not exist, raises IndexError.
    #---
    # If two or more edges exists between source and target,
    # all of them are removed.
    #+++
    def remove_edge(source, target)
      unless self.get_edge(source, target) then
        raise IndexError, 'edge not found'
      end
      fwd = [ source, target ]
      rev = [ target, source ]
      @pathway.relations.delete_if do |rel|
        rel.node == fwd or rel.node == rev
      end
      h = @pathway.graph[source]
      h.delete(target) if h
      h = @pathway.graph[target]
      h.delete(source) if h
      self
    end

    # Removes each edge if the block returns not nil.
    # Returns self.
    def remove_edge_if #:yields: source, target, edge
      removed_rel = []
      @pathway.relations.delete_if do |rel|
        if yield rel.node[0], rel.node[1], edge then
          removed_rel << rel
          true
        end
      end
      removed_rel.each do |rel|
        source = rel[0]
        target = rel[1]
        h = @pathway.graph[source]
        h.delete(target) if h
        h = @pathway.graph[target]
        h.delete(source) if h
      end
      self
    end

    # Replaces each node by each block's return value.
    # Returns self.
    def collect_node! #:yields: node
      tr = {}
      self.each_node do |node|
        tr[node] = yield node
      end
      # replaces nodes in @pathway.relations
      @pathway.relations.each do |rel|
        rel.node.collect! { |node| tr[node] }
      end
      # re-generates @pathway from relations
      @pathway.to_list
      # adds orphan nodes
      tr.each_value do |newnode|
        @pathway.graph[newnode] ||= {}
      end
      self
    end

    # Replaces each edge by each block's return value.
    # Returns self.
    def collect_edge! #:yields: source, target, edge
      @pathway.relations.each do |rel|
        newedge = yield rel.node[0], rel.node[1], rel.relation
        rel.relation = newedge
        @pathway.append(rel, false)
      end
      self
    end

    # Gets the sub-tree consisted of given nodes.
    # _nodes_ must be an array of nodes.
    # Nodes that do not exist in the original tree are ignored.
    # Returns a Tree object.
    # Note that the sub-tree shares Node and Edge objects
    # with the original tree.
    def subtree(nodes)
      nodes = nodes.find_all do |x|
        @pathway.graph[x]
      end
      return self.class.new if nodes.empty?
      # creates subtree
      new_tree = self.class.new
      nodes.each do |x|
        new_tree.add_node(x)
      end
      self.each_edge do |node1, node2, edge|
        if new_tree.include?(node1) and new_tree.include?(node2) then
          new_tree.add_edge(node1, node2, edge)
        end
      end
      return new_tree
    end

    # Gets the sub-tree consisted of given nodes and
    # all internal nodes connected between given nodes.
    # _nodes_ must be an array of nodes.
    # Nodes that do not exist in the original tree are ignored.
    # Returns a Tree object.
    # The result is unspecified for cyclic trees.
    # Note that the sub-tree shares Node and Edge objects
    # with the original tree.
    def subtree_with_all_paths(nodes)
      hash = {}
      nodes.each { |x| hash[x] = true }
      nodes.each_index do |i|
        node1 = nodes[i]
        (0...i).each do |j|
          node2 = nodes[j]
          unless node1 == node2 then
            begin
              path = self.path(node1, node2)
            rescue IndexError, NoPathError
              path = []
            end
            path.each { |x| hash[x] = true }
          end
        end
      end
      self.subtree(hash.keys)
    end

    # Concatenates the other tree.
    # If the same edge exists, the edge in _other_ is used.
    # Returns self.
    # The result is unspecified if _other_ isn't a Tree object.
    # Note that the Node and Edge objects in the _other_ tree are
    # shared in the concatinated tree.
    def concat(other)
      #raise TypeError unless other.kind_of?(self.class)
      other.each_node do |node|
        self.add_node(node)
      end
      other.each_edge do |node1, node2, edge|
        self.add_edge(node1, node2, edge)
      end
      self
    end

    # Gets path from node1 to node2.
    # Retruns an array of nodes, including node1 and node2.
    # If node1 and/or node2 do not exist, IndexError is raised.
    # If node1 and node2 are not connected, NoPathError is raised.
    # The result is unspecified for cyclic trees.
    def path(node1, node2)
      raise IndexError, 'node1 not found' unless @pathway.graph[node1]
      raise IndexError, 'node2 not found' unless @pathway.graph[node2]
      return [ node1 ] if node1 == node2
      step, path = @pathway.bfs_shortest_path(node1, node2)
      unless path[0] == node1 and path[-1] == node2 then
        raise NoPathError, 'node1 and node2 are not connected'
      end
      path
    end

    # Iterates over each edge from node1 to node2.
    # The result is unspecified for cyclic trees.
    def each_edge_in_path(node1, node2)
      path = self.path(node1, node2)
      source = path.shift
      path.each do |target|
        edge = self.get_edge(source, target)
        yield source, target, edge
        source = target
      end
      self
    end

    # Returns distance between node1 and node2.
    # It would raise error if the edges didn't contain distance values.
    # The result is unspecified for cyclic trees.
    def distance(node1, node2)
      distance = 0
      self.each_edge_in_path(node1, node2) do |source, target, edge|
        distance += get_edge_distance(edge)
      end
      distance
    end

    # Gets the parent node of the _node_.
    # If _root_ isn't specified or _root_ is <code>nil</code>, @root is used.
    # Returns an <code>Node</code> object or nil.
    # The result is unspecified for cyclic trees.
    def parent(node, root = nil)
      root ||= @root
      self.path(root, node)[-2]
    end

    # Gets the adjacent children nodes of the _node_.
    # If _root_ isn't specified or _root_ is <code>nil</code>, @root is used.
    # Returns an array of <code>Node</code>s.
    # The result is unspecified for cyclic trees.
    def children(node, root = nil)
      root ||= @root
      path = self.path(root, node)
      result = self.adjacent_nodes(node)
      result -= path
      result
    end

    # Gets all descendent nodes of the _node_.
    # If _root_ isn't specified or _root_ is <code>nil</code>, @root is used.
    # Returns an array of <code>Node</code>s.
    # The result is unspecified for cyclic trees.
    def descendents(node, root = nil)
      root ||= @root
      distance, route = @pathway.breadth_first_search(root)
      d = distance[node]
      result = []
      distance.each do |key, val|
        if val > d then
          x = key
          while x = route[x]
            if x == node then
              result << key
              break
            end
            break if distance[x] <= d
          end
        end
      end
      result
    end

    # If _node_ is nil, returns an array of 
    # all leaves (nodes connected with one edge).
    # Otherwise, gets all descendent leaf nodes of the _node_.
    # If _root_ isn't specified or _root_ is <code>nil</code>, @root is used.
    # Returns an array of <code>Node</code>s.
    # The result is unspecified for cyclic trees.
    def leaves(node = nil, root = nil)
      unless node then
        nodes = []
        self.each_node do |x|
          nodes << x if self.out_degree(x) == 1
        end
        return nodes
      else
        root ||= @root
        self.descendents(node, root).find_all do |x|
          self.adjacent_nodes(x).size == 1
        end
      end
    end

    # Gets all ancestral nodes of the _node_.
    # If _root_ isn't specified or _root_ is <code>nil</code>, @root is used.
    # Returns an array of <code>Node</code>s.
    # The result is unspecified for cyclic trees.
    def ancestors(node, root = nil)
      root ||= @root
      (self.path(root, node) - [ node ]).reverse
    end

    # Gets the lowest common ancestor of the two nodes.
    # If _root_ isn't specified or _root_ is <code>nil</code>, @root is used.
    # Returns a <code>Node</code> object or nil.
    # The result is unspecified for cyclic trees.
    def lowest_common_ancestor(node1, node2, root = nil)
      root ||= @root
      distance, route = @pathway.breadth_first_search(root)
      x = node1; r1 = []
      begin; r1 << x; end while x = route[x]
      x = node2; r2 = []
      begin; r2 << x; end while x = route[x]
      return (r1 & r2).first
    end

    # Returns total distance of all edges.
    # It would raise error if some edges didn't contain distance values.
    def total_distance
      distance = 0
      self.each_edge do |source, target, edge|
        distance += get_edge_distance(edge)
      end
      distance
    end

    # Calculates distance matrix of given nodes.
    # If _nodes_ is nil, or is ommited, it acts the same as
    # tree.distance_matrix(tree.leaves).
    # Returns a matrix object.
    # The result is unspecified for cyclic trees.
    # Note 1: The diagonal values of the matrix are 0.
    # Note 2: If the distance cannot be calculated, nil will be set.
    def distance_matrix(nodes = nil)
      nodes ||= self.leaves
      matrix = []
      nodes.each_index do |i|
        row = []
        nodes.each_index do |j|
          if i == j then
            distance = 0
          elsif r = matrix[j] and val = r[i] then
            distance = val
          else
            distance = (self.distance(nodes[i], nodes[j]) rescue nil)
          end
          row << distance
        end
        matrix << row
      end
      Matrix.rows(matrix, false)
    end

    # Shows the adjacency matrix representation of the tree.
    # It shows matrix only for given nodes.
    # If _nodes_ is nil or is ommitted,
    # it acts the same as tree.adjacency_matrix(tree.nodes).
    # If a block is given, for each edge,
    # it yields _source_, _target_, and _edge_, and
    # uses the returned value of the block.
    # Without blocks, it uses edge.
    # Returns a matrix object.
    def adjacency_matrix(nodes = nil,
                         default_value = nil,
                         diagonal_value = nil) #:yields: source, target, edge
      nodes ||= self.nodes
      size = nodes.size
      hash = {}
      nodes.each_with_index { |x, i| hash[x] = i }
      # prepares an matrix
      matrix = Array.new(size, nil)
      matrix.collect! { |x| Array.new(size, default_value) }
      (0...size).each { |i| matrix[i][i] = diagonal_value }
      # fills the matrix from each edge
      self.each_edge do |source, target, edge|
        i_source = hash[source]
        i_target = hash[target]
        if i_source and i_target then
          val = block_given? ? (yield source, target, edge) : edge
          matrix[i_source][i_target] = val
          matrix[i_target][i_source] = val
        end
      end
      Matrix.rows(matrix, false)
    end

    # Removes all nodes that are not branches nor leaves.
    # That is, removes nodes connected with exactly two edges.
    # For each removed node, two adjacent edges are merged and
    # a new edge are created.
    # Returns removed nodes.
    # Note that orphan nodes are still kept unchanged.
    def remove_nonsense_nodes
      hash = {}
      self.each_node do |node|
        hash[node] = true if @pathway.graph[node].size == 2
      end
      hash.each_key do |node|
        adjs = @pathway.graph[node].keys
        edges = @pathway.graph[node].values
        new_edge = get_edge_merged(edges[0], edges[1])
        @pathway.graph[adjs[0]].delete(node)
        @pathway.graph[adjs[1]].delete(node)
        @pathway.graph.delete(node)
        @pathway.append(Bio::Relation.new(adjs[0], adjs[1], new_edge))
      end
      #@pathway.to_relations
      @pathway.relations.reject! do |rel|
        hash[rel.node[0]] or hash[rel.node[1]]
      end
      return hash.keys
    end

    # Insert a new node between adjacent nodes node1 and node2.
    # The old edge between node1 and node2 are changed to the edge
    # between new_node and node2.
    # The edge between node1 and new_node is newly created.
    #
    # If new_distance is specified, the distance between
    # node1 and new_node is set to new_distance, and
    # distance between new_node and node2 is set to
    # <code>tree.get_edge(node1, node2).distance - new_distance</code>.
    #
    # Returns self.
    # If node1 and node2 are not adjacent, raises IndexError.
    #
    # If new_node already exists in the tree, the tree would become
    # circular. In addition, if the edge between new_node and
    # node1 (or node2) already exists, it will be erased.
    def insert_node(node1, node2, new_node, new_distance = nil)
      unless edge = self.get_edge(node1, node2) then
        raise IndexError, 'nodes not found or two nodes are not adjacent'
      end
      new_edge = Edge.new(new_distance)
      self.remove_edge(node1, node2)
      self.add_edge(node1, new_node, new_edge)
      if new_distance and old_distance = get_edge_distance(edge) then
        old_distance -= new_distance
        begin
          edge.distance = old_distance
        rescue NoMethodError
          edge = old_distance
        end
      end
      self.add_edge(new_node, node2, edge)
      self
    end
  end #class Tree
end #module Bio

#---
# temporary added
#+++
require 'bio/db/newick'

