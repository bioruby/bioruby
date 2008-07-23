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
    attr_reader :str
    protected :str

    def ==(other)
      self.str == other.str
    end
  end #class TestDataClass

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
  # workaround for Windows
  TestData01.gsub!(/\r\n/, "\n")

  class TestTemplate < Test::Unit::TestCase
    def setup
      @stream = Bio::FlatFile::BufferedInputStream.new(StringIO.new(TestData01), 'TestData01')
      @obj = Bio::FlatFile::Splitter::Template.new(TestDataClass, @stream)
    end

    def test_skip_leader
      assert_raise(NotImplementedError) { @obj.skip_leader }
    end

    def test_get_entry
      assert_raise(NotImplementedError) { @obj.get_entry }
    end

    def test_entry
      assert_nothing_raised {
        @obj.instance_eval { self.entry = 'test' } }
      assert_equal('test', @obj.entry)
    end

    def test_entry_pos_flag
      # default is nil or false
      assert(!@obj.entry_pos_flag)

      # set a value
      assert_equal(true, @obj.entry_pos_flag = true)
      assert_equal(true, @obj.entry_pos_flag)
    end

    def test_entry_start_pos
      assert_nothing_raised {
        @obj.instance_eval { self.entry_start_pos = 123 } }
      assert_equal(123, @obj.entry_start_pos)
    end

    def test_entry_ended_pos
      assert_nothing_raised {
        @obj.instance_eval { self.entry_ended_pos = 456 } }
      assert_equal(456, @obj.entry_ended_pos)
    end

    def test_stream
      assert_equal(@stream, @obj.instance_eval { stream })
    end

    def test_dbclass
      assert_equal(TestDataClass, @obj.instance_eval { dbclass })
    end

    def test_stream_pos
      assert_nil(@obj.instance_eval { stream_pos })
      @obj.entry_pos_flag = true
      assert_equal(0, @obj.instance_eval { stream_pos })
      @stream.gets
      assert_not_equal(0, @obj.instance_eval { stream.pos })
    end

    def test_rewind
      @obj.entry_pos_flag = true
      @stream.gets
      assert_not_equal(0, @stream.pos)
      @obj.rewind
      assert_equal(0, @stream.pos)
    end

  end #class TestTemplate

  class TestDefault < TestTemplate # < Test::Unit::TestCase
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

    def test_get_parsed_entry
      str1 = ">test1\naaagggtttcccaaagggtttccc\n"
      str2 = ">testC\ncccccccccccccccccccccccc\n"
      str3 = ">testG\ngggggggggggggggggggggggg\n"
      str4 = ">test2\ntttttttttttttttttttttttt\ntttttttttttttttttttttttt\n\n"
      str5 = ">test3\natatatatatatatatatatatat"

      @obj.skip_leader
      assert_equal(TestDataClass.new(str1), @obj.get_parsed_entry)
      assert_equal(TestDataClass.new(str2), @obj.get_parsed_entry)
      assert_equal(TestDataClass.new(str3), @obj.get_parsed_entry)
      assert_equal(TestDataClass.new(str4), @obj.get_parsed_entry)
      assert_equal(TestDataClass.new(str5), @obj.get_parsed_entry)
      assert(@stream.eof?)
    end

    def test_entry
      str1 = ">test1\naaagggtttcccaaagggtttccc\n"
      @obj.skip_leader
      @obj.get_entry
      assert_equal(str1, @obj.entry)
    end

    def test_entry_start_pos_default_nil
      @obj.skip_leader
      @obj.get_entry
      assert_nil(@obj.entry_start_pos)
    end

    def test_entry_ended_pos_default_nil
      @obj.skip_leader
      @obj.get_entry
      assert_nil(@obj.entry_ended_pos)
    end

    def test_entry_start_pos
      @obj.entry_pos_flag = true
      @obj.skip_leader
      @obj.get_entry
      assert_equal(25, @obj.entry_start_pos)
    end

    def test_entry_ended_pos
      @obj.entry_pos_flag = true
      @obj.skip_leader
      @obj.get_entry
      assert_equal(57, @obj.entry_ended_pos)
    end

  end #class TestDefault

  class TestLineOriented < TestTemplate # < Test::Unit::TestCase
    testdata02 = <<__END_OF_DATA__
