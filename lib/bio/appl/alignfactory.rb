#
# bio/appl/alignfactory.rb - template class for multiple alignment software
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
#  $Id: alignfactory.rb,v 1.2 2003/07/25 17:14:27 ng Exp $
#

require 'tempfile'
require 'bio/sequence'
require 'bio/alignment'

module Bio
  class AlignFactory

    def initialize(program, option)
      @program = program
      @option = option
      @command = nil
      @output = nil
      @report = nil
      @log = nil
    end
    attr_accessor :program, :option
    attr_reader :command, :log
    attr_reader :output, :report
    
    def query(seqs)
      if seqs then
	query_align(seqs)
      else
	exec_local(@option)
      end
    end

    def query_align(seqs, *arg)
      # seqs should be Bio::Alignment or Array of sequences or nil
      unless seqs.is_a?(Bio::Alignment)
	seqs = Bio::Alignment.new(seqs, *arg)
      end
      query_string(seqs.to_fasta(70))
    end

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

    def query_by_filename(fn, *arg)
      raise NotImplementedError
    end

    private
    def exec_local
      raise NotImplementedError
    end

  end #class AlignFactory
end #module Bio

=begin

= Bio::AlignFactory

 Bio::AlignFactory is a template class of multiple alignment software.
 Each wrapper class of alignment software shall inherit this class.

--- Bio::AlignFactory.new(program, option)

      Creates new alignment factory.

--- Bio::AlignFactory#program
--- Bio::AlignFactory#option

      Access to the variables specified in initialize.

--- Bio::AlignFactory#query(seqs)

      Executes the program(clustalw).
      If 'seqs' is not nil, perform alignment for seqs.
      If 'seqs' is nil, simply executes the program.

--- Bio::AlignFactory#query_align(seqs)

      Performs alignment for seqs.

--- Bio::AlignFactory#query_string(str)

      Performs alignment for str.
      Str should be a string that can be recognized by the program.

--- Bio::AlignFactory#query_by_filename(filename)

      Performs alignment of sequences in the file named filename.

--- Bio::AlignFactory#command

      Shows latest command-line executed by this factory.

--- Bio::AlignFactory#log

      Shows latest messages of program execution.

--- Bio::AlignFactory#report

      Shows latest alignment result (instance of Report class)
      performed by this factory.

--- Bio::AlignFactory#output

      Shows latest raw alignment result.

=end
