#
# = test/unit/bio/io/flatfile/test_autodetection.rb - unit test for Bio::FlatFile::AutoDetect
#
#   Copyright (C) 2006 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id: test_flatfile.rb,v 1.2 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio'

module Bio::TestFlatFile

  # testing default AutoDetect's behavior
  class TestDefaultAutoDetect < Test::Unit::TestCase
    
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__),
                                          ['..'] * 5)).cleanpath.to_s
    TestDataPath = Pathname.new(File.join(bioruby_root,
                                          'test', 'data')).cleanpath.to_s

    def setup
      @ad = Bio::FlatFile::AutoDetect.default
    end

    def test_genbank
      # modified from GenBank AB009803.1
      # (E-mail and telephone/FAX numbers are removed from original entry)
      text = <<__END_OF_TEXT__
LOCUS       AB009803                  81 bp    DNA     linear   PRI 14-APR-2000
DEFINITION  Homo sapiens gene for osteonidogen, intron 4.
ACCESSION   AB009803
VERSION     AB009803.1  GI:2749808
KEYWORDS    osteonidogen.
SOURCE      Homo sapiens (human)
  ORGANISM  Homo sapiens
            Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi;
            Mammalia; Eutheria; Euarchontoglires; Primates; Haplorrhini;
            Catarrhini; Hominidae; Homo.
REFERENCE   1
  AUTHORS   Ohno,I., Okubo,K. and Matsubara,K.
  TITLE     Human osteonidogen gene: intron-exon junctions and chromosomal
            localization
  JOURNAL   Published Only in Database (1998)
REFERENCE   2  (bases 1 to 81)
  AUTHORS   Ohno,I., Okubo,K. and Matsubara,K.
  TITLE     Direct Submission
  JOURNAL   Submitted (13-DEC-1997) Ikko Ohno, Institute for Molecular and
            Cellular Biology, Osaka University, Molecular Genetics; 1-3
            Yamada-oka, Suita, Osaka 565, Japan
FEATURES             Location/Qualifiers
     source          1..81
                     /organism="Homo sapiens"
                     /mol_type="genomic DNA"
                     /db_xref="taxon:9606"
                     /chromosome="14"
                     /map="14q21-22"
                     /clone_lib="Lambda FIX II STRATAGENE"
     intron          1..81
                     /number=4
ORIGIN
        1 gtaggatctc ccctccagat tctgatctgt cctccccctt gcatccaaca cctacttatt
       61 ggccattcta tcctgaaaca g
//
__END_OF_TEXT__
      assert_equal(Bio::GenBank, @ad.autodetect(text))
    end

    def test_genpept
      # modified from: NCBI: P04637.2 GI:129369
      # (to shorten data, many elements are omitted)
      text = <<__END_OF_TEXT__
LOCUS       P04637                   393 aa            linear   PRI 01-JUL-2008
DEFINITION  Cellular tumor antigen p53 (Tumor suppressor p53) (Phosphoprotein
            p53) (Antigen NY-CO-13).
ACCESSION   P04637
VERSION     P04637.2  GI:129369
KEYWORDS    3D-structure; Acetylation; Activator; Alternative splicing;
            Anti-oncogene; Apoptosis; Cell cycle; Covalent protein-RNA linkage;
            Cytoplasm; Disease mutation; DNA-binding; Endoplasmic reticulum;
            Glycoprotein; Host-virus interaction; Li-Fraumeni syndrome;
            Metal-binding; Methylation; Nucleus; Phosphoprotein; Polymorphism;
            Transcription; Transcription regulation; Ubl conjugation; Zinc.
SOURCE      Homo sapiens (human)
  ORGANISM  Homo sapiens
            Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi;
            Mammalia; Eutheria; Euarchontoglires; Primates; Haplorrhini;
            Catarrhini; Hominidae; Homo.
REFERENCE   1  (residues 1 to 393)
  AUTHORS   Zakut-Houri,R., Bienz-Tadmor,B., Givol,D. and Oren,M.
  TITLE     Human p53 cellular tumor antigen: cDNA sequence and expression in
            COS cells
  JOURNAL   EMBO J. 4 (5), 1251-1255 (1985)
   PUBMED   4006916
  REMARK    NUCLEOTIDE SEQUENCE [MRNA].
