#
# test/unit/bio/db/embl/test_sptr.rb - Unit test for Bio::SPTR
#
# Copyright:::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::     The Ruby License
#
#  $Id: test_sptr.rb,v 1.7 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), 
                                 ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/embl/sptr'

module Bio
  class TestSPTR < Test::Unit::TestCase

    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), 
                                            ['..'] * 5)).cleanpath.to_s
      data = File.open(File.join(bioruby_root, 
                                 'test', 'data', 'uniprot', 
                                 'p53_human.uniprot')).read
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
      acs = ["P04637", "Q15086", "Q15087", "Q15088", "Q16535", "Q16807", 
             "Q16808", "Q16809", "Q16810", "Q16811", "Q16848", "Q86UG1", 
             "Q8J016", "Q99659", "Q9BTM4", "Q9HAQ8", "Q9NP68", "Q9NPJ2", 
             "Q9NZD0", "Q9UBI2", "Q9UQ61"]
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
      assert_equal('01-MAR-1989 (Rel. 10, Last sequence update)', 
                   @obj.dt('sequence'))
    end

    def test_dt_annotation
      assert_equal('13-SEP-2005 (Rel. 48, Last annotation update)', 
                   @obj.dt('annotation'))
    end

    def test_de
      assert(@obj.de)
    end

    def test_protein_name
      assert_equal("Cellular tumor antigen p53", @obj.protein_name)
    end

    def test_synonyms
      ary = ["Tumor suppressor p53", "Phosphoprotein p53", "Antigen NY-CO-13"]
      assert_equal(ary, @obj.synonyms)
    end

    def test_gn
      assert_equal([{:orfs=>[], :synonyms=>["P53"], :name=>"TP53", :loci=>[]}], 
                   @obj.gn)
    end

    def test_gn_uniprot_parser
      gn_uniprot_data = ''
      assert_equal([{:orfs=>[], :loci=>[], :name=>"TP53", :synonyms=>["P53"]}], 
                   @obj.instance_eval("gn_uniprot_parser"))
    end

    def test_gn_old_parser
      gn_old_data = ''
      assert_equal([["Name=TP53; Synonyms=P53;"]], 
                   @obj.instance_eval("gn_old_parser"))
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
      assert_equal(["Eukaryota", "Metazoa", "Chordata", "Craniata", 
                    "Vertebrata", "Euteleostomi", "Mammalia", "Eutheria", 
                    "Euarchontoglires", "Primates", "Catarrhini", "Hominidae", 
                    "Homo"], 
                   @obj.oc)
    end

    def test_ox
      assert_equal({"NCBI_TaxID"=>["9606"]}, @obj.ox)
    end

    def test_ref # Bio::SPTR#ref
      assert_equal(Array, @obj.ref.class)
    end

    def test_cc
      assert_equal(Hash, @obj.cc.class)
    end
   
    def test_cc_database
      db = [{"NAME" => "IARC TP53 mutation database", 
             "WWW" => "http://www.iarc.fr/p53/", 
             "FTP" => nil, "NOTE" => "IARC db of somatic p53 mutations"},
            {"NAME" => "Tokyo p53", 
             "WWW" => "http://p53.genome.ad.jp/", "FTP" => nil, 
             "NOTE" => "University of Tokyo db of p53 mutations"},
            {"NAME" => "p53 web site at the Institut Curie", 
             "WWW" => "http://p53.curie.fr/", "FTP" => nil, "NOTE" => nil},
            {"NAME" => "Atlas Genet. Cytogenet. Oncol. Haematol.", 
             "WWW" => "http://www.infobiogen.fr/services/chromcancer/Genes/P53ID88.html", 
             "FTP" => nil, "NOTE" => nil}]
      assert_equal(db, @obj.cc('DATABASE'))
    end

    def test_cc_alternative_products
      ap = {"Comment" => "",
            "Named isoforms" => "2", 
            "Variants" => [{"IsoId" => ["P04637-1"], 
                            "Name" => "1", 
                            "Synonyms" => [], 
                            "Sequence" => ["Displayed"]},
                           {"IsoId" => ["P04637-2"], 
                            "Name" => "2", 
                            "Synonyms" => ["I9RET"], 
                            "Sequence" => ["VSP_006535", "VSP_006536"]}],
            "Event" => ["Alternative splicing"]}
      assert_equal(ap, @obj.cc('ALTERNATIVE PRODUCTS'))
    end

    def test_cc_mass_spectrometry
      assert_equal(nil, @obj.cc('MASS SPECTROMETRY'))
    end


    def test_kw
      keywords = ["3D-structure", "Acetylation", "Activator", 
                  "Alternative splicing", "Anti-oncogene", 
                  "Apoptosis", "Cell cycle", "Disease mutation", "DNA-binding", 
                  "Glycoprotein", "Li-Fraumeni syndrome", "Metal-binding", 
                  "Nuclear protein", "Phosphorylation", "Polymorphism", 
                  "Transcription", "Transcription regulation", "Zinc"]
      assert_equal(keywords, @obj.kw)
    end
    
    def test_ft
      assert(@obj.ft)
      name = 'DNA_BIND'
      assert_equal([{"FTId"=>"", "From"=>102, "diff"=>[], "To"=>292, 
                     "Description"=>"", 
                     "original" => ['DNA_BIND', '102', '292', '', '']}], 
                   @obj.ft[name])
    end

    def test_sq
      assert_equal({"CRC64"=>"AD5C149FD8106131", "aalen"=>393, "MW"=>43653}, 
                   @obj.sq)
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

  end # class TestSPTR



  class TestSPTRCC < Test::Unit::TestCase
    def test_allergen
      # ALLERGEN	Information relevant to allergenic proteins
      data = 'CC   -!- ALLERGEN: Causes an allergic reaction in human.'
      sp = Bio::SPTR.new(data)
      assert_equal(['Causes an allergic reaction in human.'], 
                   sp.cc['ALLERGEN'])
      assert_equal(['Causes an allergic reaction in human.'], 
                   sp.cc('ALLERGEN'))
    end
    
    def test_alternative_products_access_as_hash
      data = "CC   -!- ALTERNATIVE PRODUCTS:
CC       Event=Alternative initiation; Named isoforms=2;
CC       Name=Long;
CC         IsoId=P68250-1; Sequence=Displayed;
CC       Name=Short;
CC         IsoId=P68250-2; Sequence=VSP_018631;
CC         Note=Contains a N-acetylmethionine at position 1 (By
CC         similarity);"

      res = ["Event=Alternative initiation; Named isoforms=2; Name=Long; IsoId=P68250-1; Sequence=Displayed; Name=Short; IsoId=P68250-2; Sequence=VSP_018631; Note=Contains a N-acetylmethionine at position 1 (By similarity);"]
      sp = Bio::SPTR.new(data)
      assert_equal(res,
                   sp.cc['ALTERNATIVE PRODUCTS'])
    end

    def test_alternative_products_ai
      # ALTERNATIVE PRODUCTS	Description of the existence of related protein sequence(s) produced by alternative splicing of the same gene, alternative promoter usage, ribosomal frameshifting or by the use of alternative initiation codons; see 3.21.15
      # Alternative promoter usage, Alternative splicing, Alternative initiation, Ribosomal frameshifting
      data = "CC   -!- ALTERNATIVE PRODUCTS:
CC       Event=Alternative initiation; Named isoforms=2;
CC       Name=Long;
CC         IsoId=P68250-1; Sequence=Displayed;
CC       Name=Short;
CC         IsoId=P68250-2; Sequence=VSP_018631;
CC         Note=Contains a N-acetylmethionine at position 1 (By
CC         similarity);"

      sp = Bio::SPTR.new(data)
      assert_equal({"Comment"=>"",
                    "Named isoforms"=>"2",
                    "Variants"=>
                    [{"IsoId"=>["P68250-1"], 
                      "Name"=>"Long", 
                      "Synonyms" => [],
                      "Sequence"=>["Displayed"]},
                     {"IsoId"=>["P68250-2"], 
                      "Name"=>"Short", 
                      "Synonyms" => [],
                      "Sequence"=>["VSP_018631"]}],
                    "Event"=>["Alternative initiation"]},
                   sp.cc('ALTERNATIVE PRODUCTS'))
    end
    def test_alternative_products_as
      data = "CC   -!- ALTERNATIVE PRODUCTS:
CC       Event=Alternative splicing; Named isoforms=2;
CC       Name=1;
CC         IsoId=P04637-1; Sequence=Displayed;
CC       Name=2; Synonyms=I9RET;
CC         IsoId=P04637-2; Sequence=VSP_006535, VSP_006536;
CC         Note=Seems to be non-functional. Expressed in quiescent
CC         lymphocytes;"
      sp = Bio::SPTR.new(data)
      assert_equal({"Comment"=>"",
                    "Named isoforms"=>"2",
                    "Variants"=>
                    [{"Name"=>"1", 
                      "IsoId"=>["P04637-1"],
                      "Synonyms"=>[], 
                      "Sequence"=>["Displayed"]},
                     {"IsoId"=>["P04637-2"],
                      "Name"=>"2",
                      "Synonyms"=>["I9RET"],
                      "Sequence"=>["VSP_006535", "VSP_006536"]}],
                    "Event"=>["Alternative splicing"]},
                   sp.cc('ALTERNATIVE PRODUCTS'))
    end
    def test_alternative_products_apu
      data = "CC   -!- ALTERNATIVE PRODUCTS:
