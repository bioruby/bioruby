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
#  $Id: mafft.rb,v 1.1 2003/07/25 07:51:47 ng Exp $
#

require 'bio/db/fasta'
require 'bio/io/flatfile'
require 'bio/appl/alignfactory'

# We use Open3.popen3, because MAFFT on win32 requires Cygwin.
require 'open3'

module Bio
  class MAFFT < AlignFactory

    def self.fftns(n = nil)
      opt = []
      if n.to_s == 'i' then
	self.new2(nil, 'fftnsi', *opt)
      else
	opt << n if n
	self.new2(nil, 'fftns', *opt)
      end
    end

    def self.nwns(n = nil, ap = nil)
      opt = []
      opt << '--all-positive' if ap
      if n.to_s == 'i' then
	self.new2(nil, 'nwnsi', *opt)
      else
	opt << n if n
	self.new2(nil, 'nwns', *opt)
      end
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

    def query_by_filename(fn, seqtype = nil)

      require 'bio/appl/mafft/report'

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
	Thread.start do
	  @log = derr.read
	end
	ff = Bio::FlatFile.new(Bio::FastaFormat, dout)
	@output = ff.to_a
      end
      @log
    end

  end #class MAFFT
end #module Bio

