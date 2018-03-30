#
# test/unit/bio/db/embl/test_uniprotkb_new_part.rb - Unit test for Bio::UniProtKB for new file formats using part of psudo entries
#
# Copyright::  Copyright (C) 2011 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/embl/uniprotkb'

module Bio
  class TestUniProtKB_ID_since_rel9_0 < Test::Unit::TestCase

    def setup
      text = "ID   ABC_DEFGH               Reviewed;         256 AA.\n"
      @obj = Bio::UniProtKB.new(text)
    end

    def test_id_line
      expected = {
        "ENTRY_NAME" => "ABC_DEFGH",
        "DATA_CLASS" => "Reviewed",
        "SEQUENCE_LENGTH" => 256,
        "MOLECULE_TYPE" => nil
      }
      assert_equal(expected, @obj.id_line)
    end

    def test_entry_id
      assert_equal("ABC_DEFGH", @obj.entry_id)
    end

    def test_entry_name
      assert_equal("ABC_DEFGH", @obj.entry_name)
    end

    def test_entry
      assert_equal("ABC_DEFGH", @obj.entry)
    end

    def test_sequence_length
      assert_equal(256, @obj.sequence_length)
    end

    def test_aalen
      assert_equal(256, @obj.aalen)
    end

    def test_molecule
      assert_nil(@obj.molecule)
    end
  end #class TestUniProtKB_ID_since_rel9_0

  class TestUniProtKB_DE_since_rel14_0 < Test::Unit::TestCase

    def setup
      text = <<the_end_of_the_text
ID   ABC_DEFGH               Unreviewed;       256 AA.
DE   RecName: Full=Aaa Bbbb Ccccc-Dddddd Eeeeeee factor;
DE            Short=ABC-DEF;
DE            Short=A-DF;
DE            EC=9.8.0.1;
DE   AltName: Full=Bbbb-Aaa Eeeeeee Ccccc;
DE            Short=Bbbb-Aaa;
DE            EC=9.8.0.-;
DE   AltName: Allergen=Bet v 1-B;
DE   AltName: Biotech=this is fake entry;
DE   AltName: CD_antigen=CD42c;
DE   AltName: INN=Pseudo;
DE   SubName: Full=submitter named this ABC_DEFGH;
DE            EC=9.8.2.1;
DE   Includes:
DE     RecName: Full=Included protein example;
DE              Short=IPE;
DE              EC=9.9.9.9;
DE     AltName: Full=Inclided protein altname;
DE              Short=IPA;
DE   Contains:
DE     RecName: Full=Contained protein alpha chain;
DE              Short=CPAC;
DE   Flags: Precursor; Fragment;
the_end_of_the_text

      @obj = Bio::UniProtKB.new(text)
    end

    def test_private_parse_DE_line_rel14
      expected =
        [ [ "RecName",
            ["Full", "Aaa Bbbb Ccccc-Dddddd Eeeeeee factor"],
            ["Short", "ABC-DEF"],
            ["Short", "A-DF"],
            ["EC", "9.8.0.1"]
          ],
          [ "AltName",
            ["Full", "Bbbb-Aaa Eeeeeee Ccccc"],
            ["Short", "Bbbb-Aaa"],
            ["EC", "9.8.0.-"]
          ],
          [ "AltName",
            ["Allergen", "Bet v 1-B"]
          ],
          [ "AltName",
            ["Biotech", "this is fake entry"]
          ],
          [ "AltName",
            ["CD_antigen", "CD42c"]
          ],
          [ "AltName",
            ["INN", "Pseudo"]
          ],
          [ "SubName",
            ["Full", "submitter named this ABC_DEFGH"],
            ["EC", "9.8.2.1"]
          ],
          [ "Includes" ],
          [ "RecName",
            ["Full", "Included protein example"],
            ["Short", "IPE"],
            ["EC", "9.9.9.9"]
          ],
          ["AltName",
           ["Full", "Inclided protein altname"],
           ["Short", "IPA"]
          ],
          [ "Contains" ],
          [ "RecName",
            ["Full", "Contained protein alpha chain"],
            ["Short", "CPAC"]
          ],
          [ "Flags",
            ["Precursor", "Fragment"]
          ]
        ]
      @obj.protein_name
      ary = @obj.instance_eval { @data['DE'] }
      assert_equal(expected, ary)
    end

    def test_protein_name
      assert_equal('Aaa Bbbb Ccccc-Dddddd Eeeeeee factor',
                   @obj.protein_name)
    end

    def test_synonyms
      expected = [ 'ABC-DEF',
                   'A-DF',
                   'EC 9.8.0.1',
                   'Bbbb-Aaa Eeeeeee Ccccc',
                   'Bbbb-Aaa',
                   'EC 9.8.0.-',
                   'Allergen=Bet v 1-B',
                   'this is fake entry',
                   'CD_antigen=CD42c',
                   'Pseudo',
                   'submitter named this ABC_DEFGH',
                   'EC 9.8.2.1'
                 ]
      assert_equal(expected, @obj.synonyms)
    end

  end #class TestUniProtKB_DE_since_rel14_0

  class TestUniProtKB_CC_WEB_RESOURCE_since_rel12_2 < Test::Unit::TestCase

    def setup
      text = <<the_end_of_the_text
ID   ABC_DEFGH               Unreviewed;       256 AA.
CC   -!- WEB RESOURCE: Name=BioRuby web site; Note=BioRuby main web site
CC       located in Tokyo, Japan;
CC       URL="http://bioruby.org";
CC   -!- WEB RESOURCE: Name=official mirror of BioRuby web site hosted in
CC       the Open Bioinformatics Foundation;
CC       URL="http://bioruby.open-bio.org/";
CC   -!- WEB RESOURCE: Name=BioRuby Wiki site;
CC       URL="http://bioruby.open-bio.org/wiki/";
the_end_of_the_text

      @obj = Bio::UniProtKB.new(text)
    end

    def test_cc_web_resource
      expected =
        [ { "Name" => "BioRuby web site",
            "Note" => "BioRuby main web site located in Tokyo, Japan",
            "URL"  => "http://bioruby.org"
          },
          { "Name" => "official mirror of BioRuby web site hosted in the Open Bioinformatics Foundation",
            "Note" => nil,
            "URL"  => "http://bioruby.open-bio.org/"
          },
          { "Name" => "BioRuby Wiki site",
            "Note" => nil,
            "URL"  => "http://bioruby.open-bio.org/wiki/"
          }
        ]

      assert_equal(expected, @obj.cc('WEB RESOURCE'))
    end
  end #class TestUniProtKB_CC_WEB_RESOURCE_since_rel12_2

end #module Bio
