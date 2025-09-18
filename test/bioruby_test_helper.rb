#
# test/bioruby_test_helper.rb - Helper module for testing bioruby
#
# Copyright::  Copyright (C) 2009 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#

require 'pathname'

unless defined? BioRubyTestDebug
  BioRubyTestDebug = ENV['BIORUBY_TEST_DEBUG'].to_s.empty? ? false : true
  warn 'BioRuby test debug enabled.' if BioRubyTestDebug
end # BioRubyTestDebug

unless defined? BioRubyTestGem
  gem_version = ENV.fetch('BIORUBY_TEST_GEM', nil)
  if gem_version
    warn 'require "rubygems"' if BioRubyTestDebug
    require 'rubygems'
    if gem_version.empty?
      warn "gem 'bio'" if BioRubyTestDebug
      gem 'bio'
    else
      warn "gem 'bio', #{gem_version.inspect}" if BioRubyTestDebug
      gem 'bio', gem_version
    end
  end
  BioRubyTestGem = gem_version
end

unless defined? BioRubyTestLibPath
  libpath = ENV.fetch('BIORUBY_TEST_LIB', nil)
  libpath ||= Pathname.new(File.join(File.dirname(__FILE__),
                                     '..', 'lib')).cleanpath.to_s

  # do not add path to $: if BIORUBY_TEST_LIB is empty string
  # or BioRubyTestGem is true.
  libpath = nil if (libpath and libpath.empty?) or BioRubyTestGem

  if libpath
    libpath.freeze

    if $:[0] == libpath
      warn "NOT added #{libpath.inspect} to $:. because it is already on the top of $:." if BioRubyTestDebug
    else
      $:.unshift(libpath)
      warn "Added #{libpath.inspect} to $:." if BioRubyTestDebug
    end
  end

  # (String or nil) Path to be added to $:.
  # It may or may not be the path of bioruby.
  BioRubyTestLibPath = libpath

  if BioRubyTestDebug
    $stderr.print '$: = [', "\n"
    warn($:.collect { |x| "\t#{x.inspect}" }.join(",\n"))
    $stderr.print ']', "\n"
  end
end # BioRubyTestLibPath

unless defined? BioRubyTestDataPath and BioRubyTestDataPath
  datapath = ENV.fetch('BIORUBY_TEST_DATA', nil)
  if datapath.to_s.empty?
    datapath = Pathname.new(File.join(File.dirname(__FILE__),
                                      'data')).cleanpath.to_s
  end
  datapath.freeze

  # (String) Path to the test data.
  BioRubyTestDataPath = datapath

  $stderr.print 'DataPath = ', BioRubyTestDataPath.inspect, "\n" if BioRubyTestDebug
end
