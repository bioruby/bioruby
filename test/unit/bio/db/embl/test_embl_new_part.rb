#
# test/unit/bio/db/embl/test_embl_new_part.rb - Unit test for Bio::EMBL
#   for EMBL/ENA flat file format conventions common in entries from
#   2013 onward, using hand-crafted pseudo entries.
#
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/embl/embl'

module Bio
  class TestEMBL_PR_line < Test::Unit::TestCase
    def setup
      # Since 2013 (e.g. Rel. 117), entries may carry a PR line
      # cross-referencing the BioProject the entry belongs to.
      text = <<~THE_END_OF_THE_TEXT
        ID   AB123456; SV 1; linear; genomic DNA; STD; PRO; 4 BP.
        XX
        AC   AB123456;
        XX
        PR   Project:PRJEB1159;
        XX
        SQ   Sequence 4 BP; 1 A; 1 C; 1 G; 1 T; 0 other;
             acgt                                                               4
        //
      THE_END_OF_THE_TEXT

      @obj = Bio::EMBL.new(text)
    end

    def test_pr
      assert_equal(['PRJEB1159'], @obj.pr)
    end

    def test_project
      assert_equal(['PRJEB1159'], @obj.project)
    end
  end # class TestEMBL_PR_line

  class TestEMBL_PR_line_absent < Test::Unit::TestCase
    def setup
      text = <<~THE_END_OF_THE_TEXT
        ID   AB123456; SV 1; linear; genomic DNA; STD; PRO; 4 BP.
        XX
        AC   AB123456;
        XX
        SQ   Sequence 4 BP; 1 A; 1 C; 1 G; 1 T; 0 other;
             acgt                                                               4
        //
      THE_END_OF_THE_TEXT

      @obj = Bio::EMBL.new(text)
    end

    def test_pr_absent
      # Older entries (before PR was introduced) have no PR line.
      assert_equal([], @obj.pr)
    end
  end # class TestEMBL_PR_line_absent
end # module Bio
