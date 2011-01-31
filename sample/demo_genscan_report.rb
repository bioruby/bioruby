#
# = sample/demo_genscan_report.rb - demonstration of Bio::Genscan::Report
#
# Copyright::  Copyright (C) 2003 
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::Genscan::Report, parser class for Genscan output.
#
# == Usage
#
# Usage 1: Without arguments, demonstrates using preset sample data.
#
#  $ ruby demo_genscan.rb
#
# Usage 2: When a "-" is specified as the argument, read data from stdin.
#
#  $ cat testdata | ruby demo_genscan.rb -
#
# Usage 3: Specify a file containing a Genscan output.
#
#  $ ruby demo_genscan.rb file
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_genscan.rb test/data/genscan/sample.report
#
# == Development information
#
# The code was moved from lib/bio/appl/genscan/report.rb and modified:
# * Changed the way to read preset sample data.
#

require 'bio'

#if __FILE__ == $0

  if ARGV.empty? then
    report = DATA.read
  elsif ARGV.size == 1 and ARGV[0] == '-' then
    ARGV.shift
    report = $<.read
  else
    report = ARGF.read
  end

  puts "= class Bio::Genscan::Report "
  report = Bio::Genscan::Report.new(report)


  print " report.genscan_version #=> "
  p report.genscan_version
  print " report.date_run #=> "
  p report.date_run
  print " report.time #=> "
  p report.time

  print " report.query_name #=> "
  p report.query_name
  print " report.length #=> "
  p report.length
  print " report.gccontent #=> "
  p report.gccontent
  print " report.isochore #=> "
  p report.isochore

  print " report.matrix #=> " 
  p report.matrix

  puts " report.predictions (Array of Bio::Genscan::Report::Gene)  " 
  print " report.predictions.size #=> "
  p report.predictions.size


  report.predictions.each {|gene|
    puts "\n== class Bio::Genscan::Report::Gene "
    print " gene.number #=> " 
    p gene.number
    print " gene.aaseq (Bio::FastaFormat) #=> " 
    p gene.aaseq
    print " gene.naseq (Bio::FastaFormat) #=> " 
    p gene.naseq
    print " ene.promoter (Bio::Genscan::Report::Exon) #=> " 
    p gene.promoter
    print " gene.polyA (Bio::Genscan::Report::Exon) #=> " 
    p gene.polyA
    puts " gene.exons (Array of Bio::Genscan::Report::Exon) " 
    print " gene.exons.size #=> " 
    p gene.exons.size


    gene.exons.each {|exon|
      puts "\n== class Bio::Genscan::Report::Exon "
      print " exon.number #=> "
      p exon.number
      print " exon.exon_type #=> "
      p exon.exon_type
      print " exon.exon_type_long #=> "
      p exon.exon_type_long
      print " exon.strand #=> "
      p exon.strand
      print " exon.first #=> "
      p exon.first
      print " exon.last #=> "
      p exon.last
      print " exon.range (Range) #=> "
      p exon.range
      print " exon.frame #=> "
      p exon.frame
      print " exon.phase #=> "
      p exon.phase
      print " exon.acceptor_score #=> "
      p exon.acceptor_score
      print " exon.donor_score #=> "
      p exon.donor_score
      print " exon.initiation_score #=> "
      p exon.initiation_score
      print " exon.termination_score #=> "
      p exon.termination_score
      print " exon.score #=> "
      p exon.score
      print " exon.p_value #=> "
      p exon.p_value
      print " exon.t_score #=> "
      p exon.t_score
      puts
    }
    puts
  }

#end

### Sample Genscan report is attached below.
### The lines after the "__END__" can be accessed by using "DATA".

__END__
GENSCAN 1.0	Date run: 30-May-103	Time: 14:06:28

Sequence HUMRASH : 12942 bp : 68.17% C+G : Isochore 4 (57 - 100 C+G%)

Parameter matrix: HumanIso.smat

Predicted genes/exons:

