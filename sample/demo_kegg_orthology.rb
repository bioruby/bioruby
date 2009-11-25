#
# = sample/demo_kegg_orthology.rb - demonstration of Bio::KEGG::ORTHOLOGY
#
# Copyright::  Copyright (C) 2003-2007 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2003 Masumi Itoh <m@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::KEGG::ORTHOLOGY, the parser class for the KEGG
# ORTHOLOGY database entry.
#
# == Usage
#
# Specify files containing KEGG ORTHOLOGY data.
#
#  $ ruby demo_kegg_orthology.rb files...
#
# == Example of running this script
#
# Download test data.
#
#  $ ruby -Ilib bin/br_biofetch.rb ko K00001 > K00001.ko
#  $ ruby -Ilib bin/br_biofetch.rb ko K00161 > K00161.ko
#
# Run this script.
#
#  $ ruby -Ilib sample/demo_kegg_orthology.rb K00001.ko K00161.ko
#
# == Development information
#
# The code was moved from lib/bio/db/kegg/orthology.rb and modified.
#

require 'bio'

Bio::FlatFile.foreach(Bio::KEGG::ORTHOLOGY, ARGF) do |ko|
  puts "### ko = Bio::KEGG::ORTHOLOGY.new(str)"

  puts "# ko.ko_id"
  p ko.entry_id
  puts "# ko.name"
  p ko.name
  puts "# ko.names"
  p ko.names
  puts "# ko.definition"
  p ko.definition
  puts "# ko.keggclass"
  p ko.keggclass
  puts "# ko.keggclasses"
  p ko.keggclasses
  puts "# ko.pathways"
  p ko.pathways
  puts "# ko.dblinks"
  p ko.dblinks
  puts "# ko.genes"
  p ko.genes

  puts "=" * 78
end

