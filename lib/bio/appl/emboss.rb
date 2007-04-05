#
# = bio/appl/emboss.rb - EMBOSS wrapper
# 
# Copyright::  Copyright (C) 2002, 2005 Toshiaki Katayama<k@bioruby.org>
# Copyright::  Copyright (C) 2006       Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
# $Id: emboss.rb,v 1.8 2007/04/05 23:35:39 trevor Exp $
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
#  # Then you can get the output of that command in a Bio::EMBOSS object
#  # by creating a new Bio::EMBOSS object and subsequently executing it.
#  xlrhodop = Bio::EMBOSS.new('seqret embl:xlrhodop')
#  puts xlrhodop.exec
#
#  # Or all in one go:
#  puts Bio::EMBOSS.new('seqret embl:xlrhodop').exec
#
#  # Similarly:
#  puts Bio::EMBOSS.new('transeq -sbegin 110 -send 1171 embl:xlrhodop')
#  puts Bio::EMBOSS.new('showfeat embl:xlrhodop').exec
#  puts Bio::EMBOSS.new('seqret embl:xlrhodop -osformat acedb').exec
#
#  # A shortcut exists for this two-step process for +seqret+ and +entret+.
#  puts Bio::EMBOSS.seqret('embl:xlrhodop')
#  puts Bio::EMBOSS.entret('embl:xlrhodop')
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
  # * (required) _command_: emboss command
  # *Returns*:: Bio::EMBOSS object
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
  # * (required) _command_: emboss command
  # *Returns*:: Bio::EMBOSS object
  def self.entret(arg)
    str = self.retrieve('entret', arg)
  end

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

  private

  def self.retrieve(cmd, arg)
    cmd = [ cmd, arg, '-auto', '-stdout' ]
    return Bio::Command.query_command(cmd)
  end

end # EMBOSS

end # Bio
