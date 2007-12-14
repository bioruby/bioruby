#
# = bio/appl/blast/format8.rb - BLAST tab-delimited output (-m 8) parser
# 
# Copyright::  Copyright (C) 2002, 2003, 2007 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: format8.rb,v 1.8 2007/12/14 16:15:20 k Exp $
#
# == Note
#
# This file is automatically loaded by bio/appl/blast/report.rb
#

module Bio
  class Blast
    class Report

      private

      def tab_parse(data)
        iteration = Iteration.new
        @iterations.push(iteration)
        @query_id = @query_def = data[/\S+/]

        query_prev = ''
        target_prev = ''
        hit_num = 1
        hsp_num = 1
        hit = ''
        data.each do |line|
          ary = line.chomp.split("\t")
          query_id, target_id, hsp = tab_parse_hsp(ary)
          if query_prev != query_id or target_prev != target_id
            hit = Hit.new
            hit.num = hit_num
            hit_num += 1
            hit.query_id = hit.query_def = query_id
            hit.accession = hit.definition = target_id
            iteration.hits.push(hit)
            hsp_num = 1
          end
          hsp.num = hsp_num
          hsp_num += 1
          hit.hsps.push(hsp)
          query_prev = query_id
          target_prev = target_id
        end
      end

      def tab_parse_hsp(ary)
        query_id, target_id,
          percent_identity,
          align_len,
          mismatch_count,
          gaps,
          query_from,
          query_to,
          hit_from,
          hit_to,
          evalue,
          bit_score = *ary

        hsp = Hsp.new
        hsp.align_len		= align_len.to_i
        hsp.gaps		= gaps.to_i
        hsp.query_from		= query_from.to_i
        hsp.query_to		= query_to.to_i
        hsp.hit_from		= hit_from.to_i
        hsp.hit_to		= hit_to.to_i
        hsp.evalue		= evalue.strip.to_f
        hsp.bit_score		= bit_score.to_f

        hsp.percent_identity	= percent_identity.to_f
        hsp.mismatch_count	= mismatch_count.to_i

        return query_id, target_id, hsp
      end

    end
  end
end


