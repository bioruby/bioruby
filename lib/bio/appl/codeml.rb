#
# = bio/appl/codeml.rb - Wrapper for running codeml
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>,
#
# License::    The Ruby License
#
# == Description
#
# This file contains a wrapper for running the CodeML tool for estimating evolutionary rate 
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'tempfile'

module Bio

  # == Description
  #
  # Bio::CodeML is a wrapper for estimating evolutionary rate using the CodeML 
  # tool. The class provides methods for generating the necessary configuration 
  # file, and running CodeML with the specified binary. CodeML output is 
  # returned when CodeML is run. Bio::CodeML::Report and Bio::CodeML::Rates
  # provide simple classes for parsing and accessing the CodeML report and
  # rates files respectively.
  #
  # == Usage
  #
  #   require 'bio'
  #
  #   # Create a config file, setting some CodeML options
  #   # Default options are used otherwise, see RDoc for defaults
  #   # The names of the options correspond to those specified in the CodeML documentation
  #   config_file = Tempfile.new('codeml_config').path
  #   Bio::CodeML.create_config_file({
  #     :model       => 1,
  #     :fix_kappa   => 1,
  #     :aaRatefile  => TEST_DATA + '/wag.dat',
  #     :seqfile     => TEST_DATA + '/abglobin.aa',
  #     :treefile    => TEST_DATA + '/abglobin.trees',
  #     :outfile     => Tempfile.new('codeml_test').path,
  #    },config_file)
  #
  #    # Create an instance of CodeML specifying where the codeml binary is
  #    codeml = Bio::CodeML.new('codeml_binary')
  #
  #    # Run codeml using a config file
  #    # Returns the command line output
  #    codeml_output = codeml.run(config_file)
  #
  class CodeML

    autoload  :Report,  'bio/appl/codeml/report'
    autoload  :Rates,   'bio/appl/codeml/rates'

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

    def initialize(codeml_location)
      unless File.exists?(codeml_location)
        raise ArgumentError.new("File does not exist : #{codeml_location}")
      end
      @binary = codeml_location
    end

    def run(config_file = create_config_file)
      load_options_from_file(config_file)
      check_options
      output = %x[ #{@binary} #{config_file} ]
      output
    end
 
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

  end # End CodeML
end # End Bio
