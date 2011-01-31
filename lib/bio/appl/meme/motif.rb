#
# = bio/appl/meme/motif.rb - Class to represent a sequence motif
#
# Copyright::  Copyright (C) 2008 Adam Kraut <adamnkraut@gmail.com>,
#
# License::    The Ruby License
#
# == Description
#
# This file contains a minimal class to represent meme motifs
#
# == References
#
# * http://meme.sdsc.edu/meme/intro.html
#
module Bio
module Meme

  # == Description
  #
  # This class minimally represents a sequence motif according to the MEME program
  #
  # TODO: integrate with Bio::Sequence class
  # TODO: parse PSSM data
  #
  class Motif
    attr_accessor :sequence_name, :strand, :motif, :start_pos, :end_pos, :pvalue

    # Creates a new Bio::Meme::Motif object
    # arguments are 
    def initialize(sequence_name, strand, motif, start_pos, end_pos, pvalue)
      @sequence_name = sequence_name.to_s
      @strand = strand.to_s
      @motif = motif.to_i
      @start_pos = start_pos.to_i
      @end_pos = end_pos.to_i
      @pvalue = pvalue.to_f
    end

    # Computes the motif length
    def length
      @end_pos - @start_pos
    end

  end
  
end  
end
