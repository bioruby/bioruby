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

  class TestEMBL_CO_line < Test::Unit::TestCase
    def setup
      # CON-division entries (e.g. chromosome-level assemblies built
      # by joining WGS scaffolds, such as human GRCh38 chromosome 1,
      # accession CM000663) do not embed the sequence itself in an
      # SQ/sequence record; a CO line describes it as a join of other
      # entries instead.
      text = <<~THE_END_OF_THE_TEXT
        ID   AB123456; SV 1; linear; genomic DNA; CON; PRO; 3100 BP.
        XX
        AC   AB123456;
        XX
        CO   join(BX000000.1:1..1000,gap(100),BX000001.1:1..2000)
        //
      THE_END_OF_THE_TEXT

      @obj = Bio::EMBL.new(text)
    end

    def test_co
      assert_equal('join(BX000000.1:1..1000,gap(100),BX000001.1:1..2000)',
                   @obj.co)
    end

    def test_contig
      assert_equal('join(BX000000.1:1..1000,gap(100),BX000001.1:1..2000)',
                   @obj.contig)
    end

    def test_seq_is_empty_when_only_co_line_present
      assert_equal('', @obj.seq.to_s)
    end
  end # class TestEMBL_CO_line

  class TestEMBL_CO_line_absent < Test::Unit::TestCase
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

    def test_co_absent
      assert_equal('', @obj.co)
    end
  end # class TestEMBL_CO_line_absent

  class TestEMBL_RG_line < Test::Unit::TestCase
    def setup
      # Real example pattern (Homo sapiens chromosome 1, GRCh38,
      # accession CM000663): a reference authored solely by a
      # consortium (no RA line at all), and one with both individual
      # authors (RA) and a consortium name (RG).
      text = <<~THE_END_OF_THE_TEXT
        ID   AB123456; SV 1; linear; genomic DNA; STD; PRO; 4 BP.
        XX
        AC   AB123456;
        XX
        RN   [1]
        RA   Doe J., Roe R.;
        RG   Example Genome Consortium
        RT   ;
        RL   Submitted (01-JAN-2020) to the INSDC.
        XX
        RN   [2]
        RG   Example Genome Consortium
        RT   ;
        RL   Submitted (01-JAN-2020) to the INSDC.
        XX
        SQ   Sequence 4 BP; 1 A; 1 C; 1 G; 1 T; 0 other;
             acgt                                                               4
        //
      THE_END_OF_THE_TEXT

      @obj = Bio::EMBL.new(text)
    end

    def test_references_authors_include_consortium_alongside_individuals
      # Regression test: RG (reference group/consortium name) used to
      # be silently dropped by Common#references.
      expected = ['Doe, J.', 'Roe, R.', 'Example Genome Consortium']
      assert_equal(expected, @obj.references[0].authors)
    end

    def test_references_authors_is_consortium_only_when_no_ra
      assert_equal(['Example Genome Consortium'], @obj.references[1].authors)
    end
  end # class TestEMBL_RG_line
end # module Bio
