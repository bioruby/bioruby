#
# bio/appl/blast.rb - BLAST Execution Factory and Report Parser
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
#  $Id: blast.rb,v 1.7 2001/11/22 06:09:22 nakao Exp $
#

#require 'net/http'
begin
  require 'xmlparser'
rescue LoadError
end

module Bio

  class Blast

    class BlastExecError < StandardError; end
    class BlastOptionsError < ArgumentError; end

    ##
    # ARGUMENTS:
    # server = { 'host'=>'localhost','port'=>8080, 'cgi'=>'/blast.cgi',
    #            'proxy'=>'proxy', 'proxy_port'=>8000 }
    # opts   = {'-m' => 7, '-e' => 0.0001 , ...}
    def initialize (server = nil, blastall = nil, \
		    program = nil, db = nil, opts = nil)
      @server   = server
      @blastall = blastall
      @program  = program
      @db       = db
      @opts     = opts
      @io       = nil
    end
    attr_accessor :server, :program, :db, :opts
    # Blast#server['pryxy'] = 'proxy'
    # Blast#server['pryxy_port'] = 8000
    ##
    # constructor for local blastall
    # blastall: /path/to/blastall
    # program:  (blastp|blastn|tblastx|blasty|...)
    # db:       /path/to/db
    # opts:     {'-e' => 0.1, ... } 
    def Blast.local (blastall, program, db, opts = nil)
      self.new(nil, blastall, program, db, opts)
    end

    ##
    # constructor for remote blast server
    def Blast.remote (server, program, db, opts = nil)
      self.new(server, nil, program, db, opts)
    end
    #
    # constructor for remote blast server on NCBI
    def Blast.ncbi (program, db, opts = nil)
      server = {'server'=>'NCBI',
	'host'=>'www.ncbi.nlm.nih.gov','cgi'=>'/blast/blast.cgi'}
      self.new(server, nil, program, db, opts)
    end
    #
    # constructor for remote blast server on GenomeNet
    def Blast.genomenet (program, db, opts = nil)
      server = {'server'=>'GenomeNet',
	'host'=>'blast.genome.ad.jp','cgi'=>'/sit-bin/nph-blast'}
      self.new(server, nil, program, db, opts)
    end
    
    ##
    # query in (multi) fasta format file in String
    def query(query) 
      if @server
	return remote_blast(query)
      elsif @blastall
	return local_blast(query)
      end
    end
    alias exec query

    ##
    # execute blastall in remote server
    def remote_blast(query)
      raise NotImplementError, "Not yet implimented"
#
#      http = New::HTTP.new(@server['host'],@server['port'])
#      data = set_post_data(opts,query) 
#      result = http.post2(@server['cgi'], data)
#      reports = preparse(result.body)
#
#	return reports.read.split("\n<\\?xml").collect { |entry|	
#	  unless entry =~ /^<.xml/
#	    Report.new('<?xml'+entry)
#	  else
#	    Report.new(entry)
#	  end
#	}
#
    end
    private :remote_blast
    #
    def set_post_data
      raise NotImplementError, "Not yet implimented"
