#
# test/unit/bio/appl/test_fasta.rb - Unit test for Bio::Fasta
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
#  $Id: test_fasta.rb,v 1.1 2005/12/18 16:50:20 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/fasta'


module Bio

  class TestFastaInitialize < Test::Unit::TestCase
    def test_new_1
      program = 'string'
      db = 'string'
      option = ['-e', '0.001']
      server = 'local'
      assert_raise(ArgumentError) { Bio::Fasta.new() }
      assert_raise(ArgumentError) { Bio::Fasta.new(program) }
      assert(Bio::Fasta.new(program, db))
      assert(Bio::Fasta.new(program, db, option))
      assert(Bio::Fasta.new(program, db, option, server))
      assert_raise(ArgumentError) {  Bio::Fasta.new(program, db, option, server, nil) }
    end

    def test_option_backward_compatibility
      fasta = Bio::Fasta.new('program', 'db', "-e 10")
      assert_equal([ '-Q', '-H', '-m','10', '-e',  '10'], fasta.options)
    end

    def test_option
      fasta = Bio::Fasta.new('program', 'db', ["-e", "10"])
      assert_equal([ '-Q', '-H', '-m','10', '-e', '10'], fasta.options)
    end
  end


  class TestFasta < Test::Unit::TestCase

    def setup
      program = 'ssearch'
      db = 'nr'
      option = ['-e', '10']
      @obj = Bio::Fasta.new(program, db, option)
    end

    def test_program
      assert_equal('ssearch', @obj.program)
      @obj.program = 'lalign'
      assert_equal('lalign', @obj.program)
    end

    def test_db
      assert_equal('nr', @obj.db)
      @obj.db = 'refseq'
      assert_equal('refseq', @obj.db)
    end

    def test_options
      assert_equal(["-Q", "-H", "-m", "10", "-e", "10"], @obj.options)
      @obj.options = ['-Q', '-H', '-m', '8']
      assert_equal(['-Q', '-H', '-m', '8'], @obj.options)
    end

    def test_server
      assert_equal('local', @obj.server)
      @obj.server = 'genomenet'
      assert_equal('genomenet', @obj.server)
    end

    def test_ktup
      assert_equal(nil, @obj.ktup)
      @obj.ktup = 6
      assert_equal(6, @obj.ktup)
    end
    def test_matrix
      assert_equal(nil, @obj.matrix)
      @obj.matrix = 'PAM120'
      assert_equal('PAM120', @obj.matrix)
    end

    def test_output
      assert_equal('', @obj.output)
#      assert_raise(NoMethodError) { @obj.output = "" }
    end
    
    def test_option
      option = ['-M'].to_s
      assert(@obj.option = option)
      assert_equal(option, @obj.option)
    end
    
    def test_format
      assert_equal(10, @obj.format)
    end

    def test_format_arg_str
      assert(@obj.format = '1')
      assert_equal(1, @obj.format)
    end

    def test_format_arg_integer
      assert(@obj.format = 2)
      assert_equal(2, @obj.format)
    end
  end

  class TestFastaQuery < Test::Unit::TestCase
    def test_self_parser
    end
    def test_self_local
      # test/functional/bio/test_fasta.rb
    end
    def test_self_remote
      # test/functional/bio/test_fasta.rb
    end
    def test_query
    end
  end

end
