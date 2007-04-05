#
# test/unit/bio/db/test_aaindex.rb - Unit test for Bio::AAindex
#
# Copyright::  Copyright (C) 2006 
#              Mitsuteru C. Nakao <n@bioruby.org>
# License::    The Ruby License
#
# $Id: test_aaindex.rb,v 1.4 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/io/fetch'
require 'bio/db/aaindex'

module Bio
  class DataAAindex
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s    
    TestDataAAindex = Pathname.new(File.join(bioruby_root, 'test', 'data', 'aaindex')).cleanpath.to_s

    def self.aax1
      File.read(File.join(TestDataAAindex, "PRAM900102"))
    end

    def self.aax2
      File.read(File.join(TestDataAAindex, "DAYM780301"))
    end
  end

  # A super class for Bio::AAindex1 and Bio::AAindex2
  class TestAAindexConstant < Test::Unit::TestCase
    def test_delimiter
      rs = "\n//\n"
      assert_equal(rs, Bio::AAindex::DELIMITER)
      assert_equal(rs, Bio::AAindex::RS)
    end

    def test_tagsize
      assert_equal(2, Bio::AAindex::TAGSIZE)
    end
  end

  class TestAAindex < Test::Unit::TestCase
    def test_api
      api_methods = ['entry_id', 'definition', 'dblinks', 'author',
             'title', 'journal', 'comment']
      api_methods.each do |m|
      end
    end

    def test_auto_aax1
      assert_equal(Bio::AAindex1, Bio::AAindex.auto(DataAAindex.aax1).class)
    end

    def test_auto_aax2
      assert_equal(Bio::AAindex2, Bio::AAindex.auto(DataAAindex.aax2).class)
    end
  end

  class TestAAindex1 < Test::Unit::TestCase
    def setup
      str = DataAAindex.aax1
      @obj = Bio::AAindex1.new(str)
    end
    
    def test_entry_id
      assert_equal('PRAM900102', @obj.entry_id)
    end

    def test_definition
      assert_equal('Relative frequency in alpha-helix (Prabhakaran, 1990)', @obj.definition)
    end

    def test_dblinks
      assert_equal(['LIT:1614053b', 'PMID:2390062'], @obj.dblinks)
    end

    def test_author
      assert_equal('Prabhakaran, M.', @obj.author)
    end

    def test_title
      assert_equal('The distribution of physical, chemical and conformational properties in signal and nascent peptides', @obj.title)
    end

    def test_journal
      assert_equal('Biochem. J. 269, 691-696 (1990) Original reference of these three data: Creighton, T.E. In "Protein Structure and Melecular Properties", (Freeman, W.H., ed.), San Francisco P.235 (1983)', @obj.journal)
    end

    def test_comment
      assert_equal("", @obj.comment)
    end

    def test_correlation_coefficient
#      str = "LEVM780101 1.000 LEVM780104 0.964 PALJ810101 0.943 KANM800101 0.942 ISOY800101 0.929 MAXF760101 0.924 ROBB760101 0.916 GEIM800101 0.912 GEIM800104 0.907 RACS820108 0.904 PALJ810102 0.902 PALJ810109 0.898 NAGK730101 0.894 CRAJ730101 0.887 CHOP780201 0.873 TANS770101 0.854 KANM800103 0.850 QIAN880107 0.829 QIAN880106 0.827 BURA740101 0.805 NAGK730103 -0.809"
#      assert_equal(str, @obj.correlation_coefficient)
      # to be this ?
      hash = {'LEVM780101' => 1.000, 'LEVM780104' => 0.964, 'PALJ810101' => 0.943,  'KANM800101' => 0.942, 'ISOY800101' => 0.929, 'MAXF760101' => 0.924, 'ROBB760101' => 0.916, 'GEIM800101' => 0.912, 'GEIM800104' => 0.907, 'RACS820108' => 0.904, 'PALJ810102' => 0.902, 'PALJ810109' => 0.898, 'NAGK730101' => 0.894, 'CRAJ730101' => 0.887, 'CHOP780201' => 0.873, 'TANS770101' => 0.854, 'KANM800103' => 0.850, 'QIAN880107' => 0.829, 'QIAN880106' => 0.827,  'BURA740101' => 0.805, 'NAGK730103' => -0.809}
      assert_equal(hash, @obj.correlation_coefficient)
    end

    def test_index
      hash = {"V"=>0.91, "K"=>1.23, "W"=>0.99, "L"=>1.3, "A"=>1.29, "M"=>1.47, "Y"=>0.72, "C"=>1.11, "N"=>0.9, "D"=>1.04, "P"=>0.52, "E"=>1.44, "F"=>1.07, "Q"=>1.27, "G"=>0.56, "R"=>0.96, "S"=>0.82, "H"=>1.22, "T"=>0.82, "I"=>0.97}
      assert_equal(hash, @obj.index)
    end
  end


  class TestAAindex2 < Test::Unit::TestCase
    def setup
      str = DataAAindex.aax2
      @obj = Bio::AAindex2.new(str)
    end

    def test_entry_id
      assert_equal('DAYM780301', @obj.entry_id)
    end

    def test_definition
      assert_equal('Log odds matrix for 250 PAMs (Dayhoff et al., 1978)', @obj.definition)
    end

    def test_dblinks
      assert_equal([], @obj.dblinks)
    end

    def test_author
      assert_equal("Dayhoff, M.O., Schwartz, R.M. and Orcutt, B.C.", @obj.author)
    end

    def test_title
      assert_equal("A model of evolutionary change in proteins", @obj.title)
    end

    def test_journal
      assert_equal('In "Atlas of Protein Sequence and Structure", Vol.5, Suppl.3 (Dayhoff, M.O., ed.), National Biomedical Research Foundation, Washington, D.C., p.352 (1978)', @obj.journal)
    end

    def test_comment
      assert_equal("", @obj.comment)
    end

    def test_rows
      ary = ["A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V"]
      assert_equal(ary, @obj.rows)
    end

    def test_cols
      ary = ["A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V"]
      assert_equal(ary, @obj.cols)
    end

    def test_matrix
      assert_equal(Matrix, @obj.matrix.class)
    end

    def test_matrix_2_2
      assert_equal(2.0, @obj.matrix[2, 2])
    end

    def test_matrix_1_2
      assert_equal(nil, @obj.matrix[1, 2])
    end

    def test_access_A_R
      assert_equal(nil, @obj['A', 'R'])
    end

    def test_access_R_A
      assert_equal(-2.0, @obj['R', 'A'])
    end

    def test_matrix_A_R
      assert_equal(nil, @obj.matrix('A', 'R'))
    end

    def test_matrix_R_A
      assert_equal(-2.0, @obj.matrix('R', 'A'))
    end

    def test_matrix_determinant
      assert_equal(0, @obj.matrix.determinant)
    end

    def test_matrix_rank
      assert_equal(1, @obj.matrix.rank)
    end

    def test_matrix_transpose
      ary = Matrix[[2.0, -2.0, 0.0, 0.0, -2.0, 0.0, 0.0, 1.0, -1.0, -1.0, -2.0, -1.0, -1.0, -4.0, 1.0, 1.0, 1.0, -6.0, -3.0, 0.0]]
      assert_equal(ary, @obj.matrix.transpose)
    end
  end    
end