CC       Event=Alternative promoter usage, Alternative splicing; Named isoforms=5;
CC         Comment=Additional isoforms (AAT-1L and AAT-1S) may exist;
CC       Name=1; Synonyms=AAT-1M;
CC         IsoId=Q7Z4T9-1; Sequence=Displayed;
CC       Name=2;
CC         IsoId=Q7Z4T9-2; Sequence=VSP_014910, VSP_014911;
CC         Note=No experimental confirmation available;
CC       Name=3;
CC         IsoId=Q7Z4T9-3; Sequence=VSP_014907, VSP_014912;
CC       Name=4; Synonyms=AAT1-alpha;
CC         IsoId=Q7Z4T9-4; Sequence=VSP_014908;
CC         Note=May be produced by alternative promoter usage;
CC       Name=5; Synonyms=AAT1-beta, AAT1-gamma;
CC         IsoId=Q7Z4T9-5; Sequence=VSP_014909;
CC         Note=May be produced by alternative promoter usage;"
      sp = Bio::SPTR.new(data)
      assert_equal({"Comment"=>"Additional isoforms (AAT-1L and AAT-1S) may exist",
                    "Named isoforms"=>"5",
                    "Variants"=>
                    [{"Name"=>"1",
                      "IsoId"=>["Q7Z4T9-1"],
                      "Synonyms"=>["AAT-1M"],
                      "Sequence"=>["Displayed"]},
                     {"Name"=>"2",
                      "IsoId"=>["Q7Z4T9-2"],
                      "Synonyms" => [],
                      "Sequence"=>["VSP_014910", "VSP_014911"]},
                     {"Name"=>"3",
                      "IsoId"=>["Q7Z4T9-3"],
                      "Synonyms" => [],
                      "Sequence"=>["VSP_014907", "VSP_014912"]},
                     {"Name"=>"4",
                      "IsoId"=>["Q7Z4T9-4"],
                      "Synonyms"=>["AAT1-alpha"],
                      "Sequence"=>["VSP_014908"]},
                     {"Name"=>"5",
                      "IsoId"=>["Q7Z4T9-5"],
                      "Synonyms"=>["AAT1-beta", "AAT1-gamma"],
                      "Sequence"=>["VSP_014909"]}],
                   "Event"=>["Alternative promoter usage", "Alternative splicing"]},
                   sp.cc('ALTERNATIVE PRODUCTS'))
    end
    def test_alternative_products_rf
      data = ""
      sp = Bio::SPTR.new(data)
      assert_equal({},
                   sp.cc('ALTERNATIVE PRODUCTS'))
    end
    
    def test_biophysicochemical_properties
      # BIOPHYSICOCHEMICAL PROPERTIES	Description of the information relevant to biophysical and physicochemical data and information on pH dependence, temperature dependence, kinetic parameters, redox potentials, and maximal absorption; see 3.21.8
      #
      data = 'CC   -!- BIOPHYSICOCHEMICAL PROPERTIES:
CC       Kinetic parameters:
CC         KM=45 uM for AdoMet;
CC         Vmax=32 uM/h/mg enzyme;
CC       pH dependence:
CC         Optimum pH is 8.2;'
      sp = Bio::SPTR.new(data)
      assert_equal(["Kinetic parameters: KM=45 uM for AdoMet; Vmax=32 uM/h/mg enzyme; pH dependence: Optimum pH is 8.2;"],
                   sp.cc['BIOPHYSICOCHEMICAL PROPERTIES'])
      assert_equal({"Redox potential" => "",
                    "Temperature dependence" => "",
                    "Kinetic parameters" => {"KM" => "45 uM for AdoMet", 
                                             "Vmax" => "32 uM/h/mg enzyme"}, 
                    "Absorption" => {},
                    "pH dependence" => "Optimum pH is 8.2"},
                   sp.cc('BIOPHYSICOCHEMICAL PROPERTIES'))

# 3.12.2. Syntax of the topic 'BIOPHYSICOCHEMICAL PROPERTIES'
      data = "CC   -!- BIOPHYSICOCHEMICAL PROPERTIES:
CC       Absorption:
CC         Abs(max)=xx nm;
CC         Note=free_text;
CC       Kinetic parameters:
CC         KM=xx unit for substrate [(free_text)];
CC         Vmax=xx unit enzyme [free_text];
CC         Note=free_text;
CC       pH dependence:
CC         free_text;
CC       Redox potential:
CC         free_text;
CC       Temperature dependence:
CC         free_text;"
      sp = Bio::SPTR.new(data)
      assert_equal({"Redox potential"=>"free_text",
                    "Temperature dependence"=>"free_text",
                    "Kinetic parameters"=>
                    {"KM"=>"xx unit for substrate [(free_text)]",
                     "Note"=>"free_text",
                     "Vmax"=>"xx unit enzyme [free_text]"},
                    "Absorption"=>{"Note"=>"free_text", "Abs(max)"=>"xx nm"},
                    "pH dependence"=>"free_text"},
                   sp.cc('BIOPHYSICOCHEMICAL PROPERTIES'))
    end


    def test_biotechnology
      # BIOTECHNOLOGY	Description of the use of a specific protein in a biotechnological process
      data = 'CC   -!- BIOTECHNOLOGY: Introduced by genetic manipulation and expressed in
CC       improved ripening tomato by Monsanto. ACC is the immediate
CC       precursor of the phytohormone ethylene which is involved in the
CC       control of ripening. ACC deaminase reduces ethylene biosynthesis
CC       and thus extends the shelf life of fruits and vegetables.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Introduced by genetic manipulation and expressed in improved ripening tomato by Monsanto. ACC is the immediate precursor of the phytohormone ethylene which is involved in the control of ripening. ACC deaminase reduces ethylene biosynthesis and thus extends the shelf life of fruits and vegetables."],
                   sp.cc['BIOTECHNOLOGY'])
    end

    def test_catalytic_activity
      # CATALYTIC ACTIVITY	Description of the reaction(s) catalyzed by an enzyme [1]
      data = 'CC   -!- CATALYTIC ACTIVITY: Hydrolysis of alkylated DNA, releasing 3-
CC       methyladenine, 3-methylguanine, 7-methylguanine and 7-
CC       methyladenine.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Hydrolysis of alkylated DNA, releasing 3-methyladenine, 3-methylguanine, 7-methylguanine and 7-methyladenine."],
                   sp.cc['CATALYTIC ACTIVITY'])
    end

    def test_caution
      # CAUTION	Warning about possible errors and/or grounds for confusion
      data = 'CC   -!- CAUTION: Ref.1 sequence differs from that shown due to a Leu codon
CC       in position 480 which was translated as a stop codon to shorten
CC       the sequence.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Ref.1 sequence differs from that shown due to a Leu codon in position 480 which was translated as a stop codon to shorten the sequence."],
                   sp.cc['CAUTION'])
      assert_equal("Ref.1 sequence differs from that shown due to a Leu codon in position 480 which was translated as a stop codon to shorten the sequence.",
                   sp.cc('CAUTION'))

    end

    def test_cofactor
      # COFACTOR	Description of any non-protein substance required by an enzyme for its catalytic activity
      data = 'CC   -!- COFACTOR: Cl(-). Is unique in requiring Cl(-) for its activity.
CC   -!- COFACTOR: Mg(2+).'
      sp = Bio::SPTR.new(data)
      assert_equal(["Cl(-). Is unique in requiring Cl(-) for its activity.", 
                    "Mg(2+)."],
                   sp.cc['COFACTOR'])

      assert_equal(["Cl(-). Is unique in requiring Cl(-) for its activity.", 
                    "Mg(2+)."],
                   sp.cc('COFACTOR'))
    end

    def test_developmental_stage
      # DEVELOPMENTAL STAGE	Description of the developmentally-specific expression of mRNA or protein
      data = 'CC   -!- DEVELOPMENTAL STAGE: In females, isoform 1 is expressed at day 35
CC       with higher levels detected at day 56. Isoform 1 is not detected
CC       in males of any age.'
      sp = Bio::SPTR.new(data)
      assert_equal(["In females, isoform 1 is expressed at day 35 with higher levels detected at day 56. Isoform 1 is not detected in males of any age."],
                   sp.cc['DEVELOPMENTAL STAGE'])
      assert_equal("In females, isoform 1 is expressed at day 35 with higher levels detected at day 56. Isoform 1 is not detected in males of any age.",
                   sp.cc('DEVELOPMENTAL STAGE'))
    end

    def test_disease
      # DISEASE	Description of the disease(s) associated with a deficiency of a protein
      data = 'CC   -!- DISEASE: Defects in APP are a cause of hereditary cerebral
CC       hemorrhage with amyloidosis (HCHWAD) [MIM:609065, 104760]. This
CC       disorder is characterized by amyloid deposits in cerebral vessels.
CC       The principal clinical characteristics are recurring cerebral
CC       hemorrhages, sometimes preceded by migrainous headaches or mental
CC       cleavage. Various types of HCHWAD are known. They differ in onset
CC       and aggressiveness of the disease. The Iowa type demonstrated no
CC       cerebral hemorrhaging but is characterized by progressive
CC       cognitive decline. Beta-APP40 is the predominant form of
CC       cerebrovascular amyloid.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Defects in APP are a cause of hereditary cerebral hemorrhage with amyloidosis (HCHWAD) [MIM:609065, 104760]. This disorder is characterized by amyloid deposits in cerebral vessels. The principal clinical characteristics are recurring cerebral hemorrhages, sometimes preceded by migrainous headaches or mental cleavage. Various types of HCHWAD are known. They differ in onset and aggressiveness of the disease. The Iowa type demonstrated no cerebral hemorrhaging but is characterized by progressive cognitive decline. Beta-APP40 is the predominant form of cerebrovascular amyloid."],
                   sp.cc['DISEASE'])
      assert_equal("Defects in APP are a cause of hereditary cerebral hemorrhage with amyloidosis (HCHWAD) [MIM:609065, 104760]. This disorder is characterized by amyloid deposits in cerebral vessels. The principal clinical characteristics are recurring cerebral hemorrhages, sometimes preceded by migrainous headaches or mental cleavage. Various types of HCHWAD are known. They differ in onset and aggressiveness of the disease. The Iowa type demonstrated no cerebral hemorrhaging but is characterized by progressive cognitive decline. Beta-APP40 is the predominant form of cerebrovascular amyloid.",
                   sp.cc('DISEASE'))
    end

    def test_domain
      # DOMAIN	Description of the domain structure of a protein
      data = 'CC   -!- DOMAIN: The basolateral sorting signal (BaSS) is required for
