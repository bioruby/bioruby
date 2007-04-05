#
# bio/util/contingency_table.rb - Statistical contingency table analysis for aligned sequences
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: contingency_table.rb,v 1.7 2007/04/05 23:35:41 trevor Exp $
#

module Bio #:nodoc:

#
# bio/util/contingency_table.rb - Statistical contingency table analysis for aligned sequences
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
# = Description
# 
# The Bio::ContingencyTable class provides basic statistical contingency table
# analysis for two positions within aligned sequences.
# 
# When ContingencyTable is instantiated the set of characters in the
# aligned sequences may be passed to it as an array.  This is
# important since it uses these characters to create the table's rows
# and columns.  If this array is not passed it will use it's default
# of an amino acid and nucleotide alphabet in lowercase along with the
# clustal spacer '-'.
# 
# To get data from the table the most used functions will be
# chi_square and contingency_coefficient:
# 
#   ctable = Bio::ContingencyTable.new()
#   ctable['a']['t'] += 1
#   # .. put more values into the table
#   puts ctable.chi_square
#   puts ctable.contingency_coefficient  # between 0.0 and 1.0
# 
# The contingency_coefficient represents the degree of correlation of
# change between two sequence positions in a multiple-sequence
# alignment.  0.0 indicates no correlation, 1.0 is the maximum
# correlation.
# 
# 
# = Further Reading
# 
# * http://en.wikipedia.org/wiki/Contingency_table
# * http://www.physics.csbsju.edu/stats/exact.details.html
# * Numerical Recipes in C by Press, Flannery, Teukolsky, and Vetterling
#  
# = Usage
# 
# What follows is an example of ContingencyTable in typical usage
# analyzing results from a clustal alignment.
# 
#   require 'bio'
# 
#   seqs = {}
#   max_length = 0
#   Bio::ClustalW::Report.new( IO.read('sample.aln') ).to_a.each do |entry|
#     data = entry.data.strip
#     seqs[entry.definition] = data.downcase
#     max_length = data.size if max_length == 0
#     raise "Aligned sequences must be the same length!" unless data.size == max_length
#   end
# 
#   VERBOSE = true
#   puts "i\tj\tchi_square\tcontingency_coefficient" if VERBOSE
#   correlations = {}
# 
#   0.upto(max_length - 1) do |i|
#     (i+1).upto(max_length - 1) do |j|
#       ctable = Bio::ContingencyTable.new()
#       seqs.each_value { |seq| ctable.table[ seq[i].chr ][ seq[j].chr ] += 1 }
# 
#       chi_square = ctable.chi_square
#       contingency_coefficient = ctable.contingency_coefficient
#       puts [(i+1), (j+1), chi_square, contingency_coefficient].join("\t") if VERBOSE
# 
#       correlations["#{i+1},#{j+1}"] = contingency_coefficient
#       correlations["#{j+1},#{i+1}"] = contingency_coefficient  # Both ways are accurate
#     end
#   end
# 
#   require 'yaml'
#   File.new('results.yml', 'a+') { |f| f.puts correlations.to_yaml }
# 
# 
# = Tutorial
#
# ContingencyTable returns the statistical significance of change
# between two positions in an alignment.  If you would like to see how
# every possible combination of positions in your alignment compares
# to one another you must set this up yourself.  Hopefully the
# provided examples will help you get started without too much
# trouble.
# 
#   def lite_example(sequences, max_length, characters)
# 
#     %w{i j chi_square contingency_coefficient}.each { |x| print x.ljust(12) }
#     puts
# 
#     0.upto(max_length - 1) do |i|
#       (i+1).upto(max_length - 1) do |j|
#         ctable = Bio::ContingencyTable.new( characters )
#         sequences.each do |seq|
#           i_char = seq[i].chr
#           j_char = seq[j].chr
#           ctable.table[i_char][j_char] += 1
#         end
#         chi_square = ctable.chi_square
#         contingency_coefficient = ctable.contingency_coefficient
#         [(i+1), (j+1), chi_square, contingency_coefficient].each { |x| print x.to_s.ljust(12) }
#         puts
#       end
#     end
# 
#   end
# 
#   allowed_letters = Array.new
#   allowed_letters = 'abcdefghijk'.split('')
# 
#   seqs = Array.new
#   seqs << 'abcde'
#   seqs << 'abcde'
#   seqs << 'aacje'
#   seqs << 'aacae'
# 
#   length_of_every_sequence = seqs[0].size  # 5 letters long
# 
#   lite_example(seqs, length_of_every_sequence, allowed_letters)
# 
# 
# Producing the following results:
# 
#   i           j           chi_square  contingency_coefficient
#   1           2           0.0         0.0
#   1           3           0.0         0.0
#   1           4           0.0         0.0
#   1           5           0.0         0.0
#   2           3           0.0         0.0
#   2           4           4.0         0.707106781186548
#   2           5           0.0         0.0
#   3           4           0.0         0.0
#   3           5           0.0         0.0
#   4           5           0.0         0.0
# 
# The position i=2 and j=4 has a high contingency coefficient
# indicating that the changes at these positions are related.  Note
# that i and j are arbitrary, this could be represented as i=4 and j=2
# since they both refer to position two and position four in the
# alignment.  Here are some more examples:
# 
#   seqs = Array.new
#   seqs << 'abcde'
#   seqs << 'abcde'
#   seqs << 'aacje'
#   seqs << 'aacae'
#   seqs << 'akcfe'
#   seqs << 'akcfe'
# 
#   length_of_every_sequence = seqs[0].size  # 5 letters long
# 
#   lite_example(seqs, length_of_every_sequence, allowed_letters)
# 
# 
# Results:
# 
#   i           j           chi_square  contingency_coefficient
#   1           2           0.0         0.0
#   1           3           0.0         0.0
#   1           4           0.0         0.0
#   1           5           0.0         0.0
#   2           3           0.0         0.0
#   2           4           12.0        0.816496580927726
#   2           5           0.0         0.0
#   3           4           0.0         0.0
#   3           5           0.0         0.0
#   4           5           0.0         0.0
# 
# Here we can see that the strength of the correlation of change has
# increased when more data is added with correlated changes at the
# same positions.
# 
#   seqs = Array.new
#   seqs << 'abcde'
#   seqs << 'abcde'
#   seqs << 'kacje'  # changed first letter
#   seqs << 'aacae'
#   seqs << 'akcfa'  # changed last letter
#   seqs << 'akcfe'
# 
#   length_of_every_sequence = seqs[0].size  # 5 letters long
# 
#   lite_example(seqs, length_of_every_sequence, allowed_letters)
# 
# 
# Results:
# 
#   i           j           chi_square  contingency_coefficient
#   1           2           2.4         0.534522483824849
#   1           3           0.0         0.0
#   1           4           6.0         0.707106781186548
#   1           5           0.24        0.196116135138184
#   2           3           0.0         0.0
#   2           4           12.0        0.816496580927726
#   2           5           2.4         0.534522483824849
#   3           4           0.0         0.0
#   3           5           0.0         0.0
#   4           5           2.4         0.534522483824849
# 
# With random changes it becomes more difficult to identify correlated
# changes, yet positions two and four still have the highest
# correlation as indicated by the contingency coefficient.  The best
# way to improve the accuracy of your results, as is often the case
# with statistics, is to increase the sample size.
# 
# 
# = A Note on Efficiency
# 
# ContingencyTable is slow.  It involves many calculations for even a
# seemingly small five-string data set.  Even worse, it's very
# dependent on matrix traversal, and this is done with two dimensional
# hashes which dashes any hope of decent speed.
# 
# Finally, half of the matrix is redundant and positions could be
# summed with their companion position to reduce calculations.  For
# example the positions (5,2) and (2,5) could both have their values
# added together and just stored in (2,5) while (5,2) could be an
# illegal position.  Also, positions (1,1), (2,2), (3,3), etc.  will
# never be used.
# 
# The purpose of this package is flexibility and education.  The code
# is short and to the point in aims of achieving that purpose.  If the
# BioRuby project moves towards C extensions in the future a
# professional caliber version will likely be created.
#
  
