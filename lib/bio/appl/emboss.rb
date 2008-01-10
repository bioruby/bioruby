#
# = bio/appl/emboss.rb - EMBOSS wrapper
# 
# Copyright::  Copyright (C) 2002, 2005 Toshiaki Katayama<k@bioruby.org>
# Copyright::  Copyright (C) 2006       Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id: emboss.rb,v 1.9 2008/01/10 03:51:06 ngoto Exp $
#

module Bio

# == Description
#
# This file holds classes pertaining to the EMBOSS software suite.
#
# This class provides a wrapper for the applications of the EMBOSS suite, which 
# is a mature and stable collection of open-source applications that can handle
# a huge range of sequence formats.
# Applications include:
# * Sequence alignment
# * Rapid database searching with sequence patterns
# * Protein motif identification, including domain analysis
# * Nucleotide sequence pattern analysis---for example to identify CpG islands or repeats
# * Codon usage analysis for small genomes
# * Rapid identification of sequence patterns in large scale sequence sets
# * Presentation tools for publication
#
# See the emboss website for more information: http://emboss.sourceforge.net.
#
#
# == Usage
#
#  require 'bio'
#
#  # Suppose that you could get the sequence for XLRHODOP by running
#  # the EMBOSS command +seqret embl:xlrhodop+ on the command line.
#  # Then you can get the output of that command in a String object
#  # by using  Bio::EMBOSS.run method.
#  xlrhodop = Bio::EMBOSS.run('seqret', 'embl:xlrhodop')
#  puts xlrhodop
#
#  # Or all in one go:
#  puts Bio::EMBOSS.run('seqret', 'embl:xlrhodop')
#
#  # Similarly:
#  puts Bio::EMBOSS.run('transeq', '-sbegin', '110','-send', '1171',
#                       'embl:xlrhodop')
#  puts Bio::EMBOSS.run('showfeat', 'embl:xlrhodop')
#  puts Bio::EMBOSS.run('seqret', 'embl:xlrhodop', '-osformat', 'acedb')
#
#  # A shortcut exists for this two-step process for +seqret+ and +entret+.
#  puts Bio::EMBOSS.seqret('embl:xlrhodop')
#  puts Bio::EMBOSS.entret('embl:xlrhodop')
#
#  # You can use %w() syntax.
#  puts Bio::EMBOSS.run(*%w( transeq -sbegin 110 -send 1171 embl:xlrhodop ))
#
#  # You can also use Shellwords.shellwords.
#  require 'shellwords'
#  str = 'transeq -sbegin 110 -send 1171 embl:xlrhodop'
#  cmd = Shellwords.shellwords(str)
#  puts Bio::EMBOSS.run(*cmd)
#

#
# == Pre-requisites
#
# You must have the EMBOSS suite installed locally. You can download from the
# project website (see References below).
#
# = Rereferences
#
# * http://emboss.sourceforge.net
# * Rice P, Longden I and Bleasby A. \
#    EMBOSS: the European Molecular Biology Open Software Suite. \
#    Trends Genet. 2000 Jun ; 16(6): 276-7 
#
class EMBOSS

  # Combines the initialization and execution for the emboss +seqret+ command.
  #
  #  puts Bio::EMBOSS.seqret('embl:xlrhodop')
  #
  # is equivalent to:
  #
  #  object = Bio::EMBOSS.new('seqret embl:xlrhodop')
  #  puts object.exec
  # ---
  # *Arguments*:
  # * (required) _arg_: argument given to the emboss seqret command
  # *Returns*:: String
  def self.seqret(arg)
    str = self.retrieve('seqret', arg)
  end

  # Combines the initialization and execution for the emboss +entret+ command.
  #
  #  puts Bio::EMBOSS.entret('embl:xlrhodop')
  #
  # is equivalent to:
  #
  #  object = Bio::EMBOSS.new('entret embl:xlrhodop')
  #  puts object.exec
  # ---
  # *Arguments*:
  # * (required) _arg_: argument given to the emboss entret command
  # *Returns*:: String
  def self.entret(arg)
    str = self.retrieve('entret', arg)
  end

  # WARNING: Bio::EMBOSS.new will be changed in the future because
  # Bio::EMBOSS.new(cmd_line) is inconvenient and potential security hole.
  # Using Bio::EMBOSS.run(program, options...) is strongly recommended.
  #
  # Initializes a new Bio::EMBOSS object. This provides a holder that can
  # subsequently be executed (see Bio::EMBOSS.exec). The object does _not_
  # hold any actual data when initialized.
  #
  #   e = Bio::EMBOSS.new('seqret embl:xlrhodop')
  #
  # For e to actually hold data, it has to be executed:
  #   puts e.exec
  #
  # For an overview of commands that can be used with this method, see the
  # emboss website.
  # ---
  # *Arguments*:
  # * (required) _command_: emboss command
  # *Returns*:: Bio::EMBOSS object
  def initialize(cmd_line)
    warn 'Bio::EMBOSS.new(cmd_line) is inconvenient and potential security hole. Using Bio::EMBOSS.run(program, options...) is strongly recommended.'
    @cmd_line = cmd_line + ' -stdout -auto'
  end

  # A Bio::EMBOSS object has to be executed before it can return any result.
  #   obj_A = Bio::EMBOSS.new('transeq -sbegin 110 -send 1171 embl:xlrhodop')
  #   puts obj_A.result                   #=> nil
  #   obj_A.exec
  #   puts obj_A.result                   #=> a FASTA-formatted sequence
  #
  #   obj_B = Bio::EMBOSS.new('showfeat embl:xlrhodop')
  #   obj_B.exec
  #   puts obj_B.result
  def exec
    begin
      @io = IO.popen(@cmd_line, "w+")
      @result = @io.read
      return @result
    ensure
      @io.close
    end
  end
  
  # Pipe for the command
  attr_reader :io
  
  # Result of the executed command
  attr_reader :result

  # Runs an emboss program and get the result as string.
  # Note that "-auto -stdout" are automatically added to the options.
  #
  # Example 1:
  #
  #   result = Bio::EMBOSS.run('seqret', 'embl:xlrhodop')
  #
  # Example 2:
  #
  #   result = Bio::EMBOSS.run('water',
  #                             '-asequence', 'swissprot:slpi_human',
  #                             '-bsequence', 'swissprot:slpi_mouse')
  #
  # Example 3:
  #   options = %w( -asequence swissprot:slpi_human
  #                 -bsequence swissprot:slpi_mouse )
  #   result = Bio::EMBOSS.run('needle', *options)
  #
  # For an overview of commands that can be used with this method, see the
  # emboss website.
  # ---
  # *Arguments*:
  # * (required) _program_: command name, or filename of an emboss program
  # * _options_: options given to the emboss program
  # *Returns*:: String
  def self.run(program, *options)
    cmd = [ program, *options ]
    cmd.push '-auto'
    cmd.push '-stdout'
    return Bio::Command.query_command(cmd)
  end

  private

  def self.retrieve(cmd, arg)
    cmd = [ cmd, arg, '-auto', '-stdout' ]
    return Bio::Command.query_command(cmd)
  end

end # EMBOSS

end # Bio
