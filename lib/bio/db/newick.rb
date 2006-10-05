#
# = bio/db/newick.rb - Newick Standard phylogenetic tree parser / formatter
#
# Copyright::   Copyright (C) 2004-2006
#               Naohisa Goto <ng@bioruby.org>
#               Daniel Amelang <dan@amelang.net>
# License::     Ruby's
#
# $Id: newick.rb,v 1.1 2006/10/05 13:38:22 ngoto Exp $
#

module Bio
  class PhylogeneticTree

    #---
    # newick output
    #+++

    def __get_option(key, options)
      options[key] or (@options ? @options[key] : nil)
    end
    private :__get_option

    # formats leaf
    def __to_newick_format_leaf(node, edge, options)

      label = get_node_name(node).to_s

      dist = get_edge_distance_string(edge)

      bs = get_node_bootstrap_string(node)

      if  __get_option(:branch_length_style, options) == :disabled
        dist = nil
      end
     
      case __get_option(:bootstrap_style, options)
      when :disabled
        label + (dist ? ":#{dist}" : '')
      when :molphy
        label + (dist ? ":#{dist}" : '') + (bs ? "[#{bs}]" : '')
      when :traditional
        label + (bs ? bs : '') + (dist ? ":#{dist}" : '')
      else
        # default: same as molphy style
        label + (dist ? ":#{dist}" : '') + (bs ? "[#{bs}]" : '')
      end
    end
    private :__to_newick_format_leaf

    #
    def __to_newick(parents, source, depth, options)
      result = []
      indent0 = '  ' * depth
      indent  = '  ' * (depth + 1)
      self.each_out_edge(source) do |src, tgt, edge|
        if parents.include?(tgt) then
          ;;
        elsif self.out_degree(tgt) == 1 then
          result << indent + __to_newick_format_leaf(tgt, edge, options)
        else
          result << 
            __to_newick([ src ].concat(parents), tgt, depth + 1, options) +
            __to_newick_format_leaf(tgt, edge, options)
        end
      end
      indent0 + "(\n" + result.join(",\n") +
        (result.size > 0 ? "\n" : '') + indent0 + ')'
    end
    private :__to_newick

    # Returns a newick formatted string.
    def newick(options = {})
      root = @root
      root ||= self.nodes.first
      return '();' unless root
      __to_newick([], root, 0, options) +
        __to_newick_format_leaf(root, Edge.new, options) +
        ";\n"
    end
  end #class PhylogeneticTree

  #---
  # newick parser
  #+++

  # Newick standard phylogenetic tree parser class.
  #
  # This is alpha version. Incompatible changes may be made frequently.
  class Newick

    # delemiter of the entry
    DELIMITER = RS = ";"

    # parse error class
    class ParseError < RuntimeError; end

    # same as Bio::PhylogeneticTree::Edge
    Edge = Bio::PhylogeneticTree::Edge

    # same as Bio::PhylogeneticTree::Node
    Node = Bio::PhylogeneticTree::Node

    # Creates a new Newick object.
    # _options_ for parsing can be set.
    #
    # Note: molphy-style bootstrap values are always parsed, even if
    # the options[:bootstrap_style] is set to :traditional or :disabled.
    # Note: By default, if all of the internal node's names are numeric
    # and there are no molphy-style boostrap values,
    # the names are regarded as bootstrap values.
    # options[:bootstrap_style] = :disabled or :molphy to disable the feature.
    def initialize(str, options = nil)
      str = str.sub(/\;(.*)/m, ';')
      @original_string = str
      @entry_overrun = $1
      @options = (options or {})
    end

    # parser options
    # (in some cases, options can be automatically set by the parser)
    attr_reader :options

    # original string before parsing
    attr_reader :original_string

    # string after this entry
    attr_reader :entry_overrun

    # Gets the tree.
    # Returns a Bio::PhylogeneticTree object.
    def tree
      if !defined?(@tree)
        @tree = __parse_newick(@original_string, @options)
      else
        @tree
      end
    end

    # Re-parses the tree from the original string.
    # Returns self.
    # This method is useful after changing parser options.
    def reparse
      remove_instance_variable(:tree)
      self.tree
      self
    end

    private

    # gets a option
    def __get_option(key, options)
      options[key] or (@options ? @options[key] : nil)
    end

    # Parses newick formatted leaf (or internal node) name.
    def __parse_newick_leaf(str, node, edge)
      case str
      when /(.*)\:(.*)\[(.*)\]/
        node.name = $1
        edge.distance_string = $2 if $2 and !($2.strip.empty?)
        node.bootstrap_string = $3 if $3 and !($3.strip.empty?)
      when /(.*)\[(.*)\]/
        node.name = $1
        node.bootstrap_string = $2 if $2 and !($2.strip.empty?)
      when /(.*)\:(.*)/
        node.name = $1
        edge.distance_string = $2 if $2 and !($2.strip.empty?)
      else
        node.name = str
      end
      true
    end

    # Parses newick formatted string.
    def __parse_newick(str, options = {})
      # initializing
      root = Node.new
      cur_node = root
      edges = []
      nodes = [ root ]
      internal_nodes = []
      node_stack = []
      # preparation of tokens
      str = str.chop if str[-1..-1] == ';'
      ary = str.split(/([\(\)\,])/)
      ary.collect! { |x| x.strip!; x.empty? ? nil : x }
      ary.compact!
      previous_token = nil
      # main loop
      while token = ary.shift
        #p token
        case token
        when ','
          if previous_token == ',' or previous_token == '(' then
            # there is a leaf whose name is empty.
            ary.unshift(token)
            ary.unshift('')
            token = nil
          end
        when '('
          node = Node.new
          nodes << node
          internal_nodes << node
          node_stack.push(cur_node)
          cur_node = node
        when ')'
          if previous_token == ',' or previous_token == '(' then
            # there is a leaf whose name is empty.
            ary.unshift(token)
            ary.unshift('')
            token = nil
          else
            edge = Edge.new
            next_token = ary[0]
            if next_token and next_token != ',' and next_token != ')' then
              __parse_newick_leaf(next_token, cur_node, edge)
              ary.shift
            end
            parent = node_stack.pop
            raise ParseError, 'unmatched parentheses' unless parent
            edges << Bio::Relation.new(parent, cur_node, edge)
            cur_node = parent
          end
        else
          leaf = Node.new
          edge = Edge.new
          __parse_newick_leaf(token, leaf, edge)
          nodes << leaf
          edges << Bio::Relation.new(cur_node, leaf, edge)
        end #case
        previous_token = token
      end #while
      raise ParseError, 'unmatched parentheses' unless node_stack.empty?
      bsopt = __get_option(:bootstrap_style, options)
      unless bsopt == :disabled or bsopt == :molphy then
        # If all of the internal node's names are numeric
        # and there are no molphy-style boostrap values,
        # the names are regarded as bootstrap values.
        flag = false
        internal_nodes.each do |node|
          if node.bootstrap
            unless __get_option(:bootstrap_style, options) == :traditional
              @options[:bootstrap_style] = :molphy
            end
            flag = false
            break
          end
          if node.name and !node.name.to_s.strip.empty? then
            if /\A[\+\-]?\d*\.?\d*\z/ =~ node.name
              flag = true
            else
              flag = false
              break
            end
          end
        end
        if flag then
          @options[:bootstrap_style] = :traditional
          internal_nodes.each do |node|
            if node.name then
              node.bootstrap_string = node.name
              node.name = nil
            end
          end
        end
      end
      # If the root implicitly prepared by the program is a leaf and
      # there are no additional information for the edge from the root to
      # the first internal node, the root is removed.
      if rel = edges[-1] and rel.node == [ root, internal_nodes[0] ] and
          rel.relation.instance_eval { !defined?(@distance) } and
          edges.find_all { |x| x.node.include?(root) }.size == 1
        nodes.shift
        edges.pop
      end
      # Let the tree into instance variables
      tree = Bio::PhylogeneticTree.new
      tree.instance_eval {
        @pathway.relations.concat(edges)
        @pathway.to_list
      }
      tree.root = nodes[0]
      tree.options.update(@options)
      tree
    end
  end #class Newick

end #module Bio

