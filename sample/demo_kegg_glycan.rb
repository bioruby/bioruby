#
# = sample/demo_kegg_glycan.rb - demonstration of Bio::KEGG::GLYCAN
#
# Copyright::  Copyright (C) 2004 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::KEGG::GLYCAN, a parser class for the KEGG GLYCAN
# glycome informatics database.
#
# == Usage
#
# Specify files containing KEGG GLYCAN data.
#
#  $ ruby demo_kegg_glycan.rb files...
#
# == Example of running this script
#
# Download test data.
#
#  $ ruby -Ilib bin/br_biofetch.rb glycan G00001 > G00001.glycan
#  $ ruby -Ilib bin/br_biofetch.rb glycan G00024 > G00024.glycan
#
# Run this script.
#
#  $ ruby -Ilib sample/demo_kegg_glycan.rb G00001.glycan G00024.glycan
#
# == Development information
#
# The code was moved from lib/bio/db/kegg/glycan.rb and modified.
#

require 'bio'

Bio::FlatFile.foreach(Bio::KEGG::GLYCAN, ARGF) do |gl|
  #entry = ARGF.read	# gl:G00024
  #gl = Bio::KEGG::GLYCAN.new(entry)

  puts "### gl = Bio::KEGG::GLYCAN.new(str)"
  puts "# gl.entry_id"
  p gl.entry_id
  puts "# gl.name"
  p gl.name
  puts "# gl.composition"
  p gl.composition
  puts "# gl.mass"
  p gl.mass
  puts "# gl.keggclass"
  p gl.keggclass
  #puts "# gl.bindings"
  #p gl.bindings
  puts "# gl.compounds"
  p gl.compounds
  puts "# gl.reactions"
  p gl.reactions
  puts "# gl.pathways"
  p gl.pathways
  puts "# gl.enzymes"
  p gl.enzymes
  puts "# gl.orthologs"
  p gl.orthologs
  puts "# gl.references"
  p gl.references
  puts "# gl.dblinks"
  p gl.dblinks
  puts "# gl.kcf"
  p gl.kcf

  puts "=" * 78
end
