#
# = test/unit/bio/db/pdb/test_pdb.rb - Unit test for Bio::PDB classes
#
# Copyright:: Copyright (C) 2006
#             Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id: test_pdb.rb,v 1.3 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio'

module Bio
  #class TestPDB < Test::Unit::TestCase
  #end #class TestPDB

  module TestPDBRecord

    # test of Bio::PDB::Record::ATOM
    class TestATOM < Test::Unit::TestCase
      def setup
        # the data is taken from
        # http://www.rcsb.org/pdb/file_formats/pdb/pdbguide2.2/part_62.html
        @str = 'ATOM    154  CG2BVAL A  25      29.909  16.996  55.922  0.72 13.25      A1   C  '
        @atom = Bio::PDB::Record::ATOM.new.initialize_from_string(@str)
      end

      def test_record_name
        assert_equal('ATOM', @atom.record_name)
      end

      def test_serial
        assert_equal(154, @atom.serial)
      end

      def test_name
        assert_equal('CG2', @atom.name)
      end

      def test_altLoc
        assert_equal('B', @atom.altLoc)
      end

      def test_resName
        assert_equal('VAL', @atom.resName)
      end

      def test_chainID
        assert_equal('A', @atom.chainID)
      end

      def test_resSeq
        assert_equal(25, @atom.resSeq)
      end

      def test_iCode
        assert_equal('', @atom.iCode)
      end

      def test_x
        assert_in_delta(29.909, @atom.x, Float::EPSILON)
      end

      def test_y
        assert_in_delta(16.996, @atom.y, Float::EPSILON)
      end

      def test_z
        assert_in_delta(55.922, @atom.z, Float::EPSILON)
      end

      def test_occupancy
        assert_in_delta(0.72, @atom.occupancy, Float::EPSILON)
      end

      def test_tempFactor
        assert_in_delta(13.25, @atom.tempFactor, Float::EPSILON)
      end

      def test_segID
        assert_equal('A1', @atom.segID)
      end

      def test_element
        assert_equal('C', @atom.element)
      end

      def test_charge
        assert_equal('', @atom.charge)
      end

      def test_xyz
        assert_equal(Bio::PDB::Coordinate[
                       "29.909".to_f,
                       "16.996".to_f,
                       "55.922".to_f ], @atom.xyz)
      end

      def test_to_a
        assert_equal([ "29.909".to_f,
                       "16.996".to_f,
                       "55.922".to_f ], @atom.to_a)
      end

      def test_comparable
        a = Bio::PDB::Record::ATOM.new
        a.serial = 999
        assert_equal(-1, @atom <=> a)
        a.serial = 154
        assert_equal( 0, @atom <=> a)
        a.serial = 111
        assert_equal( 1, @atom <=> a)
      end

      def test_to_s
        assert_equal(@str + "\n", @atom.to_s)
      end

      def test_original_data
        assert_equal([ @str ], @atom.original_data)
      end

      def test_do_parse
        assert_equal(@atom, @atom.do_parse)
      end

      def test_residue
        assert_equal(nil, @atom.residue)
      end

      def test_sigatm
        assert_equal(nil, @atom.sigatm)
      end

      def test_anisou
        assert_equal(nil, @atom.anisou)
      end

      def test_ter
        assert_equal(nil, @atom.ter)
      end
    end #class TestATOM

  end #module TestPDBRecord

end #module Bio
