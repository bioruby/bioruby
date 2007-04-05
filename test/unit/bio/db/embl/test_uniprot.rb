#
# test/unit/bio/db/embl/test_uniprot.rb - Unit test for Bio::UniProt
#
# Copyright::  Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
# License::    The Ruby License
#
#  $Id: test_uniprot.rb,v 1.5 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/db/embl/uniprot'

module Bio
  class TestUniProt < Test::Unit::TestCase

    def setup
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5)).cleanpath.to_s
      data = File.open(File.join(bioruby_root, 'test', 'data', 'uniprot', 'p53_human.uniprot')).read
      @obj = Bio::UniProt.new(data)
    end

    def test_gene_name
      assert_equal('TP53', @obj.gene_name)
    end

  end
end
