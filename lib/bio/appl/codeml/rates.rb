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
        array
      end

    end
  end
end
