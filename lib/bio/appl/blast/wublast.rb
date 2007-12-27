#
# = bio/appl/blast/wublast.rb - WU-BLAST default output parser
# 
# Copyright::  Copyright (C) 2003 GOTO Naohisa <ng@bioruby.org>
# License::    The Ruby License
#
# $Id: wublast.rb,v 1.12 2007/12/27 17:28:57 ngoto Exp $
#
# == Description
#
# WU-BLAST default output parser.
#
# The parser is still incomplete and may contain many bugs,
# because I didn't have WU-BLAST license.
# It was tested under web-based WU-BLAST results and
# obsolete version downloaded from http://blast.wustl.edu/ .
#
# == References
#
# * http://blast.wustl.edu/
# * http://www.ebi.ac.uk/blast2/
#

require 'bio/appl/blast/format0'

module Bio
  class Blast
    module WU #:nodoc:

      # Bio::Blast::WU::Report parses WU-BLAST default output
      # and stores information in the data.
      # It may contain a Bio::Blast::WU::Report::Iteration object.
      # Because it inherits Bio::Blast::Default::Report,
      # please also refer Bio::Blast::Default::Report.
      class Report < Default::Report

        # Returns parameters (???)
        def parameters
          parse_parameters
          @parameters
        end

        # Returns parameter matrix (???)
        def parameter_matrix
          parse_parameters
          @parameter_matrix
        end

        # Returns e-value threshold specified when BLAST was executed.
        def expect; parse_parameters; @parameters['E']; end

        # Returns warning messages.
        def warnings
          unless defined?(@warnings)
            @warnings = @f0warnings
            iterations.each { |x| @warnings.concat(x.warnings) }
          end
          @warnings
        end

        # Returns notice messages.
        def notice
          unless defined?(@notice)
            @notice = @f0notice.to_s.gsub(/\s+/, ' ').strip
          end #unless
          @notice
        end

        private
        # Splits headers.
        def format0_split_headers(data)
          @f0header = data.shift
          @f0references = []
          while r = data.first
            case r
            when /^Reference\: /
              @f0references.push data.shift
            when /^Copyright /
              @f0copyright = data.shift
            when /^Notice\: /
              @f0notice = data.shift
            when /^Query\= /
              break
            else
              break
            end
          end
          @f0query = data.shift
          if r = data.first and !(/^Database\: / =~ r)
            @f0translate_info = data.shift
          end
          @f0database = data.shift
        end

        # Splits search data.
        def format0_split_search(data)
          [ Iteration.new(data) ]
        end

        # Splits statistics parameters.
        def format0_split_stat_params(data)
          @f0warnings = []
          if r = data.first and r =~ /^WARNING\: / then
            @f0warnings << data.shift
          end
          @f0wu_params = []
          @f0wu_stats = []
          while r = data.shift and !(r =~ /^Statistics\:/)
            @f0wu_params << r
          end
          @f0wu_stats << r if r
          while r = data.shift
            @f0wu_stats << r
          end
          @f0dbstat = F0dbstat.new(@f0wu_stats)
          itr = @iterations[0]
          x = @f0dbstat
          itr.instance_eval { @f0dbstat = x } if itr
        end

        # Splits parameters.
        def parse_parameters
          unless defined?(@parse_parameters)
            @parameters = {}
            @parameter_matrix = []
            @f0wu_params.each do |x|
              if /^  Query/ =~ x then
                @parameter_matrix << x
              else
                x.split(/^/).each do |y|
                  if /\A\s*(.+)\s*\=\s*(.*)\s*/ =~ y then
                    @parameters[$1] = $2
                  elsif /\AParameters\:/ =~ y then
                    ; #ignore this
                  elsif /\A\s*(.+)\s*$/ =~ y then
                    @parameters[$1] = true
                  end
                end
              end
            end
            if ev = @parameters['E'] then
              ev = '1' + ev if ev[0] == ?e
              @parameters['E'] = ev.to_f
            end
            @parse_parameters = true
          end
        end

        # Stores database statistics.
        # Internal use only. Users must not use the class.
        class F0dbstat < Default::Report::F0dbstat #:nodoc:
          def initialize(ary)
            @f0stat = ary
            @hash = {}
          end

          #--
          #undef :f0params
          #undef :matrix, :gap_open, :gap_extend,
          #  :eff_space, :expect, :sc_match, :sc_mismatch,
          #  :num_hits
          #++

          # Parses database statistics.
          def parse_dbstat
            unless defined?(@parse_dbstat)
              parse_colon_separated_params(@hash, @f0stat)
              @database = @hash['Database']
              @posted_date = @hash['Posted']
              if val = @hash['# of letters in database'] then
                @db_len =  val.tr(',', '').to_i
              end
              if val = @hash['# of sequences in database'] then
                @db_num = val.tr(',', '').to_i
              end
              @parse_dbstat = true
            end #unless
          end #def
          private :parse_dbstat

        end #class F0dbstat

        #--
        #class Frame
        #end #class FrameParams
        #++

        # Iteration class for WU-BLAST report.
        # Though WU-BLAST does not iterate like PSI-BLAST,
        # Bio::Blast::WU::Report::Iteration aims to keep compatibility
        # with Bio::Blast::Default::Report::* classes.
        # It may contain some Bio::Blast::WU::Report::Hit objects.
        # Because it inherits Bio::Blast::Default::Report::Iteration,
        # please also refer Bio::Blast::Default::Report::Iteration.
        class Iteration < Default::Report::Iteration
          # Creates a new Iteration object.
          # It is designed to be called only internally from
          # the Bio::Blast::WU::Report class.
          # Users shall not use the method directly.
          def initialize(data)
            @f0stat = []
            @f0dbstat = Default::Report::AlwaysNil.instance
            @f0hitlist = []
            @hits = []
            @num = 1
            @f0message = []
            @f0warnings = []
            return unless r = data.shift
            @f0hitlist << r
            return unless r = data.shift
            unless /\*{3} +NONE +\*{3}/ =~ r then
              @f0hitlist << r
              while r = data.first and /^WARNING\: / =~ r
                @f0warnings << data.shift
              end
              while r = data.first and /^\>/ =~ r
                @hits << Hit.new(data)
              end
            end #unless
          end

          # Returns warning messages.
          def warnings
            @f0warnings
          end

          private
          # Parses hit list.
          def parse_hitlist
            unless defined?(@parse_hitlist)
              r = @f0hitlist.shift.to_s
              if /Reading/ =~ r and /Frame/ =~ r then
                flag_tblast = true 
                spnum = 5
              else
                flag_tblast = nil
                spnum = 4
              end
              i = 0
              @f0hitlist.each do |x|
                b = x.split(/^/)
                b.collect! { |y| y.empty? ? nil : y }
                b.compact!
                b.each do |y|
                  y.strip!
                  y.reverse!
                  z = y.split(/\s+/, spnum)
                  z.each { |y| y.reverse! }
                  dfl  = z.pop
                  h = @hits[i] 
                  unless h then
                    h = Hit.new([ dfl.to_s.sub(/\.+\z/, '') ])
                    @hits[i] = h
                  end
                  z.pop if flag_tblast #ignore Reading Frame
                  scr = z.pop
                  scr = (scr ? scr.to_i : nil)
                  pval = z.pop.to_s
                  pval = '1' + pval if pval[0] == ?e
                  pval = (pval.empty? ? (1.0/0.0) : pval.to_f)
                  nnum = z.pop.to_i
                  h.instance_eval {
                    @score = scr
                    @pvalue = pval
                    @n_number = nnum
                  }
                  i += 1
                end
              end #each
              @parse_hitlist = true
            end #unless
          end
        end #class Iteration

        # Bio::Blast::WU::Report::Hit contains information about a hit.
        # It may contain some Bio::Blast::WU::Report::HSP objects.
        #
        # Because it inherits Bio::Blast::Default::Report::Hit,
        # please also refer Bio::Blast::Default::Report::Hit.
        class Hit < Default::Report::Hit
          # Creates a new Hit object.
          # It is designed to be called only internally from the
          # Bio::Blast::WU::Report::Iteration class.
          # Users should not call the method directly.
          def initialize(data)
            @f0hitname = data.shift
            @hsps = []
            while r = data.first
              if r =~ /^\s*(?:Plus|Minus) +Strand +HSPs\:/ then
                data.shift
                r = data.first
              end
              if /\A\s+Score/ =~ r then
                @hsps << HSP.new(data)
              else
                break
              end
            end
            @again = false
          end

          # Returns score.
          def score
            @score
          end
          # p-value
          attr_reader :pvalue
          # n-number (???)
          attr_reader :n_number
        end #class Hit

        # Bio::Blast::WU::Report::HSP holds information about the hsp
        # (high-scoring segment pair).
        #
        # Because it inherits Bio::Blast::Default::Report::HSP,
        # please also refer Bio::Blast::Default::Report::HSP.
        class HSP < Default::Report::HSP
          # p-value
          attr_reader :pvalue if false #dummy
          method_after_parse_score :pvalue
          # p_sum_n (???)
          attr_reader :p_sum_n if false #dummy
          method_after_parse_score :p_sum_n
        end #class HSP

      end #class Report

      # WU-BLAST default output parser for TBLAST.
      # All methods are equal to Bio::Blast::WU::Report.
      # Only DELIMITER (and RS) is different.
      class Report_TBlast < Report
        # Delimter of each entry for TBLAST. Bio::FlatFile uses it.
        DELIMITER = RS = "\nTBLAST"

        # (Integer) excess read size included in DELIMITER.
        DELIMITER_OVERRUN = 6 # "TBLAST"
      end #class Report_TBlast

    end #module WU
  end #class Blast
