#
# = sample/demo_pubmed.rb - demonstration of Bio::PubMed
#
# Copyright::  Copyright (C) 2001, 2007, 2008 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::PubMed, NCBI Entrez/PubMed client module.
#
# == Requirements
#
# Internet connection is needed.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_pubmed.rb
#
# == Development information
#
# The code was moved from lib/bio/io/pubmed.rb and modified as below:
# * Codes using Entrez CGI are disabled.

require 'bio'

Bio::NCBI.default_email = 'staff@bioruby.org'

#if __FILE__ == $0

  puts "=== instance methods ==="

  pubmed = Bio::PubMed.new

  puts "--- Search PubMed by E-Utils ---"
  opts = {"rettype" => "count"}
  puts Time.now
  puts pubmed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  puts pubmed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  puts pubmed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  pubmed.esearch("(genome AND analysis) OR bioinformatics").each do |x|
    puts x
  end

  puts "--- Retrieve PubMed entry by E-Utils ---"
  puts Time.now
  puts pubmed.efetch(16381885)
  puts Time.now
  puts pubmed.efetch("16381885")
  puts Time.now
  puts pubmed.efetch("16381885")
  puts Time.now
  opts = {"retmode" => "xml"}
  puts pubmed.efetch([10592173, 14693808], opts)
  puts Time.now
  puts pubmed.efetch(["10592173", "14693808"], opts)

  #puts "--- Search PubMed by Entrez CGI ---"
  #pubmed.search("(genome AND analysis) OR bioinformatics").each do |x|
  #  p x
  #end

  #puts "--- Retrieve PubMed entry by Entrez CGI ---"
  #puts pubmed.query("16381885")


  puts "--- Retrieve PubMed entry by PMfetch ---"
  puts pubmed.pmfetch("16381885")


  puts "=== class methods ==="


  puts "--- Search PubMed by E-Utils ---"
  opts = {"rettype" => "count"}
  puts Time.now
  puts Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  puts Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  puts Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics", opts)
  puts Time.now
  Bio::PubMed.esearch("(genome AND analysis) OR bioinformatics").each do |x|
    puts x
  end

  puts "--- Retrieve PubMed entry by E-Utils ---"
  puts Time.now
  puts Bio::PubMed.efetch(16381885)
  puts Time.now
  puts Bio::PubMed.efetch("16381885")
  puts Time.now
  puts Bio::PubMed.efetch("16381885")
  puts Time.now
  opts = {"retmode" => "xml"}
  puts Bio::PubMed.efetch([10592173, 14693808], opts)
  puts Time.now
  puts Bio::PubMed.efetch(["10592173", "14693808"], opts)

  #puts "--- Search PubMed by Entrez CGI ---"
  #Bio::PubMed.search("(genome AND analysis) OR bioinformatics").each do |x|
  #  p x
  #end

  #puts "--- Retrieve PubMed entry by Entrez CGI ---"
  #puts Bio::PubMed.query("16381885")


  puts "--- Retrieve PubMed entry by PMfetch ---"
  puts Bio::PubMed.pmfetch("16381885")

#end
