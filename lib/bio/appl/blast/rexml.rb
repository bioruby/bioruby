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
#  $Id: rexml.rb,v 1.1 2002/05/28 14:49:06 k Exp $
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
	@iterations = []

	d.elements.each("/BlastOutput/BlastOutput_iterations/Iteration") do |e|
	  @iterations.push(Iteration.new(e))
	end
      end
      attr_reader :program, :iterations

      def each_iteration
	@iterations.each do |x|
	  yield x
	end
      end

      # shortcut for @iterations[0]
      def each
	@iterations[0].each do |x|
	  yield x
	end
      end


      class Program
	def initialize(dom)
	  @program = {}
	  dom.elements["/BlastOutput"].each_element_with_text do |e|
	    name, text = e.name, e.text
	    case name
	    when 'BlastOutput_param'
	      e.elements["Parameters"].each_element_with_text do |p|
		@program[p.name] = p.text
	      end
	    else
	      @program[name] = text if text.strip.size > 0
	    end
	  end
	end
	attr_reader :program
      
	def version;	@program['BlastOutput_version'];		end
	def reference;	@program['BlastOutput_reference'];		end
	def db;		@program['BlastOutput_db'];			end
	def query_id;	@program['BlastOutput_query-ID'];		end
	def query_def;	@program['BlastOutput_query-def'];		end
	def query_len;	@program['BlastOutput_query-len'].to_i;		end
	def expect;	@program['Parameters_expect'].to_i;		end
	def include;	@program['Parameters_include'].to_i;		end
	def match;	@program['Parameters_sc-match'].to_i;		end
	def mismatch;	@program['Parameters_sc-mismatch'].to_i;	end
	def gap_open;	@program['Parameters_gap-open'].to_i;		end
	def gap_extend;	@program['Parameters_gap-extend'].to_i;		end
	def filter;	@program['Parameters_filter'];			end
      end


      class Iteration
	def initialize(e)
	  e.elements.each do |i|
	    case i.name
	    when 'Iteration_iter-num'
	      @num = i.text.to_i
	    when 'Iteration_stat'
	      @stat = {}
	      i.elements["Statistics"].each_element_with_text do |s|
		@stat[s.name] = s.text
	      end
	    when 'Iteration_hits'
	      @hits = []
	      i.elements.each("Hit") do |h|
		@hits.push(Hit.new(h))
	      end
	    end
	  end
	end
	attr_reader :num, :hits

	def each
	  @hits.each do |x|
	    yield x
	  end
	end

	def db_len;	@stat['Statistics_db-len'].to_i;	end
	def db_num;	@stat['Statistics_db-num'].to_i;	end
	def eff_space;	@stat['Statistics_eff-space'].to_f;	end
	def entropy;	@stat['Statistics_entropy'].to_f;	end
	def hsp_len;	@stat['Statistics_hsp-len'].to_i;	end
	def kappa;	@stat['Statistics_kappa'].to_f;		end
	def lambda;	@stat['Statistics_lambda'].to_f;	end
      end


      class Hit
	def initialize(e)
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
	def hit_def;		@hit['Hit_def'];		end
	def hit_accession;	@hit['Hit_accession'];		end
	def hit_len;		@hit['Hit_len'].to_i;		end

	# Access methods for the best Hsp

	def evalue
	  @hsps[0].evalue
	end

	def bit
	  @hsps[0].bit
	end

	def identity
	  @hsps[0].identity
	end

	def overlap
	  @hsps[0].overlap
	end

#	def query_id
#	  # BlastOutput_query-def
#	end

	def target_id
	  hit_accession
	end

#	def query_len
#	  # BlastOutput_query-len
#	end

	def target_len
	  hit_len
	end

	def query_start
	  @hsps[0].query_start
	end

	def query_end
	  @hsps[0].query_end
	end

	def target_start
	  @hsps[0].target_start
	end

	def target_end
	  @hsps[0].target_end
	end

	def lap_at
	  @hsps[0].lap_at
	end

	def direction
	  @hsps[0].direction
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
	def bit;		@hsp['Hsp_bit-score'].to_f;	end
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

	alias :overlap :align_len
	alias :query_start :query_from
	alias :query_end :query_to
	alias :target_start :hit_from
	alias :target_end :hit_to

	def lap_at
	  [ query_start, query_end, target_start, target_end ]
	end

	def direction
	  hit_frame <=> 0
	end
      end

    end

  end
end


if __FILE__ == $0
  begin
    require 'pp'
    alias :p :pp
  rescue
  end

  rep = Bio::Blast::Report.new(ARGF.read)
  rep.
  rep.each do |x|
    p x
  end
end


=begin

= Bio::Blast::Report

Summerized results of the blast execution hits.

--- Bio::Blast::Report.new(data)
--- Bio::Blast::Report#iterations

      Returns an Array of Bio::Blast::Report::Iteration objects.

