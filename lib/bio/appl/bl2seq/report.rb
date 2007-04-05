#
# = bio/appl/bl2seq/report.rb - bl2seq (BLAST 2 sequences) parser
# 
# Copyright:: Copyright (C) 2005 GOTO Naohisa <ng@bioruby.org>
# License::   The Ruby License
#
#  $Id: report.rb,v 1.8 2007/04/05 23:35:39 trevor Exp $
#
# Bio::Bl2seq::Report is a NCBI bl2seq (BLAST 2 sequences) output parser.
#
# = Acknowledgements
#
# Thanks to Tomoaki NISHIYAMA <tomoakin __at__ kenroku.kanazawa-u.ac.jp> 
# for providing bl2seq parser patches based on
# lib/bio/appl/blast/format0.rb.
#

require 'bio/appl/blast/format0'

module Bio
class Blast

  class Bl2seq

    # Bio::Bl2seq::Report is a NCBI bl2seq (BLAST 2 sequences) output parser.
    # It inherits Bio::Blast::Default::Report.
    # Most of its methods are the same as Bio::Blast::Default::Report,
    # but it lacks many methods.
    class Report < Bio::Blast::Default::Report

      # Delimiter of each entry. Bio::FlatFile uses it.
      # In Bio::Bl2seq::Report, it it nil (1 entry 1 file).
      DELIMITER = RS = nil

      undef format0_parse_header
      undef program, version, version_number, version_date,
        message, converged?, reference, db

      # Splits headers.
      def format0_split_headers(data)
        @f0query = data.shift
      end
      private :format0_split_headers

      # Splits the search results.
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
      private :format0_split_search

      # Stores format0 database statistics.
      # Internal use only. Users must not use the class.
      class F0dbstat < Bio::Blast::Default::Report::F0dbstat #:nodoc:
        # Returns number of sequences in database.
        def db_num
          unless defined?(@db_num)
            parse_params
            @db_num = @hash['Number of Sequences'].to_i
          end
          @db_num
        end

        # Returns number of letters in database.
        def db_len
          unless defined?(@db_len)
            parse_params
            @db_len = @hash['length of database'].to_i
          end
          @db_len
        end
      end #class F0dbstat

      # Bio::Bl2seq::Report::Iteration stores information about
      # a iteration.
      # Normally, it may contain some Bio::Bl2seq::Report::Hit objects.
      #
      # Note that its main existance reason is to keep complatibility
      # between Bio::Blast::Default::Report::* classes.
      class Iteration < Bio::Blast::Default::Report::Iteration
        # Creates a new Iteration object.
        # It is designed to be called only internally from
        # the Bio::Blast::Default::Report class.
        # Users shall not use the method directly.
        def initialize(data)
          @f0stat = []
          @f0dbstat = Bio::Blast::Default::Report::AlwaysNil.instance
          @hits = []
          @num = 1
          while r = data[0] and /^\>/ =~ r
            @hits << Hit.new(data)
          end
        end

        # Returns the hits of the iteration.
        # It returns an array of Bio::Bl2seq::Report::Hit objects.
        def hits; @hits; end

        undef message, pattern_in_database, 
          pattern, pattern_positions, hits_found_again,
          hits_newly_found, hits_for_pattern, parse_hitlist,
          converged?
      end #class Iteration

      # Bio::Bl2seq::Report::Hit contains information about a hit.
      # It may contain some Bio::Blast::Default::Report::HSP objects.
      # All methods are the same as Bio::Blast::Default::Report::Hit class.
      # Please refer to Bio::Blast::Default::Report::Hit.
      class Hit < Bio::Blast::Default::Report::Hit
      end #class Hit

      # Bio::Bl2seq::Report::HSP holds information about the hsp
      # (high-scoring segment pair).
      # NOTE that the HSP class below is NOT used because
      # Ruby's constants namespace are normally statically determined
      # and HSP object is created in Bio::Blast::Default::Report::Hit class.
      # Please refer to Bio::Blast::Default::Report::HSP.
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

