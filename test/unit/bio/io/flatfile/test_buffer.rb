#
# = test/unit/bio/io/flatfile/test_buffer.rb - unit test for Bio::FlatFile::BufferedInputStream
#
#   Copyright (C) 2006 Naohisa Goto <ng@bioruby.org>
#
# License:: The Ruby License
#
#  $Id:$
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'
require 'stringio'
require 'bio/io/flatfile/buffer'

module Bio::TestFlatFileBufferedInputStream

  TestDataPath = BioRubyTestDataPath
  TestDataFastaFormat01 = File.join(TestDataPath, 'fasta', 'example1.txt')

  class TestBufferedInputStreamParseFileOpenArg < Test::Unit::TestCase

    K = Bio::FlatFile::BufferedInputStream

    def _parse_file_open_mode(mode)
      K.module_eval { _parse_file_open_mode(mode) }
    end
    private :_parse_file_open_mode

    def _parse_file_open_arg(*arg)
      K.module_eval { _parse_file_open_arg(*arg) }
    end
    private :_parse_file_open_arg

    def test_parse_file_open_mode_nil
      assert_equal(nil, _parse_file_open_mode(nil))
    end

    def test_parse_file_open_mode_integer
      assert_equal({ :fmode_integer => 127 },
                   _parse_file_open_mode(127))
    end

    def test_parse_file_open_mode_str
      assert_equal({ :fmode_string => "r+b" },
                   _parse_file_open_mode("r+b"))
    end

    def test_parse_file_open_mode_str_with_ext_enc
      assert_equal({ :fmode_string => "r+t",
                     :external_encoding => "UTF-8" },
                   _parse_file_open_mode("r+t:UTF-8"))
    end

    def test_parse_file_open_mode_str_with_enc
      assert_equal({ :fmode_string => "rb",
                     :external_encoding => "EUC-JP",
                     :internal_encoding => "UTF-8" },
                   _parse_file_open_mode("rb:EUC-JP:UTF-8"))
    end

    def test_parse_file_open_arg_nil
      assert_equal({}, _parse_file_open_arg(nil))
    end

    def test_parse_file_open_arg_integer
      assert_equal({ :fmode_integer => 127 },
                   _parse_file_open_arg(127))
    end

    def test_parse_file_open_arg_str
      assert_equal({ :fmode_string => "r+b" },
                   _parse_file_open_arg("r+b"))
    end

    def test_parse_file_open_arg_str_with_ext_enc
      assert_equal({ :fmode_string => "r+t",
                     :external_encoding => "UTF-8" },
                   _parse_file_open_arg("r+t:UTF-8"))
    end

    def test_parse_file_open_arg_str_with_enc
      assert_equal({ :fmode_string => "rb",
                     :external_encoding => "EUC-JP",
                     :internal_encoding => "UTF-8" },
                   _parse_file_open_arg("rb:EUC-JP:UTF-8"))
    end

    def test_parse_file_open_arg_str_perm
      assert_equal({ :fmode_string => "r+b",
                     :perm => 0644 },
                   _parse_file_open_arg("r+b", 0644))
    end

    def test_parse_file_open_arg_int_perm
      assert_equal({ :fmode_integer => 255,
                     :perm => 0755 },
                   _parse_file_open_arg(255, 0755))
    end

    def test_parse_file_open_arg_int_perm_opt
      assert_equal({ :fmode_integer => 191,
                     :perm => 0600,
                     :textmode => true,
                     :internal_encoding => "EUC-JP" },
                   _parse_file_open_arg(191, 0600,
                                        :textmode => true,
                                        :internal_encoding => "EUC-JP"))
    end

    def test_parse_file_open_arg_int_opt
      assert_equal({ :fmode_integer => 191,
                     :textmode => true,
                     :internal_encoding => "EUC-JP" },
                   _parse_file_open_arg(191, 
                                        :textmode => true,
                                        :internal_encoding => "EUC-JP"))
    end

    def test_parse_file_open_arg_str_perm_opt
      assert_equal({ :fmode_string => "a",
                     :perm => 0644,
                     :binmode => true,
                     :external_encoding => "UTF-8" },
                   _parse_file_open_arg("a", 0644,
                                        :binmode => true,
                                        :external_encoding => "UTF-8"))
    end

    def test_parse_file_open_arg_str_opt
      assert_equal({ :fmode_string => "a",
                     :binmode => true,
                     :external_encoding => "UTF-8" },
                   _parse_file_open_arg("a",
                                        :binmode => true,
                                        :external_encoding => "UTF-8"))
    end

    def test_parse_file_open_arg_opt
      assert_equal({ :fmode_string => "r",
                     :binmode => true,
                     :external_encoding => "UTF-8" },
                   _parse_file_open_arg(:mode => "r",
                                        :binmode => true,
                                        :external_encoding => "UTF-8"))
    end

    def test_parse_file_open_arg_opt_with_integer_mode
      assert_equal({ :fmode_integer => 123,
                     :perm => 0600,
                     :textmode => true,
                     :external_encoding => "EUC-JP" },
                   _parse_file_open_arg(:mode => 123,
                                        :perm => 0600,
                                        :textmode => true,
                                        :external_encoding => "EUC-JP"))
    end
  end #class TestBufferedInputStreamParseFileOpenArg

  class TestBufferedInputStreamClassMethod < Test::Unit::TestCase

    def test_self_for_io
      io = File.open(TestDataFastaFormat01)
      obj = Bio::FlatFile::BufferedInputStream.for_io(io)
      assert_instance_of(Bio::FlatFile::BufferedInputStream, obj)
      assert_equal(TestDataFastaFormat01, obj.path)
    end

    def test_self_open_file
      obj = Bio::FlatFile::BufferedInputStream.open_file(TestDataFastaFormat01)
      assert_instance_of(Bio::FlatFile::BufferedInputStream, obj)
      assert_equal(TestDataFastaFormat01, obj.path)
    end

    def test_self_open_file_with_block
      obj2 = nil
      Bio::FlatFile::BufferedInputStream.open_file(TestDataFastaFormat01) do |obj|
        assert_instance_of(Bio::FlatFile::BufferedInputStream, obj)
        assert_equal(TestDataFastaFormat01, obj.path)
        obj2 = obj
      end
      assert_raise(IOError) { obj2.close }
    end
  end #class TestBufferedInputStreamClassMethod

  class TestBufferedInputStream < Test::Unit::TestCase
    def setup
      io = File.open(TestDataFastaFormat01)
      io.binmode
      path = TestDataFastaFormat01
      @obj = Bio::FlatFile::BufferedInputStream.new(io, path)
    end

    def test_to_io
      assert_kind_of(IO, @obj.to_io)
    end

    def test_close
      assert_nil(@obj.close)
    end

    def test_rewind
      @obj.prefetch_gets
      @obj.rewind
      assert_equal('', @obj.prefetch_buffer)
    end

    def test_pos
      @obj.gets
      @obj.gets
      @obj.prefetch_gets
      assert_equal(117, @obj.pos) #the number depends on original data
    end

    def test_pos=()
      str = @obj.gets
      assert_equal(0, @obj.pos = 0)
      assert_equal(str, @obj.gets)
    end
      
    def test_eof_false_first
      assert_equal(false, @obj.eof?)
    end

    def test_eof_false_after_prefetch
      while @obj.prefetch_gets; nil; end
      assert_equal(false, @obj.eof?)
    end

    def test_eof_true
      while @obj.gets; nil; end
      assert_equal(true, @obj.eof?)
    end

    def test_gets
      @obj.gets
      @obj.gets
      assert_equal("gagcaaatcgaaaaggagagatttctgcatatcaagagaaaattcgagctgagatacattccaagtgtggctactc", @obj.gets.chomp)
    end

    def test_gets_equal_prefetch_gets
      @obj.prefetch_gets
      str = @obj.prefetch_gets
      @obj.prefetch_gets
      @obj.gets
      assert_equal(@obj.gets, str)
    end

    def test_gets_rs
      rs = 'tggtg'
      str = <<__END_OF_STR__
