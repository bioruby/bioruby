#
# = test/unit/bio/db/pdb/test_pdb.rb - Unit test for Bio::PDB classes
#
# Copyright:: Copyright (C) 2010 Kazuhiro Hayashi <k.hayashi.info@gmail.com>
# Copyright:: Copyright (C) 2006 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#

# loading helper routine for testing bioruby
require 'pathname'
require 'matrix'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'bio'

module Bio

  #This class tests Bio::PDB class.
  #The sample record isn't sufficient because it cannot pass through all of the case statement...
  class TestPDB < Test::Unit::TestCase
    def setup
      str =<<EOF
HEADER    OXIDOREDUCTASE                          12-AUG-09   3INJ
TITLE     HUMAN MITOCHONDRIAL ALDEHYDE DEHYDROGENASE COMPLEXED WITH
DBREF  3INJ A    1   500  UNP    P05091   ALDH2_HUMAN     18    517
HELIX    1   1 ASP A   55  PHE A   70  1                                  16
KEYWDS    OXIDOREDUCTASE, ALDH, E487K, ROSSMANN FOLD, ALDA-1,
SEQRES   1 A  500  SER ALA ALA ALA THR GLN ALA VAL PRO ALA PRO ASN GLN
SHEET    1   A 2 ILE A  22  ILE A  24  0
SSBOND   1 CYS B  301    CYS B  303                          1555   1555  2.97
REVDAT   1   12-JAN-10 3INJ
MODEL        1
ATOM      1  N   ALA A   7      23.484 -35.866  44.510  1.00 28.52           N
ANISOU    1  N   ALA A   7     2406   1892   1614    198    519   -328       N
SIGUIJ    1  N   ALA A   7       10     10     10     10     10     10       N
SIGATM    1  N   ALA     7       0.040   0.030   0.030  0.00  0.00           N
ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C
ANISOU    2  CA  ALA A   7     2748   2004   1679    -21    155   -419       C
SIGUIJ    2  CA  ALA A   7       10     10     10     10     10     10       C
SIGATM    2  CA  ALA     7       0.040   0.030   0.030  0.00  0.00           C
ATOM      3  C   ALA A   7      23.102 -34.082  46.159  1.00 26.68           C
ANISOU    3  C   ALA A   7     2555   1955   1468     87    357   -109       C
SIGUIJ    3  C   ALA A   7       10     10     10     10     10     10       C
SIGATM    3  N   ALA     7       0.040   0.030   0.030  0.00  0.00           C
ATOM      4  O   ALA A   7      23.097 -32.903  46.524  1.00 30.02           O
ANISOU    4  O   ALA A   7     2555   1955   1468     87    357   -109       O
SIGUIJ    4  O   ALA A   7       10     10     10     10     10     10       O
SIGATM    4  O   ALA     7       0.040   0.030   0.030  0.00  0.00           O
ATOM      5  CB  ALA A   7      23.581 -33.526  43.770  1.00 31.41           C
ANISOU    5  CB  ALA A   7     2555   1955   1468     87    357   -109       C
SIGUIJ    5  CB  ALA A   7       10     10     10     10     10     10       C
SIGATM    1  CB  ALA     7       0.040   0.030   0.030  0.00  0.00           C
MODEL        2
ATOM      1  N   ALA A   7      23.484 -35.866  44.510  1.00 28.52           N
TER    3821      SER A 500
HETATM30582  C1  EDO A 701      -0.205 -27.262  49.961  1.00 34.45           C
HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O
HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C
HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O
HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C
HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O
HETATM30588  C2  EDO A 702       3.678   7.589  66.425  1.00 15.31           C
HETATM30589  O2  EDO A 702       3.391   6.512  65.550  1.00 17.67           O
HETATM30857  O   HOH A 502      13.654 -16.451  49.711  1.00 12.79           O
EOF
      @pdb = Bio::PDB.new(str)
    end
    def test_accession
      assert_equal("3INJ", @pdb.accession)
    end
    def test_addModel
      assert_nothing_raised{@pdb.addModel(Bio::PDB::Model.new(1,nil))}
    end
    def test_authors
      assert_equal([],@pdb.authors)
    end
    def test_classification
      assert_equal("OXIDOREDUCTASE",@pdb.classification)
    end
    def test_dbref
      assert_instance_of(Bio::PDB::Record::DBREF,@pdb.dbref.first)
      assert_instance_of(Bio::PDB::Record::DBREF,@pdb.dbref("A").first)
    end
    def test_definition
      assert_equal("HUMAN MITOCHONDRIAL ALDEHYDE DEHYDROGENASE COMPLEXED WITH",@pdb.definition)
    end
    def test_each
      expected = [nil, 1, 2, 3]
      pdb = Bio::PDB.new(" ")
      pdb.addModel(Bio::PDB::Model.new(1,nil))
      pdb.addModel(Bio::PDB::Model.new(2,nil))
      pdb.addModel(Bio::PDB::Model.new(3,nil))
      actual = []
      pdb.each do |model|
        actual << model.serial
      end
      assert_equal(expected,actual)
    end
    def test_each_model
      expected = [nil, 1, 2, 3]
      pdb = Bio::PDB.new("")
      pdb.addModel(Bio::PDB::Model.new(1,nil))
      pdb.addModel(Bio::PDB::Model.new(2,nil))
      pdb.addModel(Bio::PDB::Model.new(3,nil))
      actual = []
      pdb.each_model do |model|
        actual << model.serial
      end
      assert_equal(expected,actual)
    end

    def test_entry_id
      assert_equal("3INJ", @pdb.entry_id)
    end
    def test_helix
      assert_instance_of(Array, @pdb.helix)
      assert_equal(nil,@pdb.helix(1))
    end
    def test_inspect
      assert_equal("#<Bio::PDB entry_id=\"3INJ\">",@pdb.inspect)
    end
    def test_jrnl
      assert_instance_of(Hash, @pdb.jrnl)
    end
    def test_keywords
      assert_equal(["OXIDOREDUCTASE", "ALDH", "E487K", "ROSSMANN FOLD", "ALDA-1"],@pdb.keywords)
    end
    def test_remark
      str =<<EOS
REMARK   1 REFERENCE 1
REMARK   1  AUTH   C.H.CHEN,G.R.BUDAS,E.N.CHURCHILL,M.H.DISATNIK
REMARK   2 
REMARK   3
EOS

      expected =
     { 1 => {:remarkNum=>1,
                :sub_record=>"AUTH",
                :authorList=>["C.H.CHEN", "G.R.BUDAS", "E.N.CHURCHILL", "M.H.DISATNIK"]},
        2=>[],
        3=>[]}
      obj = Bio::PDB.new(str)
      actual = 
      { 1 => {:remarkNum=>obj.remark[1][0].remarkNum,
                :sub_record=>obj.remark[1][0].sub_record,
                :authorList=>obj.remark[1][0].authorList},
        2=>obj.remark[2],
        3=>obj.remark[3]}

      assert_equal(actual,expected)
    end
    def test_record
      assert_instance_of(Hash, @pdb.record)
    end
    def test_seqres
      assert_equal({"A"=>"SAAATQAVPAPNQ"},@pdb.seqres)
      assert_equal(nil,@pdb.seqres(7)) #I'm not sure why this returns nil
      str =<<EOS
SEQRES   1 X   39    U   C   C   C   C   C   G   U   G   C   C   C   A 
EOS
      obj = Bio::PDB.new(str)
      assert_equal({"X"=>"ucccccgugccca"},obj.seqres)
    end
    # too redundant?
    def test_sheet
      seq =<<EOS
