#
# = sample/demo_fasta_remote.rb - demonstration of FASTA execution using GenomeNet web service
#
# Copyright::  Copyright (C) 2001, 2002 Toshiaki Katayama <k@bioruby.org>
# License::    The Ruby License
#
# == Description
#
# Demonstration of Bio::Fasta.remote, wrapper class for FASTA execution using
# GenomeNet fasta.genome.jp web service.
#
# == Requirements
#
# * Internet connection
#
# == Usage
#
# Specify a files containing a nucleic acid sequence.
# The file format should be the fasta format.
#
#  $ ruby demo_fasta_remote.rb file.fst
#
# Example usage using test data:
#
#  $ ruby -Ilib sample/demo_fasta_remote.rb test/data/blast/b0002.faa
#
# Note that it may take very long time. Please wait for 3 to 5 minutes.
#
# == Development information
#
# The code was moved from lib/bio/appl/fasta.rb.
#

require 'bio'

#if __FILE__ == $0
  begin
    require 'pp'
    alias p pp
  rescue
  end

# serv = Bio::Fasta.local('fasta34', 'hoge.nuc')
# serv = Bio::Fasta.local('fasta34', 'hoge.pep')
# serv = Bio::Fasta.local('ssearch34', 'hoge.pep')

  # This may take 3 minutes or so.
  serv = Bio::Fasta.remote('fasta', 'genes')
  p serv.query(ARGF.read)
#end

