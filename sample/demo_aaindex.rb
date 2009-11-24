#
# = sample/demo_aaindex.rb - demonstration of Bio::AAindex1 and AAindex2
#
# Copyright::  Copyright (C) 2001 
#              KAWASHIMA Shuichi <s@bioruby.org>
# Copyright::  Copyright (C) 2006
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::AAindex1 and Bio::AAindex2.
#
# == Requirements
#
# Internet connection and/or OBDA (Open Bio Database Access) configuration.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_aaindex.rb
#
# == Development information
#
# The code was moved from lib/bio/db/aaindex.rb.
#

require 'bio'

#if __FILE__ == $0

  puts "### AAindex1 (PRAM900102)"
  aax1 = Bio::AAindex1.new(Bio::Fetch.query('aaindex', 'PRAM900102', 'raw'))
  p aax1.entry_id
  p aax1.definition
  p aax1.dblinks
  p aax1.author
  p aax1.title
  p aax1.journal
  p aax1.comment
  p aax1.correlation_coefficient
  p aax1.index
  p aax1
  puts "### AAindex2 (DAYM780301)"
  aax2 = Bio::AAindex2.new(Bio::Fetch.query('aaindex', 'DAYM780301', 'raw'))
  p aax2.entry_id
  p aax2.definition
  p aax2.dblinks
  p aax2.author
  p aax2.title
  p aax2.journal
  p aax1.comment
  p aax2.rows
  p aax2.cols
  p aax2.matrix
  p aax2.matrix[2,2]
  p aax2.matrix[2,3]
  p aax2.matrix[4,3]
  p aax2.matrix.determinant
  p aax2.matrix.rank
  p aax2.matrix.transpose
  p aax2

#end