SHEET    2 BS8 3 LYS   639  LYS   648 -1  N  PHE   643   O  HIS   662
SHEET    3 BS8 3 ASN   596  VAL   600 -1  N  TYR   598   O  ILE   646
EOS
      s = Bio::PDB.new(seq)
      actual = []
      s.sheet.each do |obj2|
        obj2.each do |obj|
      
      actual <<
  {:strand=>obj.strand,
   :sheetID=>obj.sheetID,
   :numStrands=>obj.numStrands,
   :initResName=>obj.initResName,
   :initChainID=>obj.initChainID,
   :initSeqNum=>obj.initSeqNum,
   :initICode=>obj.initICode,
   :endResName=>obj.endResName,
   :endChainID=>obj.endChainID,
   :endSeqNum=>obj.endSeqNum,
   :endICode=>obj.endICode,
   :sense=>obj.sense,
   :curAtom=>obj.curAtom,
   :curResName=>obj.curResName,
   :curChainId=>obj.curChainId,
   :curResSeq=>obj.curResSeq,
   :curICode=>obj.curICode,
   :prevAtom=>obj.prevAtom,
   :prevResName=>obj.prevResName,
   :prevChainId=>obj.prevChainId,
   :prevResSeq=>obj.prevResSeq,
   :prevICode=>obj.prevICode}
      end
      end
      expected =
  [
  {:strand=>2,
   :sheetID=>"BS8",
   :numStrands=>3,
   :initResName=>"LYS",
   :initChainID=>" ",
   :initSeqNum=>639,
   :initICode=>"",
   :endResName=>"LYS",
   :endChainID=>" ",
   :endSeqNum=>648,
   :endICode=>"",
   :sense=>-1,
   :curAtom=>" N",
   :curResName=>"PHE",
   :curChainId=>" ",
   :curResSeq=>643,
   :curICode=>"",
   :prevAtom=>" O",
   :prevResName=>"HIS",
   :prevChainId=>" ",
   :prevResSeq=>662,
   :prevICode=>""},

   {:strand=>3,
   :sheetID=>"BS8",
   :numStrands=>3,
   :initResName=>"ASN",
   :initChainID=>" ",
   :initSeqNum=>596,
   :initICode=>"",
   :endResName=>"VAL",
   :endChainID=>" ",
   :endSeqNum=>600,
   :endICode=>"",
   :sense=>-1,
   :curAtom=>" N",
   :curResName=>"TYR",
   :curChainId=>" ",
   :curResSeq=>598,
   :curICode=>"",
   :prevAtom=>" O",
   :prevResName=>"ILE",
   :prevChainId=>" ",
   :prevResSeq=>646,
   :prevICode=>""}]
      actual2 = []
      s.sheet("BS8").each do |obj2|
        obj2.each do |obj|

      actual2 <<
  {:strand=>obj.strand,
   :sheetID=>obj.sheetID,
   :numStrands=>obj.numStrands,
   :initResName=>obj.initResName,
   :initChainID=>obj.initChainID,
   :initSeqNum=>obj.initSeqNum,
   :initICode=>obj.initICode,
   :endResName=>obj.endResName,
   :endChainID=>obj.endChainID,
   :endSeqNum=>obj.endSeqNum,
   :endICode=>obj.endICode,
   :sense=>obj.sense,
   :curAtom=>obj.curAtom,
   :curResName=>obj.curResName,
   :curChainId=>obj.curChainId,
   :curResSeq=>obj.curResSeq,
   :curICode=>obj.curICode,
   :prevAtom=>obj.prevAtom,
   :prevResName=>obj.prevResName,
   :prevChainId=>obj.prevChainId,
   :prevResSeq=>obj.prevResSeq,
   :prevICode=>obj.prevICode}
      end
      end

      assert_equal(expected,actual)
      assert_equal(expected,actual2)
    end
    def test_ssbond
      assert_instance_of(Bio::PDB::Record::SSBOND,@pdb.ssbond.first)
    end
    
    #is this method correct?
    def test_to_s
      assert_equal("MODEL     1\nATOM      1  N   ALA A   7      23.484 -35.866  44.510  1.00 28.52           N  \nATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C  \nATOM      3  C   ALA A   7      23.102 -34.082  46.159  1.00 26.68           C  \nATOM      4  O   ALA A   7      23.097 -32.903  46.524  1.00 30.02           O  \nATOM      5  CB  ALA A   7      23.581 -33.526  43.770  1.00 31.41           C  \nTER\nENDMDL\nMODEL     2\nATOM      1  N   ALA A   7      23.484 -35.866  44.510  1.00 28.52           N  \nTER\nHETATM30582  C1  EDO A 701      -0.205 -27.262  49.961  1.00 34.45           C  \nHETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O  \nHETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C  \nHETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O  \nHETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C  \nHETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O  \nHETATM30588  C2  EDO A 702       3.678   7.589  66.425  1.00 15.31           C  \nHETATM30589  O2  EDO A 702       3.391   6.512  65.550  1.00 17.67           O  \nHETATM30857  O   HOH A 502      13.654 -16.451  49.711  1.00 12.79           O  \nENDMDL\nEND\n",@pdb.to_s)
    end
    def test_turn
      assert_equal([],@pdb.turn)
      assert_equal(nil,@pdb.turn(1))

    end
    def test_version
      assert_equal(1,@pdb.version)
    end

    def test_bracket #test for []
      assert_equal(1,@pdb[1].serial)
    end


  end

  #TestPDBRecord::Test* are unit tests for pdb field classes.
  #each test class uses one line or several lines of PDB record.
  #they tests all the methods described or generated in Bio::PDB::Record.

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
        assert_in_delta(29.909, @atom.x, 0.0001)
      end

      def test_y
        assert_in_delta(16.996, @atom.y, 0.0001)
      end

      def test_z
        assert_in_delta(55.922, @atom.z, 0.0001)
      end

      def test_occupancy
        assert_in_delta(0.72, @atom.occupancy, 0.001)
      end

      def test_tempFactor
        assert_in_delta(13.25, @atom.tempFactor, 0.001)
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

    # test of Bio::PDB::Record::ATOM
    class TestHETATM < Test::Unit::TestCase
      def setup
        # the data is taken from
        # http://www.rcsb.org/pdb/file_formats/pdb/pdbguide2.2/part_62.html
        @str = 'HETATM30581 NA    NA A 601       5.037 -39.853  62.809  1.00 17.37          NA  '
        @hetatm = Bio::PDB::Record::HETATM.new.initialize_from_string(@str)
      end

      def test_record_name
        assert_equal('HETATM', @hetatm.record_name)
      end

      def test_serial
        assert_equal(30581, @hetatm.serial)
      end

      def test_name
        assert_equal('NA', @hetatm.name)
      end

      def test_altLoc
        assert_equal(' ', @hetatm.altLoc)
      end

      def test_resName
        assert_equal('NA', @hetatm.resName)
      end

      def test_chainID
        assert_equal('A', @hetatm.chainID)
      end

      def test_resSeq
        assert_equal(601, @hetatm.resSeq)
      end

      def test_iCode
        assert_equal('', @hetatm.iCode)
      end

      def test_x
        assert_in_delta(5.037, @hetatm.x, 0.0001)
      end

      def test_y
        assert_in_delta(-39.853, @hetatm.y, 0.0001)
      end

      def test_z
        assert_in_delta(62.809, @hetatm.z, 0.0001)
      end

      def test_occupancy
        assert_in_delta(1.00, @hetatm.occupancy, 0.001)
      end

      def test_tempFactor
        assert_in_delta(17.37, @hetatm.tempFactor, 0.001)
      end

      def test_segID
        assert_equal('', @hetatm.segID)
      end

      def test_element
        assert_equal('NA', @hetatm.element)
      end

      def test_charge
        assert_equal('', @hetatm.charge)
      end

      def test_xyz
        assert_equal(Bio::PDB::Coordinate[
                       "5.037".to_f,
                       "-39.853".to_f,
                       "62.809".to_f ], @hetatm.xyz)
      end

      def test_to_a
        assert_equal([ "5.037".to_f,
                       "-39.853".to_f,
                       "62.809".to_f ], @hetatm.to_a)
      end

      def test_comparable
        a = Bio::PDB::Record::HETATM.new
        a.serial = 40000
        assert_equal(-1, @hetatm <=> a)
        a.serial = 30581
        assert_equal( 0, @hetatm <=> a)
        a.serial = 30000
        assert_equal( 1, @hetatm <=> a)
      end

      def test_to_s
        assert_equal(@str + "\n", @hetatm.to_s)
      end

      def test_original_data
        assert_equal([ @str ], @hetatm.original_data)
      end

      def test_do_parse
        assert_equal(@hetatm, @hetatm.do_parse)
      end

      def test_residue
        assert_equal(nil, @hetatm.residue)
      end

      def test_sigatm
        assert_equal(nil, @hetatm.sigatm)
      end

      def test_anisou
        assert_equal(nil, @hetatm.anisou)
      end

      def test_ter
        assert_equal(nil, @hetatm.ter)
      end
    end #class TestATOM

    class TestHEADER < Test::Unit::TestCase
      def setup
        @str = 'HEADER    OXIDOREDUCTASE                          12-AUG-09   3INJ              '
        @header = Bio::PDB::Record::HEADER.new.initialize_from_string(@str)
      end


      def test_classification
        assert_equal('OXIDOREDUCTASE', @header.classification)
      end


      def test_depDate
        assert_equal('12-AUG-09', @header.depDate)
      end


      def test_idCode
        assert_equal('3INJ', @header.idCode)
      end


    end

    class TestOBSLTE < Test::Unit::TestCase
      def setup
        @str = 'OBSLTE     31-JAN-94 1MBP      2MBP                                   '
        @obslte = Bio::PDB::Record::OBSLTE.new.initialize_from_string(@str)
      end


      def test_repDate
        assert_equal('31-JAN-94', @obslte.repDate)
      end


      def test_idCode
        assert_equal('1MBP', @obslte.idCode)
      end


      def test_rIdCode
        assert_equal(["2MBP"], @obslte.rIdCode)
      end

    end

    #Is this unit test correct?
    class TestTITLE < Test::Unit::TestCase
      def setup
        @str =
"TITLE     HUMAN MITOCHONDRIAL ALDEHYDE DEHYDROGENASE COMPLEXED WITH             \n
TITLE    2 AGONIST ALDA-1                                                       "
        @title = Bio::PDB::Record::TITLE.new.initialize_from_string(@str)
      end


      def test_title
        assert_equal('HUMAN MITOCHONDRIAL ALDEHYDE DEHYDROGENASE COMPLEXED WITH', @title.title)
      end


    end

    class TestCAVEAT < Test::Unit::TestCase
      def setup
        @str = 'CAVEAT     1ABC    INCORRECT'
        @caveat = Bio::PDB::Record::CAVEAT.new.initialize_from_string(@str)
      end


      def test_idcode
        assert_equal('1ABC', @caveat.idcode)
      end


      def test_comment
        assert_equal('INCORRECT', @caveat.comment)
      end


    end

    class TestCOMPND < Test::Unit::TestCase
      def setup
        @str =<<EOS
COMPND    MOL_ID: 1;                                                            
COMPND   2 MOLECULE: ALDEHYDE DEHYDROGENASE, MITOCHONDRIAL;                     
COMPND   3 CHAIN: A, B, C, D, E, F, G, H;                                       
COMPND   4 SYNONYM: ALDH CLASS 2, ALDHI, ALDH-E2;                               
COMPND   5 EC: 1.2.1.3;                                                         
COMPND   6 ENGINEERED: YES                                                      

EOS
        @compnd = Bio::PDB::Record::COMPND.new.initialize_from_string(@str)
      end


      def test_compound
        assert_equal([["MOL_ID", "1"]], @compnd.compound)
      end


    end

    class TestSOURCE < Test::Unit::TestCase
      def setup
        @str =<<EOS
SOURCE    MOL_ID: 1;
SOURCE   2 ORGANISM_SCIENTIFIC: HOMO SAPIENS;
SOURCE   3 ORGANISM_COMMON: HUMAN;
SOURCE   4 ORGANISM_TAXID: 9606;
SOURCE   5 GENE: ALDH2, ALDM;
SOURCE   6 EXPRESSION_SYSTEM: ESCHERICHIA COLI;
SOURCE   7 EXPRESSION_SYSTEM_TAXID: 562;
SOURCE   8 EXPRESSION_SYSTEM_STRAIN: BL21(DE3);
SOURCE   9 EXPRESSION_SYSTEM_VECTOR_TYPE: PLASMID;
SOURCE  10 EXPRESSION_SYSTEM_PLASMID: PT-7-7
EOS
        @source = Bio::PDB::Record::SOURCE.new.initialize_from_string(@str)
      end


      def test_srcName
        expected =
          [["MOL_ID", "1"], ["SOURCE   2 ORGANISM_SCIENTIFIC", "HOMO SAPIENS"], ["SOU"]]
        assert_equal(expected, @source.srcName)
      end
    end

    class TestKEYWDS < Test::Unit::TestCase
      def setup
        @str =<<EOF
KEYWDS    OXIDOREDUCTASE, ALDH, E487K, ROSSMANN FOLD, ALDA-1,
KEYWDS   2 ACTIVATOR, ACETYLATION, MITOCHONDRION, NAD, POLYMORPHISM,
KEYWDS   3 TRANSIT PEPTIDE
EOF
        @keywds = Bio::PDB::Record::KEYWDS.new.initialize_from_string(@str)
      end


      def test_keywds
        assert_equal(["OXIDOREDUCTASE", "ALDH", "E487K", "ROSSMANN FOLD", "ALDA-1", "KEYWDS"], @keywds.keywds)
      end

    end

    class TestEXPDTA < Test::Unit::TestCase
      def setup
        @str = <<EOF
EXPDTA    X-RAY DIFFRACTION
EOF
        @expdta = Bio::PDB::Record::EXPDTA.new.initialize_from_string(@str)
      end


      def test_technique
        assert_equal(["X-RAY DIFFRACTION"], @expdta.technique)
      end


    end

    class TestAUTHOR < Test::Unit::TestCase
      def setup
        @str = 'AUTHOR    S.PEREZ-MILLER,T.D.HURLEY'
        @author = Bio::PDB::Record::AUTHOR.new.initialize_from_string(@str)
      end


      def test_authorList
        assert_equal(["S.PEREZ-MILLER", "T.D.HURLEY"], @author.authorList)
      end


    end

    class TestREVDAT < Test::Unit::TestCase
      def setup
        @str = 'REVDAT   1   12-JAN-10 3INJ    0'
        @revdat = Bio::PDB::Record::REVDAT.new.initialize_from_string(@str)
      end


      def test_modNum
        assert_equal(1, @revdat.modNum )
      end


      def test_modDate
        assert_equal('12-JAN-10', @revdat.modDate)
      end


      def test_modId
        assert_equal('3INJ', @revdat.modId  )
      end


      def test_modType
        assert_equal(0, @revdat.modType)
      end


      def test_record
        assert_equal([], @revdat.record )
      end


    end

    class TestSPRSDE < Test::Unit::TestCase
      def setup
        @str = 'SPRSDE     17-JUL-84 4HHB      1HHB                             '
        @sprsde = Bio::PDB::Record::SPRSDE.new.initialize_from_string(@str)
      end


      def test_sprsdeDate
        assert_equal('17-JUL-84', @sprsde.sprsdeDate)
      end


      def test_idCode
        assert_equal('4HHB', @sprsde.idCode)
      end


      def test_sIdCode
        assert_equal(["1HHB"], @sprsde.sIdCode)
      end

    end

    class TestDBREF < Test::Unit::TestCase
      def setup
        @str =<<EOS
