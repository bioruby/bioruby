#
# = bio/appl/meme.rb - Wrapper for running MEME program
#
# Copyright::  Copyright (C) 2008 Adam Kraut <adamnkraut@gmail.com>,8
# Copyright::  Copyright (C) 2011 Brandon Fulk <brandon.fulk@gmail.com>,
#
# License::    The Ruby License
#
# == Description
#
# This file contains a wrapper for running the MEME tool for finding motifs in a dataset.
# This implementation was modeled after the MAST wrapper developed by Adam Kraut.
#
# == References
#
# * http://meme.sdsc.edu/meme/intro.html
#
require "bio/command"

module Bio

  # == Description
  #
  # Bio::Meme is a wrapper for searching a dataset using the MEME program.  The code
  # will read options from a Hash and run the program.  Parsing of the output is provided by
  # Bio::Meme::Report.  Before running, options[:dataset] must be set in the constructor
  # or Meme.config(options = {})
  #
  # == Usage
  #
  #   meme = Meme.new('/path/to/meme')
  #   or with options
  #   meme = Meme.new('/path/to/meme', {:dataset => 'dataset', :mod => 'zoops'})
  #
  #   report = Meme::Report.new(meme.run)
  #   report.each do |motif|
  #     puts motif.length
  #   end
  #
  #  
  
  class Meme
    
    include Bio::Command
    
    autoload :Report, 'bio/appl/meme/report'
    
    # A Hash of options for Meme
    attr_accessor :options

    # Try to refactor so nostatus can be symbol instead of ''
    DEFAULT_OPTIONS = {
      # required
      :dataset => 'dataset', 
      # optional 
      :protein  => true,
      :text     => true,
      :mod      => 'oops',
      :maxw     => 40,
      :nmotifs  => 3,
      
      # other options, not default
      :dna      => false,
      :w        => nil,
      :minw     => nil,
      :wg       => nil,
      :ws       => nil,
      :noendgaps => nil,
      :bfile    => nil,
      :revcomp  => nil,
      :pal      => nil,
      :maxiter  => nil,
      :distance => nil,
      :psp      => nil,
      :prior    => nil,
      :b        => nil,
      :plib     => nil,
      :spfuzz   => nil,
      :spmap    => nil,
      :cons     => nil,
      :heapsize => nil,
      :x_branch => nil,
      :w_branch => nil,
      :bfactor  => nil,
      :maxsize  => nil,
      :nostatus => nil,
      :p        => nil,
      :time     => nil,
      :sf       => nil,
      :V        => nil,  
      
      # Another default, listed down here because it won't be recognized if listed earlier
      :nostatus => true,  
    }

    # The command line String to be executed
    attr_reader :cmd
    
    # Create a meme instance
    #
    #   m = Meme.new('/usr/local/bin/meme')
    # ---
    # *Arguments*:
    # * (required) _mast_location_: String
    # *Raises*:: ArgumentError if mast program is not found
    # *Returns*:: a Bio::Meme object
    
    def initialize(meme_location, options = {})
      unless File.exists?(meme_location)
        raise ArgumentError.new("meme: command not found : #{meme_location}")
      end
      @binary = meme_location
      options.empty? ? config(DEFAULT_OPTIONS) : config(options)
    end
    
    # Builds the command line string
    # any options passed in will be merged with DEFAULT_OPTIONS
    # Meme usage: meme <dataset> <opts> <flags>
    #
    #   meme.config({:dataset => "dataset"})
    # ---
    # *Arguments*:
    # * (required) _options_: Hash (see DEFAULT_OPTIONS)
    # *Returns*:: the command line string

    def config(options)
      @options = DEFAULT_OPTIONS.merge(options)
      dataset, opts, flags = "", "", ""
      @options.each_pair do |opt, val|
        if val.nil? or val == false
          next
        elsif opt == :dataset
          dataset = val
        elsif val == true
          flags << " -#{opt}"
        else
          opts << " -#{opt} #{val}"
        end
      end
      @cmd = "#{@binary} #{dataset + opts + flags}"
    end
    
    # Checks if input file exists and options are valid
    # *Raises*:: ArgumentError if the dataset file does not exist
    # *Raises*:: ArgumentError if there is an invalid option
    
    def check_options
      @options.each_key do |k|
        raise ArgumentError.new("Invalid option: #{k}") unless DEFAULT_OPTIONS.has_key?(k)
      end
      raise ArgumentError.new("Dataset file not found: #{@options[:dataset]}") if @options[:dataset].nil? or !File.exists?(@options[:dataset])
    end

    # Run the meme program
    # ---
    # *Returns*:: Bio::Meme::Report object
    
    def run
      check_options
      @command = @cmd.split
      call_command(@command) {|io| @output = io.read }
      Report.new(@output)
    end
    
  end # end Meme class
end # end Bio module