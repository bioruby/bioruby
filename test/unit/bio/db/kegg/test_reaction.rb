#
# test/unit/bio/db/kegg/test_reaction.rb - Unit test for Bio::KEGG::REACTION
#
# Copyright::  Copyright (C) 2009 Kozo Nishida <kozo-ni@is.naist.jp>
# License::    The Ruby License

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/kegg/reaction'

module Bio
  class TestReaction < Test::Unit::TestCase

    def setup
      bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      testdata_kegg = Pathname.new(File.join(bioruby_root, 'test', 'data', 'KEGG')).cleanpath.to_s
      entry = File.read(File.join(testdata_kegg, "R00006.reaction"))
      @obj = Bio::KEGG::REACTION.new(entry)
    end

    def test_entry_id
      assert_equal('R00006', @obj.entry_id)
    end

    def test_name
      assert_equal('pyruvate:pyruvate acetaldehydetransferase (decarboxylating); 2-acetolactate pyruvate-lyase (carboxylating)', @obj.name)
    end

    def test_definition
      assert_equal('2-Acetolactate + CO2 <=> 2 Pyruvate', @obj.definition)
    end

    def test_equation
      assert_equal('C00900 + C00011 <=> 2 C00022', @obj.equation)
    end

    def test_rpairs
      assert_equal([{"name"=>"C00022_C00900", "type"=>"main", "entry"=>"RP00440"}, {"name"=>"C00011_C00022", "type"=>"leave", "entry"=>"RP05698"}, {"name"=>"C00022_C00900", "type"=>"trans", "entry"=>"RP12733"}], @obj.rpairs)
    end

    def test_pathways
      assert_equal([{"name"=>"Pantothenate and CoA biosynthesis", "entry"=>"rn00770"}], @obj.pathways)
    end

    def test_enzymes
      assert_equal(["2.2.1.6"], @obj.enzymes)
    end

    def test_orthologies
      assert_equal([{"entry"=>"K01652", "definition"=>"acetolactate synthase I/II/III large subunit [EC:2.2.1.6]"}, {"entry"=>"K01653", "definition"=>"acetolactate synthase I/III small subunit [EC:2.2.1.6]"}], @obj.orthologies)
    end

  end
end
