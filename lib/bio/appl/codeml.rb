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
require 'english'

module Bio

class CodeML

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
