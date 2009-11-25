#
# = sample/demo_kegg_genome.rb - demonstration of Bio::KEGG::GENOME
#
# Copyright::  Copyright (C) 2001, 2002, 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::KEGG::GENOME, a parser class for the KEGG/GENOME
# genome database.
#
# == Usage
#
# Specify files containing KEGG GENOME data.
#
#  $ ruby demo_kegg_genome.rb files...
#
# == Example of running this script
#
# Download test data.
#
#  $ ruby -Ilib bin/br_biofetch.rb genome eco > eco.genome
#  $ ruby -Ilib bin/br_biofetch.rb genome hsa > hsa.genome
#
# Run this script.
#
#  $ ruby -Ilib sample/demo_kegg_genome.rb eco.genome hsa.genome
#
# == Development information
#
# The code was moved from lib/bio/db/kegg/genome.rb and modified.
#

require 'bio'

#if __FILE__ == $0

  begin
    require 'pp'
    def p(arg); pp(arg); end
  rescue LoadError
  end

  #require 'bio/io/flatfile'

  ff = Bio::FlatFile.new(Bio::KEGG::GENOME, ARGF)

  ff.each do |genome|

    puts "### Tags"
    p genome.tags

    [
      %w( ENTRY entry_id ),
      %w( NAME name ),
      %w( DEFINITION definition ),
      %w( TAXONOMY taxonomy taxid lineage ),
      %w( REFERENCE references ),
      %w( CHROMOSOME chromosomes ),
      %w( PLASMID plasmids ),
      %w( STATISTICS statistics nalen num_gene num_rna ),
    ].each do |x|
      puts "### " + x.shift
      x.each do |m|
        p genome.__send__(m)
      end
    end

    puts "=" * 78
  end

#end

