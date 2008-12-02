#
# = bio/appl/paml/common_report.rb - basic report class for PAML results
#
# Copyright::  Copyright (C) 2008
#              Naohisa Goto <ng@bioruby.org>
#
# License::    The Ruby License
#
# == Description
#
# This file contains Bio::PAML::Common::Report, a basic report class
# for PAML program's results.
#
# == References
#
# * http://abacus.gene.ucl.ac.uk/software/paml.html
#

require 'bio/appl/paml/common'

module Bio::PAML
  class Common

    # UNDER CONSTRUCTION.
    #
    # Bio::PAML::Common::Report is a basic report class for PAML program's
    # results. It will have common function for baseml and codeml.
    #
    # Normally, users should not use this class directly.
    class Report

      # Creates a new Report object.
      def initialize(str)
      end
    end #class Report

  end #class Common
end #module Bio::PAML
