#
# = sample/demo_litdb.rb - demonstration of Bio::LITDB
#
# Copyright::  Copyright (C) 2001 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::LITDB, LITDB literature database parser class.
#
# == Requirements
#
# Internet connection and/or OBDA (Open Bio Database Access) configuration.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_litdb.rb
#
# == Development information
#
# The code was moved from lib/bio/db/litdb.rb.
#

require 'bio'

#if __FILE__ == $0

  entry = Bio::Fetch.query('litdb', '0308004') 
  puts entry
  p Bio::LITDB.new(entry).reference

  entry = Bio::Fetch.query('litdb', '0309094')
  puts entry
  p Bio::LITDB.new(entry).reference

  entry = Bio::Fetch.query('litdb', '0309093')
  puts entry
  p Bio::LITDB.new(entry).reference
#end
