#
# = bio/appl/paml/codeml/rates.rb - Codeml rates report file parser
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
#
# License::    The Ruby License
#
# == Description
#
# This file contains a class that implement a simple interface to Codeml rates estimation file
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'delegate'
require 'bio/appl/paml/codeml'

module Bio::PAML
  class Codeml

    # == Description
    # 
    # A simple class for parsing the codeml rates file.
    #
    # WARNING: The order of the parsed data should be correct, however will
    # not necessarily correspond to the position in the alignment. For instance
    # codeml ignores columns that contains gaps, and therefore there will not
    # be any estimated rate data.
    #
    # == Usage
    #
    # site_rates = Bio::PAML::Codeml::Rates.new(File.open(@tmp_dir + "/rates").read)
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
