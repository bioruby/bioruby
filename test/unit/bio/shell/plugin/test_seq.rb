#
# test/unit/bio/shell/plugin/test_seq.rb - Unit test for Bio::Shell plugin for biological sequence manipulations
#
# Copyright::   Copyright (C) 2005 
#               Mitsuteru Nakao <n@bioruby.org>
# License::     The Ruby License
#
# $Id: test_seq.rb,v 1.9 2007/04/05 23:35:44 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/shell'
require 'bio/shell/plugin/seq'

module Bio

  class TestShellPluginSeq < Test::Unit::TestCase
    include Bio::Shell

    Bio::Shell.config = {:color => false}

    def test_htmlseq
      str = 'ATGC'
      html =<<END
<div style="font-family:monospace;">
<span style="background:#64F73F;">a</span>
<span style="background:#3C88EE;">t</span>
<span style="background:#EB413C;">g</span>
<span style="background:#FFB340;">c</span>
<br>
</div>
END
      assert_equal(html, htmlseq(str))
    end


    def test_naseq
      str = 'ACGT'
      assert_equal(Bio::Sequence, getseq(str).class)
      assert_equal(Bio::Sequence::NA, getseq(str).moltype)
      assert_equal('acgt', getseq(str).seq)
    end


    def test_aaseq
      str = 'WD'
      assert_equal(Bio::Sequence, getseq(str).class)
      assert_equal(Bio::Sequence::AA, getseq(str).moltype)
      assert_equal('WD', getseq(str).seq)
    end


    def test_na_seqstat
      naseq = 'atgcatgcatgc'
      output =<<END

* * * Sequence statistics * * *

5'->3' sequence   : atgcatgcatgc
3'->5' sequence   : gcatgcatgcat
Translation   1   : MHAC
Translation   2   : CMH
Translation   3   : ACM
Translation  -1   : ACMH
Translation  -2   : HAC
Translation  -3   : MHA
Length            : 12 bp
GC percent        : 50 %
Composition       : a -  3 ( 25.00 %)
                    c -  3 ( 25.00 %)
                    g -  3 ( 25.00 %)
                    t -  3 ( 25.00 %)
Codon usage       :

 *---------------------------------------------*
 |       |              2nd              |     |
 |  1st  |-------------------------------| 3rd |
 |       |  U    |  C    |  A    |  G    |     |
 |-------+-------+-------+-------+-------+-----|
 | U   U |F  0.0%|S  0.0%|Y  0.0%|C  0.0%|  u  |
 | U   U |F  0.0%|S  0.0%|Y  0.0%|C 25.0%|  c  |
 | U   U |L  0.0%|S  0.0%|*  0.0%|*  0.0%|  a  |
 |  UUU  |L  0.0%|S  0.0%|*  0.0%|W  0.0%|  g  |
 |-------+-------+-------+-------+-------+-----|
 |  CCCC |L  0.0%|P  0.0%|H 25.0%|R  0.0%|  u  |
 | C     |L  0.0%|P  0.0%|H  0.0%|R  0.0%|  c  |
 | C     |L  0.0%|P  0.0%|Q  0.0%|R  0.0%|  a  |
 |  CCCC |L  0.0%|P  0.0%|Q  0.0%|R  0.0%|  g  |
 |-------+-------+-------+-------+-------+-----|
 |   A   |I  0.0%|T  0.0%|N  0.0%|S  0.0%|  u  |
 |  A A  |I  0.0%|T  0.0%|N  0.0%|S  0.0%|  c  |
 | AAAAA |I  0.0%|T  0.0%|K  0.0%|R  0.0%|  a  |
 | A   A |M 25.0%|T  0.0%|K  0.0%|R  0.0%|  g  |
 |-------+-------+-------+-------+-------+-----|
 |  GGGG |V  0.0%|A  0.0%|D  0.0%|G  0.0%|  u  |
 | G     |V  0.0%|A  0.0%|D  0.0%|G  0.0%|  c  |
 | G GGG |V  0.0%|A 25.0%|E  0.0%|G  0.0%|  a  |
 |  GG G |V  0.0%|A  0.0%|E  0.0%|G  0.0%|  g  |
 *---------------------------------------------*

Molecular weight  : 3701.61444
Protein weight    : 460.565
//
END
      $str = ''
      alias puts_orig puts
      def puts(*args)
        args.each do |obj|
          $str << obj.to_s
        end
      end
      seqstat(naseq)
      undef puts
      alias puts puts_orig
      assert_equal(output, $str)
    end


    def test_aa_seqstat
      aaseq = 'WD'
      output =<<END

* * * Sequence statistics * * *

N->C sequence     : WD
Length            : 2 aa
Composition       : D Asp - 1 ( 50.00 %) aspartic acid
                    W Trp - 1 ( 50.00 %) tryptophan
Protein weight    : 319.315
//
END
      $str = ''
      alias puts_orig puts
      def puts(*args)
        args.each do |obj|
          $str << obj.to_s
        end
      end
      seqstat(aaseq)
      undef puts
      alias puts puts_orig
      assert_equal(output, $str)
    end


    def test_doublehelix
      seq = 'ACGTACGTACGTACGT'
      output = <<END
     at
    c--g
   g---c
  t----a
 a----t
c---g
g--c
 ta
 ta
g--c
c---g
 a----t
  t----a
   g---c
    c--g
     at
END
      $str = ''
      alias puts_orig puts
      def puts(*args)
        args.each do |obj|
          $str << obj.to_s
        end
      end
      doublehelix(seq)
      undef puts
      alias puts puts_orig
      assert_equal(output, $str)
    end

  end

end