#this is header line 1
#this is header line 2
test01 1 2 3
test02 4 5 6
test02 7 8 9
test02 10 11 12
test03 13 14 15

test03 16 17 18
__END_OF_DATA__
    TestData02 = testdata02.gsub(/\r\n/, "\n")

    class TestData02Class
      FLATFILE_SPLITTER = Bio::FlatFile::Splitter::LineOriented

      LineData = Struct.new(:name, :data)

      def initialize(str = '')
        @headers = []
        @lines = []
        flag_header = true
        str.each_line do |line|
          if flag_header then
            flag_header = add_header_line(line)
          end
          unless flag_header then
            r = add_line(line)
          end
        end
      end

      attr_reader :headers
      attr_reader :lines

      def ==(other)
        self.headers == other.headers and
          self.lines == other.lines ? true : false
      end

      def add_header_line(line)
        #puts "add_header_line: #{@headers.inspect} #{line.inspect}"
        case line
        when /\A\#/
          @headers.push line
          return self
        else
          return false
        end
      end

      def add_line(line)
        #puts "add_line: #{@lines.inspect} #{line.inspect}"
        if /\A\s*\z/ =~ line then
          return @lines.empty? ? self : false
        end
        parsed = parse_line(line)
        if @lines.empty? or @lines.first.name == parsed.name then
          @lines.push parsed
          return self
        else
          return false
        end
      end

      def parse_line(line)
        LineData.new(*(line.chomp.split(/\s+/, 2)))
      end
      private :parse_line

    end #class TestData02Class

    def setup
      @stream = Bio::FlatFile::BufferedInputStream.new(StringIO.new(TestData02), 'TestData02')
      @obj = Bio::FlatFile::Splitter::LineOriented.new(TestData02Class, @stream)
      @raw_entries =
        [
         "#this is header line 1\n#this is header line 2\ntest01 1 2 3\n",
         "test02 4 5 6\ntest02 7 8 9\ntest02 10 11 12\n",
         "test03 13 14 15\n",
         "\ntest03 16 17 18\n",
        ]
      @entries = @raw_entries.collect do |str|
        TestData02Class.new(str)
      end
    end

    def test_get_parsed_entry
      @entries.each do |ent|
        assert_equal(ent, @obj.get_parsed_entry)
      end
      assert_nil(@obj.get_parsed_entry)
    end

    def test_get_entry
      @raw_entries.each do |raw|
        assert_equal(raw, @obj.get_entry)
      end
      assert_nil(@obj.get_entry)
    end

    def test_rewind
      while @obj.get_parsed_entry; end
      assert_equal(0, @obj.rewind)
    end

    def test_flag_to_fetch_header
      assert(@obj.instance_eval { flag_to_fetch_header })
      @obj.get_parsed_entry
      assert(!@obj.instance_eval { flag_to_fetch_header })
      @obj.rewind
      assert(@obj.instance_eval { flag_to_fetch_header })
    end

    def test_skip_leader
      assert_nil(@obj.skip_leader)
    end

    def test_dbclass
      assert_equal(TestData02Class, @obj.instance_eval { dbclass })
    end

    def test_entry_start_pos
      @obj.entry_pos_flag = true
      @obj.skip_leader
      @obj.get_entry
      assert_equal(0, @obj.entry_start_pos)
      @obj.get_entry
      assert_equal(59, @obj.entry_start_pos)
    end

    def test_entry_ended_pos
      @obj.entry_pos_flag = true
      @obj.skip_leader
      @obj.get_entry
      assert_equal(59, @obj.entry_ended_pos)
      @obj.get_entry
      assert_equal(101, @obj.entry_ended_pos)
    end

  end #class TestLineOriented

end
