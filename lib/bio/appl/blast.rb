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
#  $Id: blast.rb,v 1.8 2002/01/07 08:51:27 nakao Exp $
#

require 'net/http'
require 'cgi-lib'
begin
  require 'xmlparser'
rescue LoadError
end

module Bio
  class Blast
    class BlastExecError < StandardError;    end
    class BlastOptionsError < ArgumentError; end
    class Options;                           end
    class Report
      class XMLRetry < Exception; end
      class Iteration;            end
      class Hit;                  end
      class Hsp;                  end
    end
  end
end



module Bio

  class Blast

    ## Bio::Blast.new 
    # Constructor is called by Blast.remote or Blast.local class method. 
    #
    # ARGUMENTS:
    # server = { 'host'       => 'localhost',
    #            'port'       => 8080, 
    #            'path'       => '/blast.cgi',
    #            'proxy'      => 'proxy', 
    #            'proxy_port' => 8000 }
    # opts   = {'-m' => 7, '-e' => 0.0001 , ...}
    #
    def initialize(server = nil, blastall = nil, \
		   program = nil, db = nil, opts = nil)
      @server   = server
      @blastall = blastall
      @program  = program
      @db       = db
      if opts.is_a? Options
	@opts = opts
      else
	@opts = Options.new(opts)
      end
      @io       = nil
    end
    attr_accessor :server, :program, :db, :opts

    # Blast#server['pryxy'] = 'proxy'
    # Blast#server['pryxy_port'] = 8000
    #

    ##
    # Constructor for local blastall
    # blastall: /path/to/blastall
    # program:  (blastp|blastn|tblastx|blasty|...)
    # db:       /path/to/db
    # opts:     {'-e' => 0.1, ... } 
    def Blast.local(blastall, program, db, opts = nil)
      self.new(nil, blastall, program, db, opts)
    end

    ##
    # Constructor for remote blast server
    #
    # opts = Bio::Blast::Options.new(opts)
    # opts.set(blast_opt_code, cgi_post_key, default_value)
    # opts.set_value(blast_opt_code, value)
    #
    # server['server']
    # server['host']
    # server['path']
    def Blast.remote(server, program, db, opts)
      self.new(server, nil, program, db, opts)
    end

    ##
    # query in (multi) fasta format file in String
    def query(query) 
      if @server
	return remote_blast(query)
      else
	return local_blast(query)
      end
    end
    alias exec query

    
    ##
    # execute blastall in remote server
    def remote_blast(query)
      @opts.set_value('-i', CGI.escape(query))
      @opts.set_value('-d', CGI.escape(@db))
      @opts.set_value('-p', CGI.escape(@program))

      http = Net::HTTP.new(@server['host'])
      response, result = http.post(@server['path'], @opts.post_data)

      result.sub!(@server['post_proc'],'')
      
      reports = result.split("\n<\\?xml").collect { |entry|	
	if entry =~ /^<.xml/
	  Report.new(entry)
	else
	  if entry =~ /DOCTYPE BlastOutput PUBLIC/
	    Report.new('<?xml'+entry)
	  end
	end
      }
      reports.delete(nil)
      return reports
    end
    private :remote_blast
    
    
    ##
    # execute blastall in local machine
    def local_blast(query)
      cmd = "#{@blastall} -p #{@program} -d #{@db} -m 7"
      cmd += @opts.checkout

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
    # Bio::Blast::Options 
    # Contains blast_opts_name, cgi_name, cgi_value and cgi_default for each 
    # options for specific remote blast server.
    #
    class Options
      @codes = 'eFGEXIqrvbfgQDaOJMWzkPYSTlUyZRnLA'
      def initialize(options)
	# blastall 2.2.1
	@opts = options
	@name = Hash.new
	@value = Hash.new
	@default = Hash.new
      end
      attr_reader :codes, :opts

      def Options.codes
	Regexp.new("^-[#{@codes}]$")
      end
      
      # checkout options
      def checkout
	cmd = ''
	@opts.each do |k,v|
	  if k =~ Options.codes
	    cmd += " #{k} #{v} "
	  else
	    raise BlastOptionsError, "Error: Invalid option #{k} #{v}"
	  end
	end
	return cmd
      end

      def set(opt_code, name, default = nil)
	@name[opt_code] = name
	@default[opt_code] = default unless default == nil
      end

      def set_value(opt_code, value)
	@value[opt_code] = value
      end

      def get(opt_code = nil, value = nil)
	if opt_code
	  if value == nil
	    value = @default[opt_code]
	  end
	  return "#{@name[opt_code]}=#{value}"
	else
	  list = @name.keys.collect { |opt_code|
	    self.get(opt_code, @value[opt_code])
	  }
	  return list.join('&')
	end
      end                 
      alias post_data get

    end                  # class Bio::Blast::Options



    ##
    # Blast (-m 7) XML Report Parser Class
    # xmlparser used.
    # This class is tested blastn -m 7 report only.
    class Report

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


      def parse(xml)
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
	  @db = entry[tag].strip
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


