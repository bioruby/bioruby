#
# = bio/appl/meme/mast/report.rb - Mast output parser class
#
# Copyright::  Copyright (C) 2008, Adam Kraut <adamnkraut@gmail.com>,

#
# License::    The Ruby License
#
# == Description
#
# This file contains a class to parse Mast output
#
# == Examples
#
# == References
#
# * http://meme.sdsc.edu/meme/intro.html

require "bio/appl/meme/mast"
require "bio/appl/meme/motif"

module Bio
  module Meme
    class Mast

      # == Description
      #
      # A class to parse the output from Mast
      #
      # WARNING: Currently support is only for -hit_list (machine readable) format
      #          HTML (default) output is not supported
      #
      # == Examples
      #

      class Report
        
        attr_reader :motifs

        def initialize(mast_hitlist)
          @motifs = parse_hit_list(mast_hitlist)
        end
        
        # Iterates each motif (Bio::Meme::Motif)
        def each
          @motifs.each do |motif|
            yield motif
          end
        end
        alias :each_motif :each
        
        
        private
        
        # Each line corresponds to one motif occurrence in one sequence.
        #         The format of the hit lines is
        #                [<sequence_name> <strand><motif> <start> <end> <p-value>]+
        #         where 
        #                 <sequence_name> is the name of the sequence containing the hit
        #                 <strand>        is the strand (+ or - for DNA, blank for protein),
        #                 <motif>         is the motif number,
        #                 <start>         is the starting position of the hit,
        #                 <end>           is the ending position of the hit, and
        #                 <p-value>       is the position p-value of the hit.
        def parse_hit_list(data)
          motifs = []
          data.each_line do |line|
            
            line.chomp!
            
            # skip comments
            next if line =~ /^#/
            
            fields = line.split(/\s/)
            
            if fields.size == 5
              motifs << Motif.new(fields[0], nil, fields[1], fields[2], fields[3], fields[4])
            elsif fields.size == 6
              motifs << Motif.new(fields[0], fields[1], fields[2], fields[3], fields[4], fields[5])
            else
              raise RuntimeError.new("Could not parse mast output")
            end
            
          end
          motifs
        end

      end # Result
    end # Mast
  end # Meme
end # Bio
