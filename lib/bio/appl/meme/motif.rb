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
  class Meme

  # == Description
  #
  # This class minimally represents a sequence motif according to the MEME program
  #
  # TODO: integrate with Bio::Sequence class
  # TODO: parse PSSM data
  #
  class Motif
    attr_accessor :motif_number, :motif_width, :motif_regex, :sites
    
    # Creates a new Bio::Meme::Motif object
    # arguments are 
    def initialize(motif_number, motif_width, motif_regex, sites)
      @motif_number = motif_number.to_i
      @motif_width  = motif_width.to_i
      # would like to have this return a Regex object
      @motif_regex  = motif_regex
      @sites = []
      sites.each do |site|
        @sites << Site.new(site[:site_name], site[:site_start], site[:site_end], site[:site_pvalue], site[:site_sequence])
      end
    end

    def each_site 
      @sites.each do |site|
        yield site
      end
    end

    # Computes the motif length
    def length
      @motif_width
    end

    
    
    class Site
      attr_accessor :site_name, :site_start, :site_end, :site_pvalue, :site_sequence
      # this site class should take in a motif and initialize each site for that motif
      def initialize(site_name, site_start, site_end, site_pvalue, site_sequence)
        @site_name = site_name.to_s
        @site_start = site_start.to_i
        @site_end = site_end.to_i
        @site_pvalue = site_pvalue.to_f        
        @site_sequence = site_sequence.to_s
      end
      
    end # end Site class
  end # end Motif class
  
end  
end
