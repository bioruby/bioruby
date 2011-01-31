# To change this template, choose Tools | Templates
# and open the template in the editor.

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio'

module Bio
  class TestBiosqlIO < Test::Unit::TestCase
    def setup
      @connection = Bio::SQL.establish_connection({'development'=>{'hostname'=>'localhost','database'=>"bioseq", 'adapter'=>"jdbcmysql", 'username'=>"febo", 'password'=>nil}},'development')
      @str_genbank=<<END
LOCUS       X64011                   756 bp    DNA     linear   BCT 26-SEP-2006
DEFINITION  Listeria ivanovii sod gene for superoxide dismutase.
ACCESSION   X64011 S78972
VERSION     X64011.1  GI:44010
KEYWORDS    sod gene; superoxide dismutase.
SOURCE      Listeria ivanovii
  ORGANISM  Listeria ivanovii
            Bacteria; Firmicutes; Bacillales; Listeriaceae; Listeria.
REFERENCE   1
  AUTHORS   Haas,A. and Goebel,W.
  TITLE     Cloning of a superoxide dismutase gene from Listeria ivanovii by
            functional complementation in Escherichia coli and characterization
            of the gene product
  JOURNAL   Mol. Gen. Genet. 231 (2), 313-322 (1992)
   PUBMED   1736100
REFERENCE   2  (bases 1 to 756)
  AUTHORS   Kreft,J.
  TITLE     Direct Submission
  JOURNAL   Submitted (21-APR-1992) J. Kreft, Institut f. Mikrobiologie,
            Universitaet Wuerzburg, Biozentrum Am Hubland, 8700 Wuerzburg, FRG
COMMENT     On Jun 23, 2005 this sequence version replaced gi:244394.
FEATURES             Location/Qualifiers
     source          1..756
                     /organism="Listeria ivanovii"
                     /mol_type="genomic DNA"
                     /strain="ATCC 19119"
                     /db_xref="taxon:1638"
     gene            95..746
                     /gene="sod"
     RBS             95..100
                     /gene="sod"
     CDS             109..717
                     /gene="sod"
                     /EC_number="1.15.1.1"
                     /codon_start=1
                     /transl_table=11
                     /product="superoxide dismutase"
                     /protein_id="CAA45406.1"
                     /db_xref="GI:44011"
                     /db_xref="GOA:P28763"
                     /db_xref="InterPro:IPR001189"
                     /db_xref="UniProtKB/Swiss-Prot:P28763"
                     /translation="MTYELPKLPYTYDALEPNFDKETMEIHYTKHHNIYVTKLNEAVS
                     GHAELASKPGEELVANLDSVPEEIRGAVRNHGGGHANHTLFWSSLSPNGGGAPTGNLK
                     AAIESEFGTFDEFKEKFNAAAAARFGSGWAWLVVNNGKLEIVSTANQDSPLSEGKTPV
                     LGLDVWEHAYYLKFQNRRPEYIDTFWNVINWDERNKRFDAAK"
     terminator      723..746
                     /gene="sod"
ORIGIN
        1 cgttatttaa ggtgttacat agttctatgg aaatagggtc tatacctttc gccttacaat
       61 gtaatttctt ttcacataaa taataaacaa tccgaggagg aatttttaat gacttacgaa
      121 ttaccaaaat taccttatac ttatgatgct ttggagccga attttgataa agaaacaatg
      181 gaaattcact atacaaagca ccacaatatt tatgtaacaa aactaaatga agcagtctca
      241 ggacacgcag aacttgcaag taaacctggg gaagaattag ttgctaatct agatagcgtt
      301 cctgaagaaa ttcgtggcgc agtacgtaac cacggtggtg gacatgctaa ccatacttta
      361 ttctggtcta gtcttagccc aaatggtggt ggtgctccaa ctggtaactt aaaagcagca
      421 atcgaaagcg aattcggcac atttgatgaa ttcaaagaaa aattcaatgc ggcagctgcg
      481 gctcgttttg gttcaggatg ggcatggcta gtagtgaaca atggtaaact agaaattgtt
      541 tccactgcta accaagattc tccacttagc gaaggtaaaa ctccagttct tggcttagat
      601 gtttgggaac atgcttatta tcttaaattc caaaaccgtc gtcctgaata cattgacaca
      661 ttttggaatg taattaactg ggatgaacga aataaacgct ttgacgcagc aaaataatta
      721 tcgaaaggct cacttaggtg ggtcttttta tttcta
//
END
    end

    def test_00_connection
      assert_instance_of(ActiveRecord::ConnectionAdapters::ConnectionPool, @connection)
    end

    def test_01_input_is_genbank
      assert_instance_of(Bio::GenBank,Bio::GenBank.new(@str_genbank))
    end

    def test_02_insert_bioentry
      @@x = Bio::SQL::Sequence.new(:biosequence=>Bio::GenBank.new(@str_genbank).to_biosequence, :biodatabase=>Bio::SQL::Biodatabase.find(:first))
      assert_not_nil(@@x)
    end

    def test_03_input_output
      bioseq = Bio::SQL.fetch_accession("X64011")
      assert_not_nil bioseq
      assert_equal(@str_genbank, bioseq.to_biosequence.output(:genbank))
    end

    def test_04_bioentry_data_format
      assert_equal('26-SEP-2006', @@x.date_modified.to_s)
    end

    def test_05_title
      assert_equal('Cloning of a superoxide dismutase gene from Listeria ivanovii by functional complementation in Escherichia coli and characterization of the gene product',@@x.references.first.title)
    end
    def test_99_delete_bioentry
      assert_not_nil(@@x.delete)
    end
  end
end
