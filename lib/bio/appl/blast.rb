#
# bio/appl/blast.rb - NCBI_BlastOutput.dtd XML Blast Report Parser
# 
#   Copyright (C) 2001 Mitsuteru S. Nakao <n@bioruby.org>
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
#  $Id: blast.rb,v 1.2 2001/11/12 20:53:50 katayama Exp $
#

require 'xmlparser'
require 'bio'

module Bio

  class Blast

    class Report

      class XMLRetry < Exception; end
	
      def initialize (xml)
	@program = ''
	@version = ''
	@reference = ''
	@db = ''
	@query_ID = ''
	@query_def = ''
	@query_len = 0
	@parameters = Hash.new
	@statistics = Hash.new
	@iteration = Array.new
	  
	self.parse(xml)
      end
      attr_accessor :program, :version, :reference, :db, :query_ID, 
	:query_def, :query_len, :parameters, :statistics, :iteration
	
      def parse (xml)
	parser = XMLParser.new
	def parser.default; end
	
	begin
	  tag_stack = Array.new
	  entry = Hash.new
	  name = ''
	  parser.parse(xml) do |type, name, data|
	    case type
	    when XMLParser::START_ELEM
	      tag_stack.push(name)
	      data.each do |key, value|
		entry[key] = value
	      end
	      
	      case tag_stack.last
	      when 'Iteration'
		itr = Iteration.new
		@iteration.push(itr)
	      when 'Hit'
		hit = Hit.new
		@iteration.last.add_hit(hit)
	      when 'Hsp'
		hsp = Hsp.new
		@iteration.last.hit.last.add_hsp(hsp)
	      end

	    when XMLParser::END_ELEM
	      case tag_stack.last
	      when 'BlastOutput_program'
		@program = entry[tag_stack.last]
		entry = Hash.new
	      when 'BlastOutput_version'
		@version = entry[tag_stack.last]
		entry = Hash.new
	      when 'BlastOutput_reference'
		@reference = entry
		entry = Hash.new  
	      when 'BlastOutput_db'
		@db = entry[tag_stack.last]
		entry = Hash.new  
	      when 'BlastOutput_query-ID'
		@query_ID = entry[tag_stack.last]
		entry = Hash.new  
	      when 'BlastOutput_query-def'
		@query_def = entry[tag_stack.last]
		entry = Hash.new  
	      when 'BlastOutput_query-len'
		@query_len = entry[tag_stack.last]
		entry = Hash.new  

	      when 'Parameters'
		parse_parameters(entry)
		entry = Hash.new
		  
	      when 'Iteration_iter-num'
		@iteration.last.num = entry[tag_stack.last].clone
		entry = Hash.new
		
	      when 'Hit_num'
		@iteration.last.hit.last.num = entry[tag_stack.last].clone
		entry = Hash.new
	      when 'Hit_id'
		@iteration.last.hit.last._id = entry[tag_stack.last].clone
		entry = Hash.new
	      when 'Hit_def'
		@iteration.last.hit.last._def = entry[tag_stack.last].clone
		entry = Hash.new
	      when 'Hit_accession'
		@iteration.last.hit.last.accession = entry[tag_stack.last].clone
		entry = Hash.new
	      when 'Hit_len'
		@iteration.last.hit.last.len = entry[tag_stack.last].clone
		entry = Hash.new

	      when 'Hsp'
		parse_hsp(entry)
		entry = Hash.new

	      when 'Statistics'
		parse_statistics(entry)
		entry = Hash.new

	      end

	      tag_stack.pop

	    when XMLParser::CDATA
	      if  entry[tag_stack.last] == nil
		unless data =~ /^\n/ or data =~ /^  +$/
		  entry[tag_stack.last] = data
		end
	      end

	    when XMLParser::PI
	    else
	      next if data =~ /^<\?xml /
	    end
	  end
	rescue XMLRetry
	  newencoding = nil
	  e = $!.to_s
	  parser = XMLParser.new(newencoding)
	  def parser.default; end
	  retry
	rescue XMLParserError
	  line = parser.line
	  print "Parse error(#{line}): #{$!}\n"
	end
      end
      
      # Bio::Blast::Report::Iteration
      class Iteration
	def initialize(num = nil)
	  @num = num
	  @hit = Array.new
	end
	attr_accessor :num, :hit
	def add_hit(hit)
	  @hit.push(hit)
	end
	def hits
	  hit
	end
      end

      # Bio::Blast::Report::Hit
      class Hit
	def initialize(num=nil, id=nil, def_=nil,accession=nil, len=nil)
	  @num = num
	  @_id = id
	  @_def = def_
	  @accession = accession
	  @len = len
	  @hsp = Array.new
	end
	attr_accessor :num, :_id, :_def, :accession, :len, :hsp
	def add_hsp(hsp)
	  @hsp.push(hsp)
	end
	def hsps
	  hsp
	end
      end

      # Bio::Blast::Report::Hsp
      class Hsp
	def initialize(num = nil)
	  @num = num
	  @bit_score = 0.0
	  @score = 0
	  @evalue = 0.0
	  @query_from = 0
	  @query_to = 0
	  @hit_from = 0
	  @hit_to = 0
	  @pattern_from = 0
	  @pattern_to = 0
	  @query_frame = 0
	  @hit_frame = 0
	  @identity = 0
	  @positive = 0
	  @gaps = 0
	  @align_len = 0
	  @density = 0
	  @qseq = ''
	  @hseq = ''
	  @midline = ''
	end
	attr_accessor :num, :bit_score, :score, :evalue, :query_from, 
	  :query_to, :hit_from, :hit_to, :pattern_from, :pattern_to, 
	  :query_frame, :hit_frame, :identity, :positive, :gaps, :align_len, 
	  :density, :qseq, :hseq, :midline
      end

      protected

      def parse_parameters(hash)
	labels = { 
	  'expect' => 'Parameters_expect',
	  'include' => 'Parameters_include',
	  'sc-match' => 'Parameters_so-match',
	  'sc-mismatch' => 'Parameters_so-mismatch',
	  'gep-open' => 'Parameters_gap-open',
	  'gap-extend' => 'Parameters_gap-extend',
	  'filter' => 'Parameters_filter'
	}
	labels.each do |k,v|
	  @parameters[k] = hash[v]
	end
      end

      def parse_statistics(hash)
	labels = {
	  'db-num' => 'Statistics_db-num',
	  'db-len' => 'Statistics_db-len',
	  'hsp-len' => 'Statistics_hsp-len',
	  'eff-space' => 'Statistics_eff-space',
	  'kappa' => 'Statistics_kappa',
	  'lambda' => 'Statistics_lambda',
	  'entropy' => 'Statistics_entropy'
	}
	labels.each do |k,v|
	  @statistics[k] = hash[v]
	end
      end

      def parse_hsp(h)
	@iteration.last.hit.last.hsp.last.num = h['Hsp_num']
	@iteration.last.hit.last.hsp.last.bit_score = h['Hsp_bit-score']
	@iteration.last.hit.last.hsp.last.score = h['Hsp_score']
	@iteration.last.hit.last.hsp.last.evalue = h['Hsp_evalue']
	@iteration.last.hit.last.hsp.last.query_from = h['Hsp_query-from']
	@iteration.last.hit.last.hsp.last.query_to = h['Hsp_query-to']
	@iteration.last.hit.last.hsp.last.hit_from = h['Hsp_hit-from']
	@iteration.last.hit.last.hsp.last.hit_to = h['Hsp_hit-to']
	@iteration.last.hit.last.hsp.last.pattern_from = h['Hsp_pattern-from']
	@iteration.last.hit.last.hsp.last.pattern_to = h['Hsp_pattern-to']
	@iteration.last.hit.last.hsp.last.query_frame = h['Hsp_query-frame']
	@iteration.last.hit.last.hsp.last.hit_frame = h['Hsp_hit-frame']
	@iteration.last.hit.last.hsp.last.identity = h['Hsp_identity']
	@iteration.last.hit.last.hsp.last.positive = h['Hsp_positive']
	@iteration.last.hit.last.hsp.last.gaps = h['Hsp_gaps']
	@iteration.last.hit.last.hsp.last.align_len = h['Hsp_align-len']
	@iteration.last.hit.last.hsp.last.density = h['Hsp_density']
	@iteration.last.hit.last.hsp.last.qseq = h['Hsp_qseq']
	@iteration.last.hit.last.hsp.last.hseq = h['Hsp_hseq']
	@iteration.last.hit.last.hsp.last.midline = h['Hsp_midline']
      end
	
    end				# class Report

  end				# class Blast