#
# set specific remote blast servers
# 
#
module Bio
  class Blast

    #
    # Constructor for remote blast server on NCBI
    #
    def Blast.ncbi(program, db, options = nil)
      #
      # See also http://www.ncbi.nlm.nih.gov/BLAST/
      #
      opts = Options.new(options)
      #Blast_opts_code, cgi_post_tag, default_value
      opts.set('-i', '')
      opts.set('-p', '')
      opts.set('-d', 'database',         'nr')
      opts.set('-e', 'expect',           '10')
      opts.set('-m', 'alignment_view',   '7')
      opts.set('-F', 'filter',           'F')
      opts.set('-v', 'descriptions',     '500')
      opts.set('-b', 'alignments',       '500')
      opts.set('-M', 'matrix',           'BLOSUM62')
      opts.set('-Q', 'queryGeneticCode', '1')
      opts.set('-G', 'advancedOptionG',  '11') 
      opts.set('-E', 'advancedOptionE',  '1')
      opts.set('-q', 'advancedOptionQ',  '-3')
      opts.set('-r', 'advancedOptionR',  '1') 
      opts.set('-W', 'advancedOptionW',  '11')
      opts.set('Protocol', 'resultReturnProtocol', 'www')  # or 'email'
      opts.set('minLen',   'minimumLength',        '30')
      opts.set('minLenP',  'minimumLengthProtein', '10')
      opts.set('maxLen',   'maximumLength',        '100000')
      opts.set('maxLenP',  'maximumLengthProtein', '50000')

      server = {'server' => 'NCBI',
        	'host'   => 'www.ncbi.nlm.nih.gov',
   	        'path'   => '/blast/blast.cgi',
                'post_proc' => '' }

      self.new(server, nil, program, db, opts)
    end

    #
    # constructor for remote blast server on GenomeNet
    #
    def Blast.genomenet(program, db, options = nil)
      #
      # See also http://blast.genome.ad.jp/
      # 
      opts = Options.new(options)
      # sequence: sequence 
      opts.set('-i',    'sequence')
      # prog    : blastn,blastp,tblastn,blastx
      opts.set('-p',    'prog')
      # dbname  : nr-aa,genes,vgenes,swissprot,swissprot-upd,pir,prf,pdbstr,
      #           nr-nt,genbank-nonst,gbnonst-upd,dbest,dbgss,htgs,dbsts,
      #           embl-nonst,embnonst-upd,epd,genes-nt,genome,vgenes-nt,vgenome
      opts.set('-d',    'dbname')
      # alignment_view : 7 (-m)
      opts.set('-m',    'alignment_view', '7')
      # * Set the maximum number of database sequences to be reported
      opts.set('-v',    'V_value',        '500')
      # * Set the maximum number of alignments to be displayed
      opts.set('-b',    'B_value',        '250')
      # addr    : e-mail address
      opts.set('addr',  'addr')
      # matrix  : blosum62,blosum80,pam30,pam70,pam250
      opts.set('-M',    'matrix',         'blosum62')
      # * If necessary, select the filter to mask your query sequence
      opts.set('-F',    'filter',         'F')
      opts.set('other', 'other_param')
      opts.set_value('other', CGI.escape(opts.opts.to_a.flatten.join(' ')))

      server = {'server'    => 'GenomeNet',
	        'host'      => 'blast.genome.ad.jp',
	        'path'      => '/sit-bin/nph-blast',
	        'post_proc' => "\n</PRE>\n\n</BODY>\n\n</HTML>\n\n" }

      self.new(server, nil, program, db, opts)
    end

  end       # class Blast
end         # module Bio



# Testing code

if __FILE__ == $0

  require 'bio/io/dbget'
  fna = Bio::DBGET.bget('-f -n 1 eco:b0002')

  opts = {'-e' => '10e-10', '-a' => '3', '-F' => 'T'}
  print "\tp opts\t#=> "
  p opts

#  puts "= = Bio::Blast.local = ="
#
#  blastall = '/bio/bin/blastall'     # option
#  db = '/bio/db/blast/genome/mtu'    # option
#
#  bls = Bio::Blast.local(blastall, 'blastn', db, opts)

  bls = Bio::Blast.genomenet('blastp', 'genes', opts)
  print "\tp bls\t#=> "
  p bls

  puts "\n = Bio::Blast.query(fna) ="
  bs = bls.query(fna)

