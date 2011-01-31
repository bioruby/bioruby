#
# = sample/demo_kegg_reaction.rb - demonstration of Bio::KEGG::REACTION
#
# Copyright::  Copyright (C) 2004 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::KEGG::REACTION, the parser class for the KEGG
# REACTION biochemical reaction database.
#
# == Usage
#
# Specify files containing KEGG REACTION data.
#
#  $ ruby demo_kegg_reaction.rb files...
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_kegg_reaction.rb test/data/KEGG/R00006.reaction 
#
# == Example of running this script
#
# Download test data.
#
#  $ ruby -Ilib bin/br_biofetch.rb reaction R00259 > R00259.reaction
#  $ ruby -Ilib bin/br_biofetch.rb reaction R02282 > R02282.reaction
#
# Run this script.
#
#  $ ruby -Ilib sample/demo_kegg_reaction.rb R00259.reaction R02282.reaction
#
# == Development information
#
# The code was moved from lib/bio/db/kegg/reaction.rb and modified.
#

require 'bio'

Bio::FlatFile.foreach(Bio::KEGG::REACTION, ARGF) do |rn|
  puts "### rn = Bio::KEGG::REACTION.new(str)"

  puts "# rn.entry_id"
  p rn.entry_id
  puts "# rn.name"
  p rn.name
  puts "# rn.definition"
  p rn.definition
  puts "# rn.equation"
  p rn.equation
  puts "# rn.rpairs"
  p rn.rpairs
  puts "# rn.pathways"
  p rn.pathways
  puts "# rn.enzymes"
  p rn.enzymes
  puts "# rn.orthologs"
  p rn.orthologs
  puts "# rn.orthologs_as_hash"
  p rn.orthologs_as_hash

  puts "=" * 78
end

