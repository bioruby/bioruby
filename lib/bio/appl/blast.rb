#
# = bio/appl/blast.rb - BLAST wrapper
# 
# Copyright::  Copyright (C) 2001
#              Mitsuteru C. Nakao <n@bioruby.org>
# Copyrigth::  Copyright (C) 2002,2003
#              KATAYAMA Toshiaki <k@bioruby.org>
# License::    Ruby's
#
# $Id: blast.rb,v 1.28 2006/02/18 16:08:10 nakao Exp $
#
# = Description
#
# = Examples
#
#   program = 'blastp'
#   database = 'SWISS'
#   options = '-e 0.0001'
#   serv = Bio::Blast.new(program, database, options)
#   server = 'genomenet'
#   genomenet = Bio::Blast.remote(program, database, options, server)
#   report = serv.query(sequence_text)
#
# = References
#
# * http://www.ncbi.nlm.nih.gov/blast/
#
# * http://blast.genome.jp/ideas/ideas.html#blast
#

require 'net/http'
require 'cgi' unless defined?(CGI)
require 'bio/command'
require 'shellwords'

module Bio

  # BLAST wrapper
  #
  # == Description
  #
  # A blastall program wrapper.
  #
  # == Examples
  #
  #   program = 'blastp'
  #   database = 'SWISS'
  #   options = '-e 0.0001'
  #   serv = Bio::Blast.new(program, database, options)
  #   
  #   server = 'genomenet'
  #   genomenet = Bio::Blast.remote(program, database, options, server)
  #   
  #   report = serv.query(sequence_text)
  #
  # == Available databases for Blast.remote(@program, @db, option, 'genomenet')
  #
  # ----------+-------+---------------------------------------------------
  #  @program | query | @db (supported in GenomeNet)
  # ----------+-------+---------------------------------------------------
  #  blastp   | AA    | nr-aa, genes, vgenes.pep, swissprot, swissprot-upd,
  # ----------+-------+ pir, prf, pdbstr
  #  blastx   | NA    | 
  # ----------+-------+---------------------------------------------------
  #  blastn   | NA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  # ----------+-------+ htgs, dbsts, embl-nonst, embnonst-upd, epd,
  #  tblastn  | AA    | genes-nt, genome, vgenes.nuc
  # ----------+-------+---------------------------------------------------
  #
  # * See http://blast.genome.jp/ideas/ideas.html#blast for more details.
  #
  class Blast

    autoload :Fastacmd,     'bio/io/fastacmd'
    autoload :Report,       'bio/appl/blast/report'
    autoload :Default,      'bio/appl/blast/format0'
    autoload :WU,           'bio/appl/blast/wublast'
    autoload :Bl2seq,       'bio/appl/bl2seq/report'

    include Bio::Command::Tools

    # Sets up the blast program at the localhost
    def self.local(program, db, option = '')
      self.new(program, db, option, 'local')
    end

    # Sets up the blast program at the remote host (server)
    def self.remote(program, db, option = '', server = 'genomenet')
      self.new(program, db, option, server)
    end

    # the method Bio::Blast.report is moved from bio/appl/blast/report.rb.
    # only for xml format
    def self.reports(input, parser = nil)
      ary = []
      input.each("</BlastOutput>\n") do |xml|
        xml.sub!(/[^<]*(<?)/, '\1') # skip before <?xml> tag
        next if xml.empty?          # skip trailing no hits
        if block_given?
          yield Report.new(xml, parser)
        else
          ary << Report.new(xml, parser)
        end
      end
      return ary
    end


    # Program name for blastall -p (blastp, blastn, blastx, tblastn or tblastx).
    attr_accessor :program

    # Database name for blastall -d
    attr_accessor :db
    
    # Options for blastall 
    attr_accessor :options

    # 
    attr_accessor :server

    # Full path for blastall. (default: 'blastall').
    attr_accessor :blastall

    # Substitution matrix for blastall -M
    attr_accessor :matrix

    # Filter option for blastall -F (T or F).
    attr_accessor :filter

    # Returns a String containing blast execution output in as is the Bio::Blast#format.
    attr_reader :output

    # Output report format for blastall -m 
    #
    # 0, pairwise; 1; 2; 3; 4; 5; 6; 7, XML Blast outpu;, 8, tabular; 
    # 9, tabular with comment lines; 10, ASN text; 11, ASN binery [intege].
    attr_reader :format

    #
    attr_writer :parser  # to change :xmlparser, :rexml, :tab


    # Returns a blast factory object (Bio::Blast).
    #
    # --- Bio::Blast.new(program, db, option = '', server = 'local')
    # --- Bio::Blast.local(program, db, option = '')
    # --- Bio::Blast.remote(program, db, option = '', server = 'genomenet')
    #
    # For the develpper, you can add server 'hoge' by adding
    # exec_hoge(query) method.
    #
    def initialize(program, db, opt = [], server = 'local')
      @program  = program
      @db       = db
      @server   = server

      @blastall = 'blastall'
      @matrix   = nil
      @filter   = nil

      @output   = ''
      @parser   = nil

      begin
        a = opt.to_ary
      rescue NameError #NoMethodError
        # backward compatibility
        a = Shellwords.shellwords(opt)
      end
      unless a.find { |x| /\A\-m/ =~ x.to_s } then
        if defined?(XMLParser) or defined?(REXML)
          @format = 7
        else
          @format = 8
        end
      end
      @options = [ *a ]
    end

    # Execute blast search and returns Report object (Bio::Blast::Report).
    def query(query)
      return self.send("exec_#{@server}", query.to_s)
    end

    # option reader
    def option
      # backward compatibility
      make_command_line(@options)
    end

    # option setter
    def option=(str)
      # backward compatibility
      @options = Shellwords.shellwords(str)
    end


    private


    def parse_result(data)
      Report.new(data, @parser)
    end


    def exec_local(query)
      cmd = [ @blastall, '-p', @program, '-d', @db ]
      cmd.concat([ '-M', @matrix ]) if @matrix
      cmd.concat([ '-F', @filter ]) if @filter
      cmd.concat([ '-m', @format.to_s ]) if @format
      cmd.concat(@options) if @options

      report = nil

      @output = call_command_local(cmd, query)
      report = parse_result(@output)

      return report
    end


    def exec_genomenet(query)
      host = "blast.genome.jp"
      #path = "/sit-bin/nph-blast"
      path = "/sit-bin/blast" #2005.08.12

      matrix = @matrix ? @matrix : 'blosum62'
      filter = @filter ? @filter : 'T'

      opt = []
      opt.concat([ '-m', @format.to_s ]) if @format
      opt.concat(@options) if @options

      form = {
        'style'          => 'raw',
        'prog'           => @program,
        'dbname'         => @db,
        'sequence'       => CGI.escape(query),
        'other_param'    => CGI.escape(make_command_line_unix(opt)),
        'matrix'         => matrix,
        'filter'         => filter,
        'V_value'        => 500, # default value for GenomeNet
        'B_value'        => 250, # default value for GenomeNet
        'alignment_view' => 0,
      }

      data = []

      form.each do |k, v|
        data.push("#{k}=#{v}") if v
      end

      report = nil

      begin
        http = Net::HTTP.new(host)
        http.open_timeout = 300
        http.read_timeout = 600
        result, = http.post(path, data.join('&'))
        @output = result.body
        # workaround 2005.08.12
        if /\<A +HREF=\"(http\:\/\/blast\.genome\.jp(\/tmp\/[^\"]+))\"\>Show all result\<\/A\>/i =~ @output.to_s then
          result, = http.get($2)
          @output = result.body
          txt = @output.to_s.split(/\<pre\>/)[1]
          raise 'cannot understand response' unless txt
          txt.sub!(/\<\/pre\>.*\z/m, '')
          txt.sub!(/.*^ \-{20,}\s*/m, '')
          @output = txt.gsub(/\&lt\;/, '<')
          report = parse_result(@output)
        else
          raise 'cannot understand response'
        end
      end

      return report
    end

    def exec_ncbi(query)
      raise NotImplementedError
    end

  end # class Blast

end # module Bio


if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue
  end

# serv = Bio::Blast.local('blastn', 'hoge.nuc')
# serv = Bio::Blast.local('blastp', 'hoge.pep')
  serv = Bio::Blast.remote('blastp', 'genes')

  query = ARGF.read
  p serv.query(query)
end