CC       sorting of membrane proteins to the basolateral surface of
CC       epithelial cells.
CC   -!- DOMAIN: The NPXY sequence motif found in many tyrosine-
CC       phosphorylated proteins is required for the specific binding of
CC       the PID domain. However, additional amino acids either N- or C-
CC       terminal to the NPXY motif are often required for complete
CC       interaction. The PID domain-containing proteins which bind APP
CC       require the YENPTY motif for full interaction. These interactions
CC       are independent of phosphorylation on the terminal tyrosine
CC       residue. The NPXY site is also involved in clathrin-mediated
CC       endocytosis (By similarity).'
      sp = Bio::SPTR.new(data)
      assert_equal(["The basolateral sorting signal (BaSS) is required for sorting of membrane proteins to the basolateral surface of epithelial cells.",
 "The NPXY sequence motif found in many tyrosine-phosphorylated proteins is required for the specific binding of the PID domain. However, additional amino acids either N-or C-terminal to the NPXY motif are often required for complete interaction. The PID domain-containing proteins which bind APP require the YENPTY motif for full interaction. These interactions are independent of phosphorylation on the terminal tyrosine residue. The NPXY site is also involved in clathrin-mediated endocytosis (By similarity)."],
                   sp.cc['DOMAIN'])
      assert_equal(["The basolateral sorting signal (BaSS) is required for sorting of membrane proteins to the basolateral surface of epithelial cells.",
 "The NPXY sequence motif found in many tyrosine-phosphorylated proteins is required for the specific binding of the PID domain. However, additional amino acids either N-or C-terminal to the NPXY motif are often required for complete interaction. The PID domain-containing proteins which bind APP require the YENPTY motif for full interaction. These interactions are independent of phosphorylation on the terminal tyrosine residue. The NPXY site is also involved in clathrin-mediated endocytosis (By similarity)."],
                   sp.cc('DOMAIN'))
    end

    def test_enzyme_regulation
      # ENZYME REGULATION	Description of an enzyme regulatory mechanism
      data = 'CC   -!- ENZYME REGULATION: Insensitive to calcium/calmodulin. Stimulated
CC       by the G protein beta and gamma subunit complex.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Insensitive to calcium/calmodulin. Stimulated by the G protein beta and gamma subunit complex."],
                   sp.cc['ENZYME REGULATION'])
      assert_equal("Insensitive to calcium/calmodulin. Stimulated by the G protein beta and gamma subunit complex.",
                   sp.cc('ENZYME REGULATION'))
    end
    
    def test_function
      # FUNCTION	General description of the function(s) of a protein
      data = 'CC   -!- FUNCTION: May play a fundamental role in situations where fine
CC       interplay between intracellular calcium and cAMP determines the
CC       cellular function. May be a physiologically relevant docking site
CC       for calcineurin (By similarity).'
      sp = Bio::SPTR.new(data)
      assert_equal(["May play a fundamental role in situations where fine interplay between intracellular calcium and cAMP determines the cellular function. May be a physiologically relevant docking site for calcineurin (By similarity)."],
                   sp.cc['FUNCTION'])
      assert_equal("May play a fundamental role in situations where fine interplay between intracellular calcium and cAMP determines the cellular function. May be a physiologically relevant docking site for calcineurin (By similarity).",
                   sp.cc('FUNCTION'))
    end

    def test_induction
      # INDUCTION	Description of the compound(s) or condition(s) that regulate gene expression
      data = 'CC   -!- INDUCTION: By pheromone (alpha-factor).'
      sp = Bio::SPTR.new(data)
      assert_equal(["By pheromone (alpha-factor)."],
                   sp.cc['INDUCTION'])
      assert_equal("By pheromone (alpha-factor).",
                   sp.cc('INDUCTION'))
    end

    def test_interaction
      # INTERACTION	Conveys information relevant to binary protein-protein interaction 3.21.12
      data = 'CC   -!- INTERACTION:
CC       P62158:CALM1 (xeno); NbExp=1; IntAct=EBI-457011, EBI-397435;
CC       P62155:calm1 (xeno); NbExp=1; IntAct=EBI-457011, EBI-397568;'
      sp = Bio::SPTR.new(data)
      assert_equal(["P62158:CALM1 (xeno); NbExp=1; IntAct=EBI-457011, EBI-397435; P62155:calm1 (xeno); NbExp=1; IntAct=EBI-457011, EBI-397568;"],
                   sp.cc['INTERACTION'])
      assert_equal([{'SP_Ac' => 'P62158', 
                     'identifier' => 'CALM1', 
                     'optional_identifier' => '(xeno)',
                     'NbExp' => '1', 
                     'IntAct' => ['EBI-457011', 'EBI-397435']},
                    {'SP_Ac' => 'P62155', 
                     'identifier' => 'calm1', 
                     'optional_identifier' => '(xeno)',
                     'NbExp' => '1', 
                     'IntAct' => ['EBI-457011', 'EBI-397568']}],
                   sp.cc('INTERACTION'))
    end

    def test_mass_spectrometry
      # MASS SPECTROMETRY	Reports the exact molecular weight of a protein or part of a protein as determined by mass spectrometric methods; see 3.21.23
      data = "CC   -!- MASS SPECTROMETRY: MW=2894.9; MW_ERR=3; METHOD=MALDI; RANGE=1-29;
CC       NOTE=Ref.1.
CC   -!- MASS SPECTROMETRY: MW=2892.2; METHOD=Electrospray; RANGE=1-29;
CC       NOTE=Ref.2."
      sp = Bio::SPTR.new(data)
      assert_equal(["MW=2894.9; MW_ERR=3; METHOD=MALDI; RANGE=1-29; NOTE=Ref.1.",
                    "MW=2892.2; METHOD=Electrospray; RANGE=1-29; NOTE=Ref.2."],
                   sp.cc['MASS SPECTROMETRY'])
      assert_equal([{'MW' => '2894.9', 
                     'MW_ERR' => '3', 
                     'METHOD' => 'MALDI',  
                     'RANGE' => '1-29',
                     'NOTE' => 'Ref.1'},
                    {'MW' => '2892.2', 
                     'METHOD' => 'Electrospray',
                     'MW_ERR' => nil,
                     'RANGE' => '1-29',
                     'NOTE' => 'Ref.2'}],
                   sp.cc('MASS SPECTROMETRY'))
    end

    def test_miscellaneous
      # MISCELLANEOUS	Any comment which does not belong to any of the other defined topics
      data = 'CC   -!- MISCELLANEOUS: There are two isozymes; a cytoplasmic one and a
CC       mitochondrial one.'
      sp = Bio::SPTR.new(data)
      assert_equal(["There are two isozymes; a cytoplasmic one and a mitochondrial one."],
                   sp.cc['MISCELLANEOUS'])
    end

    def test_pathway
      # PATHWAY	Description of the metabolic pathway(s) with which a protein is associated
      data = 'CC   -!- PATHWAY: Carbohydrate degradation; glycolysis; D-glyceraldehyde 3-
CC       phosphate and glycerone phosphate from D-glucose: step 4.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Carbohydrate degradation; glycolysis; D-glyceraldehyde 3-phosphate and glycerone phosphate from D-glucose: step 4."],
                   sp.cc['PATHWAY'])
      assert_equal(["Carbohydrate degradation", 
                    'glycolysis', 
                    'D-glyceraldehyde 3-phosphate',
                    'glycerone phosphate from D-glucose', 
                    'step 4'],
                   sp.cc('PATHWAY'))
    end

    def test_pharmaceutical
      # PHARMACEUTICAL	Description of the use of a protein as a pharmaceutical drug
      data = 'CC   -!- PHARMACEUTICAL: Available under the names Factrel (Ayerst Labs),
CC       Lutrepulse or Lutrelef (Ferring Pharmaceuticals) and Relisorm
CC       (Serono). Used in evaluating hypothalamic-pituitary gonadotropic
CC       function.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Available under the names Factrel (Ayerst Labs), Lutrepulse or Lutrelef (Ferring Pharmaceuticals) and Relisorm (Serono). Used in evaluating hypothalamic-pituitary gonadotropic function."],
                   sp.cc['PHARMACEUTICAL'])
    end

    def test_polymorphism
      # POLYMORPHISM	Description of polymorphism(s)
      data = 'CC   -!- POLYMORPHISM: Position 161 is associated with platelet-specific
CC       alloantigen Siba. Siba(-) has Thr-161 and Siba(+) has Met-161.
CC       Siba is involved in neonatal alloimmune thrombocytopenia (NATP).
CC   -!- POLYMORPHISM: Polymorphisms arise from a variable number of tandem
CC       13-amino acid repeats of S-E-P-A-P-S-P-T-T-P-E-P-T in the mucin-
CC       like macroglycopeptide (Pro/Thr-rich) domain. Allele D (shown
CC       here) contains one repeat starting at position 415, allele C
CC       contains two repeats, allele B contains three repeats and allele A
CC       contains four repeats.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Position 161 is associated with platelet-specific alloantigen Siba. Siba(-) has Thr-161 and Siba(+) has Met-161. Siba is involved in neonatal alloimmune thrombocytopenia (NATP).",
                    "Polymorphisms arise from a variable number of tandem 13-amino acid repeats of S-E-P-A-P-S-P-T-T-P-E-P-T in the mucin-like macroglycopeptide (Pro/Thr-rich) domain. Allele D (shown here) contains one repeat starting at position 415, allele C contains two repeats, allele B contains three repeats and allele A contains four repeats."],
                   sp.cc['POLYMORPHISM'])
    end

    def test_ptm
      # PTM	Description of any chemical alternation of a polypeptide (proteolytic cleavage, amino acid modifications including crosslinks). This topic complements information given in the feature table or indicates polypeptide modifications for which position-specific data is not available.
      data = 'CC   -!- PTM: N-glycosylated, contains approximately 8 kDa of N-linked
CC       carbohydrate.
CC   -!- PTM: Palmitoylated.'
      sp = Bio::SPTR.new(data)
      assert_equal(["N-glycosylated, contains approximately 8 kDa of N-linked carbohydrate.",
 "Palmitoylated."],
                   sp.cc['PTM'])
    end

    def test_rna_editing
      # RNA EDITING	Description of any type of RNA editing that leads to one or more amino acid changes
      data = 'CC   -!- RNA EDITING: Modified_positions=50, 59, 78, 87, 104, 132, 139,
CC       146, 149, 160, 170, 177, 185, 198, 208, 223, 226, 228, 243, 246,
CC       252, 260, 264, 277, 285, 295; Note=The nonsense codons at
CC       positions 50, 78, 104, 260 and 264 are modified to sense codons.'

      data = 'CC   -!- RNA EDITING: Modified_positions=607; Note=Fully edited in the
