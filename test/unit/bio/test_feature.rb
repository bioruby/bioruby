#
# test/unit/bio/test_feature.rb - Unit test for Features/Feature classes
#
# Copyright::  Copyright (C) 2005
#              Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 2,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/feature'
require 'bio/compat/features'

module Bio
  class TestQualifier < Test::Unit::TestCase
    def setup
      qualifier = 'gene'
      value = 'CDS'
      @obj = Bio::Feature::Qualifier.new(qualifier, value)
    end

    def test_qualifier
      assert_equal('gene', @obj.qualifier)
    end

    def test_value
      assert_equal('CDS', @obj.value)
    end
  end

  class TestFeature < Test::Unit::TestCase
    def setup
      @qualifier = Bio::Feature::Qualifier.new('organism', 'Arabidopsis thaliana')
      feature = 'source'
      position = '1..615'
      qualifiers = [@qualifier]
      @obj = Bio::Feature.new(feature, position, qualifiers)
    end

    def test_new
      assert(Bio::Feature.new)
    end

    def test_feature
      assert_equal('source', @obj.feature)
    end

    def test_position
      assert_equal('1..615', @obj.position)
    end

    def test_qualifiers
      assert_equal([@qualifier], @obj.qualifiers)
    end

    def test_locations
      assert_equal(1, @obj.locations.first.from)
      assert_equal(615, @obj.locations.first.to)
    end

    def test_append_nil
      assert(@obj.append(nil))
      assert_equal(1, @obj.qualifiers.size)
    end

    def test_append
      qualifier = Bio::Feature::Qualifier.new('db_xref', 'taxon:3702')
      assert(@obj.append(qualifier))
      assert_equal('db_xref', @obj.qualifiers.last.qualifier)
    end

    def test_each
      @obj.each do |qua|
        assert_equal('Arabidopsis thaliana', qua.value)
      end
    end

    def test_assoc
      @obj.append(Bio::Feature::Qualifier.new('organism', 'Arabidopsis thaliana'))
      assert_equal({ 'organism' => 'Arabidopsis thaliana' }, @obj.assoc)
    end
  end

  class TestFeatures < Test::Unit::TestCase
    class NullStderr
      def initialize
        @log = []
      end

      def write(*arg)
        # p arg
        @log.push([:write, *arg])
        nil
      end

      def method_missing(*arg)
        # p arg
        @log.push arg
        nil
      end
    end # class NullStderr

    def setup
      # To suppress warning messages, $stderr is replaced by dummy object.
      @stderr_orig = $stderr
      $stderr = NullStderr.new

      @obj = Bio::Features.new([Bio::Feature.new('gene', '1..615', [])])
    end

    def teardown
      # bring back $stderr
      $stderr = @stderr_orig
    end

    def test_features
      assert_equal(1, @obj.features.size)
    end

    def test_append
      assert(@obj.append(Bio::Feature.new('gene', '1..615', [])))
      assert_equal(2, @obj.features.size)
    end

    def test_each
      @obj.each do |feature|
        assert_equal('gene', feature.feature)
      end
    end

    def test_arg # def [](*arg)
      assert_equal('gene', @obj[0].feature)
    end
  end
end
