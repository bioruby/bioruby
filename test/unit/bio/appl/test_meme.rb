#
# test/unit/bio/appl/meme/test_mast.rb - Unit test for Bio::Meme::Mast
#
# Copyright::  Copyright (C) 2008 Adam Kraut    <adamnkraut@gmail.com>
# Copyright::  Copyright (C) 2011 Brandon Fulk  <brandon.fulk@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/meme'

module Bio
module TestMemeData
  
  TEST_DATA = Pathname.new(File.join(BioRubyTestDataPath, 'meme')).cleanpath.to_s
  
  def self.dataset
    File.join TEST_DATA, 'dataset'
  end
  
  def self.dummy_binary
    File.join TEST_DATA, 'meme'
  end
  
end

class TestMeme < Test::Unit::TestCase
  
  TEST_DATA = TestMemeData::TEST_DATA
  
  def setup
    @dataset = TestMemeData.dataset
    @binary = TestMemeData.dummy_binary
    @meme = Meme.new(@binary)
  end
  
  # the defaults should be equal
  def test_config_defaults
    assert_equal("oops", @meme.options[:mod])
    assert_equal(3,      @meme.options[:nmotifs])
    assert_equal(40,     @meme.options[:maxw])
    assert_equal(true,   @meme.options[:protein])
    assert_equal(true,   @meme.options[:text])
    assert_equal(true,   @meme.options[:nostatus])
  end
  
  def test_minimal_config
    options = {:dataset => @dataset}
    @meme.config(options)    
    assert_equal(@dataset, @meme.options[:dataset])
  end
  
  def test_more_config
    options = {:dataset => @dataset, :dna => true}
    @meme.config(options)
    assert_equal(true, @meme.options[:dna])
  end
  
  def test_check_options_with_valid_opts
    options = {:dataset => @dataset, :maxw => 50}
    @meme.config(options)
    assert_nothing_raised { @meme.check_options }
  end
  
  def test_check_options_with_invalid_opts
    options = {:dataset => @dataset, :bad => "option"}
    @meme.config(options)
    assert_raises(ArgumentError) { @meme.check_options }
  end
  
  def test_check_options_with_empty_opts
    # <dataset> is required
    options = {}
    @meme.config(options)
    assert_raises(ArgumentError) { @meme.check_options }
  end
  
  # this is ugly
  def test_command_to_be_run
    options = {:dataset => @dataset}
    @meme.config(options)
    assert_equal(true, @meme.cmd.include?("#{@binary} #{@dataset}") )
    assert_equal(true, @meme.cmd.include?('-nmotifs') )
    assert_equal(true, @meme.cmd.include?('-mod') )
    assert_equal(true, @meme.cmd.include?('-text') )
    assert_equal(true, @meme.cmd.include?('-nostatus') )
  end
  
  # this would require a working executable and a database
  def test_run
    # options = {:mfile => @example_mfile, :d => @db}
    ## @mast.config(options)
    # report = @mast.run
    # assert_kind_of(Meme::Mast::Report, report)
  end
  
end # TestMast
end # Bio