CC       brain. Heteromerically expressed edited GLUR2 (R) receptor
CC       complexes are impermeable to calcium, whereas the unedited (Q)
CC       forms are highly permeable to divalent ions (By similarity).'
      sp = Bio::SPTR.new(data)
      assert_equal(["Modified_positions=607; Note=Fully edited in the brain. Heteromerically expressed edited GLUR2 (R) receptor complexes are impermeable to calcium, whereas the unedited (Q) forms are highly permeable to divalent ions (By similarity)."],
                   sp.cc['RNA EDITING'])
      assert_equal({"Modified_positions" => ['607'], 
                    "Note" => "Fully edited in the brain. Heteromerically expressed edited GLUR2 (R) receptor complexes are impermeable to calcium, whereas the unedited (Q) forms are highly permeable to divalent ions (By similarity)."},
                   sp.cc('RNA EDITING'))
    end

    def test_similarity
      # SIMILARITY	Description of the similaritie(s) (sequence or structural) of a protein with other proteins
      data = 'CC   -!- SIMILARITY: Contains 1 protein kinase domain.
CC   -!- SIMILARITY: Contains 1 RGS domain.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Contains 1 protein kinase domain.", "Contains 1 RGS domain."],
                   sp.cc['SIMILARITY'])
    end
    
    def test_subcellular_location
      # SUBCELLULAR LOCATION	Description of the subcellular location of the mature protein

      data = 'CC   -!- SUBCELLULAR LOCATION: Or: Cytoplasm. Or: Secreted protein. May be
CC       secreted by a non-classical secretory pathway.'

      data = "CC   -!- SUBCELLULAR LOCATION: Cytoplasmic or may be secreted by a non-
CC       classical secretory pathway (By similarity)."

      data = "CC   -!- SUBCELLULAR LOCATION: Cytoplasm. In neurons, axonally transported
CC       to the nerve terminals."

      data = "CC   -!- SUBCELLULAR LOCATION: Cell wall. Probably the external side of the
CC       cell wall."

      data = "CC   -!- SUBCELLULAR LOCATION: Endosome; late endosome; late endosomal
CC       membrane; single-pass type I membrane protein. Lysosome; lysosomal
CC       membrane; single-pass type I membrane protein. Localizes to late
CC       endocytic compartment. Associates with lysosome membranes."


      data = "CC   -!- SUBCELLULAR LOCATION: Plastid; chloroplast; chloroplast membrane;
CC       peripheral membrane protein. Plastid; chloroplast; chloroplast
CC       stroma."
      sp = Bio::SPTR.new(data)
      assert_equal(["Plastid; chloroplast; chloroplast membrane; peripheral membrane protein. Plastid; chloroplast; chloroplast stroma."],
                   sp.cc['SUBCELLULAR LOCATION'])
      assert_equal([["Plastid",
                     "chloroplast", 
                     "chloroplast membrane", 
                     "peripheral membrane protein"], 
                    ["Plastid", "chloroplast", 
                     "chloroplast stroma"]],
                   sp.cc('SUBCELLULAR LOCATION'))
    end

    def test_subunit
      # SUBUNIT	Description of the quaternary structure of a protein and any kind of interactions with other proteins or protein complexes; except for receptor-ligand interactions, which are described in the topic FUNCTION.

      data = 'CC   -!- SUBUNIT: Interacts with BTK. Interacts with all isoforms of MAPK8,
CC       MAPK9, MAPK10 and MAPK12.'

      data = 'CC   -!- SUBUNIT: Homotetramer.'
      sp = Bio::SPTR.new(data)
      assert_equal(["Homotetramer."],
                   sp.cc['SUBUNIT'])
    end

    def test_tissue_specificity
      # TISSUE SPECIFICITY	Description of the tissue-specific expression of mRNA or protein
      data = "CC   -!- TISSUE SPECIFICITY: Heart, brain and liver mitochondria."

      data = "CC   -!- TISSUE SPECIFICITY: Widely expressed with highest expression in
CC       thymus, testis, embryo and proliferating blood lymphocytes."

      data = "CC   -!- TISSUE SPECIFICITY: Isoform 2 is highly expressed in the brain,
CC       heart, spleen, kidney and blood. Isoform 2 is expressed (at
CC       protein level) in the spleen, skeletal muscle and gastrointestinal
CC       epithelia."
      sp = Bio::SPTR.new(data)
      assert_equal(["Isoform 2 is highly expressed in the brain, heart, spleen, kidney and blood. Isoform 2 is expressed (at protein level) in the spleen, skeletal muscle and gastrointestinal epithelia."],
                   sp.cc['TISSUE SPECIFICITY'])
    end

    def test_toxic_dose
      # TOXIC DOSE	Description of the lethal dose (LD), paralytic dose (PD) or effective dose of a protein
      data = 'CC   -!- TOXIC DOSE: LD(50) is 12 mg/kg by intraperitoneal injection.'
      sp = Bio::SPTR.new(data)
      assert_equal(["LD(50) is 12 mg/kg by intraperitoneal injection."],
                   sp.cc['TOXIC DOSE'])
    end

    def test_web_resource
      # WEB RESOURCE	Description of a cross-reference to a network database/resource for a specific protein; see 3.21.34
      data = 'CC   -!- WEB RESOURCE: NAME=Inherited peripheral neuropathies mutation db;
CC       URL="http://www.molgen.ua.ac.be/CMTMutations/".
CC   -!- WEB RESOURCE: NAME=Connexin-deafness homepage;
CC       URL="http://www.crg.es/deafness/".
CC   -!- WEB RESOURCE: NAME=GeneReviews;
CC       URL="http://www.genetests.org/query?gene=GJB1".'
            sp = Bio::SPTR.new(data)
      assert_equal(['NAME=Inherited peripheral neuropathies mutation db; URL="http://www.molgen.ua.ac.be/CMTMutations/".',
                    'NAME=Connexin-deafness homepage; URL="http://www.crg.es/deafness/".',
                    'NAME=GeneReviews; URL="http://www.genetests.org/query?gene=GJB1".'],
                   sp.cc['WEB RESOURCE'])
      assert_equal([{'NAME' => "Inherited peripheral neuropathies mutation db", 
                     'URL' => 'http://www.molgen.ua.ac.be/CMTMutations/', 'NOTE' => nil},
                    {'NAME' => "Connexin-deafness homepage", 
                     'URL' => 'http://www.crg.es/deafness/', 'NOTE' => nil},
                    {'NAME' => "GeneReviews", 
                     'URL' => 'http://www.genetests.org/query?gene=GJB1', 'NOTE' => nil}],
                   sp.cc('WEB RESOURCE'))

    end

  end # class TestSPTRCC

  # http://br.expasy.org/sprot/userman.html#Ref_line
  class TestSPTRRef < Test::Unit::TestCase

    def setup
      data = 'RN   [1]
RP   NUCLEOTIDE SEQUENCE [MRNA] (ISOFORMS A AND C), FUNCTION, INTERACTION
RP   WITH PKC-3, SUBCELLULAR LOCATION, TISSUE SPECIFICITY, DEVELOPMENTAL
RP   STAGE, AND MUTAGENESIS OF PHE-175 AND PHE-221.
RC   STRAIN=Bristol N2;
RX   PubMed=11134024; DOI=10.1074/jbc.M008990200;
RG   The mouse genome sequencing consortium;
RA   Galinier A., Bleicher F., Negre D., Perriere G., Duclos B.,
RA   Cozzone A.J., Cortay J.-C.;
RT   "A novel adapter protein employs a phosphotyrosine binding domain and
RT   exceptionally basic N-terminal domains to capture and localize an
RT   atypical protein kinase C: characterization of Caenorhabditis elegans
RT   C kinase adapter 1, a protein that avidly binds protein kinase C3.";
RL   J. Biol. Chem. 276:10463-10475(2001).'
      @obj = SPTR.new(data)
    end

    def test_ref
      res = {"RT" => "A novel adapter protein employs a phosphotyrosine binding domain and exceptionally basic N-terminal domains to capture and localize an atypical protein kinase C: characterization of Caenorhabditis elegans C kinase adapter 1, a protein that avidly binds protein kinase C3.",
             "RL" => "J. Biol. Chem. 276:10463-10475(2001).",
             "RA" => "Galinier A., Bleicher F., Negre D., Perriere G., Duclos B., Cozzone A.J., Cortay J.-C.",
             "RX" => {"MEDLINE" => nil, 
                      "DOI" => "10.1074/jbc.M008990200", 
                      "PubMed" => "11134024"}, 
             "RC" => [{"Text" => "Bristol N2", "Token" => "STRAIN"}], 
             "RN" => "[1]", 
             "RP" =>  ["NUCLEOTIDE SEQUENCE [MRNA] (ISOFORMS A AND C)",
                       "FUNCTION",
                       "INTERACTION WITH PKC-3",
                       "SUBCELLULAR LOCATION",
                       "TISSUE SPECIFICITY", 
                       "DEVELOPMENTAL STAGE",
                       "MUTAGENESIS OF PHE-175 AND PHE-221"],
             "RG" => ["The mouse genome sequencing consortium"]}
      assert_equal(res, @obj.ref.first)
    end

    def test_RN
      assert_equal("[1]", @obj.ref.first['RN'])
    end
      
    def test_RP
      assert_equal(["NUCLEOTIDE SEQUENCE [MRNA] (ISOFORMS A AND C)",
                    "FUNCTION", "INTERACTION WITH PKC-3",
                    "SUBCELLULAR LOCATION",
                    "TISSUE SPECIFICITY",
                    "DEVELOPMENTAL STAGE",
                    "MUTAGENESIS OF PHE-175 AND PHE-221"],
                   @obj.ref.first['RP'])
    end

    def test_RC
      assert_equal([{"Text"=>"Bristol N2", "Token"=>"STRAIN"}],
                   @obj.ref.first['RC'])
    end

    def test_RX
      assert_equal({'MEDLINE' => nil,
                    'PubMed' => '11134024', 
                    'DOI' => '10.1074/jbc.M008990200'},
                   @obj.ref.first['RX'])
    end

    def test_RG
      assert_equal(["The mouse genome sequencing consortium"],
                   @obj.ref.first['RG'])
    end

    def test_RA
      assert_equal("Galinier A., Bleicher F., Negre D., Perriere G., Duclos B., Cozzone A.J., Cortay J.-C.",
                   @obj.ref.first['RA'])
    end

    def test_RT
      assert_equal("A novel adapter protein employs a phosphotyrosine binding domain and exceptionally basic N-terminal domains to capture and localize an atypical protein kinase C: characterization of Caenorhabditis elegans C kinase adapter 1, a protein that avidly binds protein kinase C3.",
                   @obj.ref.first['RT'])
    end

    def test_RL
      assert_equal("J. Biol. Chem. 276:10463-10475(2001).",
                   @obj.ref.first['RL'])
    end
    
  end # class TestSPTRReferences


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel41.0
  class TestSPTRSwissProtRel41_0 < Test::Unit::TestCase
    # Progress in the conversion of Swiss-Prot to mixed-case characters

    # Multiple RP lines
    def test_multiple_RP_lines
      data = "RN    [1]
