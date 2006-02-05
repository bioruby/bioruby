#
# test/unit/bio/sequence/test_compat.rb - Unit test for Bio::Sequencce::Compat
#
#   Copyright (C) 2006 Mitsuteru C. Nakao <n@bioruby.org>
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
#  $Id: test_compat.rb,v 1.1 2006/02/05 17:39:27 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/sequence'
require 'bio/sequence/compat'

module Bio
  
  class TSequence < String
    include Bio::Sequence::Common
  end


  class TestSequenceCompat < Test::Unit::TestCase

    def setup
      @obj  = TSequence.new('atgcatgcatgcatgcaaaa')
    end

    def test_to_s
      str = 'atgcatgcatgcatgcaaaa'
      assert_equal(str, @obj.to_s)
    end
  end


  class TestSequenceCommonCompat < Test::Unit::TestCase

    # Test Sequence#to_fasta    
    def test_to_fasta
      sequence = TSequence.new("agtc" * 10)
      header = "the header"
      str = ">the header\n" + ("agtc" * 5) + "\n" + ("agtc" * 5) + "\n"
      assert_equal(str, sequence.to_fasta(header, 20))
    end

  end


  require 'bio/sequence/na'

  class TestSequenceNACompat < Test::Unit::TestCase
    def test_na_self_randomize
      composition = Bio::Sequence::NA.new("acgtacgt").composition
      assert(Bio::Sequence::NA.randomize(composition))
    end
  end 

  require 'bio/sequence/aa'  

  class TestSequenceNACompat < Test::Unit::TestCase
    def test_aa_self_randomize
      composition = Bio::Sequence::AA.new("WWDTGAK").composition
      assert(Bio::Sequence::AA.randomize(composition))
    end
  end

end