end				# modlue Bio


# Testing codes
if __FILE__ == $0
  b = Bio::Blast::Report.new($<.read)

#  p b

  puts "\n= = Bio::Tools::Blast::Report = ="
  puts "   = = Report#program = ="
  p b.program
  puts "   = = Report#version = ="
  p b.version
  puts "   = = Report#reference = ="
  p b.reference
  puts "   = = Report#db = ="
  p b.db
  puts "   = = Report#query_ID = ="
  p b.query_ID
  puts "   = = Report#query_def = ="
  p b.query_def
  puts "   = = Report#query_len = ="
  p b.query_len

  puts "\n= = Parameters = ="
  p b.parameters

  puts "\n= = Statistics = ="
  p b.statistics

  
  b.iteration.each do |itr|
    puts "\n= = Bio::Blast::Report::Iteration = ="

    puts "   = = Iteration#num = ="
    p itr.num

    itr.hits.each do |hit|
      puts "\n = = Bio::Blast::Report::Hit = ="
      puts "   = = Hit#num = ="
      p hit.num
      puts "   = = Hit#_id = ="
      p hit._id
      puts "   = = Hit#_def = ="
      p hit._def
      puts "   = = Hit#accession = ="
      p hit.accession
      puts "   = = Hit#len = ="
      p hit.len

      hit.hsps.each do |hsp|
	puts "\n  = = Bio::Blast::Report::Hsp = ="
	p hsp
	p
      end
    end
  end

