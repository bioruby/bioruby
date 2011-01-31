#
# = sample/demo_prosite.rb - demonstration of Bio::PROSITE
#
# Copyright::  Copyright (C) 2001 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::PROSITE, parser class for PROSITE database entry.
#
# == Usage
#
# Specify files containing PROSITE data.
#
#  $ ruby demo_prosite.rb files...
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_prosite.rb test/data/prosite/prosite.dat
#
# == Development information
#
# The code was moved from lib/bio/db/prosite.rb.
#

require 'bio'

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

Bio::FlatFile.foreach(Bio::PROSITE, ARGF) do |ps|
  puts "### ps = Bio::PROSITE.new(str)"

  list = %w(
    name
    division
    ac
    entry_id
    dt
    date
    de
    definition
    pa
    pattern
    ma
    profile
    ru
    rule
    nr
    statistics
    release
    swissprot_release_number
    swissprot_release_sequences
    total
    total_hits
    total_sequences
    positive
    positive_hits
    positive_sequences
    unknown
    unknown_hits
    unknown_sequences
    false_pos
    false_positive_hits
    false_positive_sequences
    false_neg
    false_negative_hits
    partial
    cc
    comment
    max_repeat
    site
    skip_flag
    dr
    sp_xref
    pdb_xref
    pdoc_xref
  )

  list.each do |method|
    puts ">>> #{method}"
    p ps.__send__(method)
  end

  puts ">>> taxon_range"
  p ps.taxon_range
  puts ">>> taxon_range(expand)"
  p ps.taxon_range(true)

  puts ">>> list_truepositive"
  p ps.list_truepositive
  puts ">>> list_truepositive(by_name)"
  p ps.list_truepositive(true)

  puts ">>> list_falsenegative"
  p ps.list_falsenegative
  puts ">>> list_falsenegative(by_name)"
  p ps.list_falsenegative(true)

  puts ">>> list_falsepositive"
  p ps.list_falsepositive
  puts ">>> list_falsepositive(by_name)"
  p ps.list_falsepositive(true)

  puts ">>> list_potentialhit"
  p ps.list_potentialhit
  puts ">>> list_potentialhit(by_name)"
  p ps.list_potentialhit(true)

  puts ">>> list_unknown"
  p ps.list_unknown
  puts ">>> list_unknown(by_name)"
  p ps.list_unknown(true)

  puts "=" * 78
end
