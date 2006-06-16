#
# test/unit/bio/db/embl/test_sptr.rb - Unit test for Bio::SPTR
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
#  $Id: test_sptr.rb,v 1.3 2006/06/16 16:51:05 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/embl/sptr'

module Bio
  class TestSPTR < Test::Unit::TestCase

    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      data = File.open(File.join(bioruby_root, 'test', 'data', 'uniprot', 'p53_human.uniprot')).read
      @obj = Bio::SPTR.new(data)
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

    def test_entry
      entry = 'P53_HUMAN'
      assert_equal(entry, @obj.entry)
      assert_equal(entry, @obj.entry_name)
      assert_equal(entry, @obj.entry_id)
    end

    def test_molecule
      assert_equal('PRT', @obj.molecule)
      assert_equal('PRT', @obj.molecule_type)
    end

    def test_sequence_length
      seqlen = 393
      assert_equal(seqlen, @obj.sequence_length)
      assert_equal(seqlen, @obj.aalen)
    end

    def test_ac
      acs = ["P04637", "Q15086", "Q15087", "Q15088", "Q16535", "Q16807", "Q16808", "Q16809", "Q16810", "Q16811", "Q16848", "Q86UG1", "Q8J016", "Q99659", "Q9BTM4", "Q9HAQ8", "Q9NP68", "Q9NPJ2", "Q9NZD0", "Q9UBI2", "Q9UQ61"]
      assert_equal(acs, @obj.ac)
      assert_equal(acs, @obj.accessions)
    end

    def test_accession
      assert_equal('P04637', @obj.accession)
    end

    def test_dt
      assert(@obj.dt)
    end

    def test_dt_created
      assert_equal('13-AUG-1987 (Rel. 05, Created)', @obj.dt('created'))
    end

    def test_dt_sequence
      assert_equal('01-MAR-1989 (Rel. 10, Last sequence update)', @obj.dt('sequence'))
    end

    def test_dt_annotation
      assert_equal('13-SEP-2005 (Rel. 48, Last annotation update)', @obj.dt('annotation'))
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
      assert_equal([{:orfs=>[], :loci=>[], :name=>"TP53", :synonyms=>["P53"]}], @obj.instance_eval("gn_uniprot_parser"))
    end

    def test_gn_old_parser
      gn_old_data = ''
      assert_equal([["Name=TP53; Synonyms=P53;"]], @obj.instance_eval("gn_old_parser"))
    end

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
      assert_equal("Homo sapiens (Human)", @obj.os(0))
    end

    def test_os_access2
      assert_equal({"name"=>"(Human)", "os"=>"Homo sapiens"}, @obj.os[0])
    end

    def test_og_1
      og = "OG   Plastid; Chloroplast."
      ary = ['Plastid', 'Chloroplast']
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(ary, @obj.og)
    end

    def test_og_2
      og = "OG   Mitochondrion."
      ary = ['Mitochondrion']
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(ary, @obj.og)
    end

    def test_og_3
      og = "OG   Plasmid sym pNGR234a."
      ary = ["Plasmid sym pNGR234a"]
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(ary, @obj.og)
    end

    def test_og_4
      og = "OG   Plastid; Cyanelle."
      ary = ['Plastid', 'Cyanelle']
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(ary, @obj.og)
    end

    def test_og_5
      og = "OG   Plasmid pSymA (megaplasmid 1)." 
      ary = ["Plasmid pSymA (megaplasmid 1)"]
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(ary, @obj.og)
    end

    def test_og_6
      og = "OG   Plasmid pNRC100, Plasmid pNRC200, and Plasmid pHH1." 
      ary = ['Plasmid pNRC100', 'Plasmid pNRC200', 'Plasmid pHH1']
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(ary, @obj.og)
    end

    def test_oc
      assert_equal(["Eukaryota", "Metazoa", "Chordata", "Craniata", "Vertebrata", "Euteleostomi", "Mammalia", "Eutheria", "Euarchontoglires", "Primates", "Catarrhini", "Hominidae", "Homo"], @obj.oc)
    end

    def test_ox
      assert_equal({"NCBI_TaxID"=>["9606"]}, @obj.ox)
    end

    def test_ref # Bio::EMBL::COMMON#ref
      @obj.ref
    end

    def test_cc
      assert_equal(Hash, @obj.cc.class)
    end
   
    def test_cc_database
      db = [{"NAME"=>"IARC TP53 mutation database", "WWW"=>"http://www.iarc.fr/p53/", "FTP"=>nil, "NOTE"=>"IARC db of somatic p53 mutations"},
            {"NAME"=>"Tokyo p53", "WWW"=>"http://p53.genome.ad.jp/", "FTP"=>nil, "NOTE"=>"University of Tokyo db of p53 mutations"},
            {"NAME"=>"p53 web site at the Institut Curie", "WWW"=>"http://p53.curie.fr/", "FTP"=>nil, "NOTE"=>nil},
            {"NAME"=>"Atlas Genet. Cytogenet. Oncol. Haematol.", "WWW"=>"http://www.infobiogen.fr/services/chromcancer/Genes/P53ID88.html", "FTP"=>nil, "NOTE"=>nil}]
      assert_equal(db, @obj.cc('DATABASE'))
    end

    def test_cc_alternative_products
      ap = {"Comment"=>nil, "Named isoforms"=>"2", "Variants"=>  [{"IsoId"=>"P04637-1", "Name"=>"1", "Sequence"=>["Displayed"]},
                                                                  {"IsoId"=>"P04637-2", "Name"=>"2", "Synonyms"=>"I9RET", "Sequence"=>["VSP_006535", "VSP_006536"]}],
            "Event"=>"Alternative splicing"}
      assert_equal(ap, @obj.cc('ALTERNATIVE PRODUCTS'))
    end

    def test_cc_mass_spectrometry
      assert_equal(nil, @obj.cc('MASS SPECTROMETRY'))
    end



    def test_kw
      keywords = ["3D-structure", "Acetylation", "Activator", "Alternative splicing", "Anti-oncogene", "Apoptosis", "Cell cycle", "Disease mutation", "DNA-binding", "Glycoprotein", "Li-Fraumeni syndrome", "Metal-binding", "Nuclear protein", "Phosphorylation", "Polymorphism", "Transcription", "Transcription regulation", "Zinc"]
      assert_equal(keywords, @obj.kw)
    end
    
    def test_ft
      assert(@obj.ft)
      name = 'DNA_BIND'
      assert_equal([{"FTId"=>"", "From"=>102, "diff"=>[], "To"=>292, "Description"=>""}], @obj.ft(name))
      assert_equal([{"FTId"=>"", "From"=>102, "diff"=>[], "To"=>292, "Description"=>""}], @obj.ft[name])
    end

    def test_sq
      assert_equal({"CRC64"=>"AD5C149FD8106131", "aalen"=>393, "MW"=>43653}, @obj.sq)
    end

    def test_sq_crc64
      assert_equal("AD5C149FD8106131", @obj.sq('CRC64'))
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
