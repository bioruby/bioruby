#
# = test/unit/bio/appl/paml/codeml/test_report.rb - Unit tests for Codeml report parser
#
# Copyright::  Copyright (C) 2008-2010
#              Michael D. Barton <mail@michaelbarton.me.uk>,
#              Pjotr Prins <pjotr.prins@thebird.nl>
#
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/paml/codeml/report'

module Bio

  # The test code is copied from the examples of Bio::PAML::Codeml::Report
  # described in lib/bio/appl/paml/codeml/report.rb.
  module TestPAMLCodemlReportWithModels

    FILENAME_M0M3 = File.join(BioRubyTestDataPath,
                             'paml/codeml/models/results0-3.txt')

    class TestCodemlReportM0M3 < Test::Unit::TestCase

      def setup
        buf = File.read(FILENAME_M0M3)
        @c = Bio::PAML::Codeml::Report.new(buf)
      end

      # Invoke Bioruby's PAML codeml parser, after having read the contents
      # of the codeml result file into _buf_ (for example using File.read)
      def test_initialize
        assert_instance_of(Bio::PAML::Codeml::Report, @c)
      end

      # Do we have two models?
      def test_models
        assert_equal(2, @c.models.size)
        assert_equal("M0", @c.models[0].name)
        assert_equal("M3", @c.models[1].name)
      end

      # Check the general information
      def test_num_sequences
        assert_equal(6, @c.num_sequences)
      end

      def test_num_codons
        assert_equal(134, @c.num_codons)
      end

      def test_descr
        assert_equal("M0-3", @c.descr)
      end

      # Test whether the second model M3 is significant over M0
      def test_significant
        assert_equal(true, @c.significant)
      end

      # Next take the overall posterior analysis
      def test_nb_sites
        assert_equal(44, @c.nb_sites.size)
        assert_equal([17, "I", 0.988, 3.293], @c.nb_sites[0].to_a)
      end

      # We also provide the raw buffers to adhere to the principle of 
      # unexpected use. Test the raw buffers for content:
      def test_header
        assert_equal(1, @c.header.to_s =~ /seed/)
      end

      def test_footer
        assert_equal(16, @c.footer.to_s =~ /Bayes/)
      end

    end #class TestCodemlReportM0M3

    class TestCodemlModelM0M3 < Test::Unit::TestCase

      # Now fetch the results of the first model M0, and check its values
      def setup
        buf = File.read(FILENAME_M0M3)
        c = Bio::PAML::Codeml::Report.new(buf)
        @m0 = c.models[0]
        @m3 = c.models[1]
      end

      def test_tree_length
        assert_equal(1.90227, @m0.tree_length)
      end

      def test_lnL
        assert_equal(-1125.800375, @m0.lnL)
      end

      def test_omega
        assert_equal(0.58589, @m0.omega)
      end

      def test_dN_dS
        assert_equal(0.58589, @m0.dN_dS)
      end

      def test_kappa
        assert_equal(2.14311, @m0.kappa)
      end

      def test_alpha
        assert_equal(nil, @m0.alpha)
      end
    
      # We also have a tree (as a string)
      def test_tree
        str = "((((PITG_23265T0: 0.000004, PITG_23253T0: 0.400074): 0.000004, PITG_23257T0: 0.952614): 0.000004, PITG_23264T0: 0.445507): 0.000004, PITG_23267T0: 0.011814, PITG_23293T0: 0.092242);"
        assert_equal(str, @m0.tree)
      end

      # Check the M3 and its specific values
      def test_m3_lnL
        assert_equal(-1070.964046, @m3.lnL)
      end

      def test_m3_classes
        assert_equal(3, @m3.classes.size)
        assert_equal({:w=>0.00928, :p=>0.56413}, @m3.classes[0])
      end

      def test_m3_tree
        str = "((((PITG_23265T0: 0.000004, PITG_23253T0: 0.762597): 0.000004, PITG_23257T0: 2.721710): 0.000004, PITG_23264T0: 0.924326): 0.014562, PITG_23267T0: 0.000004, PITG_23293T0: 0.237433);"
        assert_equal(str, @m3.tree)
      end

      def test_to_s
        assert_equal(3, @m0.to_s =~ /one-ratio/)
      end

      def test_m3_to_s
        assert_equal(3, @m3.to_s =~ /discrete/)
      end

    end #class TestCodemlModelM0M3

    class TestCodemlPositiveSiteM0M3 < Test::Unit::TestCase

      def setup
        buf = File.read(FILENAME_M0M3)
        c = Bio::PAML::Codeml::Report.new(buf)
        @codon = c.nb_sites[0]
      end

      def test_position
        assert_equal(17, @codon.position)
      end

      def test_probability
        assert_equal(0.988, @codon.probability)
      end

      def test_dN_dS
        assert_equal(3.293, @codon.dN_dS)
      end

      # with aliases
      def test_p
        assert_equal(0.988, @codon.p)
      end

      def test_w
        assert_equal(3.293, @codon.w)
      end

    end #class TestCodemlPositiveSiteM0M3

    class TestCodemlPositiveSitesM0M3 < Test::Unit::TestCase

      def setup
        buf = File.read(FILENAME_M0M3)
        c = Bio::PAML::Codeml::Report.new(buf)
        @nb_sites = c.nb_sites
      end
  
      # Now we generate special string 'graph' for positive selection. The 
      # following returns a string the length of the input alignment and 
      # shows the locations of positive selection:
      def test_graph
        str = "                **    *       * *"
        assert_equal(str, @nb_sites.graph[0..32])
      end

      # And with dN/dS (high values are still an asterisk *)
      def test_graph_omega
        str = "                3*    6       6 2"
        assert_equal(str, @nb_sites.graph_omega[0..32])
      end
    end #class TestCodemlPositiveSitesM0M3

    # Finally we do a test on an M7+M8 run.
    FILENAME_M7M8 = File.join(BioRubyTestDataPath,
                              'paml/codeml/models/results7-8.txt')


    class TestCodemlReportM7M8 < Test::Unit::TestCase

      def setup
        buf = File.read(FILENAME_M7M8)
        @c = Bio::PAML::Codeml::Report.new(buf)
      end

      # Do we have two models?
      def test_models
        assert_equal(2, @c.models.size)
        assert_equal("M7", @c.models[0].name)
        assert_equal("M8", @c.models[1].name)
      end

      # Assert the results are significant
      def test_significant
        assert_equal(true, @c.significant)
      end

      # Compared to M0/M3 there are some differences. The important ones
      # are the parameters and the full Bayesian result available for M7/M8.
      # This is the naive Bayesian result:
      def test_nb_sites
        assert_equal(10, @c.nb_sites.size)
      end

      # And this is the full Bayesian result:
      def test_sites
        assert_equal(30, @c.sites.size)
        array = [17, "I", 0.672, 2.847]
        assert_equal(array, @c.sites[0].to_a)
        str = "                **    *       * *"
        assert_equal(str, @c.sites.graph[0..32])
        
        # Note the differences of omega with earlier M0-M3 naive Bayesian 
        # analysis:
        str2 = "                24    3       3 2"
        assert_equal(str2, @c.sites.graph_omega[0..32])
        # The locations are the same, but the omega differs.
      end
    end #class TestCodemlReportM7M8

  end #module TestPAMLCodemlReportWithModels
end #module Bio

