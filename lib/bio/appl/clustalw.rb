#
# bio/appl/clustalw.rb - CLUSTAL W wrapper class
#
#   Copyright (C) 2003 GOTO Naohisa <ngoto@gen-info.osaka-u.ac.jp>
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
#  $Id: clustalw.rb,v 1.2 2003/07/25 17:14:27 ng Exp $
#

require 'tempfile'
require 'bio/sequence'
require 'bio/alignment'
require 'bio/appl/alignfactory'

module Bio
  class ClustalW < AlignFactory

    def initialize(program = 'clustalw', option = '')
      #
      # 'program' and 'option' are directly passed to the shell.
      # This is a potential security hole.
      #
      super
    end

    def query_align(seqs)
      # seqs should be Bio::Alignment or Array of sequences or nil
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
      query_string(seqs.to_fasta(70, true), seqtype)
    end

    def query_by_filename(path, seqtype = nil)
      #
      # 'path' is directly passed to the shell (by using IO.popen).
      # This may be a strong security hole.
      #
      require 'bio/appl/clustalw/report'

      tf_out = Tempfile.open('clustalout')
      tf_out.close(false)
      tf_dnd = Tempfile.open('clustaldnd')
      tf_dnd.close(false)

      iopt = "-align -infile=#{path} -outfile=#{tf_out.path} -newtree=#{tf_dnd.path} -outorder=input"
      iopt += " -type=#{seqtype}" if seqtype
      opt = "#{iopt} #{@option}"
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
    attr_reader :output_dnd

    private
    def exec_local(opt)
      @command = "#{@program} #{opt}"
      #STDERR.print "DEBUG: ", @command, "\n"
      @log = nil
      IO.popen(@command, "r") do |io|
	io.sync = true
	@log = io.read
      end
      @log
    end

  end #class ClustalW

end #module Bio

=begin

= Bio::ClustalW

--- Bio::ClustalW.new(path_to_clustalw = 'clustalw', option = '')

      Creates new alignment factory.
      !!!CAUTION!!!
      Both arguments 'path_to_clustalw' and 'option' are directly
      passed to the UNIX-shell (by using IO.popen).
      This is a potential security hole.
      You should escape special characters if you need.

--- Bio::ClustalW#program
--- Bio::ClustalW#option

      Access to the variables specified in Bio::ClustalW.new.

--- Bio::ClustalW#query(seqs)

      Executes the program(clustalw).
      If 'seqs' is not nil, perform alignment for seqs.
      If 'seqs' is nil, simply executes CLUSTAL W.

--- Bio::ClustalW#query_align(seqs)

      Performs alignment for seqs.

--- Bio::ClustalW#query_string(str)

      Performs alignment for str.
      Str should be a string that can be recognized by CLUSTAL W.

--- Bio::ClustalW#query_by_filename(filename)

      Performs alignment of sequences in the file named filename.
      !!!CAUTION!!!
      Argument 'filename' is directly passed to the UNIX-shell
      (by using IO.popen).
      This is a potential security hole.
      You should escape special characters if you need.

--- Bio::ClustalW#command

      Shows latest command-line executed by this factory.
      Note that filenames described in the command-line may already
      be removed because they are temporary files.

--- Bio::ClustalW#log

      Shows latest messages of CLUSTAL W execution.

--- Bio::ClustalW#report

      Shows latest alignment result (instance of Bio::ClustalW::Report)
      performed by this factory.

--- Bio::ClustalW#output

      Shows latest raw alignment result (String).

--- Bio::ClustalW#output_dnd

      Shows latest alignment guild-tree (filename.dnd).

=end
