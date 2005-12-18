#
# = bio/appl/sim4.rb - sim4 wrapper class
#
# Copyright:: Copyright (C) 2004 GOTO Naohisa <ng@bioruby.org>
# License::   LGPL
#
#--
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
#++
#
#  $Id: sim4.rb,v 1.5 2005/12/18 15:58:40 k Exp $
#
# The sim4 execution wrapper class.
#
# == References
#
# * Florea, L., et al., A Computer program for aligning a cDNA sequence
#   with a genomic DNA sequence, Genome Research, 8, 967--974, 1998.
#   http://www.genome.org/cgi/content/abstract/8/9/967
#

require 'open3'
require 'tempfile'

module Bio

  # The sim4 execution wrapper class.
  class Sim4

    autoload :Report,       'bio/appl/sim4/report'

    # Creates a new sim4 execution wrapper object.
    # [+program+]  Program name. Usually 'sim4' in UNIX.
    # [+database+] Default file name of database('seq2').
    # [+option+]   Options (array of strings).
    def initialize(program = 'sim4', database = nil, option = [])
      @program = program
      @option = option
      @database = database #seq2
      @command = nil
      @output = nil
      @report = nil
      @log = nil
    end

    # default file name of database('seq2')
    attr_accessor :database

    # name of the program (usually 'sim4' in UNIX)
    attr_reader :program

    # options
    attr_reader :option

    # last command-line strings executed by the object
    attr_reader :command

    # last messages of program reported to the STDERR
    attr_reader :log

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
      @command = [ @program, filename1, (filename2 or @database), *@option ]
      @output = nil
      @log = nil
      @report = nil
      Open3.popen3(*@command) do |din, dout, derr|
        din.close
        derr.sync = true
        t = Thread.start { @log = derr.read }
        begin
          @output = dout.read
          @report = Bio::Sim4::Report.new(@output)
        ensure
          t.join
        end
      end
      @report
    end
    alias exec exec_local

  end #class Sim4
end #module Bio

