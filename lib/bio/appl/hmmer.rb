#
# bio/appl/hmmer.rb - HMMER wrapper
# 
#   Copyright (C) 2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: hmmer.rb,v 1.2 2005/08/16 09:38:34 ngoto Exp $
#

require 'bio/appl/hmmer/report'
require 'bio/command'
require 'shellwords'

module Bio

  class HMMER

    include Bio::Command::Tools

    def initialize(program, hmmfile, seqfile, opt = [])
      @program	= program
      @hmmfile	= hmmfile
      @seqfile	= seqfile
      @output	= ''

      begin
        @options = opt.to_ary
      rescue NameError #NoMethodError
        # backward compatibility
        @options = Shellwords.shellwords(opt)
      end
    end
    attr_accessor :program, :hmmfile, :seqfile, :options
    attr_reader :output

    def option
      # backward compatibility
      make_command_line(@options)
    end

    def option=(str)
      # backward compatibility
      @options = Shellwords.shellwords(str)
    end

    def query
      cmd = [ @program, *@options ]
      cmd.concat([ @hmmfile, @seqfile ])
      
      report = nil

      @output = call_command_local(cmd, nil)
      report = parse_result(@output)
      
      return report
    end


    private

    def parse_result(data)
      Report.new(data)
    end

  end
end



if __FILE__ == $0

  begin
    require 'pp'
    alias :p :pp
  rescue
  end

  program = ARGV.shift	# hmmsearch, hmmpfam
  hmmfile = ARGV.shift
  seqfile = ARGV.shift

  factory = Bio::HMMER.new(program, hmmfile, seqfile)
  p factory.query

end


=begin

= Bio::HMMER

--- Bio::HMMER.new(program, hmmfile, seqfile, option = '')
--- Bio::HMMER#program
--- Bio::HMMER#hmmfile
--- Bio::HMMER#seqfile
--- Bio::HMMER#options

      Accessors for the factory.

--- Bio::HMMER#option
--- Bio::HMMER#option=(str)

      Get/set options by string.

--- Bio::HMMER#query

      Executes the hmmer search and returns Report object (Bio::HMMER::Report).

--- Bio::HMMER#output

      Shows the raw output from hmmer search.

=end


