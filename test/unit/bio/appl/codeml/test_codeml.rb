#
# test/unit/bio/appl/test_codeml.rb - Unit test for Bio::CodeML
#
# Copyright::  Copyright (C) 2008 Michael D. Barton <mail@michaelbarton.me.uk>
# License::    The Ruby License
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

module Bio
  class TestCodeML
    BIORUBY_ROOT  = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
    TEST_DATA = Pathname.new(File.join(BIORUBY_ROOT, 'test', 'data', 'codeml')).cleanpath.to_s
  end
end
