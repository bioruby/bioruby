#
# = bio/appl/paml/baseml.rb - Wrapper for running PAML program yn00
#
# Copyright::  Copyright (C) 2008
#              Naohisa Goto <ng@bioruby.org>
#
# License::    The Ruby License
#
# == Description
#
# This file contains Bio::PAML::Yn00, a wrapper class running yn00.
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'bio/appl/paml/common'

module Bio::PAML

  # == Description
  #
  # Bio::PAML::Yn00 is a wrapper for running PAML yn00 program. 
  #
  # Because most of the methods in this class are inherited from
  # Bio::PAML::Common, see documents of Bio::PAML::Common for details.
  #
  # == Examples
  #
  # Example 1:
  #
  #   require 'bio'
  #   # Reads multi-fasta formatted file and gets a Bio::Alignment object.
  #   alignment = Bio::FlatFile.open(Bio::Alignment::MultiFastaFormat,
  #                                  'example.fst').alignment
  #   # Creates a Yn00 object
  #   baseml = Bio::PAML::Yn00.new
  #   # Sets parameters
  #   baseml.parameters[:verbose] = 1
  #   baseml.parameters[:icode] = 0
  #   # You can also set many parameters at a time.
  #   baseml.parameters.update({ :weighting => 0, :commonf3x4 => 0 })
  #   # Executes yn00 with the alignment
  #   report = yn00.query(alignment)
  #
  class Yn00 < Common

    autoload  :Report,  'bio/appl/paml/yn00/report'

    # Default program name
    DEFAULT_PROGRAM = 'yn00'.freeze

    # Default parameters when running baseml.
    #
    # The parameters whose values are different from the baseml defalut
    # value (described in pamlDOC.pdf) in PAML 4.1 are:
    #  seqfile, outfile, treefile, ndata, noisy, verbose
    #
    DEFAULT_PARAMETERS = {
      # Essential argumemts
      :seqfile     => nil,
      :outfile     => nil,
      # Optional arguments
      :verbose     => 1,
      :icode       => 0,
      :weighting   => 0,
      :commonf3x4  => 0
    }

    # Runs the program on the internal parameters with the specified
    # sequence alignment.
    # Note that parameters[:seqfile] and parameters[:outfile]
    # are always modified.
    #
    # For other important information, see the document of
    # Bio::PAML::Common#query.
    #
    # ---
    # *Arguments*:
    # * (required) _alignment_: Bio::Alignment object or similar object
    # *Returns*:: Report object
    def query(alignment)
      super(alignment)
    end

    # Runs the program on the internal parameters with the specified
    # sequence alignment as a String object.
    #
    # For other important information, see the document of
    # query and Bio::PAML::Common#query_by_string methods.
    #
    # ---
    # *Arguments*:
    # * (required) _alignment_: Bio::Alignment object or similar object
    # *Returns*:: Report object
    def query_by_string(alignment = nil)
      super(alignment)
    end

  end #class Yn00
end #module Bio::PAML

