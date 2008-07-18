#
# = bio/appl/hmmer.rb - HMMER wrapper
# 
# Copyright::   Copyright (C) 2002 
#               Toshiaki Katayama <k@bioruby.org>
# License::     The Ruby License
#
# $Id: hmmer.rb,v 1.9 2007/04/05 23:35:39 trevor Exp $
#

require 'bio/command'
require 'shellwords'

module Bio

# == Description
# 
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
#   report.class # => Bio::HMMER::Report
#
# === References
#
# * HMMER
#   http://hmmer.wustl.edu/
#
class HMMER

  autoload :Report, 'bio/appl/hmmer/report'

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
      @options = options.to_ary
    rescue NameError #NoMethodError
      # backward compatibility
      @options = Shellwords.shellwords(options)
    end
  end


  # Gets options by String.
  # backward compatibility.
  def option
    Bio::Command.make_command_line(@options)
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
    
    @output = Bio::Command.query_command(cmd, nil)
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
