#!/usr/bin/env ruby
#
# rev_comp.rb - Reverse complement DNA sequences
#
# Copyright::   Copyright (C) 2019 BioRuby Project
# License::     The Ruby License
#

require 'bio'

ARGV.each do |fn|
  Bio::FlatFile.open(fn) do |ff|
    ff.each do |entry|
      next if /\A\s*\z/ =~ ff.entry_raw.to_s
      na = entry.naseq
      revcomp = na.reverse_complement
      print revcomp.to_fasta("complement(#{entry.entry_id}) " + entry.definition, 70)
    end
  end
end