class ContingencyTable
  # Since we're making this math-notation friendly here is the layout of @table:
  # * @table[row][column]
  # * @table[i][j]
  # * @table[y][x]
  attr_accessor :table
  attr_reader :characters

  # Create a ContingencyTable that has characters_in_sequence.size rows and
  # characters_in_sequence.size columns for each row
  #
  # ---
  # *Arguments*
  # * +characters_in_sequences+: (_optional_) The allowable characters that will be present in the aligned sequences.
  # *Returns*:: +ContingencyTable+ object to be filled with values and calculated upon
  def initialize(characters_in_sequences = nil)
    @characters = ( characters_in_sequences or %w{a c d e f g h i k l m n p q r s t v w y - x u} )
    tmp = Hash[*@characters.collect { |v| [v, 0] }.flatten]
    @table = Hash[*@characters.collect { |v| [v, tmp.dup] }.flatten]
  end
  
  # Report the sum of all values in a given row
  #
  # ---
  # *Arguments*
  # * +i+: Row to sum
  # *Returns*:: +Integer+ sum of row
  def row_sum(i)
    total = 0
    @table[i].each { |k, v| total += v }
    total
  end

  # Report the sum of all values in a given column
  #
  # ---
  # *Arguments*
  # * +j+: Column to sum
  # *Returns*:: +Integer+ sum of column
  def column_sum(j)
    total = 0
    @table.each { |row_key, column| total += column[j] }
    total
  end

  # Report the sum of all values in all columns.
  #
  # * This is the same thing as asking for the sum of all values in the table.
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Integer+ sum of all columns
  def column_sum_all
    total = 0
    @characters.each { |j| total += column_sum(j) }
    total
  end

  # Report the sum of all values in all rows.
  #
  # * This is the same thing as asking for the sum of all values in the table.
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Integer+ sum of all rows
  def row_sum_all
    total = 0
    @characters.each { |i| total += row_sum(i) }
    total
  end
  alias table_sum_all row_sum_all

  # Calculate _e_, the _expected_ value.
  #
  # ---
  # *Arguments*
  # * +i+: row
  # * +j+: column
  # *Returns*:: +Float+ e(sub:ij) = (r(sub:i)/N) * (c(sub:j))
  def expected(i, j)
    (row_sum(i).to_f / table_sum_all) * column_sum(j)
  end

  # Report the chi square of the entire table
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Float+ chi square value
  def chi_square
    total = 0
    c = @characters
    max = c.size - 1
    @characters.each do |i|    # Loop through every row in the ContingencyTable
      @characters.each do |j|  # Loop through every column in the ContingencyTable
        total += chi_square_element(i, j)
      end
    end
    total
  end

  # Report the chi-square relation of two elements in the table
  #
  # ---
  # *Arguments*
  # * +i+: row
  # * +j+: column
  # *Returns*:: +Float+ chi-square of an intersection
  def chi_square_element(i, j)
    eij = expected(i, j)
    return 0 if eij == 0
    ( @table[i][j] - eij )**2 / eij
  end

  # Report the contingency coefficient of the table
  #
  # ---
  # *Arguments*
  # * _none_
  # *Returns*:: +Float+ contingency_coefficient of the table
  def contingency_coefficient
    c_s = chi_square
    Math.sqrt(c_s / (table_sum_all + c_s) )
  end

end # ContingencyTable
end # Bio

