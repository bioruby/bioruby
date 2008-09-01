#
# = bio/appl/paml/codeml/report.rb - Codeml report parser
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
#
# License::    The Ruby License
#
# == Description
#
# This file contains a class that implement a simple interface to Codeml output file
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'bio/appl/paml/codeml'

module Bio::PAML
  class Codeml

    # == Description
    #
    # A simple class for parsing codeml output.
    #
    # WARNING: This data is parsed using a regex from the output file, and
    # so will take the first result found. If using multiple tree's, your
    # milage may vary. See the source for the regular expressions.
    #
    # require 'bio'
    #
    # report = Bio::PAML::Codeml::Report.new(File.open(codeml_output_file).read)
    # report.gene_rate  # => Rate of gene evolution as defined be alpha
    # report.tree_lengh # => Estimated phylogetic tree length
    class Report

      attr_reader :tree_log_likelihood, :tree_length, :alpha, :tree

      def initialize(codeml_report)
        @tree_log_likelihood = pull_tree_log_likelihood(codeml_report)
        @tree_length = pull_tree_length(codeml_report)
        @alpha = pull_alpha(codeml_report)
        @tree = pull_tree(codeml_report)
      end

      private

      def pull_tree_log_likelihood(text)
        text[/lnL\(.+\):\s+(-?\d+(\.\d+)?)/,1].to_f
      end

      
      def pull_tree_length(text)
        text[/tree length\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      def pull_alpha(text)
        text[/alpha .+ =\s+(-?\d+(\.\d+)?)/,1].to_f
      end

      def pull_tree(text)
        text[/([^\n]+)\n\nDetailed/m,1]
      end

    end # End Report
  end # End Codeml
end # End Bio::PAML
