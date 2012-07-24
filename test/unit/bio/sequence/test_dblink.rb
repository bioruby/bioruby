#
# test/unit/bio/sequence/test_dblink.rb - Unit test for Bio::Sequencce::DBLink
#
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 3,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio/sequence'
require 'bio/sequence/dblink'

module Bio
  class TestSequenceDBLink < Test::Unit::TestCase
    def setup
      @xref = Bio::Sequence::DBLink.new('EMBL', 'Z14088', 'CAA78466.1',
                                        '-', 'mRNA')
    end

    def test_database
      assert_equal('EMBL', @xref.database)
    end

    def test_id
      assert_equal('Z14088', @xref.id)
    end

    def test_secondary_ids
      assert_equal([ 'CAA78466.1', '-', 'mRNA' ],
                   @xref.secondary_ids)
    end
  end #class

  class TestSequenceDBLinkClassMethods < Test::Unit::TestCase
    def test_parse_embl_DR_line
      str = 'DR   EPD; EP07077; HS_HBG1.'
      xref = Bio::Sequence::DBLink.parse_embl_DR_line(str)
      assert_equal('EPD', xref.database)
      assert_equal('EP07077', xref.id)
      assert_equal([ 'HS_HBG1' ], xref.secondary_ids)
    end

    def test_parse_uniprot_DR_line
      str = 'DR   EMBL; Z14088; CAA78466.1; -; mRNA.'
      xref = Bio::Sequence::DBLink.parse_uniprot_DR_line(str)
      assert_equal('EMBL', xref.database)
      assert_equal('Z14088', xref.id)
      assert_equal([ 'CAA78466.1', '-', 'mRNA' ],
                   xref.secondary_ids)
    end
  end #class

end #module Bio
