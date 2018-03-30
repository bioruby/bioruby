#
# test/unit/bio/db/kegg/test_genome.rb - Unit test for Bio::KEGG::GENOME
#
# Copyright::  Copyright (C) 2010 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/genome'

module Bio
  class TestBioKEGGGENOME_T00005 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/T00005.genome')
      @obj = Bio::KEGG::GENOME.new(File.read(filename))
    end

    def test_new
      assert_instance_of(Bio::KEGG::GENOME, @obj)
    end

    def test_entry_id
      assert_equal("T00005", @obj.entry_id)
    end

    def test_name
      expected = "sce, S.cerevisiae, YEAST, 4932"
      assert_equal(expected, @obj.name)
    end

    def test_definition
      expected = "Saccharomyces cerevisiae S288C"
      assert_equal(expected, @obj.definition)
    end

    def test_taxonomy
      expected = { "lineage"=>
        "Eukaryota; Fungi; Dikarya; Ascomycota; Saccharomycotina; Saccharomycetes; Saccharomycetales; Saccharomycetaceae; Saccharomyces",
        "taxid"=>"TAX:4932" }
      assert_equal(expected, @obj.taxonomy)
    end

    def test_taxid
      assert_equal("TAX:4932", @obj.taxid)
    end

    def test_lineage
      expected = "Eukaryota; Fungi; Dikarya; Ascomycota; Saccharomycotina; Saccharomycetes; Saccharomycetales; Saccharomycetaceae; Saccharomyces"
      assert_equal(expected, @obj.lineage)
    end

    def test_data_source
      assert_equal("RefSeq", @obj.data_source)
    end

    def test_original_db
      assert_equal("SGD MIPS", @obj.original_db)
    end

    def test_original_databases
      assert_equal([ "SGD", "MIPS" ], @obj.original_databases)
    end

    def test_disease
      assert_equal("", @obj.disease)
    end

    def test_comment
      assert_equal("", @obj.comment)
    end

    def test_references
      data =
        [ { "authors"  => ["Goffeau A", "et al."],
            "comments" => nil,
            "journal"  => "Science",
            "pages"    => "546-67",
            "pubmed"   => "8849441",
            "title"    => "Life with 6000 genes.",
            "volume"   => "274",
            "year"     => "1996",
          },
          { "authors"  => ["Bussey H", "et al."],
            "comments" => ["(chromosome I)"],
            "journal"  => "Proc Natl Acad Sci U S A",
            "pages"    => "3809-13",
            "pubmed"   => "7731988",
            "title"    => "The nucleotide sequence of chromosome I from Saccharomyces cerevisiae.",
            "volume"   => "92",
            "year"     => "1995",
          },
          { "authors"  => ["Feldmann, H.", "et al."],
            "comments" => ["(chromosome II)"],
            "journal"  => "EMBO J",
            "pages"    => "5795-809",
            "pubmed"   => "7813418",
            "title"    => "Complete DNA sequence of yeast chromosome II.",
            "volume"   => "13",
            "year"     => "1994",
          },
          { "authors"  => ["Oliver, S.G.", "et al."],
            "comments" => ["(chromosome III)"],
            "journal"  => "Nature",
            "pages"    => "38-46",
            "pubmed"   => "1574125",
            "title"    => "The complete DNA sequence of yeast chromosome III.",
            "volume"   => "357",
            "year"     => "1992",
          },
          { "authors"  => ["Jacq C", "et al."],
            "comments" => ["(chromosome IV)"],
            "journal"  => "Nature",
            "pages"    => "75-8",
            "pubmed"   => "9169867",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome IV.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          },
          { "authors"  => ["Dietrich FS", "et al."],
            "comments" => ["(chromosome V)"],
            "journal"  => "Nature",
            "pages"    => "78-81",
            "pubmed"   => "9169868",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome V.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          },
          { "authors"  => ["Murakami, Y.", "et al."],
            "comments" => ["(chromosome VI)"],
            "journal"  => "Nat Genet",
            "pages"    => "261-8",
            "pubmed"   => "7670463",
            "title"    => "Analysis of the nucleotide sequence of chromosome VI from Saccharomyces cerevisiae.",
            "volume"   => "10",
            "year"     => "1995",
          },
          { "authors"  => ["Tettelin H", "et al."],
            "comments" => ["(chromosome VII)"],
            "journal"  => "Nature",
            "pages"    => "81-4",
            "pubmed"   => "9169869",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome VII.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          },
          { "authors"  => ["Johnston, M.", "et al."],
            "comments" => ["(chromosome VIII)"],
            "journal"  => "Science",
            "pages"    => "2077-82",
            "pubmed"   => "8091229",
            "title"    => "Complete nucleotide sequence of Saccharomyces cerevisiae chromosome VIII.",
            "volume"   => "265",
            "year"     => "1994",
          },
          { "authors"  => ["Churcher C", "et al."],
            "comments" => ["(chromosome IX)"],
            "journal"  => "Nature",
            "pages"    => "84-7",
            "pubmed"   => "9169870",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome IX.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          },
          { "authors"  => ["Galibert, F.", "et al."],
            "comments" => ["(chromosome X)"],
            "journal"  => "EMBO J",
            "pages"    => "2031-49",
            "pubmed"   => "8641269",
            "title"    => "Complete nucleotide sequence of Saccharomyces cerevisiae chromosome X.",
            "volume"   => "15",
            "year"     => "1996",
          },
          { "authors"  => ["Dujon, B.", "et al."],
            "comments" => ["(chromosome XI)"],
            "journal"  => "Nature",
            "pages"    => "371-8",
            "pubmed"   => "8196765",
            "title"    => "Complete DNA sequence of yeast chromosome XI.",
            "volume"   => "369",
            "year"     => "1994",
          },
          { "authors"  => ["Johnston M", "et al."],
            "comments" => ["(chromosome XII)"],
            "journal"  => "Nature",
            "pages"    => "87-90",
            "pubmed"   => "9169871",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome XII.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          },
          { "authors"  => ["Bowman S", "et al."],
            "comments" => ["(chromosome XIII)"],
            "journal"  => "Nature",
            "pages"    => "90-3",
            "pubmed"   => "9169872",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome XIII.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          },
          { "authors"  => ["Philippsen P", "et al."],
            "comments" => ["(chromosome XIV)"],
            "journal"  => "Nature",
            "pages"    => "93-8",
            "pubmed"   => "9169873",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome XIV and its evolutionary implications.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          },
          { "authors"  => ["Dujon B", "et al."],
            "comments" => ["(chromosome XV)"],
            "journal"  => "Nature",
            "pages"    => "98-102",
            "pubmed"   => "9169874",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome XV.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          },
          { "authors"  => ["Bussey H", "et al."],
            "comments" => ["(chromosome XVI)"],
            "journal"  => "Nature",
            "pages"    => "103-5",
            "pubmed"   => "9169875",
            "title"    => "The nucleotide sequence of Saccharomyces cerevisiae chromosome XVI.",
            "volume"   => "387(6632 Suppl)",
            "year"     => "1997",
          }
        ]
      expected = data.collect { |h| Bio::Reference.new(h) }
      #assert_equal(expected, @obj.references)
      expected.each_with_index do |x, i|
        assert_equal(x, @obj.references[i])
      end
    end

    def test_chromosomes
      expected =
        [{"SEQUENCE"=>"RS:NC_001133", "LENGTH"=>"230208", "CHROMOSOME"=>"I"},
         {"SEQUENCE"=>"RS:NC_001134", "LENGTH"=>"813178", "CHROMOSOME"=>"II"},
         {"SEQUENCE"=>"RS:NC_001135", "LENGTH"=>"316617", "CHROMOSOME"=>"III"},
         {"SEQUENCE"=>"RS:NC_001136", "LENGTH"=>"1531919", "CHROMOSOME"=>"IV"},
         {"SEQUENCE"=>"RS:NC_001137", "LENGTH"=>"576869", "CHROMOSOME"=>"V"},
         {"SEQUENCE"=>"RS:NC_001138", "LENGTH"=>"270148", "CHROMOSOME"=>"VI"},
         {"SEQUENCE"=>"RS:NC_001139", "LENGTH"=>"1090947", "CHROMOSOME"=>"VII"},
         {"SEQUENCE"=>"RS:NC_001140", "LENGTH"=>"562643", "CHROMOSOME"=>"VIII"},
         {"SEQUENCE"=>"RS:NC_001141", "LENGTH"=>"439885", "CHROMOSOME"=>"IX"},
         {"SEQUENCE"=>"RS:NC_001142", "LENGTH"=>"745741", "CHROMOSOME"=>"X"},
         {"SEQUENCE"=>"RS:NC_001143", "LENGTH"=>"666454", "CHROMOSOME"=>"XI"},
         {"SEQUENCE"=>"RS:NC_001144", "LENGTH"=>"1078175", "CHROMOSOME"=>"XII"},
         {"SEQUENCE"=>"RS:NC_001145", "LENGTH"=>"924429", "CHROMOSOME"=>"XIII"},
         {"SEQUENCE"=>"RS:NC_001146", "LENGTH"=>"784333", "CHROMOSOME"=>"XIV"},
         {"SEQUENCE"=>"RS:NC_001147", "LENGTH"=>"1091289", "CHROMOSOME"=>"XV"},
         {"SEQUENCE"=>"RS:NC_001148", "LENGTH"=>"948062", "CHROMOSOME"=>"XVI"},
         {"SEQUENCE"=>"RS:NC_001224",
           "LENGTH"=>"85779",
           "CHROMOSOME"=>"MT (mitochondrion); Circular"}
        ]
      assert_equal(expected, @obj.chromosomes)
    end

    def test_plasmids
      assert_equal([], @obj.plasmids)
    end

    def test_statistics
      expected = {"num_rna"=>414, "num_nuc"=>12156676, "num_gene"=>5881}
      assert_equal(expected, @obj.statistics)
    end

    def test_nalen
      assert_equal(12156676, @obj.nalen)
    end

    def test_num_gene
      assert_equal(5881, @obj.num_gene)
    end

    def test_num_rna
      assert_equal(414, @obj.num_rna)
    end

  end #class TestBioKEGGGENOME_T00005

  class TestBioKEGGGENOME_T00070 < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'KEGG/T00070.genome')
      @obj = Bio::KEGG::GENOME.new(File.read(filename))
    end

    def test_new
      assert_instance_of(Bio::KEGG::GENOME, @obj)
    end

    def test_entry_id
      assert_equal("T00070", @obj.entry_id)
    end

    def test_name
      expected = "atu, A.tumefaciens, AGRT5, 176299"
      assert_equal(expected, @obj.name)
    end

    def test_definition
      expected = "Agrobacterium tumefaciens C58"
      assert_equal(expected, @obj.definition)
    end

    def test_taxonomy
      expected = { "lineage"=>
        "Bacteria; Proteobacteria; Alphaproteobacteria; Rhizobiales; Rhizobiaceae; Rhizobium/Agrobacterium group; Agrobacterium",
        "taxid" => "TAX:176299" }
      assert_equal(expected, @obj.taxonomy)
    end

    def test_taxid
      assert_equal("TAX:176299", @obj.taxid)
    end

    def test_lineage
      expected = "Bacteria; Proteobacteria; Alphaproteobacteria; Rhizobiales; Rhizobiaceae; Rhizobium/Agrobacterium group; Agrobacterium"
      assert_equal(expected, @obj.lineage)
    end

    def test_data_source
      assert_equal("RefSeq", @obj.data_source)
    end

    def test_original_db
      assert_equal("UWash", @obj.original_db)
    end

    def test_original_databases
      assert_equal([ "UWash" ], @obj.original_databases)
    end

    def test_disease
      expected = "Crown gall disease in plants"
      assert_equal(expected, @obj.disease)
    end

    def test_comment
      expected = "Originally called Agrobacterium tumefaciens C58 (U.Washington/Dupont) to distinguish from Agrobacterium tumefaciens C58 (Cereon) [GN:atc]"
      assert_equal(expected, @obj.comment)
    end

    def test_references
      h = {
        "authors" => [ "Wood DW", "et al." ],
        "journal" => "Science",
        "pages"   => "2317-23",
        "pubmed"  => "11743193",
        "title"   => "The genome of the natural genetic engineer Agrobacterium tumefaciens C58.",
        "volume"  => "294",
        "year"    => "2001"
      }
      expected = [ Bio::Reference.new(h) ]
      assert_equal(expected, @obj.references)
    end

    def test_chromosomes
      expected = [ { "SEQUENCE"   => "RS:NC_003062",
                     "LENGTH"     => "2841580",
                     "CHROMOSOME" => "Circular"},
                   { "SEQUENCE"   => "RS:NC_003063",
                     "LENGTH"     => "2075577",
                     "CHROMOSOME" => "L (linear chromosome)"} ]
      assert_equal(expected, @obj.chromosomes)
    end

    def test_plasmids
      expected =
        [ { "SEQUENCE" => "RS:NC_003065",
            "LENGTH"   => "214233",
            "PLASMID"  => "Ti; Circular" },
          { "SEQUENCE" => "RS:NC_003064",
            "LENGTH"   => "542868",
            "PLASMID"  => "AT; Circular" }
        ]
      assert_equal(expected, @obj.plasmids)
    end

    def test_statistics
      expected = {"num_rna"=>74, "num_nuc"=>5674258, "num_gene"=>5355}
      assert_equal(expected, @obj.statistics)
    end

    def test_nalen
      assert_equal(5674258, @obj.nalen)
    end

    def test_num_gene
      assert_equal(5355, @obj.num_gene)
    end

    def test_num_rna
      assert_equal(74, @obj.num_rna)
    end

  end #class TestBioKEGGGENOME_T00070
end #module Bio