DBREF  3INJ A    1   500  UNP    P05091   ALDH2_HUMAN     18    517
DBREF  3INJ B    1   500  UNP    P05091   ALDH2_HUMAN     18    517
DBREF  3INJ C    1   500  UNP    P05091   ALDH2_HUMAN     18    517
DBREF  3INJ D    1   500  UNP    P05091   ALDH2_HUMAN     18    517
DBREF  3INJ E    1   500  UNP    P05091   ALDH2_HUMAN     18    517
DBREF  3INJ F    1   500  UNP    P05091   ALDH2_HUMAN     18    517
DBREF  3INJ G    1   500  UNP    P05091   ALDH2_HUMAN     18    517
DBREF  3INJ H    1   500  UNP    P05091   ALDH2_HUMAN     18    517
EOS
        @dbref = Bio::PDB::Record::DBREF.new.initialize_from_string(@str)
      end


      def test_idCode
        assert_equal('3INJ', @dbref.idCode     )
      end


      def test_chainID
        assert_equal('A', @dbref.chainID    )
      end


      def test_seqBegin
        assert_equal(1, @dbref.seqBegin   )
      end


      def test_insertBegin
        assert_equal('', @dbref.insertBegin)
      end


      def test_seqEnd
        assert_equal(500, @dbref.seqEnd     )
      end


      def test_insertEnd
        assert_equal('', @dbref.insertEnd  )
      end


      def test_database
        assert_equal('UNP', @dbref.database   )
      end


      def test_dbAccession
        assert_equal('P05091', @dbref.dbAccession)
      end


      def test_dbIdCode
        assert_equal('ALDH2_HUMAN', @dbref.dbIdCode   )
      end


      def test_dbseqBegin
        assert_equal(18, @dbref.dbseqBegin )
      end


      def test_idbnsBeg
        assert_equal('', @dbref.idbnsBeg   )
      end


      def test_dbseqEnd
        assert_equal(517, @dbref.dbseqEnd   )
      end
    end

    class TestSEQADV < Test::Unit::TestCase
      def setup
        @str = 'SEQADV 3ABC MET A   -1  UNP  P10725              EXPRESSION TAG'
        @seqadv = Bio::PDB::Record::SEQADV.new.initialize_from_string(@str)
      end


      def test_idCode
        assert_equal('3ABC', @seqadv.idCode  )
      end


      def test_resName
        assert_equal('MET', @seqadv.resName )
      end


      def test_chainID
        assert_equal('A', @seqadv.chainID )
      end


      def test_seqNum
        assert_equal(-1, @seqadv.seqNum  )
      end


      def test_iCode
        assert_equal('', @seqadv.iCode   )
      end


      def test_database
        assert_equal('UNP', @seqadv.database)
      end


      def test_dbIdCode
        assert_equal('P10725', @seqadv.dbIdCode)
      end


      def test_dbRes
        assert_equal('', @seqadv.dbRes   )
      end


      def test_dbSeq
        assert_equal(0, @seqadv.dbSeq   )
      end


      def test_conflict
        assert_equal('EXPRESSION TAG', @seqadv.conflict)
      end


    end

    class TestSEQRES < Test::Unit::TestCase
      def setup
        @str =<<EOS
SEQRES   1 A  500  SER ALA ALA ALA THR GLN ALA VAL PRO ALA PRO ASN GLN
SEQRES   2 A  500  GLN PRO GLU VAL PHE CYS ASN GLN ILE PHE ILE ASN ASN
SEQRES   3 A  500  GLU TRP HIS ASP ALA VAL SER ARG LYS THR PHE PRO THR
SEQRES   4 A  500  VAL ASN PRO SER THR GLY GLU VAL ILE CYS GLN VAL ALA
SEQRES   5 A  500  GLU GLY ASP LYS GLU ASP VAL ASP LYS ALA VAL LYS ALA
SEQRES   6 A  500  ALA ARG ALA ALA PHE GLN LEU GLY SER PRO TRP ARG ARG
SEQRES   7 A  500  MET ASP ALA SER HIS ARG GLY ARG LEU LEU ASN ARG LEU
SEQRES   8 A  500  ALA ASP LEU ILE GLU ARG ASP ARG THR TYR LEU ALA ALA
SEQRES   9 A  500  LEU GLU THR LEU ASP ASN GLY LYS PRO TYR VAL ILE SER          
EOS

        @seqres = Bio::PDB::Record::SEQRES.new.initialize_from_string(@str)
      end

      
      def test_chainID
        assert_equal('A', @seqres.chainID)
      end


      def test_numRes
        assert_equal(500, @seqres.numRes )
      end


      def test_resName
        expected =
          ["SER",
 "ALA",
 "ALA",
 "ALA",
 "THR",
 "GLN",
 "ALA",
 "VAL",
 "PRO",
 "ALA",
 "PRO",
 "ASN",
 "GLN"]
        assert_equal(expected, @seqres.resName)
      end

    end

    class TestMODRES < Test::Unit::TestCase
      def setup
        @str = 'MODRES 2R0L ASN A   74  ASN  GLYCOSYLATION SITE                     '
        @modres = Bio::PDB::Record::MODRES.new.initialize_from_string(@str)
      end


      def test_idCode
        assert_equal('2R0L', @modres.idCode)
      end


      def test_resName
        assert_equal('ASN', @modres.resName)
      end


      def test_chainID
        assert_equal('A', @modres.chainID)
      end


      def test_seqNum
        assert_equal(74, @modres.seqNum)
      end


      def test_iCode
        assert_equal('', @modres.iCode)
      end


      def test_stdRes
        assert_equal('ASN', @modres.stdRes)
      end


      def test_comment
        assert_equal('GLYCOSYLATION SITE', @modres.comment)
      end


    end

    class TestHET < Test::Unit::TestCase
      def setup
        @str = 'HET     NA  A 601       1                                                       '
        @het = Bio::PDB::Record::HET.new.initialize_from_string(@str)
      end


      def test_hetID
        assert_equal(' NA', @het.hetID)
      end


      def test_ChainID
        assert_equal('A', @het.ChainID)
      end


      def test_seqNum
        assert_equal(601, @het.seqNum)
      end


      def test_iCode
        assert_equal('', @het.iCode)
      end


      def test_numHetAtoms
        assert_equal(1, @het.numHetAtoms)
      end


      def test_text
        assert_equal('', @het.text)
      end


    end

    class TestSHEET < Test::Unit::TestCase
      def setup
        @str =<<EOS
SHEET    1   A 2 ILE A  22  ILE A  24  0                             
SHEET    2   A 2 GLU A  27  HIS A  29 -1  O  HIS A  29   N  ILE A  22
SHEET    1   B 2 THR A  36  VAL A  40  0                             
EOS
        @sheet = Bio::PDB::Record::SHEET.new.initialize_from_string(@str)
      end


      def test_strand
        assert_equal(1, @sheet.strand)
      end


      def test_sheetID
        assert_equal('A', @sheet.sheetID)
      end


      def test_numStrands
        assert_equal(2, @sheet.numStrands)
      end


      def test_initResName
        assert_equal('ILE', @sheet.initResName)
      end


      def test_initChainID
        assert_equal('A', @sheet.initChainID)
      end


      def test_initSeqNum
        assert_equal(22, @sheet.initSeqNum)
      end


      def test_initICode
        assert_equal('', @sheet.initICode)
      end


      def test_endResName
        assert_equal('ILE', @sheet.endResName)
      end


      def test_endChainID
        assert_equal('A', @sheet.endChainID)
      end


      def test_endSeqNum
        assert_equal(24, @sheet.endSeqNum)
      end


      def test_endICode
        assert_equal('', @sheet.endICode)
      end


      def test_sense
        assert_equal(0, @sheet.sense)
      end


      def test_curAtom
        assert_equal('', @sheet.curAtom)
      end


      def test_curResName
        assert_equal('', @sheet.curResName)
      end


      def test_curChainId
        assert_equal(' ', @sheet.curChainId)
      end


      def test_curResSeq
        assert_equal(0, @sheet.curResSeq)
      end


      def test_curICode
        assert_equal('', @sheet.curICode)
      end


      def test_prevAtom
        assert_equal('', @sheet.prevAtom)
      end


      def test_prevResName
        assert_equal('', @sheet.prevResName)
      end


      def test_prevChainId
        assert_equal(' ', @sheet.prevChainId)
      end


      def test_prevResSeq
        assert_equal(0, @sheet.prevResSeq)
      end


      def test_prevICode
        assert_equal('', @sheet.prevICode)
      end


    end

    class TestLINK < Test::Unit::TestCase
      def setup
        @str = 'LINK         O   VAL A  40                NA    NA A 601     1555   1555  2.41  '
        @link = Bio::PDB::Record::LINK.new.initialize_from_string(@str)
      end


      def test_name1
        assert_equal(' O', @link.name1)
      end


      def test_altLoc1
        assert_equal(' ', @link.altLoc1)
      end


      def test_resName1
        assert_equal('VAL', @link.resName1)
      end


      def test_chainID1
        assert_equal('A', @link.chainID1)
      end


      def test_resSeq1
        assert_equal(40, @link.resSeq1)
      end


      def test_iCode1
        assert_equal('', @link.iCode1)
      end


      def test_name2
        assert_equal("NA", @link.name2)
      end


      def test_altLoc2
        assert_equal(' ', @link.altLoc2)
      end


      def test_resName2
        assert_equal(' NA', @link.resName2)
      end


      def test_chainID2
        assert_equal('A', @link.chainID2)
      end


      def test_resSeq2
        assert_equal(601, @link.resSeq2)
      end


      def test_iCode2
        assert_equal('', @link.iCode2)
      end


      def test_sym1
        assert_equal('  1555', @link.sym1)
      end


      def test_sym2
        assert_equal('  1555', @link.sym2)
      end


    end

    class TestHYDBND < Test::Unit::TestCase
      def setup
        @str = 'HYDBND       O   PHE A    2        A    4  1HN  AIB A    4                    '
        @hydbnd = Bio::PDB::Record::HYDBND.new.initialize_from_string(@str)
      end


      def test_name1
        assert_equal(' O', @hydbnd.name1)
      end


      def test_altLoc1
        assert_equal(' ', @hydbnd.altLoc1)
      end


      def test_resName1
        assert_equal('PHE', @hydbnd.resName1)
      end


      def test_Chain1
        assert_equal('A', @hydbnd.Chain1)
      end


      def test_resSeq1
        assert_equal(2, @hydbnd.resSeq1)
      end


      def test_ICode1
        assert_equal('', @hydbnd.ICode1)
      end


      def test_nameH
        assert_equal('', @hydbnd.nameH)
      end


      def test_altLocH
        assert_equal(' ', @hydbnd.altLocH)
      end


      def test_ChainH
        assert_equal('A', @hydbnd.ChainH)
      end


      def test_resSeqH
        assert_equal(4, @hydbnd.resSeqH)
      end


      def test_iCodeH
        assert_equal('', @hydbnd.iCodeH)
      end


      def test_name2
        assert_equal('1HN', @hydbnd.name2)
      end


      def test_altLoc2
        assert_equal(' ', @hydbnd.altLoc2)
      end


      def test_resName2
        assert_equal('AIB', @hydbnd.resName2)
      end


      def test_chainID2
        assert_equal('A', @hydbnd.chainID2)
      end


      def test_resSeq2
        assert_equal(4, @hydbnd.resSeq2)
      end


      def test_iCode2
        assert_equal('', @hydbnd.iCode2)
      end


      def test_sym1
        assert_equal('', @hydbnd.sym1)
      end


      def test_sym2
        assert_equal('', @hydbnd.sym2)
      end


    end

    #SLTBRG field is deprecated.
    class TestSLTBRG < Test::Unit::TestCase
      def setup
        @str = ''
        @sltbrg = Bio::PDB::Record::SLTBRG.new.initialize_from_string(@str)
      end


      def test_atom1
        assert_equal('', @sltbrg.atom1)
      end


      def test_altLoc1
        assert_equal("", @sltbrg.altLoc1)
      end


      def test_resName1
        assert_equal("", @sltbrg.resName1)
      end


      def test_chainID1
        assert_equal('', @sltbrg.chainID1)
      end


      def test_resSeq1
        assert_equal(0, @sltbrg.resSeq1)
      end


      def test_iCode1
        assert_equal('', @sltbrg.iCode1)
      end


      def test_atom2
        assert_equal('', @sltbrg.atom2)
      end


      def test_altLoc2
        assert_equal('', @sltbrg.altLoc2)
      end


      def test_resName2
        assert_equal('', @sltbrg.resName2)
      end


      def test_chainID2
        assert_equal('', @sltbrg.chainID2)
      end


      def test_resSeq2
        assert_equal(0, @sltbrg.resSeq2)
      end


      def test_iCode2
        assert_equal('', @sltbrg.iCode2)
      end


      def test_sym1
        assert_equal('', @sltbrg.sym1)
      end


      def test_sym2
        assert_equal('', @sltbrg.sym2)
      end


    end

    class TestCISPEP < Test::Unit::TestCase
      def setup
        @str = 'CISPEP   1 GLY A  116    GLY A  117          0        18.50         '
        @cispep = Bio::PDB::Record::CISPEP.new.initialize_from_string(@str)
      end


      def test_serNum
        assert_equal(1, @cispep.serNum)
      end


      def test_pep1
        assert_equal("GLY", @cispep.pep1)
      end


      def test_chainID1
        assert_equal('A', @cispep.chainID1)
      end


      def test_seqNum1
        assert_equal(116, @cispep.seqNum1)
      end


      def test_icode1
        assert_equal('', @cispep.icode1)
      end


      def test_pep2
        assert_equal('GLY', @cispep.pep2)
      end


      def test_chainID2
        assert_equal('A', @cispep.chainID2)
      end


      def test_seqNum2
        assert_equal(117, @cispep.seqNum2)
      end


      def test_icode2
        assert_equal('', @cispep.icode2)
      end


      def test_modNum
        assert_equal(0, @cispep.modNum)
      end


      def test_measure
        assert_equal(18.5, @cispep.measure)
      end


    end

    class TestSITE < Test::Unit::TestCase
      def setup
        @str =<<EOS
