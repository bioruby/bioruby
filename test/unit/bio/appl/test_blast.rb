#
# test/unit/bio/appl/test_blast.rb - Unit test for Bio::Blast
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
#  $Id: test_blast.rb,v 1.3 2006/02/03 17:39:13 nakao Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib'))).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/appl/blast'


module Bio
  class TestBlastData
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s
    TestDataBlast = Pathname.new(File.join(bioruby_root, 'test', 'data', 'blast')).cleanpath.to_s

    def self.input
      File.open(File.join(TestDataBlast, 'b0002.faa')).read
    end

    def self.output(format = '7')
      case format
      when '0'
        File.open(File.join(TestDataBlast, 'b0002.faa.m0')).read 
      when '7'
        File.open(File.join(TestDataBlast, 'b0002.faa.m7')).read 
      when '8'
        File.open(File.join(TestDataBlast, 'b0002.faa.m8')).read 
      end
    end
  end

    
  class TestBlast < Test::Unit::TestCase
    def setup
      @program = 'blastp'
      @db = 'test'
      @option = []
      @server = 'localhost'
      @blast = Bio::Blast.new(@program, @db, @option, @server)
    end
    
    def test_new
      blast = Bio::Blast.new(@program, @db)
      assert_equal(@program, blast.program)
      assert_equal(@db, blast.db)
      assert(blast.options)
      assert_equal('local', blast.server)
      assert_equal('blastall', blast.blastall)
    end

    def test_new_opt_string
      blast = Bio::Blast.new(@program, @db, '-m 7 -F F')
      assert_equal(['-m', '7', '-F', 'F'], blast.options)
    end

    def test_program
      assert_equal(@program, @blast.program) 
    end

    def test_db
      assert_equal(@db, @blast.db) 
    end

    def test_options
      assert_equal([], @blast.options) 
    end

    def test_option
      assert_equal('', @blast.option) 
    end

    def test_option_set
      @blast.option = '-m 7 -p T'
      assert_equal('-m 7 -p T', @blast.option) 
    end

    def test_server
      assert_equal(@server, @blast.server) 
    end

    def test_blastll
      assert_equal('blastall', @blast.blastall) 
    end

    def test_matrix
      assert_equal(nil, @blast.matrix) 
    end

    def test_filter
      assert_equal(nil, @blast.filter) 
    end

    def test_parser
      assert_equal(nil, @blast.instance_eval { @parser })
    end

    def test_output
      assert_equal('', @blast.output)  
    end

     def test_format
       assert(@blast.format)  
     end

     def test_self_local
       assert(Bio::Blast.local(@program, @db, @option))
     end

     def test_self_local
       assert(Bio::Blast.remote(@program, @db, @option))
     end

     def test_query
       # to be tested in test/functional/bio/test_blast.rb
     end

     def test_blast_reports
       Bio::Blast.reports(TestBlastData.output) do |report|
         assert(report)
       end
     end

     def test_parse_result
       assert(@blast.instance_eval { parse_result(TestBlastData.output) })
     end

     def test_exec_local
       # to be tested in test/functional/bio/test_blast.rb       
     end
     
     def test_exec_genomenet
       # to be tested in test/functional/bio/test_blast.rb
     end

     def test_exec_ncbi
       # to be tested in test/functional/bio/test_blast.rb
     end
   end
 end
