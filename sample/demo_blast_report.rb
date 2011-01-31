#
# = sample/demo_blast_report.rb - demonstration of Bio::Blast::Report, Bio::Blast::Default::Report, and Bio::Blast::WU::Report
# 
# Copyright::  Copyright (C) 2003 Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2003-2006,2008-2009 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#
# == Description
#
# Demonstration of Bio::Blast::Report (NCBI BLAST XML format parser),
# Bio::Blast::Default::Report (NCBI BLAST default (-m 0) format parser),
# and Bio::Blast::WU::Report (WU-BLAST default format parser).
#
# == Usage
#
# Specify files containing BLAST results.
#
#  $ ruby demo_blast_report.rb files...
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_blast_report.rb test/data/blast/b0002.faa.m7
#  $ ruby -Ilib sample/demo_blast_report.rb test/data/blast/b0002.faa.m0
#
# == Development information
#
# The code was moved from lib/bio/appl/blast/report.rb,
# lib/bio/appl/blast/format0.rb, and lib/bio/appl/blast/wublast.rb,
# and modified.
#

require 'bio'

# dummpy class to return specific object
class Dummy
  def initialize(obj)
    @obj = obj
  end
  def size
    @obj
  end
  def inspect
    @obj.inspect
  end
end #class Dummy

# wrapper class to ignore error
class Wrapper
  def initialize(obj)
    @obj = obj
  end
  def class
    @obj.class
  end
  def respond_to?(*arg)
    @obj.respond_to?(*arg)
  end
  def method_missing(meth, *arg, &block)
    begin
      @obj.__send__(meth, *arg, &block)
    rescue NoMethodError => evar
      Dummy.new(evar)
    end
  end
end #class Wrapper

def wrap(obj)
  Wrapper.new(obj)
end

# -m0: not defined in Bio::Blast::Default::Report ???
# +m0: newly added in Bio::Blast::Default::Report ???
# -WU: not defined in Bio::Blast::WU::Report ???
# +WU: newly added in Bio::Blast::WU::Report ???

