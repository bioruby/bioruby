#
# bio/appl/blast/format8.rb - BLAST tab-delimited output (-m 8) parser
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
#  $Id: format8.rb,v 1.3 2002/06/25 09:28:07 k Exp $
#

module Bio
  class Blast

    class Report

      def initialize(data)
	@hits = Array.new

	hit = Hit.new
	target_prev = ''

	data.each do |line|
	  ary = line.chomp.split("\t")
	  hsp = Hsp.new(ary)

	  if target_prev != hsp.target_id
	    @hits.push(hit) unless hit.hsps.empty?
	    hit = Hit.new
	  end
	  hit.hsps.push(hsp)
	  target_prev = hsp.target_id
	end
	@hits.push(hit)
      end
      attr_reader :hits

      def each
	@hits.each do |x|
	  yield x
	end
      end


      class Hit
	def initialize(ary = Array.new)
	  @hsps = ary
	end
	attr_reader :hsps

	def each
	  @hsps.each do |x|
	    yield x
	  end
	end

	# Access methods for the best Hsp

	def evalue
	  @hsps[0].evalue
	end

	def bit_score
	  @hsps[0].bit_score
	end

	def identity
	  @hsps[0].identity
	end

	def overlap
	  @hsps[0].overlap
	end

	def query_id
	  @hsps[0].query_id
	end

	def target_id
	  @hsps[0].target_id
	end

#	def query_len;	end
#	def target_len;	end

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
	def initialize(ary)
	  @query_id, @target_id, @identity, @align_len,
	    @mismatch, @gap_open,
	    @query_start, @query_end, @target_start, @target_end,
	    @evalue, @bit_score = *ary
	end
	attr_reader :query_id, :target_id

	def evalue
	  @evalue.strip.to_f
	end

	def bit_score
	  @bit_score.to_f
	end

	def identity
	  @identity.to_f
	end

	def overlap
	  @align_len.to_i
	end

	def mismatch
	  @mismatch.to_i
	end

	def gap_open
	  @gap_open.to_i
	end

	def query_start
	  @query_start.to_i
	end

	def query_end
	  @query_end.to_i
	end

	def target_start
	  @target_start.to_i
	end

	def target_end
	  @target_end.to_i
	end

	def lap_at
	  [ query_start, query_end, target_start, target_end ]
	end

	def direction
	  target_end <=> target_start
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
  p rep

  best = rep.hits[0]
  p best.query_id
  p best.target_id
  p best.evalue
  p best.bit_score
  p best.identity
  p best.overlap
  p best.query_start
  p best.query_end
  p best.target_start
  p best.target_end
  p best.lap_at
  p best.direction

  second_hsp = best.hsps[1]
  p second_hsp.query_id
  p second_hsp.target_id
  p second_hsp.evalue
  p second_hsp.bit_score
  p second_hsp.identity
  p second_hsp.overlap
  p second_hsp.mismatch
  p second_hsp.gap_open
  p second_hsp.query_start
  p second_hsp.query_end
  p second_hsp.target_start
  p second_hsp.target_end
  p second_hsp.lap_at
  p second_hsp.direction
end


=begin

= Bio::Blast::Report

Summerized results of the blast execution hits.

Tab delimited reports consists of 

  Query id, Subject id, percent of identity, alignment length, number of
  mismatches (not including gaps), number of gap openings, start of
  alignment in query, end of alignment in query, start of alignment in
  subject, end of alignment in subject, expected value, bit score.

according to the MEGABLAST document (README.mbl).

--- Bio::Blast::Report.new(data)
--- Bio::Blast::Report#each

      Iterates on each Bio::Blast::Report::Hit object.

--- Bio::Blast::Report#hits

      Returns an Array of Bio::Blast::Report::Hit objects.


== Bio::Blast::Report::Hit

--- Bio::Blast::Report::Hit#each

      Iterates on each Hsp object.

--- Bio::Blast::Report::Hit#hsps

      Returns an Array of Bio::Blast::Report::Hsp objects.

--- Bio::Blast::Report::Hit#query_id
--- Bio::Blast::Report::Hit#target_id

      Matching subjects.

--- Bio::Blast::Report::Hit#evalue
--- Bio::Blast::Report::Hit#bit_score
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


== Bio::Blast::Report::Hsp

--- Bio::Blast::Report::Hsp#query_id
--- Bio::Blast::Report::Hsp#target_id

      Matching subjects.

--- Bio::Blast::Report::Hsp#evalue
--- Bio::Blast::Report::Hsp#bit_score
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

--- Bio::Blast::Report::Hsp#mismatch
--- Bio::Blast::Report::Hsp#gap_open

      Accessors for the other values.

=end
