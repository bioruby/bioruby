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
    # Check the general information
    #
    #   >> c.num_sequences
    #   => 6
    #   >> c.num_codons
    #   => 134
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
    #   >> m0.alpha
    #   => nil
    #
    # We also have a tree (as a string)
    #
    #   >> m0.tree
    #   => "((((PITG_23265T0: 0.000004, PITG_23253T0: 0.400074): 0.000004, PITG_23257T0: 0.952614): 0.000004, PITG_23264T0: 0.445507): 0.000004, PITG_23267T0: 0.011814, PITG_23293T0: 0.092242);"
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
    # And the tree
    #
    #   >> m3.tree
    #   => "((((PITG_23265T0: 0.000004, PITG_23253T0: 0.762597): 0.000004, PITG_23257T0: 2.721710): 0.000004, PITG_23264T0: 0.924326): 0.014562, PITG_23267T0: 0.000004, PITG_23293T0: 0.237433);"
    # 
    # Next take the overall posterior analysis
    # 
    #   >> c.nb_sites.size
    #   => 51
    #   >> c.nb_sites[0].to_a
    #   => [17, "I", 0.988, 3.293]
    # 
    # or by field
    #
    #   >> codon = c.nb_sites[0]
    #   >> codon.position
    #   => 17
    #   >> codon.probability
    #   => 0.988
    #   >> codon.dN_dS
    #   => 3.293
    #
    # with aliases
    #
    #   >> codon.p
    #   => 0.988
    #   >> codon.w
    #   => 3.293
    #
    # Now we generate special string 'graph' for positive selection. The 
    # following returns a string the length of the input alignment and 
    # shows the locations of positive selection:
    #
    #   >> c.nb_sites.graph[0..32]
    #   => "                **    *       * *"
    #
    # And with dN/dS (high values are still an asterisk *)
    #
    #   >> c.nb_sites.graph(:omega => true)[0..32]
    #   => "                3*    6       6 2"
    #
    # Test the raw buffers
    #
    #   >> c.header.to_s =~ /seed/
    #   => 1
    #   >> m0.to_s =~ /one-ratio/
    #   => 3
    #   >> m3.to_s =~ /discrete/
    #   => 3
    #   >> c.footer.to_s =~ /Bayes/
    #   => 16
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

      def num_codons
        @header.scan(/seed used = \d+\n\s+\d+\s+\d+/).to_s.split[5].to_i/3
      end

      def num_sequences
        @header.scan(/seed used = \d+\n\s+\d+\s+\d+/).to_s.split[4].to_i
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

      # Return a NBSites (naive empirical bayesian) object
      def nb_sites
        NBSites.new(@footer,num_codons)
      end

    end  # Report
   
    #   ReportSingle is a simpler parser for a codeml report
    #   containing a single run. This is retained for 
    #   backward compatibility.
    #
    #   The results of a single model (old style report parser)
    #
    #     >> buf = BioTestFile.read('paml/codeml/output.txt')
    #     >> c = Bio::PAML::Codeml::Report.new(buf)
    #
    #     >> c.tree_log_likelihood
    #     => -1817.465211
    #
    #     >> c.tree_length
    #     => 0.77902
    #
    #     >> c.alpha
    #     => 0.58871
    #
    #     >> c.tree
    #     => "(((rabbit: 0.082889, rat: 0.187866): 0.038008, human: 0.055050): 0.033639, goat-cow: 0.096992, marsupial: 0.284574);"
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
        return nil if @buf !~ /kappa/
        @buf[/kappa \(ts\/tv\)\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      def alpha
        return nil if @buf !~ /alpha/
        @buf[/alpha .+ =\s+(-?\d+(\.\d+)?)/,1].to_f
      end

      def tree_length
        @buf[/tree length\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      def tree
        @buf[/([^\n]+)\n\nDetailed/m,1]
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
        return nil if @buf !~ /classes/
        # probs = @buf.scan(/\np:\s+(\w+)\s+(\S+)\s+(\S+)/)
        probs = @buf.scan(/\np:.*?\n/).to_s.split[1..3].map { |f| f.to_f }
        ws = @buf.scan(/\nw:.*?\n/).to_s.split[1..3].map { |f| f.to_f }
        ret = []
        probs.each_with_index do | prob, i |
          ret.push  :p => prob, :w => ws[i] 
        end
        ret
      end

      def to_s
        @buf
      end
    end

    # A record of codon sites showing evidence of positive selection
    class PositiveSite
      attr_reader :position, :probability, :omega
      def initialize fields
        @position    = fields[0].to_i
        @aaref       = fields[1]
        @probability = fields[2].to_f
        @omega       = fields[3].to_f
      end
     
      def dN_dS
        omega
      end

      alias w dN_dS

      alias p probability

      def to_a
        [ @position, @aaref, @probability, @omega ]
      end
    end

    # Return the positive selection sites. PAML returns:
    #
    # Naive Empirical Bayes (NEB) analysis
    # Positively selected sites (*: P>95%; **: P>99%)
    # (amino acids refer to 1st sequence: PITG_23265T0)
    # 
    #             Pr(w>1)     post mean +- SE for w
    # 
    #     17 I      0.988*        3.293
    #     18 H      1.000**       17.975
    #     23 F      0.991**       6.283
    # (...)
    #    131 V      1.000**       22.797
    #    132 R      1.000**       10.800
    # (newline)
    #

    class NBSites < Array

      def initialize buf, num_codons
        @num_codons = num_codons
        raise ReportError,"No NB sites found" if buf !~ /Naive Empirical Bayes/
        lines = buf.split("\n")
        start = lines.index("Naive Empirical Bayes (NEB) analysis") + 6
        lines[start..-1].each do | line |
          last if line == ""
          fields = line.split
          push PositiveSite.new fields
        end
      end

      def graph options={}
        ret = ""
        pos = 0
        each do | site |
          symbol = "*"
          if options[:omega]
            symbol = site.omega.to_i.to_s if site.omega.abs <= 10.0
          end
          ret += symbol.rjust(site.position-pos)
          pos = site.position
        end
        ret += ' '.rjust(@num_codons - pos - 1)
      end

    end

    # Supporting error class
    class ReportError < RuntimeError
    end


  end # Codeml
end # Bio::PAML
