#
# test/unit/bio/db/genbank/test_common.rb - Unit test for Bio::NCBIDB::Common
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
require 'bio/db/genbank/common'
require 'bio/reference'
require 'bio/compat/references' #  Bio::References in this file seems to be obsolete, but Bio::NCBIDB::Common should require it.
require 'bio/feature'
require 'bio/compat/features'    #  Bio::Features in this file seems to be obsolete, but Bio::NCBIDB::Common should require it.


# - This class has low coverage, because a sample entry used in it lacks a lot of fields.
# - There are all the methods for test.
module Bio
  class NCBIDB
    class TestCommon < Test::Unit::TestCase

      #Mock Class including the target module.
      #BioNCBIDBCommon is used for the test.
      class BioNCBIDBCommon < Bio::NCBIDB
        include Bio::NCBIDB::Common
      end

      #a sample entry is a part of data/genbank/SCU49845.gb
      def setup
entry =<<EOF
LOCUS       SCU49845                5028 bp    DNA     linear   PLN 23-MAR-2010
DEFINITION  Saccharomyces cerevisiae TCP1-beta gene, partial cds; and Axl2p
            (AXL2) and Rev7p (REV7) genes, complete cds.
ACCESSION   U49845
VERSION     U49845.1  GI:1293613
KEYWORDS    .
SOURCE      Saccharomyces cerevisiae (baker's yeast)
  ORGANISM  Saccharomyces cerevisiae
            Eukaryota; Fungi; Dikarya; Ascomycota; Saccharomyceta;
            Saccharomycotina; Saccharomycetes; Saccharomycetales;
            Saccharomycetaceae; Saccharomyces.
EOF
        @obj = BioNCBIDBCommon.new(entry)
      end

      def test_locus
        #Since locus method is supposed to be overloaded in a child class, it may not be neccesary to test the method here.
      end
      
      def test_definition
        expected = "Saccharomyces cerevisiae TCP1-beta gene, partial cds; and Axl2p (AXL2) and Rev7p (REV7) genes, complete cds."
        assert_equal(expected, @obj.definition)
      end

      def test_accessions
         expected = ["U49845"]
        assert_equal(expected, @obj.accessions)
      end

      def test_accession
         expected = "U49845"
        assert_equal(expected, @obj.accession)
      end

      def test_versions
         expected = ["U49845.1", "GI:1293613"]
        assert_equal(expected, @obj.versions)
      end

      def test_version
         expected = 1 
        assert_equal(expected, @obj.version)
      end

      def test_acc_version
         expected = "U49845.1"
        assert_equal(expected, @obj.acc_version)
      end

      def test_gi
         expected = "GI:1293613"
        assert_equal(expected, @obj.gi)
      end

      def test_nid
         expected = ""
        assert_equal(expected, @obj.nid)
      end

      def test_keywords
         expected = []
        assert_equal(expected, @obj.keywords)
      end

      def test_segment
         expected = ""
        assert_equal(expected, @obj.segment)
      end

      def test_source
         expected = {"organism"=>"Saccharomyces cerevisiae",
                           "common_name"=>"Saccharomyces cerevisiae (baker's yeast)",
                           "taxonomy"=>
                                "Eukaryota; Fungi; Dikarya; Ascomycota; Saccharomyceta; Saccharomycotina; Saccharomycetes; Saccharomycetales; Saccharomycetaceae; Saccharomyces."}
        assert_equal(expected, @obj.source)

        #another pattern to pass line 103-105
        source_pattern2 =<<EOS
SOURCE      Saccharomyces cerevisiae (baker's yeast)
  ORGANISM  Saccharomyces cerevisiae
            Saccharomyces.
EOS
        obj2 = BioNCBIDBCommon.new(source_pattern2)
          expected2 = {"organism"=>"Saccharomyces cerevisiae",
                       "common_name"=>"Saccharomyces cerevisiae (baker's yeast)",
                       "taxonomy"=>"Saccharomyces."}
        assert_equal(expected2, obj2.source)

        #the other pattern to pass line 106-109
        source_pattern3 =<<EOS
SOURCE      Saccharomyces cerevisiae (baker's yeast)
  ORGANISM  Saccharomyces cerevisiae
EOS
        obj3 = BioNCBIDBCommon.new(source_pattern3)
          expected3 = {"organism"=>"Saccharomyces cerevisiae",
                       "common_name"=>"Saccharomyces cerevisiae (baker's yeast)",
                       "taxonomy"=>""}
        assert_equal(expected3, obj3.source)
      end

      def test_common_name
         expected = "Saccharomyces cerevisiae (baker's yeast)"
        assert_equal(expected, @obj.common_name)
      end

      def test_organism
         expected = "Saccharomyces cerevisiae"
        assert_equal(expected, @obj.organism)
      end

      def test_taxonomy
         expected = "Eukaryota; Fungi; Dikarya; Ascomycota; Saccharomyceta; Saccharomycotina; Saccharomycetes; Saccharomycetales; Saccharomycetaceae; Saccharomyces."
        assert_equal(expected, @obj.taxonomy)
      end

      def test_references
        str=<<EOS
REFERENCE   2  (bases 1 to 2264)
  AUTHORS   Zhao,X., Brade,T., Cunningham,T.J. and Duester,G.
  TITLE     Retinoic acid controls expression of tissue remodeling genes Hmgn1
            and Fgf18 at the digit-interdigit junction
  JOURNAL   Dev. Dyn. 239 (2), 665-671 (2010)
   PUBMED   20034106
  REMARK    GeneRIF: limited to the digit-interdigit junction rather than being
            expressed throughout the interdigital zone
EOS
        com = BioNCBIDBCommon.new(str)
        obj = com.references
         expected = 
           {:mesh=>[],
            :volume=>"239",
            :doi=>nil,
            :pages=>"665-671",
            :embl_gb_record_number=>2,
            :pubmed=>"20034106",
            :abstract=>"",
            :issue=>"2",
            :year=>"2010",
            :sequence_position=>"1-2264",
            :affiliations=>[],
            :journal=>"Dev. Dyn.",
            :title=>
             "Retinoic acid controls expression of tissue remodeling genes Hmgn1 and Fgf18 at the digit-interdigit junction",
            :authors=>["Zhao, X.", "Brade, T.", "Cunningham, T.J.", "Duester, G."],
            :medline=>"",
            :url=>nil,
            :comments=>
             ["GeneRIF: limited to the digit-interdigit junction rather than being expressed throughout the interdigital zone"]}  
        actual            = {:abstract => obj[0].abstract,
                             :affiliations => obj[0].affiliations,
                             :authors => obj[0].authors,
                             :comments => obj[0].comments,
                             :doi => obj[0].doi,
                             :embl_gb_record_number => obj[0].embl_gb_record_number,
                             :issue => obj[0].issue,
                             :journal =>  obj[0].journal,
                             :medline => obj[0].medline,
                             :mesh => obj[0].mesh,
                             :pages => obj[0].pages,
                             :pubmed => obj[0].pubmed,
                             :sequence_position => obj[0].sequence_position,
                             :title => obj[0].title,
                             :url => obj[0].url,
                             :volume => obj[0].volume,
                             :year => obj[0].year}
      assert_equal(expected, actual)
        actual2 = ""
      com.references do |reference|
        actual2 = reference.authors
        break
      end
      assert_equal(["Zhao, X.", "Brade, T.", "Cunningham, T.J.", "Duester, G."],actual2) 

      
      #the other pattern where a journal doesn't match the regexp.
      ref=<<EOS
REFERENCE   2  (bases 1 to 2264)
  JOURNAL   testcase
EOS
      obj2 = BioNCBIDBCommon.new(ref)
      actual3 = obj2.references[0].journal
      assert_equal("testcase",actual3)
      end

      def test_comment
         expected = ""
        assert_equal(expected, @obj.comment)
      end

      def test_features
        expected =
        {:feature=>"CDS",
         :position=>"<1..206",
         :qualifiers=>
          [{:qualifier=>"product",
           :value=>"TCP1-beta"},
           {:value=>3, :qualifier=>"codon_start"},
           {:qualifier=>"translation",
            :value=>
             "SSIYNGISTSGLDLNNGTIADMRQLGIVESYKLKRAVVSSASEAAEVLLRVDNIIRARPRTANRQHM"}]}
        fet =<<EOS
FEATURES             Location/Qualifiers
     CDS             <1..206
                     /product="TCP1-beta"
                     /codon_start=3
                     /translation="SSIYNGISTSGLDLNNGTIADMRQLGIVESYKLKRAVVSSASEA
                     AEVLLRVDNIIRARPRTANRQHM"
EOS
        obj = BioNCBIDBCommon.new(fet)
        actual =
        {:feature=>obj.features[0].feature,
         :position=>obj.features[0].position,
         :qualifiers=>
           [{:qualifier=>obj.features[0].qualifiers[0].qualifier,
             :value=>obj.features[0].qualifiers[0].value},
            {:qualifier=>obj.features[0].qualifiers[1].qualifier,
             :value=>
              obj.features[0].qualifiers[1].value},
            {:qualifier=>obj.features[0].qualifiers[2].qualifier,
             :value=>
              obj.features[0].qualifiers[2].value}]}
        assert_equal(expected, actual)
          actual2 = ""
        obj.features do |feature|
          actual2 = feature.feature
        end
          
          assert_equal("CDS", actual2)
      end

      def test_origin
         expected = ""
        assert_equal(expected, @obj.origin)
      end

    end
  end
end