--- Bio::Blast::Report#each_iteration

      Iterates on each Bio::Blast::Report::Iteration object.

--- Bio::Blast::Report#each

      Iterates on each Bio::Blast::Report::Hit object (first Iteration).


== Bio::Blast::Report::Program

--- Bio::Blast::Report::Program#program

      Accessor for the internal structure.

--- Bio::Blast::Report::Program#version
--- Bio::Blast::Report::Program#reference
--- Bio::Blast::Report::Program#db
--- Bio::Blast::Report::Program#query_id
--- Bio::Blast::Report::Program#query_def
--- Bio::Blast::Report::Program#query_len

      Accessors for the BlastOutput values.

--- Bio::Blast::Report::Program#expect
--- Bio::Blast::Report::Program#include
--- Bio::Blast::Report::Program#match
--- Bio::Blast::Report::Program#mismatch
--- Bio::Blast::Report::Program#gap_open
--- Bio::Blast::Report::Program#gap_extend
--- Bio::Blast::Report::Program#filter

      Accessors for the Parameters values.


== Bio::Blast::Report::Iteration

--- Bio::Blast::Report::Iteration#num

      Returns the number of iteration counts.

--- Bio::Blast::Report::Iteration#hits

      Returns an Array of Bio::Blast::Report::Hit objects.

--- Bio::Blast::Report::Iteration#each

      Iterates on each Bio::Blast::Report::Hit object.

--- Bio::Blast::Report::Iteration#db_len
--- Bio::Blast::Report::Iteration#db_num
--- Bio::Blast::Report::Iteration#eff_space
--- Bio::Blast::Report::Iteration#entropy
--- Bio::Blast::Report::Iteration#hsp_len
--- Bio::Blast::Report::Iteration#kappa
--- Bio::Blast::Report::Iteration#lambda

      Accessors for the Statistics values.


== Bio::Blast::Report::Hit

--- Bio::Blast::Report::Hit#each

      Iterates on each Hsp object.

--- Bio::Blast::Report::Hit#hsps

      Returns an Array of Bio::Blast::Report::Hsp objects.

#--- Bio::Blast::Report::Hit#query_id
#--- Bio::Blast::Report::Hit#query_len
--- Bio::Blast::Report::Hit#target_id
--- Bio::Blast::Report::Hit#target_len

      Matching subjects.

--- Bio::Blast::Report::Hit#evalue
--- Bio::Blast::Report::Hit#bit
--- Bio::Blast::Report::Hit#identity

      Matching scores (best Hsp's).

--- Bio::Blast::Report::Hit#query_start
--- Bio::Blast::Report::Hit#query_end
--- Bio::Blast::Report::Hit#target_start
--- Bio::Blast::Report::Hit#target_end
--- Bio::Blast::Report::Hit#overlap
--- Bio::Blast::Report::Hit#lap_at
--- Bio::Blast::Report::Hit#direction

      Matching regions (best Hsp's).

--- Bio::Blast::Report::Hit#num
--- Bio::Blast::Report::Hit#hit_id
--- Bio::Blast::Report::Hit#hit_def
--- Bio::Blast::Report::Hit#hit_accession
--- Bio::Blast::Report::Hit#hit_len

      Accessors for the Hit values.


== Bio::Blast::Report::Hsp

--- Bio::Blast::Report::Hsp#evalue
--- Bio::Blast::Report::Hsp#bit
--- Bio::Blast::Report::Hsp#identity

      Matching scores.

--- Bio::Blast::Report::Hsp#query_start
--- Bio::Blast::Report::Hsp#query_end
--- Bio::Blast::Report::Hsp#target_start
--- Bio::Blast::Report::Hsp#target_end
--- Bio::Blast::Report::Hsp#overlap
--- Bio::Blast::Report::Hsp#lap_at
--- Bio::Blast::Report::Hsp#direction

      Matching regions.

--- Bio::Blast::Report::Hsp#num
--- Bio::Blast::Report::Hsp#score
--- Bio::Blast::Report::Hsp#query_from
--- Bio::Blast::Report::Hsp#query_to
--- Bio::Blast::Report::Hsp#hit_from
--- Bio::Blast::Report::Hsp#hit_to
--- Bio::Blast::Report::Hsp#pattern_from
--- Bio::Blast::Report::Hsp#pattern_to
--- Bio::Blast::Report::Hsp#query_frame
--- Bio::Blast::Report::Hsp#hit_frame
--- Bio::Blast::Report::Hsp#positive
--- Bio::Blast::Report::Hsp#gaps
--- Bio::Blast::Report::Hsp#align_len
--- Bio::Blast::Report::Hsp#density
--- Bio::Blast::Report::Hsp#qseq
--- Bio::Blast::Report::Hsp#hseq
--- Bio::Blast::Report::Hsp#midline

      Accessors for the Hsp values.

=end
