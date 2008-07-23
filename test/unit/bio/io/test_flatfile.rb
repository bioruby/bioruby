#
# = test/unit/bio/io/test_flatfile.rb - unit test for Bio::FlatFile
#
#   Copyright (C) 2006 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id: test_flatfile.rb,v 1.2 2007/04/05 23:35:43 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio'
require 'stringio'


module Bio
    
module TestFlatFile

  bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s
  TestDataPath = Pathname.new(File.join(bioruby_root, 'test', 'data')).cleanpath.to_s
  TestData01 = File.join(TestDataPath, 'fasta', 'example1.txt')

  TestData01Ent1def =
    "At1g02580 mRNA (2291 bp) UTR's and CDS"
  TestData01Ent4def =
    'At1g65300: mRNA 837bp (shortened from start)'
  TestData01Ent4naseq = Bio::Sequence::NA.new <<__END_OF_SEQ__
ttcatctttacctcttcctattgttgcgaatgcagctgcaccagtcg
gatttgatggtcctatgtttcaatatcataatcaaaatcagcaaaagccggttcaattccaatatcaggctcttta
tgatttttatgatcagattccaaagaaaattcatggttttaatatgaatatgaataaggattcgaatcaaagtatg
gttttggatttgaatcaaaatcttaatgatggagaggacgagggcattccttgcatggacaacaacaactaccacc
ccgaaatcgattgtctcgctaccgtcaccactgcccccactgatgtttgtgctcctaacatcaccaatgatctcta
g
__END_OF_SEQ__

  # test Bio::FlatFile class method
  class TestFlatFileClassMethod < Test::Unit::TestCase

    def setup
      @filename = TestData01
      @klass = Bio::FastaFormat
    end

    # test template for Bio::FlatFile.open
    def open_TestData01(*arg)
      assert_instance_of(Bio::FlatFile,
                         ff = Bio::FlatFile.open(*arg))
      assert_equal(@klass, ff.dbclass)
      assert_nil(ff.close)
    end
    private :open_TestData01

    # test template for Bio::FlatFile.open with block
    def open_with_block_TestData01(*arg)
      ret = Bio::FlatFile.open(*arg) do |ff|
        assert_instance_of(Bio::FlatFile, ff)
        assert_equal(@klass, ff.dbclass)
        ff.each do |e|
          assert_instance_of(@klass, e)
          assert_instance_of(String, ff.entry_raw)
        end
        'test return value'
      end
      assert_equal('test return value', ret)
    end
    private :open_with_block_TestData01

    def test_open_0arg
      assert_raise(ArgumentError) { Bio::FlatFile.open }
    end

    def test_open_1arg_nil
      assert_raise(ArgumentError) { Bio::FlatFile.open(nil) }
    end

    def test_open_1arg_class
      assert_raise(ArgumentError) { Bio::FlatFile.open(Bio::GenBank) }
    end

    def test_open_1arg_filename
      open_TestData01(@filename)
    end

    def test_open_1arg_io
      io = File.open(@filename)
      open_TestData01(io)
      assert(io.closed?)
    end

    def test_open_1arg_with_block
      open_with_block_TestData01(@filename)
    end

    def test_open_1arg_io_with_block
      io = File.open(@filename)
      open_with_block_TestData01(io)
      # When IO object is given, the IO is NOT automatically closed.
      assert_equal(false, io.closed?)
      assert_nothing_raised { io.close }
    end

    def test_open_2arg_autodetect
      open_TestData01(nil, @filename)
    end

    def test_open_2arg_autodetect_with_block
      open_with_block_TestData01(nil, @filename)
    end

    def test_open_2arg_autodetect_io
      io = File.open(@filename)
      open_TestData01(nil, io)
      assert(io.closed?)
    end

    def test_open_2arg_autodetect_io_with_block
      io = File.open(@filename)
      open_with_block_TestData01(nil, io)
      # When IO object is given, the IO is NOT automatically closed.
      assert_equal(false, io.closed?)
      assert_nothing_raised { io.close }
    end

    def test_open_2arg_class
      open_TestData01(@klass, @filename)
    end

    def test_open_2arg_class_with_block
      open_with_block_TestData01(@klass, @filename)
    end

    def test_open_2arg_class_io
      io = File.open(@filename)
      open_TestData01(@klass, io)
      assert(io.closed?)
    end

    def test_open_2arg_class_io_with_block
      io = File.open(@filename)
      open_with_block_TestData01(@klass, io)
      # When IO object is given, the IO is NOT automatically closed.
      assert_equal(false, io.closed?)
      assert_nothing_raised { io.close }
    end

    def test_open_2arg_filename_mode
      open_TestData01(@filename, 'r')
    end

    def test_open_2arg_filename_mode_with_block
      open_with_block_TestData01(@filename, 'r')
    end

    def test_open_3arg
      open_TestData01(nil, @filename, 'r')
      open_TestData01(@klass, @filename, 'r')
      open_TestData01(@filename, File::RDONLY, 0)
    end

    def test_open_3arg_with_block
      open_with_block_TestData01(nil, @filename, 'r')
      open_with_block_TestData01(@klass, @filename, 'r')
      open_with_block_TestData01(@filename, File::RDONLY, 0)
    end

    def test_open_4arg
      open_TestData01(nil, @filename, File::RDONLY, 0)
      open_TestData01(Bio::FastaFormat,
                                 @filename, File::RDONLY, 0)

      open_with_block_TestData01(nil, @filename, File::RDONLY, 0)
      open_with_block_TestData01(Bio::FastaFormat,
                                            @filename, File::RDONLY, 0)
    end

    # test template for Bio::FlatFile.auto
    def auto_TestData01(*arg)
      assert_instance_of(Bio::FlatFile,
                         ff = Bio::FlatFile.auto(*arg))
      assert_equal(@klass, ff.dbclass)
      assert_nil(ff.close)
    end
    private :auto_TestData01

    # test template for Bio::FlatFile.auto with block
    def auto_with_block_TestData01(*arg)
      ret = Bio::FlatFile.auto(*arg) do |ff|
        assert_instance_of(Bio::FlatFile, ff)
        assert_equal(@klass, ff.dbclass)
        ff.each do |e|
          assert_instance_of(@klass, e)
          assert_instance_of(String, ff.entry_raw)
        end
        'test return value'
      end
      assert_equal('test return value', ret)
    end
    private :auto_with_block_TestData01

    def test_auto_0arg
      assert_raise(ArgumentError) { Bio::FlatFile.auto }
    end

    def test_auto_1arg_filename
      auto_TestData01(@filename)
    end

    def test_auto_1arg_io
      io = File.open(@filename)
      auto_TestData01(io)
      assert(io.closed?)
    end

    def test_auto_1arg_with_block
      auto_with_block_TestData01(@filename)
    end

    def test_auto_1arg_io_with_block
      io = File.open(@filename)
      auto_with_block_TestData01(io)
      # When IO object is given, the IO is NOT automatically closed.
      assert_equal(false, io.closed?)
      assert_nothing_raised { io.close }
    end

    def test_auto_2arg_filename_mode
      auto_TestData01(@filename, 'r')
    end

    def test_auto_2arg_filename_mode_with_block
      auto_with_block_TestData01(@filename, 'r')
    end

    def test_auto_3arg
      auto_TestData01(@filename, File::RDONLY, 0)
    end

    def test_auto_3arg_with_block
      auto_with_block_TestData01(@filename, File::RDONLY, 0)
    end

    def test_to_a
      assert_instance_of(Array,
                         a = Bio::FlatFile.to_a(@filename))
      assert_equal(5, a.size)
      assert_instance_of(Bio::FastaFormat, a[3])
      assert_equal(TestData01Ent4def,
                   a[3].definition)

      assert_equal(TestData01Ent4naseq, a[3].naseq)
    end

    def test_foreach
      Bio::FlatFile.foreach(@filename) do |ent|
        assert_instance_of(Bio::FastaFormat, ent)
      end
    end

    def test_new_2arg_nil
      io = File.open(@filename)
      assert_instance_of(Bio::FlatFile,
                         ff = Bio::FlatFile.new(nil, io))
      assert_equal(@klass, ff.dbclass)
      assert_nil(ff.close)
    end

    def test_new_2arg_class
      io = File.open(@filename)
      assert_instance_of(Bio::FlatFile,
                         ff = Bio::FlatFile.new(@klass, io))
      assert_equal(@klass, ff.dbclass)
      assert_nil(ff.close)
    end

  end #class TestFlatFileClassMethod

  # test Bio::FlatFile instance methods
  class TestFlatFileFastaFormat < Test::Unit::TestCase
    def setup
      @klass = Bio::FastaFormat
      @filename = TestData01
      @ff = Bio::FlatFile.open(@klass, @filename)
    end

    def test_to_io
      assert_instance_of(File, @ff.to_io)
    end

    def test_path
      assert_equal(@filename, @ff.path)
    end

    def test_next_entry
      assert_instance_of(@klass, ent = @ff.next_entry)
      assert_equal(TestData01Ent1def, ent.definition)
      assert_instance_of(@klass, ent = @ff.next_entry)
      assert_instance_of(@klass, ent = @ff.next_entry)
      assert_instance_of(@klass, ent = @ff.next_entry)
      assert_equal(TestData01Ent4def, ent.definition)
      assert_equal(TestData01Ent4naseq, ent.naseq)
    end

    def test_entry_raw
      4.times { @ff.next_entry }
      assert_instance_of(String, str = @ff.entry_raw)
      assert_equal(TestData01Ent4def, @klass.new(str).definition)
      assert_equal(TestData01Ent4naseq, @klass.new(str).naseq)
    end

    def test_entry_pos_flag
      # default is nil
      assert_equal(nil, @ff.entry_pos_flag)
      # set as true
      assert_equal(true, @ff.entry_pos_flag = true)
      assert_equal(true, @ff.entry_pos_flag)
    end

    def test_start_pos_ended_pos_not_recorded
      # default is nil
      assert_equal(nil, @ff.entry_start_pos)
      #
      @ff.entry_pos_flag = false
      @ff.next_entry
      # nil if not recorded
      assert_equal(nil, @ff.entry_start_pos)
      assert_equal(nil, @ff.entry_ended_pos)
      @ff.next_entry
      # nil if not recorded
      assert_equal(nil, @ff.entry_start_pos)
      assert_equal(nil, @ff.entry_ended_pos)
    end

    def test_start_pos
      @ff.entry_pos_flag = true
      @ff.next_entry
      assert_equal(0, @ff.entry_start_pos)
      @ff.next_entry
      # On Windows, the values might be different.
      assert_equal(2367, @ff.entry_start_pos)
    end

    def test_ended_pos
      @ff.entry_pos_flag = true
      @ff.next_entry
      # On Windows, the values might be different.
      assert_equal(2367, @ff.entry_ended_pos)
      @ff.next_entry
      # On Windows, the values might be different.
      assert_equal(3244, @ff.entry_ended_pos)
    end

    def test_each_entry
      i = 0
      @ff.each_entry do |ent|
        assert_instance_of(@klass, ent)
        i += 1
        if i == 4 then
          assert_equal(TestData01Ent4def, ent.definition)
          assert_equal(TestData01Ent4naseq, ent.naseq)
        end
      end
    end

    # each is an alias of each_entry
    def test_each
      assert_nothing_raised { @ff.each {} }
    end

    def test_rewind
      @ff.next_entry
      assert_not_equal(0, @ff.pos)
      assert_equal(0, @ff.rewind)
      assert_equal(0, @ff.pos)
    end

    def test_close
      assert_nil(@ff.close)
    end

    def test_pos
      assert_equal(0, @ff.pos)
      @ff.next_entry
      assert_not_equal(0, @ff.pos)
    end

    def test_eof?
      5.times { @ff.next_entry }
      assert_equal(true, @ff.eof?)
    end

    def test_raw
      # default false
      assert_equal(false, @ff.raw)
      # changes to true
      assert_equal(true, @ff.raw = true)
      @ff.each do |ent|
        assert_instance_of(String, ent)
      end
    end

    def test_dbclass
      assert_equal(@klass, @ff.dbclass)
    end

    def test_dbclass_eq
      klass = Bio::FastaNumericFormat
      assert_equal(klass, @ff.dbclass = klass)
      assert_equal(klass, @ff.dbclass)
    end

    def test_dbclass_nil
      assert_equal(nil, @ff.dbclass = nil)
      assert_equal(nil, @ff.dbclass)
      assert_raise(Bio::FlatFile::UnknownDataFormatError) { @ff.next_entry }
    end

    def test_autodetect
      @ff.dbclass = nil
      assert_equal(@klass, @ff.autodetect)
      assert_equal(@klass, @ff.dbclass)
    end

  end #class TestFlatFileFastaFormat


  class TestFlatFileWithCustomClass < Test::Unit::TestCase

    # very simple parser for tab-separated data
    class SimpleFormat
      # delimiter needed for flatfile
      DELIMITER = RS = nil # nil means no delimiter and reading entire file
      def initialize(str)
        @data = str.split(/\n/).collect { |x| x.to_s.split(/\t/) }
      end
      attr_reader :data
    end

    def test_simpleformat
      testdata = "AAA\tBBB\tCCCCC\tDDDD\n123\t456\n"
      testio = StringIO.new(testdata)
      Bio::FlatFile.open(SimpleFormat, testio) do |ff|
        ff.each do |entry|
          assert_equal([ [ 'AAA', 'BBB', 'CCCCC', 'DDDD' ],
                         [ '123', '456' ] ], entry.data)
        end
      end
    end

    # very simple parser for "//"-separated entries
    class SimpleFormat2
      # delimiter needed for flatfile
      DELIMITER = RS = "//\n" # the end of each entry is "//\n"
      def initialize(str)
        # very simple parser only to store a text data
        @data = str
      end
      attr_reader :data
    end

    def test_simpleformat2
      testdata = <<__END_OF_TESTDATA__
test01
This is a test.
//
test02
This is an example.
//
__END_OF_TESTDATA__
      a = testdata.split(/(\/\/\n)/)
      results = [ a[0]+a[1], a[2]+a[3] ]
      testio = StringIO.new(testdata)
      Bio::FlatFile.open(SimpleFormat2, testio) do |ff|
        ff.each do |entry|
          assert_equal(results.shift, entry.data)
        end
      end
    end

  end #class TestFlatFileWithCustomClass

end #module TestFlatFile

end #module Bio
