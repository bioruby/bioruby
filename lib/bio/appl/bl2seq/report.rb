#
# bio/appl/bl2seq/report.rb - bl2seq (BLAST 2 sequences) parser
# 
#   Copyright (C) 2005 GOTO Naohisa <ng@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: report.rb,v 1.2 2005/08/10 12:55:41 k Exp $
#
#  Acknowledgements:
#    Thanks to Tomoaki NISHIYAMA <tomoakin@kenroku.kanazawa-u.ac.jp> 
#    for providing bl2seq parser patches based on
#    lib/bio/appl/blast/format0.rb.
#

require 'bio/appl/blast/format0'

module Bio
class Blast

  class Bl2seq
    class Report < Bio::Blast::Default::Report
      DELIMITER = RS = nil

      undef format0_parse_header
      undef program, version, version_number, version_date,
	message, converged?, reference, db

      def format0_split_headers(data)
	@f0query = data.shift
      end

      def format0_split_search(data)
	iterations = []
	while r = data[0] and /^\>/ =~ r
	  iterations << Iteration.new(data)
	end
	if iterations.size <= 0 then
	  iterations << Iteration.new(data)
	end
	iterations
      end

      class F0dbstat < Bio::Blast::Default::Report::F0dbstat
	def db_num
	  unless defined?(@db_num)
	    parse_params
	    @db_num = @hash['Number of Sequences'].to_i
	  end
	  @db_num
	end

	def db_len
	  unless defined?(@db_len)
	    parse_params
	    @db_len = @hash['length of database'].to_i
	  end
	  @db_len
	end
      end #class F0dbstat

      class Iteration < Bio::Blast::Default::Report::Iteration
	def initialize(data)
	  @f0stat = []
	  @f0dbstat = nil
	  @hits = []
	  @num = 1
	  while r = data[0] and /^\>/ =~ r
	    @hits << Hit.new(data)
	  end
	end

	def hits; @hits; end
	undef message, pattern_in_database, f0message, f0hitlist,
	  pattern, pattern_positions, hits_found_again,
	  hits_newly_found, hits_for_pattern, parse_hitlist,
	  converged?
      end #class Iteration

      class Hit < Bio::Blast::Default::Report::Hit
      end #class Hit

      # NOTE: HSP class below is NOT used!!
      class HSP < Bio::Blast::Default::Report::HSP
      end #class HSP

    end #class Report
  end #class Bl2seq

end #class Blast
end #module Bio

######################################################################

