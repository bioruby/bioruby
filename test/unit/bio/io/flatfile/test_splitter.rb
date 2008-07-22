#
# = test/unit/bio/io/flatfile/test_splitter.rb - unit test for Bio::FlatFile::Splitter
#
#   Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id:$
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'stringio'

require 'bio'
require 'bio/io/flatfile/splitter'
require 'bio/io/flatfile/buffer'

module Bio::TestFlatFileSplitter

  class TestDataClass
    # Fake fasta format
    DELIMITER = RS = "\n>"
    DELIMITER_OVERRUN = 1 # '>'.length
    FLATFILE_HEADER = '>'
    def initialize(str)
      @str = str
    end
  end

  TestData01 = <<__END_OF_TESTDATA__

        # This is test

>test1
aaagggtttcccaaagggtttccc
>testC
cccccccccccccccccccccccc
>testG
gggggggggggggggggggggggg
>test2
tttttttttttttttttttttttt
tttttttttttttttttttttttt

>test3
atatatatatatatatatatatat
__END_OF_TESTDATA__
  TestData01.chomp!

  class TestDefault < Test::Unit::TestCase
    def setup
      @stream = Bio::FlatFile::BufferedInputStream.new(StringIO.new(TestData01), 'TestData01')
      @obj = Bio::FlatFile::Splitter::Default.new(TestDataClass, @stream)
    end

    def test_delimiter
      assert_equal("\n>", @obj.delimiter)
    end

    def test_header
      assert_equal('>', @obj.header)
    end

    def test_delimiter_overrun
      assert_equal(1, @obj.delimiter_overrun)
    end

    def test_skip_leader
      assert_nothing_raised { @obj.skip_leader }
      assert(@stream.pos > 0)
      assert_equal('>test1', @stream.gets.chomp)
    end

    def test_skip_leader_without_header
      @obj.header = nil
      assert_nothing_raised { @obj.skip_leader }
      assert(@stream.pos > 0)
      assert_equal('# This is test', @stream.gets.chomp)
    end

    def test_get_entry
      str0 = "\n        # This is test\n\n"
      str1 = ">test1\naaagggtttcccaaagggtttccc\n"
      str2 = ">testC\ncccccccccccccccccccccccc\n"
      str3 = ">testG\ngggggggggggggggggggggggg\n"
      str4 = ">test2\ntttttttttttttttttttttttt\ntttttttttttttttttttttttt\n\n"
      str5 = ">test3\natatatatatatatatatatatat"
      assert_equal(str0, @obj.get_entry)
      assert_equal(str1, @obj.get_entry)
      assert_equal(str2, @obj.get_entry)
      assert_equal(str3, @obj.get_entry)
      assert_equal(str4, @obj.get_entry)
      assert_equal(str5, @obj.get_entry)
      assert(@stream.eof?)
    end

  end

end
