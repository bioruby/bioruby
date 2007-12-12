#
# = bio/db/newick.rb - Newick Standard phylogenetic tree parser / formatter
#
# Copyright::   Copyright (C) 2004-2006
#               Naohisa Goto <ng@bioruby.org>
#               Daniel Amelang <dan@amelang.net>
# License::     The Ruby License
#
# $Id: newick.rb,v 1.8 2007/12/12 16:06:22 ngoto Exp $
#
# == Description
#
# This file contains parser and formatter of Newick and NHX.
#
# == References
#
# * http://evolution.genetics.washington.edu/phylip/newick_doc.html
# * http://www.phylosoft.org/forester/NHX.html
#

require 'strscan'
require 'bio/tree'

module Bio
  class Tree

    #---
    # newick output
    #+++

    # default options
    DEFAULT_OPTIONS =
      { :indent => '  ' }

    def __get_option(key, options)
      if (r = options[key]) != nil then
        r
      elsif @options && (r = @options[key]) != nil then
        r
      else
        DEFAULT_OPTIONS[key]
      end
    end
    private :__get_option


    # formats Newick label (unquoted_label or quoted_label)
    def __to_newick_format_label(str, options)
      if __get_option(:parser, options) == :naive then
        return str.to_s
      end
      str = str.to_s
      if /([\(\)\,\:\[\]\_\'\x00-\x1f\x7f])/ =~ str then
        # quoted_label
        return "\'" + str.gsub(/\'/, "\'\'") + "\'"
      end
      # unquoted_label
      return str.gsub(/ /, '_')
    end
    private :__to_newick_format_label

    # formats leaf
    def __to_newick_format_leaf(node, edge, options)

      label = __to_newick_format_label(get_node_name(node), options)

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

    # formats leaf for NHX
    def __to_newick_format_leaf_NHX(node, edge, options)

      label = __to_newick_format_label(get_node_name(node), options)

      dist = get_edge_distance_string(edge)

      bs = get_node_bootstrap_string(node)

      if  __get_option(:branch_length_style, options) == :disabled
        dist = nil
      end

      nhx = {}

      # bootstrap
      nhx[:B] = bs if bs and !(bs.empty?)
      # EC number
      nhx[:E] = node.ec_number if node.instance_eval {
        defined?(@ec_number) && self.ec_number
      }
      # scientific name
      nhx[:S] = node.scientific_name if node.instance_eval {
        defined?(@scientific_name) && self.scientific_name
      }
      # taxonomy id
      nhx[:T] = node.taxonomy_id if node.instance_eval {
        defined?(@taxonomy_id) && self.taxonomy_id
      }

      # :D (gene duplication or speciation)
      if node.instance_eval { defined?(@events) && !(self.events.empty?) } then
        if node.events.include?(:gene_duplication)
          nhx[:D] = 'Y'
        elsif node.events.include?(:speciation)
          nhx[:D] = 'N'
        end
      end

      # log likelihood
      nhx[:L] = edge.log_likelihood if edge.instance_eval {
        defined?(@log_likelihood) && self.log_likelihood }
      # width
      nhx[:W] = edge.width if edge.instance_eval {
        defined?(@width) && self.width }

      # merges other parameters
      flag = node.instance_eval { defined? @nhx_parameters }
      nhx.merge!(node.nhx_parameters) if flag
      flag = edge.instance_eval { defined? @nhx_parameters }
      nhx.merge!(edge.nhx_parameters) if flag

      nhx_string = nhx.keys.sort{ |a,b| a.to_s <=> b.to_s }.collect do |key|
        "#{key.to_s}=#{nhx[key].to_s}"
      end.join(':')
      nhx_string = "[&&NHX:" + nhx_string + "]" unless nhx_string.empty?
     
      label + (dist ? ":#{dist}" : '') + nhx_string
    end
    private :__to_newick_format_leaf_NHX

    #
    def __to_newick(parents, source, depth, format_leaf,
                    options, &block)
      result = []
      if indent_string = __get_option(:indent, options) then
        indent0 = indent_string * depth
        indent  = indent_string * (depth + 1)
        newline = "\n"
      else
        indent0 = indent = newline = ''
      end
      out_edges = self.out_edges(source)
      if block_given? then
        out_edges.sort! { |edge1, edge2| yield(edge1[1], edge2[1]) }
      else
        out_edges.sort! do |edge1, edge2|
          o1 = edge1[1].order_number
          o2 = edge2[1].order_number
          if o1 and o2 then
            o1 <=> o2
          else
            edge1[1].name.to_s <=> edge2[1].name.to_s
          end
        end
      end
      out_edges.each do |src, tgt, edge|
        if parents.include?(tgt) then
          ;;
        elsif self.out_degree(tgt) == 1 then
          result << indent + __send__(format_leaf, tgt, edge, options)
        else
          result << 
            __to_newick([ src ].concat(parents), tgt, depth + 1,
                        format_leaf, options) +
            __send__(format_leaf, tgt, edge, options)
        end
      end
      indent0 + "(" + newline + result.join(',' + newline) +
        (result.size > 0 ? newline : '') + indent0 + ')'
    end
    private :__to_newick

    # Returns a newick formatted string.
    # If block is given, the order of the node is sorted
    # (as the same manner as Enumerable#sort).
    #
    # Available options:
    # <tt>:indent</tt>::
    #     indent string; set false to disable (default: '  ')
    # <tt>:bootstrap_style</tt>::
    #     <tt>:disabled</tt> disables bootstrap representations.
    #     <tt>:traditional</tt> for traditional style.
    #     <tt>:molphy</tt> for Molphy style (default).
    def output_newick(options = {}, &block) #:yields: node1, node2
      root = @root
      root ||= self.nodes.first
      return '();' unless root
      __to_newick([], root, 0, :__to_newick_format_leaf, options, &block) +
        __to_newick_format_leaf(root, Edge.new, options) +
        ";\n"
    end

    alias newick output_newick
      

    # Returns a NHX (New Hampshire eXtended) formatted string.
    # If block is given, the order of the node is sorted
    # (as the same manner as Enumerable#sort).
    #
    # Available options:
    # <tt>:indent</tt>::
    #     indent string; set false to disable (default: '  ')
    #
    def output_nhx(options = {}, &block) #:yields: node1, node2
      root = @root
      root ||= self.nodes.first
      return '();' unless root
      __to_newick([], root, 0,
                  :__to_newick_format_leaf_NHX, options, &block) +
        __to_newick_format_leaf_NHX(root, Edge.new, options) +
        ";\n"
    end

    # Returns formatted text (or something) of the tree
    # Currently supported format is: :newick, :nhx
    def output(format, *arg, &block)
      case format
      when :newick
        output_newick(*arg, &block)
      when :nhx
        output_nhx(*arg, &block)
      when :phylip_distance_matrix
        output_phylip_distance_matrix(*arg, &block)
      else
        raise 'Unknown format'
      end
    end

    #---
    # This method isn't suitable to written in this file?
    #+++

    # Generates phylip-style distance matrix as a string.
    # if nodes is not given, all leaves in the tree are used.
    # If the names of some of the given (or default) nodes
    # are not defined or are empty, the names are automatically generated.
    def output_phylip_distance_matrix(nodes = nil, options = {})
      nodes = self.leaves unless nodes
      names = nodes.collect do |x|
        y = get_node_name(x)
        y = sprintf("%x", x.__id__.abs) if y.empty?
        y
      end
      m = self.distance_matrix(nodes)
      Bio::Phylip::DistanceMatrix.generate(m, names, options)
    end

  end #class Tree

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

    # same as Bio::Tree::Edge
    Edge = Bio::Tree::Edge

    # same as Bio::Tree::Node
    Node = Bio::Tree::Node

    # Creates a new Newick object.
    # _options_ for parsing can be set.
    #
    # Available options:
    # <tt>:bootstrap_style</tt>::
    #     <tt>:traditional</tt> for traditional bootstrap style,
    #     <tt>:molphy</tt> for molphy style,
    #     <tt>:disabled</tt> to ignore bootstrap strings.
    #     For details of default actions, please read the notes below.
    # <tt>:parser</tt>::
    #     <tt>:naive</tt> for using naive parser, compatible with
    #     BioRuby 1.1.0, which ignores quoted strings and
    #     do not convert underscores to spaces. 
    #
    # Notes for bootstrap style:
    # Molphy-style bootstrap values may always be parsed, even if
    # the <tt>options[:bootstrap_style]</tt> is set to
    # <tt>:traditional</tt> or <tt>:disabled</tt>.
    #
    # Note for default or traditional bootstrap style:
    # By default, if all of the internal node's names are numeric
    # and there are no NHX and no molphy-style boostrap values,
    # the names of internal nodes are regarded as bootstrap values.
    # <tt>options[:bootstrap_style] = :disabled</tt> or <tt>:molphy</tt>
    # to disable the feature (or at least one NHX tag exists).
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
    # Returns a Bio::Tree object.
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
    def __parse_newick_leaf(leaf_tokens, node, edge, options)
      t = leaf_tokens.shift
      if !t.kind_of?(Symbol) then
        node.name = t
        t = leaf_tokens.shift
      end

      if t == :':' then
        t = leaf_tokens.shift
        if !t.kind_of?(Symbol) then
          edge.distance_string = t if t and !(t.strip.empty?)
          t = leaf_tokens.shift
        end
      end

      if t == :'[' then
        btokens = leaf_tokens
        case __get_option(:original_format, options)
        when :nhx
          # regarded as NHX string which might be broken
          __parse_nhx(btokens, node, edge)
        when :traditional
          # simply ignored
        else
          case btokens[0].to_s.strip
          when ''
            # not automatically determined
          when /\A\&\&NHX/
            # NHX string
            # force to set NHX mode
            @options[:original_format] = :nhx
            __parse_nhx(btokens, node, edge)
          else
            # Molphy-style boostrap values
            # let molphy mode if nothing determined
            @options[:original_format] ||= :molphy
            bstr = ''
            while t = btokens.shift and t != :']'
              bstr.concat t.to_s
            end
            node.bootstrap_string = bstr
          end #case btokens[0]
        end
      end

      if !btokens and !leaf_tokens.empty? then
        # syntax error?
      end
      node.name ||= '' # compatibility for older BioRuby

      # returns true
      true
    end

    # Parses NHX (New Hampshire eXtended) string
    def __parse_nhx(btokens, node, edge)
      btokens.shift if btokens[0] == '&&NHX'
      btokens.each do |str|
        break if str == :']'
        next if str.kind_of?(Symbol)
        tag, val = str.split(/\=/, 2)
        case tag
        when 'B'
          node.bootstrap_string = val
        when 'D'
          case val
            when 'Y'
            node.events.push :gene_duplication
            when 'N'
            node.events.push :speciation
          end
        when 'E'
          node.ec_number = val
        when 'L'
          edge.log_likelihood = val.to_f
        when 'S'
          node.scientific_name = val
        when 'T'
          node.taxonomy_id = val
        when 'W'
          edge.width = val.to_i
        when 'XB'
          edge.nhx_parameters[:XB] = val
        when 'O', 'SO'
          node.nhx_parameters[tag.to_sym] = val.to_i
        else # :Co, :SN, :Sw, :XN, and others
          node.nhx_parameters[tag.to_sym] = val
        end
      end #each
      true
    end

    # splits string to tokens
    def __parse_newick_tokenize(str, options)
      str = str.chop if str[-1..-1] == ';'
      # http://evolution.genetics.washington.edu/phylip/newick_doc.html
      # quoted_label ==> ' string_of_printing_characters '
      # single quote in quoted_label is '' (two single quotes)
      #

      if __get_option(:parser, options) == :naive then
        ary = str.split(/([\(\)\,\:\[\]])/)
        ary.collect! { |x| x.strip!; x.empty? ? nil : x }
        ary.compact!
        ary.collect! do |x|
          if /\A([\(\)\,\:\[\]])\z/ =~ x then
            x.intern
          else
            x
          end
        end
        return ary
      end

      tokens = []
      ss = StringScanner.new(str)

      while !(ss.eos?)
        if ss.scan(/\s+/) then
          # do nothing

        elsif ss.scan(/[\(\)\,\:\[\]]/) then
          # '(' or ')' or ',' or ':' or '[' or ']'
          t = ss.matched
          tokens.push t.intern

        elsif ss.scan(/\'/) then
          # quoted_label
          t = ''
          while true
            if ss.scan(/([^\']*)\'/) then
              t.concat ss[1]
              if  ss.scan(/\'/) then
                # single quote in quoted_label
                t.concat ss.matched
              else
                break
              end
            else
              # incomplete quoted_label?
              break
            end
          end #while true
          unless ss.match?(/\s*[\(\)\,\:\[\]]/) or ss.match?(/\s*\z/) then
            # label continues? (illegal, but try to rescue)
            if ss.scan(/[^\(\)\,\:\[\]]+/) then
              t.concat ss.matched.lstrip
            end
          end
          tokens.push t

        elsif ss.scan(/[^\(\)\,\:\[\]]+/) then
          # unquoted_label
          t = ss.matched.strip
          t.gsub!(/[\r\n]/, '')
          # unquoted underscore should be converted to blank
          t.gsub!(/\_/, ' ')
          tokens.push t unless t.empty?

        else
          # unquoted_label in end of string
          t = ss.rest.strip
          t.gsub!(/[\r\n]/, '')
          # unquoted underscore should be converted to blank
          t.gsub!(/\_/, ' ')
          tokens.push t unless t.empty?
          ss.terminate

        end
      end #while !(ss.eos?)

      tokens
    end

    # get tokens for a leaf
    def __parse_newick_get_tokens_for_leaf(ary)
      r = []
      while t = ary[0] and t != :',' and t != :')' and t != :'('
        r.push ary.shift
      end
      r
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
      ary = __parse_newick_tokenize(str, options)
      previous_token = nil
      # main loop
      while token = ary.shift
        #p token
        case token
        when :','
          if previous_token == :',' or previous_token == :'(' then
            # there is a leaf whose name is empty.
            ary.unshift(token)
            ary.unshift('')
            token = nil
          end
        when :'('
          node = Node.new
          nodes << node
          internal_nodes << node
          node_stack.push(cur_node)
          cur_node = node
        when :')'
          if previous_token == :',' or previous_token == :'(' then
            # there is a leaf whose name is empty.
            ary.unshift(token)
            ary.unshift('')
            token = nil
          else
            edge = Edge.new
            leaf_tokens = __parse_newick_get_tokens_for_leaf(ary)
            token = nil
            if leaf_tokens.size > 0 then
              __parse_newick_leaf(leaf_tokens, cur_node, edge, options)
            end
            parent = node_stack.pop
            raise ParseError, 'unmatched parentheses' unless parent
            edges << Bio::Relation.new(parent, cur_node, edge)
            cur_node = parent
          end
        else
          leaf = Node.new
          edge = Edge.new
          ary.unshift(token)
          leaf_tokens = __parse_newick_get_tokens_for_leaf(ary)
          token = nil
          __parse_newick_leaf(leaf_tokens, leaf, edge, options)
          nodes << leaf
          edges << Bio::Relation.new(cur_node, leaf, edge)
        end #case
        previous_token = token
      end #while
      raise ParseError, 'unmatched parentheses' unless node_stack.empty?
      bsopt = __get_option(:bootstrap_style, options)
      ofmt  = __get_option(:original_format, options)
      unless bsopt == :disabled or bsopt == :molphy or 
          ofmt == :nhx or ofmt == :molphy then
        # If all of the internal node's names are numeric,
        # the names are regarded as bootstrap values.
        flag = false
        internal_nodes.each do |node|
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
          @options[:original_format] = :traditional
          internal_nodes.each do |node|
            if node.name then
              node.bootstrap_string = node.name
              node.name = nil
            end
          end
        end
      end
      # Sets nodes order numbers
      nodes.each_with_index do |node, i|
        node.order_number = i
      end
      # If the root implicitly prepared by the program is a leaf and
      # there are no additional information for the edge from the root to
      # the first internal node, the root is removed.
      if rel = edges[-1] and rel.node == [ root, internal_nodes[0] ] and
          rel.relation.instance_eval {
          !defined?(@distance) and !defined?(@log_likelihood) and
          !defined?(@width) and !defined?(@nhx_parameters) } and
          edges.find_all { |x| x.node.include?(root) }.size == 1
        nodes.shift
        edges.pop
      end
      # Let the tree into instance variables
      tree = Bio::Tree.new
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

