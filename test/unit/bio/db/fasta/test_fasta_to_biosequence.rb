# frozen_string_literal: true

#
# test/unit/bio/db/fasta/test_fasta_to_biosequence.rb
#   - Unit test for Bio::Sequence::Adapter::FastaFormat
#
# Copyright::  Copyright (C) 2026
#               The BioRuby developers
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
require 'bio/db/fasta'
require 'bio/db/fasta/fasta_to_biosequence'

module Bio
  module TestFastaToBiosequenceData
    GI = '>gi|398365175|ref|NP_009718.3| Cdc28p [Saccharomyces cerevisiae S288c]'
    MULTI = ">gi|2495000|sp|Q63931|CCKR_CAVPO CCK-A RECEPTOR\001" \
            "gi|2147182|pir||I51898 receptor - guinea pig\001" \
            'gi|544724|gb|AAB29504.1| receptor [Cavia]'
    NOACC = '>localid only description'
    LOCUS = '>sce:YBR160W  CDC28; description'
  end # module TestFastaToBiosequenceData

  class TestFastaToBiosequenceGI < Test::Unit::TestCase
    def setup
      @bs = biosequence(TestFastaToBiosequenceData::GI)
    end

    def biosequence(defline)
      text = "#{defline}\nMSGE\n"
      Bio::FastaFormat.new(text).to_biosequence
    end

    def test_seq
      assert_equal('MSGE', @bs.seq)
    end

    def test_primary_accession
      assert_equal('NP_009718', @bs.primary_accession)
    end

    def test_secondary_accessions
      assert_equal([], @bs.secondary_accessions)
    end

    def test_entry_id
      assert_equal('NP_009718', @bs.entry_id)
    end

    def test_definition
      assert_equal('Cdc28p [Saccharomyces cerevisiae S288c]', @bs.definition)
    end

    def test_other_seqids
      assert_equal(1, @bs.other_seqids.size)
    end

    def test_other_seqids_database
      assert_equal('GI', @bs.other_seqids[0].database)
    end

    def test_other_seqids_id
      assert_equal('398365175', @bs.other_seqids[0].id)
    end
  end # class TestFastaToBiosequenceGI

  class TestFastaToBiosequenceMultiAccession < Test::Unit::TestCase
    def setup
      text = "#{TestFastaToBiosequenceData::MULTI}\nMSGE\n"
      @bs = Bio::FastaFormat.new(text).to_biosequence
    end

    def test_primary_accession
      assert_equal('Q63931', @bs.primary_accession)
    end

    def test_secondary_accessions
      assert_equal(['AAB29504'], @bs.secondary_accessions)
    end

    def test_entry_id
      assert_equal('Q63931', @bs.entry_id)
    end

    def test_definition
      assert_equal('CCK-A RECEPTOR', @bs.definition)
    end

    def test_other_seqids
      assert_equal(1, @bs.other_seqids.size)
    end
  end # class TestFastaToBiosequenceMultiAccession

  class TestFastaToBiosequenceNoAccession < Test::Unit::TestCase
    def setup
      text = "#{TestFastaToBiosequenceData::NOACC}\nMSGE\n"
      @bs = Bio::FastaFormat.new(text).to_biosequence
    end

    def test_primary_accession
      assert_equal('localid', @bs.primary_accession)
    end

    def test_secondary_accessions
      assert_nil(@bs.secondary_accessions)
    end

    def test_entry_id
      assert_equal('localid', @bs.entry_id)
    end

    def test_definition
      assert_equal('localid only description', @bs.definition)
    end

    def test_other_seqids
      assert_nil(@bs.other_seqids)
    end
  end # class TestFastaToBiosequenceNoAccession

  class TestFastaToBiosequenceLocus < Test::Unit::TestCase
    def setup
      text = "#{TestFastaToBiosequenceData::LOCUS}\nMSGE\n"
      @bs = Bio::FastaFormat.new(text).to_biosequence
    end

    def test_entry_id
      assert_equal('sce:YBR160W', @bs.entry_id)
    end

    def test_primary_accession
      assert_equal('sce:YBR160W', @bs.primary_accession)
    end

    def test_definition
      assert_equal('sce:YBR160W  CDC28; description', @bs.definition)
    end
  end # class TestFastaToBiosequenceLocus
end # module Bio
