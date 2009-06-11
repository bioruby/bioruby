#!/usr/bin/env ruby

require 'test/unit'
require 'pathname'

bioruby_libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'], 'lib')).cleanpath.to_s
$:.unshift(bioruby_libpath) unless $:.include?(bioruby_libpath)

if !defined?(Test::Unit::AutoRunner) then
  # Ruby 1.9.1 does not have Test::Unit::AutoRunner
  Test::Unit.setup_argv do |files|
    [ File.dirname($0) ]
  end
  # tests called when exiting the program

elsif defined?(Test::Unit::Color) then
  # workaround for test-unit-2.0.x
  r = Test::Unit::AutoRunner.new(true)
  r.to_run.push File.dirname($0)
  r.process_args(ARGV)
  exit r.run

elsif RUBY_VERSION > "1.8.2"
  # current Test::Unit -- Ruby 1.8.3 or later
  exit Test::Unit::AutoRunner.run(true, File.dirname($0))
else
  # old Test::Unit -- Ruby 1.8.2 or older
  exit Test::Unit::AutoRunner.run(false, File.dirname($0))
end

