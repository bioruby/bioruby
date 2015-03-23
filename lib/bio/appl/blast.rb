#
# = bio/appl/blast.rb - BLAST wrapper
# 
# Copyright::  Copyright (C) 2001,2008  Mitsuteru C. Nakao <n@bioruby.org>
# Copyright::  Copyright (C) 2002,2003  Toshiaki Katayama <k@bioruby.org>
# Copyright::  Copyright (C) 2006       Jan Aerts <jan.aerts@bbsrc.ac.uk>
# Copyright::  Copyright (C) 2008       Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#

require 'bio/command'
require 'shellwords'
require 'stringio'
require 'bio/io/flatfile'

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
  #   remote_blast_factory = Bio::Blast.remote('blastp', 'swissprot',
  #                                            '-e 0.0001', 'genomenet')
  #   #or:
  #   local_blast_factory = Bio::Blast.local('blastn','/path/to/db')
  #
  #   #   2. run the actual BLAST by querying the factory
  #   report = remote_blast_factory.query(sequence_text)
  #
  #   # Then, to parse the report, see Bio::Blast::Report
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
    autoload :Report_tab,   'bio/appl/blast/report'
    autoload :Default,      'bio/appl/blast/format0'
    autoload :WU,           'bio/appl/blast/wublast'
    autoload :Bl2seq,       'bio/appl/bl2seq/report'
    autoload :RPSBlast,     'bio/appl/blast/rpsblast'
    autoload :NCBIOptions,  'bio/appl/blast/ncbioptions'
    autoload :Remote,       'bio/appl/blast/remote'

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
    # * _blastall_: full path to blastall program (e.g. "/opt/bin/blastall"; DEFAULT: "blastall")
    # *Returns*:: Bio::Blast factory object
    def self.local(program, db, options = '', blastall = nil)
      f = self.new(program, db, options, 'local')
      if blastall then
        f.blastall = blastall
      end
      f
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

 
    # Bio::Blast.report parses given data, 
    # and returns an array of report 
    # (Bio::Blast::Report or Bio::Blast::Default::Report) objects,
    # or yields each report object when a block is given.
    #
    # Supported formats: NCBI default (-m 0), XML (-m 7), tabular (-m 8).
    #
    # ---
    # *Arguments*:
    # * _input_ (required): input data
    # * _parser_: type of parser. see Bio::Blast::Report.new
    # *Returns*:: Undefiend when a block is given. Otherwise, an Array containing report (Bio::Blast::Report or Bio::Blast::Default::Report) objects.
    def self.reports(input, parser = nil)
      begin
        istr = input.to_str
      rescue NoMethodError
        istr = nil
      end
      if istr then
        input = StringIO.new(istr)
      end
      raise 'unsupported input data type' unless input.respond_to?(:gets)

      # if proper parser is given, emulates old behavior.
      case parser
      when :xmlparser, :rexml
        ff = Bio::FlatFile.new(Bio::Blast::Report, input)
        if block_given? then
          ff.each do |e|
            yield e
          end
          return []
        else
          return ff.to_a
        end
      when :tab
        istr = input.read unless istr
        rep = Report.new(istr, parser)
        if block_given? then
          yield rep
          return []
        else
          return [ rep ]
        end
      end

      # preparation of the new format autodetection rule if needed
      if !defined?(@@reports_format_autodetection_rule) or
          !@@reports_format_autodetection_rule then
        regrule = Bio::FlatFile::AutoDetect::RuleRegexp
        blastxml = regrule[ 'Bio::Blast::Report',
                            /\<\!DOCTYPE BlastOutput PUBLIC / ]
        blast    = regrule[ 'Bio::Blast::Default::Report',
                            /^BLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/ ]
        tblast   = regrule[ 'Bio::Blast::Default::Report_TBlast',
                            /^TBLAST.? +[\-\.\w]+ +\[[\-\.\w ]+\]/ ]
        tab      = regrule[ 'Bio::Blast::Report_tab',
                            /^([^\t]*\t){11}[^\t]*$/ ]
        auto = Bio::FlatFile::AutoDetect[ blastxml,
                                          blast,
                                          tblast,
                                          tab
                                        ]
        # sets priorities
        blastxml.is_prior_to blast
        blast.is_prior_to tblast
        tblast.is_prior_to tab
        # rehash
        auto.rehash
        @@report_format_autodetection_rule = auto
      end

      # Creates a FlatFile object with dummy class
      ff = Bio::FlatFile.new(Object, input)
      ff.dbclass = nil

      # file format autodetection
      3.times do
        break if ff.eof? or
          ff.autodetect(31, @@report_format_autodetection_rule)
      end
      # If format detection failed, assumed to be tabular (-m 8)
      ff.dbclass = Bio::Blast::Report_tab unless ff.dbclass

      if block_given? then
        ff.each do |entry|
          yield entry
        end
        ret = []
      else
        ret = ff.to_a
      end
      ret
    end

    #--
    # the method Bio::Blast.reports is moved from bio/appl/blast/report.rb.
    #++
     
    # Note that this is the old implementation of Bio::Blast.reports.
    # The aim of this method is keeping compatibility for older BLAST
    # XML documents which might not be parsed by the new
    # Bio::Blast.reports nor Bio::FlatFile.
    # (Though we are not sure whether such documents exist or not.)
    #
    # Bio::Blast.reports_xml parses given data, 
    # and returns an array of Bio::Blast::Report objects, or
    # yields each Bio::Blast::Report object when a block is given.
    #
    # It can be used only for XML format.
    # For default (-m 0) format, consider using Bio::FlatFile, or
    # Bio::Blast.reports.
    #
    # ---
    # *Arguments*:
    # * _input_ (required): input data
    # * _parser_: type of parser. see Bio::Blast::Report.new
    # *Returns*:: Undefiend when a block is given. Otherwise, an Array containing Bio::Blast::Report objects.
    def self.reports_xml(input, parser = nil)
      ary = []
      input.each_line("</BlastOutput>\n") do |xml|
        xml.sub!(/[^<]*(<?)/, '\1') # skip before <?xml> tag
        next if xml.empty?          # skip trailing no hits
        rep = Report.new(xml, parser)
        if rep.reports then
          if block_given?
            rep.reports.each { |r| yield r }
          else
            ary.concat rep.reports
          end
        else
          if block_given?
            yield rep
          else
            ary.push rep
          end
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
    attr_reader :options

    # Sets options for blastall
    def options=(ary)
      @options = set_options(ary)
    end

    # Server to submit the BLASTs to
    attr_reader :server

    # Sets server to submit the BLASTs to.
    # The exec_xxxx method should be defined in Bio::Blast or
    # Bio::Blast::Remote::Xxxx class.
    def server=(str)
      @server = str
      begin
        m = Bio::Blast::Remote.const_get(@server.capitalize)
      rescue NameError
        m = nil
      end
      if m and !(self.is_a?(m)) then
        # lazy include Bio::Blast::Remote::XXX module
        self.class.class_eval { include m }
      end
      return @server
    end

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
    attr_accessor :format

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

      @blastall = 'blastall'
      @matrix   = nil
      @filter   = nil

      @output   = ''
      @parser   = nil
      @format   = nil

      @options = set_options(opt, program, db)
      self.server = server
    end


    # This method submits a sequence to a BLAST factory, which performs the
    # actual BLAST.
    # 
    #   # example 1
    #   seq = Bio::Sequence::NA.new('agggcattgccccggaagatcaagtcgtgctcctg')
    #   report = blast_factory.query(seq)
    #
    #   # example 2
    #   str <<END_OF_FASTA
    #   >lcl|MySequence
    #   MPPSAISKISNSTTPQVQSSSAPNLTMLEGKGISVEKSFRVYSEEENQNQHKAKDSLGF
    #   KELEKDAIKNSKQDKKDHKNWLETLYDQAEQKWLQEPKKKLQDLIKNSGDNSRVILKDS
    #   END_OF_FASTA
    #   report = blast_factory.query(str)
    #
    # Bug note: When multi-FASTA is given and the format is 7 (XML) or 8 (tab),
    # it should return an array of Bio::Blast::Report objects,
    # but it returns a single Bio::Blast::Report object.
    # This is a known bug and should be fixed in the future.
    # 
    # ---
    # *Arguments*:
    # * _query_ (required): single- or multiple-FASTA formatted sequence(s)
    # *Returns*:: a Bio::Blast::Report (or Bio::Blast::Default::Report) object when single query is given. When multiple sequences are given as the query, it returns an array of Bio::Blast::Report (or Bio::Blast::Default::Report) objects. If it can not parse result, nil will be returnd.
    def query(query)
      case query
      when Bio::Sequence
        query = query.output(:fasta)
      when Bio::Sequence::NA, Bio::Sequence::AA, Bio::Sequence::Generic
        query = query.to_fasta('query', 70)
      else
        query = query.to_s
      end

      @output = self.__send__("exec_#{@server}", query)
      report = parse_result(@output)
      return report
    end

    # Returns options of blastall
    def option
      # backward compatibility
      Bio::Command.make_command_line(options)
    end

    # Set options for blastall
    def option=(str)
      # backward compatibility
      self.options = Shellwords.shellwords(str)
    end

    private

    def set_options(opt = nil, program = nil, db = nil)
      opt = @options unless opt

      # when opt is a String, splits to an array
      begin
        a = opt.to_ary
      rescue NameError #NoMethodError
        # backward compatibility
        a = Shellwords.shellwords(opt)
      end
      ncbiopt = NCBIOptions.new(a)

      if fmt = ncbiopt.get('-m') then
        @format = fmt.to_i
      else
        _ = Bio::Blast::Report #dummy to load XMLParser or REXML
        if defined?(XMLParser) or defined?(REXML)
          @format ||= 7
        else
          @format ||= 8
        end
      end

      mtrx = ncbiopt.get('-M')
      @matrix = mtrx if mtrx
      fltr = ncbiopt.get('-F')
      @filter = fltr if fltr

      # special treatment for '-p'
      if program then
        @program = program
        ncbiopt.delete('-p')
      else
        program = ncbiopt.get('-p')
        @program = program if program
      end

      # special treatment for '-d'
      if db then
        @db = db
        ncbiopt.delete('-d')
      else
        db = ncbiopt.get('-d')
        @db = db if db
      end

      # returns an array of string containing options
      return ncbiopt.options
    end

    # parses result
    def parse_result(str)
      if @format.to_i == 0 then
        ary = Bio::FlatFile.open(Bio::Blast::Default::Report,
                                 StringIO.new(str)) { |ff| ff.to_a }
        case ary.size
        when 0
          return nil
        when 1
          return ary[0]
        else
          return ary
        end
      else
        Report.new(str, @parser)
      end
    end

    # returns an array containing NCBI BLAST options
    def make_command_line_options
      set_options
      cmd = []
      if @program
        cmd.concat([ '-p', @program ])
      end
      if @db
        cmd.concat([ '-d', @db ])
      end
      if @format
        cmd.concat([ '-m', @format.to_s ])
      end
      if @matrix
        cmd.concat([ '-M', @matrix ]) 
      end
      if @filter
        cmd.concat([ '-F', @filter ]) 
      end
      ncbiopts = NCBIOptions.new(@options)
      ncbiopts.make_command_line_options(cmd)
    end

    # makes command line.
    def make_command_line
      cmd = make_command_line_options
      cmd.unshift @blastall
      cmd
    end

    # Local execution of blastall
    def exec_local(query)
      cmd = make_command_line
      @output = Bio::Command.query_command(cmd, query)
      return @output
    end

    # This method is obsolete.
    #
    # Runs genomenet with '-m 8' option.
    # Note that the format option is overwritten.
    def exec_genomenet_tab(query)
      warn "Bio::Blast#server=\"genomenet_tab\" is deprecated."
      @format = 8
      exec_genomenet(query)
    end

  end # class Blast

end # module Bio

