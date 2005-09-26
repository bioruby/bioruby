#
# bio/appl/blast/report.rb - BLAST Report class
# 
#   Copyright (C) 2003 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: report.rb,v 1.9 2005/09/26 13:00:04 k Exp $
#

require 'bio/appl/blast'
require 'bio/appl/blast/xmlparser'
require 'bio/appl/blast/rexml'
require 'bio/appl/blast/format8'

module Bio
  class Blast

    class Report

      # for Bio::FlatFile support (only for XML data)
      DELIMITER = RS = "</BlastOutput>\n"

      def self.xmlparser(data)
        self.new(data, :xmlparser)
      end
      def self.rexml(data)
        self.new(data, :rexml)
      end
      def self.tab(data)
        self.new(data, :tab)
      end

      def auto_parse(data)
        if /<?xml/.match(data[/.*/])
          if defined?(XMLParser)
            xmlparser_parse(data)
          else
            rexml_parse(data)
          end
        else
          tab_parse(data)
        end
      end
      private :auto_parse

      def initialize(data, parser = nil)
        @iterations = []
        @parameters = {}
        case parser
        when :xmlparser		# format 7
          xmlparser_parse(data)
        when :rexml		# format 7
          rexml_parse(data)
        when :tab		# format 8
          tab_parse(data)
        else
          auto_parse(data)
        end
      end
      attr_reader :iterations, :parameters,
        :program, :version, :reference,	:db, :query_id, :query_def, :query_len

      # shortcut for @parameters
      def matrix;	@parameters['matrix'];			end
      def expect;	@parameters['expect'].to_i;		end
      def inclusion;	@parameters['include'].to_i;		end
      def sc_match;	@parameters['sc-match'].to_i;		end
      def sc_mismatch;	@parameters['sc-mismatch'].to_i;	end
      def gap_open;	@parameters['gap-open'].to_i;		end
      def gap_extend;	@parameters['gap-extend'].to_i;		end
      def filter;	@parameters['filter'];			end
      def pattern;	@parameters['pattern'];			end
      def entrez_query; @parameters['entrez-query'];		end

      # <for blastpgp>
      def each_iteration
        @iterations.each do |x|
          yield x
        end
      end

      # <for blastall> shortcut for the last iteration's hits
      def each_hit
        @iterations.last.each do |x|
          yield x
        end
      end
      alias each each_hit

      # shortcut for the last iteration's hits
      def hits
        @iterations.last.hits
      end

      # shortcut for the last iteration's statistics
      def statistics
        @iterations.last.statistics
      end
      def db_num;	statistics['db-num'];			end
      def db_len;	statistics['db-len'];			end
      def hsp_len;	statistics['hsp-len'];			end
      def eff_space;	statistics['eff-space'];		end
      def kappa;	statistics['kappa'];			end
      def lambda;	statistics['lambda'];			end
      def entropy;	statistics['entropy'];			end

      # shortcut for the last iteration's message (for checking 'CONVERGED')
      def message
        @iterations.last.message
      end


      # Bio::Blast::Report::Iteration
      class Iteration
        def initialize
          @message = nil
          @statistics = {}
          @num = 1
          @hits = []
        end
        attr_reader :hits, :statistics
        attr_accessor :num, :message

        def each
          @hits.each do |x|
            yield x
          end
        end
      end


      # Bio::Blast::Report::Hit
      class Hit
        def initialize
          @hsps = []
        end
        attr_reader :hsps
        attr_accessor :query_id, :query_def, :query_len,
          :num, :hit_id, :len, :definition, :accession

        def each
          @hsps.each do |x|
            yield x
          end
        end

        # Compatible with Bio::Fasta::Report::Hit

        alias target_id accession
        alias target_def definition
        alias target_len len

        # Shortcut methods for the best Hsp

        def evalue;		@hsps.first.evalue;		end
        def bit_score;		@hsps.first.bit_score;		end
        def identity;		@hsps.first.identity;		end
        def percent_identity;	@hsps.first.percent_identity;	end
        def overlap;		@hsps.first.align_len;		end

        def query_seq;		@hsps.first.qseq;		end
        def target_seq;		@hsps.first.hseq;		end
        def midline;		@hsps.first.midline;		end

        def query_start;	@hsps.first.query_from;		end
        def query_end;		@hsps.first.query_to;		end
        def target_start;	@hsps.first.hit_from;		end
        def target_end;		@hsps.first.hit_to;		end
        def lap_at
          [ query_start, query_end, target_start, target_end ]
        end
      end


      # Bio::Blast::Report::Hsp
      class Hsp
        def initialize
          @hsp = {}
        end
        attr_reader :hsp
        attr_accessor :num, :bit_score, :score, :evalue,
          :query_from, :query_to, :hit_from, :hit_to,
          :pattern_from, :pattern_to, :query_frame, :hit_frame,
          :identity, :positive, :gaps, :align_len, :density,
          :qseq, :hseq, :midline,
          :percent_identity, :mismatch_count	 # only for '-m 8'
      end

    end
  end