RP   SEQUENCE FROM N.A., SEQUENCE OF 23-42 AND 351-365, AND
RP   CHARACTERIZATION."
      sp = SPTR.new(data)
      assert_equal(['SEQUENCE FROM N.A.', 
                    'SEQUENCE OF 23-42 AND 351-365',
                    'CHARACTERIZATION'],
                   sp.ref.first['RP'])
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel41.1
  class TestSPTRSwissProtRel41_1 < Test::Unit::TestCase
    # New syntax of the CC line topic ALTERNATIVE PRODUCTS
    def test_alternative_products
      data = "ID   TEST_ENTRY      STANDARD;      PRT;   393 AA.
CC   -!- ALTERNATIVE PRODUCTS:
CC       Event=Alternative promoter;
CC         Comment=Free text;
CC       Event=Alternative splicing; Named isoforms=2;
CC         Comment=Optional free text;
CC       Name=Isoform_1; Synonyms=Synonym_1;
CC         IsoId=Isoform_identifier_1;
CC         Sequence=Displayed;
CC         Note=Free text;
CC       Name=Isoform_2; Synonyms=Synonym_1, Synonym_2;
CC         IsoId=Isoform_identifier_1, Isoform_identifer_2; 
CC         Sequence=VSP_identifier_1, VSP_identifier_2;
CC         Note=Free text;
CC       Event=Alternative initiation;
CC         Comment=Free text;"
      sp = SPTR.new(data)
      res = {"Comment" => "Free text",
             "Named isoforms" => "2", 
             "Variants" => [{"Name" => "Isoform_1",
                             "Synonyms" => ["Synonym_1"],
                             "IsoId" => ["Isoform_identifier_1"],
                             "Sequence" => ["Displayed"]   },
                            {"Name" => "Isoform_2",
                             "Synonyms" => ["Synonym_1", "Synonym_2"],
                             "IsoId" => ["Isoform_identifier_1", "Isoform_identifer_2"],
                             "Sequence" => ["VSP_identifier_1", "VSP_identifier_2"]}],
             "Event" => ["Alternative promoter"]}
      assert_equal(res,
                   sp.cc('ALTERNATIVE PRODUCTS'))
    end

    def test_alternative_products_with_ft
data = "ID   TEST_ENTRY      STANDARD;      PRT;   393 AA.
CC   -!- ALTERNATIVE PRODUCTS:
CC       Event=Alternative splicing; Named isoforms=6;
CC       Name=1;
CC         IsoId=Q15746-4; Sequence=Displayed;
CC       Name=2;
CC         IsoId=Q15746-5; Sequence=VSP_000040;
CC       Name=3A;
CC         IsoId=Q15746-6; Sequence=VSP_000041, VSP_000043; 
CC       Name=3B;
CC         IsoId=Q15746-7; Sequence=VSP_000040, VSP_000041, VSP_000042;
CC       Name=4;
CC         IsoId=Q15746-8; Sequence=VSP_000041, VSP_000042;
CC       Name=del-1790;
CC         IsoId=Q15746-9; Sequence=VSP_000044;
FT   VARSPLIC    437    506       VSGIPKPEVAWFLEGTPVRRQEGSIEVYEDAGSHYLCLLKA
FT                                RTRDSGTYSCTASNAQGQVSCSWTLQVER -> G (in
FT                                isoform 2 and isoform 3B).
FT                                /FTId=VSP_004791.
FT   VARSPLIC   1433   1439       DEVEVSD -> MKWRCQT (in isoform 3A,
FT                                isoform 3B and isoform 4).
FT                                /FTId=VSP_004792.
FT   VARSPLIC   1473   1545       Missing (in isoform 4).
FT                                /FTId=VSP_004793.
FT   VARSPLIC   1655   1705       Missing (in isoform 3A and isoform 3B).
FT                                /FTId=VSP_004794.
FT   VARSPLIC   1790   1790       Missing (in isoform Del-1790).
FT                                /FTId=VSP_004795."
      sp = SPTR.new(data)
      
      assert_equal({"Comment" => "",
                    "Named isoforms" => "6",
                    "Variants" => [{"IsoId"=>["Q15746-4"],
                                    "Name"=>"1",
                                    "Synonyms"=>[], 
                                    "Sequence"=>["Displayed"]},
                                   {"IsoId"=>["Q15746-5"],
                                    "Name"=>"2",
                                    "Synonyms"=>[],
                                    "Sequence"=>["VSP_000040"]},
                                   {"IsoId"=>["Q15746-6"],
                                    "Name"=>"3A",
                                    "Synonyms"=>[],
                                    "Sequence"=>["VSP_000041", "VSP_000043"]}, 
                                   {"IsoId"=>["Q15746-7"],  
                                    "Name"=>"3B",  
                                    "Synonyms"=>[], 
                                    "Sequence"=>["VSP_000040", "VSP_000041", "VSP_000042"]},
                                   {"IsoId"=>["Q15746-8"],  
                                    "Name"=>"4", 
                                    "Synonyms"=>[], 
                                    "Sequence"=>["VSP_000041", "VSP_000042"]},
                                   {"IsoId"=>["Q15746-9"],
                                    "Name"=>"del-1790", 
                                    "Synonyms"=>[], 
                                    "Sequence"=>["VSP_000044"]}], 
                    "Event"=>["Alternative splicing"]},
                   sp.cc('ALTERNATIVE PRODUCTS'))
      assert_equal([{"FTId"=>"VSP_004791",
                     "From"=>437,
                     "To"=>506,  
                    "Description"=>"VSGIPKPEVAWFLEGTPVRRQEGSIEVYEDAGSHYLCLLKA RTRDSGTYSCTASNAQGQVSCSWTLQVER -> G (in isoform 2 and isoform 3B).",
                     "diff"=> ["VSGIPKPEVAWFLEGTPVRRQEGSIEVYEDAGSHYLCLLKARTRDSGTYSCTASNAQGQVSCSWTLQVER",    "G"],  
                    "original"=> ["VARSPLIC", "437", "506", "VSGIPKPEVAWFLEGTPVRRQEGSIEVYEDAGSHYLCLLKA RTRDSGTYSCTASNAQGQVSCSWTLQVER -> G (in isoform 2 and isoform 3B).", "/FTId=VSP_004791."]},
                   {"FTId"=>"VSP_004792",
                    "From"=>1433,
                    "diff"=>["DEVEVSD", "MKWRCQT"],
                    "To"=>1439,
                    "original"=> ["VARSPLIC", "1433", "1439", "DEVEVSD -> MKWRCQT (in isoform 3A, isoform 3B and isoform 4).", "/FTId=VSP_004792."], 
                    "Description"=>"DEVEVSD -> MKWRCQT (in isoform 3A, isoform 3B and isoform 4)."},
                   {"FTId"=>"VSP_004793",
                    "From"=>1473,
                    "diff"=>[nil, nil],
                    "To"=>1545, 
                    "original"=> ["VARSPLIC", "1473", "1545", "Missing (in isoform 4).", "/FTId=VSP_004793."], "Description"=>"Missing (in isoform 4)."}, 
                   {"FTId"=>"VSP_004794",
                    "From"=>1655,
                    "diff"=>[nil, nil], 
                    "To"=>1705, 
                    "original"=> ["VARSPLIC", "1655", "1705", "Missing (in isoform 3A and isoform 3B).", "/FTId=VSP_004794."],
                    "Description"=>"Missing (in isoform 3A and isoform 3B)."}, 
                   {"FTId"=>"VSP_004795",
                    "From"=>1790,
                    "diff"=>[nil, nil],
                    "To"=>1790, 
                    "original"=>["VARSPLIC", "1790", "1790", "Missing (in isoform Del-1790).", "/FTId=VSP_004795."],
                    "Description"=>"Missing (in isoform Del-1790)."}],
                   sp.ft['VARSPLIC'])
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel41.10
  class TestSPTRSwissProtRel41_10 < Test::Unit::TestCase
    # Reference Comment (RC) line topics may span lines
    def test_RC_lines
      data = "RN    [1]
RC   STRAIN=AZ.026, DC.005, GA.039, GA2181, IL.014, IN.018, KY.172, KY2.37,
RC   LA.013, MN.001, MNb027, MS.040, NY.016, OH.036, TN.173, TN2.38,
RC   UT.002, AL.012, AZ.180, MI.035, VA.015, and IL2.17;"
      sp = SPTR.new(data)
      assert_equal([{"Text"=>"AZ.026", "Token"=>"STRAIN"}, 
                    {"Text"=>"DC.005", "Token"=>"STRAIN"},
                    {"Text"=>"GA.039", "Token"=>"STRAIN"},
                    {"Text"=>"GA2181", "Token"=>"STRAIN"}, 
                    {"Text"=>"IL.014", "Token"=>"STRAIN"}, 
                    {"Text"=>"IN.018", "Token"=>"STRAIN"}, 
                    {"Text"=>"KY.172", "Token"=>"STRAIN"}, 
                    {"Text"=>"KY2.37", "Token"=>"STRAIN"}, 
                    {"Text"=>"LA.013", "Token"=>"STRAIN"}, 
                    {"Text"=>"MN.001", "Token"=>"STRAIN"}, 
                    {"Text"=>"MNb027", "Token"=>"STRAIN"}, 
                    {"Text"=>"MS.040", "Token"=>"STRAIN"}, 
                    {"Text"=>"NY.016", "Token"=>"STRAIN"}, 
                    {"Text"=>"OH.036", "Token"=>"STRAIN"}, 
                    {"Text"=>"TN.173", "Token"=>"STRAIN"}, 
                    {"Text"=>"TN2.38", "Token"=>"STRAIN"}, 
                    {"Text"=>"UT.002", "Token"=>"STRAIN"},
                    {"Text"=>"AL.012", "Token"=>"STRAIN"}, 
                    {"Text"=>"AZ.180", "Token"=>"STRAIN"}, 
                    {"Text"=>"MI.035", "Token"=>"STRAIN"}, 
                    {"Text"=>"VA.015", "Token"=>"STRAIN"},
                    {"Text"=>"IL2.17", "Token"=>"STRAIN"}],
                   sp.ref.first['RC'])
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel41.20
  class TestSPTRSwissProtRel41_20 < Test::Unit::TestCase
    # Case and wording change for submissions to Swiss-Prot in reference location (RL) lines
    def test_RL_lines
      data = "RL   Submitted (MAY-2002) to the SWISS-PROT data bank."
      sp = SPTR.new(data)
      assert_equal('',
                    sp.ref.first['RL'])
    end

    # New comment line (CC) topic ALLERGEN
    def test_CC_allergen
      data = "CC   -!- ALLERGEN: Causes an allergic reaction in human. Binds IgE. It is a
