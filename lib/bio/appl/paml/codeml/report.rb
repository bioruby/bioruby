#
# = bio/appl/paml/codeml/report.rb - Codeml report parser
#
# Copyright::  Copyright (C) 2008-2010
#              Michael D. Barton <mail@michaelbarton.me.uk>,
#              Pjotr Prins <pjotr.prins@thebird.nl>
#
# License::    The Ruby License
#

require 'bio/appl/paml/codeml'

module Bio::PAML
  class Codeml

    # == Description
    #
    # Run PAML codeml and get the results from the output file. The
    # Codeml::Report object is returned by Bio::PAML::Codeml.query. For
    # example
    #
    #   codeml = Bio::PAML::Codeml.new('codeml', :runmode => 0, 
    #       :RateAncestor => 1, :alpha => 0.5, :fix_alpha => 0)
    #   result = codeml.query(alignment, tree)
    #
    # where alignment and tree are Bioruby objects. This class assumes we have a
    # buffer containing the output of codeml. 
    #
    # == References
    #
    # Phylogenetic Analysis by Maximum Likelihood (PAML) is a package of
    # programs for phylogenetic analyses of DNA or protein sequences using
    # maximum likelihood. It is maintained and distributed for academic use
    # free of charge by Ziheng Yang. Suggestion citation 
    #
    #   Yang, Z. 1997
    #   PAML: a program package for phylogenetic analysis by maximum likelihood 
    #   CABIOS 13:555-556 
    #
    # http://abacus.gene.ucl.ac.uk/software/paml.html
    #
    # == Examples
    #
    # Read the data file into a buffer
    #
    #   >> require 'bio/test/biotestfile'
    #   >> buf = BioTestFile.read('paml/codeml/models/results0-3.txt')
    #
    # Invoke Bioruby's PAML parser
    #
    #   >> require 'bio'
    #   >> c = Bio::PAML::Codeml::Report.new(buf)
    #
    #   >> c.model.size
    #   => 2
    #   >> c.model[0].name
    #   => "M0"
    # 
    # Now fetch the results of the first model M0, and check its values
    # 
    #   >> m0 = c.model['M0']
    #   >> m0.tree_length
    #   => 9.00878
    #   >> m0.lnL
    #   => -28155.576740
    #   >> m0.kappa
    #   => 2.17796
    # 
    # Check the M3 and its specific values
    #    
    #   >> m3 = c.model['M3']
    #   >> m3.lnL
    #   => -30768.946749
    #   >> m3.classes.size
    #   => 3
    #   >> m3.classes[0]
    #   => ['p' => 0.69751, 'w' => 0.35313 ]
    # 
    # Next take the overall posterior analysis
    # 
    #   >> c.nb_sites.size
    #   => 63
    #   >> c.nb_sites[0].to_a
    #   => [31,'L',1.0,2.895]
    # 
    # or by field
    #
    #   >> codon = c.nb_sites[0]
    #   >> codon.position
    #   => 31
    #   >> codon.probability
    #   => 1.0
    #   >> codon.dN_dS
    #   => 2.895
    #
    # with aliases
    #
    #   >> codon.p
    #   => 1.0
    #   >> codon.w
    #   => 2.895
    #
    # The results of a single model (old style report parser)
    #
    #   >> buf = File.read(File.join(TEST_DATA, 'output.txt'))
    #   >> c = Bio::PAML::Codeml::Report.new(buf)
    #
    #   >> c.tree_log_likelihood
    #   => -1817.465211
    #
    #   >> c.tree_length
    #   => 0.77902
    #
    #   >> c.alpha
    #   => 0.58871
    #
    #   >> c.tree)
    #   => "(((rabbit: 0.082889, rat: 0.187866): 0.038008, human: 0.055050): 0.033639, goat-cow: 0.096992, marsupial: 0.284574);"
    #

    class Report < Bio::PAML::Common::Report

      # Parse codeml output file passed with +buf+
      def initialize buf
      end

    end  # Report
   
    #   ReportSingle is a simpler parser for a codeml report
    #   containing a single run. This is retained for 
    #   backward compatibility.
    #
    class ReportSingle < Bio::PAML::Common::Report

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

    end # ReportSingle
  end # Codeml
end # Bio::PAML
