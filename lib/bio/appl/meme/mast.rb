#
# = bio/appl/meme/mast.rb - Wrapper for running MAST program
#
# Copyright::  Copyright (C) 2008 Adam Kraut <adamnkraut@gmail.com>,
#
# License::    The Ruby License
#
# == Description
#
# This file contains a wrapper for running the MAST tool for searching sequence databases using motifs
#
# == References
#
# * http://meme.sdsc.edu/meme/intro.html
#
require "bio/command"

module Bio
module Meme

  # == Description
  #
  # Bio::Meme::Mast is a wrapper for searching a database using sequence motifs.  The code
  # will read options from a Hash and run the program.  Parsing of the output is provided by
  # Bio::Meme::Mast::Report.  Before running, options[:mfile] and options[:d] must be set 
  # in the constructor or Mast.config(options = {})
  #
  # == Usage
  #
  #   mast = Mast.new('/path/to/mast')
  #   or with options
  #   mast = Mast.new('/path/to/mast', {:mfile => 'meme.out', :d => '/shared/db/nr'})
  #
  #   report = Mast::Report.new(mast.run)
  #   report.each do |motif|
  #     puts motif.length
  #   end
  #
  #
  class Mast
    
    include Bio::Command
    
    autoload :Report, 'bio/appl/meme/mast/report'
    
    # A Hash of options for Mast
    attr_accessor :options

    DEFAULT_OPTIONS = {
      # required
      :mfile => nil, 
      :d => nil,
      # optional 
      :stdin => nil, # may not work as expected
      :count => nil, 
      :alphabet => nil, 
      :stdout => true, 
      :text => false, 
      :sep => false, 
      :norc => false, 
      :dna => false, 
      :comp => false, 
      :rank => nil, 
      :smax => nil, 
      :ev => nil, 
      :mt => nil,
      :w => false, 
      :bfile => nil, 
      :seqp => false, 
      :mf => nil, 
      :df => nil, 
      :minseqs => nil, 
      :mev => nil, 
      :m => nil, 
      :diag => nil, 
      :best => false, 
      :remcorr => false, 
      :brief => false, 
      :b => false, 
      :nostatus => true, 
      :hit_list => true, 
    }

    # The command line String to be executed
    attr_reader :cmd
    
    # Create a mast instance
    #
    #   m = Mast.new('/usr/local/bin/mast')
    # ---
    # *Arguments*:
    # * (required) _mast_location_: String
    # *Raises*:: ArgumentError if mast program is not found
    # *Returns*:: a Bio::Meme::Mast object
    
    def initialize(mast_location, options = {})
      unless File.exists?(mast_location)
        raise ArgumentError.new("mast: command not found : #{mast_location}")
      end
      @binary = mast_location
      options.empty? ? config(DEFAULT_OPTIONS) : config(options)
    end

    # Builds the command line string
    # any options passed in will be merged with DEFAULT_OPTIONS
    # Mast usage: mast <mfile> <opts> <flags>
    #
    #   mast.config({:mfile => "meme.out", :d => "/path/to/fasta/db"})
    # ---
    # *Arguments*:
    # * (required) _options_: Hash (see DEFAULT_OPTIONS)
    # *Returns*:: the command line string

    def config(options)
      @options = DEFAULT_OPTIONS.merge(options)
      mfile, opts, flags = "", "", ""
      @options.each_pair do |opt, val|
        if val.nil? or val == false
          next
        elsif opt == :mfile
          mfile = val
        elsif val == true
          flags << " -#{opt}"
        else
          opts << " -#{opt} #{val}"
        end
      end
      @cmd = "#{@binary} #{mfile + opts + flags}"
    end

    # Checks if input/database files exist and options are valid
    # *Raises*:: ArgumentError if the motifs file does not exist
    # *Raises*:: ArgumentError if the database file does not exist
    # *Raises*:: ArgumentError if there is an invalid option
    
    def check_options
      @options.each_key do |k|
        raise ArgumentError.new("Invalid option: #{k}") unless DEFAULT_OPTIONS.has_key?(k)
      end
      raise ArgumentError.new("Motif file not found: #{@options[:mfile]}") if @options[:mfile].nil? or !File.exists?(@options[:mfile])
      raise ArgumentError.new("Database not found: #{@options[:d]}") if @options[:d].nil? or !File.exists?(@options[:d])
    end

    # Run the mast program
    # ---
    # *Returns*:: Bio::Meme::Mast::Report object
    
    def run
      check_options
      call_command(@cmd) {|io| @output = io.read }
      Report.new(@output)
    end
    
  end # End class Mast
end # End module Meme
end # End module Bio