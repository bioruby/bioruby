#
# bio/appl/blast/xmlparser.rb - BLAST XML output (-m 7) parser by XMLParser
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
#  $Id: xmlparser.rb,v 1.2 2002/06/22 03:17:21 k Exp $
#

begin
  require 'xmlparser'
rescue LoadError
end

module Bio
  class Blast

    ##
    # Blast (-m 7) XML Report Parser Class
    # xmlparser used.
    # This class is tested blastn -m 7 report only.
    class Report

      class XMLRetry < Exception; end

      attr_accessor :program, :version, :reference, :db, :query_id, 
	:query_def, :query_len, :parameters, :statistics, :iterations

      def initialize (xml)
	@program   = ''
	@version   = ''
	@reference = ''
	@db        = ''
	@query_id  = ''
	@query_def = ''
	@query_len = 0
	@parameters = Hash.new
	@statistics = Hash.new
	@iterations = Array.new
	  
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
	      
	      case name
	      when 'Iteration'
		itr = Iteration.new
		@iterations.push(itr)
	      when 'Hit'
		hit = Hit.new
		@iterations.last.add_hit(hit)
	      when 'Hsp'
		hsp = Hsp.new
		@iterations.last.hits.last.add_hsp(hsp)
	      end

	    when XMLParser::END_ELEM
	      case name
	      when /^BlastOutput/
		self.parse_blastoutput(name, entry)
		entry = Hash.new
	      when /^Parameters$/
		self.parse_parameters(entry)
		entry = Hash.new
	      when /^Iteration/
		self.parse_iteration(name, entry)
		entry = Hash.new
	      when /^Hit/
		self.parse_hit(name, entry)
		entry = Hash.new
	      when /^Hsp$/
		self.parse_hsp(entry)
		entry = Hash.new
	      when /^Statistics$/
		self.parse_statistics(entry)
		entry = Hash.new
	      else
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
      
      ##
      # Bio::Blast::Report::Iteration
      class Iteration

	def initialize(num = nil)
	  @num = num
	  @hits = Array.new
	end
	attr_accessor :num, :hits

	def add_hit(hit)
	  @hits.push(hit)
	end

      end                       # class Iteration

      #
      # Bio::Blast::Report::Hit
      class Hit

	def initialize(num = nil, id = nil, definition = nil,
		       accession = nil, len = nil)
	  @num        = num
	  @hit_id     = id
	  @definition = definition
	  @accession  = accession
	  @len        = len
	  @hsps       = Array.new
	end
	attr_accessor :num, :hit_id, :definition, :accession, :len, :hsps

	def add_hsp(hsp)
	  @hsps.push(hsp)
	end

      end                       # class Hit

      #
      # Bio::Blast::Report::Hsp
      class Hsp

	def initialize(num = nil)
	  @num          = num
	  @bit_score    = 0.0
	  @score        = 0
	  @evalue       = 0.0
	  @query_from   = 0
	  @query_to     = 0
	  @hit_from     = 0
	  @hit_to       = 0
	  @pattern_from = 0
	  @pattern_to   = 0
	  @query_frame  = 0
	  @hit_frame    = 0
	  @identity     = 0
	  @positive     = 0
	  @gaps         = 0
	  @align_len    = 0
	  @density      = 0
	  @qseq         = ''
	  @hseq         = ''
	  @midline      = ''
	end
	attr_accessor :num, :bit_score, :score, :evalue, :query_from, 
	  :query_to, :hit_from, :hit_to, :pattern_from, :pattern_to, 
	  :query_frame, :hit_frame, :identity, :positive, :gaps, :align_len, 
	  :density, :qseq, :hseq, :midline

      end                       # class Hsp


      protected

      def parse_blastoutput(tag, entry)
	case tag
	when 'BlastOutput_program'
	  @program = entry[tag]
	when 'BlastOutput_version'
	  @version = entry[tag]
	when 'BlastOutput_reference'
	  @reference = entry
	when 'BlastOutput_db'
	  @db = entry[tag].strip
	when 'BlastOutput_query-ID'
	  @query_id = entry[tag]
	when 'BlastOutput_query-def'
	  @query_def = entry[tag]
	when 'BlastOutput_query-len'
	  @query_len = entry[tag].to_i
	end
      end

      def parse_parameters(hash)
	labels = { 
	  'expect'      => 'Parameters_expect',
	  'include'     => 'Parameters_include',
	  'sc-match'    => 'Parameters_sc-match',
	  'sc-mismatch' => 'Parameters_sc-mismatch',
	  'gep-open'    => 'Parameters_gap-open',
	  'gap-extend'  => 'Parameters_gap-extend',
	  'filter'      => 'Parameters_filter'
	}
	labels.each do |k,v|
	  if k == 'filter'
	    @parameters[k] = hash[v].to_s
	  else
	    @parameters[k] = hash[v].to_i
	  end
	end
      end

      def parse_iteration(tag, entry)
	case tag
	when 'Iteration_iter-num'
	  @iterations.last.num = entry[tag].to_i
	end
      end

      def parse_hit(tag, entry)
	hit = @iterations.last.hits.last
	case tag
	when 'Hit_num'
	  hit.num = entry[tag].to_i
	when 'Hit_id'
	  hit.hit_id = entry[tag].clone
	when 'Hit_def'
	  hit.definition = entry[tag].clone
	when 'Hit_accession'
	  hit.accession = entry[tag].clone
	when 'Hit_len'
	  hit.len = entry[tag].clone.to_i
	end
      end

      def parse_hsp(hash)
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
	hsp.qseq         = hash['Hsp_qseq']  # to_seq ?
	hsp.hseq         = hash['Hsp_hseq']  # to_seq ?
	hsp.midline      = hash['Hsp_midline']
      end

      def parse_statistics(hash)
	labels = { 'db-num'     => 'Statistics_db-num',
	           'db-len'     => 'Statistics_db-len',
	           'hsp-len'    => 'Statistics_hsp-len',
	           'eff-space'  => 'Statistics_eff-space',
	           'kappa'      => 'Statistics_kappa',
	           'lambda'     => 'Statistics_lambda',
	           'entropy'    => 'Statistics_entropy'	}
	labels.each do |k,v|
	  if k == 'dn-num' or k == 'db-len' or k == 'hsp-len'
	    @statistics[k] = hash[v].to_i
	  else
	    @statistics[k] = hash[v].to_f
	  end
	end
      end
	
    end				# class Report

  end				# class Blast

