#
# = sample/demo_fastaformat.rb - demonstration of the FASTA format parser
#
# Copyright::  Copyright (C) 2001, 2002
#              Naohisa Goto <ng@bioruby.org>,
#              Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#
# == Description
#
# Demonstration of FASTA format parser.
#
# == Usage
#
# Simply run the script.
#
#  $ ruby demo_fastaformat.rb
#
# == Development information
#
# The code was moved from lib/bio/db/fasta.rb.
#

require 'bio'

  f_str = <<END
>sce:YBR160W  CDC28, SRM5; cyclin-dependent protein kinase catalytic subunit [EC:2.7.1.-] [SP:CC28_YEAST]
MSGELANYKRLEKVGEGTYGVVYKALDLRPGQGQRVVALKKIRLESEDEG
VPSTAIREISLLKELKDDNIVRLYDIVHSDAHKLYLVFEFLDLDLKRYME
GIPKDQPLGADIVKKFMMQLCKGIAYCHSHRILHRDLKPQNLLINKDGNL
KLGDFGLARAFGVPLRAYTHEIVTLWYRAPEVLLGGKQYSTGVDTWSIGC
IFAEMCNRKPIFSGDSEIDQIFKIFRVLGTPNEAIWPDIVYLPDFKPSFP
QWRRKDLSQVVPSLDPRGIDLLDKLLAYDPINRISARRAAIHPYFQES
>sce:YBR274W  CHK1; probable serine/threonine-protein kinase [EC:2.7.1.-] [SP:KB9S_YEAST]
MSLSQVSPLPHIKDVVLGDTVGQGAFACVKNAHLQMDPSIILAVKFIHVP
TCKKMGLSDKDITKEVVLQSKCSKHPNVLRLIDCNVSKEYMWIILEMADG
GDLFDKIEPDVGVDSDVAQFYFQQLVSAINYLHVECGVAHRDIKPENILL
DKNGNLKLADFGLASQFRRKDGTLRVSMDQRGSPPYMAPEVLYSEEGYYA
DRTDIWSIGILLFVLLTGQTPWELPSLENEDFVFFIENDGNLNWGPWSKI
EFTHLNLLRKILQPDPNKRVTLKALKLHPWVLRRASFSGDDGLCNDPELL
AKKLFSHLKVSLSNENYLKFTQDTNSNNRYISTQPIGNELAELEHDSMHF
QTVSNTQRAFTSYDSNTNYNSGTGMTQEAKWTQFISYDIAALQFHSDEND
CNELVKRHLQFNPNKLTKFYTLQPMDVLLPILEKALNLSQIRVKPDLFAN
FERLCELLGYDNVFPLIINIKTKSNGGYQLCGSISIIKIEEELKSVGFER
KTGDPLEWRRLFKKISTICRDIILIPN
END

  f = Bio::FastaFormat.new(f_str)
  puts "### FastaFormat"
  puts "# entry"
  puts f.entry
  puts "# entry_id"
  p f.entry_id
  puts "# definition"
  p f.definition
  puts "# data"
  p f.data
  puts "# seq"
  p f.seq
  puts "# seq.type"
  p f.seq.type
  puts "# length"
  p f.length
  puts "# aaseq"
  p f.aaseq
  puts "# aaseq.type"
  p f.aaseq.type
  puts "# aaseq.composition"
  p f.aaseq.composition
  puts "# aalen"
  p f.aalen

  puts

  n_str = <<END
>CRA3575282.F 
24 15 23 29 20 13 20 21 21 23 22 25 13 22 17 15 25 27 32 26  
32 29 29 25
END

  n = Bio::FastaNumericFormat.new(n_str)
  puts "### FastaNumericFormat"
  puts "# entry"
  puts n.entry
  puts "# entry_id"
  p n.entry_id
  puts "# definition"
  p n.definition
  puts "# data"
  p n.data
  puts "# length"
  p n.length
  #puts "# percent to ratio by yield"
  #n.each do |x|
  #  p x/100.0
  #end
  puts "# first three"
  p n[0]
  p n[1]
  p n[2]
  puts "# last one"
  p n[-1]

