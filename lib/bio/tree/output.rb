#
# = bio/tree/output.rb - Phylogenetic tree formatter
#
# Copyright::   Copyright (C) 2004-2006
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
#
# == Description
#
# This file contains formatter of Newick, NHX and Phylip distance matrix.
#
# == References
#
# * http://evolution.genetics.washington.edu/phylip/newick_doc.html
# * http://www.phylosoft.org/forester/NHX.html
#

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

end #module Bio
