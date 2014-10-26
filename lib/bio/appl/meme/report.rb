#
# = bio/appl/meme/report.rb - Meme output parser class
#
# Copyright::  Copyright (C) 2008, Adam Kraut <adamnkraut@gmail.com>,
# Copyright::  Copyright (C) 2011, Brandon Fulk <brandon.fulk@gmail.com>,
#
# License::    The Ruby License
#
# == Description
#
# This file contains a class to parse Meme output
#
# == Examples
#
# == References
#
# * http://meme.sdsc.edu/meme/intro.html

require "bio/appl/meme"
require "bio/appl/meme/motif"

module Bio
  #  module Meme
  class Meme

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
        
        attr_reader :motifs, :sites

        def initialize(report)
          @motifs = parse_motif_list(report)
        end
        
        # Iterates each motif (Bio::Meme::Motif)
        def each
          @motifs.each do |motif|
            yield motif
          end
        end
        alias :each_motif :each
        
                
        private
        
        
        # This method will extract the meme output data and create Meme::Motif objects
        # out of each motif.  Each motif also has Meme::Motif::Site objects for each site.
        #                 <p-value>       is the position p-value of the hit.
        def parse_motif_list(data)
          
          meme_file_format = /\*+.^MEME - Motif discovery tool/m

          unless meme_file_format =~ data
            raise RuntimeError.new("This data is of the incorrect format")
          end

          motifs = []
          sites  = []

          ## TODO: Refactor this so it doesn't parse line by line but will parse each motif
          # separately... each motif will then have other methods to parse each site's results

          # these variables are flags, raised when a record or a regex if found
          record_start = false
          regex_match  = false

          motif_number = 0
          motif_width  = 0
          motif_regex  = //
          data.each_line do |line|
            # skip comments
            next if line =~ /^#/
            # skip lines that begin with dashes
            next if line =~ /^-+/
            

            # This regex is looking for the motif line
            motif_regex = /^MOTIF\s{2}(\d+)\swidth =\s+(\d+)/
            # This regex is looking for the site report sorted by p value          
            record_regex = /^(\w+)[\.\d\|\w]+\s+(\d+)\s+(\d\.\d+e\-\d+)/
            # This regex is looking for this motif's regex
            regex_regex  = /\s+Motif \d regular expression/

            # if you found the line detailing this motif, capture it
            if motif_regex.match(line)
              motif_number = $1   #This shows the first capture
              motif_width  = $2   #This shows the second capture

            # else if this line starts the motif sites sorted by p-value, set the record_start flag
            elsif line =~ /^Sequence name\s+Start\s+P-value/
              record_start = true
              next
            # else if the start of the record has been found AND the record_regex has matched, capture input
            elsif record_start and record_regex.match(line)
              if RUBY_VERSION > 1.9
                /^(?<site_name>\w+)[\.\d\|\w]+\s+(?<site_start>\d+)\s+(?<site_pvalue>\d\.\d+e\-\d+)\s+\w+\s+(?<site_sequence>\w+)/ =~ line
              else
                site_name     = $1
                site_start    = $2
                site_pvalue   = $3
                site_sequence = $4
              # need this minus 1 or else the sequence is 1 AA too long
              site_end = site_start.to_i + motif_width.to_i - 1
                            
              site = { :site_name   => site_name,
                       :site_start  => site_start,
                       :site_end    => site_end,
                       :site_pvalue => site_pvalue,
                       :site_sequence => site_sequence }
              sites << site
   

            # if you have been parsing sites and you run across a dashed line, end this motif
            elsif record_start and line =~ /^-+/
              record_start = false
              # just making sure this will delete the sites for this motif
              sites = []
            # this will look for the line before the regex line and raise a flag              
            elsif regex_regex.match(line)
              regex_match = true
              next
            # Once the regex_match flag is raised, it will capture the next line (except the ----- line)
            elsif regex_match
              motif_regex = line.chomp!
              regex_match = false
              puts motif_number.to_s
              motifs << Meme::Motif.new(motif_number, motif_width, motif_regex, sites)
            else              
              # need to find a way to display errors if the input file is bad
              # raise RuntimeError.new("Could not parse meme output")
            end          
            
          end
          motifs
        end

      end # Result
      #    end #Meme module
  end # Meme
end # Bio