end


if __FILE__ == $0

=begin

  begin			# p is suitable than pp for the following test script
    require 'pp'
    alias p pp
  rescue
  end

  # for multiple xml reports (iterates on each Blast::Report)
  Bio::Blast.reports(ARGF) do |rep|
    rep.iterations.each do |itr|
      itr.hits.each do |hit|
        hit.hsps.each do |hsp|
        end
      end
    end
  end

  # for multiple xml reports (returns Array of Blast::Report)
  reps = Bio::Blast.reports(ARGF.read)

  # for a single report (xml or tab) format auto detect, parser auto selected
  rep = Bio::Blast::Report.new(ARGF.read)

  # to use xmlparser explicitly for a report
  rep = Bio::Blast::Report.xmlparser(ARGF.read)

  # to use resml explicitly for a report
  rep = Bio::Blast::Report.rexml(ARGF.read)

  # to use a tab delimited report
  rep = Bio::Blast::Report.tab(ARGF.read)

=end

  Bio::Blast.reports(ARGF) do |rep|	# for multiple xml reports

  print "# === Bio::Tools::Blast::Report\n"
  puts
  print "  rep.program           #=> "; p rep.program
  print "  rep.version           #=> "; p rep.version
  print "  rep.reference         #=> "; p rep.reference
  print "  rep.db                #=> "; p rep.db
  print "  rep.query_id          #=> "; p rep.query_id
  print "  rep.query_def         #=> "; p rep.query_def
  print "  rep.query_len         #=> "; p rep.query_len
  puts

  print "# === Parameters\n"
  puts
  print "  rep.parameters        #=> "; p rep.parameters
  puts
  print "  rep.matrix            #=> "; p rep.matrix
  print "  rep.expect            #=> "; p rep.expect
  print "  rep.inclusion         #=> "; p rep.inclusion
  print "  rep.sc_match          #=> "; p rep.sc_match
  print "  rep.sc_mismatch       #=> "; p rep.sc_mismatch
  print "  rep.gap_open          #=> "; p rep.gap_open
  print "  rep.gap_extend        #=> "; p rep.gap_extend
  print "  rep.filter            #=> "; p rep.filter
  print "  rep.pattern           #=> "; p rep.pattern
  print "  rep.entrez_query      #=> "; p rep.entrez_query
  puts

  print "# === Statistics (last iteration's)\n"
  puts
  print "  rep.statistics        #=> "; p rep.statistics
  puts
  print "  rep.db_num            #=> "; p rep.db_num
  print "  rep.db_len            #=> "; p rep.db_len
  print "  rep.hsp_len           #=> "; p rep.hsp_len
  print "  rep.eff_space         #=> "; p rep.eff_space
  print "  rep.kappa             #=> "; p rep.kappa
  print "  rep.lambda            #=> "; p rep.lambda
  print "  rep.entropy           #=> "; p rep.entropy
  puts

  print "# === Message (last iteration's)\n"
  puts
  print "  rep.message           #=> "; p rep.message
  puts

  print "# === Iterations\n"
  puts
  print "  rep.itrerations.each do |itr|\n"
  puts

  rep.iterations.each do |itr|
      
  print "# --- Bio::Blast::Report::Iteration\n"
  puts

  print "    itr.num             #=> "; p itr.num
  print "    itr.statistics      #=> "; p itr.statistics
  print "    itr.message         #=> "; p itr.message
  print "    itr.hits.size       #=> "; p itr.hits.size
  puts

  print "    itr.hits.each do |hit|\n"
  puts

  itr.hits.each do |hit|

  print "# --- Bio::Blast::Report::Hit\n"
  puts

  print "      hit.num           #=> "; p hit.num
  print "      hit.hit_id        #=> "; p hit.hit_id
  print "      hit.len           #=> "; p hit.len
  print "      hit.definition    #=> "; p hit.definition
  print "      hit.accession     #=> "; p hit.accession

  print "        --- compatible/shortcut ---\n"
  print "      hit.query_id      #=> "; p hit.query_id
  print "      hit.query_def     #=> "; p hit.query_def
  print "      hit.query_len     #=> "; p hit.query_len
  print "      hit.target_id     #=> "; p hit.target_id
  print "      hit.target_def    #=> "; p hit.target_def
  print "      hit.target_len    #=> "; p hit.target_len

  print "      hit.evalue        #=> "; p hit.evalue
  print "      hit.bit_score     #=> "; p hit.bit_score
  print "      hit.identity      #=> "; p hit.identity
  print "      hit.overlap       #=> "; p hit.overlap

  print "      hit.query_seq     #=> "; p hit.query_seq
  print "      hit.midline       #=> "; p hit.midline
  print "      hit.target_seq    #=> "; p hit.target_seq

  print "      hit.query_start   #=> "; p hit.query_start
  print "      hit.query_end     #=> "; p hit.query_end
  print "      hit.target_start  #=> "; p hit.target_start
  print "      hit.target_end    #=> "; p hit.target_end
  print "      hit.lap_at        #=> "; p hit.lap_at
  print "        --- compatible/shortcut ---\n"

  print "      hit.hsps.size     #=> "; p hit.hsps.size
  puts

  print "      hit.hsps.each do |hsp|\n"
  puts

  hit.hsps.each do |hsp|

  print "# --- Bio::Blast::Report::Hsp\n"
  puts
  print "        hsp.num         #=> "; p hsp.num
  print "        hsp.bit_score   #=> "; p hsp.bit_score 
  print "        hsp.score       #=> "; p hsp.score
  print "        hsp.evalue      #=> "; p hsp.evalue
  print "        hsp.identity    #=> "; p hsp.identity
  print "        hsp.gaps        #=> "; p hsp.gaps
  print "        hsp.positive    #=> "; p hsp.positive
  print "        hsp.align_len   #=> "; p hsp.align_len
  print "        hsp.density     #=> "; p hsp.density

  print "        hsp.query_frame #=> "; p hsp.query_frame
  print "        hsp.query_from  #=> "; p hsp.query_from
  print "        hsp.query_to    #=> "; p hsp.query_to

  print "        hsp.hit_frame   #=> "; p hsp.hit_frame
  print "        hsp.hit_from    #=> "; p hsp.hit_from
  print "        hsp.hit_to      #=> "; p hsp.hit_to

  print "        hsp.pattern_from#=> "; p hsp.pattern_from
  print "        hsp.pattern_to  #=> "; p hsp.pattern_to

  print "        hsp.qseq        #=> "; p hsp.qseq
  print "        hsp.midline     #=> "; p hsp.midline
  print "        hsp.hseq        #=> "; p hsp.hseq
  puts
  print "        hsp.percent_identity  #=> "; p hsp.percent_identity
  print "        hsp.mismatch_count    #=> "; p hsp.mismatch_count
  puts

  end
  end
  end
  end					# for multiple xml reports

