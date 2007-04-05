#
# test/unit/bio/db/embl/common.rb - Unit test for Bio::EMBL::COMMON module
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_common.rb,v 1.4 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

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
      assert(@obj.instance_methods.find {|x| x ==  'ac' })
    end

    def test_accessions
      assert(@obj.instance_methods.find {|x| x ==  'accessions' })
    end
    
    def test_accession
      assert(@obj.instance_methods.find {|x| x ==  'accession' })
    end

    def test_de
      assert(@obj.instance_methods.find {|x| x ==  'de' })
    end
    
    def test_description
      assert(@obj.instance_methods.find {|x| x ==  'description' })
    end

    def test_definition
      assert(@obj.instance_methods.find {|x| x ==  'definition' })
    end

    def test_os
      assert(@obj.instance_methods.find {|x| x ==  'os' })
    end

    def test_og
      assert(@obj.instance_methods.find {|x| x ==  'og' })
    end
    
    def test_oc
      assert(@obj.instance_methods.find {|x| x ==  'oc' })
    end
    
    def test_kw
      assert(@obj.instance_methods.find {|x| x ==  'kw' })
    end

    def test_keywords
      assert(@obj.instance_methods.find {|x| x ==  'keywords' })
    end

    def test_ref
      assert(@obj.instance_methods.find {|x| x ==  'ref' })
    end

    def test_references
      assert(@obj.instance_methods.find {|x| x ==  'references' })
    end

    def test_dr
      assert(@obj.instance_methods.find {|x| x ==  'dr' })
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
