#
# = bio/appl/mafft.rb - MAFFT wrapper class
#
# Copyright:: Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
# License::   Ruby's
#
#  $Id: mafft.rb,v 1.12 2006/12/14 14:54:50 ngoto Exp $
#
# Bio::MAFFT is a wrapper class to execute MAFFT.
# MAFFT is a very fast multiple sequence alignment software.
#
# = Important Notes
#
# Though Bio::MAFFT class currently supports only MAFFT version 3,
# you can use MAFFT version 5 because the class is a wrapper class.
#
# == References
#
# * K. Katoh, K. Misawa, K. Kuma and T. Miyata.
#   MAFFT: a novel method for rapid multiple sequence alignment based
#   on fast Fourier transform. Nucleic Acids Res. 30: 3059-3066, 2002.
#   http://nar.oupjournals.org/cgi/content/abstract/30/14/3059
# * http://www.biophys.kyoto-u.ac.jp/~katoh/programs/align/mafft/
#

require 'tempfile'

require 'bio/command'

require 'bio/db/fasta'
require 'bio/io/flatfile'

module Bio

  # Bio::MAFFT is a wrapper class to execute MAFFT.
  # MAFFT is a very fast multiple sequence alignment software.
  #
  # Though Bio::MAFFT class currently supports only MAFFT version 3,
  # you can use MAFFT version 5 because the class is a wrapper class.
  class MAFFT

    autoload :Report,       'bio/appl/mafft/report'

    # Creates a new alignment factory.
    # When +n+ is a number (1,2,3, ...), performs 'fftns n'.
    # When +n+ is :i or 'i', performs 'fftnsi'.
    def self.fftns(n = nil)
      opt = []
      if n.to_s == 'i' then
        self.new2(nil, 'fftnsi', *opt)
      else
        opt << n.to_s if n
        self.new2(nil, 'fftns', *opt)
      end
    end

    # Creates a new alignment factory.
    # Performs 'fftnsi'.
    def self.fftnsi
      self.new2(nil, 'fftnsi')
    end

    # Creates a new alignment factory.
    # When +n+ is a number (1,2,3, ...), performs 'nwns n'.
    # When +n+ is :i or 'i', performs 'nwnsi'.
    # In both case, if all_positive is true, add option '--all-positive'.
    def self.nwns(n = nil, ap = nil)
      opt = []
      opt << '--all-positive' if ap
      if n.to_s == 'i' then
        self.new2(nil, 'nwnsi', *opt)
      else
        opt << n.to_s if n
        self.new2(nil, 'nwns', *opt)
      end
    end

    # Creates a new alignment factory.
    # Performs 'nwnsi'.
    # If +all_positive+ is true, add option '--all-positive'.
    def self.nwnsi(all_positive = nil)
      opt = []
      opt << '--all-positive' if all_positive
      self.new2(nil, 'nwnsi', *opt)
    end

    # Creates a new alignment factory.
    # Performs 'nwns --all-positive n' or 'nwnsi --all-positive'.
    # Same as Bio::MAFFT.nwap(n, true).
    def self.nwap(n = nil)
      self.nwns(n, true)
    end

    # Creates a new alignment factory.
    # +dir+ is the path of the MAFFT program.
    # +prog+ is the name of the program.
    # +opt+ is options of the program.
    def self.new2(dir, prog, *opt)
      if dir then
        prog = File.join(dir, prog)
      end
      self.new(prog, opt)
    end

    # Creates a new alignment factory.
    # +program+ is the name of the program.
    # +opt+ is options of the program.
    def initialize(program, opt)
      @program = program
      @options = opt
      @command = nil
      @output = nil
      @report = nil
    end

    # program name
    attr_accessor :program

    # options
    attr_accessor :options

    # option is deprecated. Instead, please use options.
    def option
      warn "option is deprecated. Please use options."
      options
    end

    # Shows last command-line string. Returns nil or an array of String.
    # Note that filenames described in the command-line may already
    # be removed because they are temporary files.
    attr_reader :command

    #---
    # last message to STDERR when executing the program.
    #attr_reader :log
    #+++

    #log is deprecated (no replacement) and returns empty string.
    def log
      warn "log is deprecated (no replacement) and returns empty string."
      ''
    end

    # Shows latest raw alignment result.
    # Since a result of MAFFT is simply a multiple-fasta format,
    # it returns an array of Bio::FastaFormat instances
    # instead of raw string.
    attr_reader :output

    # Shows last alignment result (instance of Bio::MAFFT::Report class)
    # performed by the factory.
    attr_reader :report

    # Executes the program.
    # If +seqs+ is not nil, perform alignment for seqs.
    # If +seqs+ is nil, simply executes the program.
    def query(seqs)
      if seqs then
        query_align(seqs)
      else
        exec_local(@option)
      end
    end

    # Performs alignment for seqs.
    # +seqs+ should be Bio::Alignment or Array of sequences or nil.
    def query_align(seqs, *arg)
      unless seqs.is_a?(Bio::Alignment)
        seqs = Bio::Alignment.new(seqs, *arg)
      end
      query_string(seqs.to_fasta(70))
    end

    # Performs alignment for +str+.
    # Str should be a string that can be recognized by the program.
    def query_string(str, *arg)
      begin
        tf_in = Tempfile.open('align')
        tf_in.print str
      ensure
        tf_in.close(false)
      end
      r = query_by_filename(tf_in.path, *arg)
      tf_in.close(true)
      r
    end

    # Performs alignment of sequences in the file named +fn+.
    def query_by_filename(fn, seqtype = nil)
      opt = @option + [ fn ]
      exec_local(opt)
      @report = Report.new(@output, seqtype)
      @report
    end

    private
    # Executes a program in the local machine.
    def exec_local(opt)
      @command = [ @program, *opt ]
      #STDERR.print "DEBUG: ", @command.join(" "), "\n"
      @output = nil
      Bio::Command.call_command(*@command) do |io|
        io.close_write
        ff = Bio::FlatFile.new(Bio::FastaFormat, io)
        @output = ff.to_a
      end
    end

  end #class MAFFT
end #module Bio

