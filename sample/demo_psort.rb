#
# = sample/demo_psort.rb - demonstration of Bio::PSORT, client for PSORT WWW server
#
# Copyright::   Copyright (C) 2003-2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
#
# == Description
#
# Demonstration of Bio::PSORT, client for PSORT (protein sorting site
# prediction systems) WWW server.
#
# == Requirements
#
# Internet connection is needed.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_psort.rb
#
# == Development information
#
# The code was moved from lib/bio/appl/psort.rb.
#

require 'bio'

#if __FILE__ == $0

  #begin
  #  require 'psort/report.rb'
  #rescue LoadError
  #end


  seq = ">hoge mit
MALEPIDYTT RDEDDLDENE LLMKISNAAG SSRVNDNNDD LTFVENDKII 
ARYSIQTSSK QQGKASTPPV EEAEEAAPQL PSRSSAAPPP PPRRATPEKK 
DVKDLKSKFE GLAASEKEEE EMENKFAPPP KKSEPTIISP KPFSKPQEPV
FKGYHVQVTA HSREIDAEYL KIVRGSDPDT TWLIISPNAK KEYEPESTGS 
KKSFTPSKSP APVSKKEPVK TPSPAPAAKI PKENPWATAE YDYDAAEDNE
NIEFVDDDWW LGELEKDGSK GLFPSNYVSL LPSRNVASGA PVQKEEPEQE 
SFHDFLQLFD ETKVQYGLAR RKAKQNSGNA ETKAEAPKPE VPEDEPEGEP
DDWNEPELKE RDFDQAPLKP NQSSYKPIGK IDLQKVIAEE KAKEDPRLVQ
DYKKIGNPLP GMHIEADNEE EPEENDDDWD DDEDEAAQPP ANFAAVANNL 
KPTAAGSKID DDKVIKGFRN EKSPAQLWAE VSPPGSDVEK IIIIGWCPDS 
APLKTRASFA PSSDIANLKN ESKLKRDSEF NSFLGTTKPP SMTESSLKND
KAEEAEQPKT EIAPSLPSRN SIPAPKQEEA PEQAPEEEIE GN
"
  Seq1 = ">hgoe
LTFVENDKII NI
"

  puts "\n Bio::PSORT::PSORT"
  
  puts "\n ==> p serv = Bio::PSORT::PSORT.imsut"
  p serv = Bio::PSORT::PSORT1.imsut

  puts "\n ==> p serv.class "  
  p serv.class

  puts "\n ==> p serv.title = 'Query_title_splited_by_white space'"
  p serv.title = 'Query_title_splited_by_white space'

  puts "\n ==> p serv.exec(seq, false) "  
  p serv.exec(seq, false)

  puts "\n ==> p serv.exec(seq) "  
  p serv.exec(seq)

  puts "\n ==> p report = serv.exec(Bio::FastaFormat.new(seq)) "  
  p report = serv.exec(Bio::FastaFormat.new(seq))

  puts "\n ==> p report.class"
  p report.class


  puts "\n ==> p report_raw = serv.exec(Bio::FastaFormat.new(seq), false) "  
  p report_raw = serv.exec(Bio::FastaFormat.new(seq), false)

  puts "\n ==> p report_raw.class"
  p report_raw.class


  puts "\n ==> p report.methods" 
  p report.methods

  methods = ['entry_id', 'origin', 'title', 'sequence','result_info',
             'reasoning', 'final_result', 'raw']
  methods.each do |method|
    puts "\n ==> p report.#{method}"
    p eval("report.#{method}")
  end



  puts "\n Bio::PSORT::PSORT2"

  puts "\n ==> p serv = Bio::PSORT::PSORT2.imsut"
  p serv = Bio::PSORT::PSORT2.imsut

  puts "\n ==> p serv.class "
  p serv.class

  puts "\n ==> p seq "
  p seq

  puts "\n ==> p serv.title = 'Query_title_splited_by_white space'"
  p serv.title = 'Query_title_splited_by_white space'

  puts "\n ==> p serv.exec(seq) # parsed report" 
  p serv.exec(seq)

  puts "\n ==> p report = serv.exec(Bio::FastaFormat.new(seq)) # parsed report" 
  p report = serv.exec(Bio::FastaFormat.new(seq))



  puts "\n ==> p serv.exec(seq, false) # report in plain text"
  p serv.exec(seq, false)

  puts "\n ==> p report_raw = serv.exec(Bio::FastaFormat.new(seq), false) # report in plain text"
  p report_raw = serv.exec(Bio::FastaFormat.new(seq), false)


  puts "\n ==> p report.methods"
  p report.methods

  methods = ['entry_id', 'scl', 'definition', 'seq', 'features', 'prob', 'pred', 'k', 'raw']
  methods.each do |method|
    puts "\n ==> p report.#{method}"
    p eval("report.#{method}")
  end

#end
