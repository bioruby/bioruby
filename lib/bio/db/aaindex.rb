#
# bio/db/aaindex.rb - AAindex database class
#
#   Copyright (C) 2001 KAWASHIMA Shuichi <s@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: aaindex.rb,v 1.4 2001/09/26 19:13:38 katayama Exp $
#

require "bio/db"
require "bio/matrix"

class AAindex < NCBIDB

  DELIMITER     = RS = "\n//\n"
  TAGSIZE       = 2

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  def id
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

end

class AAindex1 < AAindex

  def initialize(entry)
    super(entry)
  end

  def correlation_coefficient
    field_fetch('C')
  end

  def index
    hash = {}; i = 0
    aa   = %w( A R N D C Q E G H I L K M F P S T W Y V )
    field_fetch('I').scan(/[\d\.]+/).each do |value|
      hash[aa[i]] = value.to_f
      i += 1
    end
    return hash
  end

end

class AAindex2 < AAindex


  def initialize(entry)
    super(entry)
    @aa = {}		# used to determine row/column of the aa
  end
  attr_reader :aa

  def matrix
    field = field_fetch('I')

    case field
    when / (ARNDCQEGHILKMFPSTWYV)\s+(.*)/	# 20x19/2 matrix
      aalist = $1
      values = $2.split(/\s+/)

      0.upto(aalist.length - 1) do |i|
        @aa[aalist[i].chr] = i
      end

      ma = Array.new(20, [])		# 2D array of 20x(20)
      for i in 0 .. 19 do
        for j in i .. 19 do
          ma[i][j] = values[i + j*(j+1)/2].to_f
          ma[j][i] = ma[i][j]
        end
      end
      BioMatrix[*ma]

    when / -ARNDCQEGHILKMFPSTWYV /	# 21x20/2 matrix (with gap)
      raise NotImplementedError
    when / ACDEFGHIKLMNPQRSTVWYJ- /	# 21x21 matrix (with gap)
      raise NotImplementedError
    end
  end

end