CC       partially heat-labile allergen that may cause both respiratory and
CC       food-allergy symptoms in patients with the bird-egg syndrome."
      sp = SPTR.new(data)
      assert_equal(["Causes an allergic reaction in human. Binds IgE. It is a partially heat-labile allergen that may cause both respiratory and food-allergy symptoms in patients with the bird-egg syndrome."],
                   sp.cc("ALLERGEN"))
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel42.6
  class TestSPTRSwissProtRel42_6 < Test::Unit::TestCase
    # New comment line (CC) topic RNA EDITING
    def test_CC_rna_editing
      data = "CC   -!- RNA EDITING: Modified_positions=393, 431, 452, 495."
      sp = SPTR.new(data)
      assert_equal({"Note"=>"", 
                    "Modified_positions"=>['393', '431', '452', '495']},
                   sp.cc("RNA EDITING"))

      data = "CC   -!- RNA EDITING: Modified_positions=59, 78, 94, 98, 102, 121; Note=The
CC       stop codon at position 121 is created by RNA editing. The nonsense
CC       codon at position 59 is modified to a sense codon."
      sp = SPTR.new(data)
      assert_equal({"Note"=>"The stop codon at position 121 is created by RNA editing. The nonsense codon at position 59 is modified to a sense codon.", 
                    "Modified_positions"=>['59', '78', '94', '98', '102', '121']},
                   sp.cc("RNA EDITING"))

      data = "CC   -!- RNA EDITING: Modified_positions=Not_applicable; Note=Some
CC       positions are modified by RNA editing via nucleotide insertion or
CC       deletion. The initiator methionine is created by RNA editing."
      sp = SPTR.new(data)
      assert_equal({'Modified_positions' => ['Not_applicable'],
                    'Note' => "Some positions are modified by RNA editing via nucleotide insertion or deletion. The initiator methionine is created by RNA editing."},
                   sp.cc("RNA EDITING"))
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel1_12
  class TestSPTRUniProtRel1_12 < Test::Unit::TestCase
    # Digital Object Identifier (DOI) in the RX line
    def test_DOI_in_RX_line
      # RX   [MEDLINE=Medline_identifier; ][PubMed=Pubmed_identifier; ][DOI=Digital_object_identifier;]
      data = "
RN   [1]
RX   MEDLINE=97291283; PubMed=9145897; DOI=10.1007/s00248-002-2038-4;"
      sp = SPTR.new(data)
      assert_equal({'MEDLINE' => '97291283', 
                    'PubMed' => '9145897', 
                     'DOI' => '10.1007/s00248-002-2038-4'},
                   sp.ref.first['RX'])
    end

    # New line type: RG (Reference Group)
    def test_RG_line
      data = "
RN   [1]
RG   The C. elegans sequencing consortium;
RG   The Brazilian network for HIV isolation and characterization;"
      sp = SPTR.new(data)
      assert_equal(['The C. elegans sequencing consortium', 
                    'The Brazilian network for HIV isolation and characterization'],
                   sp.ref.first['RG'])
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel2_0
  class TestSPTRUniProtRel2_0 < Test::Unit::TestCase
    # New format for the GN (Gene Name) line
    # GN   Name=<name>; Synonyms=<name1>[, <name2>...]; OrderedLocusNames=<name1>[, <name2>...];
    # xsGN   ORFNames=<name1>[, <name2>...];
    def test_GN_line
      data = "GN   Name=atpG; Synonyms=uncG, papC;
GN   OrderedLocusNames=b3733, c4659, z5231, ECs4675, SF3813, S3955;"
      sp = SPTR.new(data)
      assert_equal([{:orfs => [],
                     :loci => ["b3733", "c4659", "z5231", "ECs4675", "SF3813", "S3955"],
                     :name => "atpG",
                     :synonyms => ["uncG", "papC"]}],
                   sp.gn)

      data = "GN   ORFNames=SPAC1834.11c;"
      sp = SPTR.new(data)
      assert_equal([{:orfs => ['SPAC1834.11c'], 
                     :loci => [], 
                     :name => '', 
                     :synonyms => []}],
                   sp.gn)

      data = "GN   Name=cysA1; Synonyms=cysA; OrderedLocusNames=Rv3117, MT3199;
GN   ORFNames=MTCY164.27;
GN   and
GN   Name=cysA2; OrderedLocusNames=Rv0815c, MT0837; ORFNames=MTV043.07c;"
      sp = SPTR.new(data)
      assert_equal([{:orfs => ["MTCY164.27"],
                     :loci => ["Rv3117", "MT3199"],
                     :name => "cysA1", 
                     :synonyms => ["cysA"]},
                    {:orfs => ["MTV043.07c"],
                     :loci => ["Rv0815c", "MT0837"], 
                     :name => "cysA2",
                     :synonyms => []}],
                   sp.gn)
    end
  end

  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel2_1
  class TestSPTRUniProtRel2_1 < Test::Unit::TestCase
    # Format change in the comment line (CC) topic: MASS SPECTROMETRY
    def test_CC_mass_spectrometry
      data = "CC   -!- MASS SPECTROMETRY: MW=32875.93; METHOD=MALDI;
CC       RANGE=1-284 (Isoform 3); NOTE=Ref.6."
      sp = SPTR.new(data)
      assert_equal([{"RANGE"=>"1-284",
                     "METHOD"=>"MALDI",
                     "MW_ERR"=>nil,
                     "NOTE"=>"Ref.6",
                     "MW"=>"32875.93"}],
                   sp.cc("MASS SPECTROMETRY"))
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel2_3
  class TestSPTRUniProtRel2_3 < Test::Unit::TestCase
    # New RL line structure for electronic publications
    def test_RL_line
      data = "RL   Submitted (XXX-YYYY) to the HIV data bank."
      sp = SPTR.new(data)
      assert_equal('',
                   sp.ref.first['RL'])
    end

    # Format change in the cross-reference to PDB
    def test_DR_PDB
      data = "DR   PDB; 1NB3; X-ray; A/B/C/D=116-335, P/R/S/T=98-105."
      sp = SPTR.new(data)
      assert_equal([["1NB3", "X-ray", "A/B/C/D=116-335, P/R/S/T=98-105"]],
                   sp.dr['PDB'])
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel3_4
  class TestSPTRUniProtRel3_4 < Test::Unit::TestCase
    # Changes in the RP (Reference Position) line
    def test_RP_line
      data = "
RN   [1]
RP   NUCLEOTIDE SEQUENCE [LARGE SCALE MRNA] (ISOFORM 1), PROTEIN SEQUENCE 
RP   OF 108-131; 220-231 AND 349-393, CHARACTERIZATION, AND MUTAGENESIS OF 
RP   ARG-336."
      sp = SPTR.new(data)
      assert_equal(['NUCLEOTIDE SEQUENCE [LARGE SCALE MRNA] (ISOFORM 1)', 
                    'PROTEIN SEQUENCE OF 108-131; 220-231 AND 349-393', 
                    'CHARACTERIZATION', 
                    'MUTAGENESIS OF ARG-336'],
                   sp.ref.first['RP'])

      data = "
RN   [1]
RP   NUCLEOTIDE SEQUENCE [GENOMIC DNA / MRNA]."
      sp = SPTR.new(data)
      assert_equal(['NUCLEOTIDE SEQUENCE [GENOMIC DNA / MRNA]'],
                   sp.ref.first['RP'])
    end


    # New comment line (CC) topic: BIOPHYSICOCHEMICAL PROPERTIES
    def test_CC_biophysiochemical_properties
      data = "CC   -!- BIOPHYSICOCHEMICAL PROPERTIES:
CC       Absorption:
CC         Abs(max)=395 nm;
CC         Note=Exhibits a smaller absorbance peak at 470 nm. The
CC         fluorescence emission spectrum peaks at 509 nm with a shoulder
CC         at 540 nm;"
      sp = SPTR.new(data)
      assert_equal({"Redox potential" => "", 
                    "Temperature dependence" => "", 
                    "Kinetic parameters" => {}, 
                    "Absorption" => {"Note" => "Exhibits a smaller absorbance peak at 470 nm. The fluorescence emission spectrum peaks at 509 nm with a shoulder at 540 nm", 
                                     "Abs(max)" => "395 nm"}, 
                    "pH dependence" => ""},
                   sp.cc("BIOPHYSICOCHEMICAL PROPERTIES"))

data = "CC   -!- BIOPHYSICOCHEMICAL PROPERTIES:
CC       Kinetic parameters:
CC         KM=62 mM for glucose;
CC         KM=90 mM for maltose;
CC         Vmax=0.20 mmol/min/mg enzyme with glucose as substrate;
CC         Vmax=0.11 mmol/min/mg enzyme with maltose as substrate;
CC         Note=Acetylates glucose, maltose, mannose, galactose, and
CC         fructose with a decreasing relative rate of 1, 0.55, 0.20, 0.07,
CC         0.04;"
      sp = SPTR.new(data)
      assert_equal({"Redox potential" => "", 
                    "Temperature dependence" => "", 
                    "Kinetic parameters" => {"KM" => "62 mM for glucose; KM=90 mM for maltose",  
                                             "Note" => "Acetylates glucose, maltose, mannose, galactose, and fructose with a decreasing relative rate of 1, 0.55, 0.20, 0.07, 0.04",   
                                             "Vmax" => "0.20 mmol/min/mg enzyme with glucose as substrate"},
                    "Absorption" => {},
                    "pH dependence" => ""},
                   sp.cc("BIOPHYSICOCHEMICAL PROPERTIES"))

