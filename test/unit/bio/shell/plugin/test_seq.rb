#
# test/unit/bio/shell/plugin/test_seq.rb - Unit test for Bio::Shell plugin for biological sequence manipulations
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: test_seq.rb,v 1.1 2005/10/28 02:03:34 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 5, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/shell'

module Bio
  class TestShellPluginSeq < Test::Unit::TestCase
    include Bio::Shell    


    def test_naseq
      str = 'ACGT'
      assert_equal(naseq(str).class, Bio::Sequence::NA)
      assert_equal(naseq(str), Bio::Sequence::NA.new(str))
      assert_equal(naseq(str), 'acgt')
    end

    def test_aaseq
      str = 'WD'
      assert_equal(aaseq(str).class, Bio::Sequence::AA)
      assert_equal(aaseq(str), Bio::Sequence::AA.new('WD'))
      assert_equal(aaseq(str), 'WD')
    end

    def test_revseq
      str = 'acgta'
      assert_equal(revseq(str), 'tacgt')
    end

    def test_translate
      str = 'ATGATG'
      assert_equal(translate(str), Bio::Sequence::AA.new('MM'))
    end

    def test_seq_report_na
      str = 'ACGT'
      output = ''
      assert_equal(seq_report(str), output)
    end


    def test_seq_report_aa
      str = 'WD'
      output = ''
      assert_equal(seq_report(str), output)
    end


    def test_na_report
      naseq = 'ACGT'
      output =<<END
input sequence     : acgt
reverse complement : acgt
translation 1      : T
translation 2      : R
translation 3      : GT
translation -1     : T
translation -2     : R
translation -3     : GT
gc percent         : 50 %
composition        : {\"a\"=>1, \"c\"=>1, \"g\"=>1, \"t\"=>1}
molecular weight   : 1245.88148
complemnet weight  : 1245.88148
protein weight     : 119.12
//
END
      assert_equal(na_report(naseq), output)
    end

    def test_aa_report
      aaseq = 'WD'
      output =<<END
input sequence    : WD
composition       : {\"W\"=>1, \"D\"=>1}
protein weight    : 319.315
amino acid codes  : [\"Trp\", \"Asp\"]
amino acid names  : [\"tryptophan\", \"aspartic acid\"]
//
END
      assert_equal(aa_report(aaseq), output)
    end

    def test_double_helix
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
      assert_equal(double_helix(seq), output)
    end

  end
end