FEATURES             Location/Qualifiers
     source          1..393
                     /organism="Homo sapiens"
                     /db_xref="taxon:9606"
     gene            1..393
                     /gene="TP53"
                     /note="synonym: P53"
     Protein         1..393
                     /gene="TP53"
                     /product="Cellular tumor antigen p53"
ORIGIN
        1 meepqsdpsv epplsqetfs dlwkllpenn vlsplpsqam ddlmlspddi eqwftedpgp
       61 deaprmpeaa ppvapapaap tpaapapaps wplsssvpsq ktyqgsygfr lgflhsgtak
      121 svtctyspal nkmfcqlakt cpvqlwvdst pppgtrvram aiykqsqhmt evvrrcphhe
      181 rcsdsdglap pqhlirvegn lrveylddrn tfrhsvvvpy eppevgsdct tihynymcns
      241 scmggmnrrp iltiitleds sgnllgrnsf evrvcacpgr drrteeenlr kkgephhelp
      301 pgstkralpn ntssspqpkk kpldgeyftl qirgrerfem frelnealel kdaqagkepg
      361 gsrahsshlk skkgqstsrh kklmfktegp dsd
//
__END_OF_TEXT__

      assert_equal(Bio::GenPept, @ad.autodetect(text))
    end

    def test_medline
      # PMID: 13054692
      text = <<__END_OF_TEXT__
PMID- 13054692
OWN - NLM
STAT- MEDLINE
DA  - 19531201
DCOM- 20030501
LR  - 20061115
PUBM- Print
IS  - 0028-0836 (Print)
VI  - 171
IP  - 4356
DP  - 1953 Apr 25
TI  - Molecular structure of nucleic acids; a structure for deoxyribose nucleic acid.
PG  - 737-8
FAU - WATSON, J D
AU  - WATSON JD
FAU - CRICK, F H
AU  - CRICK FH
LA  - eng
PT  - Journal Article
PL  - Not Available
TA  - Nature
JT  - Nature
JID - 0410462
RN  - 0 (Nucleic Acids)
SB  - OM
MH  - *Nucleic Acids
OID - CLML: 5324:25254:447
OTO - NLM
OT  - *NUCLEIC ACIDS
EDAT- 1953/04/25
MHDA- 1953/04/25 00:01
PST - ppublish
SO  - Nature. 1953 Apr 25;171(4356):737-8.
__END_OF_TEXT__

      assert_equal(Bio::MEDLINE, @ad.autodetect(text))
    end

    def test_embl_oldrelease
      fn = File.join(TestDataPath, 'embl', 'AB090716.embl')
      text = File.read(fn)
      assert_equal(Bio::EMBL, @ad.autodetect(text))
    end

    def test_embl
      fn = File.join(TestDataPath, 'embl', 'AB090716.embl.rel89')
      text = File.read(fn)
      assert_equal(Bio::EMBL, @ad.autodetect(text))
    end

    def test_sptr
      fn = File.join(TestDataPath, 'uniprot', 'p53_human.uniprot')
      text = File.read(fn)
      assert_equal(Bio::SPTR, @ad.autodetect(text))
    end

    def test_prosite
      fn = File.join(TestDataPath, 'prosite', 'prosite.dat')
      text = File.read(fn)
      assert_equal(Bio::PROSITE, @ad.autodetect(text))
    end

    def test_transfac
      # Dummy data; Generated from random data
      text = <<__END_OF_TEXT__
