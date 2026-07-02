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
end # module Bio
