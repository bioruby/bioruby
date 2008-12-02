#
# = bio/appl/paml/baseml.rb - Wrapper for running PAML program baseml
#
# Copyright::  Copyright (C) 2008
#              Naohisa Goto <ng@bioruby.org>
#
# License::    The Ruby License
#
# == Description
#
# This file contains Bio::PAML::Baseml, a wrapper class running baseml.
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'bio/appl/paml/common'

module Bio::PAML

  # == Description
  #
  # Bio::PAML::Baseml is a wrapper for running PAML baseml program. 
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
  #   # Reads newick tree from a file
  #   tree = Bio::FlatFile.open(Bio::Newick, 'example.tree').tree
  #   # Creates a Baseml object
  #   baseml = Bio::PAML::Baseml.new
  #   # Sets parameters
  #   baseml.parameters[:runmode] = 0
  #   baseml.parameters[:RateAncestor] = 1
  #   # You can also set many parameters at a time.
  #   baseml.parameters.update({ :alpha => 0.5, :fix_alpha => 0 })
  #   # Executes baseml with the alignment and the tree
  #   report = baseml.query(alignment, tree)
  #
  class Baseml < Common

    autoload  :Report,  'bio/appl/paml/baseml/report'

    # Default program name
    DEFAULT_PROGRAM = 'baseml'.freeze

    # Default parameters when running baseml.
    #
    # The parameters whose values are different from the baseml defalut
    # value (described in pamlDOC.pdf) in PAML 4.1 are:
    #  seqfile, outfile, treefile, ndata, noisy, verbose
    #
    DEFAULT_PARAMETERS = {
      # Essential argumemts
      :seqfile             => nil,
      :outfile             => nil,
      # Optional arguments
      :treefile            => nil,
      :noisy               => 0,
      :verbose             => 1,
      :runmode             => 0,
      :model               => 5,
      :Mgene               => 0,
      :ndata               => 1,
      :clock               => 0,
      :fix_kappa           => 0,
      :kappa               => 2.5,
      :fix_alpha           => 1,
      :alpha               => 0.0,
      :Malpha              => 0,
      :ncatG               => 5,
      :fix_rho             => 1,
      :rho                 => 0.0,
      :nparK               => 0,
      :nhomo               => 0,
      :getSE               => 0,
      :RateAncestor        => 0,
      :Small_Diff          => 1e-6,
      :cleandata           => 1,
      :fix_blength         => 0,
      :method              => 0
    }

  end #class Baseml
end #module Bio::PAML