end	    


=begin

== NAME

blast_report.rb  - NCBI_BlastOutput.dtd XML Parser

Copyright (C) 2001 Mitsuteru S. Nakao <n@bioruby.org>

== EXAMPLE

require 'bio/appl/blast'

xml = $<.read

res = Bio::Blast::Report.new(xml)
# Bio::Blast::Report
res.program #=> blastn                        <BlastOutput_program>
res.version #=> blastn 2.2.1 [Jul-12-2001]    <BlastOutput_version>
res.reference #=> Reference. ..               <BlastOutput_reference>
res.db #=> /bio/db/blast/genome/bsu           <BlastOutput_db>
res.query_ID #=> lcl|QUERY                    <BlastOutput_query-ID>
res.query_ID #=> lcl|QUERY                    <BlastOutput_query-ID>
res.query_def #=>                             <BlastOutput_query-def>
res.query_len #=>                             <BlastOutput_query-len>
res.param #-> Array ?                         <BlastOutput_param>
res.parameters['expect'] #=> 10         <Parameters_expect>
res.parameters['include'] #=> 0         <Parameters_include>  
res.parameters['sc-match'] #=> 1        <Parameters_so-match>
res.parameters['sc-mismatch'] #=> -3    <Parameters_so-mismatch>
res.parameters['gep-open'] #=> 5        <Parameters_gap-open>
res.parameters['gap-extend'] #=> 2      <Parameters_gap-extend>
res.parameters['filter'] #=> D          <Parameters_filter>
res.iteration #-> Array                       <BlastOutput_iterations>

it = res.iteration[0]
# Bio::Blast::Report::Iteration
it.num #=> 1                             <Iteration_iter-num>
it.hits #-> Array

hit = it.hits[0]
# Bio::Blast::Report::Hit              # on db
hit.num #=> 1                                 <Hit_num>
hit.id #=> gn|BL_ORD_ID|0                     <Hit_id>
hit.def #=> gn:bsu [AL...                     <Hit_def>
hit.accession #=> 0                           <Hit_accession>
hit.len #=> 4214814                           <Hit_len>
hit.hsps #-> Array

hsp = hit.hsps[0]
# Bio::Blast::Report::Hsp
hsp.num #=> 1                                 <Hsp_num>
hsp.bit_score #=> 36.1753                     <Hsp_bit-score>
hsp.score #=> 18                              <Hsp_score>
hsp.evalue #=> 0.432948                       <Hsp_evalue>
hsp.query_from #=> 781                        <Hsp_query-from>
hsp.query_to #=> 764                          <Hsp_query-to>
hsp.hit_from #=> 3683654                      <Hsp_hit-from>
phsp.hit_to #=> 3683671                        <Hsp_hit-to>
hsp.pattern_from #=> 0                        <Hsp_pattern-from>
hsp.pattern_to #=> 0                          <Hsp_pattern-to>
hsp.query_frame #=> 1                         <Hsp_query-frame>
hsp.hit_frame #=> -1                          <Hsp_hit-frame>
hsp.identity #=> 18                           <Hsp_identity>
hsp.positive #=> 18                           <Hsp_positive>
hsp.gaps #=> 0                                <Hsp_gaps>

it.statistics['db-num'] #=> 1                 <Statistics_db-num>
it.statistics['db-len'] #=> 4214814           <Statistics_db-len>
it.statistics['hsp-len'] #=> 0                <Statistics_hsp-len>
it.statistics['eff-space'] #=> 3.35e+10       <Statistics_eff-space>
it.statistics['kappa'] #=> 0.710605           <Statistics_kappa>
it.statistics['db'] #=> 1                     <Statistics_db-num>
it.statistics['db-num'] #=> 1                 <Statistics_db-num>

== DTD files

* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.mod
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_Entity.mod

=end

