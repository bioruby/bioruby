#
# = bio/appl/blast/xmlparser.rb - BLAST XML output (-m 7) parser by XMLParser
# 
# Copyright::  Copyright (C) 2001 
#              Mitsuteru C. Nakao <n@bioruby.org>
# Copyright::  Copyright (C) 2003 
#              Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#
# == Description
# 
# A parser for blast XML report (format 7) based on the XMLParser.
# This file is automatically loaded by bio/appl/blast/report.rb if
# the XMLParser installed.
#
# BioRuby provides two implements of the paser for the blast XML format report
# (format 7) based on the XMLParser and the REXML.
#

begin
  require 'xmlparser'
rescue LoadError
end

module Bio
class Blast
  class Report

    private

    def xmlparser_parse(xml)
      parser = XMLParser.new
      def parser.default; end
       
      begin
        tag_stack = Array.new
        hash = Hash.new

        parser.parse(xml) do |type, name, data|
          case type
          when XMLParser::START_ELEM
            tag_stack.push(name)
            hash.update(data)
            case name
            when 'Iteration'
              iteration = Iteration.new
              @iterations.push(iteration)
            when 'Hit'
              hit = Hit.new
              hit.query_id = @query_id
              hit.query_def = @query_def
              hit.query_len = @query_len
              @iterations.last.hits.push(hit)
            when 'Hsp'
              hsp = Hsp.new
              @iterations.last.hits.last.hsps.push(hsp)
            end
          when XMLParser::END_ELEM
            case name
            when /^BlastOutput/
              xmlparser_parse_program(name,hash)
              hash = Hash.new
            when /^Parameters$/
              xmlparser_parse_parameters(hash)
              hash = Hash.new
            when /^Iteration/
              xmlparser_parse_iteration(name, hash)
              hash = Hash.new
            when /^Hit/
              xmlparser_parse_hit(name, hash)
              hash = Hash.new
            when /^Hsp$/
              xmlparser_parse_hsp(hash)
              hash = Hash.new
            when /^Statistics$/
              xmlparser_parse_statistics(hash)
              hash = Hash.new
            end
            tag_stack.pop
          when XMLParser::CDATA
            if hash[tag_stack.last].nil?
              hash[tag_stack.last] = data unless data.strip.empty?
            else
              hash[tag_stack.last].concat(data) if data
            end
          when XMLParser::PI
          end
        end
      rescue XMLParserError
        line = parser.line
        column = parser.column
        print "Parse error at #{line}(#{column}) : #{$!}\n"
      end
    end


    def xmlparser_parse_program(tag, hash)
      case tag
      when 'BlastOutput_program'
        @program = hash[tag]
      when 'BlastOutput_version'
        @version = hash[tag]
      when 'BlastOutput_reference'
        @reference = hash[tag]
      when 'BlastOutput_db'
        @db = hash[tag].strip
      when 'BlastOutput_query-ID'
        @query_id = hash[tag]
      when 'BlastOutput_query-def'
        @query_def = hash[tag]
      when 'BlastOutput_query-len'
        @query_len = hash[tag].to_i
      end
    end

    # set parameter of the key as val
    def xml_set_parameter(key, val)
      #labels = { 
      #  'matrix'       => 'Parameters_matrix',
      #  'expect'       => 'Parameters_expect',
      #  'include'      => 'Parameters_include',
      #  'sc-match'     => 'Parameters_sc-match',
      #  'sc-mismatch'  => 'Parameters_sc-mismatch',
      #  'gap-open'     => 'Parameters_gap-open',
      #  'gap-extend'   => 'Parameters_gap-extend',
      #  'filter'       => 'Parameters_filter',
      #  'pattern'      => 'Parameters_pattern',
      #  'entrez-query' => 'Parameters_entrez-query',
      #}
      k = key.sub(/\AParameters\_/, '')
      @parameters[k] =
        case k
        when 'expect', 'include'
          val.to_f
        when /\Agap\-/, /\Asc\-/
          val.to_i
        else
          val
        end
    end

    def xmlparser_parse_parameters(hash)
      hash.each do |k, v|
        xml_set_parameter(k, v)
      end
    end

    def xmlparser_parse_iteration(tag, hash)
      case tag
      when 'Iteration_iter-num'
        @iterations.last.num = hash[tag].to_i
      when 'Iteration_message'
        @iterations.last.message = hash[tag].to_s

        # for new BLAST XML format
      when 'Iteration_query-ID'
        @iterations.last.query_id = hash[tag].to_s
      when 'Iteration_query-def'
        @iterations.last.query_def = hash[tag].to_s
      when 'Iteration_query-len'
        @iterations.last.query_len = hash[tag].to_i
      end
    end

    def xmlparser_parse_hit(tag, hash)
      hit = @iterations.last.hits.last
      case tag
      when 'Hit_num'
        hit.num = hash[tag].to_i
      when 'Hit_id'
        hit.hit_id = hash[tag].clone
      when 'Hit_def'
        hit.definition = hash[tag].clone
      when 'Hit_accession'
        hit.accession = hash[tag].clone
      when 'Hit_len'
        hit.len = hash[tag].clone.to_i
      end
    end

    def xmlparser_parse_hsp(hash)
      hsp = @iterations.last.hits.last.hsps.last
      hsp.num          = hash['Hsp_num'].to_i
      hsp.bit_score    = hash['Hsp_bit-score'].to_f
      hsp.score        = hash['Hsp_score'].to_i
      hsp.evalue       = hash['Hsp_evalue'].to_f
      hsp.query_from   = hash['Hsp_query-from'].to_i
      hsp.query_to     = hash['Hsp_query-to'].to_i
      hsp.hit_from     = hash['Hsp_hit-from'].to_i
      hsp.hit_to       = hash['Hsp_hit-to'].to_i
      hsp.pattern_from = hash['Hsp_pattern-from'].to_i
      hsp.pattern_to   = hash['Hsp_pattern-to'].to_i
      hsp.query_frame  = hash['Hsp_query-frame'].to_i
      hsp.hit_frame    = hash['Hsp_hit-frame'].to_i
      hsp.identity     = hash['Hsp_identity'].to_i
      hsp.positive     = hash['Hsp_positive'].to_i
      hsp.gaps         = hash['Hsp_gaps'].to_i
      hsp.align_len    = hash['Hsp_align-len'].to_i
      hsp.density      = hash['Hsp_density'].to_i
      hsp.qseq         = hash['Hsp_qseq']
      hsp.hseq         = hash['Hsp_hseq']
      hsp.midline      = hash['Hsp_midline']
    end

    def xmlparser_parse_statistics(hash)
      labels = {
        'db-num'	=> 'Statistics_db-num',
        'db-len'	=> 'Statistics_db-len',
        'hsp-len'	=> 'Statistics_hsp-len',
        'eff-space'	=> 'Statistics_eff-space',
        'kappa'	=> 'Statistics_kappa',
        'lambda'	=> 'Statistics_lambda',
        'entropy'	=> 'Statistics_entropy'
      }
      labels.each do |k,v|
        case k
        when 'db-num', 'db-len', 'hsp-len'
          @iterations.last.statistics[k] = hash[v].to_i
        else
          @iterations.last.statistics[k] = hash[v].to_f
        end
      end
    end
        
  end # class Report
end # class Blast
end # module Bio


=begin

This file is automatically loaded by bio/appl/blast/report.rb

=end
