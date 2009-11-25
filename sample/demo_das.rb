#
# = sample/demo_go.rb - demonstration of Bio::DAS, BioDAS access module
#
# Copyright::	Copyright (C) 2003, 2004, 2007
#		Shuichi Kawashima <shuichi@hgc.jp>,
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#
# == Description
#
# Demonstration of Bio::GO, BioDAS access module.
#
# == Requirements
#
# Internet connection is needed.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_das.rb
#
# == Notes
#
# Demo using the WormBase DAS server is temporarily disabled because
# it does not work well possibly because of the server trouble.
#
# == Development information
#
# The code was moved from lib/bio/io/das.rb and modified as below:
#
# * Demo codes using UCSC DAS server is added.
#

require 'bio'

# begin
#   require 'pp'
#   alias p pp
# rescue LoadError
# end

if false #disabled
  puts "### WormBase"
  wormbase = Bio::DAS.new('http://www.wormbase.org/db/')

  puts ">>> test get_dsn"
  p wormbase.get_dsn

  puts ">>> create segment obj Bio::DAS::SEGMENT.region('I', 1, 1000)"
  seg = Bio::DAS::SEGMENT.region('I', 1, 1000)
  p seg

  puts ">>> test get_dna"
  p wormbase.get_dna('elegans', seg)

  puts "### test get_features"
  p wormbase.get_features('elegans', seg)
end #if false #disabled

if true #enabled
  puts "### UCSC"
  ucsc = Bio::DAS.new('http://genome.ucsc.edu/cgi-bin/')

  puts ">>> test get_dsn"
  p ucsc.get_dsn

  puts ">>> test get_entry_points('hg19')"
  p ucsc.get_entry_points('hg19')

  puts ">>> test get_types('hg19')"
  p ucsc.get_types('hg19')

  len = rand(50) * 10 + 100
  pos = rand(243199373 - len)
  puts ">>> create segment obj Bio::DAS::SEGMENT.region('2', #{pos}, #{pos + len - 1})"
  seg2 = Bio::DAS::SEGMENT.region('2', pos, pos + len - 1)
  p seg2

  puts ">>> test get_dna"
  p ucsc.get_dna('hg19', seg2)

  puts "### test get_features"
  p ucsc.get_features('hg19', seg2)
end #if true #enabled

if true #enabled
  puts "### KEGG DAS"
  kegg_das = Bio::DAS.new("http://das.hgc.jp/cgi-bin/")

  dsn_list = kegg_das.get_dsn
  org_list = dsn_list.collect {|x| x.source}

  puts ">>> dsn : entry_points"
  org_list.each do |org|
    print "#{org} : "
    list = kegg_das.get_entry_points(org)
    list.segments.each do |seg|
      print " #{seg.entry_id}"
    end
    puts
  end
end #if true #enabled

