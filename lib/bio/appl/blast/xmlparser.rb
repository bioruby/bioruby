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
#  $Id: xmlparser.rb,v 1.8 2002/07/02 01:41:50 k Exp $
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
	:query_def, :query_len, :parameters, :iterations

      def initialize (xml)
	@program   = ''
	@version   = ''
	@reference = ''
	@db        = ''
	@query_id  = ''
	@query_def = ''
	@query_len = 0
	@parameters = Hash.new
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
		hit.query_info(@query_id, @query_def, @query_len)
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

      def each_iteration
	@iterations.each do |x|
	  yield x
	end
      end

      def each_hit
	@iterations.last.each do |x|
	  yield x
	end
      end
      alias :each :each_hit

      def hits
	@iterations.last.hits
      end

      def statistics
	@iterations.last.statistics
      end

      def message
	@iterations.last.message
      end


      ##
      # Bio::Blast::Report::Iteration
      class Iteration

	def initialize(num = nil)
	  @message = nil
	  @num = num
	  @hits = Array.new
	  @statistics = Hash.new
	end
	attr_accessor :num, :hits, :statistics, :message

	def each
	  @hits.each do |x|
	    yield x
	  end
	end

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

	def each
	  @hsps.each do |x|
	    yield x
	  end
	end

	def add_hsp(hsp)
	  @hsps.push(hsp)
	end

	# for the compatibility with Fasta::Report::Hit class

	def query_info(query_id, query_def, query_len)
	  @query_id, @query_def, @query_len = query_id, query_def, query_len
	end
	attr_reader :query_id, :query_def, :query_len
	alias :target_id :accession
	alias :target_def :definition
	alias :target_len :len


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
	  @reference = entry[tag]
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
	  'filter'      => 'Parameters_filter',
	  'matrix'	=> 'Parameters_matrix',
	}
	labels.each do |k,v|
	  if k == 'filter' or k == 'matrix'
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
	when 'Iteration_message'
	  @iterations.last.message = entry[tag].to_s
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
	  case k
	  when 'dn-num','db-len','hsp-len'
	    @iterations.last.statistics[k] = hash[v].to_i
	  else
	    @iterations.last.statistics[k] = hash[v].to_f
	  end
	end
      end
	
    end				# class Report

  end				# class Blast

end				# modlue Bio



# Testing code

if __FILE__ == $0

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

--- Bio::Blast::Report.new(xml)

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

--- Bio::Blast::Report#iterations -> ary

      Returns an Array(Bio::Blast::Report::Iteration).

--- Bio::Blast::Report#each_iteration

      Iterates on Bio::Blast::Report::Iteration.

--- Bio::Blast::Report#each_hit
--- Bio::Blast::Report#each

      Iterates on Bio::Blast::Report::Hit of the last Iteration.

--- Bio::Blast::Report#statistics -> hsh

      Returns a Hash containing execution statistics of the last iteration.
      Valid keys are:
        'db-len', 'db-num', 'eff-space', 'entropy', 'hsp-len',
        'kappa', 'lambda'

--- Bio::Blast::Report#message

      Returns a String (or nil) containing execution message of the last
      iteration (typically "CONVERGED").

--- Bio::Blast::Report#hits

      Returns a Array of Bio::Blast::Report::Hits of the last iteration.


= Bio::Blast::Report::Iteration

--- Bio::Blast::Report::Iteration#num
--- Bio::Blast::Report::Iteration#each
--- Bio::Blast::Report::Iteration#message
--- Bio::Blast::Report::Iteration#statistics
--- Bio::Blast::Report::Iteration#hits -> ary

      Returns an Array(Bio::Blast::Report::Hit).

--- Bio::Blast::Report::Iteration#add_hit(Bio::Blast::Report::Hit)


= Bio::Blast::Report::Hit

--- Bio::Blast::Report::Hit#num
--- Bio::Blast::Report::Hit#hit_id
--- Bio::Blast::Report::Hit#len
--- Bio::Blast::Report::Hit#definition
--- Bio::Blast::Report::Hit#accession
--- Bio::Blast::Report::Hit#each
--- Bio::Blast::Report::Hit#hsps -> ary

      Returns an Array(Bio::Blast::Report::Hsp).

--- Bio::Blast::Report::Hit#add_hsp(Bio::Blast::Report::Hsp)


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


= Bio::Blast::Report::Hsp

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


= DTD files

* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.mod
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_Entity.mod

=end

