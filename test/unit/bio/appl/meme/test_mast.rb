#
# test/unit/bio/appl/meme/test_mast.rb - Unit test for Bio::Meme::Mast
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
require 'bio/appl/meme/mast'

module Bio
module TestMastData
  
  TEST_DATA = Pathname.new(File.join(BioRubyTestDataPath, 'meme')).cleanpath.to_s
  
  def self.example_mfile
    File.join TEST_DATA, 'meme.out'
  end
  
  def self.dummy_binary
    File.join TEST_DATA, 'mast'
  end
  
  def self.dummy_db
    File.join TEST_DATA, 'db'
  end
end

class TestMast < Test::Unit::TestCase
  
  TEST_DATA = TestMastData::TEST_DATA
  
  def setup
    @example_mfile = TestMastData.example_mfile
    @binary = TestMastData.dummy_binary
    @db = TestMastData.dummy_db
    @mast = Meme::Mast.new(@binary)
  end
  
  def test_config_defaults
    assert_equal(true, @mast.options[:hit_list])
    assert_equal(true, @mast.options[:stdout])
    assert_equal(true, @mast.options[:nostatus])
  end
  
  def test_minimal_config
    options = {:mfile => @example_mfile, :d => @db}
    @mast.config(options)
    assert_equal(@db, @mast.options[:d])
    assert_equal(@example_mfile, @mast.options[:mfile])
  end
  
  def test_more_config
    options = {:mfile => @example_mfile, :d => @db, :dna => true}
    @mast.config(options)
    assert_equal(true, @mast.options[:dna])
  end
  
  def test_check_options_with_valid_opts
    options = {:mfile => @example_mfile, :d => @db}
    @mast.config(options)
    assert_nothing_raised { @mast.check_options }
  end
  
  def test_check_options_with_invalid_opts
    options = {:mfile => @example_mfile, :d => @db, :bad => "option"}
    @mast.config(options)
    assert_raises(ArgumentError) { @mast.check_options }
  end
  
  def test_check_options_with_empty_opts
    # <mfile> and <-d> are required
    options = {}
    @mast.config(options)
    assert_raises(ArgumentError) { @mast.check_options }
  end
  
  # this is ugly
  def test_command_to_be_run
    options = {:mfile => @example_mfile, :d => @db}
    @mast.config(options)
    assert_equal(true, @mast.cmd.include?("#{@binary} #{@example_mfile} -d #{@db}") )
    assert_equal(true, @mast.cmd.include?('-hit_list') )
    assert_equal(true, @mast.cmd.include?('-stdout') )
    assert_equal(true, @mast.cmd.include?('-nostatus') )
  end
  
  # this would require a working executable and a database
  def test_run
    # options = {:mfile => @example_mfile, :d => @db}
    # @mast.config(options)
    # report = @mast.run
    # assert_kind_of(Meme::Mast::Report, report)
  end
  
end # TestMast
end # Bio