Gn.Ex Type S .Begin ...End .Len Fr Ph I/Ac Do/T CodRg P.... Tscr..
----- ---- - ------ ------ ---- -- -- ---- ---- ----- ----- ------

 1.01 Init +   1664   1774  111  1  0   94   83   212 0.997  21.33
 1.02 Intr +   2042   2220  179  1  2  104   66   408 0.997  40.12
 1.03 Intr +   2374   2533  160  1  1   89   94   302 0.999  32.08
 1.04 Term +   3231   3350  120  2  0  115   48   202 0.980  18.31
 1.05 PlyA +   3722   3727    6                              -5.80

 2.00 Prom +   6469   6508   40                              -7.92
 2.01 Init +   8153   8263  111  1  0   94   83   212 0.998  21.33
 2.02 Intr +   8531   8709  179  1  2  104   66   408 0.997  40.12
 2.03 Intr +   8863   9022  160  1  1   89   94   302 0.999  32.08
 2.04 Term +   9720   9839  120  2  0  115   48   202 0.961  18.31

Predicted peptide sequence(s):

Predicted coding sequence(s):


>HUMRASH|GENSCAN_predicted_peptide_1|189_aa
MTEYKLVVVGAGGVGKSALTIQLIQNHFVDEYDPTIEDSYRKQVVIDGETCLLDILDTAG
QEEYSAMRDQYMRTGEGFLCVFAINNTKSFEDIHQYREQIKRVKDSDDVPMVLVGNKCDL
AARTVESRQAQDLARSYGIPYIETSAKTRQGVEDAFYTLVREIRQHKLRKLNPPDESGPG
CMSCKCVLS

>HUMRASH|GENSCAN_predicted_CDS_1|570_bp
atgacggaatataagctggtggtggtgggcgccggcggtgtgggcaagagtgcgctgacc
atccagctgatccagaaccattttgtggacgaatacgaccccactatagaggattcctac
cggaagcaggtggtcattgatggggagacgtgcctgttggacatcctggataccgccggc
caggaggagtacagcgccatgcgggaccagtacatgcgcaccggggagggcttcctgtgt
gtgtttgccatcaacaacaccaagtcttttgaggacatccaccagtacagggagcagatc
aaacgggtgaaggactcggatgacgtgcccatggtgctggtggggaacaagtgtgacctg
gctgcacgcactgtggaatctcggcaggctcaggacctcgcccgaagctacggcatcccc
tacatcgagacctcggccaagacccggcagggagtggaggatgccttctacacgttggtg
cgtgagatccggcagcacaagctgcggaagctgaaccctcctgatgagagtggccccggc
tgcatgagctgcaagtgtgtgctctcctga

>HUMRASH|GENSCAN_predicted_peptide_2|189_aa
MTEYKLVVVGAGGVGKSALTIQLIQNHFVDEYDPTIEDSYRKQVVIDGETCLLDILDTAG
QEEYSAMRDQYMRTGEGFLCVFAINNTKSFEDIHQYREQIKRVKDSDDVPMVLVGNKCDL
AARTVESRQAQDLARSYGIPYIETSAKTRQGVEDAFYTLVREIRQHKLRKLNPPDESGPG
CMSCKCVLS

>HUMRASH|GENSCAN_predicted_CDS_2|570_bp
atgacggaatataagctggtggtggtgggcgccggcggtgtgggcaagagtgcgctgacc
atccagctgatccagaaccattttgtggacgaatacgaccccactatagaggattcctac
cggaagcaggtggtcattgatggggagacgtgcctgttggacatcctggataccgccggc
caggaggagtacagcgccatgcgggaccagtacatgcgcaccggggagggcttcctgtgt
gtgtttgccatcaacaacaccaagtcttttgaggacatccaccagtacagggagcagatc
aaacgggtgaaggactcggatgacgtgcccatggtgctggtggggaacaagtgtgacctg
gctgcacgcactgtggaatctcggcaggctcaggacctcgcccgaagctacggcatcccc
tacatcgagacctcggccaagacccggcagggagtggaggatgccttctacacgttggtg
cgtgagatccggcagcacaagctgcggaagctgaaccctcctgatgagagtggccccggc
tgcatgagctgcaagtgtgtgctctcctga
