#
# test/unit/bio/db/embl/test_uniprot.rb - Unit test for Bio::UniProt
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
#  $Id: test_uniprot.rb,v 1.2 2005/11/23 10:12:09 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/embl/uniprot'

module Bio
  class TestUniProt < Test::Unit::TestCase

    def setup
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      data = File.open(File.join(bioruby_root, 'test', 'data', 'uniprot', 'p53_human.uniprot')).read
      @obj = Bio::UniProt.new(data)
    end

    def test_id_line
      assert(@obj.id_line)
    end
    def test_id_line_entry_name
      assert_equal('P53_HUMAN', @obj.id_line('ENTRY_NAME'))
    end   
    def test_id_line_data_class
      assert_equal('STANDARD', @obj.id_line('DATA_CLASS'))
    end
    def test_id_line_molecule_type
      assert_equal('PRT', @obj.id_line('MOLECULE_TYPE'))
    end
    def test_id_line_sequence_length
      assert_equal(393, @obj.id_line('SEQUENCE_LENGTH'))
    end


    def test_ac
      assert_equal([], @obj.ac)
      assert_equal([], @obj.acccessions)
    end
    def test_accession
      assert_equal('', @obj.accession)
    end

    def test_de
      assert(@obj.de)
    end

    def test_protein_name
      assert_equal("Cellular tumor antigen p53", @obj.protein_name)
    end

    def test_synonyms
      assert_equal(["Tumor suppressor p53", "Phosphoprotein p53", "Antigen NY-CO-13"], @obj.synonyms)
    end

    def test_gn
      assert_equal([{:orfs=>[], :synonyms=>["P53"], :name=>"TP53", :loci=>[]}], @obj.gn)
    end
    def test_gn_uniprot_parser
      gn_uniprot_data = ''
      assert_equal('', @obj.instance_eval(gn_uniprot_parser(gn_uniprot_data)))
    end
#     def test_gn_old_parser
#       gn_old_data = ''
#       assert_equal('', @obj.instance_eval(gn_old_parser(gn_old_data)))
#     end

    def test_gene_names
      assert_equal(["TP53"], @obj.gene_names)
    end

    def test_gene_name
      assert_equal('TP53', @obj.gene_name)
    end

    def test_os
      assert(@obj.os)
    end

    def test_os_access
      assert_equal({'name' => '', 'os' => ''}, @obj.os(1))
    end

    def test_os_access2
      assert_equal({}, @obj.os[1])
    end


    def test_cc
      data = ''
      assert_equal('', @obj.instance_eval(cc_scan_alternative_products(data)))
      data = ''
      assert_equal('', @obj.instance_eval(cc_scan_database(data)))
      data = ''
      assert_equal('', @obj.instance_eval(cc_scan_mass_spectorometry(data)))

      assert_equal([], @obj.cc)
    end
    def test_cc_database
      assert_equal([], @obj.cc('DATABASE'))
    end
    def test_cc_alternative_products
      assert_equal({}, @obj.cc('ALTERNATIVE PRODUCTS'))
    end
    def test_cc_mass_spectrometry
      assert_equal([], @obj.cc('MASS SPECTROMETRY'))
    end

    def test_cc_interaction
      data =<<END
CC   -!- INTERACTION:
CC       P46527:CDKN1B; NbExp=1; IntAct=EBI-359815, EBI-519280;
CC       Q99759:MAP3K3; NbExp=1; IntAct=EBI-359815, EBI-307281;
CC       P04049:RAF1; NbExp=4; IntAct=EBI-359815, EBI-365996;
END
      @obj.instance_eval('@orig["CC"] = "#{data}"')
      assert_equal('', @obj.cc('INTERACTION'))
    end


    def test_kw
    end
    
    def test_ft
      assert(@obj.ft)
      name = 'DNA_BIND'
      assert_equal([], @obj.ft(name))
    end

    def test_sq_mw
      mw = 43653
      assert_equal(mw, @obj.sq('mw'))
      assert_equal(mw, @obj.sq('molecular'))
      assert_equal(mw, @obj.sq('weight'))
    end

    def test_sq_len
      length = 393
      assert_equal(length, @obj.sq('len'))
      assert_equal(length, @obj.sq('length'))
      assert_equal(length, @obj.sq('AA'))
    end

    def test_seq
      seq = 'MEEPQSDPSVEPPLSQETFSDLWKLLPENNVLSPLPSQAMDDLMLSPDDIEQWFTEDPGPDEAPRMPEAAPPVAPAPAAPTPAAPAPAPSWPLSSSVPSQKTYQGSYGFRLGFLHSGTAKSVTCTYSPALNKMFCQLAKTCPVQLWVDSTPPPGTRVRAMAIYKQSQHMTEVVRRCPHHERCSDSDGLAPPQHLIRVEGNLRVEYLDDRNTFRHSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNRRPILTIITLEDSSGNLLGRNSFEVRVCACPGRDRRTEEENLRKKGEPHHELPPGSTKRALPNNTSSSPQPKKKPLDGEYFTLQIRGRERFEMFRELNEALELKDAQAGKEPGGSRAHSSHLKSKKGQSTSRHKKLMFKTEGPDSD'
      assert_equal(seq, @obj.seq)
      assert_equal(seq, @obj.aaseq)
    end
  end
end
