#
# = bio/db/kegg/taxonomy.rb - KEGG taxonomy parser class
#
# Copyright::  Copyright (C) 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#  $Id: taxonomy.rb,v 1.1 2007/07/09 08:48:03 k Exp $
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
    @tree = Hash.new
    @path = Array.new
    @leaves = Hash.new

    # ルートノードを Genes とする
    @root = 'Genes'

    hier = Array.new
    level = 0
    label = nil

    File.open(filename).each do |line|
      next if line.strip.empty?

      # タクソノミー階層行 - # の個数で階層をインデントする処理
      if line[/^#/]
	level = line[/^#+/].length
	label = line[/[A-z].*/]
	hier[level] = sanitize(label)

      # 生物種リスト行 - 生物種コードとストレイン違いをまとめる処理
      else
	tax, org, name, desc = line.chomp.split("\t")
        if orgs.nil? or orgs.empty? or orgs.include?(org)
          species, strain, = name.split('_')
          # (0) species 名が直前の行のものと同じ場合、そのグループに追加
          #  Gamma/enterobacteria など括りが大まかで種数の多いグループを
          #  同じ種名（ストレイン違い）ごとにサブグループ化するのが目的
          #   ex. E.coli, H.influenzae など
          # トリッキーな部分：
          #  もし species 名が上位中間ノード（### 行など）と同じ（既出）であれば
          #  Tree を Hash で持つ仕様とコンフリクトするので別名が必要
          # (1) species 名が系統の異なる上位中間ノード名と同じ場合
          #   → とりあえず species 名に _sp をつけてコンフリクトを避ける (1-1)
          #      すでに _sp も使われている場合は strain 名を使う (1-2)
          #   ex. Bacteria/Proteobacteria/Beta/T.denitrificans/tbd と
          #       Bacteria/Proteobacteria/Epsilon/T.denitrificans_ATCC33889/tdn
          #    -> Bacteria/Proteobacteria/Beta/T.denitrificans/tbd と
          #       Bacteria/Proteobacteria/Epsilon/T.denitrificans_sp/tdn
          # (2) species 名が上記中間ノード名と同じ場合
          #   → とりあえず species 名に _sp をつけてコンフリクトを避ける
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
          # hier は [nil, Eukaryotes, Fungi, Ascomycetes, Saccharomycetes] に
          # species と org の [S_cerevisiae, sce] を加えた形式
          hier[level+1] = species
          #hier[level+1] = sanitize(species)
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

  # root ノードの下に [node, subnode, subsubnode, ..., leaf] なパスを追加
  # 各中間ノードが子要素をハッシュで保持
  def add_to_tree(ary)
    parent = @root
    ary.each do |node|
      @tree[parent] ||= Hash.new
      @tree[parent][node] = nil
      parent = node
    end
  end

  # 各中間ノードに対応するリーフのリストを保持
  def add_to_leaves(ary)
    leaf = ary.last
    ary.each do |node|
      @leaves[node] ||= Array.new
      @leaves[node] << leaf
    end
  end

  # 各中間ノードまでのパスを保持
  def add_to_path(ary)
    @path << ary
  end

  # 親ノードから見て子ノードが孫ノードを１つしか持っていない場合、
  # 孫ノードの子供（ひ孫）を、子ノードの子（孫）とする
  #
  # ex.
  #  Plants / Monocotyledons / grass family / osa --> Plants / Monocotyledons / osa
  #
  def compact(node = root)
    # 子ノードがあり
    if subnodes = @tree[node]
      # それぞれの子ノードについて
      subnodes.keys.each do |subnode|
        # 孫ノードを取得
        if subsubnodes = @tree[subnode]
          # 孫ノードの数が 1 つの場合
          if subsubnodes.keys.size == 1
            # 孫ノードの名前を取得
            subsubnode = subsubnodes.keys.first
            # 孫ノードの子供を取得
            if subsubsubnodes = @tree[subsubnode]
              # 孫ノードの子供を子ノードの子供にすげかえ
              @tree[subnode] = subsubsubnodes
              # 孫ノードを削除
              @tree[subnode].delete(subsubnode)
              warn "--- compact: #{subsubnode} is replaced by #{subsubsubnodes}" if $DEBUG
              # 新しい孫ノードでも compact が必要かもしれないため繰り返す
              retry
            end
          end
        end
        # 子ノードを親ノードとして再帰
        compact(subnode)
      end
    end
  end

  # リーフノードが１つの場合、親ノードをリーフノードにすげかえる
  #
  # ex.
  #  Plants / Monocotyledons / osa --> Plants / osa
  #
  def reduce(node = root)
    # 子ノードがあり
    if subnodes = @tree[node]
      # それぞれの子ノードについて
      subnodes.keys.each do |subnode|
        # 孫ノードを取得
        if subsubnodes = @tree[subnode]
          # 孫ノードの数が 1 つの場合
          if subsubnodes.keys.size == 1
            # 孫ノードの名前を取得
            subsubnode = subsubnodes.keys.first
            # 孫ノードがリーフの場合
            unless @tree[subsubnode]
              # 孫ノードを子ノードにすげかえ
              @tree[node].update(subsubnodes)
              # 子ノードを削除
              @tree[node].delete(subnode)
              warn "--- reduce: #{subnode} is replaced by #{subsubnode}" if $DEBUG
            end
          end
        end
        # 子ノードを親ノードとして再帰
        reduce(subnode)
      end
    end
  end

  # 与えられたノードと、子ノードのリスト（Hash）をうけとり、
  # 子ノードについてイテレーションする
  def dfs(parent, &block)
    if children = @tree[parent]
      yield parent, children
      children.keys.each do |child|
        dfs(child, &block)
      end
    end
  end

  # 現在の階層の深さもイテレーションに渡す
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

  # ツリー構造をアスキーアートで表示する
  def to_s
    result = "#{@root}\n"
    @tree[@root].keys.each do |node|
      result += subtree(node, "  ")
    end
    return result
  end

  private

  # 上記 to_s 用の下請けメソッド
  def subtree(node, indent)
    result = "#{indent}+- #{node}\n"
    indent += "  "
    @tree[node].keys.each do |child|
      if @tree[child]
        result += subtree(child, indent)
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
