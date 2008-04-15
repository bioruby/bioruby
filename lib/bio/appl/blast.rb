#
# = bio/appl/blast.rb - BLAST wrapper
# 
# Copyright::  Copyright (C) 2001,2008  Mitsuteru C. Nakao <n@bioruby.org>
# Copyright::  Copyright (C) 2002,2003  Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006       Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id: blast.rb,v 1.35 2008/04/15 13:54:39 ngoto Exp $
#

require 'net/http'
require 'cgi' unless defined?(CGI)
require 'bio/command'
require 'shellwords'

module Bio

  # == Description
  # 
  # The Bio::Blast class contains methods for running local or remote BLAST
  # searches, as well as for parsing of the output of such BLASTs (i.e. the
  # BLAST reports). For more information on similarity searches and the BLAST
  # program, see http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/similarity.html.
  #
  # == Usage
  #
  #   require 'bio'
  #   
  #   # To run an actual BLAST analysis:
  #   #   1. create a BLAST factory
  #   remote_blast_factory = Bio::Blast.remote('blastp', 'SWISS',
  #                                            '-e 0.0001', 'genomenet')
  #   #or:
  #   local_blast_factory = Bio::Blast.local('blastn','/path/to/db')
  #
  #   #   2. run the actual BLAST by querying the factory
  #   report = remote_blast_factory.query(sequence_text)
  #
  #   # Then, to parse the report, see Bio::Blast::Report
  #
  # === Available databases for Bio::Blast.remote
  #
  #  ----------+-------+---------------------------------------------------
  #   program  | query | db (supported in GenomeNet)
  #  ----------+-------+---------------------------------------------------
  #   blastp   | AA    | nr-aa, genes, vgenes.pep, swissprot, swissprot-upd,
  #  ----------+-------+ pir, prf, pdbstr
  #   blastx   | NA    | 
  #  ----------+-------+---------------------------------------------------
  #   blastn   | NA    | nr-nt, genbank-nonst, gbnonst-upd, dbest, dbgss,
  #  ----------+-------+ htgs, dbsts, embl-nonst, embnonst-upd, epd,
  #   tblastn  | AA    | genes-nt, genome, vgenes.nuc
  #  ----------+-------+---------------------------------------------------
  #
  # == See also
  #
  # * Bio::Blast::Report
  # * Bio::Blast::Report::Hit
  # * Bio::Blast::Report::Hsp
  #
  # == References
  # 
  # * http://www.ncbi.nlm.nih.gov/blast/
  # * http://www.ncbi.nlm.nih.gov/Education/BLASTinfo/similarity.html
  # * http://blast.genome.jp/ideas/ideas.html#blast
  #
  class Blast

    autoload :Fastacmd,     'bio/io/fastacmd'
    autoload :Report,       'bio/appl/blast/report'
    autoload :Default,      'bio/appl/blast/format0'
    autoload :WU,           'bio/appl/blast/wublast'
    autoload :Bl2seq,       'bio/appl/bl2seq/report'
    autoload :RPSBlast,     'bio/appl/blast/rpsblast'

    # This is a shortcut for Bio::Blast.new:
    #  Bio::Blast.local(program, database, options)
    # is equivalent to
    #  Bio::Blast.new(program, database, options, 'local')
    # ---
    # *Arguments*:
    # * _program_ (required): 'blastn', 'blastp', 'blastx', 'tblastn' or 'tblastx'
    # * _db_ (required): name of the local database
    # * _options_: blastall options \
    # (see http://www.genome.jp/dbget-bin/show_man?blast2)
    # *Returns*:: Bio::Blast factory object
    def self.local(program, db, option = '')
      self.new(program, db, option, 'local')
    end

    # Bio::Blast.remote does exactly the same as Bio::Blast.new, but sets
    # the remote server 'genomenet' as its default.
    # ---
    # *Arguments*:
    # * _program_ (required): 'blastn', 'blastp', 'blastx', 'tblastn' or 'tblastx'
    # * _db_ (required): name of the remote database
    # * _options_: blastall options \
    # (see http://www.genome.jp/dbget-bin/show_man?blast2)
    # * _server_: server to use (DEFAULT = 'genomenet')
    # *Returns*:: Bio::Blast factory object
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


    # Program name (_-p_ option for blastall): blastp, blastn, blastx, tblastn
    # or tblastx
    attr_accessor :program

    # Database name (_-d_ option for blastall)
    attr_accessor :db
    
    # Options for blastall
    attr_accessor :options

    # Server to submit the BLASTs to
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


    # Creates a Bio::Blast factory object.
    # 
    # To run any BLAST searches, a factory has to be created that describes a
    # certain BLAST pipeline: the program to use, the database to search, any
    # options and the server to use. E.g.
    # 
    #   blast_factory = Bio::Blast.new('blastn','dbsts', '-e 0.0001 -r 4', 'genomenet')
    # 
    # ---
    # *Arguments*:
    # * _program_ (required): 'blastn', 'blastp', 'blastx', 'tblastn' or 'tblastx'
    # * _db_ (required): name of the (local or remote) database
    # * _options_: blastall options \
    # (see http://www.genome.jp/dbget-bin/show_man?blast2)
    # * _server_: server to use (e.g. 'genomenet'; DEFAULT = 'local')
    # *Returns*:: Bio::Blast factory object
    def initialize(program, db, opt = [], server = 'local')
      @program  = program
      @db       = db
      @server   = server

      @blastall = 'blastall'
      @matrix   = nil
      @filter   = nil

      @output   = ''
      @parser   = nil
      @format   = 0

      set_options(opt)
    end      


    # This method submits a sequence to a BLAST factory, which performs the
    # actual BLAST.
    # 
    #   fasta_sequences = Bio::FlatFile.open(Bio::FastaFormat, 'my_sequences.fa')
    #   report = blast_factory.query(fasta_sequences)
    # 
    # ---
    # *Arguments*:
    # * _query_ (required): single- or multiple-FASTA formatted sequence(s)
    # *Returns*:: a Bio::Blast::Report object
    def query(query)
      return self.send("exec_#{@server}", query.to_s)
    end

    # Returns options of blastall
    def option
      # backward compatibility
      Bio::Command.make_command_line(@options)
    end

    # Set options for blastall
    def option=(str)
      # backward compatibility
      @options = Shellwords.shellwords(str)
    end

    private

    def set_options(opt = nil)
      opt = @options unless opt
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
      else
        @format = a[a.index('-m') + 1].to_i
      end
      @options = [ *a ]
    end


    def parse_result(data)
      Report.new(data, @parser)
    end


    def make_command_line
      set_options
      cmd = [ @blastall, '-p', @program, '-d', @db ]
      if @matrix
        cmd.concat([ '-M', @matrix ]) 
        i = @options.index('-M')
        @options.delete_at(i)
        @options.delete_at(i)
      end
      if @filter
        cmd.concat([ '-F', @filter ]) 
        i = @options.index('-F')
        @options.delete_at(i)
        @options.delete_at(i)
      end
      if @format
        cmd.concat([ '-m', @format.to_s ])
        i = @options.index('-m')
        @options.delete_at(i)
        @options.delete_at(i)
      end
      cmd.concat(@options) if @options
    end


    def exec_local(query)
      cmd = make_command_line
      report = nil

      @output = Bio::Command.query_command(cmd, query)
      report = parse_result(@output)

      return report
    end


    def exec_genomenet_tab(query)
      @format = 8
      exec_genomenet(query)
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
        'other_param'    => CGI.escape(Bio::Command.make_command_line_unix(opt)),
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
        http = Bio::Command.new_http(host)
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

