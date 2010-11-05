#
# test/unit/bio/db/genbank/test_genbank.rb - Unit test for Bio::GenBank
#
# Copyright::  Copyright (C) 2010 Kazuhiro Hayashi <k.hayashi.info@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/reference'
require 'bio/feature'
require 'bio/compat/features'
require 'bio/compat/references'
require 'bio/db/genbank/genbank'
require 'bio/db/genbank/genbank_to_biosequence'


module Bio
  class TestBioGenBank < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'genbank', 'SCU49845.gb')
      @obj = Bio::GenBank.new(File.read(filename))
    end

    def test_locus_class
      expected = Bio::GenBank::Locus
      assert_equal(expected, @obj.locus.class)
      locus_rel126 = "LOCUS       AB000383     5423 bp    DNA   circular  VRL       05-FEB-1999"#another type of LOCUS line.(release 126)
      obj_rel126 = Bio::GenBank.new(locus_rel126)
      assert_equal(Bio::GenBank::Locus, obj_rel126.locus.class)
    end
    def test_locus_circular
       expected = "linear"
       assert_equal(expected, @obj.locus.circular)
       locus_rel126 = "LOCUS       AB000383     5423 bp    DNA   circular  VRL       05-FEB-1999"
       obj_rel126 = Bio::GenBank.new(locus_rel126)
       assert_equal("circular", obj_rel126.locus.circular)
    end
    def test_locus_date
       expected = "23-MAR-2010"
       assert_equal(expected, @obj.locus.date)
       locus_rel126 = "LOCUS       AB000383     5423 bp    DNA   circular  VRL       05-FEB-1999"
       obj_rel126 = Bio::GenBank.new(locus_rel126)
       assert_equal("05-FEB-1999", obj_rel126.locus.date)
    end
    def test_locus_division
       expected = "PLN"
       assert_equal(expected, @obj.locus.division)
       locus_rel126 = "LOCUS       AB000383     5423 bp    DNA   circular  VRL       05-FEB-1999"
       obj_rel126 = Bio::GenBank.new(locus_rel126)
       assert_equal("VRL", obj_rel126.locus.division)
    end
    def test_locus_entry_id
       expected = "SCU49845"
       assert_equal(expected, @obj.locus.entry_id)
       locus_rel126 = "LOCUS       AB000383     5423 bp    DNA   circular  VRL       05-FEB-1999"
       obj_rel126 = Bio::GenBank.new(locus_rel126)
       assert_equal("AB000383", obj_rel126.locus.entry_id)
    end
    def test_locus_length
       expected = 5028
       assert_equal(expected, @obj.locus.length)
       locus_rel126 = "LOCUS       AB000383     5423 bp    DNA   circular  VRL       05-FEB-1999"
       obj_rel126 = Bio::GenBank.new(locus_rel126)
       assert_equal(5423, obj_rel126.locus.length)
    end
    def test_locus_natype
       expected = "DNA"
       assert_equal(expected, @obj.locus.natype)
       locus_rel126 = "LOCUS       AB000383     5423 bp    DNA   circular  VRL       05-FEB-1999"
       obj_rel126 = Bio::GenBank.new(locus_rel126)
       assert_equal("DNA", obj_rel126.locus.natype)
    end
    def test_locus_strand
       expected = ""
       assert_equal(expected, @obj.locus.strand)
       locus_rel126 = "LOCUS       AB000383     5423 bp    DNA   circular  VRL       05-FEB-1999"
       obj_rel126 = Bio::GenBank.new(locus_rel126)
       assert_equal("", obj_rel126.locus.strand)
    end
    def test_entry_id
      assert_equal("SCU49845", @obj.entry_id)
    end

    def test_length
      assert_equal(5028, @obj.length)
    end

    def test_circular
      assert_equal("linear", @obj.circular)
    end

    def test_division
      assert_equal("PLN", @obj.division)
    end

    def test_date
      assert_equal("23-MAR-2010", @obj.date)
    end

    def test_strand
      assert_equal("", @obj.strand)
    end

    def test_natype
      assert_equal("DNA", @obj.natype)
    end

    def test_each_cds_feature
      @obj.each_cds do |feature|
        assert_equal("CDS", feature.feature)
      end
    end
=begin
    def test_each_cds_qualifiers
      @obj.each_cds do |feature|
        feature.qualifiers do |qualifier|
          assert_equal(Bio::Feature::Qualifier, qualifier.class)
        end
      end
    end
