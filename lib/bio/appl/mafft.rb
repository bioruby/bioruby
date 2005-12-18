#
# = bio/appl/mafft.rb - MAFFT wrapper class
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
#  $Id: mafft.rb,v 1.9 2005/12/18 15:58:40 k Exp $
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

require 'bio/db/fasta'
require 'bio/io/flatfile'

#--
# We use Open3.popen3, because MAFFT on win32 requires Cygwin.
#++
require 'open3'

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
    def initialize(program, option)
      @program = program
      @option = option
      @command = nil
      @output = nil
      @report = nil
      @log = nil
    end

    # program name
    attr_accessor :program

    # options
    attr_accessor :option

    # Shows last command-line string. Returns nil or an array of String.
    # Note that filenames described in the command-line may already
    # be removed because they are temporary files.
    attr_reader :command

    # last message to STDERR when executing the program.
    attr_reader :log

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

