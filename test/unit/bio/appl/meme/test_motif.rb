#
# test/unit/bio/appl/meme/test_motif.rb - Unit test for Bio::Meme::Motif
#
# Copyright::  Copyright (C) 2008 Adam Kraut <adamnkraut@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/meme/motif'

module Bio
  class TestMotif < Test::Unit::TestCase
    
    def setup
      @motif = Meme::Motif.new("P12345", "A", "1", "10", "30", "1.0e-100")
    end
    
    def test_creation_and_attributes
      assert_equal("P12345", @motif.sequence_name)
      assert_equal("A", @motif.strand)
      assert_equal(1, @motif.motif)
      assert_equal(10, @motif.start_pos)
      assert_equal(30, @motif.end_pos)
      assert_equal(1.0e-100, @motif.pvalue)
    end
    
    def test_length
      assert_equal(20, @motif.length)
    end
    
  end # TestMotif
end # Bio
