#
# test/unit/bio/db/embl/common.rb - Unit test for Bio::EMBL::COMMON module
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/embl/common'


module Bio

  # TestClass EMBLDB Inherited 
  class EMBL_API < EMBLDB
    include Bio::EMBLDB::Common
  end


  class TestEMBLCommon < Test::Unit::TestCase

    def setup
      @obj = Bio::EMBLDB::Common
    end

    def test_ac
      assert(@obj.instance_methods.find {|x| x.to_s ==  'ac' })
    end

    def test_accessions
      assert(@obj.instance_methods.find {|x| x.to_s ==  'accessions' })
    end
    
    def test_accession
      assert(@obj.instance_methods.find {|x| x.to_s ==  'accession' })
    end

    def test_de
      assert(@obj.instance_methods.find {|x| x.to_s ==  'de' })
    end
    
    def test_description
      assert(@obj.instance_methods.find {|x| x.to_s ==  'description' })
    end

    def test_definition
      assert(@obj.instance_methods.find {|x| x.to_s ==  'definition' })
    end

    def test_os
      assert(@obj.instance_methods.find {|x| x.to_s ==  'os' })
    end

    def test_og
      assert(@obj.instance_methods.find {|x| x.to_s ==  'og' })
    end
    
    def test_oc
      assert(@obj.instance_methods.find {|x| x.to_s ==  'oc' })
    end
    
    def test_kw
      assert(@obj.instance_methods.find {|x| x.to_s ==  'kw' })
    end

    def test_keywords
      assert(@obj.instance_methods.find {|x| x.to_s ==  'keywords' })
    end

    def test_ref
      assert(@obj.instance_methods.find {|x| x.to_s ==  'ref' })
    end

    def test_references
      assert(@obj.instance_methods.find {|x| x.to_s ==  'references' })
    end

    def test_dr
      assert(@obj.instance_methods.find {|x| x.to_s ==  'dr' })
    end
  end


  class TestEMBLAPI < Test::Unit::TestCase

    def setup
      data =<<END
AC   A12345; B23456;
DE   Dummy data for Bio::EMBL::Common APIs.
OS   Ruby Class Library for Bioinformatics (BioRuby) (open-bio).
OC   
OG
KW
R
DR
END
      @obj = Bio::EMBL_API.new(data)
    end

    def test_ac
      assert_equal(["A12345", "B23456"], @obj.ac)
    end

    def test_accessions
      assert_equal(["A12345", "B23456"], @obj.accessions)
    end

  end

  
end
