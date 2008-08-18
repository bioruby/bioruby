#
# test/unit/bio/io/test_ddbjxml.rb - Unit test for DDBJ XML.
#
# Copyright:: Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::   The Ruby License
#
#  $Id: test_ddbjxml.rb,v 1.4 2007/04/05 23:35:43 trevor Exp $ 
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/io/ddbjxml'

module Bio

class TestDDBJXMLConstants < Test::Unit::TestCase

  def test_constants
    constants = ["DDBJ", "TxSearch", "ClustalW", "PML", "Gib", "Fasta", 
                 "BASE_URI", "SRS", "SERVER_URI", "Gtop", "GetEntry",
                 "Blast", "RequestManager"].sort
    assert_equal(constants, Bio::DDBJ::XML.constants.sort)
  end

  def test_base_url
    assert_equal("http://xml.nig.ac.jp/wsdl/", Bio::DDBJ::XML::BASE_URI)
  end

  def test_blast_server_rul
    assert_equal("http://xml.nig.ac.jp/wsdl/Blast.wsdl", Bio::DDBJ::XML::Blast::SERVER_URI)
  end

  def test_clustalw_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/ClustalW.wsdl", Bio::DDBJ::XML::ClustalW::SERVER_URI)
  end

  def test_ddbj_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/DDBJ.wsdl", Bio::DDBJ::XML::DDBJ::SERVER_URI)
  end

  def test_fasta_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/Fasta.wsdl", Bio::DDBJ::XML::Fasta::SERVER_URI)
  end

  def test_getentry_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/GetEntry.wsdl", Bio::DDBJ::XML::GetEntry::SERVER_URI)
  end

  def test_gib_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/Gib.wsdl", Bio::DDBJ::XML::Gib::SERVER_URI)
  end

  def test_gtop_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/Gtop.wsdl", Bio::DDBJ::XML::Gtop::SERVER_URI)
  end

  def test_pml_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/PML.wsdl", Bio::DDBJ::XML::PML::SERVER_URI)
  end

  def test_srs_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/SRS.wsdl", Bio::DDBJ::XML::SRS::SERVER_URI)
  end

  def test_txsearch_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/TxSearch.wsdl", Bio::DDBJ::XML::TxSearch::SERVER_URI)
  end

  def test_requestmanager_server_url
    assert_equal("http://xml.nig.ac.jp/wsdl/RequestManager.wsdl", Bio::DDBJ::XML::RequestManager::SERVER_URI)
  end

end


end
