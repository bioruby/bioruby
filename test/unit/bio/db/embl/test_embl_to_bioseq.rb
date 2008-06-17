#
# test/unit/bio/db/embl/test_embl.rb - Unit test for Bio::EMBL
#
# Copyright::  Copyright (C) 2005, 2008
#                 Mitsuteru Nakao <n@bioruby.org>
#                 Jan Aerts <jan.aerts@bbsrc.ac.uk>
# License::    The Ruby License
#
#  $Id: test_embl_to_bioseq.rb,v 1.1.2.2 2008/06/17 16:09:53 ngoto Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio'
require 'bio/db/embl/embl'

module Bio
  class TestEMBLToBioSequence < Test::Unit::TestCase
    
    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      input = File.open(File.join(bioruby_root, 'test', 'data', 'embl', 'AB090716.embl.rel89')).read
      embl_object = Bio::EMBL.new(input)
      embl_object.instance_eval { @data['OS'] = "Haplochromis sp. 'muzu rukwa'" }
      @bio_seq = embl_object.to_biosequence
    end

    def test_entry_id
      assert_equal('AB090716', @bio_seq.entry_id)
    end
    
    def test_primary_accession
      assert_equal('AB090716', @bio_seq.primary_accession)
    end
    
    def test_secondary_accessions
      assert_equal([], @bio_seq.secondary_accessions)
    end
    
    def test_molecule_type
      assert_equal('genomic DNA', @bio_seq.molecule_type)
    end
    
    def test_definition
      assert_equal("Haplochromis sp. 'muzu, rukwa' LWS gene for long wavelength-sensitive opsin, partial cds, specimen_voucher:specimen No. HT-9361.", @bio_seq.definition)
    end

    def test_topology
      assert_equal('linear', @bio_seq.topology)
    end
    
    def test_date_created
      # '25-OCT-2002 (Rel. 73, Created)'
      assert_equal(Date.parse('25-OCT-2002'), @bio_seq.date_created)
    end

    def test_date_modified
      # '14-NOV-2006 (Rel. 89, Last updated, Version 3)'
      assert_equal(Date.parse('14-NOV-2006'), @bio_seq.date_modified)
    end

    def test_release_created
      assert_equal('73', @bio_seq.release_created)
    end

    def test_release_modified
      assert_equal('89', @bio_seq.release_modified)
    end

    def test_entry_version
      assert_equal('3', @bio_seq.entry_version)
    end
    
    def test_division
      assert_equal('VRT', @bio_seq.division)
    end
    
    def test_sequence_version
      assert_equal(1, @bio_seq.sequence_version)
    end
    
    def test_keywords
      assert_equal([], @bio_seq.keywords)
    end
    
    def test_species
      assert_equal("Haplochromis sp. 'muzu, rukwa'", @bio_seq.species)
    end
    
    def test_classification
      assert_equal(['Eukaryota','Metazoa','Chordata','Craniata','Vertebrata','Euteleostomi','Actinopterygii','Neopterygii','Teleostei','Euteleostei','Neoteleostei','Acanthomorpha','Acanthopterygii','Percomorpha','Perciformes','Labroidei','Cichlidae','African cichlids','Pseudocrenilabrinae','Haplochromini','Haplochromis'], @bio_seq.classification)
      

    end

    def test_references
      assert_equal(2, @bio_seq.references.length)
      assert_equal(Bio::Reference, @bio_seq.references[0].class)
    end
    
    def test_features
      assert_equal(3, @bio_seq.features.length)
      assert_equal(Bio::Feature, @bio_seq.features[0].class)
    end
    
  end

  # To really test the Bio::EMBL to Bio::Sequence conversion, we need to test if
  # that Bio::Sequence can be made into a valid Bio::EMBL again.
  class TestEMBLToBioSequenceRoundTrip < Test::Unit::TestCase
    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      input = File.open(File.join(bioruby_root, 'test', 'data', 'embl', 'AB090716.embl.rel89')).read
      embl_object_1 = Bio::EMBL.new(input)
      embl_object_1.instance_eval { @data['OS'] = "Haplochromis sp. 'muzu rukwa'" }
      @bio_seq_1 = embl_object_1.to_biosequence
      embl_object_2 = Bio::EMBL.new(@bio_seq_1.output(:embl))
      @bio_seq_2 = embl_object_2.to_biosequence
    end
    
    def test_entry_id
      assert_equal('AB090716', @bio_seq_2.entry_id)
    end
    
    def test_primary_accession
      assert_equal('AB090716', @bio_seq_2.primary_accession)
    end
    
    def test_secondary_accessions
      assert_equal([], @bio_seq_2.secondary_accessions)
    end
    
    def test_molecule_type
      assert_equal('genomic DNA', @bio_seq_2.molecule_type)
    end
    
    def test_definition
      assert_equal("Haplochromis sp. 'muzu, rukwa' LWS gene for long wavelength-sensitive opsin, partial cds, specimen_voucher:specimen No. HT-9361.", @bio_seq_2.definition)
    end

    def test_topology
      assert_equal('linear', @bio_seq_2.topology)
    end
    
    def test_date_created
      # '25-OCT-2002 (Rel. 73, Created)'
      assert_equal(Date.parse('25-OCT-2002'), @bio_seq_2.date_created)
    end

    def test_date_modified
      # '14-NOV-2006 (Rel. 89, Last updated, Version 3)'
      assert_equal(Date.parse('14-NOV-2006'), @bio_seq_2.date_modified)
    end

    def test_release_created
      assert_equal('73', @bio_seq_2.release_created)
    end

    def test_release_modified
      assert_equal('89', @bio_seq_2.release_modified)
    end

    def test_entry_version
      assert_equal('3', @bio_seq_2.entry_version)
    end
    
    def test_division
      assert_equal('VRT', @bio_seq_2.division)
    end
    
    def test_sequence_version
      assert_equal(1, @bio_seq_2.sequence_version)
    end
    
    def test_keywords
      assert_equal([], @bio_seq_2.keywords)
    end
    
    def test_species
      assert_equal("Haplochromis sp. 'muzu, rukwa'", @bio_seq_2.species)
    end
    
    def test_classification
      assert_equal(['Eukaryota','Metazoa','Chordata','Craniata','Vertebrata','Euteleostomi','Actinopterygii','Neopterygii','Teleostei','Euteleostei','Neoteleostei','Acanthomorpha','Acanthopterygii','Percomorpha','Perciformes','Labroidei','Cichlidae','African cichlids','Pseudocrenilabrinae','Haplochromini','Haplochromis'], @bio_seq_2.classification)
      

    end

    def test_references
      assert_equal(2, @bio_seq_2.references.length)
      assert_equal(Bio::Reference, @bio_seq_2.references[0].class)
    end
    
    def test_features a
      assert_equal(3, @bio_seq_2.features.length)
      assert_equal(Bio::Feature, @bio_seq_2.features[0].class)
    end
  end
end