end


=begin

= Bio::Blast::Report

Parsed results of the blast execution for Tab-delimited and XML output
format.  Tab-delimited reports are consists of

  Query id,
  Subject id,
  percent of identity,
  alignment length,
  number of mismatches (not including gaps),
  number of gap openings,
  start of alignment in query,
  end of alignment in query,
  start of alignment in subject,
  end of alignment in subject,
  expected value,
  bit score.

according to the MEGABLAST document (README.mbl).  As for XML output,
see the following DTDs.

  * http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd
  * http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.mod
  * http://www.ncbi.nlm.nih.gov/dtd/NCBI_Entity.mod


--- Bio::Blast::Report.new(data)

      Passing a BLAST output from 'blastall -m 7' or '-m 8' as a String.
      Formats are auto detected.

--- Bio::Blast::Report.xmlparaser(xml)

      Specify to use XMLParser to parse XML (-m 7) output.

--- Bio::Blast::Report.rexml(xml)

      Specify to use REXML to parse XML (-m 7) output.

--- Bio::Blast::Report.tab(data)

      Specify to use tab delimited output parser.

--- Bio::Blast::Report#program
--- Bio::Blast::Report#version
--- Bio::Blast::Report#reference
--- Bio::Blast::Report#db
--- Bio::Blast::Report#query_id
--- Bio::Blast::Report#query_def
--- Bio::Blast::Report#query_len

      Shortcut for BlastOutput values.

