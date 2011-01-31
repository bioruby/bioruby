#
# = sample/demo_kegg_compound.rb - demonstration of Bio::KEGG::COMPOUND
#
# Copyright::  Copyright (C) 2001, 2002, 2004, 2007 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::KEGG::COMPOUND, a parser class for the KEGG COMPOUND
# chemical structure database.
#
# == Usage
#
# Specify files containing KEGG COMPOUND data.
#
#  $ ruby demo_kegg_compound.rb files...
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_kegg_compound.rb test/data/KEGG/C00025.compound
#
# == Development information
#
# The code was moved from lib/bio/db/kegg/compound.rb and modified.
#

require 'bio'

Bio::FlatFile.foreach(Bio::KEGG::COMPOUND, ARGF) do |cpd|
  puts "### cpd = Bio::KEGG::COMPOUND.new(str)"
  puts "# cpd.entry_id"
  p cpd.entry_id
  puts "# cpd.names"
  p cpd.names
  puts "# cpd.name"
  p cpd.name
  puts "# cpd.formula"
  p cpd.formula
  puts "# cpd.mass"
  p cpd.mass
  puts "# cpd.reactions"
  p cpd.reactions
  puts "# cpd.rpairs"
  p cpd.rpairs
  puts "# cpd.pathways"
  p cpd.pathways
  puts "# cpd.enzymes"
  p cpd.enzymes
  puts "# cpd.dblinks"
  p cpd.dblinks
  puts "# cpd.kcf"
  p cpd.kcf
  puts "=" * 78
end

