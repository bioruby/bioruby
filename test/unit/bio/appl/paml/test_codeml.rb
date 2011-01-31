#
# test/unit/bio/appl/paml/test_codeml.rb - Unit test for Bio::PAML::Codeml
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/paml/codeml'

module Bio; module TestPAMLCodeml
  module TestCodemlData

    TEST_DATA = Pathname.new(File.join(BioRubyTestDataPath, 'paml', 'codeml')).cleanpath.to_s

    def self.example_control
      File.join TEST_DATA, 'control_file.txt'
    end

  end #module TestCodemlData

  class TestCodemlInitialize < Test::Unit::TestCase

    def test_new_with_one_argument
      factory = Bio::PAML::Codeml.new('echo')
      assert_instance_of(Bio::PAML::Codeml, factory)
      assert_equal('echo', factory.instance_eval { @program })
    end

    def test_new_with_two_argument
      factory = Bio::PAML::Codeml.new('echo', { :test => 'value' })
      assert_instance_of(Bio::PAML::Codeml, factory)
      assert_equal('echo', factory.instance_eval { @program })
      assert_equal('value', factory.parameters[:test])
    end

    def test_new_with_parameters
      factory = Bio::PAML::Codeml.new(nil, { :test => 'value' })
      assert_instance_of(Bio::PAML::Codeml, factory)
      assert_equal('codeml', factory.instance_eval { @program })
      assert_equal('value', factory.parameters[:test])
    end

    def test_new_without_argument
      factory = Bio::PAML::Codeml.new
      assert_instance_of(Bio::PAML::Codeml, factory)
      assert_equal('codeml', factory.instance_eval { @program })
    end

  end #class TestCodemlInitialize

  class TestCodeml < Test::Unit::TestCase
    def setup
      @codeml = Bio::PAML::Codeml.new
    end

    def test_parameters
      params = { :verbose => 1 }
      @codeml.parameters = params
      assert_equal(params, @codeml.parameters)
    end

    def test_load_parameters
      str = " seqfile = test.aa \n verbose = 1 \n"
      params = { :seqfile => 'test.aa', :verbose => '1' }
      assert_equal(params, @codeml.load_parameters(str))
    end

    def test_set_default_parameters
      assert_equal(Bio::PAML::Codeml::DEFAULT_PARAMETERS,
                   @codeml.set_default_parameters)
      # modifying parameters should not affect DEFAULT_PARAMETERS
      @codeml.parameters[:only_for_test] = 'this is test'
      assert_not_equal(Bio::PAML::Codeml::DEFAULT_PARAMETERS,
                       @codeml.parameters)
    end

    def test_dump_parameters
      params = { :seqfile => 'test.aa', :verbose => '1' }
      @codeml.parameters = params
      assert_equal("seqfile = test.aa\nverbose = 1\n",
                   @codeml.dump_parameters)
    end

  end #class TestCodeml

  class TestCodemlControlGeneration < Test::Unit::TestCase

    TEST_DATA = TestCodemlData::TEST_DATA

    def generate_control_file
      @tempfile_control = Tempfile.new('codeml_control')
      @tempfile_control.close(false)
      @tempfile_outfile = Tempfile.new('codeml_test')
      @tempfile_outfile.close(false)

      test_control = @tempfile_control.path
      Bio::PAML::Codeml.create_control_file({
        :model       => 1,
        :fix_kappa   => 1,
        :aaRatefile  => File.join(TEST_DATA, 'wag.dat'),
        :seqfile     => File.join(TEST_DATA, 'abglobin.aa'),
        :treefile    => File.join(TEST_DATA, 'abglobin.trees'),
        :outfile     => @tempfile_outfile.path,
      }, test_control)
      test_control
    end
    private :generate_control_file

    def setup
      @example_control = generate_control_file
    end

    def teardown
      @tempfile_control.close(true)
      @tempfile_outfile.close(true)
    end

    def test_control_file_generated
      assert_not_nil(File.size?(@example_control))
    end

    def test_expected_parameters_set_in_control_file
      produced_control = File.open(@example_control) do |f|
        f.inject(Hash.new) do |hash,line|
          hash.store(*line.strip.split(' = '))
          hash
        end
      end
      assert_equal(File.join(TEST_DATA, 'abglobin.aa'),
                   produced_control['seqfile'])
      assert_equal('1', produced_control['fix_kappa'])
      assert_equal('1', produced_control['model'])
    end
  end #class TestCodemlControlGeneration

  class TestControlFileUsage < Test::Unit::TestCase
    
    def setup
      @codeml = Bio::PAML::Codeml.new
      @codeml.load_parameters(File.read(TestCodemlData.example_control))
    end

    def test_parameters_should_be_loaded_from_control
      assert_not_nil(@codeml.parameters)
    end

    def test_correct_parameters_should_be_loaded
      assert_equal('abglobin.aa', @codeml.parameters[:seqfile])
      assert_equal('1', @codeml.parameters[:fix_kappa])
      assert_equal('1', @codeml.parameters[:model])
    end

  end #class TestControlFileUsage

  class TestExpectedErrorsThrown < Test::Unit::TestCase
  
    def test_error_thrown_if_seqfile_does_not_specified
      codeml = Bio::PAML::Codeml.new('echo')
      codeml.load_parameters(File.read(TestCodemlData.example_control))
      codeml.parameters[:seqfile] = nil
      assert_raises RuntimeError do
        codeml.query_by_string()
      end
    end
  
  end #class TestExpectedErrorsThrown

end; end #module TestPAMLCodeml; module Bio