--- Bio::Blast::Report#parameters

      Returns a Hash containing execution parameters.  Valid keys are:
        'matrix', 'expect', 'include', 'sc-match', 'sc-mismatch',
        'gap-open', 'gap-extend', 'filter'

--- Bio::Blast::Report#matrix
      * Matrix used (-M)
--- Bio::Blast::Report#expect
      * Expectation threshold (-e)
--- Bio::Blast::Report#inclusion
      * Inclusion threshold (-h)
--- Bio::Blast::Report#sc_match
      * Match score for NT (-r)
--- Bio::Blast::Report#sc_mismatch
      * Mismatch score for NT (-q)
--- Bio::Blast::Report#gap_open
      * Gap opening cost (-G)
--- Bio::Blast::Report#gap_extend
      * Gap extension cost (-E)
--- Bio::Blast::Report#filter
      * Filtering options (-F)
--- Bio::Blast::Report#pattern
      * PHI-BLAST pattern
--- Bio::Blast::Report#entrez_query
      * Limit of request to Entrez

      These are shortcuts for parameters.


--- Bio::Blast::Report#iterations

      Returns an Array of Bio::Blast::Report::Iteration objects.

--- Bio::Blast::Report#each_iteration

      Iterates on each Bio::Blast::Report::Iteration object.

--- Bio::Blast::Report#each_hit
--- Bio::Blast::Report#each

      Iterates on each Bio::Blast::Report::Hit object of the the
      last Iteration.

--- Bio::Blast::Report#statistics

      Returns a Hash containing execution statistics of the last iteration.
      Valid keys are:
        'db-num', 'db-len', 'hsp-len', 'eff-space', 'kappa',
        'lambda', 'entropy'

--- Bio::Blast::Report#db_num
      * Number of sequences in BLAST db
--- Bio::Blast::Report#db_len
      * Length of BLAST db
--- Bio::Blast::Report#hsp_len
      * Effective HSP length
--- Bio::Blast::Report#eff_space
      * Effective search space
--- Bio::Blast::Report#kappa
      * Karlin-Altschul parameter K
--- Bio::Blast::Report#lambda
      * Karlin-Altschul parameter Lamba
--- Bio::Blast::Report#entropy
      * Karlin-Altschul parameter H

      These are shortcuts for statistics.


--- Bio::Blast::Report#message

      Returns a String (or nil) containing execution message of the last
      iteration (typically "CONVERGED").

--- Bio::Blast::Report#hits

      Returns a Array of Bio::Blast::Report::Hits of the last iteration.


== Bio::Blast::Report::Iteration

--- Bio::Blast::Report::Iteration#num

      Returns the number of iteration counts.

--- Bio::Blast::Report::Iteration#hits

      Returns an Array of Bio::Blast::Report::Hit objects.

