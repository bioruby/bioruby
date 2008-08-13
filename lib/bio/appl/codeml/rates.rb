#
# = bio/appl/codeml/rates.rb - CodeML rates report file parser
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
#
# License::    The Ruby License
#
# == Description
#
# This file contains a class that implement a simple interface to CodeML rates estimation file
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'delegate'

module Bio
  class CodeML

    # == Description
    # 
    # A simple class for parsing the codeml rates file.
    #
    # == Usage
    #
    # site_rates = Bio::CodeML::Rates.new(File.open(@tmp_dir + "/rates").read)
    # site_rate.first[:freq] # => Number of times that column appears
    # site_rate.[5][:rate] # => Estimated rate of evolution
    # site_rate.last[:data] # => The content of the column, as a string
    #
    # # This class delegates to an array, so will respond to all array methods
    # site_rates.max {|x,y| x[:rate] <=> y[:rate] } # => Fastest evolving column
    # site_rates.detect {|x| x[:freq] > 1 } # => Columns appearing more than once
    class Rates < DelegateClass(Array)

      def initialize(rates)
        super(parse_rates(rates))
      end

      private

      def parse_rates(text)
        re = /\s+(\d+)\s+(\d+)\s+([A-Z]+)\s+(\d+\.\d+)\s+(\d)/
        array = Array.new
        text.each do |line|
          if re =~ line
            match = Regexp.last_match
            array[match[1].to_i] = {
              :freq => match[2].to_i, 
              :data => match[3], 
              :rate => match[4].to_f }
          end
        end
        array.compact
      end

    end
  end
end
