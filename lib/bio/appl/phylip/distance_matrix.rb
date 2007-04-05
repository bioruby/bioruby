#
# = bio/appl/phylip/distance_matrix.rb - phylip distance matrix parser
#
# Copyright:: Copyright (C) 2006
#             GOTO Naohisa <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id: distance_matrix.rb,v 1.3 2007/04/05 23:35:40 trevor Exp $
#
# = About Bio::Phylip::DistanceMatrix
#
# Please refer document of Bio::Phylip::DistanceMatrix class.
#

require 'matrix'

module Bio
  module Phylip

    # This is a parser class for phylip distance matrix data
    # created by dnadist, protdist, or restdist commands.
    #
    class DistanceMatrix

      # creates a new distance matrix object
      def initialize(str)
        data = str.strip.split(/(?:\r\n|\r|\n)/)
        @otus = data.shift.to_s.strip.to_i
        prev = nil
        data.collect! do |x|
          if /\A +/ =~ x and prev then
            prev.concat x.strip.split(/\s+/)
            nil
          else
            prev = x.strip.split(/\s+/)
            prev
          end
        end
        data.compact!
        if data.size != @otus then
          raise "inconsistent data (OTUs=#{@otus} but #{data.size} rows)"
        end
        @otu_names = data.collect { |x| x.shift }
        mat = data.collect do |x|
          if x.size != @otus then
            raise "inconsistent data (OTUs=#{@otus} but #{x.size} columns)"
          end
          x.collect { |y| y.to_f }
        end
        @matrix = Matrix.rows(mat, false)
        @original_matrix = Matrix.rows(data, false)
      end

      # distance matrix (returns Ruby's Matrix object)
      attr_reader :matrix

      # matrix contains values as original strings.
      # Use it when you doubt precision of floating-point numbers.
      attr_reader :original_matrix

      # number of OTUs
      attr_reader :otus

      # names of OTUs
      attr_reader :otu_names

      # Generates a new phylip distance matrix formatted text as a string.
      def self.generate(matrix, otu_names = nil, options = {})
        if matrix.row_size != matrix.column_size then
          raise "must be a square matrix"
        end
        otus = matrix.row_size
        names = (0...otus).collect do |i|
          name = ((otu_names and otu_names[i]) or "OTU#{i.to_s}")
          name
        end
        data = (0...otus).collect do |i|
          x = (0...otus).collect { |j|  sprintf("%9.6f", matrix[i, j]) }
          x.unshift(sprintf("%-10s", names[i])[0, 10])

          str = x[0, 7].join(' ') + "\n"
          7.step(otus + 1, 7) do |k|
            str << ' ' + x[k, 7].join(' ') + "\n"
          end
          str
        end
        sprintf("%5d\n", otus) + data.join('')
      end
        
    end #class DistanceMatrix

  end #module Phylip

end #module Bio

