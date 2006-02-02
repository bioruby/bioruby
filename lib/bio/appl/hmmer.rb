#
# = bio/appl/hmmer.rb - HMMER wrapper
# 
# Copyright::   Copyright (C) 2002 
#               KATAYAMA Toshiaki <k@bioruby.org>
# Lisence::     LGPL
#
# $Id: hmmer.rb,v 1.5 2006/02/02 17:08:36 nakao Exp $
#
# == Description
#
# A wrapper for the HMMER programs (hmmsearch or hmmpfam).
#
# == Examples
#
#   require 'bio'
#   program = 'hmmsearch' # or 'hmmpfam'
#   hmmfile = 'test.hmm'
#   seqfile = 'test.faa'
#   
#   factory = Bio::HMMER.new(program, hmmfile, seqfile)
#   p factory.query
#
# == References
#
# * HMMER
#   http://hmmer.wustl.edu/
#
#--
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
#++
#

require 'bio/command'
require 'shellwords'

module Bio

# A wapper for HMMER programs (hmmsearch or hmmpfam).
#
# === Examples
#
#   require 'bio'
#   program = 'hmmsearch' # or 'hmmpfam'
#   hmmfile = 'test.hmm'
#   seqfile = 'test.faa'
#   
#   factory = Bio::HMMER.new(program, hmmfile, seqfile)
#   report = factory.query
#   report.class #=> Bio::HMMER::Report
#
# === References
#
# * HMMER
#   http://hmmer.wustl.edu/
#
class HMMER

  autoload :Report, 'bio/appl/hmmer/report'

  include Bio::Command::Tools

  # Prgrams name. (hmmsearch or hmmpfam).
  attr_accessor :program
  
  # Name of hmmfile.
  attr_accessor :hmmfile
  
  # Name of seqfile.
  attr_accessor :seqfile
  
  #  Command line options.
  attr_accessor :options
  
  # Shows the raw output from the hmmer search.
  attr_reader :output

  # Sets a program name, a profile hmm file name, a query sequence file name 
  # and options in string.
  # 
  # Program names: hmmsearch, hmmpfam
  #
  def initialize(program, hmmfile, seqfile, options = [])
    @program = program
    @hmmfile = hmmfile
    @seqfile = seqfile
    @output  = ''
    
    begin
      @options = opt.to_ary
    rescue NameError #NoMethodError
      # backward compatibility
      @options = Shellwords.shellwords(options)
    end
  end


  # Gets options by String.
  # backward compatibility.
  def option
    make_command_line(@options)
  end


  # Sets options by String.
  # backward compatibility.
  def option=(str)
    @options = Shellwords.shellwords(str)
  end


  # Executes the hmmer search and returns the report 
  # (Bio::HMMER::Report object).
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

end # class HMMER

end # module Bio



if __FILE__ == $0

  require 'pp'

  program = ARGV.shift # hmmsearch, hmmpfam
  hmmfile = ARGV.shift
  seqfile = ARGV.shift

  factory = Bio::HMMER.new(program, hmmfile, seqfile)
  pp factory.query

end
