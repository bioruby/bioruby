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
