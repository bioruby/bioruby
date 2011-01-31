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

unless defined? BioRubyTestLibPath and BioRubyTestLibPath then
  libpath = ENV['BIORUBY_TEST_LIB']
  if libpath.to_s.empty? then
    libpath = Pathname.new(File.join(File.dirname(__FILE__),
                                     "..", "lib")).cleanpath.to_s
  end
  libpath.freeze

  unless $:.include?(libpath)
    $:.unshift(libpath)
    if BioRubyTestDebug then
      $stderr.puts "Added #{libpath.inspect} to $:."
    end
  else
    if BioRubyTestDebug then
      $stderr.puts "NOT added #{libpath.inspect} to $:. because it is already in $:."
    end
  end

  # (String) Path to be added to $:.
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
