#
# test/unit/bio/db/embl/test_embl_rel89.rb - Unit test for Bio::EMBL
#
# Copyright::  Copyright (C) 2007 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_embl_rel89.rb,v 1.2 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/db/embl/embl'

module Bio
  class TestEMBL < Test::Unit::TestCase
    
    def setup
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      output = File.open(File.join(bioruby_root, 'test', 'data', 'embl', 'AB090716.embl.rel89')).read
      @obj = Bio::EMBL.new(output)
    end

    # http://www.ebi.ac.uk/embl/Documentation/User_manual/usrman.html#s_3_4_1
    def test_id_line
      assert(@obj.id_line)
    end

    def test_id_line_iterator
      assert(@obj.id_line {|key, value| })
    end

    def test_id_line_entry_name
      assert_equal('AB090716', @obj.id_line('ENTRY_NAME'))
    end

    def test_id_line_data_class
      assert_equal('STD', @obj.id_line('DATA_CLASS'))
    end

    def test_id_line_sequence_version
      assert_equal('1', @obj.id_line('SEQUENCE_VERSION'))
    end

    def test_id_line_molecule_type
      assert_equal('genomic DNA', @obj.id_line('MOLECULE_TYPE'))
    end

    def test_id_line_division
      assert_equal('VRT', @obj.id_line('DIVISION'))
    end

    def test_id_line_sequence_length
      assert_equal(166, @obj.id_line('SEQUENCE_LENGTH'))
    end
    
    def test_entry
      entry_id = 'AB090716'
      assert_equal(entry_id, @obj.entry)
      assert_equal(entry_id, @obj.entry_name)
      assert_equal(entry_id, @obj.entry_id)
    end

    def test_molecule
      molecule = 'genomic DNA'
      assert_equal(molecule, @obj.molecule)
      assert_equal(molecule, @obj.molecule_type)
    end

    def test_division
      assert_equal('VRT', @obj.division)
    end
    
    def test_sequence_length
      seqlen = 166
      assert_equal(seqlen, @obj.sequence_length)
      assert_equal(seqlen, @obj.seqlen)
    end

    # Bio::EMBLDB::COMMON#ac
    def test_ac 
      ac = ['AB090716']
      assert_equal(ac, @obj.ac)
      assert_equal(ac, @obj.accessions)
    end

    # Bio::EMBLDB::COMMON#accession
    def test_accession
      assert_equal('AB090716', @obj.accession)
    end

    def test_sv
      assert_equal('AB090716.1', @obj.sv)
    end

    def test_version
      assert_equal(1, @obj.version)
    end

    def test_dt
      assert(@obj.dt)
    end

    def test_dt_iterator
      assert(@obj.dt {|key, value| })
    end

    def test_dt_created
      assert_equal('25-OCT-2002 (Rel. 73, Created)', @obj.dt('created'))
    end

    def test_dt_updated
      assert_equal('14-NOV-2006 (Rel. 89, Last updated, Version 3)', @obj.dt('updated'))
    end

    # Bio::EMBLDB::COMMON#de
    def test_de
      assert_equal("Haplochromis sp. 'muzu, rukwa' LWS gene for long wavelength-sensitive opsin, partial cds, specimen_voucher:specimen No. HT-9361.", @obj.de)
    end

    # Bio::EMBLDB::COMMON#kw
    def test_kw 
      k = []
      assert_equal([], @obj.kw)
      assert_equal([], @obj.keywords)
    end

    def test_os
#      assert_equal('', @obj.os)
      assert_raises(RuntimeError) { @obj.os }
    end

    def test_os_valid
      @obj.instance_eval { @data['OS'] = "Haplochromis sp. 'muzu rukwa'" }
      assert_equal("Haplochromis sp. 'muzu rukwa'", @obj.os)
    end

    # Bio::EMBLDB::COMMON#oc
    def test_oc 
      assert_equal('Eukaryota', @obj.oc.first)
    end

    # Bio::EMBLDB::COMMON#og
    def test_og 
      assert_equal([], @obj.og)
    end

    # Bio::EMBLDB::COMMON#ref
    def test_ref
      assert_equal(2, @obj.ref.size)
    end

    # Bio::EMBLDB::COMMON#references
    def test_references 
      assert_equal(Bio::References, @obj.references.class)
    end

    # Bio::EMBLDB::COMMON#dr
    def test_dr
      assert_equal({}, @obj.dr)
    end

    def test_fh
      assert_equal('Key Location/Qualifiers', @obj.fh)
    end

    def test_ft
      assert_equal(Bio::Features, @obj.ft.class)
    end

    def test_ft_iterator
      @obj.ft.each do |feature|
        assert_equal(Bio::Feature, feature.class)
      end
    end

    def test_ft_accessor
      assert_equal('CDS', @obj.ft.features[1].feature)
    end

    def test_each_cds
      @obj.each_cds do |x|
        assert_equal('CDS', x.feature)
      end
    end

    def test_each_gene
      @obj.each_gene do |x| 
        assert_equal('gene', x.feature)
      end
    end

    def test_cc
      assert_equal('', @obj.cc)
    end

#    def test_xx
#    end

    def test_sq
      data = {"a"=>29, "c"=>42, "ntlen"=>166, "g"=>41, "t"=>54, "other"=>0}
      assert_equal(data, @obj.sq)
    end

    def test_sq_get
      assert_equal(29, @obj.sq("a"))
    end

    def test_seq
      seq = 'gttctggcctcatggactgaagacttcctgtggacctgatgtgttcagtggaagtgaagaccctggagtacagtcctacatgattgttctcatgattacttgctgtttcatccccctggctatcatcatcctgtgctaccttgctgtgtggatggccatccgtgct'
      assert_equal(seq, @obj.seq)
      assert_equal(seq, @obj.naseq)
      assert_equal(seq, @obj.ntseq)
    end
  end
end
