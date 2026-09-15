# frozen_string_literal: true

#
# test/unit/bio/db/test_fantom.rb - Unit test for Bio::FANTOM::MaXML
#
# Copyright::  Copyright (C) 2026
#               The BioRuby developers
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'rexml/document'
require 'bio/db/fantom'

module Bio
  module TestFANTOMData
    SEQUENCES = <<~__END_OF_SEQUENCES__
      <?xml version="1.0"?>
      <maxml-sequences>
      <sequence id="seq1">
        <altid type="seqid">SEQID1</altid>
        <altid type="cloneid">CLONE1</altid>
        <altid type="fantomid">FANTOM1</altid>
        <altid type="rearrayid">REARRAY1</altid>
        <altid type="accession">ACC1</altid>
        <annotator>ann</annotator>
        <version>1.0</version>
        <modified_time>2003-01-01</modified_time>
        <comment>a comment</comment>
        <annotations>
          <annotation>
            <qualifier>cds_start</qualifier>
            <srckey>sk1</srckey>
            <anntext>10</anntext>
            <evidence>ev1</evidence>
            <datasrc href="http://example.org/x">db1</datasrc>
          </annotation>
          <annotation>
            <qualifier>cds_stop</qualifier>
            <anntext>100</anntext>
          </annotation>
          <annotation>
            <qualifier>gene_name</qualifier>
            <anntext>GENE1</anntext>
            <evidence>ev2</evidence>
            <datasrc href="http://example.org/y">db2</datasrc>
          </annotation>
        </annotations>
      </sequence>
      <sequence id="seq2">
        <altid type="seqid">SEQID2</altid>
      </sequence>
      </maxml-sequences>
    __END_OF_SEQUENCES__

    CLUSTER = <<~__END_OF_CLUSTER__
      <?xml version="1.0"?>
      <maxml-clusters>
      <cluster id="cl1">
        <representative-seqid>SEQID1</representative-seqid>
        <fantomid>FANTOM1</fantomid>
        <sequence id="seq1">
          <altid type="seqid">SEQID1</altid>
          <altid type="cloneid">CLONE1</altid>
          <annotations>
            <annotation>
              <qualifier>gene_name</qualifier>
              <anntext>GENE1</anntext>
            </annotation>
          </annotations>
        </sequence>
      </cluster>
      </maxml-clusters>
    __END_OF_CLUSTER__
  end # module TestFANTOMData

  class TestFANTOMMaXML < Test::Unit::TestCase
    def setup
      @ma = Bio::FANTOM::MaXML.new('')
    end

    def test_elem
      assert_kind_of(REXML::Document, @ma.elem)
    end

    def test_entry_id
      assert_nil(@ma.entry_id)
    end

    def test_to_s
      assert_kind_of(String, @ma.to_s)
    end

    def test_gsub_entities
      assert_equal('ABC', @ma.gsub_entities('&#65;BC'))
    end

    def test_gsub_entities_nil
      assert_nil(@ma.gsub_entities(nil))
    end

    def test_new_with_rexml_element
      elem = REXML::Document.new('<x id="a">text</x>').elements['x']
      ma = Bio::FANTOM::MaXML.new(elem)
      assert_equal('a', ma.entry_id)
    end

    def test_new_with_delimiter
      text = <<~__END_OF_TEXT__
        <maxml-sequences>
        <sequence id="s1"><altid type="seqid">A</altid></sequence>
        </maxml-sequences>
        --EOF--
      __END_OF_TEXT__
      seqs = Bio::FANTOM::MaXML::Sequences.new(text)
      assert_equal('A', seqs[0].seqid)
    end
  end # class TestFANTOMMaXML

  class TestFANTOMMaXMLSequence < Test::Unit::TestCase
    def setup
      seqs = Bio::FANTOM::MaXML::Sequences.new(TestFANTOMData::SEQUENCES)
      @seq = seqs[0]
    end

    def test_entry_id
      assert_equal('seq1', @seq.entry_id)
    end

    def test_altid
      assert_equal('SEQID1', @seq.altid['seqid'])
    end

    def test_altid_with_arg
      assert_equal('CLONE1', @seq.altid('cloneid'))
    end

    def test_altid_missing_type
      assert_nil(@seq.altid('nosuch'))
    end

    def test_id_strings
      expected = %w[ACC1 CLONE1 FANTOM1 REARRAY1 SEQID1]
      assert_equal(expected, @seq.id_strings)
    end

    def test_library_id
      assert_equal('se', @seq.library_id)
    end

    def test_seqid
      assert_equal('SEQID1', @seq.seqid)
    end

    def test_fantomid
      assert_equal('FANTOM1', @seq.fantomid)
    end

    def test_cloneid
      assert_equal('CLONE1', @seq.cloneid)
    end

    def test_rearrayid
      assert_equal('REARRAY1', @seq.rearrayid)
    end

    def test_accession
      assert_equal('ACC1', @seq.accession)
    end

    def test_annotator
      assert_equal('ann', @seq.annotator)
    end

    def test_version
      assert_equal('1.0', @seq.version)
    end

    def test_modified_time
      assert_equal('2003-01-01', @seq.modified_time)
    end

    def test_comment
      assert_equal('a comment', @seq.comment)
    end

    def test_annotations
      assert_instance_of(Bio::FANTOM::MaXML::Annotations, @seq.annotations)
    end
  end # class TestFANTOMMaXMLSequence

  class TestFANTOMMaXMLSequenceFallback < Test::Unit::TestCase
    def setup
      seqs = Bio::FANTOM::MaXML::Sequences.new(TestFANTOMData::SEQUENCES)
      @seq = seqs[1]
    end

    def test_seqid_from_altid
      assert_equal('SEQID2', @seq.seqid)
    end

    def test_fantomid_is_nil
      assert_nil(@seq.fantomid)
    end
  end # class TestFANTOMMaXMLSequenceFallback

  class TestFANTOMMaXMLSequences < Test::Unit::TestCase
    def setup
      @seqs = Bio::FANTOM::MaXML::Sequences.new(TestFANTOMData::SEQUENCES)
    end

    def test_to_a
      assert_equal(2, @seqs.to_a.size)
    end

    def test_each
      count = 0
      @seqs.each { |_x| count += 1 }
      assert_equal(2, count)
    end

    def test_get_by_id
      assert_equal('seq1', @seqs.get('SEQID1').entry_id)
    end

    def test_get_by_id_not_found
      assert_nil(@seqs.get('NOSUCH'))
    end

    def test_get_caches_result
      assert_nil(@seqs.get('NOSUCH'))
      assert_nil(@seqs.get('NOSUCH'))
    end

    def test_aref_with_string
      assert_equal('seq1', @seqs['SEQID1'].entry_id)
    end

    def test_aref_with_integer
      assert_equal('seq2', @seqs[1].entry_id)
    end

    def test_cloneids
      assert_equal(['CLONE1', nil], @seqs.cloneids)
    end

    def test_id_strings
      expected = %w[ACC1 CLONE1 FANTOM1 REARRAY1 SEQID1 SEQID2]
      assert_equal(expected, @seqs.id_strings)
    end
  end # class TestFANTOMMaXMLSequences

  class TestFANTOMMaXMLCluster < Test::Unit::TestCase
    def setup
      @cluster = Bio::FANTOM::MaXML::Cluster.new(TestFANTOMData::CLUSTER)
    end

    def test_entry_id
      assert_equal('cl1', @cluster.entry_id)
    end

    def test_fantomid
      assert_equal('FANTOM1', @cluster.fantomid)
    end

    def test_representative_seqid
      assert_equal('SEQID1', @cluster.representative_seqid)
    end

    def test_representative_sequence
      assert_equal('seq1', @cluster.representative_sequence.entry_id)
    end

    def test_representative_clone
      assert_equal('seq1', @cluster.representative_clone.entry_id)
    end

    def test_representative_cloneid
      assert_equal('CLONE1', @cluster.representative_cloneid)
    end

    def test_representative_annotations
      assert_equal('GENE1', @cluster.representative_annotations.gene_name)
    end

    def test_sequence_with_id
      assert_equal('seq1', @cluster.sequence('SEQID1').entry_id)
    end

    def test_sequence_without_id
      assert_equal('seq1', @cluster.sequence.entry_id)
    end

    def test_sequences
      assert_equal(1, @cluster.sequences.to_a.size)
    end
  end # class TestFANTOMMaXMLCluster

  class TestFANTOMMaXMLAnnotations < Test::Unit::TestCase
    def setup
      seqs = Bio::FANTOM::MaXML::Sequences.new(TestFANTOMData::SEQUENCES)
      @ann = seqs[0].annotations
    end

    def test_to_a
      assert_equal(3, @ann.to_a.size)
    end

    def test_each
      count = 0
      @ann.each { |_x| count += 1 }
      assert_equal(3, count)
    end

    def test_cds_start
      assert_equal(10, @ann.cds_start)
    end

    def test_cds_stop
      assert_equal(100, @ann.cds_stop)
    end

    def test_gene_name
      assert_equal('GENE1', @ann.gene_name)
    end

    def test_data_source
      assert_equal('db2', @ann.data_source)
    end

    def test_evidence
      assert_equal('ev2', @ann.evidence)
    end

    def test_get_by_qualifier
      assert_equal('GENE1', @ann.get_by_qualifier('gene_name').anntext)
    end

    def test_get_by_qualifier_missing
      assert_nil(@ann.get_by_qualifier('nosuch'))
    end

    def test_get_all_by_qualifier
      assert_equal(1, @ann.get_all_by_qualifier('gene_name').size)
    end

    def test_aref_with_string
      assert_equal('gene_name', @ann['gene_name'].qualifier)
    end

    def test_aref_with_integer
      assert_equal('cds_start', @ann[0].qualifier)
    end
  end # class TestFANTOMMaXMLAnnotations

  class TestFANTOMMaXMLAnnotation < Test::Unit::TestCase
    def setup
      seqs = Bio::FANTOM::MaXML::Sequences.new(TestFANTOMData::SEQUENCES)
      @gene = seqs[0].annotations['gene_name']
    end

    def test_entry_id
      assert_nil(@gene.entry_id)
    end

    def test_qualifier
      assert_equal('gene_name', @gene.qualifier)
    end

    def test_anntext
      assert_equal('GENE1', @gene.anntext)
    end

    def test_evidence
      assert_equal('ev2', @gene.evidence)
    end

    def test_srckey
      assert_nil(@gene.srckey)
    end

    def test_datasrc
      assert_equal(1, @gene.datasrc.size)
    end

    def test_datasrc_text
      assert_equal('db2', @gene.datasrc[0].to_s)
    end

    def test_datasrc_href
      assert_equal('http://example.org/y', @gene.datasrc[0].href)
    end
  end # class TestFANTOMMaXMLAnnotation
end # module Bio