SITE     1 AC1  5 THR A  39  VAL A  40  ASP A 109  GLN A 196
SITE     2 AC1  5 HOH A4009                                                     
EOS
        @site = Bio::PDB::Record::SITE.new.initialize_from_string(@str)
      end


      def test_seqNum
        assert_equal(1, @site.seqNum   )
      end


      def test_siteID
        assert_equal('AC1', @site.siteID   )
      end


      def test_numRes
        assert_equal(5, @site.numRes   )
      end


      def test_resName1
        assert_equal('THR', @site.resName1 )
      end


      def test_chainID1
        assert_equal('A', @site.chainID1 )
      end


      def test_seq1
        assert_equal(39, @site.seq1     )
      end


      def test_iCode1
        assert_equal('', @site.iCode1   )
      end


      def test_resName2
        assert_equal('VAL', @site.resName2 )
      end


      def test_chainID2
        assert_equal('A', @site.chainID2 )
      end


      def test_seq2
        assert_equal(40, @site.seq2     )
      end


      def test_iCode2
        assert_equal('', @site.iCode2   )
      end


      def test_resName3
        assert_equal('ASP', @site.resName3 )
      end


      def test_chainID3
        assert_equal('A', @site.chainID3 )
      end


      def test_seq3
        assert_equal(109, @site.seq3     )
      end


      def test_iCode3
        assert_equal('', @site.iCode3   )
      end


      def test_resName4
        assert_equal('GLN', @site.resName4 )
      end


      def test_chainID4
        assert_equal('A', @site.chainID4 )
      end


      def test_seq4
        assert_equal(196, @site.seq4     )
      end


      def test_iCode4
        assert_equal('', @site.iCode4   )
      end


    end

    class TestCRYST1 < Test::Unit::TestCase
      def setup
        @str = 'CRYST1  117.000   15.000   39.000  90.00  90.00  90.00 P 21 21 21    8'
        @cryst1 = Bio::PDB::Record::CRYST1.new.initialize_from_string(@str)
      end


      def test_a
        assert_equal(117.0, @cryst1.a)
      end


      def test_b
        assert_equal(15.0, @cryst1.b)
      end


      def test_c
        assert_equal(39.0, @cryst1.c)
      end


      def test_alpha
        assert_equal(90.0, @cryst1.alpha)
      end


      def test_beta
        assert_equal(90.0, @cryst1.beta)
      end


      def test_gamma
        assert_equal(90.0, @cryst1.gamma)
      end


      def test_sGroup
        assert_equal("P 21 21 21 ", @cryst1.sGroup)
      end


      def test_z
        assert_equal(8, @cryst1.z)
      end


    end

    class TestORIGX1 < Test::Unit::TestCase
      def setup
        @str = 'ORIGX1      1.000000  0.000000  0.000000        0.00000                         '
        @origx1 = Bio::PDB::Record::ORIGX1.new.initialize_from_string(@str)
      end


      def test_On1
        assert_equal(1.0, @origx1.On1)
      end


      def test_On2
        assert_equal(0.0, @origx1.On2)
      end


      def test_On3
        assert_equal(0.0, @origx1.On3)
      end


      def test_Tn
        assert_equal(0.0, @origx1.Tn)
      end


    end

    class TestSCALE1 < Test::Unit::TestCase
      def setup
        @str = 'SCALE1      0.019231  0.000000  0.000000        0.00000               '
        @scale1 = Bio::PDB::Record::SCALE1.new.initialize_from_string(@str)
      end


      def test_Sn1
        assert_equal(0.019231, @scale1.Sn1)
      end


      def test_Sn2
        assert_equal(0.0, @scale1.Sn2)
      end


      def test_Sn3
        assert_equal(0.0, @scale1.Sn3)
      end


      def test_Un
        assert_equal(0.0, @scale1.Un)
      end


    end

    class TestSCALE2 < Test::Unit::TestCase
      def setup
        @str = 'SCALE2      0.000000  0.017065  0.000000        0.00000               '
        @scale2 = Bio::PDB::Record::SCALE2.new.initialize_from_string(@str)
      end


      def test_Sn1
        assert_equal(0.0, @scale2.Sn1)
      end


      def test_Sn2
        assert_equal(0.017065, @scale2.Sn2)
      end


      def test_Sn3
        assert_equal(0.0, @scale2.Sn3)
      end


      def test_Un
        assert_equal(0.0, @scale2.Un)
      end


    end

    class TestSCALE3 < Test::Unit::TestCase
      def setup
        @str = 'SCALE3      0.000000  0.000000  0.016155        0.00000               '
        @scale3 = Bio::PDB::Record::SCALE3.new.initialize_from_string(@str)
      end


      def test_Sn1
        assert_equal(0.0, @scale3.Sn1)
      end


      def test_Sn2
        assert_equal(0.0, @scale3.Sn2)
      end


      def test_Sn3
        assert_equal(0.016155, @scale3.Sn3)
      end


      def test_Un
        assert_equal(0.0, @scale3.Un)
      end


    end

    class TestMTRIX1 < Test::Unit::TestCase
      def setup
        @str = 'MTRIX1   1 -1.000000  0.000000 -0.000000        0.00001    1          '
        @mtrix1 = Bio::PDB::Record::MTRIX1.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(1, @mtrix1.serial)
      end


      def test_Mn1
        assert_equal(-1.0, @mtrix1.Mn1)
      end


      def test_Mn2
        assert_equal(0.0, @mtrix1.Mn2)
      end


      def test_Mn3
        assert_equal(-0.0, @mtrix1.Mn3)
      end


      def test_Vn
        assert_equal(1.0e-05, @mtrix1.Vn)
      end


      def test_iGiven
        assert_equal(1, @mtrix1.iGiven)
      end


    end

    class TestMTRIX2 < Test::Unit::TestCase
      def setup
        @str = 'MTRIX2   1 -0.000000  1.000000  0.000000        0.00002    1          '
        @mtrix2 = Bio::PDB::Record::MTRIX2.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(1, @mtrix2.serial)
      end


      def test_Mn1
        assert_equal(-0.0, @mtrix2.Mn1)
      end


      def test_Mn2
        assert_equal(1.0, @mtrix2.Mn2)
      end


      def test_Mn3
        assert_equal(0.0, @mtrix2.Mn3)
      end


      def test_Vn
        assert_equal(2.0e-05, @mtrix2.Vn)
      end


      def test_iGiven
        assert_equal(1, @mtrix2.iGiven)
      end


    end

    class TestMTRIX3 < Test::Unit::TestCase
      def setup
        @str = 'MTRIX3   1  0.000000 -0.000000 -1.000000        0.00002    1          '
        @mtrix3 = Bio::PDB::Record::MTRIX3.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(1, @mtrix3.serial)
      end


      def test_Mn1
        assert_equal(0.0, @mtrix3.Mn1)
      end


      def test_Mn2
        assert_equal(-0.0, @mtrix3.Mn2)
      end


      def test_Mn3
        assert_equal(-1.0, @mtrix3.Mn3)
      end


      def test_Vn
        assert_equal(2.0e-05, @mtrix3.Vn)
      end


      def test_iGiven
        assert_equal(1, @mtrix3.iGiven)
      end


    end

    class TestTVECT < Test::Unit::TestCase
      def setup
        @str = 'TVECT    1   0.00000   0.00000  28.30000                              '
        @tvect = Bio::PDB::Record::TVECT.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(1, @tvect.serial)
      end


      def test_t1
        assert_equal(0.0, @tvect.t1)
      end


      def test_t2
        assert_equal(0.0, @tvect.t2)
      end


      def test_t3
        assert_equal(28.3, @tvect.t3)
      end


      def test_text
        assert_equal('', @tvect.text)
      end


    end

    class TestMODEL < Test::Unit::TestCase
      def setup
        @str = 'MODEL        1'
        @model = Bio::PDB::Record::MODEL.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(1, @model.serial)
      end


    end

    class TestSIGATM < Test::Unit::TestCase

      def setup
        @str = 'SIGATM  230  N   PRO    15       0.040   0.030   0.030  0.00  0.00           N'
        @sigatm = Bio::PDB::Record::SIGATM.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(230, @sigatm.serial)
      end


      def test_name
        assert_equal(' N', @sigatm.name)
      end


      def test_altLoc
        assert_equal(' ', @sigatm.altLoc)
      end


      def test_resName
        assert_equal('PRO', @sigatm.resName)
      end


      def test_chainID
        assert_equal(' ', @sigatm.chainID)
      end


      def test_resSeq
        assert_equal(15, @sigatm.resSeq)
      end


      def test_iCode
        assert_equal('', @sigatm.iCode)
      end


      def test_sigX
        assert_equal(0.04, @sigatm.sigX)
      end


      def test_sigY
        assert_equal(0.03, @sigatm.sigY)
      end


      def test_sigZ
        assert_equal(0.03, @sigatm.sigZ)
      end


      def test_sigOcc
        assert_equal(0.0, @sigatm.sigOcc)
      end


      def test_sigTemp
        assert_equal(0.0, @sigatm.sigTemp)
      end


      def test_segID
        assert_equal('    ', @sigatm.segID)
      end


      def test_element
        assert_equal(' N', @sigatm.element)
      end


      def test_charge
        assert_equal('  ', @sigatm.charge)
      end


    end

    class TestANISOU < Test::Unit::TestCase
      def setup
        @str = 'ANISOU  107  N   GLY    13     2406   1892   1614    198    519   -328       N'
        @anisou = Bio::PDB::Record::ANISOU.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(107, @anisou.serial)
      end


      def test_name
        assert_equal(' N', @anisou.name)
      end


      def test_altLoc
        assert_equal(' ', @anisou.altLoc)
      end


      def test_resName
        assert_equal('GLY', @anisou.resName)
      end


      def test_chainID
        assert_equal(' ', @anisou.chainID)
      end


      def test_resSeq
        assert_equal(13, @anisou.resSeq)
      end


      def test_iCode
        assert_equal('', @anisou.iCode)
      end


      def test_U11
        assert_equal(2406, @anisou.U11)
      end


      def test_U22
        assert_equal(1892, @anisou.U22)
      end


      def test_U33
        assert_equal(1614, @anisou.U33)
      end


      def test_U12
        assert_equal(198, @anisou.U12)
      end


      def test_U13
        assert_equal(519, @anisou.U13)
      end


      def test_U23
        assert_equal(-328, @anisou.U23)
      end


      def test_segID
        assert_equal('    ', @anisou.segID)
      end


      def test_element
        assert_equal(' N', @anisou.element)
      end


      def test_charge
        assert_equal('  ', @anisou.charge)
      end


    end

    class TestSIGUIJ < Test::Unit::TestCase
      def setup
        @str = 'SIGUIJ  107  N   GLY    13       10     10     10     10    10      10       N'
        @siguij = Bio::PDB::Record::SIGUIJ.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(107, @siguij.serial)
      end


      def test_name
        assert_equal(' N', @siguij.name)
      end


      def test_altLoc
        assert_equal(' ', @siguij.altLoc)
      end


      def test_resName
        assert_equal("GLY", @siguij.resName)
      end


      def test_chainID
        assert_equal(" ", @siguij.chainID)
      end


      def test_resSeq
        assert_equal(13, @siguij.resSeq)
      end


      def test_iCode
        assert_equal('', @siguij.iCode)
      end


      def test_SigmaU11
        assert_equal(10, @siguij.SigmaU11)
      end


      def test_SigmaU22
        assert_equal(10, @siguij.SigmaU22)
      end


      def test_SigmaU33
        assert_equal(10, @siguij.SigmaU33)
      end


      def test_SigmaU12
        assert_equal(10, @siguij.SigmaU12)
      end


      def test_SigmaU13
        assert_equal(10, @siguij.SigmaU13)
      end


      def test_SigmaU23
        assert_equal(10, @siguij.SigmaU23)
      end


      def test_segID
        assert_equal('    ', @siguij.segID)
      end


      def test_element
        assert_equal(' N', @siguij.element)
      end


      def test_charge
        assert_equal('  ', @siguij.charge)
      end


    end

    class TestTER < Test::Unit::TestCase
      def setup
        @str = 'TER    3821      SER A 500                                                      '
        @ter = Bio::PDB::Record::TER.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(3821, @ter.serial)
      end


      def test_resName
        assert_equal('SER', @ter.resName)
      end


      def test_chainID
        assert_equal('A', @ter.chainID)
      end


      def test_resSeq
        assert_equal(500, @ter.resSeq)
      end


      def test_iCode
        assert_equal('', @ter.iCode)
      end


    end

    class TestENDMDL < Test::Unit::TestCase
      def setup
        @str = 'ENDMDL'
        @endmdl = Bio::PDB::Record::ENDMDL.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(0, @endmdl.serial)
      end


    end

    class TestCONECT < Test::Unit::TestCase
      def setup
        @str = 'CONECT  27230581                                                                '
        @conect = Bio::PDB::Record::CONECT.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal([272, 30581], @conect.serial)
      end


    end

    class TestMASTER < Test::Unit::TestCase
      def setup
        @str = 'MASTER      589    0   41  150  164    0   77    634857    8  322  312          '
        @master = Bio::PDB::Record::MASTER.new.initialize_from_string(@str)
      end


      def test_numRemark
        assert_equal(589, @master.numRemark)
      end


      def test_numHet
        assert_equal(41, @master.numHet)
      end


      def test_numHelix
        assert_equal(150, @master.numHelix)
      end


      def test_numSheet
        assert_equal(164, @master.numSheet)
      end


      def test_numTurn
        assert_equal(0, @master.numTurn)
      end


      def test_numSite
        assert_equal(77, @master.numSite)
      end


      def test_numXform
        assert_equal(6, @master.numXform)
      end


      def test_numCoord
        assert_equal(34857, @master.numCoord)
      end


      def test_numTer
        assert_equal(8, @master.numTer)
      end


      def test_numConect
        assert_equal(322, @master.numConect)
      end


      def test_numSeq
        assert_equal(312, @master.numSeq)
      end


    end

    class TestRemarkN < Test::Unit::TestCase
      def setup
        @str =<<EOS