aggcactagaattgagcagtgaa
gaagatgaggaagatgaagaagaagatgaggaagaaatcaagaaagaaaaatgcgaattttctgaagatgtagacc
gatttatatggacggttgggcaggactatggtttggatgatctggtcgtgcggcgtgctctcgccaagtacctcga
agtggatgtttcggacatattggaaagatacaatgaactcaagcttaagaatgatggaactgctggtg
__END_OF_STR__
      @obj.gets(rs)
      @obj.gets(rs)
      assert_equal(str.chomp, @obj.gets(rs))
    end

    def test_gets_rs_equal_prefetch_gets
      rs = 'tggtg'
      @obj.prefetch_gets(rs)
      str = @obj.prefetch_gets(rs)
      @obj.prefetch_gets(rs)
      @obj.gets(rs)
      assert_equal(@obj.gets(rs), str)
    end

    def test_gets_rs_within_buffer
      rs = 'tggtg'
      a = []
      20.times {a.push @obj.gets }
      @obj.ungets(a.join(''))
      
      assert_equal(">At1g02580 mRNA (2291 bp) UTR's and CDS\naggcgagtggttaatggagaaggaaaaccatgaggacgatggtg", @obj.gets(rs))

      assert_equal('ggctgaaagtgattctgtgattggtaagagacaaatctattatttgaatggtg',
                   @obj.gets(rs).split(/\n/)[-1])

      assert_equal('aggcactagaattgagcagtgaa',
                   @obj.gets(rs).split(/\n/)[0])

      assert_equal('aggcttct', @obj.gets(rs).split(/\n/)[0])

      assert_equal('agacacc', @obj.gets(rs).split(/\n/)[0])
    end

    def test_gets_paragraph_mode
      @obj.gets('')
      @obj.gets('')
      assert_equal('>At1g65300: mRNA 837bp (shortened at end)',
                   @obj.gets('').split(/\n/)[0])
    end

    def test_gets_paragraph_mode_equal_prefetch_gets
      rs = ''
      @obj.prefetch_gets(rs)
      str = @obj.prefetch_gets(rs)
      @obj.prefetch_gets(rs)
      @obj.gets(rs)
      assert_equal(@obj.gets(rs), str)
    end

    def test_gets_paragraph_mode_within_buffer
      @obj.gets('')
      a = []
      20.times {a.push @obj.gets }
      @obj.ungets(a.join(''))
     
      assert_equal('>At1g65300: mRNA 837bp',
                   @obj.gets('').split(/\n/)[0])

      assert_equal('>At1g65300: mRNA 837bp (shortened at end)',
                   @obj.gets('').split(/\n/)[0])

      assert_equal('>At1g65300: mRNA 837bp (shortened from start)',
                   @obj.gets('').split(/\n/)[0])
    end

    def test_ungets
      @obj.gets
      @obj.gets
      str1 = @obj.gets
      str2 = @obj.gets
      assert_nil(@obj.ungets(str2))
      assert_nil(@obj.ungets(str1))
      assert_equal(str1, @obj.gets)
      assert_equal(str2, @obj.gets)
    end

    def test_getc
      assert_equal(?>, @obj.getc)
    end

    def test_getc_after_prefetch
      @obj.prefetch_gets
      assert_equal(?>, @obj.getc)
    end

    def test_ungetc
      c = @obj.getc
      assert_nil(@obj.ungetc(c))
      assert_equal(c, @obj.getc)
    end

    def test_ungetc_after_prefetch
      str = @obj.prefetch_gets
      c = @obj.getc
      assert_nil(@obj.ungetc(c))
      assert_equal(str, @obj.gets)
    end

    def test_prefetch_buffer
      str = @obj.prefetch_gets
      str += @obj.prefetch_gets
      assert_equal(str, @obj.prefetch_buffer)
    end

    def test_prefetch_gets
      @obj.prefetch_gets
      @obj.prefetch_gets
      @obj.gets
      str = @obj.prefetch_gets
      @obj.gets
      assert_equal(str, @obj.gets)
    end

    def test_prefetch_gets_with_arg
      # test @obj.gets
      str = @obj.prefetch_gets("\n>")
      assert_equal(str, @obj.gets("\n>"))
      # test using IO object
      io = @obj.to_io
      io.rewind
      assert_equal(str, io.gets("\n>"))
    end

    def test_skip_spaces
      @obj.gets('CDS')
      assert_nil(@obj.skip_spaces)
      assert_equal(?a, @obj.getc)
    end
                   
  end #class TestBufferedInputStream
end #module Bio::TestFlatFile