end #module Bio

######################################################################

if __FILE__ == $0

  Bio::FlatFile.open(Bio::Blast::WU::Report, ARGF) do |ff|
  ff.each do |rep|

  print "# === Bio::Blast::WU::Report\n"
  puts
  print "  rep.program           #=> "; p rep.program
  print "  rep.version           #=> "; p rep.version
  print "  rep.reference         #=> "; p rep.reference
  print "  rep.notice            #=> "; p rep.notice
  print "  rep.db                #=> "; p rep.db
  #print "  rep.query_id          #=> "; p rep.query_id
  print "  rep.query_def         #=> "; p rep.query_def
  print "  rep.query_len         #=> "; p rep.query_len
  #puts
  print "  rep.version_number    #=> "; p rep.version_number
  print "  rep.version_date      #=> "; p rep.version_date
  puts

  print "# === Parameters\n"
  #puts
  print "  rep.parameters        #=> "; p rep.parameters
  puts
  #@#print "  rep.matrix            #=> "; p rep.matrix
  print "  rep.expect            #=> "; p rep.expect
  #print "  rep.inclusion         #=> "; p rep.inclusion
  #@#print "  rep.sc_match          #=> "; p rep.sc_match
  #@#print "  rep.sc_mismatch       #=> "; p rep.sc_mismatch
  #@#print "  rep.gap_open          #=> "; p rep.gap_open
  #@#print "  rep.gap_extend        #=> "; p rep.gap_extend
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
  #@#print "  rep.eff_space         #=> "; p rep.eff_space
  #@#print "  rep.kappa             #=> "; p rep.kappa
  #@#print "  rep.lambda            #=> "; p rep.lambda
  #@#print "  rep.entropy           #=> "; p rep.entropy
  puts
  #@#print "  rep.num_hits          #=> "; p rep.num_hits
  #@#print "  rep.gapped_kappa      #=> "; p rep.gapped_kappa
  #@#print "  rep.gapped_lambda     #=> "; p rep.gapped_lambda
  #@#print "  rep.gapped_entropy    #=> "; p rep.gapped_entropy
  #@#print "  rep.posted_date       #=> "; p rep.posted_date
  puts

  #@#print "# === Message (last iteration's)\n"
  #@#puts
  #@#print "  rep.message           #=> "; p rep.message
  #puts
  #@#print "  rep.converged?        #=> "; p rep.converged?
  #puts

  print "# === Warning messages\n"
  print "  rep.warnings        #=> "; p rep.warnings

  print "# === Iterations\n"
  puts
  print "  rep.itrerations.each do |itr|\n"
  puts

  rep.iterations.each do |itr|
      
  print "# --- Bio::Blast::WU::Report::Iteration\n"
  puts

  print "    itr.num             #=> "; p itr.num
  #print "    itr.statistics      #=> "; p itr.statistics
  puts
  print "    itr.warnings        #=> "; p itr.warnings
  print "    itr.message         #=> "; p itr.message
  print "    itr.hits.size       #=> "; p itr.hits.size
  #puts
  #@#print "    itr.hits_newly_found.size    #=> "; p itr.hits_newly_found.size;
  #@#print "    itr.hits_found_again.size    #=> "; p itr.hits_found_again.size;
  if itr.hits_for_pattern then
  itr.hits_for_pattern.each_with_index do |hp, hpi|
  print "    itr.hits_for_pattern[#{hpi}].size #=> "; p hp.size;
  end
  end
  print "    itr.converged?      #=> "; p itr.converged?
  puts

  print "    itr.hits.each do |hit|\n"
  puts

  itr.hits.each_with_index do |hit, i|

  print "# --- Bio::Blast::WU::Report::Hit"
  print " ([#{i}])\n"
  puts

  #print "      hit.num           #=> "; p hit.num
  #print "      hit.hit_id        #=> "; p hit.hit_id
  print "      hit.len           #=> "; p hit.len
  print "      hit.definition    #=> "; p hit.definition
  #print "      hit.accession     #=> "; p hit.accession
  #puts
  print "      hit.found_again?  #=> "; p hit.found_again?
  #puts
  print "      hit.score         #=> "; p hit.score
  print "      hit.pvalue        #=> "; p hit.pvalue
  print "      hit.n_number      #=> "; p hit.n_number

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

  print "# --- Bio::Blast::WU::Report::Hsp"
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
  puts
  print "        hsp.pvalue      #=> "; p hsp.pvalue
  print "        hsp.p_sum_n     #=> "; p hsp.p_sum_n
  puts

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

