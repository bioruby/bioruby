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

require "bio/biomatrix"
require "bio/db"

class AAindex < NCBIDB

  DELIMITER     = RS = "\n//\n"
  TAGSIZE       = 2

  def initialize(entry)
    super(entry, TAGSIZE)
  end

  # H  entry identifier        (1 per entry)
  #
  #H BEGF750101
  #
  def h
    field_fetch('H')
  end
  alias id h

  # D  definition of the entry (1 per entry)
  #
  #D Conformational parameter of inner helix (Beghin-Dirkx, 1975)
  #
  def d
    field_fetch('D')
  end
  alias def d

  def r
    field_fetch('R')
  end
  alias cross_ref r

  def a
    field_fetch('A')
  end
  alias author a

  def t
    field_fetch('T')
  end
  alias title t

  def j
    field_fetch('J')
  end
  alias journal j

end

class AAindex1 < AAindex

  def initialize(entry)
    super(entry)
  end

#C      Correlate coefficient
  def c
    field_fetch('C')
  end

#I      index
  def i
    index = []
    org_field = field_fetch('I')
    /A\/L R\/K N\/M D\/F C\/P Q\/S E\/T G\/W H\/Y I\/V (.+)/ =~ org_field
    org_index = $1.split(/\s+/)
    org_index.each do |x|
      index << x.to_f
    end
    index
  end
  alias index i

end

class AAindex2 < AAindex

  def initialize(entry)
    super(entry)
  end

  def matrix
    @ma = []
    (0 .. 19).each do |i|
      @ma << []
      (0 .. 19).each do |j|
        @ma[i] << nil
      end
    end
    org_field = field_fetch('I')
    if /Data ordered by .+ where I,J = ARNDCQEGHILKMFPSTWYV (.+)/ =~ org_field
      org_ary = $1.split(/\s+/)
      for i in 0 .. 19 do
        for j in i .. 19 do
          c = i + 1
          r = j + 1
          @ma[i][j] = org_ary[c+r*(r-1)/2 - 1].to_f
          @ma[j][i] = @ma[i][j]
        end
      end
      @m = BioMatrix[*@ma]
    end
    @m
  end
end
