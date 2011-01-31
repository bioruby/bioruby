#
# = sample/demo_genbank.rb - demonstration of Bio::GenBank
#
# Copyright::  Copyright (C) 2000-2005 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::GenBank, the parser class for the GenBank entry.
#
# == Usage
#
# Usage 1: Without arguments, showing demo with a GenBank entry.
# Internet connection is needed.
#
#  $ ruby demo_genbank.rb
#
# Usage 2: IDs or accession numbers are given as the arguments.
# Internet connection is needed.
#
#  $ ruby demo_genbank.rb X94434 NM_000669
#
# Usage 3: When the first argument is "--files", "-files", "--file", or
# "-file", filenames are given as the arguments.
#
#  $ ruby demo_genbank.rb --files file1.gbk file2.gbk ...
#
# == Development information
#
# The code was moved from lib/bio/db/genbank/genbank.rb, and modified
# as below:
# * To get sequences from the NCBI web service.
# * By default, arguments are sequence IDs (accession numbers).
# * New option "--files" (or "-files", "--file", or "-file") to
#   read sequences from file(s).
# 

require 'bio'

begin
  require 'pp'
  alias p pp
rescue LoadError
end

def demo_genbank(gb)

  puts "### GenBank"
  puts "## LOCUS"
  puts "# GenBank.locus"
  p gb.locus
  puts "# GenBank.entry_id"
  p gb.entry_id
  puts "# GenBank.nalen"
  p gb.nalen
  puts "# GenBank.strand"
  p gb.strand
  puts "# GenBank.natype"
  p gb.natype
  puts "# GenBank.circular"
  p gb.circular
  puts "# GenBank.division"
  p gb.division
  puts "# GenBank.date"
  p gb.date

  puts "## DEFINITION"
  p gb.definition

  puts "## ACCESSION"
  p gb.accession

  puts "## VERSION"
  p gb.versions
  p gb.version
  p gb.gi

  puts "## NID"
  p gb.nid

  puts "## KEYWORDS"
  p gb.keywords

  puts "## SEGMENT"
  p gb.segment

  puts "## SOURCE"
  p gb.source
  p gb.common_name
  p gb.vernacular_name
  p gb.organism
  p gb.taxonomy

  puts "## REFERENCE"
  p gb.references

  puts "## COMMENT"
  p gb.comment

  puts "## FEATURES"
  p gb.features

  puts "## BASE COUNT"
  p gb.basecount
  p gb.basecount('a')
  p gb.basecount('A')

  puts "## ORIGIN"
  p gb.origin
  p gb.naseq

  puts "=" * 78
end

case ARGV[0]
when '-file', '--file', '-files', '--files'
  ARGV.shift
  ARGV.each do |filename|
    Bio::FlatFile.foreach(filename) do |gb|
      demo_genbank(gb)
    end
  end
else
  efetch = Bio::NCBI::REST::EFetch.new
  argv = ARGV.empty? ? [ 'X94434' ] : ARGV
  argv.each do |id_or_accession|
    raw = efetch.sequence(id_or_accession)
    gb = Bio::GenBank.new(raw)
    demo_genbank(gb)
  end
end