end				# modlue Bio



# Testing code

if __FILE__ == $0

  reports = []
  reports << Bio::Blast::Report.new(ARGF.read)

  print "\treports.size\t#=> "
  p reports.size

  puts "\n= = reports.each do |b| "
  reports.each do |b|
    puts "\n= = Bio::Tools::Blast::Report = ="
    print "\tb.program    #=> "
    p b.program
    print "\tb.version    #=> "
    p b.version
    print "\tb.reference  #=> "
    p b.reference
    print "\tb.db         #=> "
    p b.db
    print "\tb.query_id   #=> "
    p b.query_id
    print "\tb.query_def  #=> "
    p b.query_def
    print "\tb.query_len  #=> "
    p b.query_len
    
    puts "\n= = Parameters = ="
    p b.parameters

    puts "\n= = Statistics = ="
    p b.statistics

  
    puts "\n= = b.itreration.each do |itr| "
    b.iterations.each do |itr|
      puts "\n= = Bio::Blast::Report::Iteration = ="
      
      print "\titr.num        #=> "
      p itr.num

      print "\titr.hits.size  #=> "
      p itr.hits.size

      puts "\n= = itr.hits.each do |hit| "
      itr.hits.each do |hit|
	puts "\n = = Bio::Blast::Report::Hit = ="
	print "\thit.num        #=> "
	p hit.num
	print "\thit.hit_id     #=> "
	p hit.hit_id
	print "\thit.definition #=> "
	p hit.definition
	print "\thit.accession  #=> "
	p hit.accession
	print "\thit.len        #=> "
	p hit.len

	print "\thit.hsps.size  #=> "
	p hit.hsps.size

	
	hit.hsps.each do |hsp|
	  puts "\n  = = Bio::Blast::Report::Hsp = ="
	  print "\thsp.num          #=> "
	  p hsp.num
	  print "\thsp.bit_score    #=> "
	  p hsp.bit_score 
	  print "\thsp.score        #=> "
	  p hsp.score
	  print "\thsp.evalue       #=> "
	  p hsp.evalue
	  print "\thsp.identity     #=> "
	  p hsp.identity
	  print "\thsp.gaps         #=> "
	  p hsp.gaps
	  print "\thsp.positive     #=> "
	  p hsp.positive
	  print "\thsp.align_len    #=> "
	  p hsp.align_len
	  print "\thsp.density      #=> "
	  p hsp.density

	  print "\thsp.query_frame  #=> "
	  p hsp.query_frame
	  print "\thsp.query_from   #=> "
	  p hsp.query_from
	  print "\thsp.query_to     #=> "
	  p hsp.query_to

	  print "\thsp.hit_frame    #=> "
	  p hsp.hit_frame
	  print "\thsp.hit_from     #=> "
	  p hsp.hit_from
	  print "\thsp.hit_to       #=> "
	  p hsp.hit_to

	  print "\thsp.pattern_from #=> "
	  p hsp.pattern_from
	  print "\thsp.pattern_to   #=> "
	  p hsp.pattern_to

	  print "\thsp.qseq         #=> "
	  p hsp.qseq
	  print "\thsp.midline      #=> "
	  p hsp.midline
	  print "\thsp.hseq         #=> "
	  p hsp.hseq

	  puts
	  puts "#{hsp.query_from} .. #{hsp.query_to}"
	  puts "query: #{hsp.qseq}"
	  puts "       #{hsp.midline}"
	  puts "hit:   #{hsp.hseq}"
	  puts "#{hsp.hit_from} .. #{hsp.hit_to}"
	  puts 
	end
      end
    end
  end

