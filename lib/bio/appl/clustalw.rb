#
# = bio/appl/clustalw.rb - CLUSTAL W wrapper class
#
# Copyright:: Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
# License::   The Ruby License
#
#  $Id: clustalw.rb,v 1.19 2007/07/16 12:27:29 ngoto Exp $
#
# Bio::ClustalW is a CLUSTAL W execution wrapper class.
# It can also be called as an alignment factory.
# CLUSTAL W is a very popular software for multiple sequence alignment.
#
# == References
#
# * Thompson,J.D., Higgins,D.G. and Gibson,T.J..
#   CLUSTAL W: improving the sensitivity of progressive multiple sequence
#   alignment through sequence weighting, position-specific gap penalties
#   and weight matrix choice. Nucleic Acids Research, 22:4673-4680, 1994.
#   http://nar.oxfordjournals.org/cgi/content/abstract/22/22/4673
# * http://www.ebi.ac.uk/clustalw/
# * ftp://ftp.ebi.ac.uk/pub/software/unix/clustalw/
#


require 'tempfile'

require 'bio/command'
require 'bio/sequence'
require 'bio/alignment'

module Bio

  # Bio::ClustalW is a CLUSTAL W execution wrapper class.
  # Its object is also called an alignment factory.
  # CLUSTAL W is a very popular software for multiple sequence alignment.
  class ClustalW

    autoload :Report, 'bio/appl/clustalw/report'

    # Creates a new CLUSTAL W execution wrapper object (alignment factory).
    def initialize(program = 'clustalw', opt = [])
      @program = program
      @options = opt
      @command = nil
      @output = nil
      @report = nil
      @data_stdout = nil
      @exit_status = nil
      @output_dnd = nil
    end

    # name of the program (usually 'clustalw' in UNIX)
    attr_accessor :program

    # options
    attr_accessor :options

    # option is deprecated. Instead, please use options.
    def option
      warn "Bio::ClustalW#option is deprecated. Please use options."
      options
    end

    # Returns last command-line strings executed by this factory.
    # Note that filenames described in the command-line may already
    # be removed because they are temporary files.
    # Returns an array.
    attr_reader :command

    # This method will be deprecated.
    #
    # Returns last messages of CLUSTAL W execution.
    def log
      #warn 'Bio::ClustalW#log will be deprecated.'
      @data_stdout
    end

    # Returns last raw alignment result (String or nil).
    attr_reader :output

    # Returns last alignment result.
    # Returns a Bio::ClustalW::Report object.
    attr_reader :report

    # Last exit status
    attr_reader :exit_status

    # Last output to the stdout.
    attr_accessor :data_stdout
    
    # Clear the internal data and status, except program and options.
    def reset
      @command = nil
      @output = nil
      @report = nil
      @exit_status = nil
      @data_stdout = nil
      @output_dnd = nil
    end

    # Executes the program(clustalw).
    # If +seqs+ is not nil, perform alignment for seqs.
    # If +seqs+ is nil, simply executes CLUSTAL W.
    #
    # Compatibility note: When seqs is nil,
    # returns true if the program exits normally, and
    # returns false if the program exits abnormally.
    def query(seqs)
      if seqs then
        query_align(seqs)
      else
        exec_local(@options)
        @exit_status.exitstatus == 0 ? true : false
      end
    end

    # Note that this method will be renamed to query_alignment.
    #
    # Performs alignment for +seqs+.
    # +seqs+ should be Bio::Alignment or Array of sequences or nil.
    #
    # Compatibility Note: Nucleic or amino is not determined by this method.
    def query_align(seqs)
      unless seqs.is_a?(Bio::Alignment)
        seqs = Bio::Alignment.new(seqs)
      end
      query_string(seqs.output_fasta(:width => 70,
                                     :avoid_same_name => true))
    end

    # Performs alignment for +seqs+.
    # +seqs+ should be Bio::Alignment or Array of sequences or nil.
    def query_alignment(seqs)
      query_align(seqs)
    end

    # Performs alignment for +str+.
    # +str+ should be a string that can be recognized by CLUSTAL W.
    #
    # Compatibility Note: 2nd argument is deprecated and ignored.
    def query_string(str, *arg)
      if arg.size > 0 then
        warn '2nd argument of Bio::ClustalW#query_string is ignored'
      end
      begin
        tf_in = Tempfile.open('align')
        tf_in.print str
      ensure
        tf_in.close(false)
      end
      r = query_by_filename(tf_in.path)
      tf_in.close(true)
      r
    end

    # Performs alignment of sequences in the file named +path+.
    #
    # Compatibility Note: 2nd argument (seqtype) is deprecated and ignored.
    def query_by_filename(path, *arg)
      if arg.size > 0 then
        warn '2nd argument of Bio::ClustalW#query_by_filename is ignored'
      end

      tf_out = Tempfile.open('clustalout')
      tf_out.close(false)
      tf_dnd = Tempfile.open('clustaldnd')
      tf_dnd.close(false)

      opt = [ "-align",
        "-infile=#{path}",
        "-outfile=#{tf_out.path}",
        "-newtree=#{tf_dnd.path}",
        "-outorder=input"
      ]
      #opt << "-type=#{seqtype}" if seqtype
      opt.concat(@options)
      exec_local(opt)
      tf_out.open
      @output = tf_out.read
      tf_out.close(true)
      tf_dnd.open
      @output_dnd = tf_dnd.read
      tf_dnd.close(true)
      @report = Report.new(@output)
      @report
    end

    # Returns last alignment guild-tree (file.dnd).
    attr_reader :output_dnd

    #---
    # Returns last error messages (to stderr) of CLUSTAL W execution.
    #attr_reader :errorlog
    #+++
    #errorlog is deprecated (no replacement) and returns empty string.
    def errorlog
      warn "errorlog is deprecated (no replacement) and returns empty string."
      ''
    end

    private
    # Executes the program in the local machine.
    def exec_local(opt)
      @command = [ @program,  *opt ]
      #STDERR.print "DEBUG: ", @command.join(" "), "\n"
      @data_stdout = nil
      @exit_status = nil

      Bio::Command.call_command(@command) do |io|
        io.close_write
        @data_stdout = io.read
      end
      @exit_status = $?
    end

  end #class ClustalW

end #module Bio

