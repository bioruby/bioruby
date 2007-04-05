#
# test/unit/bio/util/test_contingency_table.rb - Unit test for Bio::ContingencyTable
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: test_contingency_table.rb,v 1.4 2007/04/05 23:35:44 trevor Exp $
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4 , 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'test/unit'
require 'bio/util/contingency_table'

module Bio #:nodoc:
  class TestContingencyTable < Test::Unit::TestCase #:nodoc:
 
    def lite_example(sequences, max_length, characters)

      output = []

      0.upto(max_length - 1) do |i|
        (i+1).upto(max_length - 1) do |j|
          ctable = Bio::ContingencyTable.new( characters )
          sequences.each do |seq|
            i_char = seq[i].chr
            j_char = seq[j].chr
            ctable.table[i_char][j_char] += 1
          end
          chi_square = ctable.chi_square
          contingency_coefficient = ctable.contingency_coefficient
          output << [(i+1), (j+1), chi_square, contingency_coefficient]
        end
      end

      return output
    end


    def test_lite_example
      ctable = Bio::ContingencyTable
      allowed_letters = 'abcdefghijk'.split('')

      seqs = Array.new
      seqs << 'abcde'
      seqs << 'abcde'
      seqs << 'kacje'
      seqs << 'aacae'
      seqs << 'akcfa'
      seqs << 'akcfe'

      length_of_every_sequence = seqs[0].size  # 5 letters long

      results = lite_example(seqs, length_of_every_sequence, allowed_letters)

=begin
  i           j           chi_square  contingency_coefficient
  1           2           2.4         0.534522483824849
  1           3           0.0         0.0
  1           4           6.0         0.707106781186548
  1           5           0.24        0.196116135138184
  2           3           0.0         0.0
  2           4           12.0        0.816496580927726
  2           5           2.4         0.534522483824849
  3           4           0.0         0.0
  3           5           0.0         0.0
  4           5           2.4         0.534522483824849
=end


      #assert_equal(2.4, results[0][2])
      assert_equal('2.4', results[0][2].to_s)
      assert_equal('0.534522483824849', results[0][3].to_s)

      assert_equal('12.0', results[5][2].to_s)
      assert_equal('0.816496580927726', results[5][3].to_s)

      assert_equal('2.4', results[9][2].to_s)
      assert_equal('0.534522483824849', results[9][3].to_s)

      ctable = Bio::ContingencyTable.new
      ctable.table['a']['t'] = 4
      ctable.table['a']['g'] = 2
      ctable.table['g']['t'] = 3
      assert_equal('1.28571428571429', ctable.chi_square.to_s)
      assert_equal(ctable.column_sum_all, ctable.row_sum_all)
      assert_equal(ctable.column_sum_all, ctable.table_sum_all)
    end

  end
end
