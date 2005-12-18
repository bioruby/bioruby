#
# = bio/appl/clustalw.rb - CLUSTAL W wrapper class
#
# Copyright:: Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: clustalw.rb,v 1.10 2005/12/18 15:58:40 k Exp $
#
# Bio::ClustalW is a CLUSTAL W execution wrapper class.
# Its object is also called an alignment factory.
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
require 'open3'

require 'bio/sequence'
require 'bio/alignment'

module Bio

  # Bio::ClustalW is a CLUSTAL W execution wrapper class.
  # Its object is also called an alignment factory.
  # CLUSTAL W is a very popular software for multiple sequence alignment.
  class ClustalW

    autoload :Report, 'bio/appl/clustalw/report'

    # Creates a new CLUSTAL W execution wrapper object (alignment factory).
    def initialize(program = 'clustalw', option = [])
      @program = program
      @option = option
      @command = nil
      @output = nil
      @report = nil
      @log = nil
    end

    # name of the program (usually 'clustalw' in UNIX)
    attr_accessor :program

    # options
    attr_accessor :option

    # Returns last command-line strings executed by this factory.
    # Note that filenames described in the command-line may already
    # be removed because they are temporary files.
    # Returns an array.
    attr_reader :command

    # Returns last messages of CLUSTAL W execution.
    attr_reader :log

    # Returns last raw alignment result (String).
    attr_reader :output

    # Returns last alignment result.
    # Returns a Bio::ClustalW::Report object.
    attr_reader :report

    # Executes the program(clustalw).
    # If +seqs+ is not nil, perform alignment for seqs.
    # If +seqs+ is nil, simply executes CLUSTAL W.
    def query(seqs)
      if seqs then
        query_align(seqs)
      else
        exec_local(@option)
      end
    end

    # Performs alignment for +seqs+.
    # +seqs+ should be Bio::Alignment or Array of sequences or nil.
    def query_align(seqs)
      seqtype = nil
      unless seqs.is_a?(Bio::Alignment)
        seqs = Bio::Alignment.new(seqs)
      end
      seqs.each do |s|
        if    s.is_a?(Bio::Sequence::AA) then
          seqtype = 'PROTEIN'
        elsif s.is_a?(Bio::Sequence::NA) then
          seqtype = 'DNA'
        end
        break if seqtype
      end
      query_string(seqs.to_fasta(70, :avoid_same_name => true), seqtype)
    end

    # Performs alignment for +str+.
    # +str+ should be a string that can be recognized by CLUSTAL W.
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

    # Performs alignment of sequences in the file named +path+.
    def query_by_filename(path, seqtype = nil)
      require 'bio/appl/clustalw/report'

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
      opt << "-type=#{seqtype}" if seqtype
      opt.concat(@option)
      exec_local(opt)
      tf_out.open
      @output = tf_out.read
      tf_out.close(true)
      tf_dnd.open
      @output_dnd = tf_dnd.read
      tf_dnd.close(true)
      @report = Report.new(@output, seqtype)
      @report
    end

    # Returns last alignment guild-tree (file.dnd).
    attr_reader :output_dnd

    # Returns last error messages (to stderr) of CLUSTAL W execution.
    attr_reader :errorlog

    private
    # Executes the program in the local machine.
    def exec_local(opt)
      @command = [ @program,  *opt ]
      #STDERR.print "DEBUG: ", @command.join(" "), "\n"
      @log = nil

      Open3.popen3(*@command) do |din, dout, derr|
        din.close
        t = Thread.start do
          @errorlog = derr.read
        end
        @log = dout.read
        t.join
      end
#      @command_string = @command.join(" ")
#      IO.popen(@command, "r") do |io|
#	io.sync = true
#	@log = io.read
#      end
      @log
    end

  end #class ClustalW

end #module Bio

