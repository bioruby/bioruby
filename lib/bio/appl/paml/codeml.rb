#
# = bio/appl/paml/codeml.rb - Wrapper for running PAML program codeml
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>,
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

require 'tempfile'

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
  # == Usage
  #
  #   require 'bio'
  #
  #   # Create a config file, setting some Codeml options
  #   # Default options are used otherwise, see RDoc for defaults
  #   # The names of the options correspond to those specified in the Codeml documentation
  #   config_file = Tempfile.new('codeml_config').path
  #   Bio::PAML::Codeml.create_config_file({
  #     :model       => 1,
  #     :fix_kappa   => 1,
  #     :aaRatefile  => TEST_DATA + '/wag.dat',
  #     :seqfile     => TEST_DATA + '/abglobin.aa',
  #     :treefile    => TEST_DATA + '/abglobin.trees',
  #     :outfile     => Tempfile.new('codeml_test').path,
  #    },config_file)
  #
  #    # Create an instance of Codeml specifying where the codeml binary is
  #    codeml = Bio::PAML::Codeml.new('codeml_binary')
  #
  #    # Run codeml using a config file
  #    # Returns the command line output
  #    codeml_output = codeml.run(config_file)
  #
  class Codeml

    autoload  :Report,  'bio/appl/paml/codeml/report'
    autoload  :Rates,   'bio/appl/paml/codeml/rates'

    DEFAULT_OPTIONS = {
      # Essential argumemts
      :seqfile             => nil,
      :treefile            => nil,
      # Optional arguments
      :outfile             => Tempfile.new('codeml').path,
      :noisy               => 0,
      :verbose             => 1,
      :runmode             => 0,
      :seqtype             => 2,
      :CodonFreq           => 2,
      :ndata               => 1,
      :clock               => 0,
      :aaDist              => 0,
      :aaRatefile          => 'wag.dat',
      :model               => 3,
      :NSsites             => 0,
      :icode               => 0,
      :Mgene               => 0,
      :fix_kappa           => 0,
      :kappa               => 2,
      :fix_omega           => 0,
      :omega               => 0.4,
      :fix_alpha           => 0,
      :alpha               => 0.5,
      :Malpha              => 0,
      :ncatG               => 8,
      :getSE               => 0,
      :RateAncestor        => 0,
      :Small_Diff          => 0.000005,
      :cleandata           => 1,
      :fix_blength         => 0,
      :method              => 0
    }
  
    attr_accessor :options


    # Create a codeml instance, which will run using the specified binary location
    # This method with throw and error if the binary cannot be found.
    def initialize(codeml_location)
      unless File.exists?(codeml_location)
        raise ArgumentError.new("File does not exist : #{codeml_location}")
      end
      @binary = codeml_location
    end

    # Runs the codeml analysis based on the options in the passed config file
    # An error will be thrown if required options are not specific in the config file
    def run(config_file)
      load_options_from_file(config_file)
      check_options
      output = %x[ #{@binary} #{config_file} ]
      output
    end

    # Helper method for creating a codeml config file
    def self.create_config_file(options = Hash.new, location = Tempfile.new('codeml_config').path)
      options = DEFAULT_OPTIONS.merge(options)
      File.open(location,'w') do |file|
        options.each do |key, value|
          file.puts "#{key.to_s} = #{value.to_s}"
        end
      end
      location
    end

    private

    def load_options_from_file(file)
      options = Hash.new
      File.readlines(file).each do |line|
        param, value = line.strip.split(/\s+=\s+/)
        options[param.to_sym] = value
      end
      self.options = options
    end

    def check_options
      raise ArgumentError.new("Sequence file not found") unless File.exists?(self.options[:seqfile])
      raise ArgumentError.new("Tree file not found") unless File.exists?(self.options[:treefile])
    end

  end # End class Codeml
end # End module PAML
end # End module Bio
