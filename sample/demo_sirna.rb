#
# = sample/demo_sirna.rb - demonstration of Bio::SiRNA
#
# Copyright::   Copyright (C) 2004, 2005
#               Itoshi NIKAIDO <dritoshi@gmail.com>
# License::     The Ruby License
#
#
# == Description
#
# Demonstration of Bio::SiRNA, class for designing small inhibitory RNAs.
#
# == Usage
#
# Specify files containing nucleotide sequences.
#
#  $ ruby demo_sirna.rb files...
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_sirna.rb test/data/fasta/example1.txt
#
# == Development information
#
# The code was moved from lib/bio/util/sirna.rb, and modified for reading
# normal sequence files.
#

require 'bio'

if ARGV.size <= 0 then
  puts "Demonstration of designing SiRNA for each sequence."
  puts "Usage: #{$0} files..."
  exit(0)
end

ARGV.each do |filename|
Bio::FlatFile.foreach(filename) do |entry|
  puts "##entry.entry_id: #{entry.entry_id}"
  puts "##entry.definition: #{entry.definition}"
  seq = entry.naseq
  puts "##entry.naseq.length: #{seq.length}"

  sirna = Bio::SiRNA.new(seq)
  pairs = sirna.design # or .design('uitei') or .uitei or .reynolds

  pairs.each do |pair|
    puts pair.report

    shrna = Bio::SiRNA::ShRNA.new(pair)
    shrna.design # or .design('BLOCK-iT') or .block_it
    puts shrna.report

    puts "# as DNA"
    puts shrna.top_strand.dna
    puts shrna.bottom_strand.dna
  end

  puts "=" * 78

end #Bio::FlatFile.foreach
end #ARGV.each

