#
# test/unit/bio/appl/test_codeml.rb - Unit test for Bio::CodeML
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/codeml'

BIORUBY_ROOT  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
TEST_DATA = Pathname.new(File.join(BIORUBY_ROOT, 'test', 'data', 'codeml')).cleanpath.to_s

module Bio
  class TestCodemlData

    def self.generate_config_file
      test_config = Tempfile.new('codeml_config').path
      Bio::CodeML.create_config_file({
        :model       => 1,
        :fix_kappa   => 1,
        :aaRatefile  => TEST_DATA + '/wag.dat',
        :seqfile     => TEST_DATA + '/abglobin.aa',
        :treefile    => TEST_DATA + '/abglobin.trees',
        :outfile     => Tempfile.new('codeml_test').path,
      },test_config)
      test_config
    end
  end

  class TestCodemlConfigGeneration < Test::Unit::TestCase

    EXAMPLE_CONFIG = TestCodemlData.generate_config_file

    def test_config_file_generated
      assert_not_nil(File.size?(EXAMPLE_CONFIG))
    end

    def test_expected_options_set_in_config_file
      produced_config = File.open(EXAMPLE_CONFIG).inject(Hash.new) do |hash,line|
        hash.store(*line.strip.split(' = '))
        hash
      end
      assert_equal(produced_config['seqfile'], TEST_DATA + '/abglobin.aa')
      assert_equal(produced_config['fix_kappa'], '1')
      assert_equal(produced_config['model'], '1')
    end

  end
end
