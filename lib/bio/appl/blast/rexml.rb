#
# bio/appl/blast/rexml.rb - BLAST XML output (-m 7) parser by REXML
# 
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: rexml.rb,v 1.6 2002/06/25 16:56:37 k Exp $
#

begin
  require 'rexml/document'
rescue LoadError
end

module Bio
  class Blast

    class Report

      def initialize(data)
	d = REXML::Document.new(data)

	@program = Program.new(d)
	query_info = [ @program.query_id, @program.query_def, @program.query_len ]

	@iterations = []
	d.elements.each("*//Iteration") do |e|
	  @iterations.push(Iteration.new(e, *query_info))
	end
      end
      attr_reader :iterations

      def method_missing(name, *args, &block)
	@program.send(name, *args, &block)	 # program, query_id etc.
      end

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
      alias :each :each_hit

      # shortcut for the last iteration's hits
      def hits
	@iterations.last.hits
      end

      # shortcut for the last iteration's statistics
      def statistics
	@iterations.last.statistics
      end

      # shortcut for the last iteration's message (for checking 'CONVERGED')
      def message
	@iterations.last.message
      end

      class Program
	def initialize(dom)
	  @program = {}
	  @parameters = {}
	  dom.root.each_element_with_text do |e|
	    name, text = e.name, e.text
	    case name
	    when 'BlastOutput_param'
	      e.elements["Parameters"].each_element_with_text do |p|
		k = p.name.sub(/Parameters_/, '')
		v = p.text =~ /\D/ ? p.text : p.text.to_i
		@parameters[k] = v
	      end
	    else
	      @program[name] = text if text.strip.size > 0
	    end
	  end
	end
	attr_reader :parameters

	def program;	@program['BlastOutput_program'];	end
	def version;	@program['BlastOutput_version'];	end
	def reference;	@program['BlastOutput_reference'];	end
	def db;		@program['BlastOutput_db'];		end
	def query_id;	@program['BlastOutput_query-ID'];	end
	def query_def;	@program['BlastOutput_query-def'];	end
	def query_len;	@program['BlastOutput_query-len'].to_i;	end
      end


      class Iteration
	def initialize(e, *args)
	  @message = nil
	  @statistics = {}
	  e.elements.each do |i|
	    case i.name
	    when 'Iteration_iter-num'
	      @num = i.text.to_i
	    when 'Iteration_hits'
	      @hits = []
	      i.elements.each("Hit") do |h|
		@hits.push(Hit.new(h, *args))
	      end
	    when 'Iteration_message'
	      @message = i.text
	    when 'Iteration_stat'
	      i.elements["*//Statistics"].each_element_with_text do |s|
		k = s.name.sub(/Statistics_/, '')
		v = s.text =~ /\D/ ? s.text.to_f : s.text.to_i
		@statistics[k] = v
	      end
	    end
	  end
	end
	attr_reader :num, :hits, :message, :statistics

	def each
	  @hits.each do |x|
	    yield x
	  end
	end
      end


      class Hit
	def initialize(e, *args)
	  @query_id, @query_def, @query_len = *args
	  @hit = {}
	  @hsps = []
	  e.elements.each do |h|
	    case h.name
	    when 'Hit_hsps'
	      h.elements.each("Hsp") do |s|
		@hsps.push(Hsp.new(s))
	      end
	    else
	      @hit[h.name] = h.text
	    end
	  end
	end
	attr_reader :hsps

	def each
	  @hsps.each do |x|
	    yield x
	  end
	end

	def num;		@hit['Hit_num'].to_i;		end
	def hit_id;		@hit['Hit_id'];			end
	def len;		@hit['Hit_len'].to_i;		end
	def definition;		@hit['Hit_def'];		end
	def accession;		@hit['Hit_accession'];		end

	# Compatible with Bio::Fasta::Report::Hit

	attr_reader :query_id, :query_def, :query_len
	alias :target_id :accession
	alias :target_def :definition
	alias :target_len :len

	# Shortcut methods for the best Hsp

	def evalue;		@hsps.first.evalue;		end
	def bit_score;		@hsps.first.bit_score;		end
	def identity;		@hsps.first.identity;		end
	def overlap;		@hsps.first.align_len;		end

	def query_seq;		@hsps.first.qseq;		end
	def target_seq;		@hsps.first.hseq;		end
	def midline;		@hsps.first.midline;		end

	def query_start;	@hsps.first.query_from;		end
	def query_end;		@hsps.first.query_to;		end
	def target_start;	@hsps.first.hit_from;		end
	def target_end;		@hsps.first.hit_to;		end
	def direction;		@hsps.first.hit_frame <=> 0;	end
	def lap_at
	  [ query_start, query_end, target_start, target_end ]
	end
      end


      class Hsp
	def initialize(e)
	  @hsp = {}
	  e.each_element_with_text do |h|
	    @hsp[h.name] = h.text
	  end
	end

	def num;		@hsp['Hsp_num'].to_i;		end
	def bit_score;		@hsp['Hsp_bit-score'].to_f;	end
	def score;		@hsp['Hsp_score'].to_i;		end
	def evalue;		@hsp['Hsp_evalue'].to_f;	end
	def query_from;		@hsp['Hsp_query-from'].to_i;	end
	def query_to;		@hsp['Hsp_query-to'].to_i;	end
	def hit_from;		@hsp['Hsp_hit-from'].to_i;	end
	def hit_to;		@hsp['Hsp_hit-to'].to_i;	end
	def pattern_from;	@hsp['Hsp_pattern-from'].to_i;	end
	def pattern_to;		@hsp['Hsp_pattern-to'].to_i;	end
	def query_frame;	@hsp['Hsp_query-frame'].to_i;	end
	def hit_frame;		@hsp['Hsp_hit-frame'].to_i;	end
	def identity;		@hsp['Hsp_identity'].to_i;	end
	def positive;		@hsp['Hsp_positive'].to_i;	end
	def gaps;		@hsp['Hsp_gaps'].to_i;		end
	def align_len;		@hsp['Hsp_align-len'].to_i;	end
	def density;		@hsp['Hsp_density'].to_i;	end
	def qseq;		@hsp['Hsp_qseq'];		end
	def hseq;		@hsp['Hsp_hseq'];		end
	def midline;		@hsp['Hsp_midline'];		end
      end

    end

  end