#----------------------------#{$id(%13x)}
#Content-Disposition: form-data; name="#{name}"
#
#----------------------------#{$id(%13x)}
#Content-Disposition: form-data; name="upload_file"; filename="#{filename}"
#Content-Type: application/octet-stream
#
#
#----------------------------#{$id(%13x)}--
# data = "
    end
    private :set_post_data
    #
    def preparse(data)
      raise NotImplementError, "Not yet implimented"
    end
    private :preparse



    ##
    # execute blastall in local machine
    def local_blast(query)
      cmd = "#{@blastall} -p #{@program} -d #{@db} -m 7"

      # Check blastall options 
      if @opts.type == Hash
	@opts.each do |k,v|
	  if k =~ /^-[eFGEXIqrvbfgQDaOJMWzkPYSTlUyZRnLA]$/
	    cmd += " #{k} #{v} "
	  else
	    raise BlastOptionsError, "Error: Invalid option #{k} #{v}"
	  end
	end
      end

      begin 
	@io = IO.popen(cmd, "w+")
	@io.sync = 1   
	@io.puts(query)
	@io.close_write

	# Returns Multi Queries, Multi XML Reports
	return @io.read.split("\n<\\?xml").collect { |entry|	
	  unless entry =~ /^<.xml/
	    Report.new('<?xml'+entry)
	  else
	    Report.new(entry)
	  end
	}
	@io.close
      rescue BlastExecError
	raise "Error: #{$!}: #{cmd} \n"
      ensure
	@io.close
      end
    end
    private :local_blast

    ## ``blastall'' and ``db'' check methods
    #
    # Executable file ?
    def blastall?
      File.stat(@blastall).executable?
    end
    #
    # Readable db ?
    def db?
      File.stat(@db).readable?
    end



    ##
    # Blast (-m 7) XML Report Parser Class
    # xmlparser used.
    # This class is tested blastn -m 7 report only.
    class Report

      class XMLRetry < Exception; end
	
      def initialize (xml)
	@program   = ''
	@version   = ''
	@reference = ''
	@db        = ''
	@query_ID  = ''
	@query_def = ''
	@query_len = 0
	@parameters = Hash.new
	@statistics = Hash.new
	@iteration  = Array.new
	  
	self.parse(xml)
      end
      attr_accessor :program, :version, :reference, :db, :query_ID, 
	:query_def, :query_len, :parameters, :statistics, :iteration
      alias iterations iteration
      alias itrs iteration


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
	      if tag_stack.last =~ /^BlastOutput/
		self.parse_blastoutput(tag_stack.last, entry)
		entry = Hash.new
	      elsif tag_stack.last =~ /^Parameters$/
		self.parse_parameters(entry)
		entry = Hash.new
	      elsif tag_stack.last =~ /^Iteration/
		self.parse_iteration(tag_stack.last, entry)
		entry = Hash.new
	      elsif tag_stack.last =~ /^Hit/
		self.parse_hit(tag_stack.last, entry)
		entry = Hash.new
	      elsif tag_stack.last =~ /^Hsp$/
		self.parse_hsp(entry)
		entry = Hash.new
	      elsif tag_stack.last =~ /^Statistics$/
		self.parse_statistics(entry)
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
      
      ##
      # Bio::Blast::Report::Iteration
      class Iteration

	def initialize(num = nil)
	  @num = num
	  @hits = Array.new
	end
	attr_accessor :num, :hits
	alias hit hits

	def add_hit(hit)
	  @hits.push(hit)
	end

      end                       # class Iteration

      #
      # Bio::Blast::Report::Hit
      class Hit

	def initialize(num=nil, id=nil, def_=nil,accession=nil, len=nil)
	  @num       = num
	  @_id       = id
	  @_def      = def_
	  @accession = accession
	  @len       = len
	  @hsps      = Array.new
	end
	attr_accessor :num, :_id, :_def, :accession, :len, :hsps
	alias hsp hsps

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
	  @db = entry[tag]
	when 'BlastOutput_query-ID'
	  @query_ID = entry[tag]
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
	  'sc-match'    => 'Parameters_so-match',
	  'sc-mismatch' => 'Parameters_so-mismatch',
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
	  @iteration.last.num = entry[tag].to_i
	end
      end

      def parse_hit(tag, entry)
	hit = @iteration.last.hit.last
	case tag
	when 'Hit_num'
	  hit.num = entry[tag].to_i
	when 'Hit_id'
	  hit._id = entry[tag].clone
	when 'Hit_def'
	  hit._def = entry[tag].clone
	when 'Hit_accession'
	  hit.accession = entry[tag].clone
	when 'Hit_len'
	  hit.len = entry[tag].clone.to_i
	end
      end

      def parse_hsp(hash)
	hsp = @iteration.last.hit.last.hsp.last
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
	labels = {
	  'db-num'     => 'Statistics_db-num',
	  'db-len'     => 'Statistics_db-len',
	  'hsp-len'    => 'Statistics_hsp-len',
	  'eff-space'  => 'Statistics_eff-space',
	  'kappa'      => 'Statistics_kappa',
	  'lambda'     => 'Statistics_lambda',
	  'entropy'    => 'Statistics_entropy'
	}
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

  fna="> hoge