end	    



=begin

= Bio::Blast::Report

--- Bio::Blast::Report#new(xml)

      xml as blastall -m 7 report

--- Bio::Blast::Report#program
--- Bio::Blast::Report#version
--- Bio::Blast::Report#reference
--- Bio::Blast::Report#db
--- Bio::Blast::Report#query_id
--- Bio::Blast::Report#query_def
--- Bio::Blast::Report#query_len

--- Bio::Blast::Report#prameters -> hsh

      Keys: expect, include, sc-match, sc-mismatch, gap-open, gap-extend
            filter

--- Bio::Blast::Report#statistics -> hsh

      Keys: db-num, db-len, hsp-len, eff-space, kappa, db, db-num

--- Bio::Blast::Report#iterations -> ary

      Returns an Array(Bio::Blast::Iteration).
      alias Bio::Blast::Report#iteration, Bio::Blast::Report#itrs


= Bio::Blast::Iteration

--- Bio::Blast::Iteration#num
--- Bio::Blast::Iteration#add_hit(Bio::Blast::Hit)
--- Bio::Blast::Iteration#hits -> ary

      Returns an Array(Bio::Blast::Hit).

= Bio::Blast::Hit

--- Bio::Blast::Hit#num
--- Bio::Blast::Hit#hit_id
--- Bio::Blast::Hit#definition
--- Bio::Blast::Hit#accession
--- Bio::Blast::Hit#len
--- Bio::Blast::Hit#add_hsp(Bio::Blsat::Hsp)
--- Bio::Blast::Hit#hsps -> ary

      Returns an Array(Bio::Blast::Hsp).

= Bio::Blast::Hsp

--- Bio::Blast::Hsp#num
--- Bio::Blast::Hsp#bit_score
--- Bio::Blast::Hsp#score
--- Bio::Blast::Hsp#evalue
--- Bio::Blast::Hsp#query_from
--- Bio::Blast::Hsp#query_to
--- Bio::Blast::Hsp#hit_from
--- Bio::Blast::Hsp#hit_to
--- Bio::Blast::Hsp#pattern_from
--- Bio::Blast::Hsp#pattern_to
--- Bio::Blast::Hsp#query_frame
--- Bio::Blast::Hsp#hit_frame
--- Bio::Blast::Hsp#identity
--- Bio::Blast::Hsp#positive
--- Bio::Blast::Hsp#gaps
--- Bio::Blast::Hsp#align_len
--- Bio::Blast::Hsp#density
--- Bio::Blast::Hsp#qseq
--- Bio::Blast::Hsp#hseq
--- Bio::Blast::Hsp#midline


= DTD files

* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.mod
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_Entity.mod

=end

