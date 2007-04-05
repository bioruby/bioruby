#
# = test/unit/bio/io/test_ensembl.rb - Unit test for Bio::Ensembl.
#
# Copyright::   Copyright (C) 2006, 2007
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: test_ensembl.rb,v 1.6 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/io/ensembl'

# tests for ensembl.rb,v 1.4
class TestEnsembl_v14 < Test::Unit::TestCase
  def test_ensembl_url
    assert_equal('http://www.ensembl.org', Bio::Ensembl::ENSEMBL_URL)
  end
  
  def test_server
    obj = Bio::Ensembl.new('Homo_sapiens')
    assert_equal('http://www.ensembl.org', obj.server)
  end

  def test_organism
    organism = 'Homo_sapiens'
    obj = Bio::Ensembl.new(organism)
    assert_equal(organism, obj.organism)
  end
  
  def test_self_human
    organism = 'Homo_sapiens'    
    obj = Bio::Ensembl.human
    assert_equal(organism, obj.organism)
  end

  def test_self_mouse
    organism = 'Mus_musculus'
    obj = Bio::Ensembl.mouse
    assert_equal(organism, obj.organism)
  end

  def test_new_with_2_args
    organism = 'Oryza_sativa'
    server_url = 'http://www.gramene.org'
    obj = Bio::Ensembl.new(organism, server_url)
    assert_equal(organism, obj.organism)
    assert_equal(server_url, obj.server)
  end
end


class TestEnsembl < Test::Unit::TestCase
  def test_server_name
    assert_equal('http://www.ensembl.org', Bio::Ensembl::EBIServerURI)
  end

  def test_server_uri
    assert_equal('http://www.ensembl.org', Bio::Ensembl.server_uri)
  end
  
  def test_set_server_uri
    host = 'http://localhost'
    Bio::Ensembl.server_uri(host)
    assert_equal(host, Bio::Ensembl.server_uri)
  end
end


class TestEnsemblBase < Test::Unit::TestCase
  def test_exportview
    
  end
end

class TestEnsemblBaseClient < Test::Unit::TestCase
  def test_class

  end
end


class TestEnsemblHuman < Test::Unit::TestCase
  def test_organism
    assert_equal("Homo_sapiens", Bio::Ensembl::Human::Organism)
  end
end

class TestEnsemblMouse < Test::Unit::TestCase
  def test_organism
    assert_equal("Mus_musculus", Bio::Ensembl::Mouse::Organism)
  end
end


class TestEnsemblOldStyleClient < Test::Unit::TestCase
  class Rice < Bio::Ensembl::Base
    Organism = 'Oryza_sativa'
  end

  def test_organism
    assert_equal('Oryza_sativa', Rice::Organism)
  end
end
  
