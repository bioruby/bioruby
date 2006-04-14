#
# = test/unit/bio/io/test_ensembl.rb - Unit test for Bio::Ensembl.
#
# Copyright::   Copyright (C) 2006
#               Mitsuteru C. Nakao <n@bioruby.org>
# License::     Ruby's
#
# $Id: test_ensembl.rb,v 1.1 2006/04/14 06:28:09 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/io/ensembl'


class TestEnsembl < Test::Unit::TestCase
  def test_server_name
    assert_equal('www.ensembl.org', Bio::Ensembl::ServerName)
  end

end

class TestEnsemblBase < Test::Unit::TestCase
  def test_exportview
    
  end
end

class TestEnsemblBaseClient < Test::Unit::TestCase
  def test_class
    assert_equal(Bio::PSORT::CGIDriver, Bio::Ensembl::Base::Client.superclass)
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
