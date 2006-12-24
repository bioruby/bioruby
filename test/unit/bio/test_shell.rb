#
# test/unit/bio/test_shell.rb - Unit test for Bio::Shell
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    Ruby's
#
#  $Id: test_shell.rb,v 1.6 2006/12/24 17:19:04 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/shell'

module Bio
end
