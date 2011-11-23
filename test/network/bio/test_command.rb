#
# test/network/bio/test_command.rb - Functional test for network connection methods in Bio::Command
#
# Copyright::	Copyright (C) 2008, 2011
# 		Naohisa Goto <ng@bioruby.org>
# License::	The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 2,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/command'

module Bio
  class FuncTestCommandNet < Test::Unit::TestCase
    def test_read_uri
      assert_nothing_raised {
        Bio::Command.read_uri("http://bioruby.open-bio.org/")
      }
    end

    def test_start_http
    end

    def test_new_http
    end

    def test_post_form
    end
  end #class FuncTestCommandNet
end