if __FILE__ == $0

  Bio::FlatFile.open(Bio::Blast::Bl2seq::Report, ARGF) do |ff|
  ff.each do |rep|

  print "# === Bio::Blast::Bl2seq::Report\n"
  puts
  #@#print "  rep.program           #=> "; p rep.program
  #@#print "  rep.version           #=> "; p rep.version
  #@#print "  rep.reference         #=> "; p rep.reference
  #@#print "  rep.db                #=> "; p rep.db
  #print "  rep.query_id          #=> "; p rep.query_id
  print "  rep.query_def         #=> "; p rep.query_def
  print "  rep.query_len         #=> "; p rep.query_len
  #puts
  #@#print "  rep.version_number    #=> "; p rep.version_number
  #@#print "  rep.version_date      #=> "; p rep.version_date
  puts

  print "# === Parameters\n"
  #puts
  #print "  rep.parameters        #=> "; p rep.parameters
  puts
  print "  rep.matrix            #=> "; p rep.matrix
  print "  rep.expect            #=> "; p rep.expect
  #print "  rep.inclusion         #=> "; p rep.inclusion
  print "  rep.sc_match          #=> "; p rep.sc_match
  print "  rep.sc_mismatch       #=> "; p rep.sc_mismatch
  print "  rep.gap_open          #=> "; p rep.gap_open
  print "  rep.gap_extend        #=> "; p rep.gap_extend
  #print "  rep.filter            #=> "; p rep.filter
  #@#print "  rep.pattern           #=> "; p rep.pattern
  #print "  rep.entrez_query      #=> "; p rep.entrez_query
  #puts
  #@#print "  rep.pattern_positions  #=> "; p rep.pattern_positions
  puts

  print "# === Statistics (last iteration's)\n"
  #puts
  #print "  rep.statistics        #=> "; p rep.statistics
  puts
  print "  rep.db_num            #=> "; p rep.db_num
  print "  rep.db_len            #=> "; p rep.db_len
  #print "  rep.hsp_len           #=> "; p rep.hsp_len
  print "  rep.eff_space         #=> "; p rep.eff_space
  print "  rep.kappa             #=> "; p rep.kappa
  print "  rep.lambda            #=> "; p rep.lambda
  print "  rep.entropy           #=> "; p rep.entropy
  puts
  print "  rep.num_hits          #=> "; p rep.num_hits
  print "  rep.gapped_kappa      #=> "; p rep.gapped_kappa
  print "  rep.gapped_lambda     #=> "; p rep.gapped_lambda
  print "  rep.gapped_entropy    #=> "; p rep.gapped_entropy
  print "  rep.posted_date       #=> "; p rep.posted_date
  puts

  #@#print "# === Message (last iteration's)\n"
  #@#puts
  #@#print "  rep.message           #=> "; p rep.message
  #puts
  #@#print "  rep.converged?        #=> "; p rep.converged?
  #@#puts

  print "# === Iterations\n"
  puts
  print "  rep.itrerations.each do |itr|\n"
  puts

  rep.iterations.each do |itr|
      
  print "# --- Bio::Blast::Bl2seq::Report::Iteration\n"
  puts

  print "    itr.num             #=> "; p itr.num
  #print "    itr.statistics      #=> "; p itr.statistics
  #@#print "    itr.message         #=> "; p itr.message
  print "    itr.hits.size       #=> "; p itr.hits.size
  #puts
  #@#print "    itr.hits_newly_found.size    #=> "; p itr.hits_newly_found.size;
  #@#print "    itr.hits_found_again.size    #=> "; p itr.hits_found_again.size;
  #@#if itr.hits_for_pattern then
  #@#itr.hits_for_pattern.each_with_index do |hp, hpi|
  #@#print "    itr.hits_for_pattern[#{hpi}].size #=> "; p hp.size;
  #@#end
  #@#end
  #@#print "    itr.converged?      #=> "; p itr.converged?
  puts

  print "    itr.hits.each do |hit|\n"
  puts

  itr.hits.each_with_index do |hit, i|

  print "# --- Bio::Blast::Bl2seq::Default::Report::Hit"
  print " ([#{i}])\n"
  puts

  #print "      hit.num           #=> "; p hit.num
  #print "      hit.hit_id        #=> "; p hit.hit_id
  print "      hit.len           #=> "; p hit.len
  print "      hit.definition    #=> "; p hit.definition
  #print "      hit.accession     #=> "; p hit.accession
  #puts
  print "      hit.found_again?  #=> "; p hit.found_again?

  print "        --- compatible/shortcut ---\n"
  #print "      hit.query_id      #=> "; p hit.query_id
  #print "      hit.query_def     #=> "; p hit.query_def
  #print "      hit.query_len     #=> "; p hit.query_len
  #print "      hit.target_id     #=> "; p hit.target_id
  print "      hit.target_def    #=> "; p hit.target_def
  print "      hit.target_len    #=> "; p hit.target_len

  print "            --- first HSP's values (shortcut) ---\n"
  print "      hit.evalue        #=> "; p hit.evalue
  print "      hit.bit_score     #=> "; p hit.bit_score
  print "      hit.identity      #=> "; p hit.identity
  #print "      hit.overlap       #=> "; p hit.overlap

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

  print "# --- Bio::Blast::Default::Report::HSP (Bio::Blast::Bl2seq::Report::HSP)"
  print " ([#{j}])\n"
  puts
  #print "        hsp.num         #=> "; p hsp.num
  print "        hsp.bit_score   #=> "; p hsp.bit_score 
  print "        hsp.score       #=> "; p hsp.score
  print "        hsp.evalue      #=> "; p hsp.evalue
  print "        hsp.identity    #=> "; p hsp.identity
  print "        hsp.gaps        #=> "; p hsp.gaps
  print "        hsp.positive    #=> "; p hsp.positive
  print "        hsp.align_len   #=> "; p hsp.align_len
  #print "        hsp.density     #=> "; p hsp.density

  print "        hsp.query_frame #=> "; p hsp.query_frame
  print "        hsp.query_from  #=> "; p hsp.query_from
  print "        hsp.query_to    #=> "; p hsp.query_to

  print "        hsp.hit_frame   #=> "; p hsp.hit_frame
  print "        hsp.hit_from    #=> "; p hsp.hit_from
  print "        hsp.hit_to      #=> "; p hsp.hit_to

  #print "        hsp.pattern_from#=> "; p hsp.pattern_from
  #print "        hsp.pattern_to  #=> "; p hsp.pattern_to

  print "        hsp.qseq        #=> "; p hsp.qseq
  print "        hsp.midline     #=> "; p hsp.midline
  print "        hsp.hseq        #=> "; p hsp.hseq
  puts
  print "        hsp.percent_identity  #=> "; p hsp.percent_identity
  #print "        hsp.mismatch_count    #=> "; p hsp.mismatch_count
  #
  print "        hsp.query_strand      #=> "; p hsp.query_strand
  print "        hsp.hit_strand        #=> "; p hsp.hit_strand
  print "        hsp.percent_positive  #=> "; p hsp.percent_positive
  print "        hsp.percent_gaps      #=> "; p hsp.percent_gaps
  puts

  end #each
  end #if hit.hsps.size == 0
  end
  end
  end #ff.each
  end #FlatFile.open

end #if __FILE__ == $0

######################################################################

=begin

= Bio::Blast::Bl2seq::Report

    NCBI bl2seq (BLAST 2 sequences) output parser

=end

