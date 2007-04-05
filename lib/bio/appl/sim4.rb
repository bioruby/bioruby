#
# = bio/appl/sim4.rb - sim4 wrapper class
#
# Copyright:: Copyright (C) 2004 GOTO Naohisa <ng@bioruby.org>
# License::   The Ruby License
#
#  $Id: sim4.rb,v 1.10 2007/04/05 23:35:39 trevor Exp $
#
# The sim4 execution wrapper class.
#
# == References
#
# * Florea, L., et al., A Computer program for aligning a cDNA sequence
#   with a genomic DNA sequence, Genome Research, 8, 967--974, 1998.
#   http://www.genome.org/cgi/content/abstract/8/9/967
#

require 'tempfile'
require 'bio/command'

module Bio

  # The sim4 execution wrapper class.
  class Sim4

    autoload :Report,       'bio/appl/sim4/report'

    # Creates a new sim4 execution wrapper object.
    # [+program+]  Program name. Usually 'sim4' in UNIX.
    # [+database+] Default file name of database('seq2').
    # [+option+]   Options (array of strings).
    def initialize(program = 'sim4', database = nil, opt = [])
      @program = program
      @options = opt
      @database = database #seq2
      @command = nil
      @output = nil
      @report = nil
    end

    # default file name of database('seq2')
    attr_accessor :database

    # name of the program (usually 'sim4' in UNIX)
    attr_reader :program

    # options
    attr_accessor :options

    # option is deprecated. Instead, please use options.
    def option
      warn "option is deprecated. Please use options."
      options
    end

    # last command-line strings executed by the object
    attr_reader :command

    #---
    # last messages of program reported to the STDERR
    #attr_reader :log
    #+++

    #log is deprecated (no replacement) and returns empty string.
    def log
      warn "log is deprecated (no replacement) and returns empty string."
      ''
    end

    # last result text (String)
    attr_reader :output

    # last result. Returns a Bio::Sim4::Report object.
    attr_reader :report

    # Executes the sim4 program.
    # <tt>seq1</tt> shall be a Bio::Sequence object.
    # Returns a Bio::Sim4::Report object.
    def query(seq1)
      tf = Tempfile.open('sim4')
      tf.print seq1.to_fasta('seq1', 70)
      tf.close(false)
      r = exec_local(tf.path)
      tf.close(true)
      r
    end

    # Executes the sim4 program.
    # Perform mRNA-genome alignment between given sequences.
    # <tt>seq1</tt> and <tt>seq2</tt> should be Bio::Sequence objects.
    # Returns a Bio::Sim4::Report object.
    def query_pairwise(seq1, seq2)
      tf = Tempfile.open('sim4')
      tf.print seq1.to_fasta('seq1', 70)
      tf.close(false)
      tf2 = Tempfile.open('seq2')
      tf2.print seq1.to_fasta('seq2', 70)
      tf2.close(false)
      r = exec_local(tf.path, tf2.path)
      tf.close(true)
      tf2.close(true)
      r
    end

    # Executes the sim4 program.
    # Perform mRNA-genome alignment between sequences in given files.
    # <tt>filename1</tt> and <tt>filename2</tt> should be file name strings.
    # If <tt>filename2</tt> is not specified, using <tt>self.database</tt>.
    def exec_local(filename1, filename2 = nil)
      @command = [ @program, filename1, (filename2 or @database), *@options ]
      @output = nil
      @report = nil
      Bio::Command.call_command(@command) do |io|
        io.close_write
        @output = io.read
        @report = Bio::Sim4::Report.new(@output)
      end
      @report
    end
    alias exec exec_local

  end #class Sim4
end #module Bio