--- Bio::Blast::Report::Iteration#each

      Iterates on each Bio::Blast::Report::Hit object.

--- Bio::Blast::Report::Iteration#statistics

      Returns a Hash containing execution statistics.
      Valid keys are:
        'db-len', 'db-num', 'eff-space', 'entropy', 'hsp-len',
        'kappa', 'lambda'

--- Bio::Blast::Report::Iteration#message

      Returns a String (or nil) containing execution message (typically
      "CONVERGED").


== Bio::Blast::Report::Hit

--- Bio::Blast::Report::Hit#each

      Iterates on each Hsp object.

--- Bio::Blast::Report::Hit#hsps

      Returns an Array of Bio::Blast::Report::Hsp objects.

--- Bio::Blast::Report::Hit#num
      * hit number
--- Bio::Blast::Report::Hit#hit_id
      * SeqId of subject
--- Bio::Blast::Report::Hit#len
      * length of subject
--- Bio::Blast::Report::Hit#definition
      * definition line of subject
--- Bio::Blast::Report::Hit#accession
      * accession

      Accessors for the Hit values.

--- Bio::Blast::Report::Hit#query_id
--- Bio::Blast::Report::Hit#query_def
--- Bio::Blast::Report::Hit#query_len
--- Bio::Blast::Report::Hit#target_id
--- Bio::Blast::Report::Hit#target_def
--- Bio::Blast::Report::Hit#target_len

      Compatible methods with Bio::Fasta::Report::Hit class.

--- Bio::Blast::Report::Hit#evalue
--- Bio::Blast::Report::Hit#bit_score
--- Bio::Blast::Report::Hit#identity
--- Bio::Blast::Report::Hit#overlap

--- Bio::Blast::Report::Hit#query_seq
--- Bio::Blast::Report::Hit#midline
--- Bio::Blast::Report::Hit#target_seq

--- Bio::Blast::Report::Hit#query_start
--- Bio::Blast::Report::Hit#query_end
--- Bio::Blast::Report::Hit#target_start
--- Bio::Blast::Report::Hit#target_end
--- Bio::Blast::Report::Hit#lap_at

      Shortcut methods for the best Hsp, some are also compatible with
      Bio::Fasta::Report::Hit class.


== Bio::Blast::Report::Hsp

--- Bio::Blast::Report::Hsp#num
      * HSP number
--- Bio::Blast::Report::Hsp#bit_score
      * score (in bits) of HSP
--- Bio::Blast::Report::Hsp#score
      * score of HSP
--- Bio::Blast::Report::Hsp#evalue
      * e-value of HSP
--- Bio::Blast::Report::Hsp#query_from
      * start of HSP in query
--- Bio::Blast::Report::Hsp#query_to
      * end of HSP
--- Bio::Blast::Report::Hsp#hit_from
      * start of HSP in subject
--- Bio::Blast::Report::Hsp#hit_to
      * end of HSP
--- Bio::Blast::Report::Hsp#pattern_from
      * start of PHI-BLAST pattern
--- Bio::Blast::Report::Hsp#pattern_to
      * end of PHI-BLAST pattern
--- Bio::Blast::Report::Hsp#query_frame
      * translation frame of query
--- Bio::Blast::Report::Hsp#hit_frame
      * translation frame of subject
--- Bio::Blast::Report::Hsp#identity
      * number of identities in HSP
--- Bio::Blast::Report::Hsp#positive
      * number of positives in HSP
--- Bio::Blast::Report::Hsp#gaps
      * number of gaps in HSP
--- Bio::Blast::Report::Hsp#align_len
      * length of the alignment used
--- Bio::Blast::Report::Hsp#density
      * score density
--- Bio::Blast::Report::Hsp#qseq
      * alignment string for the query (with gaps)
--- Bio::Blast::Report::Hsp#hseq
      * alignment string for subject (with gaps)
--- Bio::Blast::Report::Hsp#midline
      * formating middle line

--- Bio::Blast::Report::Hsp#percent_identity
--- Bio::Blast::Report::Hsp#mismatch_count

      Available only for '-m 8' format outputs.

=end