REMARK   3 REFINEMENT.
REMARK   3   PROGRAM     : PHENIX (PHENIX.REFINE: 1.4_4)
REMARK   3   AUTHORS     : PAUL ADAMS,PAVEL AFONINE,VICENT CHEN,IAN
REMARK   3               : DAVIS,KRESHNA GOPAL,RALF GROSSE-
REMARK   3               : KUNSTLEVE,LI-WEI HUNG,ROBERT IMMORMINO,
REMARK   3               : TOM IOERGER,AIRLIE MCCOY,ERIK MCKEE,NIGEL
REMARK   3               : MORIARTY,REETAL PAI,RANDY READ,JANE
REMARK   3               : RICHARDSON,DAVID RICHARDSON,TOD ROMO,JIM
REMARK   3               : SACCHETTINI,NICHOLAS SAUTER,JACOB SMITH,
REMARK   3               : LAURENT STORONI,TOM TERWILLIGER,PETER
REMARK   3               : ZWART
REMARK   3
REMARK   3    REFINEMENT TARGET : TWIN_LSQ_F                                    
EOS
        @remarkn = Bio::PDB::Record::RemarkN.new.initialize_from_string(@str)
      end


      def test_remarkNum
        assert_equal(3, @remarkn.remarkNum)
      end

      #Is the output correct?
      def test_text
        assert_equal("REFINEMENT.\nREMARK   3   PROGRAM     : PHENIX (PHENIX.REFIN", @remarkn.text)
      end


    end

    #What is this record?
    class TestDefault < Test::Unit::TestCase
      def setup
        @str = ''
        @default = Bio::PDB::Record::Default.new.initialize_from_string(@str)
      end


      def test_text
        assert_equal('', @default.text)
      end


    end

    class TestEnd < Test::Unit::TestCase
      def setup
        @str = "END                                                                             "
        @end = Bio::PDB::Record::End.new.initialize_from_string(@str)
      end


      def test_serial
        assert_equal(0, @end.serial)
      end


    end


    #end
  end #module TestPDBRecord
  
  #This class tests the behaviors of the complex types defined and used only in Bio::PDB classes.
  class TestDataType < Test::Unit::TestCase      
      
    def test_pdb_integer
      actual = Bio::PDB::DataType::Pdb_Integer.new("1")
      assert_equal(1, actual)
    end
    def test_pdb_slist
      actual = Bio::PDB::DataType::Pdb_SList.new("hoge; foo;  bar")
      assert_equal(["hoge", "foo", "bar"], actual)
    end    
    def test_pdb_list
      actual = Bio::PDB::DataType::Pdb_List.new("hoge, foo,  bar")
      assert_equal(["hoge", "foo", "bar"], actual)
    end
    def test_specification_list
      actual = Bio::PDB::DataType::Pdb_Specification_list.new("hoge: 1; foo: 2; bar: 3;")
      assert_equal([["hoge", "1"], ["foo", "2"], ["bar","3"]], actual)
    end

    def test_pdb_string
      actual = Bio::PDB::DataType::Pdb_String.new("hoge  \n  ")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_String[10].new("hoge")
      assert_equal("hoge      ", actual)
    end
    def test_pdb_lstring
      actual = Bio::PDB::DataType::Pdb_LString.new("hoge")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_LString[10].new("hoge")
      assert_equal("hoge      ", actual)
    end
    def test_pdb_real
      actual = Bio::PDB::DataType::Pdb_Real.new("1.25")
      assert_equal(1.25, actual)
      actual =Bio::PDB::DataType::Pdb_Real[10]
      #include actual
      #assert_equal(10, @@format)
    end

    def test_pdb_stringrj
      actual = Bio::PDB::DataType::Pdb_StringRJ.new("      hoge")
      assert_equal("hoge", actual)
    end

    def test_pdb_date
      actual = Bio::PDB::DataType::Pdb_Date.new("hoge")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_Date[10].new("hoge")
      assert_equal("hoge      ", actual)
    end

    def test_pdb_idcode
      actual = Bio::PDB::DataType::Pdb_IDcode.new("hoge")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_IDcode[10].new("hoge")
      assert_equal("hoge      ", actual)
    end
    
    def test_pdb_resudue_name
      actual = Bio::PDB::DataType::Pdb_Residue_name.new("hoge  \n  ")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_Residue_name[10].new("hoge")
      assert_equal("hoge      ", actual)
    end
    
    def test_pdb_symop
      actual = Bio::PDB::DataType::Pdb_Residue_name.new("hoge")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_Residue_name[10].new("hoge")
      assert_equal("hoge      ", actual)
    end
    
    def test_pdb_atom
      actual = Bio::PDB::DataType::Pdb_Residue_name.new("hoge")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_Residue_name[10].new("hoge")
      assert_equal("hoge      ", actual)
    end
    
    def test_pdb_achar
      actual = Bio::PDB::DataType::Pdb_Residue_name.new("hoge")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_Residue_name[10].new("hoge")
      assert_equal("hoge      ", actual)
    end

    def test_pdb_character
      actual = Bio::PDB::DataType::Pdb_Residue_name.new("hoge")
      assert_equal("hoge", actual)
      actual =Bio::PDB::DataType::Pdb_Residue_name[10].new("hoge")
      assert_equal("hoge      ", actual)
    end
    
    def test_const_like_method
      extend Bio::PDB::DataType::ConstLikeMethod
      actual = Pdb_LString(5).new("aaa")
      assert_equal("aaa  ", actual)
      actual = Pdb_String(5).new("aaa")
      assert_equal("aaa  ", actual)
      actual = Pdb_Real(3).new("1.25")
      assert_equal(1.25, actual)
    end
    
  end

  # test of Bio::PDB::Record::ATOM
  class TestResidue < Test::Unit::TestCase
    def setup
      # resName="ALA",resSeq = 7, iCode = "", chain = nil
      @res = Bio::PDB::Residue.new("ALA", 7, "", nil)
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      1  N   ALA A   7      23.484 -35.866  44.510  1.00 28.52           N"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      3  C   ALA A   7      23.102 -34.082  46.159  1.00 26.68           C"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      4  O   ALA A   7      23.097 -32.903  46.524  1.00 30.02           O"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      5  CB  ALA A   7      23.581 -33.526  43.770  1.00 31.41           C"))

    end
    def test_get_residue_id_from_atom
      id = Bio::PDB::Residue.get_residue_id_from_atom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      1  N   ALA A   7      23.48    4 -35.866  44.510  1.00 28.52           N"))
      assert_equal("7",id)
    end

    def test_addAtom
     assert_nothing_raised {
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      1  N   ALA A   7      23.484 -35.866  44.510  1.00 28.52           N"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string(" ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      3  C   ALA A   7      23.102 -34.082  46.159  1.00 26.68           C"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      4  O   ALA A   7      23.097 -32.903  46.524  1.00 30.02           O"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      5  CB  ALA A   7      23.581 -33.526  43.770  1.00 31.41           C"))
      }
    end
    def test_square_bracket
     expected = {:tempFactor=>27.89,
 :iCode=>"",
 :serial=>2,
 :charge=>"",
 :z=>44.904,
 :chainID=>"A",
 :segID=>"",
 :x=>23.849,
 :altLoc=>" ",
 :occupancy=>1.0,
 :resSeq=>7,
 :element=>"C",
 :name=>"CA",
 :y=>-34.509,
 :resName=>"ALA"}
      actual = {}
      @res["CA"].each_pair do |m, v|
        actual[m] = v
      end
      assert_equal(expected, actual)
    end 
    
    def test_each_atom
expected = [{:serial=>1, :name=>"N", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.484, :y=>-35.866, :z=>44.51, :occupancy=>1.0, :tempFactor=>28.52, :segID=>"", :element=>"N", :charge=>""},
{:serial=>2, :name=>"CA", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.849, :y=>-34.509, :z=>44.904, :occupancy=>1.0, :tempFactor=>27.89, :segID=>"", :element=>"C", :charge=>""},
{:serial=>3, :name=>"C", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.102, :y=>-34.082, :z=>46.159, :occupancy=>1.0, :tempFactor=>26.68, :segID=>"", :element=>"C", :charge=>""},{:serial=>4, :name=>"O", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.097, :y=>-32.903, :z=>46.524, :occupancy=>1.0, :tempFactor=>30.02, :segID=>"", :element=>"O", :charge=>""},
{:serial=>5, :name=>"CB", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.581, :y=>-33.526, :z=>43.77, :occupancy=>1.0, :tempFactor=>31.41, :segID=>"", :element=>"C", :charge=>""}]
      actual = []
      @res.each_atom do |atom|
        actual << {:serial=>atom.serial, :name=>atom.name, :altLoc=>atom.altLoc, :resName=>atom.resName, :chainID=>atom.chainID, :resSeq=>atom.resSeq, :iCode=>atom.iCode, :x=>atom.x, :y=>atom.y, :z=>atom.z, :occupancy=>atom.occupancy, :tempFactor=>atom.tempFactor, :segID=>atom.segID, :element=>atom.element, :charge=>atom.charge}
      end
      assert_equal(expected, actual)
    end    

    def test_each
