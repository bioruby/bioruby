#
# test/unit/bio/appl/paml/test_codeml.rb - Unit test for Bio::PAML::Codeml
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/paml/codeml'

module Bio
  module TestCodemlData

    bioruby_root  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
    TEST_DATA = Pathname.new(File.join(bioruby_root, 'test', 'data', 'paml', 'codeml')).cleanpath.to_s

    def self.dummy_binary
      File.join TEST_DATA, 'dummy_binary'
    end

    def self.example_config
      File.join TEST_DATA, 'config.txt'
    end

    def self.config_missing_tree
      File.join TEST_DATA, 'config.missing_tree.txt'
    end

    def self.config_missing_align
      File.join TEST_DATA, 'config.missing_align.txt'
    end
  end

  class TestCodemlConfigGeneration < Test::Unit::TestCase

    TEST_DATA = TestCodemlData::TEST_DATA

    def generate_config_file
      @tempfile_config = Tempfile.new('codeml_config')
      @tempfile_config.close(false)
      @tempfile_outfile = Tempfile.new('codeml_test')
      @tempfile_outfile.close(false)

      test_config = @tempfile_config.path
      Bio::PAML::Codeml.create_config_file({
        :model       => 1,
        :fix_kappa   => 1,
        :aaRatefile  => File.join(TEST_DATA, 'wag.dat'),
        :seqfile     => File.join(TEST_DATA, 'abglobin.aa'),
        :treefile    => File.join(TEST_DATA, 'abglobin.trees'),
        :outfile     => @tempfile_outfile.path,
      },test_config)
      test_config
    end
    private :generate_config_file

    def setup
      @example_config = generate_config_file
    end

    def teardown
      @tempfile_config.close(true)
      @tempfile_outfile.close(true)
    end

    def test_config_file_generated
      assert_not_nil(File.size?(@example_config))
    end

    def test_expected_options_set_in_config_file
      produced_config = File.open(@example_config).inject(Hash.new) do |hash,line|
        hash.store(*line.strip.split(' = '))
        hash
      end
      assert_equal(File.join(TEST_DATA, 'abglobin.aa'),
                   produced_config['seqfile'])
      assert_equal('1', produced_config['fix_kappa'])
      assert_equal('1', produced_config['model'])
    end
  end

  class TestConfigFileUsage < Test::Unit::TestCase
    
    def loaded
      codeml = Bio::PAML::Codeml.new(TestCodemlData.dummy_binary)
      codeml.instance_eval {
        load_options_from_file(TestCodemlData.example_config)
      }
      codeml
    end

    def test_options_should_be_loaded_from_config
      assert_not_nil(loaded.options)
    end

    def test_correct_options_should_be_loaded
      assert_equal('abglobin.aa', loaded.options[:seqfile])
      assert_equal('1', loaded.options[:fix_kappa])
      assert_equal('1', loaded.options[:model])
    end

  end

  class TestExpectedErrorsThrown < Test::Unit::TestCase

    def test_error_thrown_if_binary_does_not_exist
      assert_raises ArgumentError do
        Bio::PAML::Codeml.new('non_existent_file')
      end
    end

    def test_error_thrown_if_treefile_does_not_exist
      codeml = Bio::PAML::Codeml.new(TestCodemlData.dummy_binary)
      assert_raises ArgumentError do
        codeml.run(TestCodemlData.config_missing_tree)
      end
    end

    def test_error_thrown_if_alignment_file_does_not_exist
      codeml = Bio::PAML::Codeml.new(TestCodemlData.dummy_binary)
      assert_raises ArgumentError do
        codeml.run(TestCodemlData.config_missing_align)
      end
    end

  end
end