data = "CC   -!- BIOPHYSICOCHEMICAL PROPERTIES:
CC       Kinetic parameters:
CC         KM=1.76 uM for chlorophyll;
CC       pH dependence:
CC         Optimum pH is 7.5. Active from pH 5.0 to 9.0;
CC       Temperature dependence:
CC         Optimum temperature is 45 degrees Celsius. Active from 30 to 60
CC         degrees Celsius;"
      sp = SPTR.new(data)
      assert_equal({"Redox potential" => "", 
                    "Temperature dependence" => "Optimum temperature is 45 degrees Celsius. Active from 30 to 60 degrees Celsius", 
                    "Kinetic parameters" => {},
                    "Absorption" => {},
                    "pH dependence" => "Optimum pH is 7.5. Active from pH 5.0 to 9.0"},
                   sp.cc("BIOPHYSICOCHEMICAL PROPERTIES"))
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel3_5
  class TestSPTRUniProtRel3_5 < Test::Unit::TestCase
    # Extension of the Swiss-Prot entry name format
    def test_entry_name_format
      # TBD
    end
  end

  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel4_0
  class TestSPTRUniProtRel4_0 < Test::Unit::TestCase
    # Extension of the TrEMBL entry name format

    # Change of the entry name in many Swiss-Prot entries

    # New comment line (CC) topic: INTERACTION
    def test_CC_interaction
      data = "CC   -!- INTERACTION:
CC       P11450:fcp3c; NbExp=1; IntAct=EBI-126914, EBI-159556;"
      sp = SPTR.new(data)
      assert_equal([{"SP_Ac" => "P11450",
                     "identifier" => "fcp3c",
                     "optional_identifier" => nil,
                     "NbExp" => "1",
                     "IntAct" => ["EBI-126914", "EBI-159556"]}],
                   sp.cc("INTERACTION"))
    end

    def test_CC_interaction_isoform
      data = "CC   -!- INTERACTION:
CC       Q9W1K5-1:cg11299; NbExp=1; IntAct=EBI-133844, EBI-212772;"
      sp = SPTR.new(data)
      assert_equal([{"SP_Ac" => 'Q9W1K5-1',
                     "identifier" => 'cg11299',
                     "optional_identifier" => nil,
                     "NbExp" => "1",
                     "IntAct" => ["EBI-133844", "EBI-212772"]}],
                   sp.cc("INTERACTION"))
    end

    def test_CC_interaction_no_gene_name
      data = "CC   -!- INTERACTION:
CC       Q8NI08:-; NbExp=1; IntAct=EBI-80809, EBI-80799;"
      sp = SPTR.new(data)
      assert_equal([{"SP_Ac" => 'Q8NI08',
                     "identifier" => '-',
                     "optional_identifier" => nil,
                     "NbExp" => "1",
                     "IntAct" => ["EBI-80809", "EBI-80799"]}],
                   sp.cc("INTERACTION"))
    end

    def test_CC_interaction_self_association
      data = "ID   TEST_ENTRY      STANDARD;      PRT;   393 AA.
CC   -!- INTERACTION:
CC       Self; NbExp=1; IntAct=EBI-123485, EBI-123485;"
      sp = SPTR.new(data)
      assert_equal([{"SP_Ac" => 'TEST_ENTRY',
                     "identifier" => 'TEST_ENTRY',
                     "optional_identifier" => nil,
                     "NbExp" => "1",
                     "IntAct" => ["EBI-123485", "EBI-123485"]}],
                   sp.cc("INTERACTION"))
    end

    def test_CC_interaction_The_source_organisms_of_the_interacting_proteins_are_different
      data = "CC   -!- INTERACTION:
CC       Q8C1S0:2410018m14rik (xeno); NbExp=1; IntAct=EBI-394562, EBI-398761;"
      sp = SPTR.new(data)
      assert_equal([{"SP_Ac" => 'Q8C1S0', 
                     "identifier" => '2410018m14rik',
                     "optional_identifier" => '(xeno)',  
                     "NbExp" => "1", 
                     "IntAct" => ["EBI-394562", "EBI-398761"]}],
                   sp.cc("INTERACTION"))
    end

    def test_CC_interaction_Different_isoforms_of_the_current_protein_are_shown_to_interact_with_the_same_protein
      data = "CC   -!- INTERACTION:
CC       P51617:irak1; NbExp=1; IntAct=EBI-448466, EBI-358664;
CC       P51617:irak1; NbExp=1; IntAct=EBI-448472, EBI-358664;"
      sp = SPTR.new(data)
      assert_equal([{"SP_Ac" => "P51617", 
                     "identifier" => "irak1",
                     "optional_identifier" => nil,
                     "NbExp" => "1",
                     "IntAct" => ["EBI-448466", "EBI-358664"]}, 
                    {"SP_Ac" => "P51617",
                     "identifier" => "irak1",
                     "optional_identifier" => nil,
                     "NbExp" => "1",  
                     "IntAct" => ["EBI-448472", "EBI-358664"]}],
                   sp.cc("INTERACTION"))
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel5_0
  class TestSPTRUniProtRel5_0 < Test::Unit::TestCase
    # Format change in the DR line
    # DR   DATABASE_IDENTIFIER; PRIMARY_IDENTIFIER; SECONDARY_IDENTIFIER[; TERTIARY_IDENTIFIER][; QUATERNARY_IDENTIFIER].
    def test_DR_line
      data = "
DR   EMBL; M68939; AAA26107.1; -; Genomic_DNA.
DR   EMBL; U56386; AAB72034.1; -; mRNA."

      sp = SPTR.new(data)
      assert_equal([["M68939", "AAA26107.1", "-", "Genomic_DNA"],
                    ["U56386", "AAB72034.1", "-", "mRNA"]],
                   sp.dr['EMBL'])
      
      assert_equal([{" "=>"-",  
                     "Version"=>"AAA26107.1",  
                     "Accession"=>"M68939",  
                     "Molecular Type"=>"Genomic_DNA"}, 
                    {" "=>"-", 
                     "Version"=>"AAB72034.1",
                     "Accession"=>"U56386", 
                     "Molecular Type"=>"mRNA"}],
                   sp.dr('EMBL'))
                   
    end
    # New feature (FT) keys and redefinition of existing FT keys
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel5_4
  class TestSPTRUniProtRel5_4 < Test::Unit::TestCase
    # Multiple comment line (CC) topics COFACTOR
    def test_multiple_cofactors
      data = "CC   -!- COFACTOR: Binds 1 2Fe-2S cluster per subunit (By similarity).
CC   -!- COFACTOR: Binds 1 Fe(2+) ion per subunit (By similarity)."
      sp = SPTR.new(data)
      assert_equal(["Binds 1 2Fe-2S cluster per subunit (By similarity).", 
                    "Binds 1 Fe(2+) ion per subunit (By similarity)."],
                   sp.cc['COFACTOR'])
      assert_equal(["Binds 1 2Fe-2S cluster per subunit (By similarity).", 
                    "Binds 1 Fe(2+) ion per subunit (By similarity)."],
                   sp.cc('COFACTOR'))
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel6_0
  class TestSPTRUniProtRel6_0 < Test::Unit::TestCase
    # Changes in the OG (OrGanelle) line
    def test_OG_line
      data = "OG   Plastid."
      sp = SPTR.new(data)
      assert_equal(['Plastid'], sp.og)

      data = "OG   Plastid; Apicoplast."
      sp = SPTR.new(data)
      assert_equal(['Plastid', 'Apicoplast'], sp.og)

      data = "OG   Plastid; Chloroplast."
      sp = SPTR.new(data)
      assert_equal(['Plastid', 'Chloroplast'], sp.og)

      data = "OG   Plastid; Cyanelle."
      sp = SPTR.new(data)
      assert_equal(['Plastid', 'Cyanelle'], sp.og)

      data = "OG   Plastid; Non-photosynthetic plastid."
      sp = SPTR.new(data)
      assert_equal(['Plastid', 'Non-photosynthetic plastid'], sp.og)
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel6_1
  class TestSPTRUniProtRel6_1 < Test::Unit::TestCase
    # Annotation changes concerning the feature key METAL
    def test_FT_metal
      old_data = "FT   METAL        61     61       Copper and zinc."
      sp = SPTR.new(old_data)
      assert_equal([{'From' => 61,
                     'To' => 61,
                     'Description' => 'Copper and zinc.',
                     'FTId' =>'',
                     'diff' => [],
                     'original' => ["METAL", "61", "61", "Copper and zinc.", ""]}],
                   sp.ft['METAL'])

      new_data = "FT   METAL        61     61       Copper.
FT   METAL        61     61       Zinc."
      sp = SPTR.new(new_data)
      assert_equal([{"From" => 61, 
                     "To" => 61, 
                     "Description" => "Copper.",
                     "FTId" => "",  
                     "diff" => [], 
                     "original" => ["METAL", "61", "61", "Copper.", ""]},
                    {"From" => 61, 
                     "To" => 61, 
                     "Description" => "Zinc.",
                     "FTId" => "",  
                     "diff" => [], 
                     "original" => ["METAL", "61", "61", "Zinc.", ""]}],
                   sp.ft['METAL'])
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel6_5
  class TestSPTRUniProtRel6_5 < Test::Unit::TestCase
    # Changes in the keywlist.txt file
    # * Modification of the HI line format:
    def test_HI_line
      # HI   Category: Keyword_1; ...; Keyword_n; Described_Keyword.
      # The first term listed in an HI line is a category. It is followed by a hierarchical list of keywords of that category and ends with the described keyword. There can be more than one HI line of the same category in one keyword entry.
      data = "HI   Molecular function: Ionic channel; Calcium channel.
HI   Biological process: Transport; Ion transport; Calcium transport; Calcium channel.
HI   Ligand: Calcium; Calcium channel."
      sp = SPTR.new(data)
      assert_equal([{'Category' => 'Molecular function', 
                     'Keywords' => ['Ionic channel'], 
                     'Keyword' => 'Calcium channel'},
                    {'Category' => 'Biological process',
                     'Keywords' =>  ['Transport', 'Ion transport', 'Calcium transport'],
                     'Keyword' =>  'Calcium channel'},
                    {'Category' => 'Ligand',
                     'Keywords' => ['Calcium'],
                     'Keyword' => 'Calcium channel'}],
                   sp.hi)
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel7.0
  class TestSPTRUniProtRel7_0 < Test::Unit::TestCase
    # Changes concerning dates and versions numbers (DT lines)
    def test_DT_line
      up_sp_data = "DT   01-JAN-1998, integrated into UniProtKB/Swiss-Prot.
