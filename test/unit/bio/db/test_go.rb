#
# test/unit/bio/db/test_go.rb - Unit test for Bio::GO
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
require 'bio/db/go'

module Bio
  class TestBioGOOntology < Test::Unit::TestCase

    TestDataFileName = File.join(BioRubyTestDataPath,
                                 'go', 'selected_component.ontology')

    def setup
      @obj = Bio::GO::Ontology.new(File.read(TestDataFileName))
    end

    def test_dag_edit_format_parser
      obj = Bio::GO::Ontology.new(File.read(TestDataFileName))
      assert_equal(Bio::GO::Ontology,obj.class)
    end
    def test_goid2term
      assert_equal('cellular_component', @obj.goid2term('0005575'))
      assert_equal('cellular_component', @obj.goid2term('0008372'))
    end

    def test_parse_goids
      actual = Bio::GO::Ontology.parse_goids("<cellular_component ; GO:0005575, GO:0008372 ; synonym:cellular component ; synonym:cellular component unknown")
      assert_equal(["0005575", "0008372"], actual)
    end
  end

  class TestGeneAssociation < Test::Unit::TestCase

    TestDataFileName = File.join(BioRubyTestDataPath,
                                 'go', "selected_gene_association.sgd")

    def setup
      @ga = Bio::GO::GeneAssociation.new("SGD\tS000007287\t15S_RRNA\t\tGO:0005763\tSGD_REF:S000073642|PMID:6261980\tISS\t\tC\tRibosomal RNA of the small mitochondrial ribosomal subunit\t15S_rRNA|15S_RRNA_2\tgene\ttaxon:4932\t20040202\tSGD\t\t")
    end

    def test_parser
      file = File.read(TestDataFileName)
      gas = Bio::GO::GeneAssociation.parser(file)
      gas.map{ |ga| assert_equal(Bio::GO::GeneAssociation, ga.class) }
      Bio::GO::GeneAssociation.parser(file) {|ga| assert_equal(Bio::GO::GeneAssociation, ga.class) }
    end

    def test_goid
      assert_equal("0005763", @ga.goid)
      assert_equal("GO:0005763", @ga.goid(true))
    end
    def test_to_str
      #Bio::GO::GeneAssociation#to_str probably has an error.
      #
      assert_equal("SGD\tS000007287\t15S_RRNA\t\tGO:0005763\tSGD_REF:S000073642|PMID:6261980\tISS\t\tC\tRibosomal RNA of the small mitochondrial ribosomal subunit\t15S_rRNA|15S_RRNA_2\tgene\ttaxon:4932\t20040202\tSGD",@ga.to_str)
    end
    def test_db
      assert_equal("SGD",@ga.db)
    end
    def test_db_object_id
      assert_equal("S000007287",@ga.db_object_id)
    end
    def test_db_object_symbol
      assert_equal("15S_RRNA",@ga.db_object_symbol)
    end
    def test_qualifier
      assert_equal("",@ga.qualifier)
    end
    def test_db_reference
      assert_equal(["SGD_REF:S000073642", "PMID:6261980"],@ga.db_reference)
    end
    def test_evidence
      assert_equal("ISS",@ga.evidence)
    end
    def test_with
      assert_equal([],@ga.with)
    end
    def test_aspect
      assert_equal("C",@ga.aspect)
    end
    def test_db_object_name
      assert_equal("Ribosomal RNA of the small mitochondrial ribosomal subunit",@ga.db_object_name)
    end
    def test_db_object_synonym
      assert_equal(["15S_rRNA", "15S_RRNA_2"],@ga.db_object_synonym)
    end
    def test_db_object_type
      assert_equal("gene",@ga.db_object_type)
    end
    def test_taxon
      assert_equal("taxon:4932",@ga.taxon)
    end
    def test_date
      assert_equal("20040202",@ga.date)
    end
    def test_assigned_by
      assert_equal("SGD",@ga.assigned_by)
    end

  end

  class External2go < Test::Unit::TestCase

    TestDataFileName = File.join(BioRubyTestDataPath,
                                 'go', "selected_wikipedia2go")

    def setup
      file = File.read(TestDataFileName)
      @e2g = Bio::GO::External2go.parser(file)
    end
    def test_parser
      expected = [{:go_id=>"GO:0003845",
  :db=>"Wikipedia",
  :db_id=>"11beta-hydroxysteroid_dehydrogenase",
  :go_term=>"11-beta-hydroxysteroid dehydrogenase activity"},
 {:go_id=>"GO:0047414",
  :db=>"Wikipedia",
  :db_id=>
   "2-(hydroxymethyl)-3-(acetamidomethylene)succinate_amidohydrolase_(deaminating\\,_decarboxylating)",
  :go_term=>
   "2-(hydroxymethyl)-3-(acetamidomethylene)succinate hydrolase activity"},
 {:go_id=>"GO:0043718",
  :db=>"Wikipedia",
  :db_id=>"2-hydroxymethylglutarate_dehydrogenase",
  :go_term=>"2-hydroxymethylglutarate dehydrogenase activity"}]
      file = File.read(TestDataFileName)
      e2g = Bio::GO::External2go.parser(file)
      assert_equal(expected, e2g)
      assert_raise(RuntimeError){ Bio::GO::External2go.parser("probably this occurs error")}
    end
    def test_set_date
      e2g = Bio::GO::External2go.new
      e2g.set_date("$Date: 2010/06/11 01:01:37 $")
      assert_equal("$Date: 2010/06/11 01:01:37 $",e2g.header[:date])
    end
    def test_set_desc
      e2g = Bio::GO::External2go.new
      e2g.set_desc([" Mapping of Gene Ontology terms to Wikipedia entries."," Wikipedia: http://en.wikipedia.org"])
      assert_equal([" Mapping of Gene Ontology terms to Wikipedia entries."," Wikipedia: http://en.wikipedia.org"],e2g.header[:desc])
    end
    def test_to_str
      assert_equal("!date: \n! version: $Revision: 1.17 $\n! date: $Date: 2010/06/11 01:01:37 $\n!\n! Generated from file ontology/editors/gene_ontology_write.obo,\n! CVS revision:  1.1296; date:  10:06:2010 16:16\n!\n! Mapping of Gene Ontology terms to Wikipedia entries.\n! Wikipedia: http://en.wikipedia.org\n! Last update at Thu Jun 10 17:21:44 2010 by the script /users/cjm/cvs/go-moose/bin/daily_from_obo.pl\n!\nWikipedia:11beta-hydroxysteroid_dehydrogenase > GO:11-beta-hydroxysteroid dehydrogenase activity ; GO:0003845\nWikipedia:2-(hydroxymethyl)-3-(acetamidomethylene)succinate_amidohydrolase_(deaminating\\,_decarboxylating) > GO:2-(hydroxymethyl)-3-(acetamidomethylene)succinate hydrolase activity ; GO:0047414\nWikipedia:2-hydroxymethylglutarate_dehydrogenase > GO:2-hydroxymethylglutarate dehydrogenase activity ; GO:0043718", @e2g.to_str)
    end
    def test_dbs
      assert_equal(["Wikipedia"], @e2g.dbs)
    end
    def test_db_ids
      assert_equal(["11beta-hydroxysteroid_dehydrogenase",
 "2-(hydroxymethyl)-3-(acetamidomethylene)succinate_amidohydrolase_(deaminating\\,_decarboxylating)",
 "2-hydroxymethylglutarate_dehydrogenase"], @e2g.db_ids)
    end
    def test_go_terms
      assert_equal(["11-beta-hydroxysteroid dehydrogenase activity",
 "2-(hydroxymethyl)-3-(acetamidomethylene)succinate hydrolase activity",
 "2-hydroxymethylglutarate dehydrogenase activity"], @e2g.go_terms)
    end
    def test_go_ids
      assert_equal(["GO:0003845", "GO:0047414", "GO:0043718"], @e2g.go_ids)
    end
  end
end
