#
# test/network/bio/test_command.rb - Functional test for network connection methods in Bio::Command
#
# Copyright::	Copyright (C) 2008, 2011, 2015
# 		Naohisa Goto <ng@bioruby.org>
# License::	The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 2,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'uri'
require 'bio/command'

module Bio
  class FuncTestCommandNet < Test::Unit::TestCase
    def setup
      @host = "bioruby.open-bio.org"
      @port = 80 
      @path = "/"
      @url = "http://bioruby.open-bio.org:80/"
      @uri = URI.parse(@url)
    end

    def test_read_uri
      str = nil
      assert_nothing_raised {
        str = Bio::Command.read_uri(@url)
      }
      assert(!str.to_s.empty?)
    end

    def test_start_http_uri
      ht = Bio::Command.start_http_uri(@uri)
      assert_kind_of(Net::HTTP, ht)
      res = ht.get(@path)
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_start_http_uri_with_block
      res = Bio::Command.start_http_uri(@uri) do |ht|
        assert_kind_of(Net::HTTP, ht)
        ht.get(@path)
      end
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_start_http
      ht = Bio::Command.start_http(@host, @port)
      assert_kind_of(Net::HTTP, ht)
      res = ht.get(@path)
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_start_http_with_block
      res = Bio::Command.start_http(@host, @port) do |ht|
        assert_kind_of(Net::HTTP, ht)
        ht.get(@path)
      end
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_start_http_default_port
      ht = Bio::Command.start_http(@host)
      assert_kind_of(Net::HTTP, ht)
      res = ht.get(@path)
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_new_http
      ht = Bio::Command.new_http(@host, @port)
      assert_kind_of(Net::HTTP, ht)
      res = ht.get(@path)
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_new_http_default_port
      ht = Bio::Command.new_http(@host)
      assert_kind_of(Net::HTTP, ht)
      res = ht.get(@path)
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_post_form
      res = Bio::Command.post_form(@url, { 'test' => 'bioruby' })
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_http_post_form
      ht = Bio::Command.new_http(@host)
      res = Bio::Command.http_post_form(ht, @path,
                                        { 'test' => 'bioruby' },
                                        { 'Content-Language' => 'en' })
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_post
      res = Bio::Command.post(@url, "this is test\n" * 10)
      assert_kind_of(Net::HTTPResponse, res)
    end

    def test_http_post
      ht = Bio::Command.new_http(@host)
      res = Bio::Command.http_post(ht, @path,
                                        "this is test\n" * 10,
                                        { 'Content-Language' => 'en' })
      assert_kind_of(Net::HTTPResponse, res)
    end

  end #class FuncTestCommandNet
end
