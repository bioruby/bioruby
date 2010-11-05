#
# test/unit/bio/db/litdb.rb - Unit test for Bio::LITDB
#
# Copyright::  Copyright (C) 2010 Kazuhiro Hayashi <k.hayashi.info@gmail.com>
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/litdb'
require 'bio/reference'

module Bio
  class TestBioLITDB < Test::Unit::TestCase

    def setup
      filename = File.join(BioRubyTestDataPath, 'litdb', '1717226.litdb')
      @obj = Bio::LITDB.new(File.read(filename))
    end

    # it return the reference infromation formatted as part of a Bio::Reference object.
    def test_reference
      expected = 
 {:authors=>
  ["Boyd, L.A.",
   "Adam, L.",
   "Pelcher, L.E.",
   "McHughen, A.",
   "Hirji, R.",
   " Selvaraj, G."],

 :issue=>"1",
 :journal=>"Gene",
 :pages=>"45-52",
 :title=>
  "Characterization of an Escherichia coli gene encoding betaine aldehyde dehydrogenase (BADH). Structural similarity to mammalian ALDHs and a plant BADH.",
 :volume=>"103",
 :year=>"(1991)"}
     litdb_ref = @obj.reference
       actual = {:authors=>litdb_ref.authors,
         :journal=> litdb_ref.journal,
         :pages=> litdb_ref.pages,
         :volume=>litdb_ref.volume,
         :year=>litdb_ref.year,
         :issue=>litdb_ref.issue,
         :title=>litdb_ref.title
       }
      assert_equal(expected, actual)
    end

    #access to the each field with field_fetch method.
   #most methods are the same as values of Bio::Refence object.
    def test_entry_id
      assert_equal("1717226", @obj.entry_id)
    end

    def test_title
      expected = "Characterization of an Escherichia coli gene encoding betaine aldehyde dehydrogenase (BADH). Structural similarity to mammalian ALDHs and a plant BADH."
      assert_equal(expected, @obj.title)
    end

    def test_field
      assert_equal("q (sequence analysis)", @obj.field)
    end

    def test_journal
      assert_equal("Gene", @obj.journal)
    end

    def test_volume
      assert_equal("Vol.103, No.1, 45-52 (1991)", @obj.volume)
    end

    def test_keyword
      expected = ["*Betaine Aldehyde Dehydrogenase",
 "*betB Gene;E.coli",
 "Seq Determination;1854bp;491AAs",
 "Hydropathy Plot;*EC1.2.1.8",
 "Seq Comparison"]
      assert_equal(expected, @obj.keyword)
    end

    def test_author
      expected = "Boyd,L.A.;Adam,L.;Pelcher,L.E.;McHughen,A.;Hirji,R.; Selvaraj,G."
      assert_equal(expected, @obj.author)
    end

  end #class TestBioLITDB
end #module Bio

