#
# test/unit/bio/db/embl/test_uniprotkb_2023_format.rb
#   - Unit test for Bio::UniProtKB for UniProtKB flat file format
#     conventions that are common in entries from 2023 onward
#     (inline evidence tags, "STRAIN"+"PLASMID" RC lines,
#     Rhea-based CATALYTIC ACTIVITY, multi-record SEQUENCE CAUTION,
#     and the ACTIVITY REGULATION / DISRUPTION PHENOTYPE CC topics),
#     using hand-crafted pseudo entries.
#
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/embl/uniprotkb'

module Bio
  class TestUniProtKB_RC_multitoken < Test::Unit::TestCase
    def setup
      text = <<~THE_END_OF_THE_TEXT
        ID   ABC_DEFGH               Reviewed;         256 AA.
        RN   [1]
        RP   NUCLEOTIDE SEQUENCE [GENOMIC DNA].
        RC   STRAIN=K12; PLASMID=pBR322;
        RX   PubMed=12345678;
        RA   Doe J.;
        RL   J. Test. 1:1-1(2020).
      THE_END_OF_THE_TEXT

      @obj = Bio::UniProtKB.new(text)
    end

    def test_rc_keeps_both_tokens
      # Regression test: a naive greedy regexp merges the second and
      # subsequent RC tokens into the text of the first one.
      expected = [{ 'Token' => 'STRAIN', 'Text' => 'K12' },
                  { 'Token' => 'PLASMID', 'Text' => 'pBR322' }]
      assert_equal(expected, @obj.ref[0]['RC'])
    end
  end # class TestUniProtKB_RC_multitoken

  class TestUniProtKB_GN_evidence_tag < Test::Unit::TestCase
    def setup
      text = <<~THE_END_OF_THE_TEXT
        ID   ABC_DEFGH               Reviewed;         256 AA.
        GN   Name=fooX {ECO:0000255|HAMAP-Rule:MF_00042}; Synonyms=barY {ECO:0000255|HAMAP-Rule:MF_00042}, bazZ;
        GN   OrderedLocusNames=XX_0001 {ECO:0000313|EMBL:AAA00001.1};
        GN   ORFNames=YY0001 {ECO:0000313|EMBL:AAA00001.1}, YY0002;
      THE_END_OF_THE_TEXT

      @obj = Bio::UniProtKB.new(text)
    end

    def test_gn_strips_evidence_tag
      expected = [{ name: 'fooX', synonyms: %w[barY bazZ],
                    loci: ['XX_0001'], orfs: %w[YY0001 YY0002] }]
      assert_equal(expected, @obj.gn)
    end

    def test_gene_name_strips_evidence_tag
      assert_equal('fooX', @obj.gene_name)
    end
  end # class TestUniProtKB_GN_evidence_tag

  class TestUniProtKB_RN_RC_evidence_tag < Test::Unit::TestCase
    def setup
      text = <<~THE_END_OF_THE_TEXT
        ID   ABC_DEFGH               Reviewed;         256 AA.
        RN   [1] {ECO:0000313|EMBL:AAA00001.1}
        RP   NUCLEOTIDE SEQUENCE [GENOMIC DNA].
        RC   STRAIN=K12 {ECO:0000313|EMBL:AAA00001.1}; PLASMID=pBR322 {ECO:0000303|PubMed:12345678};
        RX   PubMed=12345678;
        RA   Doe J.;
        RL   J. Test. 1:1-1(2020).
      THE_END_OF_THE_TEXT

      @obj = Bio::UniProtKB.new(text)
    end

    def test_rn_strips_evidence_tag
      assert_equal('[1]', @obj.ref[0]['RN'])
    end

    def test_rc_keeps_both_tokens_and_strips_evidence_tag
      expected = [{ 'Token' => 'STRAIN', 'Text' => 'K12' },
                  { 'Token' => 'PLASMID', 'Text' => 'pBR322' }]
      assert_equal(expected, @obj.ref[0]['RC'])
    end
  end # class TestUniProtKB_RN_RC_evidence_tag

  class TestUniProtKB_OX_evidence_tag < Test::Unit::TestCase
    def setup
      text = <<~THE_END_OF_THE_TEXT
        ID   ABC_DEFGH               Reviewed;         256 AA.
        OX   NCBI_TaxID=1234 {ECO:0000313|EMBL:AAA00001.1};
      THE_END_OF_THE_TEXT

      @obj = Bio::UniProtKB.new(text)
    end

    def test_ox_strips_evidence_tag
      assert_equal({ 'NCBI_TaxID' => ['1234'] }, @obj.ox)
    end
  end # class TestUniProtKB_OX_evidence_tag

  class TestUniProtKB_DE_evidence_tag < Test::Unit::TestCase
    def setup
      text = <<~THE_END_OF_THE_TEXT
        ID   ABC_DEFGH               Reviewed;         256 AA.
        DE   RecName: Full=Test protein {ECO:0000255|HAMAP-Rule:MF_00042};
        DE            Short=TstP {ECO:0000255|HAMAP-Rule:MF_00042};
      THE_END_OF_THE_TEXT

      @obj = Bio::UniProtKB.new(text)
    end

    def test_de_strips_evidence_tag
      expected = [['RecName', ['Full', 'Test protein'], %w[Short TstP]]]
      assert_equal(expected, @obj.de)
    end

    def test_protein_name_strips_evidence_tag
      assert_equal('Test protein', @obj.protein_name)
    end
  end # class TestUniProtKB_DE_evidence_tag

  class TestUniProtKB_CC_CATALYTIC_ACTIVITY < Test::Unit::TestCase
    def setup
      text = <<~THE_END_OF_THE_TEXT
        ID   ABC_DEFGH               Reviewed;         256 AA.
        CC   -!- CATALYTIC ACTIVITY:
        CC       Reaction=a + b = c + d; Xref=Rhea:RHEA:12345, ChEBI:CHEBI:1,
        CC         ChEBI:CHEBI:2; EC=1.2.3.4; Evidence={ECO:0000255|HAMAP-Rule:MF_00042};
        CC       PhysiologicalDirection=left-to-right; Xref=Rhea:RHEA:12346;
      THE_END_OF_THE_TEXT

      @obj = Bio::UniProtKB.new(text)
    end

    def test_cc_catalytic_activity
      expected = [{ 'Reaction' => 'a + b = c + d',
                    'Xref' => %w[Rhea:RHEA:12345 ChEBI:CHEBI:1
                                 ChEBI:CHEBI:2 Rhea:RHEA:12346],
                    'EC' => '1.2.3.4',
                    'Evidence' => ['ECO:0000255|HAMAP-Rule:MF_00042'],
                    'PhysiologicalDirection' => 'left-to-right' }]
      assert_equal(expected, @obj.cc('CATALYTIC ACTIVITY'))
    end
  end # class TestUniProtKB_CC_CATALYTIC_ACTIVITY
end # module Bio
