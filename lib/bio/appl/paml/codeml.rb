#
# = bio/appl/paml/codeml.rb - Wrapper for running PAML program codeml
#
# Copyright::  Copyright (C) 2008
#              Michael D. Barton <mail@michaelbarton.me.uk>,
#              Naohisa Goto <ng@bioruby.org>
#
# License::    The Ruby License
#
# == Description
#
# This file contains a wrapper for running the CODEML tool for estimating evolutionary rate 
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'bio/appl/paml/common'

module Bio
module PAML

  # == Description
  #
  # Bio::PAML::Codeml is a wrapper for estimating evolutionary rate using the CODEML 
  # tool. The class provides methods for generating the necessary configuration 
  # file, and running codeml with the specified binary. Codeml output is 
  # returned when codeml is run. Bio::PAML::Codeml::Report and Bio::PAML::Codeml::Rates
  # provide simple classes for parsing and accessing the Codeml report and
  # rates files respectively.
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
  #   # Creates a Codeml object
  #   codeml = Bio::PAML::Codeml.new
  #   # Sets parameters
  #   codeml.parameters[:runmode] = 0
  #   codeml.parameters[:RateAncestor] = 1
  #   # You can also set many parameters at a time.
  #   codeml.parameters.update({ :alpha => 0.5, :fix_alpha => 0 })
  #   # Executes codeml with the alignment and the tree
  #   report = codeml.query(alignment, tree)
  #       
  # Example 2 (Obsolete usage):
  #
  #   # Create a control file, setting some Codeml options
  #   # Default parameters are used otherwise, see RDoc for defaults
  #   # The names of the parameters correspond to those specified
  #   # in the Codeml documentation
  #   control_file = Tempfile.new('codeml_ctl')
  #   control_file.close(false)
  #   # Prepare output file as a temporary file
  #   output_file = Tempfile.new('codeml_test')
  #   output_file.close(false)
  #   Bio::PAML::Codeml.create_control_file(config_file.path, {
  #     :model       => 1,
  #     :fix_kappa   => 1,
  #     :aaRatefile  => TEST_DATA + '/wag.dat',
  #     :seqfile     => TEST_DATA + '/abglobin.aa',
  #     :treefile    => TEST_DATA + '/abglobin.trees',
  #     :outfile     => output_file.path,
  #   })
  #   
  #   # Create an instance of Codeml specifying where the codeml binary is
  #   codeml = Bio::PAML::Codeml.new('/path/to/codeml')
  #   
  #   # Run codeml using a control file
  #   # Returns the command line output
  #   codeml_output = codeml.run(control_file)
  #
  class Codeml < Common

    autoload  :Report,  'bio/appl/paml/codeml/report'
    autoload  :Rates,   'bio/appl/paml/codeml/rates'

    # Default program name
    DEFAULT_PROGRAM = 'codeml'.freeze

    # Default parameters when running codeml.
    #
    # The parameters whose values are different from the codeml defalut
    # value (described in pamlDOC.pdf) in PAML 4.1 are:
    #  seqfile, outfile, treefile, ndata, noisy, verbose, cleandata
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
      :seqtype             => 2,
      :CodonFreq           => 2,
      :ndata               => 1,
      :clock               => 0,
      :aaDist              => 0,
      :aaRatefile          => 'wag.dat',
      :model               => 2,
      :NSsites             => 0,
      :icode               => 0,
      :Mgene               => 0,
      :fix_kappa           => 0,
      :kappa               => 2,
      :fix_omega           => 0,
      :omega               => 0.4,
      :fix_alpha           => 0,
      :alpha               => 0.0,
      :Malpha              => 0,
      :ncatG               => 3,
      :fix_rho             => 1,
      :rho                 => 0.0,
      :getSE               => 0,
      :RateAncestor        => 0,
      :Small_Diff          => 0.5e-6,
      :cleandata           => 1,
      :fix_blength         => 0,
      :method              => 0
    }

    # OBSOLETE. This method should not be used. 
    # Instead, use parameters.
    def options
      warn 'The method Codeml#options will be changed to be used for command line arguments in the future. Instead, use Codeml#parameters.'
      parameters
    end

    # OBSOLETE. This method should not be used. 
    # Instead, use parameters=(hash).
    def options=(hash)
      warn 'The method Codeml#options=() will be changed to be used for command line arguments in the future. Instead, use Codeml#parameters=().'
      self.parameters=(hash)
    end

    # Obsolete. This method will be removed in the future.
    # Helper method for creating a codeml control file.
    # Note that default parameters are automatically merged.
    def self.create_control_file(parameters, filename)
      parameters = DEFAULT_PARAMETERS.merge(parameters)
      File.open(filename, 'w') do |file|
        parameters.each do |key, value|
          file.puts "#{key.to_s} = #{value.to_s}" if value
        end
      end
      filename
    end

    # OBSOLETE. This method will soon be removed.
    # Instead, use create_control_file(parameters, filename).
    def self.create_config_file(parameters, filename)
      warn "The method Codeml.create_config_file(parameters, filename) will soon be removed. Instead, use Codeml.create_control_file(filename, parameters)."
      create_control_file(parameters, filename)
    end


    # Runs the program on the internal parameters with the specified
    # sequence alignment and tree.
    #
    # Note that parameters[:seqfile] and parameters[:outfile]
    # are always modified, and parameters[:treefile] and
    # parameters[:aaRatefile] are modified when tree and aarate are
    # specified respectively.
    #
    # For other important information, see the document of
    # Bio::PAML::Common#query.
    #
    # ---
    # *Arguments*:
    # * (required) _alignment_: Bio::Alignment object or similar object
    # * (optional) _tree_: Bio::Tree object
    # * (optional) _aarate_: String or nil
    # *Returns*:: Report object
    def query(alignment, tree = nil, aarate = nil)
      begin
        aaratefile = prepare_aaratefile(aarate)
        ret = super(alignment, tree)
      ensure
        finalize_aaratefile(aaratefile)
      end
      ret
    end

    # Runs the program on the internal parameters with the specified
    # sequence alignment data string and tree data string.
    #
    # Note that parameters[:outfile] is always modified, and
    # parameters[:seqfile], parameters[:treefile], and
    # parameters[:aaRatefile] are modified when
    # alignment, tree, and aarate are specified respectively.
    #
    # It raises RuntimeError if seqfile is not specified in the argument
    # or in the parameter.
    #
    # For other important information, see the document of query method.
    # 
    # ---
    # *Arguments*:
    # * (optional) _alignment_: String
    # * (optional) _tree_: String or nil
    # * (optional) _aarate_: String or nil
    # *Returns*:: contents of output file (String)
    def query_by_string(alignment = nil, tree = nil, aarate = nil)
      begin
        aaratefile = prepare_aaratefile(aarate)
        ret = super(alignment, tree)
      ensure
        finalize_aaratefile(aaratefile)
      end
      ret
    end

    private

    # (private) prepares temporary file for aaRatefile if needed
    def prepare_aaratefile(aarate)
      if aarate then
        aaratefile = Tempfile.new('codeml_aarate')
        aaratefile.print aarate
        aaratefile.close(false)
        self.parameters[:aaRatefile] = aaratefile.path
      end
      aaratefile
    end

    # (private) removes temporary file for aaRatefile if needed
    def finalize_aaratefile(aaratefile)
      aaratefile.close(true) if aaratefile
    end

  end # End class Codeml
end # End module PAML
end # End module Bio
