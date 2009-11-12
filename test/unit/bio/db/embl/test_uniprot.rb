#
# test/unit/bio/db/embl/test_uniprot.rb - Unit test for Bio::UniProt
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/db/embl/uniprot'

module Bio
  class TestUniProt < Test::Unit::TestCase

    def setup
      data = File.read(File.join(BioRubyTestDataPath, 'uniprot', 'p53_human.uniprot'))
      @obj = Bio::UniProt.new(data)
    end

    def test_gene_name
      assert_equal('TP53', @obj.gene_name)
    end

  end
end
