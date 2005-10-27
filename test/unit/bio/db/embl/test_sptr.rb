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
#  $Id: test_sptr.rb,v 1.1 2005/10/27 09:28:43 nakao Exp $
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
      assert_equal(@obj.id_line('ENTRY_NAME'), 'P53_HUMAN')
    end   

    def test_id_line_data_class
      assert_equal(@obj.id_line('DATA_CLASS'), 'STANDARD')
    end

    def test_id_line_molecule_type
      assert_equal(@obj.id_line('MOLECULE_TYPE'), 'PRT')
    end

    def test_id_line_sequence_length
      assert_equal(@obj.id_line('SEQUENCE_LENGTH'), 393)
    end

    def test_entry
      entry = 'P53_HUMAN'
      assert_equal(@obj.entry, entry)
      assert_equal(@obj.entry_name, entry)
      assert_equal(@obj.entry_id, entry)
    end

    def test_molecule
      assert_equal(@obj.molecule, 'PRT')
      assert_equal(@obj.molecule_type, 'PRT')
    end

    def test_sequence_length
      seqlen = 393
      assert_equal(@obj.sequence_length, seqlen)
      assert_equal(@obj.aalen, seqlen)
    end

    def test_ac
      acs = ["P04637", "Q15086", "Q15087", "Q15088", "Q16535", "Q16807", "Q16808", "Q16809", "Q16810", "Q16811", "Q16848", "Q86UG1", "Q8J016", "Q99659", "Q9BTM4", "Q9HAQ8", "Q9NP68", "Q9NPJ2", "Q9NZD0", "Q9UBI2", "Q9UQ61"]
      assert_equal(@obj.ac, acs)
      assert_equal(@obj.accessions, acs)
    end

    def test_accession
      assert_equal(@obj.accession, 'P04637')
    end

    def test_dt
      assert(@obj.dt)
    end

    def test_dt_created
      assert_equal(@obj.dt('created'), '13-AUG-1987 (Rel. 05, Created)')
    end

    def test_dt_sequence
      assert_equal(@obj.dt('sequence'), '01-MAR-1989 (Rel. 10, Last sequence update)')
    end

    def test_dt_annotation
      assert_equal(@obj.dt('annotation'), '13-SEP-2005 (Rel. 48, Last annotation update)')
    end

    def test_de
      assert(@obj.de)
    end

    def test_protein_name
      assert_equal(@obj.protein_name, "Cellular tumor antigen p53")
    end

    def test_synonyms
      assert_equal(@obj.synonyms, ["Tumor suppressor p53", "Phosphoprotein p53", "Antigen NY-CO-13"])
    end

    def test_gn
      assert_equal(@obj.gn, [{:orfs=>[], :synonyms=>["P53"], :name=>"TP53", :loci=>[]}])
    end

    def test_gn_uniprot_parser
      gn_uniprot_data = ''
      assert_equal(@obj.instance_eval("gn_uniprot_parser"), [{:orfs=>[], :loci=>[], :name=>"TP53", :synonyms=>["P53"]}])
    end

    def test_gn_old_parser
      gn_old_data = ''
      assert_equal(@obj.instance_eval("gn_old_parser"), [["Name=TP53; Synonyms=P53;"]])
    end

    def test_gene_names
      assert_equal(@obj.gene_names, ["TP53"])
    end

    def test_gene_name
      assert_equal(@obj.gene_name, 'TP53')
    end

    def test_os
      assert(@obj.os)
    end

    def test_os_access
      assert_equal(@obj.os(0), "Homo sapiens (Human)")
    end

    def test_os_access2
      assert_equal(@obj.os[0], {"name"=>"(Human)", "os"=>"Homo sapiens"})
    end

    def test_og_1
      og = "OG   Plastid; Chloroplast."
      ary = ['Plastid', 'Chloroplast']
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(@obj.og, ary)
    end

    def test_og_2
      og = "OG   Mitochondrion."
      ary = ['Mitochondrion']
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(@obj.og, ary)
    end

    def test_og_3
      og = "OG   Plasmid sym pNGR234a."
      ary = ["Plasmid sym pNGR234a"]
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(@obj.og, ary)
    end

    def test_og_4
      og = "OG   Plastid; Cyanelle."
      ary = ['Plastid', 'Cyanelle']
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(@obj.og, ary)
    end

    def test_og_5
      og = "OG   Plasmid pSymA (megaplasmid 1)." 
      ary = ["Plasmid pSymA (megaplasmid 1)"]
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(@obj.og, ary)
    end

    def test_og_6
      og = "OG   Plasmid pNRC100, Plasmid pNRC200, and Plasmid pHH1." 
      ary = ['Plasmid pNRC100', 'Plasmid pNRC200', 'Plasmid pHH1']
      @obj.instance_eval("@orig['OG'] = '#{og}'")
      assert_equal(@obj.og, ary)
    end

    def test_oc
      assert_equal(@obj.oc, ["Eukaryota", "Metazoa", "Chordata", "Craniata", "Vertebrata", "Euteleostomi", "Mammalia", "Eutheria", "Euarchontoglires", "Primates", "Catarrhini", "Hominidae", "Homo"])
    end

    def test_ox
      assert_equal(@obj.ox, {"NCBI_TaxID"=>["9606"]})
    end

    def test_ref # Bio::EMBL::COMMON#ref
      @obj.ref
    end

    def test_cc
      assert_equal(@obj.cc.class, Hash)
    end
   
    def test_cc_database
      db = [{"NAME"=>"IARC TP53 mutation database", "WWW"=>"http://www.iarc.fr/p53/", "FTP"=>nil, "NOTE"=>"IARC db of somatic p53 mutations"},
            {"NAME"=>"Tokyo p53", "WWW"=>"http://p53.genome.ad.jp/", "FTP"=>nil, "NOTE"=>"University of Tokyo db of p53 mutations"},
            {"NAME"=>"p53 web site at the Institut Curie", "WWW"=>"http://p53.curie.fr/", "FTP"=>nil, "NOTE"=>nil},
            {"NAME"=>"Atlas Genet. Cytogenet. Oncol. Haematol.", "WWW"=>"http://www.infobiogen.fr/services/chromcancer/Genes/P53ID88.html", "FTP"=>nil, "NOTE"=>nil}]
      assert_equal(@obj.cc('DATABASE'), db)
    end

    def test_cc_alternative_products
      ap = {"Comment"=>nil, "Named isoforms"=>"2", "Variants"=>  [{"IsoId"=>"P04637-1", "Name"=>"1", "Sequence"=>["Displayed"]},
                                                                  {"IsoId"=>"P04637-2", "Name"=>"2", "Synonyms"=>"I9RET", "Sequence"=>["VSP_006535", "VSP_006536"]}],
            "Event"=>"Alternative splicing"}
      assert_equal(@obj.cc('ALTERNATIVE PRODUCTS'), ap)
    end

    def test_cc_mass_spectrometry
      assert_equal(@obj.cc('MASS SPECTROMETRY'), nil)
    end



    def test_kw
      keywords = ["3D-structure", "Acetylation", "Activator", "Alternative splicing", "Anti-oncogene", "Apoptosis", "Cell cycle", "Disease mutation", "DNA-binding", "Glycoprotein", "Li-Fraumeni syndrome", "Metal-binding", "Nuclear protein", "Phosphorylation", "Polymorphism", "Transcription", "Transcription regulation", "Zinc"]
      assert_equal(@obj.kw, keywords)
    end
    
    def test_ft
      assert(@obj.ft)
      name = 'DNA_BIND'
      assert_equal(@obj.ft(name), [{"FTId"=>nil, "From"=>102, "diff"=>[], "To"=>292, "Description"=>nil}])
    end

    def test_sq
      assert_equal(@obj.sq, {"CRC64"=>"AD5C149FD8106131", "aalen"=>393, "MW"=>43653})
    end

    def test_sq_crc64
      assert_equal(@obj.sq('CRC64'), "AD5C149FD8106131")
    end

    def test_sq_mw
      mw = 43653
      assert_equal(@obj.sq('mw'), mw)
      assert_equal(@obj.sq('molecular'), mw)
      assert_equal(@obj.sq('weight'), mw)
    end

    def test_sq_len
      length = 393
      assert_equal(@obj.sq('len'), length)
      assert_equal(@obj.sq('length'), length)
      assert_equal(@obj.sq('AA'), length)
    end

    def test_seq
      seq = 'MEEPQSDPSVEPPLSQETFSDLWKLLPENNVLSPLPSQAMDDLMLSPDDIEQWFTEDPGPDEAPRMPEAAPPVAPAPAAPTPAAPAPAPSWPLSSSVPSQKTYQGSYGFRLGFLHSGTAKSVTCTYSPALNKMFCQLAKTCPVQLWVDSTPPPGTRVRAMAIYKQSQHMTEVVRRCPHHERCSDSDGLAPPQHLIRVEGNLRVEYLDDRNTFRHSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNRRPILTIITLEDSSGNLLGRNSFEVRVCACPGRDRRTEEENLRKKGEPHHELPPGSTKRALPNNTSSSPQPKKKPLDGEYFTLQIRGRERFEMFRELNEALELKDAQAGKEPGGSRAHSSHLKSKKGQSTSRHKKLMFKTEGPDSD'
      assert_equal(@obj.seq, seq)
      assert_equal(@obj.aaseq, seq)
    end

  end
end
