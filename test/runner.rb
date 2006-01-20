#!/usr/bin/env ruby

require 'test/unit'
require 'pathname'

bioruby_libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'], 'lib')).cleanpath.to_s
$:.unshift(bioruby_libpath) unless $:.include?(bioruby_libpath)

if RUBY_VERSION > "1.8.2"
  exit Test::Unit::AutoRunner.run(true, File.dirname($0))
else
  exit Test::Unit::AutoRunner.run(false, File.dirname($0))
end

