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
#  $Id: aaindex.rb,v 1.3 2001/09/26 18:49:25 katayama Exp $
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
    @aa = {}
  end
  attr_reader :aa

  def matrix

    org_field = field_fetch('I')
    if /Data ordered by .+ where I,J = ARNDCQEGHILKMFPSTWYV (.+)/ =~ org_field
      ma = Array.new(20, [])
      i = 0
      %w( A R N D C Q E G H I L K M F P S T W Y V ).each do |aa|
	@aa[aa] = i
	i += 1
      end
      org_ary = $1.split(/\s+/)
      for i in 0 .. 19 do
        for j in i .. 19 do
          c = i + 1
          r = j + 1
          ma[i][j] = org_ary[c+r*(r-1)/2 - 1].to_f
          ma[j][i] = ma[i][j]
        end
      end
      BioMatrix[*ma]
    elsif /Data ordered by = -ARNDCQEGHILKMFPSTWYV/ =~ org_field
      raise NotImplementedError
    elsif /Row data ordered by = ACDEFGHIKLMNPQRSTVWYJ-/ =~ org_field
      raise NotImplementedError
    end
  end

end
