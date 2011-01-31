#
# = sample/demo_kegg_taxonomy.rb - demonstration of Bio::KEGG::Taxonomy
#
# Copyright::  Copyright (C) 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# IMPORTANT NOTE: currently, this sample does not work!
#
# Demonstration of Bio::KEGG::Taxonomy.
#
# == Usage
#
# Specify a file containing KEGG Taxonomy data.
#
#  $ ruby demo_kegg_taxonomy.rb file
#
# Optionally, when a file containing organisms list (1 line per 1 organism)
# is specified after the file, only the specified organisms are shown.
#
#  $ ruby demo_kegg_taxonomy.rb kegg_taxonomy_file org_list_file
#
# == Example of running this script
#
# Download test data.
#
#  $ wget ftp://ftp.genome.jp/pub/kegg/genes/taxonomy
#
# The downloaded filename is "taxonomy".
#
# Run this script.
#
#  $ ruby -Ilib sample/demo_kegg_taxonomy.rb taxonomy
#
# == Development information
#
# The code was moved from lib/bio/db/kegg/taxonomy.rb.
#

require 'bio'

#if __FILE__ == $0

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

#end