expected = [{:serial=>1, :name=>"N", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.484, :y=>-35.866, :z=>44.51, :occupancy=>1.0, :tempFactor=>28.52, :segID=>"", :element=>"N", :charge=>""},
{:serial=>2, :name=>"CA", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.849, :y=>-34.509, :z=>44.904, :occupancy=>1.0, :tempFactor=>27.89, :segID=>"", :element=>"C", :charge=>""},
{:serial=>3, :name=>"C", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.102, :y=>-34.082, :z=>46.159, :occupancy=>1.0, :tempFactor=>26.68, :segID=>"", :element=>"C", :charge=>""},{:serial=>4, :name=>"O", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.097, :y=>-32.903, :z=>46.524, :occupancy=>1.0, :tempFactor=>30.02, :segID=>"", :element=>"O", :charge=>""},
{:serial=>5, :name=>"CB", :altLoc=>" ", :resName=>"ALA", :chainID=>"A", :resSeq=>7, :iCode=>"", :x=>23.581, :y=>-33.526, :z=>43.77, :occupancy=>1.0, :tempFactor=>31.41, :segID=>"", :element=>"C", :charge=>""}]
      actual = []
      @res.each do |atom|
        actual << {:serial=>atom.serial, :name=>atom.name, :altLoc=>atom.altLoc, :resName=>atom.resName, :chainID=>atom.chainID, :resSeq=>atom.resSeq, :iCode=>atom.iCode, :x=>atom.x, :y=>atom.y, :z=>atom.z, :occupancy=>atom.occupancy, :tempFactor=>atom.tempFactor, :segID=>atom.segID, :element=>atom.element, :charge=>atom.charge}
      end
      assert_equal(expected, actual)
    end    
    def test_het_atom
      assert_equal(false, @res.hetatm)
    end
    def test_iCode
      assert_equal( 1, @res.iCode=1)
    end
    def test_resSeq
      assert_equal( 1, @res.resSeq=1)
    end
    def test_to_s
      expected ="ATOM      1  N   ALA A   7      23.484 -35.866  44.510  1.00 28.52           N  \nATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C  \nATOM      3  C   ALA A   7      23.102 -34.082  46.159  1.00 26.68           C  \nATOM      4  O   ALA A   7      23.097 -32.903  46.524  1.00 30.02           O  \nATOM      5  CB  ALA A   7      23.581 -33.526  43.770  1.00 31.41           C  \n"
      assert_equal(expected, @res.to_s)
    end
    def test_inspect
      expected = "#<Bio::PDB::Residue resName=\"ALA\" id=\"7\" chain.id=nil resSeq=7 iCode=\"\" atoms.size=5>"
      assert_equal(expected,@res.inspect)
    end
    def test_sort #<=>
      expected = [Bio::PDB::Residue.new(resName="ALA",resSeq = 6, iCode = 2, chain = nil),
                  Bio::PDB::Residue.new(resName="ALA",resSeq = 7, iCode = 1, chain = nil),
                  Bio::PDB::Residue.new(resName="ALA",resSeq = 7,  iCode = 3, chain = nil)]
      ress = [Bio::PDB::Residue.new(resName="ALA",resSeq = 7, iCode = 1, chain = nil)]
      ress << Bio::PDB::Residue.new(resName="ALA",resSeq = 6, iCode = 2, chain = nil)
      ress << Bio::PDB::Residue.new(resName="ALA",resSeq = 7,  iCode = 3, chain = nil)
      actual = ress.sort do |a, b|
        a <=> b
      end
      assert_equal(expected,actual)
    end
    def test_update_resudue_id
      # resName="ALA", resSeq = nil, iCode = nil, chain = nil
      res = Bio::PDB::Residue.new("ALA", nil, nil, nil)
      assert_equal(nil, res.residue_id)
    end
  end
  
  class TestHeterogen < Test::Unit::TestCase
    def setup
      # resName="EDO",resSeq = 701, iCode = "", chain = nil
      @res = Bio::PDB::Heterogen.new("EDO", 701, "", nil)
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O"))
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C"))
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O"))
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C"))
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O"))

    end
    def test_get_residue_id_from_atom
      id = Bio::PDB::Residue.get_residue_id_from_atom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30582  C1  EDO A 701      -0.205 -27.262  49.961  1.00 34.45           C"))
      assert_equal("701",id)
    end

    def test_addAtom
     assert_nothing_raised {
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O"))
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C"))
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O"))
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C"))
      @res.addAtom(Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O")) 
     }
    end
    def test_square_bracket
     expected = {
:serial=>30586, 
:name=>"C1", 
:altLoc=>" ", 
:resName=>"EDO", 
:chainID=>"A", 
:resSeq=>702, 
:iCode=>"", 
:x=>2.792, 
:y=>7.449,
:z=>67.655, 
:occupancy=>1.0,
:tempFactor=>17.09, 
:segID=>"", 
:element=>"C",
:charge=>""
}
      actual = {}
      @res["C1"].each_pair do |m, v|
        actual[m] = v
      end
      assert_equal(expected, actual)
    end 
    
    def test_each_hetatm
expected = [{:z=>49.587, :resName=>"EDO", :altLoc=>" ", :resSeq=>701, :occupancy=>1.0, :iCode=>"", :tempFactor=>35.2, :chainID=>"A", :y=>-26.859, :segID=>"", :x=>-1.516, :name=>"O1", :charge=>"", :element=>"O", :serial=>30583}, {:z=>51.219, :resName=>"EDO", :altLoc=>" ", :resSeq=>701, :occupancy=>1.0, :iCode=>"", :tempFactor=>34.49, :chainID=>"A", :y=>-28.124, :segID=>"", :x=>-0.275, :name=>"C2", :charge=>"", :element=>"C", :serial=>30584}, {:z=>51.167, :resName=>"EDO", :altLoc=>" ", :resSeq=>701, :occupancy=>1.0, :iCode=>"", :tempFactor=>33.95, :chainID=>"A", :y=>-28.941, :segID=>"", :x=>-1.442, :name=>"O2", :charge=>"", :element=>"O", :serial=>30585}, {:z=>67.655, :resName=>"EDO", :altLoc=>" ", :resSeq=>702, :occupancy=>1.0, :iCode=>"", :tempFactor=>17.09, :chainID=>"A", :y=>7.449, :segID=>"", :x=>2.792, :name=>"C1", :charge=>"", :element=>"C", :serial=>30586}, {:z=>67.213, :resName=>"EDO", :altLoc=>" ", :resSeq=>702, :occupancy=>1.0, :iCode=>"", :tempFactor=>15.74, :chainID=>"A", :y=>7.273, :segID=>"", :x=>1.451, :name=>"O1", :charge=>"", :element=>"O", :serial=>30587}]
      actual = []
      @res.each_hetatm do |hetatm|
        actual << {:serial=>hetatm.serial, :name=>hetatm.name, :altLoc=>hetatm.altLoc, :resName=>hetatm.resName, :chainID=>hetatm.chainID, :resSeq=>hetatm.resSeq, :iCode=>hetatm.iCode, :x=>hetatm.x, :y=>hetatm.y, :z=>hetatm.z, :occupancy=>hetatm.occupancy, :tempFactor=>hetatm.tempFactor, :segID=>hetatm.segID, :element=>hetatm.element, :charge=>hetatm.charge}
      end
      assert_equal(expected, actual)
    end    
    def test_each
expected = [{:z=>49.587, :resName=>"EDO", :altLoc=>" ", :resSeq=>701, :occupancy=>1.0, :iCode=>"", :tempFactor=>35.2, :chainID=>"A", :y=>-26.859, :segID=>"", :x=>-1.516, :name=>"O1", :charge=>"", :element=>"O", :serial=>30583}, {:z=>51.219, :resName=>"EDO", :altLoc=>" ", :resSeq=>701, :occupancy=>1.0, :iCode=>"", :tempFactor=>34.49, :chainID=>"A", :y=>-28.124, :segID=>"", :x=>-0.275, :name=>"C2", :charge=>"", :element=>"C", :serial=>30584}, {:z=>51.167, :resName=>"EDO", :altLoc=>" ", :resSeq=>701, :occupancy=>1.0, :iCode=>"", :tempFactor=>33.95, :chainID=>"A", :y=>-28.941, :segID=>"", :x=>-1.442, :name=>"O2", :charge=>"", :element=>"O", :serial=>30585}, {:z=>67.655, :resName=>"EDO", :altLoc=>" ", :resSeq=>702, :occupancy=>1.0, :iCode=>"", :tempFactor=>17.09, :chainID=>"A", :y=>7.449, :segID=>"", :x=>2.792, :name=>"C1", :charge=>"", :element=>"C", :serial=>30586}, {:z=>67.213, :resName=>"EDO", :altLoc=>" ", :resSeq=>702, :occupancy=>1.0, :iCode=>"", :tempFactor=>15.74, :chainID=>"A", :y=>7.273, :segID=>"", :x=>1.451, :name=>"O1", :charge=>"", :element=>"O", :serial=>30587}]
      actual = []
      @res.each do |hetatm|
        actual << {:serial=>hetatm.serial, :name=>hetatm.name, :altLoc=>hetatm.altLoc, :resName=>hetatm.resName, :chainID=>hetatm.chainID, :resSeq=>hetatm.resSeq, :iCode=>hetatm.iCode, :x=>hetatm.x, :y=>hetatm.y, :z=>hetatm.z, :occupancy=>hetatm.occupancy, :tempFactor=>hetatm.tempFactor, :segID=>hetatm.segID, :element=>hetatm.element, :charge=>hetatm.charge}
      end
      assert_equal(expected, actual)
    end    

    def test_het_atom
      assert_equal(true, @res.hetatm)
    end
    def test_iCode
      assert_equal( 1, @res.iCode=1)
    end
    def test_resSeq
      assert_equal( 1, @res.resSeq=1)
    end
    def test_to_s
      expected = "HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O  \nHETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C  \nHETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O  \nHETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C  \nHETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O  \n"
      assert_equal(expected, @res.to_s)
    end
    def test_inspect
      expected = "#<Bio::PDB::Heterogen resName=\"EDO\" id=\"701\" chain.id=nil resSeq=701 iCode=\"\" atoms.size=5>"
      assert_equal(expected,@res.inspect)
    end
    def test_sort #<=>
      expected = [Bio::PDB::Heterogen.new(resName="EDD",resSeq = 1, iCode = 2, chain = nil),
                  Bio::PDB::Heterogen.new(resName="EDD",resSeq = 1, iCode = 3, chain = nil),
                  Bio::PDB::Heterogen.new(resName="EDD",resSeq = 2,  iCode = 1, chain = nil)]
      ress = [Bio::PDB::Heterogen.new(resName="EDD",resSeq = 1, iCode = 2, chain = nil)]
      ress << Bio::PDB::Heterogen.new(resName="EDD",resSeq = 1, iCode = 3, chain = nil)
      ress << Bio::PDB::Heterogen.new(resName="EDD",resSeq = 2,  iCode = 1, chain = nil)
      actual = ress.sort do |a, b|
        a <=> b
      end
      assert_equal(expected,actual)
    end
    def test_update_resudue_id
      # resName="EDD", resSeq = nil, iCode = nil, chain = nil
      res = Bio::PDB::Heterogen.new("EDD", nil, nil, nil)
      assert_equal(nil, res.residue_id)
    end
  end
  
  class TestChain < Test::Unit::TestCase
      def setup
        @chain = Bio::PDB::Chain.new('A',nil)
        @chain.addResidue(Bio::PDB::Residue.new(resName="ALA",resSeq = 7, iCode = 1, chain = @chain))
        @chain.addResidue(Bio::PDB::Residue.new(resName="ALA",resSeq = 6, iCode = 2, chain = @chain))
        @chain.addResidue(Bio::PDB::Residue.new(resName="ALA",resSeq = 7,  iCode = 3, chain = @chain))
        @chain.addLigand(Bio::PDB::Heterogen.new(resName="EDD",resSeq = 1, iCode = 2, chain = @chain)) 
      end

      def test_square_brace #[]
        expected = {:iCode=>1,
                    :chain_id=>'A',
                    :atoms_size=>0,
                    :resSeq=>7,
                    :id=>"71",
                    :resName=>"ALA"}
        residue = @chain["71"]
        actual = {:resName => residue.resName, :id => residue.id, :chain_id => residue.chain.id, :resSeq => residue.resSeq, :iCode => residue.iCode, :atoms_size => residue.atoms.size}
        assert_equal(expected, actual)
      end
      def test_comp #<=> 
        expected = [{:iCode=>2,
                     :chain_id=>'A',
                     :atoms_size=>0,
                     :resSeq=>6,
                     :id=>"62",
                     :resName=>"ALA"},
                    {:iCode=>1,
                     :chain_id=>'A',
                     :atoms_size=>0,
                     :resSeq=>7,
                     :id=>"71",
                     :resName=>"ALA"},
                    {:iCode=>3,
                     :chain_id=>'A',
                     :atoms_size=>0,
                     :resSeq=>7,
                     :id=>"73",
                     :resName=>"ALA"}]
        sorted = @chain.sort do |a, b|
          a<=>b
        end
        actual = []
        sorted.each do |residue|
          actual << {:resName => residue.resName, :id => residue.id, :chain_id => residue.chain.id, :resSeq => residue.resSeq, :iCode => residue.iCode, :atoms_size => residue.atoms.size}
        end
        assert_equal(expected, actual)
      end
      def test_addResidue
        # resName="ALA",resSeq = 9, iCode = 1, chain = @chain
        assert_nothing_raised{ @chain.addResidue(Bio::PDB::Residue.new("ALA", 9, 1, @chain))}
      end
      def test_aaseq
        assert_equal("AAA", @chain.aaseq)
      end
      def test_addLigand
         # resName="EDD",resSeq = 10, iCode = 2, chain = @chain
         assert_nothing_raised{ @chain.addLigand(Bio::PDB::Heterogen.new("EDD", 10, 2, @chain)) }
      end
      def test_atom_seq
        assert_equal("AAA", @chain.atom_seq)
      end
      def test_each
        expected = [{:atoms_size=>0, :resSeq=>7, :chain_id=>'A', :iCode=>1, :id=>"71", :resName=>"ALA"}, {:atoms_size=>0, :resSeq=>6, :chain_id=>'A', :iCode=>2, :id=>"62", :resName=>"ALA"}, {:atoms_size=>0, :resSeq=>7, :chain_id=>'A', :iCode=>3, :id=>"73", :resName=>"ALA"}]
        actual = []
        @chain.each do |residue|
           actual << {:resName => residue.resName, :id => residue.id, :chain_id => residue.chain.id, :resSeq => residue.resSeq, :iCode => residue.iCode, :atoms_size => residue.atoms.size}
        end
        assert_equal(expected, actual)
      end
      def test_each_residue
        expected = [{:atoms_size=>0, :resSeq=>7, :chain_id=>'A', :iCode=>1, :id=>"71", :resName=>"ALA"}, {:atoms_size=>0, :resSeq=>6, :chain_id=>'A', :iCode=>2, :id=>"62", :resName=>"ALA"}, {:atoms_size=>0, :resSeq=>7, :chain_id=>'A', :iCode=>3, :id=>"73", :resName=>"ALA"}]
        actual = []
        @chain.each do |residue|
           actual << {:resName => residue.resName, :id => residue.id, :chain_id => residue.chain.id, :resSeq => residue.resSeq, :iCode => residue.iCode, :atoms_size => residue.atoms.size}
        end
        assert_equal(expected, actual)
      end
      def test_each_heterogen
        expected = [{:iCode=>2,
                      :chain_id=>'A',
                      :resSeq=>1,
                      :id=>"12",
                      :atoms_size=>0,
                      :resName=>"EDD"}]
        actual = []
        @chain.each_heterogen do |heterogen|
           actual << {:resName => heterogen.resName, :id => heterogen.id, :chain_id => heterogen.chain.id, :resSeq => heterogen.resSeq, :iCode => heterogen.iCode, :atoms_size => heterogen.atoms.size}
        end
        assert_equal(expected, actual)
      end
      def test_get_heterogen_by_id
        heterogen = @chain.get_heterogen_by_id("12")
        expected = {:iCode=>2,
                      :chain_id=>'A',
                      :resSeq=>1,
                      :id=>"12",
                      :atoms_size=>0,
                      :resName=>"EDD"}
        actual = {:resName => heterogen.resName, :id => heterogen.id, :chain_id => heterogen.chain.id,     :resSeq => heterogen.resSeq, :iCode => heterogen.iCode, :atoms_size => heterogen.atoms.size}
        assert_equal(expected, actual)
      end
      def test_get_residue_by_id
        residue = @chain.get_residue_by_id("71")
        expected = {:atoms_size=>0, :resSeq=>7, :chain_id=>'A', :iCode=>1, :id=>"71", :resName=>"ALA"}
        actual = {:resName => residue.resName, :id => residue.id, :chain_id => residue.chain.id,     :resSeq => residue.resSeq, :iCode => residue.iCode, :atoms_size => residue.atoms.size}
        assert_equal(expected, actual)
      end
      def test_inspect
        expected = "#<Bio::PDB::Chain id=\"A\" model.serial=nil residues.size=3 heterogens.size=1 aaseq=\"AAA\">"
        assert_equal(expected, @chain.inspect)
      end
      def test_rehash
        assert_nothing_raised{@chain.rehash}
      end
      def test_rehash_heterogens
        assert_nothing_raised{@chain.rehash_heterogens}
        
        #assert_raise{@chain.rehash_heterogens}
      end
      def test_rehash_residues
        assert_nothing_raised{@chain.rehash_residues}
      end
      def test_to_s
        assert_equal("TER\n",@chain.to_s)
      end
  end

  class TestModel < Test::Unit::TestCase
      def setup
        @model = Bio::PDB::Model.new(1,nil)
        @model.addChain(Bio::PDB::Chain.new(1, @model))
        @model.addChain(Bio::PDB::Chain.new(2, @model))
        @model.addChain(Bio::PDB::Chain.new(3, @model))
      end

      def test_square_brace #[]
        expected = {:id=>1, :model_serial=>1, :residues_size=>0, :heterogens_size=>0, :aaseq=>""}
        residue = @model[1]
        actual = {:id=>residue.id, :model_serial=>residue.model.serial, :residues_size=>residue.residues.size, :heterogens_size=>residue.heterogens.size, :aaseq=>residue.aaseq}

        assert_equal(expected, actual)
      end
      def test_comp #<=> 
        models = [Bio::PDB::Model.new(2,nil), Bio::PDB::Model.new(1,nil), Bio::PDB::Model.new(3,nil)]
        expected = [{:serial=>1, :chains_size=>0},
 {:serial=>2, :chains_size=>0},
 {:serial=>3, :chains_size=>0}]

        sorted = models.sort do |a, b|
          a<=>b
        end
        actual = []
        sorted.each do |model|
          actual << {:serial => model.serial, :chains_size => model.chains.size }
        end
        assert_equal(expected, actual)
      end
      def test_addChain
        assert_nothing_raised{ @model.addChain(Bio::PDB::Chain.new("D", @model))}
      end
      def test_each
        expected = [{:model_serial=>1,
                     :aaseq=>"",
                     :residues_size=>0,
                     :heterogens_size=>0,
                     :id=>1},
                    {:model_serial=>1,
                     :aaseq=>"",
                     :residues_size=>0,
                     :heterogens_size=>0,
                     :id=>2},
                    {:model_serial=>1,
                     :aaseq=>"",
                     :residues_size=>0,
                     :heterogens_size=>0,
                     :id=>3}]
        actual = []
        @model.each do |m|
           actual << {:id => m.id, :model_serial => m.model.serial, :residues_size => m.residues.size, :heterogens_size => m.heterogens.size, :aaseq => m.aaseq }
        end
        assert_equal(expected, actual)
      end

      def test_each_chain
        expected = [{:model_serial=>1,
                     :aaseq=>"",
                     :residues_size=>0,
                     :heterogens_size=>0,
                     :id=>1},
                    {:model_serial=>1,
                     :aaseq=>"",
                     :residues_size=>0,
                     :heterogens_size=>0,
                     :id=>2},
                    {:model_serial=>1,
                     :aaseq=>"",
                     :residues_size=>0,
                     :heterogens_size=>0,
                     :id=>3}]
        actual = []
        @model.each_chain do |m|
           actual << {:id => m.id, :model_serial => m.model.serial, :residues_size => m.residues.size, :heterogens_size => m.heterogens.size, :aaseq => m.aaseq }
        end
        assert_equal(expected, actual)
      end
      def test_inspect
        expected = "#<Bio::PDB::Model serial=1 chains.size=3>"
        assert_equal(expected, @model.inspect)
      end
      def test_rehash
        assert_nothing_raised{@model.rehash}
      end
      def test_to_s
        assert_equal("MODEL     1\nTER\nTER\nTER\nENDMDL\n",@model.to_s)
      end
  end

  #this class tests Bio::PDB::Utils with Bio::PDB::Residue class witch is generated directly
  class TestUtils < Test::Unit::TestCase
    def setup
      # resName="ALA",resSeq = 7, iCode = "", chain = nil
      @res = Bio::PDB::Residue.new("ALA", 7, "", nil)
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      1  N   ALA A   7      23.484 -35.866  44.510  1.00 28.52           N"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      3  C   ALA A   7      23.102 -34.082  46.159  1.00 26.68           C"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      4  O   ALA A   7      23.097 -32.903  46.524  1.00 30.02           O"))
      @res.addAtom(Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      5  CB  ALA A   7      23.581 -33.526  43.770  1.00 31.41           C"))
    end

    def test_geometricCentre
      assert_instance_of(Bio::PDB::Coordinate,@res.geometricCentre())
#      assert_equal(Vector[23.4226, -34.1772, 45.1734], @res.geometricCentre())
      expected = [ 23.4226, -34.1772, 45.1734 ]
      @res.geometricCentre().to_a.each do |num|
        assert_in_delta(expected.shift, num, 0.001)
      end
      assert(expected.empty?)
    end

    def test_centreOfGravity
      assert_instance_of(Bio::PDB::Coordinate,@res.centreOfGravity())
      expected = [ 23.4047272727273, -34.1511515151515, 45.2351515151515 ]
      @res.centreOfGravity().to_a.each do |num|
        assert_in_delta(expected.shift, num, 0.001)
      end
      assert(expected.empty?)
    end
    
    def test_distance
      actual1 = Bio::PDB::Utils.distance(
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      7  CA  VAL A   8      21.887 -34.822  48.124  1.00 23.78           C")
      )

      actual2 = Bio::PDB::Utils.distance([23.849, -34.509,  44.904], [21.887, -34.822,  48.124])
      assert_in_delta(3.78362432067456, actual1, 0.001)
      assert_in_delta(3.78362432067456, actual2, 0.001)
    end
    def test_dihedral_angle
      actual1 = Bio::PDB::Utils.dihedral_angle(
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      7  CA  VAL A   8      21.887 -34.822  48.124  1.00 23.78           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM     14  CA  PRO A   9      24.180 -35.345  51.107  1.00 22.35           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM     21  CA  ALA A  10      23.833 -38.844  52.579  1.00 23.41           C")
      )


      actual2 = Bio::PDB::Utils.dihedral_angle(
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849  34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      7  CA  VAL A   8      21.887  34.822  48.124  1.00 23.78           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM     14  CA  PRO A   9      24.180  35.345  51.107  1.00 22.35           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM     21  CA  ALA A  10      23.833  38.844  52.579  1.00 23.41           C")
      )
      assert_in_delta(-1.94387328933899, actual1, 0.001)
      assert_in_delta( 1.94387328933899, actual2, 0.001)

    end
    def test_rad2deg
      deg = Bio::PDB::Utils::rad2deg(3.14159265358979)
      assert_in_delta(180.0, deg, 0.0000000001)
    end

  end #class Test_Utils

  #The following classes is unit tests for Test_*Finder
  #The sample data are arrays generated from corresponding Bio::PDB::* classes, witch has  Bio::PDB::Utils::*Finder

  class TestModelFinder < Test::Unit::TestCase
    def setup
      @models = [Bio::PDB::Model.new(1), Bio::PDB::Model.new(2), Bio::PDB::Model.new(3)]
      def @models.each_model
        self.each do |model|
          yield model
        end
      end
      @models.extend(Bio::PDB::ModelFinder)
    end

    def test_find_model
      expected = [Bio::PDB::Model.new(1), Bio::PDB::Model.new(2), Bio::PDB::Model.new(3)]
      actual = @models.find_model{|m| true}
      assert_equal(expected,actual)
    end

  end

  class TestChainFinder < Test::Unit::TestCase
    def setup
      @model = [Bio::PDB::Chain.new(1), Bio::PDB::Chain.new(2), Bio::PDB::Chain.new(3)]
    end

    def test_find_chain
      def @model.each_chain
        self.each do |chain|
          yield chain
        end
      end
      @model.extend(Bio::PDB::ChainFinder)
      expected = [Bio::PDB::Chain.new(1), Bio::PDB::Chain.new(2), Bio::PDB::Chain.new(3)]
      actual = @model.find_chain{|m| true}
      assert_equal(expected,actual)
    end
    def test_each_chain
      expected = [Bio::PDB::Chain.new(1), Bio::PDB::Chain.new(2), Bio::PDB::Chain.new(3), Bio::PDB::Chain.new(1), Bio::PDB::Chain.new(2), Bio::PDB::Chain.new(3)]
      models = [@model,@model]
      def models.each_model
        self.each do |model|
          yield model
        end
      end
      models.extend(Bio::PDB::ChainFinder)
      actual = []
      models.each_chain{|chain| actual << chain}
      assert_equal(expected, actual)
    end

    def test_chains
      expected = [Bio::PDB::Chain.new(1), Bio::PDB::Chain.new(2), Bio::PDB::Chain.new(3), Bio::PDB::Chain.new(1), Bio::PDB::Chain.new(2), Bio::PDB::Chain.new(3)]
      @model.instance_eval{
        def chains
          return self
        end
      }
      models = [@model,@model]
      def models.each_model
          self.each do |model|
            yield model
          end
      end
      models.extend(Bio::PDB::ChainFinder)
      models.extend(Bio::PDB::ModelFinder)
      actual = models.chains
      assert_equal(expected,actual)
    end
  end #TestChainFinder

  class TestResidueFinder < Test::Unit::TestCase
    def setup
      @residues = [Bio::PDB::Residue.new("",1), Bio::PDB::Residue.new("",2), Bio::PDB::Residue.new("",3)]
    end

    def test_find_residue
      def @residues.each_residue
        self.each do |residue|
          yield residue
        end
      end
      @residues.extend(Bio::PDB::ResidueFinder)
#      expected = [Bio::PDB::Residue.new("",1), Bio::PDB::Residue.new("",2), Bio::PDB::Residue.new("",3)]
      expected = [
        {:resName=>"", :id=>"1", :chain=>nil, :resSeq=>1, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"2", :chain=>nil, :resSeq=>2, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"3", :chain=>nil, :resSeq=>3, :iCode=>nil, :atoms_size=>0},
      ]
      finded = @residues.find_residue{|m| true}
      actual = []
      finded.each do |res|
         actual << {:resName=> res.resName, :id=> res.id, :chain=> res.chain, :resSeq=> res.resSeq, :iCode=> res.iCode, :atoms_size=> res.atoms.size}    
      end
      assert_equal(expected,actual)
    end

    def test_each_residue
#      expected = [Bio::PDB::Residue.new("", 1), Bio::PDB::Residue.new("",2), Bio::PDB::Residue.new("",3), Bio::PDB::Residue.new("",1), Bio::PDB::Residue.new("",2), Bio::PDB::Residue.new("",3)]
      expected = [
        {:resName=>"", :id=>"1", :chain=>nil, :resSeq=>1, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"2", :chain=>nil, :resSeq=>2, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"3", :chain=>nil, :resSeq=>3, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"1", :chain=>nil, :resSeq=>1, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"2", :chain=>nil, :resSeq=>2, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"3", :chain=>nil, :resSeq=>3, :iCode=>nil, :atoms_size=>0}
      ]
      chains = [@residues,@residues]
      def chains.each_chain
        self.each do |chain|
          yield chain
        end
      end
      chains.extend(Bio::PDB::ResidueFinder)
      actual = []
      chains.each_residue do |res|
         actual << {:resName=> res.resName, :id=> res.id, :chain=> res.chain, :resSeq=> res.resSeq, :iCode=> res.iCode, :atoms_size=> res.atoms.size}
      end
      assert_equal(expected, actual)
    end

    def test_residues
#      expected = [Bio::PDB::Residue.new("", 1), Bio::PDB::Residue.new("",2), Bio::PDB::Residue.new("",3), Bio::PDB::Residue.new("",1), Bio::PDB::Residue.new("",2), Bio::PDB::Residue.new("",3)]
      expected = [ 
        {:resName=>"", :id=>"1", :chain=>nil, :resSeq=>1, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"2", :chain=>nil, :resSeq=>2, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"3", :chain=>nil, :resSeq=>3, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"1", :chain=>nil, :resSeq=>1, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"2", :chain=>nil, :resSeq=>2, :iCode=>nil, :atoms_size=>0},
        {:resName=>"", :id=>"3", :chain=>nil, :resSeq=>3, :iCode=>nil, :atoms_size=>0}]
      @residues.instance_eval{
        def residues
          return self
        end
     }
      chains = [@residues,@residues]
      def chains.each_chain
        self.each do |chain|
          yield chain
        end
      end
      chains.extend(Bio::PDB::ResidueFinder)
      chains.extend(Bio::PDB::ChainFinder)
      actual = []
      chains.residues.each do |res|
        actual << {:resName=> res.resName, :id=> res.id, :chain=> res.chain, :resSeq=> res.resSeq, :iCode=> res.iCode, :atoms_size=> res.atoms.size}
      end
      assert_equal(expected,actual)
    end
  end #TestResidueFinder

  class TestAtomFinder < Test::Unit::TestCase
    def setup
      @atoms = [Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
                Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
                Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C")]
    end

    def test_find_atom
      expected = 
        [Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
         Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
         Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C")]
      def @atoms.each_atom
        self.each do |atom|
          yield atom
        end
      end
      @atoms.extend(Bio::PDB::AtomFinder)
      actual = @atoms.find_atom{|a| true}
      assert_equal(expected,actual)
    end

    def test_each_atom
      expected = [
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C")
      ]
      residues = [@atoms,@atoms]
      def residues.each_residue
        self.each do |residue|
          yield residue
        end
      end
      residues.extend(Bio::PDB::AtomFinder)
      actual = []
      residues.each_atom{|atom| actual << atom}
      assert_equal(expected, actual)
    end

    def test_atoms
      expected = [
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C"),
        Bio::PDB::Record::ATOM.new.initialize_from_string("ATOM      2  CA  ALA A   7      23.849 -34.509  44.904  1.00 27.89           C")
      ]
      @atoms.instance_eval{
        def atoms
          return self
        end
     }
      residues = [@atoms,@atoms]
      def residues.each_residue
        self.each do |atom|
          yield atom
        end
      end
      residues.extend(Bio::PDB::AtomFinder)
      residues.extend(Bio::PDB::ResidueFinder)
      actual = residues.atoms
      assert_equal(expected,actual)
    end
  end #AtomFinder

  class TestHetatmFinder < Test::Unit::TestCase
    def setup
      @hetatms =
        [Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O"),
         Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C"),
         Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O"),
         Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C"),
         Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O")
        ]
    end

    def test_find_hetatm
      expected =
        [Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O"),
         Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C"),
         Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O"),
         Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C"),
         Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O")
        ]
      def @hetatms.each_hetatm
        self.each do |hetatm|
          yield hetatm
        end
      end
      @hetatms.extend(Bio::PDB::HetatmFinder)
      actual = @hetatms.find_hetatm{|a| true}

      assert_equal(expected,actual)
    end

    def test_each_hetatm
      expected = [
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O")

      ]
      heterogens = [@hetatms,@hetatms]
      def heterogens.each_heterogen
        self.each do |heterogen|
          yield heterogen
        end
      end
      heterogens.extend(Bio::PDB::HetatmFinder)
      actual = []
      heterogens.each_hetatm{|hetatm| actual << hetatm}

      assert_equal(expected, actual)
    end

    def test_hetatms
      expected = [
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30583  O1  EDO A 701      -1.516 -26.859  49.587  1.00 35.20           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30584  C2  EDO A 701      -0.275 -28.124  51.219  1.00 34.49           C"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30585  O2  EDO A 701      -1.442 -28.941  51.167  1.00 33.95           O"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30586  C1  EDO A 702       2.792   7.449  67.655  1.00 17.09           C"),
        Bio::PDB::Record::HETATM.new.initialize_from_string("HETATM30587  O1  EDO A 702       1.451   7.273  67.213  1.00 15.74           O")
      ]
      @hetatms.instance_eval{
        def hetatms
          return self
        end
     }
      heterogens = [@hetatms,@hetatms]
      def heterogens.each_heterogen
        self.each do |heterogen|
          yield heterogen
        end
      end
      heterogens.extend(Bio::PDB::HetatmFinder)
      heterogens.extend(Bio::PDB::HeterogenFinder)
      actual = heterogens.hetatms
      assert_equal(expected,actual)
    end
  end #HetatmFinder

  class TestHeterogenFinder < Test::Unit::TestCase
    def setup
      @heterogens =
        [Bio::PDB::Heterogen.new(),
         Bio::PDB::Heterogen.new(),
         Bio::PDB::Heterogen.new(),
         Bio::PDB::Heterogen.new()
        ]
    end

    def test_find_heterogen
      def @heterogens.each_heterogen
        self.each do |heterogen|
          yield heterogen
        end
      end
      @heterogens.extend(Bio::PDB::HeterogenFinder)
      expected = [
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
      ]
      hets = @heterogens.find_heterogen{|a| true}
      actual = []
      hets.each do |het|
        actual << {:resName=> het.resName, :id=> het.id, :chain=> het.chain, :resSeq=> het.resSeq, :iCode=> het.iCode, :atoms_size=> het.atoms.size}
      end
      assert_equal(expected,actual)
    end

    def test_each_heterogen
#      expected = [
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new()
#      ]
      expected = [
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0}
      ]
      def @heterogens.each_heterogen
        self.each do |heterogen|
          yield heterogen
        end
      end
      chains = [@heterogens,@heterogens]
      def chains.each_chain
        self.each do |chain|
          yield chain
        end
      end
      chains.extend(Bio::PDB::HeterogenFinder)
      actual = []
      chains.each_heterogen do |het|
        actual << {:resName=> het.resName, :id=> het.id, :chain=> het.chain, :resSeq=> het.resSeq, :iCode=> het.iCode, :atoms_size=> het.atoms.size}
      end
      assert_equal(expected, actual)
    end

    def test_heterogens
#      expected = [
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new(),
#        Bio::PDB::Heterogen.new()
#      ]
      expected = [
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0},
        {:resName=>nil, :id=>nil, :chain=>nil, :resSeq=>nil, :iCode=>nil, :atoms_size=>0}
      ]
      @heterogens.instance_eval{
        def heterogens
          return self
        end
     }
      chains = [@heterogens,@heterogens]
      def chains.each_chain
        self.each do |chain|
          yield chain
        end
      end
      chains.extend(Bio::PDB::HeterogenFinder)
      chains.extend(Bio::PDB::ChainFinder)
      hets = chains.heterogens
        actual = []
        hets.each do |het|
           actual << {:resName=> het.resName, :id=> het.id, :chain=> het.chain, :resSeq=> het.resSeq, :iCode=> het.iCode, :atoms_size=> het.atoms.size}
        end

      assert_equal(expected,actual)
    end
  end #HetatmFinder
end #module Bio
