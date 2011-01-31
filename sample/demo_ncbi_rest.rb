#
# = sample/demo_ncbi_rest.rb - demonstration of Bio::NCBI::REST, NCBI E-Utilities client
#
# Copyright::  Copyright (C) 2008 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::NCBI::REST, NCBI E-Utilities client.
#
# == Requirements
#
# Internet connection is needed.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_ncbi_rest.rb
#
# == Development information
#
# The code was moved from lib/bio/io/ncbirest.rb.
#

require 'bio'

Bio::NCBI.default_email = 'staff@bioruby.org'

#if __FILE__ == $0

  gbopts = {"db"=>"nuccore", "rettype"=>"gb"}
  pmopts = {"db"=>"pubmed", "rettype"=>"medline"}
  count = {"rettype" => "count"}
  xml = {"retmode"=>"xml"}
  max = {"retmax"=>5}

  puts "=== class methods ==="

  puts "--- Search NCBI by E-Utils ---"

  puts Time.now
  puts "# count of 'tardigrada' in nuccore"
  puts Bio::NCBI::REST.esearch("tardigrada", gbopts.merge(count))

  puts Time.now
  puts "# max 5 'tardigrada' entries in nuccore"
  puts Bio::NCBI::REST.esearch("tardigrada", gbopts.merge(max))

  puts Time.now
  puts "# count of 'yeast kinase' in nuccore"
  puts Bio::NCBI::REST.esearch("yeast kinase", gbopts.merge(count))

  puts Time.now
  puts "# max 5 'yeast kinase' entries in nuccore (XML)"
  puts Bio::NCBI::REST.esearch("yeast kinase", gbopts.merge(xml).merge(max))

  puts Time.now
  puts "# count of 'genome&analysis|bioinformatics' in pubmed"
  puts Bio::NCBI::REST.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(count))

  puts Time.now
  puts "# max 5 'genome&analysis|bioinformatics' entries in pubmed (XML)"
  puts Bio::NCBI::REST.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(xml).merge(max))

  puts Time.now
  Bio::NCBI::REST.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(max)).each do |x|
    puts "# each of 5 'genome&analysis|bioinformatics' entries in pubmed"
    puts x
  end

  puts "--- Retrieve NCBI entry by E-Utils ---"

  puts Time.now
  puts "# '185041' entry in nuccore"
  puts Bio::NCBI::REST.efetch("185041", gbopts)

  puts Time.now
  puts "# 'J00231' entry in nuccore (XML)"
  puts Bio::NCBI::REST.efetch("J00231", gbopts.merge(xml))

  puts Time.now
  puts "# 16381885 entry in pubmed"
  puts Bio::NCBI::REST.efetch(16381885, pmopts)

  puts Time.now
  puts "# '16381885' entry in pubmed"
  puts Bio::NCBI::REST.efetch("16381885", pmopts)

  puts Time.now
  puts "# [10592173,14693808] entries in pubmed"
  puts Bio::NCBI::REST.efetch([10592173, 14693808], pmopts)

  puts Time.now
  puts "# [10592173,14693808] entries in pubmed (XML)"
  puts Bio::NCBI::REST.efetch([10592173, 14693808], pmopts.merge(xml))


  puts "=== instance methods ==="

  ncbi = Bio::NCBI::REST.new

  puts "--- Search NCBI by E-Utils ---"

  puts Time.now
  puts "# count of 'genome&analysis|bioinformatics' in pubmed"
  puts ncbi.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(count))

  puts Time.now
  puts "# max 5 'genome&analysis|bioinformatics' entries in pubmed"
  puts ncbi.esearch("(genome AND analysis) OR bioinformatics", pmopts.merge(max))

  puts Time.now
  ncbi.esearch("(genome AND analysis) OR bioinformatics", pmopts).each do |x|
    puts "# each 'genome&analysis|bioinformatics' entries in pubmed"
    puts x
  end

  puts "--- Retrieve NCBI entry by E-Utils ---"

  puts Time.now
  puts "# 16381885 entry in pubmed"
  puts ncbi.efetch(16381885, pmopts)

  puts Time.now
  puts "# [10592173,14693808] entries in pubmed"
  puts ncbi.efetch([10592173, 14693808], pmopts)

#end