Bio::FlatFile.open(ARGF) do |ff|
  puts "Detected file format: #{ff.dbclass}"
  unless ff.dbclass then
    ff.dbclass = Bio::Blast::Report
    puts "Input data may be tab-delimited format (-m 8)."
  end
  ff.each do |rep|
  rep = wrap(rep)

  #print "# === Bio::Blast::Default::Report\n"
  print "# === #{rep.class}\n"
  puts
  print "  rep.program           #=> "; p rep.program
  print "  rep.version           #=> "; p rep.version
  print "  rep.reference         #=> "; p rep.reference
  print "  rep.notice       [WU] #=> "; p rep.notice              #+WU
  print "  rep.db                #=> "; p rep.db
  print "  rep.query_id          #=> "; p rep.query_id        #-m0,-WU
  print "  rep.query_def         #=> "; p rep.query_def
  print "  rep.query_len         #=> "; p rep.query_len
  #puts
  print "  rep.version_number    #=> "; p rep.version_number  #+m0,+WU
  print "  rep.version_date      #=> "; p rep.version_date    #+m0,+WU
  puts

  print "# === Parameters\n"
  #puts
  print "  rep.parameters        #=> "; p rep.parameters      #-m0
  puts
  print "  rep.matrix            #=> "; p rep.matrix              #-WU
  print "  rep.expect            #=> "; p rep.expect
  print "  rep.inclusion         #=> "; p rep.inclusion       #-m0,-WU
  print "  rep.sc_match          #=> "; p rep.sc_match            #-WU
  print "  rep.sc_mismatch       #=> "; p rep.sc_mismatch         #-WU
  print "  rep.gap_open          #=> "; p rep.gap_open            #-WU
  print "  rep.gap_extend        #=> "; p rep.gap_extend          #-WU
  print "  rep.filter            #=> "; p rep.filter          #-m0,-WU
  print "  rep.pattern           #=> "; p rep.pattern             #-WU
  print "  rep.entrez_query      #=> "; p rep.entrez_query    #-m0
  #puts
  print "  rep.pattern_positions #=> "; p rep.pattern_positions #+m0
  puts

  print "# === Statistics (last iteration's)\n"
  #puts
  print "  rep.statistics        #=> "; p rep.statistics      #-m0,-WU
  puts
  print "  rep.db_num            #=> "; p rep.db_num
  print "  rep.db_len            #=> "; p rep.db_len
  print "  rep.hsp_len           #=> "; p rep.hsp_len         #-m0,-WU
  print "  rep.eff_space         #=> "; p rep.eff_space           #-WU
  print "  rep.kappa             #=> "; p rep.kappa               #-WU
  print "  rep.lambda            #=> "; p rep.lambda              #-WU
  print "  rep.entropy           #=> "; p rep.entropy             #-WU
  puts
  print "  rep.num_hits          #=> "; p rep.num_hits        #+m0
  print "  rep.gapped_kappa      #=> "; p rep.gapped_kappa    #+m0
  print "  rep.gapped_lambda     #=> "; p rep.gapped_lambda   #+m0
  print "  rep.gapped_entropy    #=> "; p rep.gapped_entropy  #+m0
  print "  rep.posted_date       #=> "; p rep.posted_date     #+m0
  puts

  print "# === Message (last iteration's)\n"
  puts
  print "  rep.message           #=> "; p rep.message             #-WU
  #puts
  print "  rep.converged?        #=> "; p rep.converged?      #+m0
  puts

  print "# === Warning messages\n"
  print "  rep.warnings     [WU] #=> "; p rep.warnings            #+WU

  print "# === Iterations\n"
  puts
  print "  rep.itrerations.each do |itr|\n"
  puts

  rep.iterations.each do |itr|
  itr = wrap(itr)
      
  #print "# --- Bio::Blast::Default::Report::Iteration\n"
  print "# --- #{itr.class}\n"
  puts

  print "    itr.num             #=> "; p itr.num
  print "    itr.statistics      #=> "; p itr.statistics      #-m0,-WU
  print "    itr.warnings   [WU] #=> "; p itr.warnings            #+WU
  print "    itr.message         #=> "; p itr.message
  print "    itr.hits.size       #=> "; p itr.hits.size
  #puts
  print "    itr.hits_newly_found.size    #=> "; p((itr.hits_newly_found.size rescue nil)); #+m0
  print "    itr.hits_found_again.size    #=> "; p((itr.hits_found_again.size rescue nil)); #+m0
  if itr.respond_to?(:hits_for_pattern) and itr.hits_for_pattern then #+m0
  itr.hits_for_pattern.each_with_index do |hp, hpi|
  print "    itr.hits_for_pattern[#{hpi}].size #=> "; p hp.size;
  end
  end
  print "    itr.converged?      #=> "; p itr.converged?      #+m0,+WU
  puts

  print "    itr.hits.each do |hit|\n"
  puts

  itr.hits.each_with_index do |hit, i|
  hit = wrap(hit)

  #print "# --- Bio::Blast::Default::Report::Hit"
  print "# --- #{hit.class}"
  print " ([#{i}])\n"
  puts

  print "      hit.num           #=> "; p hit.num             #-m0,-WU
  print "      hit.hit_id        #=> "; p hit.hit_id          #-m0,-WU
  print "      hit.len           #=> "; p hit.len
  print "      hit.definition    #=> "; p hit.definition
  print "      hit.accession     #=> "; p hit.accession       #-m0,-WU
  #puts
  print "      hit.found_again?  #=> "; p hit.found_again?    #+m0,+WU
  print "      hit.score    [WU] #=> "; p hit.score               #+WU
  print "      hit.pvalue   [WU] #=> "; p hit.pvalue              #+WU
  print "      hit.n_number [WU] #=> "; p hit.n_number            #+WU

  print "        --- compatible/shortcut ---\n"
  print "      hit.query_id      #=> "; p hit.query_id        #-m0,-WU
  print "      hit.query_def     #=> "; p hit.query_def       #-m0,-WU
  print "      hit.query_len     #=> "; p hit.query_len       #-m0,-WU
  print "      hit.target_id     #=> "; p hit.target_id       #-m0,-WU
  print "      hit.target_def    #=> "; p hit.target_def
  print "      hit.target_len    #=> "; p hit.target_len

  print "            --- first HSP's values (shortcut) ---\n"
  print "      hit.evalue        #=> "; p hit.evalue
  print "      hit.bit_score     #=> "; p hit.bit_score
  print "      hit.identity      #=> "; p hit.identity
  print "      hit.overlap       #=> "; p hit.overlap         #-m0,-WU

  print "      hit.query_seq     #=> "; p hit.query_seq
  print "      hit.midline       #=> "; p hit.midline
  print "      hit.target_seq    #=> "; p hit.target_seq

  print "      hit.query_start   #=> "; p hit.query_start
  print "      hit.query_end     #=> "; p hit.query_end
  print "      hit.target_start  #=> "; p hit.target_start
  print "      hit.target_end    #=> "; p hit.target_end
  print "      hit.lap_at        #=> "; p hit.lap_at
  print "            --- first HSP's vaules (shortcut) ---\n"
  print "        --- compatible/shortcut ---\n"

  puts
  print "      hit.hsps.size     #=> "; p hit.hsps.size
  if hit.hsps.size == 0 then
  puts  "          (HSP not found: please see blastall's -b and -v options)"
  puts
  else

  puts
  print "      hit.hsps.each do |hsp|\n"
  puts

  hit.hsps.each_with_index do |hsp, j|
  hsp = wrap(hsp)

  #print "# --- Bio::Blast::Default::Report::Hsp"
  print "# --- #{hsp.class}"
  print " ([#{j}])\n"
  puts
  print "        hsp.num         #=> "; p hsp.num             #-m0,-WU
  print "        hsp.bit_score   #=> "; p hsp.bit_score 
  print "        hsp.score       #=> "; p hsp.score
  print "        hsp.evalue      #=> "; p hsp.evalue
  print "        hsp.identity    #=> "; p hsp.identity
  print "        hsp.gaps        #=> "; p hsp.gaps
  print "        hsp.positive    #=> "; p hsp.positive
  print "        hsp.align_len   #=> "; p hsp.align_len
  print "        hsp.density     #=> "; p hsp.density         #-m0,-WU
  print "        hsp.pvalue  [WU]#=> "; p hsp.pvalue              #+WU
  print "        hsp.p_sum_n [WU]#=> "; p hsp.p_sum_n             #+WU

  print "        hsp.query_frame #=> "; p hsp.query_frame
  print "        hsp.query_from  #=> "; p hsp.query_from
  print "        hsp.query_to    #=> "; p hsp.query_to

  print "        hsp.hit_frame   #=> "; p hsp.hit_frame
  print "        hsp.hit_from    #=> "; p hsp.hit_from
  print "        hsp.hit_to      #=> "; p hsp.hit_to

  print "        hsp.pattern_from#=> "; p hsp.pattern_from    #-m0,-WU
  print "        hsp.pattern_to  #=> "; p hsp.pattern_to      #-m0,-WU

  print "        hsp.qseq        #=> "; p hsp.qseq
  print "        hsp.midline     #=> "; p hsp.midline
  print "        hsp.hseq        #=> "; p hsp.hseq
  puts
  print "        hsp.percent_identity  #=> "; p hsp.percent_identity
  print "        hsp.mismatch_count    #=> "; p hsp.mismatch_count   #-m0,-WU
  #
  print "        hsp.query_strand      #=> "; p hsp.query_strand     #+m0,+WU
  print "        hsp.hit_strand        #=> "; p hsp.hit_strand       #+m0,+WU
  print "        hsp.percent_positive  #=> "; p hsp.percent_positive #+m0,+WU
  print "        hsp.percent_gaps      #=> "; p hsp.percent_gaps     #+m0,+WU
  puts

  end #each
  end #if hit.hsps.size == 0
  end
  end
  end #ff.each
end #Bio::FlatFile.open

