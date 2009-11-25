#
# = sample/demo_kegg_drug.rb - demonstration of Bio::KEGG::DRUG
#
# Copyright::  Copyright (C) 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::KEGG::DRUG, a parser class for the KEGG DRUG
# drug database entry.
#
# == Usage
#
# Specify files containing KEGG DRUG data.
#
#  $ ruby demo_kegg_drug.rb files...
#
# == Example of running this script
#
# Download test data.
#
#  $ ruby -Ilib bin/br_biofetch.rb dr D00001 > D00001.drug
#  $ ruby -Ilib bin/br_biofetch.rb dr D00002 > D00002.drug
#
# Run this script.
#
#  $ ruby -Ilib sample/demo_kegg_drug.rb D00001.drug D00002.drug
#
# == Development information
#
# The code was moved from lib/bio/db/kegg/drug.rb and modified.
#

require 'bio'

Bio::FlatFile.foreach(Bio::KEGG::DRUG, ARGF) do |dr|
  #entry = ARGF.read	# dr:D00001
  #dr = Bio::KEGG::DRUG.new(entry)

  puts "### dr = Bio::KEGG::DRUG.new(str)"
  puts "# dr.entry_id"
  p dr.entry_id
  puts "# dr.names"
  p dr.names
  puts "# dr.name"
  p dr.name
  puts "# dr.formula"
  p dr.formula
  puts "# dr.mass"
  p dr.mass
  puts "# dr.activity"
  p dr.activity
  puts "# dr.remark"
  p dr.remark
  puts "# dr.comment"
  p dr.comment
  puts "# dr.dblinks"
  p dr.dblinks
  puts "# dr.kcf"
  p dr.kcf

  puts "=" * 78
end

