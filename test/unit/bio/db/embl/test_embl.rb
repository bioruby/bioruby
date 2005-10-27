#
# test/unit/bio/db/embl/test_embl.rb - Unit test for Bio::EMBL
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: test_embl.rb,v 1.2 2005/10/27 09:38:12 nakao Exp $
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
      output = File.open(File.join(bioruby_root, 'test', 'data', 'embl', 'AB090716.embl')).read
      @obj = Bio::EMBL.new(output)
    end

    def test_id_line
      assert(@obj.id_line)
    end

    def test_id_line_iterator
      assert(@obj.id_line {|key, value| })
    end

    def test_id_line_entry_name
      assert_equal(@obj.id_line('ENTRY_NAME'), 'AB090716')
    end

    def test_id_line_data_class
      assert_equal(@obj.id_line('DATA_CLASS'), 'standard')
    end

    def test_id_line_molecule_type
      assert_equal(@obj.id_line('MOLECULE_TYPE'), 'genomic DNA')
    end

    def test_id_line_division
      assert_equal(@obj.id_line('DIVISION'), 'VRT')
    end

    def test_id_line_sequence_length
      assert_equal(@obj.id_line('SEQUENCE_LENGTH'), 166)
    end
    
    def test_entry
      entry_id = 'AB090716'
      assert_equal(@obj.entry, entry_id)
      assert_equal(@obj.entry_name, entry_id)
      assert_equal(@obj.entry_id, entry_id)
    end

    def test_molecule
      molecule = 'genomic DNA'
      assert_equal(@obj.molecule, molecule)
      assert_equal(@obj.molecule_type, molecule)
    end

    def test_division
      assert_equal(@obj.division, 'VRT')
    end
    
    def test_sequence_length
      seqlen = 166
      assert_equal(@obj.sequence_length, seqlen)
      assert_equal(@obj.seqlen, seqlen)
    end

    # Bio::EMBLDB::COMMON#ac
    def test_ac 
      ac = ['AB090716']
      assert_equal(@obj.ac, ac)
      assert_equal(@obj.accessions, ac)
    end

    # Bio::EMBLDB::COMMON#accession
    def test_accession
      assert_equal(@obj.accession, 'AB090716')
    end

    def test_sv
      assert_equal(@obj.sv, 'AB090716.1')
    end

    def test_version
      assert_equal(@obj.version, 1)
    end

    def test_dt
      assert(@obj.dt)
    end

    def test_dt_iterator
      assert(@obj.dt {|key, value| })
    end

    def test_dt_created
      assert_equal(@obj.dt('created'), '25-OCT-2002 (Rel. 73, Created)')
    end

    def test_dt_updated
      assert_equal(@obj.dt('updated'), '29-NOV-2002 (Rel. 73, Last updated, Version 2)')
    end

    # Bio::EMBLDB::COMMON#de
    def test_de
      assert_equal(@obj.de, "Haplochromis sp. 'muzu, rukwa' LWS gene for long wavelength-sensitive opsin, partial cds, specimen_voucher:specimen No. HT-9361.")
    end

    # Bio::EMBLDB::COMMON#kw
    def test_kw 
      k = []
      assert_equal(@obj.kw, [])
      assert_equal(@obj.keywords, [])
    end

    def test_os
#      assert_equal(@obj.os, '')
      assert_raises(RuntimeError) { @obj.os }
    end

    def test_os_valid
      @obj.instance_eval { @data['OS'] = "Haplochromis sp. 'muzu rukwa'" }
      assert_equal(@obj.os, "Haplochromis sp. 'muzu rukwa'")
    end

    # Bio::EMBLDB::COMMON#oc
    def test_oc 
      assert_equal(@obj.oc.first, 'Eukaryota')
    end

    # Bio::EMBLDB::COMMON#og
    def test_og 
      assert_equal(@obj.og, [])
    end

    # Bio::EMBLDB::COMMON#ref
    def test_ref
      assert_equal(@obj.ref.size, 2)
    end

    # Bio::EMBLDB::COMMON#references
    def test_references 
      assert_equal(@obj.references.class, Bio::References)
    end

    # Bio::EMBLDB::COMMON#dr
    def test_dr
      assert_equal(@obj.dr, {})
    end

    def test_fh
      assert_equal(@obj.fh, 'Key Location/Qualifiers')
    end

    def test_ft
      assert_equal(@obj.ft.class, Bio::Features)
    end

    def test_ft_iterator
      @obj.ft.each do |feature|
        assert_equal(feature.class, Bio::Feature)
      end
    end

    def test_ft_accessor
      assert_equal(@obj.ft.features[1].feature, 'CDS')
    end

    def test_each_cds
      @obj.each_cds do |x|
        assert_equal(x.feature, 'CDS')
      end
    end

    def test_each_gene
      @obj.each_gene do |x| 
        assert_equal(x.feature, 'gene')
      end
    end

    def test_cc
      assert_equal(@obj.cc, '')
    end

#    def test_xx
#    end

    def test_sq
      data = {"a"=>29, "c"=>42, "ntlen"=>166, "g"=>41, "t"=>54, "other"=>0}
      assert_equal(@obj.sq, data)
    end

    def test_sq_get
      assert_equal(@obj.sq("a"), 29)
    end

    def test_seq
      seq = 'gttctggcctcatggactgaagacttcctgtggacctgatgtgttcagtggaagtgaagaccctggagtacagtcctacatgattgttctcatgattacttgctgtttcatccccctggctatcatcatcctgtgctaccttgctgtgtggatggccatccgtgct'
      assert_equal(@obj.seq, seq)
      assert_equal(@obj.naseq, seq)
      assert_equal(@obj.ntseq, seq)
    end
  end
end
