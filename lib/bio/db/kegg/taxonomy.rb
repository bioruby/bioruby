#
# = bio/db/kegg/taxonomy.rb - KEGG taxonomy parser class
#
# Copyright::  Copyright (C) 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#  $Id: taxonomy.rb,v 1.2 2007/07/09 10:29:16 k Exp $
#

module Bio
class KEGG

# == Description
#
# Parse the KEGG 'taxonomy' file which describes taxonomic classification
# of organisms.
#
# == References
#
# The KEGG 'taxonomy' file is available at
#
# * ftp://ftp.genome.jp/pub/kegg/genes/taxonomy
#
class Taxonomy

  def initialize(filename, orgs = [])
    # Stores the taxonomic tree as a linked list (implemented in Hash), so
    # every node need to have unique name (key) to work correctly
    @tree = Hash.new

    # Also stores the taxonomic tree as a list of arrays (full path)
    @path = Array.new

    # Also stores all leaf nodes (organism codes) of every intermediate nodes
    @leaves = Hash.new

    # tentative name for the root node (use accessor to change)
    @root = 'Genes'

    hier = Array.new
    level = 0
    label = nil

    File.open(filename).each do |line|
      next if line.strip.empty?

      # line for taxonomic hierarchy (indent according to the number of # marks)
      if line[/^#/]
	level = line[/^#+/].length
	label = line[/[A-z].*/]
	hier[level] = sanitize(label)

      # line for organims name (unify different strains of a species)
      else
	tax, org, name, desc = line.chomp.split("\t")
        if orgs.nil? or orgs.empty? or orgs.include?(org)
          species, strain, = name.split('_')
          # (0) Grouping of the strains of the same species.
          #  If the name of species is the same as the previous line,
          #  add the species to the same species group.
          #   ex. Gamma/enterobacteria has a large number of organisms,
          #       so sub grouping of strains is needed for E.coli strains etc.
          #
          # However, if the species name is already used, need to avoid
          # collision of species name as the current implementation stores
          # the tree as a Hash, which may cause the infinite loop.
          #
          # (1) If species name == the intermediate node of other lineage
          #  Add '_sp' to the species name to avoid the conflict (1-1), and if
          #  'species_sp' is already taken, use 'species_strain' instead (1-2).
          #   ex. Bacteria/Proteobacteria/Beta/T.denitrificans/tbd
          #       Bacteria/Proteobacteria/Epsilon/T.denitrificans_ATCC33889/tdn
          #    -> Bacteria/Proteobacteria/Beta/T.denitrificans/tbd
          #       Bacteria/Proteobacteria/Epsilon/T.denitrificans_sp/tdn
          #
          # (2) If species name == the intermediate node of the same lineage
          #  Add '_sp' to the species name to avoid the conflict.
          #   ex. Bacteria/Cyanobacgteria/Cyanobacteria_CYA/cya
          #       Bacteria/Cyanobacgteria/Cyanobacteria_CYB/cya
          #       Bacteria/Proteobacteria/Magnetococcus/Magnetococcus_MC1/mgm
          #    -> Bacteria/Cyanobacgteria/Cyanobacteria_sp/cya
          #       Bacteria/Cyanobacgteria/Cyanobacteria_sp/cya
          #       Bacteria/Proteobacteria/Magnetococcus/Magnetococcus_sp/mgm
          sp_group = "#{species}_sp"
          if @tree[species]
            if hier[level+1] == species
              # case (0)
            else
              # case (1-1)
              species = sp_group
              # case (1-2)
              if @tree[sp_group] and hier[level+1] != species
                species = name
              end
            end
          else
            if hier[level] == species
              # case (2)
              species = sp_group
            end
          end
          # 'hier' is an array of the taxonomic tree + species and strain name.
          #  ex. [nil, Eukaryotes, Fungi, Ascomycetes, Saccharomycetes] +
          #      [S_cerevisiae, sce]
          hier[level+1] = species	# sanitize(species)
          hier[level+2] = org
          ary = hier[1, level+2]
          warn ary.inspect if $DEBUG
          add_to_tree(ary)
          add_to_leaves(ary)
          add_to_path(ary)
        end
      end
    end
    return tree
  end

  attr_reader :tree
  attr_reader :path
  attr_reader :leaves
  attr_accessor :root

  def organisms(group)
    @leaves[group]
  end

  # Add a new path [node, subnode, subsubnode, ..., leaf] under the root node
  # and every intermediate nodes stores their child nodes as a Hash.
  def add_to_tree(ary)
    parent = @root
    ary.each do |node|
      @tree[parent] ||= Hash.new
      @tree[parent][node] = nil
      parent = node
    end
  end

  # Add a new path [node, subnode, subsubnode, ..., leaf] under the root node
  # and stores leaf nodes to the every intermediate nodes as an Array.
  def add_to_leaves(ary)
    leaf = ary.last
    ary.each do |node|
      @leaves[node] ||= Array.new
      @leaves[node] << leaf
    end
  end

  # Add a new path [node, subnode, subsubnode, ..., leaf] under the root node
  # and stores the path itself in an Array.
  def add_to_path(ary)
    @path << ary
  end

  # Compaction of intermediate nodes of the resulted taxonomic tree.
  #  - If child node has only one child node (grandchild), make the child of
  #    grandchild as a grandchild.
  #  ex.
  #    Plants / Monocotyledons / grass family / osa
  #    --> Plants / Monocotyledons / osa
  #
  def compact(node = root)
    # if the node has children
    if subnodes = @tree[node]
      # obtain grandchildren for each child
      subnodes.keys.each do |subnode|
        if subsubnodes = @tree[subnode]
          # if the number of grandchild node is 1
          if subsubnodes.keys.size == 1
            # obtain the name of the grandchild node
            subsubnode = subsubnodes.keys.first
            # obtain the child of the grandchlid node
            if subsubsubnodes = @tree[subsubnode]
              # make the child of grandchild node as a chlid of child node
              @tree[subnode] = subsubsubnodes
              # delete grandchild node
              @tree[subnode].delete(subsubnode)
              warn "--- compact: #{subsubnode} is replaced by #{subsubsubnodes}" if $DEBUG
              # retry until new grandchild also needed to be compacted.
              retry
            end
          end
        end
        # repeat recurseively
        compact(subnode)
      end
    end
  end

  # Reduction of the leaf node of the resulted taxonomic tree.
  #  - If the parent node have only one leaf node, replace parent node
  #    with the leaf node.
  #  ex.
  #   Plants / Monocotyledons / osa
  #   --> Plants / osa
  #
  def reduce(node = root)
    # if the node has children
    if subnodes = @tree[node]
      # obtain grandchildren for each child
      subnodes.keys.each do |subnode|
        if subsubnodes = @tree[subnode]
          # if the number of grandchild node is 1
          if subsubnodes.keys.size == 1
            # obtain the name of the grandchild node
            subsubnode = subsubnodes.keys.first
            # if the grandchild node is a leaf node
            unless @tree[subsubnode]
              # make the grandchild node as a child node
              @tree[node].update(subsubnodes)
              # delete child node
              @tree[node].delete(subnode)
              warn "--- reduce: #{subnode} is replaced by #{subsubnode}" if $DEBUG
            end
          end
        end
        # repeat recursively
        reduce(subnode)
      end
    end
  end

  # Traverse the taxonomic tree by the depth first search method
  # under the given (root or intermediate) node.
  def dfs(parent, &block)
    if children = @tree[parent]
      yield parent, children
      children.keys.each do |child|
        dfs(child, &block)
      end
    end
  end

  # Similar to the dfs method but also passes the current level of the nest
  # to the iterator.
  def dfs_with_level(parent, &block)
    @level ||= 0
    if children = @tree[parent]
      yield parent, children, @level
      @level += 1
      children.keys.each do |child|
        dfs_with_level(child, &block)
      end
      @level -= 1
    end
  end

  # Convert the taxonomic tree structure to a simple ascii art.
  def to_s
    result = "#{@root}\n"
    @tree[@root].keys.each do |node|
      result += ascii_tree(node, "  ")
    end
    return result
  end

  private

  # Helper method for the to_s method.
  def ascii_tree(node, indent)
    result = "#{indent}+- #{node}\n"
    indent += "  "
    @tree[node].keys.each do |child|
      if @tree[child]
        result += ascii_tree(child, indent)
      else
        result += "#{indent}+- #{child}\n"
      end
    end
    return result
  end

  def sanitize(str)
    str.gsub(/[^A-z0-9]/, '_')
  end

end # Taxonomy

end # KEGG
end # Bio



if __FILE__ == $0

  # Usage:
  # % wget ftp://ftp.genome.jp/pub/kegg/genes/taxonomy
  # % ruby taxonomy.rb taxonomy | less -S

  taxonomy = ARGV.shift
  org_list = ARGV.shift || nil

  if org_list
    orgs = File.readlines(org_list).map{|x| x.strip}
  else
    orgs = nil
  end

  tree = Bio::KEGG::Taxonomy.new(taxonomy, orgs)

  puts ">>> tree - original"
  puts tree

  puts ">>> tree - after compact"
  tree.compact
  puts tree

  puts ">>> tree - after reduce"
  tree.reduce
  puts tree

  puts ">>> path - sorted"
  tree.path.sort.each do |path|
    puts path.join("/")
  end

  puts ">>> group : orgs"
  tree.dfs(tree.root) do |parent, children|
    if orgs = tree.organisms(parent)
      puts "#{parent.ljust(30)} (#{orgs.size})\t#{orgs.join(', ')}"
    end
  end

  puts ">>> group : subgroups"
  tree.dfs_with_level(tree.root) do |parent, children, level|
    subgroups = children.keys.sort
    indent = " " * level
    label  = "#{indent} #{level} #{parent}"
    puts "#{label.ljust(35)}\t#{subgroups.join(', ')}"
  end

end
