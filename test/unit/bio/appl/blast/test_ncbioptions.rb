#
# = test/unit/bio/appl/blast/test_ncbioptions.rb - Unit test for Bio::Blast::NCBIOptions
#
# Copyright::  Copyright (C) 2008 Naohisa Goto <ng@bioruby.org>
# License::    The Ruby License
#
#  $Id:$
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/blast/ncbioptions'

module Bio

  class TestBlastNCBIOptions < Test::Unit::TestCase

    def setup
      @str = '-p blastn -m0 -m 1 -m2 -m 3 -F T -m 4 m5 -pblastx -m 6 -m 7'
      @options = %w( -p blastn -m0 -m 1 -m2 -m 3 -F T -m 4 m5
                     -pblastx -m 6 -m 7 )
      @normalized_options = %w( -F T m5 -p blastx -m 7 )
      @obj = Bio::Blast::NCBIOptions.parse(@str)
    end

    def test_parse
      str = '-p tblastx -d cdna_human -i est001.fst -o test.blastn -e 0.1'
      options = %w( -p tblastx -d cdna_human -i est001.fst
                    -o test.blastn -e 0.1 )
      obj = Bio::Blast::NCBIOptions.parse(str)
      assert_equal(options, obj.options)
    end

    def test_normalize!
      assert_nothing_raised { @obj.normalize! }
      assert_equal(@normalized_options, @obj.options)
    end

    def test_get
      assert_equal('blastx', @obj.get('-p'))
      assert_equal('blastx', @obj.get('p'))

      assert_equal('7', @obj.get('-m'))
      assert_equal('7', @obj.get('m'))

      assert_equal('T', @obj.get('-F'))
      assert_equal('T', @obj.get('F'))

      assert_nil(@obj.get('-X'))
    end

    def test_delete
      assert_equal('blastx', @obj.delete('-p'))
      assert_nil(@obj.delete('p'))

      assert_equal('7', @obj.delete('-m'))
      assert_nil(@obj.delete('m'))

      assert_equal('T', @obj.delete('F'))
      assert_nil(@obj.delete('-F'))

      assert_nil(@obj.delete('-X'))
    end

    def test_set
      assert_equal('blastx', @obj.set('-p', 'blastp'))
      assert_equal('blastp', @obj.set('p', 'tblastx'))
      assert_equal('tblastx',@obj.get('p'))
      
      assert_equal('7', @obj.set('m', '8'))
      assert_equal('8', @obj.set('-m', '0'))
      assert_equal('0', @obj.get('m'))
      
      assert_equal('T', @obj.set('-F', 'F'))
      assert_equal('F', @obj.get('F'))

      assert_nil(@obj.set('-d', 'nr'))
      assert_equal('nr', @obj.get('d'))

      assert_nil(@obj.set('i', 'test.fst'))
      assert_equal('test.fst', @obj.get('-i'))
    end

    def test_equal_equal
      obj1 = Bio::Blast::NCBIOptions.parse(@str)
      assert_equal(true, @obj == obj1)

      obj2 = Bio::Blast::NCBIOptions.parse('-F F')
      assert_equal(false, @obj == obj2)

      assert_equal(false, @obj == 12345)
    end

    def test_add_options
      opts = %w( -p tblastx -m 8 -d cdna -i est.fst -o test.blast -e 0.01 )
      result_opts = %w( -F T m5 ) + opts
      assert_nothing_raised { @obj.add_options(opts) }
      assert_equal(result_opts, @obj.options)
    end

    def test_make_command_line_options
      opts = %w( -p tblastx -d cdna -i est.fst -o test.blast -e 0.01 )
      result_opts = opts + %w( -m 0 -m 1 -m 2 -m 3 -F T -m 4 m5 -m 6 -m 7 )
      assert_equal(result_opts, @obj.make_command_line_options(opts))
    end

  end #class TestBlastNCBIOptions

end #module Bio
