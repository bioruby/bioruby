#
# bio/appl/mafft.rb - MAFFT wrapper class
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
#  $Id: mafft.rb,v 1.4 2005/03/04 04:48:41 k Exp $
#

require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'bio/appl/mafft/report'
#require 'bio/appl/factory'

# We use Open3.popen3, because MAFFT on win32 requires Cygwin.
require 'open3'

module Bio
  class MAFFT

    def self.fftns(n = nil)
      opt = []
      if n.to_s == 'i' then
	self.new2(nil, 'fftnsi', *opt)
      else
	opt << n.to_s if n
	self.new2(nil, 'fftns', *opt)
      end
    end

    def self.fftnsi
      self.new2(nil, 'fftnsi')
    end

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

    def self.nwnsi(ap = nil)
      opt = []
      opt << '--all-positive' if ap
      self.new2(nil, 'nwnsi', *opt)
    end

    def self.nwap(n = nil)
      self.nwns(n, true)
    end

    def self.new2(dir, prog, *opt)
      if dir then
	prog = File.join(dir, prog)
      end
      self.new(prog, opt)
    end

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

    def query_by_filename(fn, seqtype = nil)
      opt = @option + [ fn ]
      exec_local(opt)
      @report = Report.new(@output, seqtype)
      @report
    end

    private
    def exec_local(opt)
      @command = [ @program, *opt ]
      #STDERR.print "DEBUG: ", @command.join(" "), "\n"
      @output = nil
      @log = nil
      Open3.popen3(*@command) do |din, dout, derr|
	din.close
	derr.sync = true
	t = Thread.start do
	  @log = derr.read
	end
	ff = Bio::FlatFile.new(Bio::FastaFormat, dout)
	@output = ff.to_a
	t.join
      end
      @log
    end

  end #class MAFFT
end #module Bio


=begin

= Bio::MAFFT

 Bio::MAFFT is a wrapper class of MAFFT, multiple sequence alignment software.
 ((<URL:http://www.biophys.kyoto-u.ac.jp/~katoh/programs/align/mafft/>))

--- Bio::MAFFT.fftns(n = nil)

      Create new alignment factory.
      When n is a number (1,2,3, ...), performs 'fftns n'.
      When n is :i or 'i', performs 'fftnsi'.

--- Bio::MAFFT.fftnsi

      Create new alignment factory.
      Performs 'fftnsi'.

--- Bio::MAFFT.nwns(n = nil, all_positive = nil)

      Create new alignment factory.
      When n is a number (1,2,3, ...), performs 'nwns n'.
      When n is :i or 'i', performs 'nwnsi'.
      In both case, if all_positive is true, add option '--all-positive'.

--- Bio::MAFFT.nwnsi(all_positive = true)

      Create new alignment factory.
      Performs 'nwnsi'.
      If all_positive is true, add option '--all-positive'.

--- Bio::MAFFT.nwap(n = nil)

      Create new alignment factory.
      Performs 'nwns --all-positive n' or 'nwnsi --all-positive'.
      Same as Bio::MAFFT.nwap(n, true).

--- Bio::MAFFT.new(program, option)

      Creates new alignment factory.

--- Bio::MAFFT#program
--- Bio::MAFFT#option

      Access to the variables specified in initialize.

--- Bio::MAFFT#query(seqs)

      Executes the program(clustalw).
      If 'seqs' is not nil, perform alignment for seqs.
      If 'seqs' is nil, simply executes the program.

--- Bio::MAFFT#query_align(seqs)

      Performs alignment for seqs.

--- Bio::MAFFT#query_string(str)

      Performs alignment for str.
      Str should be a string that can be recognized by the program.

--- Bio::MAFFT#query_by_filename(filename)

      Performs alignment of sequences in the file named filename.

--- Bio::MAFFT#command

      Shows latest command-line executed by this factory.
      Note that filenames described in the command-line may already
      be removed because they are temporary files.
      Returns an array of string.

--- Bio::MAFFT#log

      Shows latest messages of execution.

--- Bio::MAFFT#report

      Shows latest alignment result (instance of Bio::MAFFT::Report class)
      performed by this factory.

--- Bio::MAFFT#output

      Shows latest raw alignment result.
      Since a result of MAFFT is simply a multiple-fasta format,
      it returns an array of Bio::FastaFormat instances
      instead of raw string.

=end
