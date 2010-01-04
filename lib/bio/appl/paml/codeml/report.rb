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
    # Read the codeml M0-M3 data file into a buffer
    #
    #   >> require 'bio/test/biotestfile'
    #   >> buf = BioTestFile.read('paml/codeml/models/results0-3.txt')
    #
    # Invoke Bioruby's PAML codeml parser
    #
    #   >> require 'bio'
    #   >> c = Bio::PAML::Codeml::Report.new(buf)
    #
    # Do we have two models?
    #
    #   >> c.models.size
    #   => 2
    #   >> c.models[0].name
    #   => "M0"
    #   >> c.models[1].name
    #   => "M3"
    # 
    # Now fetch the results of the first model M0, and check its values
    # 
    #   >> m0 = c.models[0]
    #   >> m0.tree_length
    #   => 1.90227
    #   >> m0.lnL
    #   => -1125.800375
    #   >> m0.omega
    #   => 0.58589
    #   >> m0.dN_dS
    #   => 0.58589
    #   >> m0.kappa
    #   => 2.14311
    # 
    # Check the M3 and its specific values
    #    
    #   >> m3 = c.models[1]
    #   >> m3.lnL
    #   => -1070.964046
    #   >> m3.classes.size
    #   => 3
    #   >> m3.classes[0]
    #   => {:w=>0.00928, :p=>0.56413}
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
    # Test the raw buffers
    #
    #   >> report.footer.text =~ /seed/
    #   => true
    #   >> m0.text =~ /Model 0: one-ratio/
    #   => true
    #   >> m3.text =~ /Model 3: discrete/
    #   => true
    #   >> report.footer.text =~ /Bayes/
    #   => true
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

      attr_reader :models, :header, :footer

      # Parse codeml output file passed with +buf+
      def initialize buf
        # split the main buffer into sections for each model, header and footer.
        sections = buf.split("\nModel ")
        model_num = sections.size-1
        raise ReportError,"Incorrect codeml data models=#{model_num}" if model_num > 2
        foot2 = sections[model_num].split("\nNaive ")
        if foot2.size == 2
          # We have a dual model
          sections[model_num] = foot2[0]
          @footer = 'Naive '+foot2[1]
          @models = []
          sections[1..-1].each do | model_buf |
            @models.push Model.new(model_buf)
          end
        else
          # A single model is run
          sections = buf.split("\nTREE #")
          model_num = sections.size-1
          raise ReportError,"Can not parse single model file" if model_num != 1
          @models = []
          @models.push sections[1]
          @footer = sections[1][/Time used/,1]
          @single = ReportSingle.new(buf)
        end
        @header = sections[0]
      end

      # compatibility call for older interface (single models only)
      def tree_log_likelihood
        @single.tree_log_likelihood
      end

      # compatibility call for older interface (single models only)
      def tree_length
        @single.tree_length
      end

      # compatibility call for older interface (single models only)
      def alpha
        @single.alpha
      end

      # compatibility call for older interface (single models only)
      def tree
        @single.tree
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

    # Model class
    class Model 

      def initialize buf
        @buf = buf
      end

      # Return the model name, e.g. 'M0' or 'M7'
      def name
        'M'.to_s+@buf[0..0]
      end

      def lnL
        @buf[/lnL\(.+\):\s+(-?\d+(\.\d+)?)/,1].to_f
      end

      def omega
        @buf[/omega \(dN\/dS\)\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      alias dN_dS omega

      def kappa
        @buf[/kappa \(ts\/tv\)\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      def tree_length
        @buf[/tree length\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      # Return classes when available. For M3 it parses
      #
      # dN/dS (w) for site classes (K=3)
      # p:   0.56413  0.35613  0.07974
      # w:   0.00928  1.98252 23.44160
      #
      # and turns it into an array of Hash
      #
      #   >> m3.classes[0]
      #   => {:w=>0.00928, :p=>0.56413}

      def classes
        # probs = @buf.scan(/\np:\s+(\w+)\s+(\S+)\s+(\S+)/)
        probs = @buf.scan(/\np:.*?\n/).to_s.split[1..3].map { |f| f.to_f }
        ws = @buf.scan(/\nw:.*?\n/).to_s.split[1..3].map { |f| f.to_f }
        ret = []
        probs.each_with_index do | prob, i |
          ret.push  :p => prob, :w => ws[i] 
        end
        ret
      end

    end

    # Supporting error class
    class ReportError < RuntimeError
    end


  end # Codeml
end # Bio::PAML
