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
#  $Id: hmmer.rb,v 1.1 2002/11/22 23:17:55 k Exp $
#

require 'bio/appl/hmmer/report'

module Bio

  class HMMER

    def initialize(program, hmmfile, seqfile, option = '')
      @program	= program
      @hmmfile	= hmmfile
      @seqfile	= seqfile
      @option	= option
      @output	= ''
    end
    attr_accessor :program, :hmmfile, :seqfile, :option
    attr_reader :output

    def query
      cmd = "#{@program} #{@option} #{@hmmfile} #{@seqfile}"
      
      report = nil

      begin
	io = IO.popen(cmd, 'r')
	io.sync = true
	@output = io.read
	report = parse_result(@output)
      rescue
	raise "[Error] command execution failed : #{cmd}"
      ensure
	io.close
      end 
      
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
--- Bio::HMMER#option

      Accessors for the factory.

--- Bio::HMMER#query

      Executes the hmmer search and returns Report object (Bio::HMMER::Report).

--- Bio::HMMER#output

      Shows the raw output from hmmer search.

=end


