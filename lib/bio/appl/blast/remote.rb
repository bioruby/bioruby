#
# = bio/appl/blast/remote.rb - remote BLAST wrapper basic module
# 
# Copyright::  Copyright (C) 2008  Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#

require 'bio/appl/blast'

class Bio::Blast

  # Bio::Blast::Remote is a namespace for Remote Blast factory.
  module Remote

    autoload :GenomeNet, 'bio/appl/blast/genomenet'
    autoload :Genomenet, 'bio/appl/blast/genomenet'

    # creates a remote BLAST factory using GenomeNet
    def self.genomenet(program, db, options = [])
      GenomeNet.new(program, db, options)
      #Bio::Blast.new(program, db, options, 'genomenet')
    end

  end #module Remote

end #class Bio::Blast