AC  M99999
XX
ID  V$XXXX_99
XX
DT  13.01.98 (created); ewi.
DT  31.12.99 (updated); ewi.
XX
NA  XXXX
XX
DE  example gene protein
XX
BF  T99998; XXXX; Species: human, Homo sapiens.
BF  T99999; XXXX; Species: mouse, Mus musculus.
XX
P0      A      C      G      T
01      1      2      2      2      N
02      0      2      2      3      N
03      1      1      5      0      G
04      3      1      1      2      N
05      7      0      0      0      A
06      2      0      1      4      W
07      0      1      6      0      G
08      0      3      0      4      Y
09      6      1      0      0      A
10      1      1      0      5      T
XX
BA  7 functional elements in 3 genes
XX
CC  compiled sequences
XX
RN  [1]
RA  Anonymou S., Whoam I.
RT  Example article title for XXXX
RL  J. Example. 99:990-999 (1999).
__END_OF_TEXT__

      assert_equal(Bio::TRANSFAC, @ad.autodetect(text))
    end

    def test_aaindex1
      fn = File.join(TestDataPath, 'aaindex', 'PRAM900102')
      text = File.read(fn)
      assert_equal(Bio::AAindex1, @ad.autodetect(text))
    end

    def test_aaindex2
      fn = File.join(TestDataPath, 'aaindex', 'DAYM780301')
      text = File.read(fn)
      assert_equal(Bio::AAindex2, @ad.autodetect(text))
    end

#    def test_litdb
#    end

#    def test_brite
#    end

#    def test_orthology
#    end

#    def test_drug
#    end

#    def test_glycan
#    end

#    def test_enzyme
#    end

#    def test_compound
#    end

#    def test_reaction
#    end

#    def test_genes
#    end

#    def test_genome
#    end

    def test_maxml_cluster
      # dummy empty data
      text = <<__END_OF_TEXT__
<?xml version="1.0"?>
<!DOCTYPE maxml-clusters SYSTEM "http://fantom.gsc.riken.go.jp/maxml/maxml.dtd"><maxml-clusters>
</maxml-clusters>
__END_OF_TEXT__
      assert_equal(Bio::FANTOM::MaXML::Cluster, @ad.autodetect(text))
    end

    def test_maxml_sequence
      # dummy empty data
      text = <<__END_OF_TEXT__
<?xml version="1.0"?>
<!DOCTYPE maxml-sequences SYSTEM "http://fantom.gsc.riken.go.jp/maxml/maxml.dtd">
<maxml-sequences>
</maxml-sequences>
__END_OF_TEXT__
      assert_equal(Bio::FANTOM::MaXML::Sequence, @ad.autodetect(text))
    end

#    def test_pdb
#    end

#    def test_chemicalcomponent
#    end

#    def test_clustal
#    end

#    def test_gcg_msf
#    end

#    def test_gcg_seq
#    end

    def test_blastxml
      fn = File.join(TestDataPath, 'blast', '2.2.15.blastp.m7')
      text = File.read(fn)
      assert_equal(Bio::Blast::Report, @ad.autodetect(text))
    end

#    def test_wublast
#    end

#    def test_wutblast
#    end

    def test_blast
      fn = File.join(TestDataPath, 'blast', 'b0002.faa.m0')
      text = File.read(fn)
      assert_equal(Bio::Blast::Default::Report, @ad.autodetect(text))
    end

#    def test_tblast
#    end

#    def test_blat
#    end

#    def test_spidey
#    end

    def test_hmmer
      fn = File.join(TestDataPath, 'HMMER', 'hmmpfam.out')
      text = File.read(fn)
      assert_equal(Bio::HMMER::Report, @ad.autodetect(text))

      fn = File.join(TestDataPath, 'HMMER', 'hmmsearch.out')
      text = File.read(fn)
      assert_equal(Bio::HMMER::Report, @ad.autodetect(text))
    end

#    def test_sim4
#    end

    def test_fastaformat
      fn = File.join(TestDataPath, 'fasta', 'example1.txt')
      text = File.read(fn)
      assert_equal(Bio::FastaFormat, @ad.autodetect(text))

      fn = File.join(TestDataPath, 'fasta', 'example2.txt')
      text = File.read(fn)
      assert_equal(Bio::FastaFormat, @ad.autodetect(text))
    end

    def test_fastanumericformat
      text = <<__END_OF_TEXT__
>sample
30 21 16 11 8 6 3 34 28 34 28 28 35 28 28 37 33 15 27 28 28 
27 37 33 17 27 27 28 28 33 26 33 26 28 27 37 33 15 27 26 27 
28 37 33 16 34 26 27 33 26 28 33 25 28 28 38 34 23 13 2
__END_OF_TEXT__

      assert_equal(Bio::FastaNumericFormat, @ad.autodetect(text))
    end

  end #class TestDefaultAutoDetect

end #module Bio::TestFlatFile

