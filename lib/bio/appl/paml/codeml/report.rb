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
    #--
    # The following is not shown in the documentation
    #
    #   >> require 'bio'
    #   >> require 'bio/test/biotestfile'
    #   >> buf = BioTestFile.read('paml/codeml/models/results0-3.txt')
    #++
    #
    # Invoke Bioruby's PAML codeml parser, after having read the contents
    # of the codeml result file into _buf_ (for example using File.read)
    #
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
    #   >> c.descr
    #   => "M0-3"
    #
    # Test whether the second model M3 is significant over M0
    #
    #   >> c.significant
    #   => true
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
    #   => 44
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
    #   >> c.nb_sites.graph_omega[0..32]
    #   => "                3*    6       6 2"
    #
    # We also provide the raw buffers to adhere to the principle of 
    # unexpected use. Test the raw buffers for content:
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
    # Finally we do a test on an M7+M8 run. Again, after loading the
    # results file into _buf_
    #
    #--
    #   >> buf78 = BioTestFile.read('paml/codeml/models/results7-8.txt')
    #
    #
    #++
    #
    # Invoke Bioruby's PAML codeml parser
    #
    #   >> c = Bio::PAML::Codeml::Report.new(buf78)
    #
    # Do we have two models?
    #
    #   >> c.models.size
    #   => 2
    #   >> c.models[0].name
    #   => "M7"
    #   >> c.models[1].name
    #   => "M8"
    #
    # Assert the results are significant
    #
    #   >> c.significant
    #   => true
    #
    # Compared to M0/M3 there are some differences. The important ones
    # are the parameters and the full Bayesian result available for M7/M8.
    # This is the naive Bayesian result:
    #
    #   >> c.nb_sites.size
    #   => 10
    #
    # And this is the full Bayesian result:
    #
    #   >> c.sites.size
    #   => 30
    #   >> c.sites[0].to_a
    #   => [17, "I", 0.672, 2.847]
    #   >> c.sites.graph[0..32]
    #   => "                **    *       * *"
    #
    # Note the differences of omega with earlier M0-M3 naive Bayesian 
    # analysis:
    #
    #   >> c.sites.graph_omega[0..32]
    #   => "                24    3       3 2"
    #
    # The locations are the same, but the omega differs.
    #
    class Report < Bio::PAML::Common::Report

      attr_reader :models, :header, :footer

      # Parse codeml output file passed with +buf+, where buf contains
      # the content of a codeml result file
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

      # Give a short description of the models, for example 'M0-3'
      def descr
        num = @models.size
        case num
          when 0 
            'No model'
          when 1 
            @models[0].name
          else 
            @models[0].name + '-' + @models[1].modelnum.to_s
        end
      end

      # Return the number of condons in the codeml alignment
      def num_codons
        @header.scan(/seed used = \d+\n\s+\d+\s+\d+/).to_s.split[5].to_i/3
      end

      # Return the number of sequences in the codeml alignment
      def num_sequences
        @header.scan(/seed used = \d+\n\s+\d+\s+\d+/).to_s.split[4].to_i
      end

      # Return a PositiveSites (naive empirical bayesian) object
      def nb_sites
        PositiveSites.new("Naive Empirical Bayes (NEB)",@footer,num_codons)
      end

      # Return a PositiveSites Bayes Empirical Bayes (BEB) analysis
      def sites
        PositiveSites.new("Bayes Empirical Bayes (BEB)",@footer,num_codons)
      end

      # If the number of models is two we can calculate whether the result is
      # statistically significant, or not, at the 1% significance level. For
      # example, for M7-8 the LRT statistic, or twice the log likelihood
      # difference between the two compared models, may be compared against
      # chi-square, with critical value 9.21 at the 1% significance level.
      #
      # Here we support a few likely combinations, M0-3, M1-2 and M7-8, used
      # most often in literature. For other combinations, or a different 
      # significance level, you'll have to calculate chi-square yourself.
      #
      # Returns true or false. If no result is calculated this method
      # raises an error
      def significant
        raise ReportError,"Wrong number of models #{@models.size}" if @models.size != 2
        lnL1 = @models[0].lnL
        model1 = @models[0].modelnum
        lnL2 = @models[1].lnL
        model2 = @models[1].modelnum
        case [model1, model2]
          when [0,3]
            2*(lnL2-lnL1) > 13.2767   # chi2: p=0.01, df=4
          when [1,2]
            2*(lnL2-lnL1) >  9.2103   # chi2: p=0.01, df=2
          when [7,8]
            2*(lnL2-lnL1) >  9.2103   # chi2: p=0.01, df=2
          else
            raise ReportError,"Significance calculation for #{descr} not supported"
        end
      end

      #:stopdoc:

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

      #:startdoc:

    end  # Report
   
    #   ReportSingle is a simpler parser for a codeml report
    #   containing a single run. This is retained for 
    #   backward compatibility mostly.
    #
    #   The results of a single model (old style report parser)
    #
    #--
    #     >> buf = BioTestFile.read('paml/codeml/output.txt')
    #++
    #
    #     >> single = Bio::PAML::Codeml::Report.new(buf)
    #
    #     >> single.tree_log_likelihood
    #     => -1817.465211
    #
    #     >> single.tree_length
    #     => 0.77902
    #
    #     >> single.alpha
    #     => 0.58871
    #
    #     >> single.tree
    #     => "(((rabbit: 0.082889, rat: 0.187866): 0.038008, human: 0.055050): 0.033639, goat-cow: 0.096992, marsupial: 0.284574);"
    #
    class ReportSingle < Bio::PAML::Common::Report

      attr_reader :tree_log_likelihood, :tree_length, :alpha, :tree

      # Do not use
      def initialize(codeml_report)
        @tree_log_likelihood = pull_tree_log_likelihood(codeml_report)
        @tree_length = pull_tree_length(codeml_report)
        @alpha = pull_alpha(codeml_report)
        @tree = pull_tree(codeml_report)
      end

      private

      # Do not use
      def pull_tree_log_likelihood(text)
        text[/lnL\(.+\):\s+(-?\d+(\.\d+)?)/,1].to_f
      end

      # Do not use
      def pull_tree_length(text)
        text[/tree length\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      # Do not use
      def pull_alpha(text)
        text[/alpha .+ =\s+(-?\d+(\.\d+)?)/,1].to_f
      end

      # Do not use
      def pull_tree(text)
        text[/([^\n]+)\n\nDetailed/m,1]
      end

    end # ReportSingle

    # Model class contains one of the models of a codeml run (e.g. M0)
    # which is used as a test hypothesis for positive selection. This
    # class is used by Codeml::Report.
    class Model 

      # Create a model using the relevant information from the codeml
      # result data (text buffer)
      def initialize buf
        @buf = buf
      end

      # Return the model number
      def modelnum
        @buf[0..0].to_i
      end

      # Return the model name, e.g. 'M0' or 'M7'
      def name
        'M'.to_s+modelnum.to_s
      end

      # Return codeml log likelihood of model
      def lnL
        @buf[/lnL\(.+\):\s+(-?\d+(\.\d+)?)/,1].to_f
      end

      # Return codeml omega of model
      def omega
        @buf[/omega \(dN\/dS\)\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      alias dN_dS omega

      # Return codeml kappa of model, when available
      def kappa
        return nil if @buf !~ /kappa/
        @buf[/kappa \(ts\/tv\)\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      # Return codeml alpha of model, when available
      def alpha
        return nil if @buf !~ /alpha/
        @buf[/alpha .+ =\s+(-?\d+(\.\d+)?)/,1].to_f
      end

      # Return codeml treee length
      def tree_length
        @buf[/tree length\s+=\s+ (-?\d+(\.\d+)?)/,1].to_f
      end

      # Return codeml tree
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

      # Return the model information as a String
      def to_s
        @buf
      end
    end

    # A record of codon sites, across the sequences in the alignment,
    # showing evidence of positive selection.
    #
    # This class is used for storing both codeml's full Bayesian and naive
    # Bayesian analysis
    class PositiveSite
      attr_reader :position
      attr_reader :aaref
      attr_reader :probability
      attr_reader :omega

      def initialize fields
        @position    = fields[0].to_i
        @aaref       = fields[1].to_s
        @probability = fields[2].to_f
        @omega       = fields[3].to_f
      end
     
      # Return dN/dS (or omega) for this codon
      def dN_dS
        omega
      end

      alias w dN_dS

      alias p probability

      # Return contents as Array - useful for printing
      def to_a
        [ @position, @aaref, @probability, @omega ]
      end
    end

    # List for the positive selection sites. PAML returns:
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
    # these can be accessed using normal iterators. Also special
    # methods are available for presenting this data
    #
    class PositiveSites < Array

      attr_reader :descr

      def initialize search, buf, num_codons
        @num_codons = num_codons
        if buf.index(search)==nil
          raise ReportError,"No NB sites found for #{search}" 
        end
        # Set description of this class
        @descr = search
        lines = buf.split("\n")
        # find location of 'search'
        start = 0
        lines.each_with_index do | line, i |
          if line.index(search) != nil
            start = i
            break
          end
        end
        raise ReportError,"Out of bound error for <#{buf}>" if lines[start+6]==nil
        lines[start+6..-1].each do | line |
          break if line.strip == ""
          fields = line.split
          push PositiveSite.new(fields)
        end
        num = size()
        @buf = lines[start..start+num+7].join("\n")
      end

      # Generate a graph - which is a simple string pointing out the positions
      # showing evidence of positive selection pressure.
      #
      #   >> c.sites.graph[0..32]
      #   => "                **    *       * *"
      #
      def graph
        graph_to_s(lambda { |site| "*" })
      end

      # Generate a graph - which is a simple string pointing out the positions
      # showing evidence of positive selection pressure, with dN/dS values
      # (high values are an asterisk *)
      #
      #   >> c.sites.graph_omega[0..32]
      #   => "                24    3       3 2"
      #
      def graph_omega
        graph_to_s(lambda { |site| 
            symbol = "*"
            symbol = site.omega.to_i.to_s if site.omega.abs <= 10.0
            symbol
        })
      end

      # Graph of amino acids of first sequence at locations
      def graph_seq
        graph_to_s(lambda { |site |
          symbol = site.aaref
          symbol
        })
      end
      
      # Return the positive selection information as a String
      def to_s
        @buf
      end

      # :nodoc:
      # Creates a graph of sites, adjusting for gaps. This generator
      # is also called from HtmlPositiveSites. The _fill_ is used
      # to fill out the gaps
      def graph_to_s func, fill=' '
        ret = ""
        pos = 0
        each do | site |
          symbol = func.call(site)
          gapsize = site.position-pos-1
          ret += fill*gapsize + symbol
          pos = site.position
        end
        gapsize = @num_codons - pos - 1
        ret += fill*gapsize if gapsize > 0
        ret
      end
    end

    # Supporting error class
    class ReportError < RuntimeError
    end


  end # Codeml
end # Bio::PAML
