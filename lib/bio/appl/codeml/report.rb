#
# = bio/appl/codeml/report.rb - CodeML report parser
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
#
# License::    The Ruby License
#
# == Description
#
# This file contains a class that implement a simple interface to CodeML output file
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

module Bio
  class CodeML
    class Report

      attr_reader :tree_log_likelihood, :tree_length, :alpha

      def initialize(codeml_report)
        @tree_log_likelihood = pull_tree_log_likelihood(codeml_report)
        @tree_length = pull_tree_length(codeml_report)
        @alpha = pull_alpha(codeml_report)
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

    end # End Report
  end # End CodeML
end # End Bio
