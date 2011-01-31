#
# = sample/demo_codontable.rb - demonstration of Bio::CodonTable
#
# Copyright::	Copyright (C) 2001, 2004
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#
# == Description
#
# Demonstration of Bio::CodonTable.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_codontable.rb
#
# == Development information
#
# The code was moved from lib/bio/data/codontable.rb.
#

require 'bio'


#if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  puts "### Bio::CodonTable[1]"
  p ct1 = Bio::CodonTable[1]

  puts ">>> Bio::CodonTable#table"
  p ct1.table

  puts ">>> Bio::CodonTable#each"
  ct1.each do |codon, aa|
    puts "#{codon} -- #{aa}"
  end

  puts ">>> Bio::CodonTable#definition"
  p ct1.definition

  puts ">>> Bio::CodonTable#['atg']"
  p ct1['atg']

  puts ">>> Bio::CodonTable#revtrans('A')"
  p ct1.revtrans('A')

  puts ">>> Bio::CodonTable#start_codon?('atg')"
  p ct1.start_codon?('atg')
  
  puts ">>> Bio::CodonTable#start_codon?('aaa')"
  p ct1.start_codon?('aaa')

  puts ">>> Bio::CodonTable#stop_codon?('tag')"
  p ct1.stop_codon?('tag')
  
  puts ">>> Bio::CodonTable#stop_codon?('aaa')"
  p ct1.stop_codon?('aaa')

  puts ">>> ct1_copy = Bio::CodonTable.copy(1)"
  p ct1_copy = Bio::CodonTable.copy(1)
  puts ">>> ct1_copy['tga'] = 'U'"
  p ct1_copy['tga'] = 'U'
  puts " orig : #{ct1['tga']}"
  puts " copy : #{ct1_copy['tga']}"


  puts "### ct = Bio::CodonTable.new(hash, definition)"
  hash = {
    'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
    'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
    'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'U',
    'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

    'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
    'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
    'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
    'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

    'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
    'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
    'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
    'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

    'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
    'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
    'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
    'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
  }
  my_ct = Bio::CodonTable.new(hash, "my codon table")

  puts ">>> ct.definition"
  puts my_ct.definition

  puts ">>> ct.definition=(str)"
  my_ct.definition = "selenoproteins (Eukaryote)"
  puts my_ct.definition

  puts ">>> ct['tga']"
  puts my_ct['tga']

  puts ">>> ct.revtrans('U')"
  puts my_ct.revtrans('U')

  puts ">>> ct.stop_codon?('tga')"
  puts my_ct.stop_codon?('tga')

  puts ">>> ct.stop_codon?('tag')"
  puts my_ct.stop_codon?('tag')

#end

