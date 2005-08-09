#
# bio/appl/hmmer/report.rb - hmmsearch, hmmpfam parser
#
#   Copyright (C) 2002 Hiroshi Suga <suga@biophys.kyoto-u.ac.jp>
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
#  $Id: report.rb,v 1.5 2005/08/09 09:58:19 k Exp $
#

module Bio
  class HMMER
    class Report

      def initialize(data)
        # HMM and sequence profiles
        data.sub!(/(.+ -$\n)(.+ -$\n)\n(.+?\n\n)Scores/m, '')

        @program = parse_program($1)
        @parameter = parse_parameter($2)
        @query_info =parse_query_info($3)

	case @program['name']
	when /hmmsearch/
	  is_hmmsearch = true
	else
	  is_hmmsearch = false		# hmmpfam
	end

        # Scores for complete sequences. (parsed to Hit objects)
        data.sub!(/.+-$\n(.+?)\n\nParsed/m, '')
        @hits = []
        $1.each do |l|
          @hits.push(Hit.new(l))
        end

        # Scores for domains. (parsed to Hsp objects)
        data.sub!(/.+-$\n(.+?)\n\nAlignments of top-scoring domains:\n/m, '')
        hsps=[]
        $1.each do |l|
          hsps.push(Hsp.new(l,is_hmmsearch))
        end

        # Alignments
        if is_hmmsearch
          data.sub!(/(.+?)\n\n\nHistogram of all scores:\n/m, '')
        else
          data.sub!(/(.+?)\n\n\/\//m, '')
        end
        $1.split(/^\S+.*?\n/).slice(1..-1).each_with_index do |al,k|
          al2 = al.gsub(/\n\n/,"\n").to_s.collect { |l|
	    l.sub(/^.{19}/,'').sub(/\s(\d+|-)\s*$/,'')
	  }
          align = ['', '', '']
          al2.each_with_index { |s,i| align[i%3] += s.chomp }
          align.each { |a| a.sub!(/^.{3}(.*).{3}$/, '\1') }
          hsps[k].hmmseq  << align[0]
          hsps[k].midline << align[1]
          hsps[k].flatseq << align[2]
        end
        hsps.each do |s|
          @hits.each do |h|
            if h.accession == s.accession
              h.hsps.push(s)
              next
            end
          end
        end
        if is_hmmsearch
          data.sub!(/(.+?)\n\n\n%/m, '')
          @histogram = $1

          @statistical_detail = {}
          data.sub!(/(.+?)\n\n/m, '')
          $1.each do |l|
            @statistical_detail[$1] = $2.to_f if /^\s*(.+)\s*=\s*(\S+)/ =~ l
          end

          @total_seq_searched = nil
          data.sub!(/(.+?)\n\n/m, '')
          $1.each do |l|
            @total_seq_searched = $2.to_i if /^\s*(.+)\s*:\s*(\S+)/ =~ l
          end

          @whole_seq_top_hits = {}
          data.sub!(/(.+?)\n\n/m, '')
          $1.each do |l|
            @whole_seq_top_hits[$1] = $2.to_i if /^\s*(.+)\s*:\s*(\S+)/ =~ l
          end

          @domain_top_hits = {}
          data.each do |l|
            @domain_top_hits[$1] = $2.to_i if /^\s*(.+)\s*:\s*(\S+)/ =~ l
          end
        end
      end
      attr_reader :program, :parameter, :query_info, :hits,
	:histogram, :statistical_detail, :total_seq_searched,
	:whole_seq_top_hits, :domain_top_hits 

      def each
	@hits.each do |x|
	  yield x
	end
      end


      class Hsp
        def initialize(data, is_hmmsearch)
          @is_hmmsearch = is_hmmsearch

	  @accession, @domain, seq_f, seq_t, @seq_ft, hmm_f, hmm_t, @hmm_ft,
	    score, evalue = data.split(' ')
          @seq_f = seq_f.to_i
          @seq_t = seq_t.to_i
          @hmm_f = hmm_f.to_i
          @hmm_t = hmm_t.to_i
          @score = score.to_f
          @evalue = evalue.to_f
          @hmmseq = ''
          @flatseq = ''
          @midline = ''
          @query_frame = 1
          @target_frame = 1
        end
        attr_accessor :accession, :domain, :seq_f, :seq_t, :seq_ft,
	  :hmm_f, :hmm_t, :hmm_ft, :score, :evalue, :midline, :hmmseq,
	  :flatseq, :query_frame, :target_frame

        def query_seq
          if @is_hmmsearch; @hmmseq else; @flatseq end
        end

        def target_seq
          if @is_hmmsearch; @flatseq else; @hmmseq end
        end

        def target_from
          if @is_hmmsearch; @seq_f else; @hmm_f end
        end

        def target_to
          if @is_hmmsearch; @seq_t else; @hmm_t end
        end

        def query_from
          if @is_hmmsearch; @hmm_f else; @seq_f end
        end

        def query_to
          if @is_hmmsearch; @hmm_t else; @seq_t end
        end

        def bit_score;	 @score;	end
        def target_id;	 @accession;	end
      end


      class Hit
        def initialize(data)
          @hsps = Array.new
          if /^(\S+)\s+(.*)\s+(\S+)\s+(\S+)\s+(\S+)$/ =~ data
            @accession, @description, @score, @evalue, @num = 
	      [$1, $2, $3.to_f, $4.to_f, $5.to_i]
          end
        end
        attr_accessor :hsps, :accession, :description, :score, :evalue, :num

        def each
          @hsps.each do |x|
            yield x
          end
        end

        def target_id;	@accession;	end
        def hit_id;	@accession;	end
        def entry_id;	@accession;	end
        def definition;	@description;	end
        def bit_score;	@score;		end

        def target_def
          if @hsps.size == 1
            "<#{@hsps[0].domain}> #{@description}"
          else
            "<#{@num.to_s}> #{@description}"
          end
        end
      end


      private

      def parse_program(data)
        hash = {}
        hash['name'], hash['version'], hash['copyright'], hash['license'] =
	  data.split(/\n/)
        hash
      end

      def parse_parameter(data)
        hash = {}
        data.each do |x|
          if /(.+):\s+(.*)/ =~ x
            hash[$1] = $2
          end
        end
        hash
      end

      def parse_query_info(data)
        hash = {}
        data.each do |x|
          if /(.+):\s+(.*)/ =~ x
            hash[$1] = $2
          elsif /\s+\[(.+)\]/ =~ x
            hash['comments'] = $1
          end
        end
        hash
      end

    end

  end
end


if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp
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

end


=begin

= Bio::HMMER::Report

--- Bio::HMMER::Report.new(data)
--- Bio::HMMER::Report#each

      Iterates on each Bio::HMMER::Report::Hit object.

--- Bio::HMMER::Report#hits

      Returns an Array of Bio::HMMER::Report::Hit objects.


== Bio::HMMER::Report::Hit

--- Bio::HMMER::Report::Hit#each

      Iterates on each Hsp object.

--- Bio::HMMER::Report::Hit#hsps

      Returns an Array of Bio::HMMER::Report::Hsp objects.

--- Bio::HMMER::Report::Hit#target_id
--- Bio::HMMER::Report::Hit#hit_id
--- Bio::HMMER::Report::Hit#entry_id
--- Bio::HMMER::Report::Hit#definition
--- Bio::HMMER::Report::Hit#description
--- Bio::HMMER::Report::Hit#num

      nunmer of domains

--- Bio::HMMER::Report::Hit#target_def

      <domain number> + @description

--- Bio::HMMER::Report::Hit#evalue
--- Bio::HMMER::Report::Hit#bit_score
--- Bio::HMMER::Report::Hit#score

      Matching scores (total of all HSPs).


== Bio::HMMER::Report::Hsp

--- Bio::HMMER::Report::Hsp#target_id
--- Bio::HMMER::Report::Hsp#accession
--- Bio::HMMER::Report::Hsp#domain
--- Bio::HMMER::Report::Hsp#seq_f
--- Bio::HMMER::Report::Hsp#seq_t
--- Bio::HMMER::Report::Hsp#seq_ft
--- Bio::HMMER::Report::Hsp#hmm_f
--- Bio::HMMER::Report::Hsp#hmm_t
--- Bio::HMMER::Report::Hsp#hmm_ft

--- Bio::HMMER::Report::Hsp#bit_score
--- Bio::HMMER::Report::Hsp#score
--- Bio::HMMER::Report::Hsp#evalue

--- Bio::HMMER::Report::Hsp#midline
--- Bio::HMMER::Report::Hsp#hmmseq
--- Bio::HMMER::Report::Hsp#flatseq
--- Bio::HMMER::Report::Hsp#query_frame
--- Bio::HMMER::Report::Hsp#target_frame

--- Bio::HMMER::Report::Hsp#query_seq
--- Bio::HMMER::Report::Hsp#query_from
--- Bio::HMMER::Report::Hsp#query_to
--- Bio::HMMER::Report::Hsp#target_seq
--- Bio::HMMER::Report::Hsp#target_from
--- Bio::HMMER::Report::Hsp#target_to

=end

