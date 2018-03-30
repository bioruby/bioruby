#
# test/bioruby_test_helper.rb - Helper module for testing bioruby
#
# Copyright::  Copyright (C) 2009 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#

require 'pathname'

unless defined? BioRubyTestDebug then
  BioRubyTestDebug = ENV['BIORUBY_TEST_DEBUG'].to_s.empty? ? false : true
  if BioRubyTestDebug then
    $stderr.puts "BioRuby test debug enabled."
  end
end #BioRubyTestDebug

unless defined? BioRubyTestGem then
  gem_version = ENV['BIORUBY_TEST_GEM']
  if gem_version then
    $stderr.puts 'require "rubygems"' if BioRubyTestDebug
    require "rubygems"
    if gem_version.empty? then
      $stderr.puts "gem 'bio'" if BioRubyTestDebug
      gem 'bio'
    else
      $stderr.puts "gem 'bio', #{gem_version.inspect}" if BioRubyTestDebug
      gem 'bio', gem_version
    end
  end
  BioRubyTestGem = gem_version
end

unless defined? BioRubyTestLibPath then
  libpath = ENV['BIORUBY_TEST_LIB']
  unless libpath then
    libpath = Pathname.new(File.join(File.dirname(__FILE__),
                                     "..", "lib")).cleanpath.to_s
  end

  # do not add path to $: if BIORUBY_TEST_LIB is empty string
  # or BioRubyTestGem is true.
  if (libpath and libpath.empty?) or BioRubyTestGem then
    libpath = nil
  end

  if libpath then
    libpath.freeze

    unless $:[0] == libpath then
      $:.unshift(libpath)
      if BioRubyTestDebug then
        $stderr.puts "Added #{libpath.inspect} to $:."
      end
    else
      if BioRubyTestDebug then
        $stderr.puts "NOT added #{libpath.inspect} to $:. because it is already on the top of $:."
      end
    end
  end

  # (String or nil) Path to be added to $:.
  # It may or may not be the path of bioruby.
  BioRubyTestLibPath = libpath
  
  if BioRubyTestDebug then
    $stderr.print "$: = [", "\n"
    $stderr.puts($:.collect { |x| "\t#{x.inspect}" }.join(",\n"))
    $stderr.print "]", "\n"
  end
end #BioRubyTestLibPath

unless defined? BioRubyTestDataPath and BioRubyTestDataPath
  datapath = ENV['BIORUBY_TEST_DATA']
  if datapath.to_s.empty? then
    datapath = Pathname.new(File.join(File.dirname(__FILE__),
                                      "data")).cleanpath.to_s
  end
  datapath.freeze

  # (String) Path to the test data.
  BioRubyTestDataPath = datapath
  
  if BioRubyTestDebug then
    $stderr.print "DataPath = ", BioRubyTestDataPath.inspect, "\n"
  end
end
