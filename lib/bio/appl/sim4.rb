#
# bio/appl/sim4.rb - sim4 wrapper class
#
#   Copyright (C) 2004 GOTO Naohisa <ng@bioruby.org>
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
#  $Id: sim4.rb,v 1.1 2004/10/08 17:41:08 ngoto Exp $
#

require 'bio/appl/sim4/report'
require 'open3'
require 'tempfile'

module Bio
  class Sim4
    def initialize(program = 'sim4', database = nil, option = [])
      @program = program
      @option = option
      @database = database #seq2
      @command = nil
      @output = nil
      @report = nil
      @log = nil
    end
    attr_accessor :database
    attr_reader :program, :option
    attr_reader :command, :log
    attr_reader :output, :report

    def query(seq1)
      tf = Tempfile.open('sim4')
      tf.print seq1.to_fasta('seq1', 70)
      tf.close(false)
      r = exec_local(tf.path)
      tf.close(true)
      r
    end

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

=begin

= Bio::Sim4

  Sim4 wrapper.

--- Bio::Sim4.new(program = 'sim4', database = nil, option = [])

      Creates new wrapper.
        program: program name (String)
        database: default file name of database('seq2') (String)
        option: options (Array of String)

--- Bio::Sim4#database
--- Bio::Sim4#program
--- Bio::Sim4#option

      Access to the variables specified in initialize.

--- Bio::Sim4#query(seq)

      Executes the program(sim4).
        seq: Bio::Sequence object
      Returns a Bio::Sim4::Report object.

--- Bio::Sim4#query_pairwise(seq1, seq2)

      Executes the program(sim4).
      Perform mRNA-genome alignment between given sequences.
        seq1: Bio::Sequence object
        seq2: Bio::Sequence object
      Returns a Bio::Sim4::Report object.

--- Bio::Sim4#exec(filename1, filename2 = nil)

      Executes the program(sim4).
        filename1: file name (String)
        filename2: file name (String)
                   If not specified, using self.database.

--- Bio::Sim4#command

      Shows latest command-line executed by this class.

--- Bio::Sim4#log

      Shows latest messages of program reported to stderr.

--- Bio::Sim4#report

      Shows latest result (Bio::Sim4::Report object)

--- Bio::Sim4#output

      Shows latest raw result.

=end