cagcatgtacgtgatcgtacgtagctagtcagtcgtatctatggcgcgcgcgcgcatctgactgtacga
cggcgtatcgctatctgctctcttttagcttatcgggcgctatcttcgatcttagcttcgcgcattg
ccccccccggggggtgatcgctgcgggctcggcgctcggctcgcgtggggcgggcgggcgcgcggcg
> fuga
aaaaaccaacccaccccccccccccacacatcgtatagccacgggcgcggcgtatggctagagatcgga
acgatagctaggcgcgcgcgcgtatatattatttttttttttatatatttatatattattatatattat
atatttattatatttaaaaaaaaaaaattatatatatatatttattttatagatgctcagctacggcatc
> hoge2
cagcatgtacgtgatcgtacgtagctagtcagtcgtatctatggcgcgcgcgcgcatctgactgtacga
cggcgtatcgctatctgctctcttttagcttatcgggcgctatcttcgatcttagcttcgcgcattg
ccccccccggggggtgatcgctgcgggctcggcgctcggctcgcgtggggcgggcgggcgcgcggcg
"
  
  puts "= = Bio::Blast.local = ="
  opts = {'-e' => 1.0}

  blastall = '/bio/bin/blastall'     # option
  db = '/bio/db/blast/genome/mtu'    # option

  bls = Bio::Blast.local(blastall, 'blastn', db, opts)
  p bls

  puts "\n = Bio::Blast.blastall? =="
  p bls.blastall?

  puts "\n = Bio::Blast.db? ="
  p bls.db?


  puts "\n = p fna ="
  puts fna

  puts "\n = Bio::Blast.query(fna) ="
  bs = bls.query(fna)

  puts "\n = bs.size ="
  p bs.size


  bs.each do |b|
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
	  puts "query: #{hsp.qseq}"
	  puts "       #{hsp.midline}"
	  puts "hit:   #{hsp.hseq}"
	end
      end
    end
  end

end	    


=begin

= Bio::Blast

--- Bio::Blast#local(blastall, program, db, opts)

      An intialize method for local blast search
      opts = {'-e' => 0.0, ... }

--- Bio::Blast#remote(uri, program, db, opts)

      An intialize method for remote blast search

--- Bio::Blast#ncbi(program, db, opts)

      An intialize method for remote blast search on NCBI

--- Bio::Blast#genomenet(program, db, opts)

      An intialize method for remote blast search on GenomeNet


--- Bio::Blast#query(fna)

      Execute blast search.
      Returns Bio::Blast::Report Object

--- Bio::Blast#exec(fna)

      Alias for Bio::Blast#query

--- Bio::Blast#blastall?

      Check true if @blastall excutable

--- Bio::Blast#db?

      Check true if @db redable


= Bio::Blast::Report

--- Bio::Blast::Report#new(xml)

      Constructor method
      xml as blastall -m 7 report

--- Bio::Blast::Report#program
--- Bio::Blast::Report#version
--- Bio::Blast::Report#reference
--- Bio::Blast::Report#db
--- Bio::Blast::Report#query_ID
--- Bio::Blast::Report#query_def
--- Bio::Blast::Report#query_len
--- Bio::Blast::Report#prameters -> hsh

      Keys: expect, include, sc-match, sc-mismatch, gap-open, gap-extend
            filter

--- Bio::Blast::Report#statistics -> hsh

      Keys: db-num, db-len, hsp-len, eff-space, kappa, db, db-num

--- Bio::Blast::Report#iteration -> hsh


= Bio::Blast::Iteration
--- Bio::Blast::Iteration#num
--- Bio::Blast::Iteration#add_hit(Bio::Blast::Hit)
--- Bio::Blast::Iteration#hits -> ary


= Bio::Blast::Hit
--- Bio::Blast::Hit#num
--- Bio::Blast::Hit#_id
--- Bio::Blast::Hit#_def
--- Bio::Blast::Hit#accession
--- Bio::Blast::Hit#len
--- Bio::Blast::Hit#add_hsp(Bio::Blsat::Hsp)
--- Bio::Blast::Hit#hsps -> ary

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



= EXAMPLE

require 'bio/appl/blast'


blastall = '/bio/bin/blastall'
db = '/bio/db/blast/genome/bsu'
opts = {'-e' => 0.0, '-F' => 'F'}
bls = Bio::Blast.local(blastall, 'blastn', db, opts)

res = bla.query(fna)

# res = Bio::Blast::Report.new(xml)
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
res.parameters['gap-open'] #=> 5        <Parameters_gap-open>
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

= DTD files

* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.mod
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_Entity.mod

= See also

blastall

=end

