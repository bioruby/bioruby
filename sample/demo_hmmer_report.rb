#
# = sample/demo_hmmer_report.rb - demonstration of Bio::HMMER::Report
#
# Copyright::   Copyright (C) 2002 
#               Hiroshi Suga <suga@biophys.kyoto-u.ac.jp>,
# Copyright::   Copyright (C) 2005 
#               Masashi Fujita <fujita@kuicr.kyoto-u.ac.jp>
# License::     The Ruby License
#
#
# == Description
#
# Demonstration of Bio::HMMER::Report (HMMER output parser).
#
# Note that it (and Bio::HMMER::Report) supports HMMER 2.x.
# HMMER 3.x is currently not supported.
#
# == Usage
#
# Specify a file containing a HMMER result.
#
#  $ ruby demo_hmmer_report.rb file
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_hmmer_report.rb test/data/HMMER/hmmsearch.out
#  $ ruby -Ilib sample/demo_blast_report.rb test/data/HMMER/hmmpfam.out
#
# == Development information
#
# The code was moved from lib/bio/appl/hmmer/report.rb.
#

require 'bio'

#if __FILE__ == $0

=begin

  #
  # for multiple reports in a single output file (hmmpfam)
  #
  Bio::HMMER.reports(ARGF.read) do |report|
    report.hits.each do |hit|
      hit.hsps.each do |hsp|
      end
    end
  end

=end

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  rep = Bio::HMMER::Report.new(ARGF.read)
  p rep

  indent = 18

  puts "### hmmer result"
  print "name : ".rjust(indent)
  p  rep.program['name']
  print "version : ".rjust(indent)
  p rep.program['version']
  print "copyright : ".rjust(indent)
  p rep.program['copyright']
  print "license : ".rjust(indent)
  p rep.program['license']

  print "HMM file : ".rjust(indent)
  p rep.parameter['HMM file']
  print "Sequence file : ".rjust(indent)
  p rep.parameter['Sequence file']

  print "Query sequence : ".rjust(indent)
  p rep.query_info['Query sequence']
  print "Accession : ".rjust(indent)
  p rep.query_info['Accession']
  print "Description : ".rjust(indent)
  p rep.query_info['Description']

  rep.each do |hit|
    puts "## each hit"
    print "accession : ".rjust(indent)
    p [ hit.accession, hit.target_id, hit.hit_id, hit.entry_id ]
    print "description : ".rjust(indent)
    p [ hit.description, hit.definition ]
    print "target_def : ".rjust(indent)
    p hit.target_def
    print "score : ".rjust(indent)
    p [ hit.score, hit.bit_score ]
    print "evalue : ".rjust(indent)
    p hit.evalue
    print "num : ".rjust(indent)
    p hit.num

    hit.each do |hsp|
      puts "## each hsp"
      print "accession : ".rjust(indent)
      p [ hsp.accession, hsp.target_id ]
      print "domain : ".rjust(indent)
      p hsp.domain
      print "seq_f : ".rjust(indent)
      p hsp.seq_f
      print "seq_t : ".rjust(indent)
      p hsp.seq_t
      print "seq_ft : ".rjust(indent)
      p hsp.seq_ft
      print "hmm_f : ".rjust(indent)
      p hsp.hmm_f
      print "hmm_t : ".rjust(indent)
      p hsp.hmm_t
      print "hmm_ft : ".rjust(indent)
      p hsp.hmm_ft
      print "score : ".rjust(indent)
      p [ hsp.score, hsp.bit_score ]
      print "evalue : ".rjust(indent)
      p hsp.evalue
      print "midline : ".rjust(indent)
      p hsp.midline
      print "hmmseq : ".rjust(indent)
      p hsp.hmmseq
      print "flatseq : ".rjust(indent)
      p hsp.flatseq
      print "query_frame : ".rjust(indent)
      p hsp.query_frame
      print "target_frame : ".rjust(indent)
      p hsp.target_frame

      print "query_seq : ".rjust(indent)
      p hsp.query_seq		# hmmseq, flatseq
      print "target_seq : ".rjust(indent)
      p hsp.target_seq		# flatseq, hmmseq
      print "target_from : ".rjust(indent)
      p hsp.target_from		# seq_f, hmm_f
      print "target_to : ".rjust(indent)
      p hsp.target_to		# seq_t, hmm_t
      print "query_from : ".rjust(indent)
      p hsp.query_from		# hmm_f, seq_f
      print "query_to : ".rjust(indent)
      p hsp.query_to		# hmm_t, seq_t
    end 
  end

#end 