end


if __FILE__ == $0
#  begin
#    require 'pp'
#    alias :p :pp
#  rescue
#  end

  rep = Bio::Blast::Report.new(ARGF.read)

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

  print "# === Statistics (last iteration's)\n"
  puts
  print "  rep.statistics        #=> "; p rep.statistics
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
  print "      hit.direction     #=> "; p hit.direction
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

  end
  end
  end

end


=begin

= Bio::Blast::Report

Summerized results of the blast execution hits.

--- Bio::Blast::Report.new(xml)

      Passing a XML output from 'blastall -m 7' as a String.

--- Bio::Blast::Report#program
--- Bio::Blast::Report#version
--- Bio::Blast::Report#reference
--- Bio::Blast::Report#db
--- Bio::Blast::Report#query_id
--- Bio::Blast::Report#query_def
--- Bio::Blast::Report#query_len

      Accessors for the BlastOutput values (via method_missing sended
      to the Bio::Blast::Report::Program object internally).

--- Bio::Blast::Report#parameters

      Returns a Hash containing execution parameters.
      Valid keys are:
        'expect', 'include', 'sc-match', 'sc-mismatch', 'gap-open',
        'gap-extend', 'filter'

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
        'db-len', 'db-num', 'eff-space', 'entropy', 'hsp-len',
        'kappa', 'lambda'

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
--- Bio::Blast::Report::Hit#hit_id
--- Bio::Blast::Report::Hit#len
--- Bio::Blast::Report::Hit#definition
--- Bio::Blast::Report::Hit#accession

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
--- Bio::Blast::Report::Hit#direction
--- Bio::Blast::Report::Hit#lap_at

      Shortcut methods for the best Hsp, some are also compatible with
      Bio::Fasta::Report::Hit class.


== Bio::Blast::Report::Hsp

--- Bio::Blast::Report::Hsp#num
--- Bio::Blast::Report::Hsp#bit_score
--- Bio::Blast::Report::Hsp#score
--- Bio::Blast::Report::Hsp#evalue
--- Bio::Blast::Report::Hsp#query_from
--- Bio::Blast::Report::Hsp#query_to
--- Bio::Blast::Report::Hsp#hit_from
--- Bio::Blast::Report::Hsp#hit_to
--- Bio::Blast::Report::Hsp#pattern_from
--- Bio::Blast::Report::Hsp#pattern_to
--- Bio::Blast::Report::Hsp#query_frame
--- Bio::Blast::Report::Hsp#hit_frame
--- Bio::Blast::Report::Hsp#identity
--- Bio::Blast::Report::Hsp#positive
--- Bio::Blast::Report::Hsp#gaps
--- Bio::Blast::Report::Hsp#align_len
--- Bio::Blast::Report::Hsp#density
--- Bio::Blast::Report::Hsp#qseq
--- Bio::Blast::Report::Hsp#hseq
--- Bio::Blast::Report::Hsp#midline

=end