DT   15-OCT-2001, sequence version 3.
DT   01-APR-2004, entry version 14."
      sp = SPTR.new(up_sp_data)
      assert_equal({"sequence" => "15-OCT-2001, sequence version 3.", 
                    "annotation" => "01-APR-2004, entry version 14.", 
                    "created" => "01-JAN-1998, integrated into UniProtKB/Swiss-Prot."},
                   sp.dt)

      up_tr_data = "DT   01-FEB-1999, integrated into UniProtKB/TrEMBL.
DT   15-OCT-2000, sequence version 2.
DT   15-DEC-2004, entry version 5."
      sp = SPTR.new(up_tr_data)
      assert_equal({"sequence" => "15-OCT-2000, sequence version 2.", 
                    "annotation" => "15-DEC-2004, entry version 5.",
                    "created" => "01-FEB-1999, integrated into UniProtKB/TrEMBL."},
                   sp.dt)
    end

    # Addition of a feature (FT) key CHAIN over the whole sequence length

    # Changes concerning the copyright statement
    def test_CC_copyright_statement
      data = "CC   -----------------------------------------------------------------------
CC   Copyrighted by the UniProt Consortium, see http://www.uniprot.org/terms
CC   Distributed under the Creative Commons Attribution-NoDerivs License
CC   -----------------------------------------------------------------------"
      sp = SPTR.new(data)
      assert_equal({}, sp.cc)
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel7.6
  class TestSPTRUniProtRel7_6 < Test::Unit::TestCase
    # Sequences with over 10000 amino acids in UniProtKB/Swiss-Prot
    def test_10000aa
      entry_id = 'Q09165'
      data = ["SQ   SEQUENCE   393 AA;  43653 MW;  AD5C149FD8106131 CRC64;\n",
              "     MEEPQSDPSV EPPLSQETFS DLWKLLPENN VLSPLPSQAM DDLMLSPDDI EQWFTEDPGP\n" * 200,
              "//\n"].join
      sp = SPTR.new(data)
      assert(12000, sp.seq.size)
    end
  end


  # Changes in http://br.expasy.org/sprot/relnotes/sp_news.html#rel8.0
  class TestSPTRUniProtRel8_0 < Test::Unit::TestCase
    # Replacement of the feature key VARSPLIC by VAR_SEQ
    def test_FT_VER_SEQ
      data = "FT   VAR_SEQ       1     34       Missing (in isoform 3).
FT                                /FTId=VSP_004099."
      sp = SPTR.new(data)
      res = [{'From' => 1, 
              'To' => 34, 
              'Description' => 'Missing (in isoform 3).', 
              'diff' => ['', nil], 
              'FTId' => 'VSP_004099',
              'original' =>   ["VAR_SEQ", "1", "34", "Missing (in isoform 3).", 
                               "/FTId=VSP_004099."]}]
      assert_equal(res, sp.ft('VAR_SEQ'))
    end

                 
    # Syntax modification of the comment line (CC) topic ALTERNATIVE PRODUCTS
    def test_CC_alternative_products
#  CC   -!- ALTERNATIVE PRODUCTS:
#  CC       Event=Event(, Event)*; Named isoforms=Number_of_isoforms;
# (CC         Comment=Free_text;)?
# (CC       Name=Isoform_name;( Synonyms=Synonym(, Synonym)*;)?
#  CC         IsoId=Isoform_identifier(, Isoform_identifer)*;
#  CC         Sequence=(Displayed|External|Not described|Feature_identifier(, Feature_identifier)*);
# (CC         Note=Free_text;)?)+
# Note: Variable values are represented in italics. Perl-style multipliers indicate whether a pattern (as delimited by parentheses) is optional (?), may occur 0 or more times (*), or 1 or more times (+). Alternative values are separated by a pipe symbol (|).

      data = "CC   -!- ALTERNATIVE PRODUCTS:
CC       Event=Alternative splicing, Alternative initiation; Named isoforms=3;
CC         Comment=Isoform 1 and isoform 2 arise due to the use of two
CC         alternative first exons joined to a common exon 2 at the same
CC         acceptor site but in different reading frames, resulting in two
CC         completely different isoforms;
CC       Name=1; Synonyms=p16INK4a;
CC         IsoId=O77617-1; Sequence=Displayed;
CC       Name=3;
CC         IsoId=O77617-2; Sequence=VSP_004099;
CC         Note=Produced by alternative initiation at Met-35 of isoform 1;
CC       Name=2; Synonyms=p19ARF;
CC         IsoId=O77618-1; Sequence=External;
FT   VAR_SEQ       1     34       Missing (in isoform 3).
FT                                /FTId=VSP_004099."
      sp = SPTR.new(data)
      assert_equal({"Comment" => "Isoform 1 and isoform 2 arise due to the use of two alternative first exons joined to a common exon 2 at the same acceptor site but in different reading frames, resulting in two completely different isoforms", 
                     "Named isoforms" => "3",
                     "Variants" =>  [{"IsoId" => ["O77617-1"], 
                                      "Name" => "1",
                                      "Synonyms" => ["p16INK4a"],
                                      "Sequence" => ["Displayed"]},
                                     {"IsoId" => ["O77617-2"], 
                                      "Name" => "3",
                                      "Synonyms" => [],
                                      "Sequence" => ["VSP_004099"]},
                                     {"IsoId" => ["O77618-1"],
                                      "Name" => "2",
                                      "Synonyms" => ["p19ARF"],
                                      "Sequence" => ["External"]}],
                     "Event" => ["Alternative splicing", "Alternative initiation"]},
                   sp.cc("ALTERNATIVE PRODUCTS"))
      assert_equal([{"From" => 1,  
                      "To" => 34,
                      "Description"=>"Missing (in isoform 3).",
                      "FTId" => "VSP_004099",
                      "diff" => ["", nil],
                      "original"=> ["VAR_SEQ", "1", "34", 
                                    "Missing (in isoform 3).", "/FTId=VSP_004099."]}],
                   sp.ft("VAR_SEQ"))
    end


    # Replacement of the comment line (CC) topic DATABASE by WEB RESOURCE
    def test_CC_web_resource
      # CC   -!- DATABASE: NAME=ResourceName[; NOTE=FreeText][; WWW=WWWAddress][; FTP=FTPAddress].
      # CC   -!- WEB RESOURCE: NAME=ResourceName[; NOTE=FreeText]; URL=WWWAddress.
      # The length of these lines may exceed 75 characters because long URL addresses are not wrapped into multiple lines.
      assert(true)
    end

    # Introduction of the new line type OH (Organism Host) for viral hosts
    def test_OH_lines
      data = 'OS   Tomato black ring virus (strain E) (TBRV).
OC   Viruses; ssRNA positive-strand viruses, no DNA stage; Comoviridae;
OC   Nepovirus; Subgroup B.
OX   NCBI_TaxID=12277;
OH   NCBI_TaxID=4681; Allium porrum (Leek).
OH   NCBI_TaxID=4045; Apium graveolens (Celery).
OH   NCBI_TaxID=161934; Beta vulgaris (Sugar beet).
OH   NCBI_TaxID=38871; Fraxinus (ash trees).
OH   NCBI_TaxID=4236; Lactuca sativa (Garden lettuce).
OH   NCBI_TaxID=4081; Lycopersicon esculentum (Tomato).
OH   NCBI_TaxID=39639; Narcissus pseudonarcissus (Daffodil).
OH   NCBI_TaxID=3885; Phaseolus vulgaris (Kidney bean) (French bean).
OH   NCBI_TaxID=35938; Robinia pseudoacacia (Black locust).
OH   NCBI_TaxID=23216; Rubus (bramble).
OH   NCBI_TaxID=4113; Solanum tuberosum (Potato).
OH   NCBI_TaxID=13305; Tulipa.
OH   NCBI_TaxID=3603; Vitis.'

      res = [{'NCBI_TaxID' => '4681',  'HostName' => 'Allium porrum (Leek)'},
             {'NCBI_TaxID' => '4045',  'HostName' => 'Apium graveolens (Celery)'},
             {'NCBI_TaxID' => '161934', 'HostName' => 'Beta vulgaris (Sugar beet)'},
             {'NCBI_TaxID' => '38871', 'HostName' => 'Fraxinus (ash trees)'},
             {'NCBI_TaxID' => '4236', 'HostName' => 'Lactuca sativa (Garden lettuce)'},
             {'NCBI_TaxID' => '4081', 'HostName' =>  'Lycopersicon esculentum (Tomato)'},
             {'NCBI_TaxID' => '39639', 'HostName' => 'Narcissus pseudonarcissus (Daffodil)'},
             {'NCBI_TaxID' => '3885', 
               'HostName' => 'Phaseolus vulgaris (Kidney bean) (French bean)'},
             {'NCBI_TaxID' => '35938', 'HostName' => 'Robinia pseudoacacia (Black locust)'},
             {'NCBI_TaxID' => '23216', 'HostName' =>  'Rubus (bramble)'},
             {'NCBI_TaxID' => '4113', 'HostName' => 'Solanum tuberosum (Potato)'},
             {'NCBI_TaxID' => '13305', 'HostName' => 'Tulipa'},
             {'NCBI_TaxID' => '3603', 'HostName' => 'Vitis'}]
      sp = SPTR.new(data)
      assert_equal(res, sp.oh)
    end

    def test_OH_line_exception
      data = "ID   TEST_ENTRY      STANDARD;      PRT;   393 AA.
OH   NCBI_TaxID=23216x: Rubus (bramble)."
      sp = SPTR.new(data)
      assert_raise(ArgumentError) { sp.oh }
    end

  end

  class TestOSLine < Test::Unit::TestCase
    def test_uncapitalized_letter_Q32725_9POAL
      data = "OS   unknown cyperaceous sp.\n"
      sp = SPTR.new(data)
      assert_equal('unknown cyperaceous sp.', sp.os.first['os'])
    end

    def test_period_trancation_O63147
      data = "OS   Hippotis sp. Clark and Watts 825.\n"
      sp = SPTR.new(data)
      assert_equal('Hippotis sp. Clark and Watts 825.', sp.os.first['os'])
    end
  end

end # module Bio

