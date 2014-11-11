#!/usr/bin/env ruby

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), 
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'

unit_test = File.join(File.dirname($0), "unit")
func_test = File.join(File.dirname($0), "functional")

if !defined?(Test::Unit::AutoRunner) then
  # Ruby 1.9.1 does not have Test::Unit::AutoRunner
  Test::Unit.setup_argv do |files|
    [ unit_test, func_test ]
  end
  # tests called when exiting the program

elsif defined?(Test::Unit::Color) then
  # workaround for test-unit-2.0.x
  r = Test::Unit::AutoRunner.new(true)
  r.to_run.push unit_test
  r.to_run.push func_test
  r.process_args(ARGV)
  exit r.run

elsif RUBY_VERSION > "1.8.2" then
  r = Test::Unit::AutoRunner.new(true) do |ar|
    ar.to_run.push unit_test
    ar.to_run.push func_test
    [ unit_test, func_test ]
  end
  r.process_args(ARGV)
  exit r.run

else
  # old Test::Unit -- Ruby 1.8.2 or older
  raise "Ruby version too old. Please use newer version of Ruby."
end

