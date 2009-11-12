#
# test/unit/bio/io/test_togows.rb - Unit test for Bio::TogoWS
#
# Copyright::   Copyright (C) 2009
#               Naohisa Goto <ng@bioruby.org>
# License::     The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'uri'
require 'net/http'
require 'bio/version'
require 'bio/io/togows'
require 'test/unit'

module Bio

  # unit test for Bio::TogoWS::REST
  class TestTogoWSREST < Test::Unit::TestCase

    def setup
      @togows = Bio::TogoWS::REST.new
    end

    def test_debug_default
      assert_equal(false, @togows.debug)
    end

    def test_debug
      assert_equal(true, @togows.debug = true)
      assert_equal(true, @togows.debug)
      assert_equal(false, @togows.debug = false)
      assert_equal(false, @togows.debug)
      assert_equal(true, @togows.debug = true)
      assert_equal(true, @togows.debug)
    end

    def test_internal_http
      assert_kind_of(Net::HTTP, @togows.internal_http)
    end

  end #class TestTogoWSREST

  # unit test for Bio::TogoWS::REST private methods
  class TestTogoWSRESTprivate < Test::Unit::TestCase

    def setup
      @togows = Bio::TogoWS::REST.new
    end

    def test_make_path
      a_and_q = {
        '/ab/cde/fghi' => [ 'ab', 'cde', 'fghi' ],
        '/a+b/a%2Bb/a%2Fb/a%26b/a%3Bb/a%2Cb/a%3Bb' =>
        [ 'a b', 'a+b', 'a/b', 'a&b', 'a;b', 'a,b', 'a;b' ]
      }
      count = 0
      a_and_q.each do |k,v|
        assert_equal(k, @togows.instance_eval { make_path(v) })
        count += 1
      end
      assert_equal(a_and_q.size, count)
    end

    def test_prepare_return_value
      dummyclass = Struct.new(:code, :body)
      dummy200 = dummyclass.new("200", "this is test")
      assert_equal("this is test",
                   @togows.instance_eval { prepare_return_value(dummy200) })
      dummy404 = dummyclass.new("404", "not found")
      assert_equal(nil,
                   @togows.instance_eval { prepare_return_value(dummy404) })
    end

  end #class TestTogoWSRESTprivate


  # unit test for Bio::TogoWS::REST class methods
  class TestTogoWSRESTclassMethod < Test::Unit::TestCase

    def test_new
      assert_instance_of(Bio::TogoWS::REST, Bio::TogoWS::REST.new)
    end

    def test_new_with_uri_string
      t = Bio::TogoWS::REST.new('http://localhost:1234/test')
      assert_instance_of(Bio::TogoWS::REST, t)
      http = t.internal_http
      assert_equal('localhost', http.address)
      assert_equal(1234, http.port)
      assert_equal('/test/', t.instance_eval { @pathbase })
    end

    def test_new_with_uri_object
      u = URI.parse('http://localhost:1234/test')
      t = Bio::TogoWS::REST.new(u)
      assert_instance_of(Bio::TogoWS::REST, t)
      http = t.internal_http
      assert_equal('localhost', http.address)
      assert_equal(1234, http.port)
      assert_equal('/test/', t.instance_eval { @pathbase })
    end

    def test_entry
      assert_respond_to(Bio::TogoWS::REST, :entry)
    end

    def test_search
      assert_respond_to(Bio::TogoWS::REST, :search)
    end

    def test_convert
      assert_respond_to(Bio::TogoWS::REST, :convert)
    end

    def test_retrieve
      assert_respond_to(Bio::TogoWS::REST, :retrieve)
    end

    def test_entry_database_list
      assert_respond_to(Bio::TogoWS::REST, :entry_database_list)
    end

    def test_search_database_list
      assert_respond_to(Bio::TogoWS::REST, :search_database_list)
    end

  end #class TestTogoWSRESTclassMethod

  # dummy class for testing Bio::TogoWS::AccessWait
  class DummyAccessWait
    include Bio::TogoWS::AccessWait
  end

  # unit test for Bio::TogoWS::AccessWait (all methods are private)
  class TestTogoWSAccessWait < Test::Unit::TestCase
    def setup
      @obj = DummyAccessWait.new
    end
    
    def test_togows_access_wait
      assert_kind_of(Numeric, @obj.instance_eval { togows_access_wait })

      waits = 0
      2.times { waits += @obj.instance_eval { togows_access_wait } }
      assert(waits > 0)
    end

    def test_reset_togows_access_wait
      assert_nothing_raised {
        @obj.instance_eval { reset_togows_access_wait }
      }
    end
  end #class TestTogoWSAccessWait

end #module Bio