#  puts "\n = Bio::Blast.blastall? =="
#  p bls.blastall?
#  puts "\n = Bio::Blast.db? ="
#  p bls.db?


  puts "\n = p fna ="
  puts fna

  puts "\n = Bio::Blast.query(fna) ="
  reports = bls.query(fna)

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
    print "\tb.query_ID   #=> "
    p b.query_ID
    print "\tb.query_def  #=> "
    p b.query_def
    print "\tb.query_len  #=> "
    p b.query_len
    
    puts "\n= = Parameters = ="
    p b.parameters

    puts "\n= = Statistics = ="
    p b.statistics

  
    puts "\n= = b.itreration.each do |itr| "
    b.iteration.each do |itr|
      puts "\n= = Bio::Blast::Report::Iteration = ="
      
      print "\titr.num        #=> "
      p itr.num

      print "\titr.hits.size  #=> "
      p itr.hits.size

      puts "\n= = itr.hits.each do |hit| "
      itr.hits.each do |hit|
	puts "\n = = Bio::Blast::Report::Hit = ="
	print "\thit.num       #=> "
	p hit.num
	print "\thit._id       #=> "
	p hit._id
	print "\thit._def      #=> "
	p hit._def
	print "\thit.accession #=> "
	p hit.accession
	print "\thit.len       #=> "
	p hit.len

	print "\thit.hsps.size #=> "
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
	  print "\thsp.query_from   #=> "
	  p hsp.query_from

	  p
	  puts "#{hsp.query_from} .. #{hsp.query_to}"
	  puts "query: #{hsp.qseq}"
	  puts "       #{hsp.midline}"
	  puts "hit:   #{hsp.hseq}"
	  puts "#{hsp.hit_from} .. #{hsp.hit_to}"
	end
      end
    end
  end

end	    



=begin

= Bio::Blast

--- Bio::Blast#local(blastall, program, db, opts)

      An intialize method for local blast search
      opts = {'-e' => '10e-3', ... }

--- Bio::Blast#remote(uri, program, db, opts)

      An intialize method for remote blast search
      opts.is_a Options

--- Bio::Blast#ncbi(program, db, opts)

      An intialize method for remote blast search on NCBI
      opts = {'-e' => '10e-3', ... }
      _Not yet implimented_.

--- Bio::Blast#genomenet(program, db, opts)

      An intialize method for remote blast search on GenomeNet
      opts = {'-e' => '10e-3', ... }


--- Bio::Blast#query(fna)

      Execute blast search.
      Returns Bio::Blast::Report Object

--- Bio::Blast#exec(fna)

      Alias for Bio::Blast#query

--- Bio::Blast#blastall?

      Check true if @blastall excutable

--- Bio::Blast#db?

      Check true if @db redable

= Bio::Blast::Options
--- Bio::Blast::Options.new(opts)

      Constructor. 
      opts = {'-e' => '10e-3', ... }

--- Bio::Blast::Options.codes

      An Regexp instance for checking arguments for blastall.

--- Bio::Blast::Options#checkout

      Checkout options. Returns arguments String for blastall.

--- Bio::Blast::Options#set(opt_code, post_tag, default = nil)

      Set an cgi posting configuration (blast option code, cgi tag and
      default value).

--- Bio::Blast::Options#set_value(opt_code, value)

      Set value to opt_code.

--- Bio::Blast::Options#get(opt_code)

      Returns values by blast opt_code.

--- Bio::Blast::Options#post_data
   
      Returns String for remote blast CGI POST data.

= Bio::Blast::Report

--- Bio::Blast::Report#new(xml)

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
--- Bio::Blast::Hit#_id
--- Bio::Blast::Hit#_def
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



= EXAMPLE

* blast on localhost

  require 'bio/appl/blast'

  blastall = '/bio/bin/blastall'
  db = '/bio/db/blast/genome/bsu'
  opts = {'-e' => '10e-3', '-F' => 'F'}
  bla = Bio::Blast.local(blastall, 'blastn', db, opts)
  bla.query(fna).each { |report| ... }


* blast via remote host
  * blast via GenomeNet server

    require 'bio/appl/blast'
    opts = {'-e' => '10e-3', '-F' => 'F'}
    bla = Bio::Blast.genomnet('blastp', 'genes', opts)
    bla.query(faa).each {|report| ... }

  * blast via NCBI server

    require 'bio/appl/blast'
    opts = {'-e' => '10e-3', '-F' => 'F'}
    bla = Bio::Blast.ncbi('blastp', 'genes', opts)
    bla.query(faa).each {|report| ... }

  * blast via a remote server as you like

    require 'bio/appl/blast'
    options = {'-e' => '10e-3', '-F' => 'F'}
    opts = Bio::Blast::Options.new(options)
    opts.set('-i', 'sequence') 
    opts.set('-m', 'alignment', '7')
    ...
    server = {'server' => 'MyBlastServer',
              'host'   => 'www.mydomain.hoge',
              'path'   => '/cgi-bin/blast.cgi',
              'post_proc' => '' }
    bla = Bio::Blast.remote(server, 'blastp', 'genes', opts)
    bla.query(faa).each {|report| ... }




= DTD files

* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.dtd
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_BlastOutput.mod
* http://www.ncbi.nlm.nih.gov/dtd/NCBI_Entity.mod

= See also

blastall

=end

