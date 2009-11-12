#
# = test/unit/bio/appl/test_pts1.rb - Unit test for Bio::PTS1
#
# Copyright::   Copyright (C) 2006 
#               Mitsuteru Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/appl/pts1'


module Bio

  class TestPTS1Constant < Test::Unit::TestCase
    def test_FUNCTION
      keys = ['METAZOA-specific','FUNGI-specific','GENERAL'].sort
      assert_equal(keys, Bio::PTS1::FUNCTION.keys.sort)
    end

  end

  class TestPTS1New < Test::Unit::TestCase
    def test_metazoa
      pts1 = Bio::PTS1.new_with_metazoa_function
      assert_equal('METAZOA-specific', pts1.function)
    end

    def test_fungi
      pts1 = Bio::PTS1.new_with_fungi_function
      assert_equal('FUNGI-specific', pts1.function)
    end

    def test_general
      pts1 = Bio::PTS1.new_with_general_function
      assert_equal('GENERAL', pts1.function)
    end
  end

  class TestPTS1 < Test::Unit::TestCase

    def setup
      @serv = Bio::PTS1.new
    end


    def test_function_set
      @serv.function("GENERAL")
      assert_equal("GENERAL", @serv.function)
    end

    def test_function_show
      assert_equal("METAZOA-specific", @serv.function)
    end

    def test_function_set_number_1
      @serv.function(1)
      assert_equal("METAZOA-specific", @serv.function)
    end

    def test_function_set_number_2
      @serv.function(2)
      assert_equal("FUNGI-specific", @serv.function)
    end

    def test_function_set_number_3
      @serv.function(3)
      assert_equal("GENERAL", @serv.function)
    end
  end
end
