#
# test/functional/bio/io/test_pubmed.rb - Functional test for Bio::PubMed
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
require 'test/unit'
require 'bio/io/pubmed'
require 'bio/db/medline'

module Bio

  module FuncTestPubmedCommon

    def test_esearch
      a = @pm.esearch('agile bioinformatics')
      assert_kind_of(Array, a)
      assert_operator(a.size, :>=, 3,
                      'The failure may be caused by changes of NCBI PubMed.')
      a.each do |x|
        assert_kind_of(String, x)
        assert_equal(x.strip, x.to_i.to_s,
                     'PMID is not an integer value. This suggests that NCBI have changed the PMID policy.')
      end
    end

    def test_esearch_count
      a = @pm.esearch('agile bioinformatics',
                      { "rettype"=>"count" })
      assert_kind_of(Integer, a)
      assert_operator(a, :>=, 3,
                      'The failure may be caused by changes of NCBI PubMed.')
    end

    def test_esearch_retmax_retstart
      a = @pm.esearch('p53', { "retmax" => 10, "retstart" => 20 })
      assert_equal(10, a.size,
                   'The failure may be caused by changes of NCBI PubMed.')
      a.each do |x|
        assert_kind_of(String, x)
        assert_equal(x.strip, x.to_i.to_s,
                     'PMID is not an integer value. This suggests that NCBI have changed the PMID policy.')
      end

      a1 = @pm.esearch('p53', { "retmax" => 15, "retstart" => 35 })
      a2 = @pm.esearch('p53', { "retmax" => 10, "retstart" => 0 })
      assert_equal(35, (a + a1 + a2).sort.uniq.size,
                   'The failure may be caused by changes of NCBI PubMed.')

      a3 = @pm.esearch('p53', { "retmax" => 10 })
      assert_equal(a2.sort, a3.sort,
                   'The failure may be caused by changes of NCBI PubMed.')
    end

    def check_pubmed_entry(pmid, str)
      m = Bio::MEDLINE.new(str)
      assert_equal(pmid.to_s, m.pmid)
    end
    private :check_pubmed_entry

    def do_efetch_single(pmid)
      a = @pm.efetch(pmid)
      assert_kind_of(Array, a)
      assert_equal(1, a.size)
      check_pubmed_entry(pmid, a[0])
    end
    private :do_efetch_single

    def test_efetch
      do_efetch_single(12368254)
    end

    def test_efetch_str
      do_efetch_single("16734914")
    end

    def test_efetch_multiple
      arg = [ 12368254, 18689808, 19304878 ]
      a = @pm.efetch(arg)
      assert_kind_of(Array, a)
      assert_equal(3, a.size)
      a.each do |str|
        check_pubmed_entry(arg.shift, str)
      end
    end

    def test_efetch_single_xml
      arg = 12368254
      str = @pm.efetch(arg, { "retmode" => 'xml' })
      assert_kind_of(String, str)
      assert(str.index(/\<PubmedArticleSet\>/))
    end

    def test_efetch_multiple_xml
      arg = [ "16734914", 16381885, "10592173" ]
      str = @pm.efetch(arg, { "retmode" => 'xml' })
      assert_kind_of(String, str)
      assert(str.index(/\<PubmedArticleSet\>/))
    end

  end #module FuncTestPubmedCommon

  class FuncTestPubmed < Test::Unit::TestCase

    include FuncTestPubmedCommon

    def setup
      Bio::NCBI.default_email = 'staff@bioruby.org'
      #$stderr.puts Bio::NCBI.default_tool
      @pm = Bio::PubMed.new
    end
  end #class FuncTestPubmed

  class FuncTestPubmedClassMethod < Test::Unit::TestCase

    include FuncTestPubmedCommon

    def setup
      Bio::NCBI.default_email = 'staff@bioruby.org'
      #$stderr.puts Bio::NCBI.default_tool
      @pm = Bio::PubMed
    end
  end #class FuncTestPubmedClassMethod

end
