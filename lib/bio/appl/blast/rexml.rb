#
# = bio/appl/blast/rexml.rb - BLAST XML output (-m 7) parser by REXML
# 
# Copyright::  Copyright (C) 2002, 2003 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id: rexml.rb,v 1.12.2.1 2008/05/12 13:19:32 ngoto Exp $
#
# == Note
# 
# This file is automatically loaded by bio/appl/blast/report.rb
# 

begin
  require 'rexml/document'
rescue LoadError
end

module Bio
  class Blast
    class Report

      private

      def rexml_parse(xml)
        dom = REXML::Document.new(xml)
        rexml_parse_program(dom)
        dom.elements.each("*//Iteration") do |e|
          @iterations.push(rexml_parse_iteration(e))
        end
      end

      def rexml_parse_program(dom)
        hash = {}
        dom.root.each_element_with_text do |e|
          name, text = e.name, e.text
          case name
          when 'BlastOutput_param'
            e.elements["Parameters"].each_element_with_text do |p|
              xml_set_parameter(p.name, p.text)
            end
          else
            hash[name] = text if text.strip.size > 0
          end
        end
        @program	= hash['BlastOutput_program']
        @version	= hash['BlastOutput_version']
        @reference	= hash['BlastOutput_reference']
        @db		= hash['BlastOutput_db']
        @query_id	= hash['BlastOutput_query-ID']
        @query_def	= hash['BlastOutput_query-def']
        @query_len	= hash['BlastOutput_query-len'].to_i
      end

      def rexml_parse_iteration(e)
        iteration = Iteration.new
        e.elements.each do |i|
          case i.name
          when 'Iteration_iter-num'
            iteration.num = i.text.to_i
          when 'Iteration_hits'
            i.elements.each("Hit") do |h|
              iteration.hits.push(rexml_parse_hit(h))
            end
          when 'Iteration_message'
            iteration.message = i.text
          when 'Iteration_stat'
            i.elements["Statistics"].each_element_with_text do |s|
              k = s.name.sub(/Statistics_/, '')
              v = s.text =~ /\D/ ? s.text.to_f : s.text.to_i
              iteration.statistics[k] = v
            end
          end
        end
        return iteration
      end

      def rexml_parse_hit(e)
        hit = Hit.new
        hash = {}
        hit.query_id = @query_id
        hit.query_def = @query_def
        hit.query_len = @query_len
        e.elements.each do |h|
          case h.name
          when 'Hit_hsps'
            h.elements.each("Hsp") do |s|
              hit.hsps.push(rexml_parse_hsp(s))
            end
          else
            hash[h.name] = h.text
          end
        end
        hit.num		= hash['Hit_num'].to_i
        hit.hit_id	= hash['Hit_id']
        hit.len		= hash['Hit_len'].to_i
        hit.definition	= hash['Hit_def']
        hit.accession	= hash['Hit_accession']
        return hit
      end

      def rexml_parse_hsp(e)
        hsp = Hsp.new
        hash = {}
        e.each_element_with_text do |h|
          hash[h.name] = h.text
        end
        hsp.num			= hash['Hsp_num'].to_i
        hsp.bit_score		= hash['Hsp_bit-score'].to_f
        hsp.score		= hash['Hsp_score'].to_i
        hsp.evalue		= hash['Hsp_evalue'].to_f
        hsp.query_from		= hash['Hsp_query-from'].to_i
        hsp.query_to		= hash['Hsp_query-to'].to_i
        hsp.hit_from		= hash['Hsp_hit-from'].to_i
        hsp.hit_to		= hash['Hsp_hit-to'].to_i
        hsp.pattern_from	= hash['Hsp_pattern-from'].to_i
        hsp.pattern_to		= hash['Hsp_pattern-to'].to_i
        hsp.query_frame		= hash['Hsp_query-frame'].to_i
        hsp.hit_frame		= hash['Hsp_hit-frame'].to_i
        hsp.identity		= hash['Hsp_identity'].to_i
        hsp.positive		= hash['Hsp_positive'].to_i
        hsp.gaps		= hash['Hsp_gaps'].to_i
        hsp.align_len		= hash['Hsp_align-len'].to_i
        hsp.density		= hash['Hsp_density'].to_i
        hsp.qseq		= hash['Hsp_qseq']
        hsp.hseq		= hash['Hsp_hseq']
        hsp.midline		= hash['Hsp_midline']
        return hsp
      end

    end
  end
end


