#
# bio/db/aaindex.rb - AAindex database class
#
#   Copyright (C) 2001 KAWASHIMA Shuichi <s@bioruby.org>
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
#  $Id: aaindex.rb,v 1.12 2004/02/21 19:43:50 k Exp $
#

require "bio/db"
require "matrix"

module Bio

  class AAindex < KEGGDB

    DELIMITER	= RS = "\n//\n"
    TAGSIZE	= 2

    def initialize(entry)
      super(entry, TAGSIZE)
    end

    def entry_id
      field_fetch('H')
    end

    def definition
      field_fetch('D')
    end

    def dblinks
      field_fetch('R')
    end

    def author
      field_fetch('A')
    end

    def title
      field_fetch('T')
    end

    def journal
      field_fetch('J')
    end

    def comment
      get('*')
    end

  end


  class AAindex1 < AAindex

    def initialize(entry)
      super(entry)
    end

    def correlation_coefficient
      field_fetch('C')
    end

    def index(type = :float)
      aa = %w( A R N D C Q E G H I L K M F P S T W Y V )
      values = field_fetch('I', 1).split(' ')

      if values.size != 20
	raise "Invalid format in #{entry_id} : #{values.inspect}"
      end

      if type == :zscore and values.size > 0
        sum = 0.0
        values.each do |a|
          sum += a.to_f
        end
        mean = sum / values.size	# / 20
        var = 0.0
        values.each do |a|
          var += (a.to_f - mean) ** 2
        end
        sd = Math.sqrt(var)
      end

      if type == :integer
        figure = 0
        values.each do |a|
          figure = [ figure, a[/\..*/].length - 1 ].max
        end
      end

      hash = {}

      aa.each_with_index do |a, i|
	case type
	when :string
	  hash[a] = values[i]
	when :float
	  hash[a] = values[i].to_f
	when :zscore
	  hash[a] = (values[i].to_f - mean) / sd
	when :integer
	  hash[a] = (values[i].to_f * 10 ** figure).to_i
	end
      end
      return hash
    end

  end


  class AAindex2 < AAindex

    def initialize(entry)
      super(entry)
    end

    def rows
      label_data
      @rows
    end

    def cols
      label_data
      @cols
    end

    def matrix
      ma = Array.new

      data = label_data
      data.each_line do |line|
        list = line.strip.split(/\s+/).map{|x| x.to_f}
        ma.push(list)
      end

      Matrix[*ma]
    end

    def old_matrix	# for AAindex <= ver 5.0

      @aa = {}		# used to determine row/column of the aa
      attr_reader :aa

      field = field_fetch('I')

      case field
      when / (ARNDCQEGHILKMFPSTWYV)\s+(.*)/	# 20x19/2 matrix
	aalist = $1
	values = $2.split(/\s+/)

	0.upto(aalist.length - 1) do |i|
	  @aa[aalist[i].chr] = i
	end

	ma = Array.new
	20.times do
	  ma.push(Array.new(20))		# 2D array of 20x(20)
	end

	for i in 0 .. 19 do
	  for j in i .. 19 do
	    ma[i][j] = values[i + j*(j+1)/2].to_f
	    ma[j][i] = ma[i][j]
	  end
	end
	Matrix[*ma]

      when / -ARNDCQEGHILKMFPSTWYV /		# 21x20/2 matrix (with gap)
	raise NotImplementedError
      when / ACDEFGHIKLMNPQRSTVWYJ- /		# 21x21 matrix (with gap)
	raise NotImplementedError
      end
    end

    private

    def label_data
      label, data = get('M').split("\n", 2)
      if /M rows = (\S+), cols = (\S+)/.match(label)
        rows, cols = $1, $2
        @rows = rows.split('')
        @cols = cols.split('')
      end
      return data
    end

  end

end


if __FILE__ == $0
  require 'bio/io/fetch'

  puts "### AAindex1 (PRAM900102)"
  aax1 = Bio::AAindex1.new(Bio::Fetch.query('aaindex', 'PRAM900102', 'raw'))
  p aax1.entry_id
  p aax1.definition
  p aax1.dblinks
  p aax1.author
  p aax1.title
  p aax1.journal
  p aax1.correlation_coefficient
  p aax1.index
  puts "### AAindex2 (HENS920102)"
  aax2 = Bio::AAindex2.new(Bio::Fetch.query('aaindex', 'HENS920102', 'raw'))
  p aax2.entry_id
  p aax2.definition
  p aax2.dblinks
  p aax2.author
  p aax2.title
  p aax2.journal
  p aax2.rows
  p aax2.cols
  p aax2.matrix
  p aax2.matrix[2,2]
  p aax2.matrix.determinant
  p aax2.matrix.rank
  p aax2.matrix.transpose
end

=begin

= Bio::AAindex

--- Bio::AAindex.new(entry)
--- Bio::AAindex#entry_id
--- Bio::AAindex#definition
--- Bio::AAindex#dblinks
--- Bio::AAindex#author
--- Bio::AAindex#title
--- Bio::AAindex#journal
--- Bio::AAindex#comment

= Bio::AAindex1

--- Bio::AAindex1#correlation_coefficient
--- Bio::AAindex1#index

= Bio::AAindex2

--- Bio::AAindex2#matrix
--- Bio::AAindex2#rows
--- Bio::AAindex2#cols

=end

