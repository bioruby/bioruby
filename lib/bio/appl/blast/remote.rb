#
# = bio/appl/blast/remote.rb - remote BLAST wrapper basic module
# 
# Copyright::  Copyright (C) 2008  Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
# $Id:$
#

require 'bio/appl/blast'

class Bio::Blast

  # Bio::Blast::Remote is a namespace for Remote Blast factory.
  module Remote

    autoload :GenomeNet, 'bio/appl/blast/genomenet'
    autoload :Genomenet, 'bio/appl/blast/genomenet'

    autoload :DDBJ, 'bio/appl/blast/ddbj'
    autoload :Ddbj, 'bio/appl/blast/ddbj'

    # creates a remote BLAST factory using GenomeNet
    def self.genomenet(program, db, options = [])
      GenomeNet.new(program, db, options)
      #Bio::Blast.new(program, db, options, 'genomenet')
    end

    # creates a remote BLAST factory using DDBJ Web service
    def self.ddbj(program, db, options = [])
      DDBJ.new(program, db, options)
      #Bio::Blast.new(program, db, options, 'ddbj')
    end

    # Common methods for meta-information processing
    # (e.g. list of databases).
    module Information

      # (private) parses database information and stores data
      def _parse_databases
        raise NotImplementedError
      end
      private :_parse_databases

      # Returns a list of available nucleotide databases.
      #
      # Note: see the note of databases method.
      #
      # ---
      # *Returns*:: Array containing String objects
      def nucleotide_databases
        _parse_databases
        @databases['blastn']
      end

      # Returns a list of available protein databases.
      #
      # Note: see the note of databases method.
      # ---
      # *Returns*:: Array containing String objects
      def protein_databases
        _parse_databases
        @databases['blastp']
      end

      # Returns a list of available databases for given program.
      #
      # Note: It parses http://blast.genome.jp/ to obtain database information.
      # Thus, if the site is changed, this method can not return correct data.
      # Please tell BioRuby developers when the site is changed.
      #
      # ---
      # *Arguments*:
      # * _program_ (required): blast program('blastn', 'blastp', 'blastx', 'tblastn' or 'tblastx')
      # *Returns*:: Array containing String objects
      def databases(program)
        _parse_databases
        @databases[program] || []
      end

      # Returns a short description of given database.
      #
      # Note: see the note of databases method.
      # ---
      # *Arguments*:
      # * _program_ (required): 'blastn', 'blastp', 'blastx', 'tblastn' or 'tblastx'
      # * _db_ (required): database name
      # *Returns*:: String
      def database_description(program, db)
        _parse_databases
        h = @database_descriptions[program]
        h ? (h[db] || '') : ''
      end

      # Resets data and clears cached data in this module.
      def reset
        @parse_databases = false
        true
      end
    end #module Information

  end #module Remote

end #class Bio::Blast

