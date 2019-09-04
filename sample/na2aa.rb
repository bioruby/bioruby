#!/usr/bin/env ruby
#
# na2aa.rb - translate any NA input into AA FASTA format
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
      aa = na.translate
      print aa.to_fasta(entry.definition, 70)
    end
  end
end