=end
    def test_each_cds_qualifiers
      expected = [[["codon_start", 3],
                ["product", "TCP1-beta"],
                ["protein_id", "AAA98665.1"],
                ["db_xref", "GI:1293614"],
                ["translation", "SSIYNGISTSGLDLNNGTIADMRQLGIVESYKLKRAVVSSASEAAEVLLRVDNIIRARPRTANRQHM"]],
                [["gene", "AXL2"],
                ["note", "plasma membrane glycoprotein"],
                ["codon_start", 1],
                ["product", "Axl2p"],
                ["protein_id", "AAA98666.1"],
                ["db_xref", "GI:1293615"],
                ["translation", "MTQLQISLLLTATISLLHLVVATPYEAYPIGKQYPPVARVNESFTFQISNDTYKSSVDKTAQITYNCFDLPSWLSFDSSSRTFSGEPSSDLLSDANTTLYFNVILEGTDSADSTSLNNTYQFVVTNRPSISLSSDFNLLALLKNYGYTNGKNALKLDPNEVFNVTFDRSMFTNEESIVSYYGRSQLYNAPLPNWLFFDSGELKFTGTAPVINSAIAPETSYSFVIIATDIEGFSAVEVEFELVIGAHQLTTSIQNSLIINVTDTGNVSYDLPLNYVYLDDDPISSDKLGSINLLDAPDWVALDNATISGSVPDELLGKNSNPANFSVSIYDTYGDVIYFNFEVVSTTDLFAISSLPNINATRGEWFSYYFLPSQFTDYVNTNVSLEFTNSSQDHDWVKFQSSNLTLAGEVPKNFDKLSLGLKANQGSQSQELYFNIIGMDSKITHSNHSANATSTRSSHHSTSTSSYTSSTYTAKISSTSAAATSSAPAALPAANKTSSHNKKAVAIACGVAIPLGVILVALICFLIFWRRRRENPDDENLPHAISGPDLNNPANKPNQENATPLNNPFDDDASSYDDTSIARRLAALNTLKLDNHSATESDISSVDEKRDSLSGMNTYNDQFQSQSKEELLAKPPVQPPESPFFDPQNRSSSVYMDSEPAVNKSWRYTGNLSPVSDIVRDSYGSQKTVDTEKLFDLEAPEKEKRTSRDVTMSSLDPWNSNISPSPVRKSVTPSPYNVTKHRNRHLQNIQDSQSGKNGITPTTMSTSSSDDFVPVKDGENFCWVHSMEPDRRPSKKRLVDFSNKSNVNVGQVKDIHGRIPEML"]],
               [["gene", "REV7"],
                ["codon_start", 1],
                ["product", "Rev7p"],
                ["protein_id", "AAA98667.1"],
                ["db_xref", "GI:1293616"],
["translation", "MNRWVEKWLRVYLKCYINLILFYRNVYPPQSFDYTTYQSFNLPQFVPINRHPALIDYIEELILDVLSKLTHVYRFSICIINKKNDLCIEKYVLDFSELQHVDKDDQIITETEVFDEFRSSLNSLIMHLEKLPKVNDDTITFEAVINAIELELGHKLDRNRRVDSLEEKAEIERDSNWVKCQEDENLPDNNGFQPPKIKLTSLVGSDVGPLIIHQFSEKLISGDDKILNGVYSQYEEGESIFGSLF"]]]
      actual = []
      @obj.each_cds do |feature|
        tmp = []
        feature.qualifiers.each{|qualifier| 
          tmp << [qualifier.qualifier, qualifier.value]
        }
        actual << tmp
      end
      assert_equal(expected, actual)
    end
    def test_each_gene
      expected_position = ["<687..>3158", "complement(<3300..>4037)"]
      expected_gene = [["gene","AXL2"], ["gene","REV7"]]
      actual_position = []
      actual_gene = []
      @obj.each_gene do |gene| 
        assert_equal("gene", gene.feature)
        actual_position << gene.position
        gene.qualifiers.each do |qualifier| 
          actual_gene << [qualifier.qualifier, qualifier.value]
        end
      end
      assert_equal(expected_position,actual_position)
      assert_equal(expected_gene, actual_gene)
    end

    def test_basecount
      assert_equal({}, @obj.basecount)
    end

    def test_seq
      expected = "gatcctccatatacaacggtatctccacctcaggtttagatctcaacaacggaaccattgccgacatgagacagttaggtatcgtcgagagttacaagctaaaacgagcagtagtcagctctgcatctgaagccgctgaagttctactaagggtggataacatcatccgtgcaagaccaagaaccgccaatagacaacatatgtaacatatttaggatatacctcgaaaataataaaccgccacactgtcattattataattagaaacagaacgcaaaaattatccactatataattcaaagacgcgaaaaaaaaagaacaacgcgtcatagaacttttggcaattcgcgtcacaaataaattttggcaacttatgtttcctcttcgagcagtactcgagccctgtctcaagaatgtaataatacccatcgtaggtatggttaaagatagcatctccacaacctcaaagctccttgccgagagtcgccctcctttgtcgagtaattttcacttttcatatgagaacttattttcttattctttactctcacatcctgtagtgattgacactgcaacagccaccatcactagaagaacagaacaattacttaatagaaaaattatatcttcctcgaaacgatttcctgcttccaacatctacgtatatcaagaagcattcacttaccatgacacagcttcagatttcattattgctgacagctactatatcactactccatctagtagtggccacgccctatgaggcatatcctatcggaaaacaataccccccagtggcaagagtcaatgaatcgtttacatttcaaatttccaatgatacctataaatcgtctgtagacaagacagctcaaataacatacaattgcttcgacttaccgagctggctttcgtttgactctagttctagaacgttctcaggtgaaccttcttctgacttactatctgatgcgaacaccacgttgtatttcaatgtaatactcgagggtacggactctgccgacagcacgtctttgaacaatacataccaatttgttgttacaaaccgtccatccatctcgctatcgtcagatttcaatctattggcgttgttaaaaaactatggttatactaacggcaaaaacgctctgaaactagatcctaatgaagtcttcaacgtgacttttgaccgttcaatgttcactaacgaagaatccattgtgtcgtattacggacgttctcagttgtataatgcgccgttacccaattggctgttcttcgattctggcgagttgaagtttactgggacggcaccggtgataaactcggcgattgctccagaaacaagctacagttttgtcatcatcgctacagacattgaaggattttctgccgttgaggtagaattcgaattagtcatcggggctcaccagttaactacctctattcaaaatagtttgataatcaacgttactgacacaggtaacgtttcatatgacttacctctaaactatgtttatctcgatgacgatcctatttcttctgataaattgggttctataaacttattggatgctccagactgggtggcattagataatgctaccatttccgggtctgtcccagatgaattactcggtaagaactccaatcctgccaatttttctgtgtccatttatgatacttatggtgatgtgatttatttcaacttcgaagttgtctccacaacggatttgtttgccattagttctcttcccaatattaacgctacaaggggtgaatggttctcctactattttttgccttctcagtttacagactacgtgaatacaaacgtttcattagagtttactaattcaagccaagaccatgactgggtgaaattccaatcatctaatttaacattagctggagaagtgcccaagaatttcgacaagctttcattaggtttgaaagcgaaccaaggttcacaatctcaagagctatattttaacatcattggcatggattcaaagataactcactcaaaccacagtgcgaatgcaacgtccacaagaagttctcaccactccacctcaacaagttcttacacatcttctacttacactgcaaaaatttcttctacctccgctgctgctacttcttctgctccagcagcgctgccagcagccaataaaacttcatctcacaataaaaaagcagtagcaattgcgtgcggtgttgctatcccattaggcgttatcctagtagctctcatttgcttcctaatattctggagacgcagaagggaaaatccagacgatgaaaacttaccgcatgctattagtggacctgatttgaataatcctgcaaataaaccaaatcaagaaaacgctacacctttgaacaacccctttgatgatgatgcttcctcgtacgatgatacttcaatagcaagaagattggctgctttgaacactttgaaattggataaccactctgccactgaatctgatatttccagcgtggatgaaaagagagattctctatcaggtatgaatacatacaatgatcagttccaatcccaaagtaaagaagaattattagcaaaacccccagtacagcctccagagagcccgttctttgacccacagaataggtcttcttctgtgtatatggatagtgaaccagcagtaaataaatcctggcgatatactggcaacctgtcaccagtctctgatattgtcagagacagttacggatcacaaaaaactgttgatacagaaaaacttttcgatttagaagcaccagagaaggaaaaacgtacgtcaagggatgtcactatgtcttcactggacccttggaacagcaatattagcccttctcccgtaagaaaatcagtaacaccatcaccatataacgtaacgaagcatcgtaaccgccacttacaaaatattcaagactctcaaagcggtaaaaacggaatcactcccacaacaatgtcaacttcatcttctgacgattttgttccggttaaagatggtgaaaatttttgctgggtccatagcatggaaccagacagaagaccaagtaagaaaaggttagtagatttttcaaataagagtaatgtcaatgttggtcaagttaaggacattcacggacgcatcccagaaatgctgtgattatacgcaacgatattttgcttaattttattttcctgttttattttttattagtggtttacagataccctatattttatttagtttttatacttagagacatttaattttaattccattcttcaaatttcatttttgcacttaaaacaaagatccaaaaatgctctcgccctcttcatattgagaatacactccattcaaaattttgtcgtcaccgctgattaatttttcactaaactgatgaataatcaaaggccccacgtcagaaccgactaaagaagtgagttttattttaggaggttgaaaaccattattgtctggtaaattttcatcttcttgacatttaacccagtttgaatccctttcaatttctgctttttcctccaaactatcgaccctcctgtttctgtccaacttatgtcctagttccaattcgatcgcattaataactgcttcaaatgttattgtgtcatcgttgactttaggtaatttctccaaatgcataatcaaactatttaaggaagatcggaattcgtcgaacacttcagtttccgtaatgatctgatcgtctttatccacatgttgtaattcactaaaatctaaaacgtatttttcaatgcataaatcgttctttttattaataatgcagatggaaaatctgtaaacgtgcgttaatttagaaagaacatccagtataagttcttctatatagtcaattaaagcaggatgcctattaatgggaacgaactgcggcaagttgaatgactggtaagtagtgtagtcgaatgactgaggtgggtatacatttctataaaataaaatcaaattaatgtagcattttaagtataccctcagccacttctctacccatctattcataaagctgacgcaacgattactattttttttttcttcttggatctcagtcgtcgcaaaaacgtataccttctttttccgaccttttttttagctttctggaaaagtttatattagttaaacagggtctagtcttagtgtgaaagctagtggtttcgattgactgatattaagaaagtggaaattaaattagtagtgtagacgtatatgcatatgtatttctcgcctgtttatgtttctacgtacttttgatttatagcaaggggaaaagaaatacatactattttttggtaaaggtgaaagcataatgtaaaagctagaataaaatggacgaaataaagagaggcttagttcatcttttttccaaaaagcacccaatgataataactaaaatgaaaaggatttgccatctgtcagcaacatcagttgtgtgagcaataataaaatcatcacctccgttgcctttagcgcgtttgtcgtttgtatcttccgtaattttagtcttatcaatgggaatcataaattttccaatgaattagcaatttcgtccaattctttttgagcttcttcatatttgctttggaattcttcgcacttcttttcccattcatctctttcttcttccaaagcaacgatccttctacccatttgctcagagttcaaatcggcctctttcagtttatccattgcttccttcagtttggcttcactgtcttctagctgttgttctagatcctggtttttcttggtgtagttctcattattagatctcaagttattggagtcttcagccaattgctttgtatcagacaattgactctctaacttctccacttcactgtcgagttgctcgtttttagcggacaaagatttaatctcgttttctttttcagtgttagattgctctaattctttgagctgttctctcagctcctcatatttttcttgccatgactcagattctaattttaagctattcaatttctctttgatc"
      assert_equal(expected, @obj.seq)
    end

    def test_seq_len
      assert_equal(5028, @obj.seq_len)
    end

    def test_date_modified
      assert_equal(Date, @obj.date_modified.class)
      assert_equal('2010-03-23', @obj.date_modified.to_s)
    end
 
   def test_classification
      expected = ["Eukaryota",
 "Fungi",
 "Dikarya",
 "Ascomycota",
 "Saccharomyceta",
 "Saccharomycotina",
 "Saccharomycetes",
 "Saccharomycetales",
 "Saccharomycetaceae",
 "Saccharomyces"]
      assert_equal(expected, @obj.classification)
    end

    def test_strandedness
      assert_equal(nil, @obj.strandedness)
    end

    #test for bio_to_sequence
    def test_to_biosequence
      seq = @obj.to_biosequence
      expected_seq = "gatcctccatatacaacggtatctccacctcaggtttagatctcaacaacggaaccattgccgacatgagacagttaggtatcgtcgagagttacaagctaaaacgagcagtagtcagctctgcatctgaagccgctgaagttctactaagggtggataacatcatccgtgcaagaccaagaaccgccaatagacaacatatgtaacatatttaggatatacctcgaaaataataaaccgccacactgtcattattataattagaaacagaacgcaaaaattatccactatataattcaaagacgcgaaaaaaaaagaacaacgcgtcatagaacttttggcaattcgcgtcacaaataaattttggcaacttatgtttcctcttcgagcagtactcgagccctgtctcaagaatgtaataatacccatcgtaggtatggttaaagatagcatctccacaacctcaaagctccttgccgagagtcgccctcctttgtcgagtaattttcacttttcatatgagaacttattttcttattctttactctcacatcctgtagtgattgacactgcaacagccaccatcactagaagaacagaacaattacttaatagaaaaattatatcttcctcgaaacgatttcctgcttccaacatctacgtatatcaagaagcattcacttaccatgacacagcttcagatttcattattgctgacagctactatatcactactccatctagtagtggccacgccctatgaggcatatcctatcggaaaacaataccccccagtggcaagagtcaatgaatcgtttacatttcaaatttccaatgatacctataaatcgtctgtagacaagacagctcaaataacatacaattgcttcgacttaccgagctggctttcgtttgactctagttctagaacgttctcaggtgaaccttcttctgacttactatctgatgcgaacaccacgttgtatttcaatgtaatactcgagggtacggactctgccgacagcacgtctttgaacaatacataccaatttgttgttacaaaccgtccatccatctcgctatcgtcagatttcaatctattggcgttgttaaaaaactatggttatactaacggcaaaaacgctctgaaactagatcctaatgaagtcttcaacgtgacttttgaccgttcaatgttcactaacgaagaatccattgtgtcgtattacggacgttctcagttgtataatgcgccgttacccaattggctgttcttcgattctggcgagttgaagtttactgggacggcaccggtgataaactcggcgattgctccagaaacaagctacagttttgtcatcatcgctacagacattgaaggattttctgccgttgaggtagaattcgaattagtcatcggggctcaccagttaactacctctattcaaaatagtttgataatcaacgttactgacacaggtaacgtttcatatgacttacctctaaactatgtttatctcgatgacgatcctatttcttctgataaattgggttctataaacttattggatgctccagactgggtggcattagataatgctaccatttccgggtctgtcccagatgaattactcggtaagaactccaatcctgccaatttttctgtgtccatttatgatacttatggtgatgtgatttatttcaacttcgaagttgtctccacaacggatttgtttgccattagttctcttcccaatattaacgctacaaggggtgaatggttctcctactattttttgccttctcagtttacagactacgtgaatacaaacgtttcattagagtttactaattcaagccaagaccatgactgggtgaaattccaatcatctaatttaacattagctggagaagtgcccaagaatttcgacaagctttcattaggtttgaaagcgaaccaaggttcacaatctcaagagctatattttaacatcattggcatggattcaaagataactcactcaaaccacagtgcgaatgcaacgtccacaagaagttctcaccactccacctcaacaagttcttacacatcttctacttacactgcaaaaatttcttctacctccgctgctgctacttcttctgctccagcagcgctgccagcagccaataaaacttcatctcacaataaaaaagcagtagcaattgcgtgcggtgttgctatcccattaggcgttatcctagtagctctcatttgcttcctaatattctggagacgcagaagggaaaatccagacgatgaaaacttaccgcatgctattagtggacctgatttgaataatcctgcaaataaaccaaatcaagaaaacgctacacctttgaacaacccctttgatgatgatgcttcctcgtacgatgatacttcaatagcaagaagattggctgctttgaacactttgaaattggataaccactctgccactgaatctgatatttccagcgtggatgaaaagagagattctctatcaggtatgaatacatacaatgatcagttccaatcccaaagtaaagaagaattattagcaaaacccccagtacagcctccagagagcccgttctttgacccacagaataggtcttcttctgtgtatatggatagtgaaccagcagtaaataaatcctggcgatatactggcaacctgtcaccagtctctgatattgtcagagacagttacggatcacaaaaaactgttgatacagaaaaacttttcgatttagaagcaccagagaaggaaaaacgtacgtcaagggatgtcactatgtcttcactggacccttggaacagcaatattagcccttctcccgtaagaaaatcagtaacaccatcaccatataacgtaacgaagcatcgtaaccgccacttacaaaatattcaagactctcaaagcggtaaaaacggaatcactcccacaacaatgtcaacttcatcttctgacgattttgttccggttaaagatggtgaaaatttttgctgggtccatagcatggaaccagacagaagaccaagtaagaaaaggttagtagatttttcaaataagagtaatgtcaatgttggtcaagttaaggacattcacggacgcatcccagaaatgctgtgattatacgcaacgatattttgcttaattttattttcctgttttattttttattagtggtttacagataccctatattttatttagtttttatacttagagacatttaattttaattccattcttcaaatttcatttttgcacttaaaacaaagatccaaaaatgctctcgccctcttcatattgagaatacactccattcaaaattttgtcgtcaccgctgattaatttttcactaaactgatgaataatcaaaggccccacgtcagaaccgactaaagaagtgagttttattttaggaggttgaaaaccattattgtctggtaaattttcatcttcttgacatttaacccagtttgaatccctttcaatttctgctttttcctccaaactatcgaccctcctgtttctgtccaacttatgtcctagttccaattcgatcgcattaataactgcttcaaatgttattgtgtcatcgttgactttaggtaatttctccaaatgcataatcaaactatttaaggaagatcggaattcgtcgaacacttcagtttccgtaatgatctgatcgtctttatccacatgttgtaattcactaaaatctaaaacgtatttttcaatgcataaatcgttctttttattaataatgcagatggaaaatctgtaaacgtgcgttaatttagaaagaacatccagtataagttcttctatatagtcaattaaagcaggatgcctattaatgggaacgaactgcggcaagttgaatgactggtaagtagtgtagtcgaatgactgaggtgggtatacatttctataaaataaaatcaaattaatgtagcattttaagtataccctcagccacttctctacccatctattcataaagctgacgcaacgattactattttttttttcttcttggatctcagtcgtcgcaaaaacgtataccttctttttccgaccttttttttagctttctggaaaagtttatattagttaaacagggtctagtcttagtgtgaaagctagtggtttcgattgactgatattaagaaagtggaaattaaattagtagtgtagacgtatatgcatatgtatttctcgcctgtttatgtttctacgtacttttgatttatagcaaggggaaaagaaatacatactattttttggtaaaggtgaaagcataatgtaaaagctagaataaaatggacgaaataaagagaggcttagttcatcttttttccaaaaagcacccaatgataataactaaaatgaaaaggatttgccatctgtcagcaacatcagttgtgtgagcaataataaaatcatcacctccgttgcctttagcgcgtttgtcgtttgtatcttccgtaattttagtcttatcaatgggaatcataaattttccaatgaattagcaatttcgtccaattctttttgagcttcttcatatttgctttggaattcttcgcacttcttttcccattcatctctttcttcttccaaagcaacgatccttctacccatttgctcagagttcaaatcggcctctttcagtttatccattgcttccttcagtttggcttcactgtcttctagctgttgttctagatcctggtttttcttggtgtagttctcattattagatctcaagttattggagtcttcagccaattgctttgtatcagacaattgactctctaacttctccacttcactgtcgagttgctcgtttttagcggacaaagatttaatctcgttttctttttcagtgttagattgctctaattctttgagctgttctctcagctcctcatatttttcttgccatgactcagattctaattttaagctattcaatttctctttgatc"
      expected_id_namespace = "GenBank"
      expected_entry_id = "SCU49845"
      expected_primary_accession = "U49845"
      expected_secondary_accessions = []
      expected_other_seqids = ["1293613", "GI", []]
      expected_molecule_type = "DNA"
      expected_division = "PLN"
      expected_topology = "linear"
      expected_strandedness = nil
      expected_keywords = []
      expected_sequence_version = "1"
      expected_date_modified = "2010-03-23"
      expected_definition = "Saccharomyces cerevisiae TCP1-beta gene, partial cds; and Axl2p (AXL2) and Rev7p (REV7) genes, complete cds."
      expected_species = []
      expected_classification= ["Eukaryota", "Fungi", "Dikarya", "Ascomycota", "Saccharomyceta", "Saccharomycotina", "Saccharomycetes", "Saccharomycetales", "Saccharomycetaceae", "Saccharomyces"]
      expected_comments = ""
      expected_references = [{
  :abstract=>"",
  :affiliations=>[],
  :authors=>["Roemer, T.", "Madden, K.", "Chang, J.", "Snyder, M."],
  :comments=>nil,
  :doi=>nil,
  :embl_gb_record_number=>1,
  :issue=>"7",
  :journal=>"Genes Dev.",
  :medline=>"",
  :mesh=>[],
  :pages=>"777-793",
  :pubmed=>"8846915",
  :sequence_position=>"1-5028",
  :title=>
   "Selection of axial growth sites in yeast requires Axl2p, a novel plasma membrane glycoprotein",
  :url=>nil,
  :volume=>"10",
  :year=>"1996"},

  {:abstract=>"",
  :affiliations=>[],
  :authors=>["Roemer, T."],
  :comments=>nil,
  :doi=>nil,
  :embl_gb_record_number=>2,
  :issue=>"",
  :journal=>
   "Submitted (22-FEB-1996) Biology, Yale University, New Haven, CT 06520, USA",
  :medline=>"",
  :mesh=>[],
  :pages=>"",
  :pubmed=>"",
  :sequence_position=>"1-5028",
  :title=>"Direct Submission",
  :url=>nil,
  :volume=>"",
  :year=>""}]

      expected_features = [
 {:feature=>"source",
  :position=>"1..5028",
  :qualifiers=>
   [{:qualifier=>"organism",
     :value=>"Saccharomyces cerevisiae"},
    {:qualifier=>"mol_type",
     :value=>"genomic DNA"},
    {:qualifier=>"db_xref",
     :value=>"taxon:4932"},
    {:qualifier=>"chromosome",
      :value=>"IX"}]},
  {:feature=>"mRNA",
   :position=>"<1..>206",
   :qualifiers=>
   [{   
     :qualifier=>"product",
     :value=>"TCP1-beta"}]},
  {:feature=>"CDS",
   :position=>"<1..206",
   :qualifiers=>   [{:qualifier=>"codon_start", :value=>3},    {:qualifier=>"product",     :value=>"TCP1-beta"},
    {:qualifier=>"protein_id",
     :value=>"AAA98665.1"},
    {:qualifier=>"db_xref",
     :value=>"GI:1293614"},
    {:qualifier=>"translation",
     :value=>
      "SSIYNGISTSGLDLNNGTIADMRQLGIVESYKLKRAVVSSASEAAEVLLRVDNIIRARPRTANRQHM"}]},
  {:feature=>"gene",
   :position=>"<687..>3158",
   :qualifiers=>
   [{:qualifier=>"gene", :value=>"AXL2"}]},
  {:feature=>"mRNA",
   :position=>"<687..>3158",
   :qualifiers=>
   [{:qualifier=>"gene", :value=>"AXL2"},
   {:qualifier=>"product",
    :value=>"Axl2p"}]},
  {:feature=>"CDS",
   :position=>"687..3158",
   :qualifiers=>
   [{:qualifier=>"gene", :value=>"AXL2"},
   {:qualifier=>"note",
    :value=>"plasma membrane glycoprotein"},
   {:qualifier=>"codon_start", :value=>1},   {:qualifier=>"product",
     :value=>"Axl2p"},
   {:qualifier=>"protein_id",
    :value=>"AAA98666.1"},
   {:qualifier=>"db_xref",
    :value=>"GI:1293615"},
   {:qualifier=>"translation",
    :value=>
      "MTQLQISLLLTATISLLHLVVATPYEAYPIGKQYPPVARVNESFTFQISNDTYKSSVDKTAQITYNCFDLPSWLSFDSSSRTFSGEPSSDLLSDANTTLYFNVILEGTDSADSTSLNNTYQFVVTNRPSISLSSDFNLLALLKNYGYTNGKNALKLDPNEVFNVTFDRSMFTNEESIVSYYGRSQLYNAPLPNWLFFDSGELKFTGTAPVINSAIAPETSYSFVIIATDIEGFSAVEVEFELVIGAHQLTTSIQNSLIINVTDTGNVSYDLPLNYVYLDDDPISSDKLGSINLLDAPDWVALDNATISGSVPDELLGKNSNPANFSVSIYDTYGDVIYFNFEVVSTTDLFAISSLPNINATRGEWFSYYFLPSQFTDYVNTNVSLEFTNSSQDHDWVKFQSSNLTLAGEVPKNFDKLSLGLKANQGSQSQELYFNIIGMDSKITHSNHSANATSTRSSHHSTSTSSYTSSTYTAKISSTSAAATSSAPAALPAANKTSSHNKKAVAIACGVAIPLGVILVALICFLIFWRRRRENPDDENLPHAISGPDLNNPANKPNQENATPLNNPFDDDASSYDDTSIARRLAALNTLKLDNHSATESDISSVDEKRDSLSGMNTYNDQFQSQSKEELLAKPPVQPPESPFFDPQNRSSSVYMDSEPAVNKSWRYTGNLSPVSDIVRDSYGSQKTVDTEKLFDLEAPEKEKRTSRDVTMSSLDPWNSNISPSPVRKSVTPSPYNVTKHRNRHLQNIQDSQSGKNGITPTTMSTSSSDDFVPVKDGENFCWVHSMEPDRRPSKKRLVDFSNKSNVNVGQVKDIHGRIPEML"}]},
  {:feature=>"gene",
   :position=>"complement(<3300..>4037)",
   :qualifiers=>
  [{:qualifier=>"gene", :value=>"REV7"}]},
  {:feature=>"mRNA",
   :position=>"complement(<3300..>4037)",
   :qualifiers=>
     [{:qualifier=>"gene", :value=>"REV7"},
     {:qualifier=>"product",
     :value=>"Rev7p"}]},
  {:feature=>"CDS",
   :position=>"complement(3300..4037)",
   :qualifiers=>
   [{:qualifier=>"gene", :value=>"REV7"},
    {:qualifier=>"codon_start", :value=>1},
    {:qualifier=>"product",
     :value=>"Rev7p"},
    {:qualifier=>"protein_id",
     :value=>"AAA98667.1"},
    {:qualifier=>"db_xref",
     :value=>"GI:1293616"},
    {:qualifier=>"translation",
     :value=>
      "MNRWVEKWLRVYLKCYINLILFYRNVYPPQSFDYTTYQSFNLPQFVPINRHPALIDYIEELILDVLSKLTHVYRFSICIINKKNDLCIEKYVLDFSELQHVDKDDQIITETEVFDEFRSSLNSLIMHLEKLPKVNDDTITFEAVINAIELELGHKLDRNRRVDSLEEKAEIERDSNWVKCQEDENLPDNNGFQPPKIKLTSLVGSDVGPLIIHQFSEKLISGDDKILNGVYSQYEEGESIFGSLF"}]}]

      assert_equal(expected_seq, seq.seq)
      assert_equal(expected_id_namespace, seq.id_namespace)
      assert_equal(expected_entry_id, seq.entry_id)
      assert_equal(expected_primary_accession, seq.primary_accession)
      assert_equal(expected_secondary_accessions, seq.secondary_accessions)
      seqids = seq.other_seqids.first
      actual_other_seqids = [seqids.id, seqids.database, seqids.secondary_ids]
      assert_equal(expected_other_seqids, actual_other_seqids)
      assert_equal(expected_division, seq.division)
      assert_equal(expected_strandedness, seq.strandedness)
      assert_equal(expected_keywords, seq.keywords)
      assert_equal(expected_classification, seq.classification)
      assert_equal(expected_comments, seq.comments)
      refs = seq.references
      actual_references = []
      refs.each do |ref|
       actual_references << {:abstract => ref.abstract,
                             :affiliations => ref.affiliations,
                             :authors => ref.authors,
                             :comments => ref.comments,
                             :doi => ref.doi,
                             :embl_gb_record_number => ref.embl_gb_record_number,
                             :issue => ref.issue,
                             :journal =>  ref.journal,
                             :medline => ref.medline,
                             :mesh => ref.mesh,
                             :pages => ref.pages,
                             :pubmed => ref.pubmed,
                             :sequence_position => ref.sequence_position,
                             :title => ref.title,
                             :url => ref.url,
                             :volume => ref.volume,
                             :year => ref.year}
      end
      assert_equal(expected_references, actual_references)
      fets = seq.features
      actual_features = []
      fets.each do |fet|
        feature = fet.feature
        position = fet.position
        quals = []
        fet.qualifiers.each do |qual|
          quals << {:qualifier => qual.qualifier, :value => qual.value}
        end
      actual_features << {:feature => feature, :position => position, :qualifiers => quals}
      end
      assert_equal(expected_features, actual_features) # skip
      

    end

  end #class TestBioGenBank
end #module Bio

