#!/usr/bin/ruby 
# bio/biomatrix.rb - biological matrix class
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
#
include Math
require 'bio/sequence'
require 'matrix'

class BioMatrix < Matrix

  def win_search(seq, threshold)
    row_size = self.row_size
#    if seq.size < row_size
#      raise BioMatrixException, "#{seq} window size is larger than the query sequence"
#    end
    if seq.size > row_size
      @result = []
      i = 0
      max_score = get_max
      for x in (0 .. seq.size - row_size)
        sum = 0
        score = 0
        for y in (0 .. row_size - 1)
          sum += get_weight(seq[x+y, 1], y)
        end
        score = sum.to_f/max_score.to_f
        if score > threshold
          tmp_ary = []
          tmp_ary << score
          s_score = "%4.3f" % tmp_ary
          @result[i] = [x, s_score]
          i += 1
        end
      end
      if @result.size == 0
        @result = nil
      end
      @result
    else
      @result = nil
      @result
    end
  end

  def get_weight(nt, col)
    case nt
    when 'a', 'A'
      return self[col, 0]
    when 'c', 'C'
      return self[col, 1]
    when 'g', 'G'
      return self[col, 2]
    when 't', 'T'
      return self[col, 3]
    else
      return 0
    end
  end

  def get_max
    max = 0
    tmp = 0
    sum = 0
    for i in (0 .. self.row_size - 1)
      for j in (0 .. 3)
        tmp = self[i, j]
        if max < tmp
          max = tmp
        end
      end
      sum += max
      max = 0
    end
    sum
  end

end

class BioMatrixException<StandardError

end

class BioVector < Vector

  def cc(v)
    Vector.Raise ErrDimensionMismatch if size != v.size

    @x_mean = self.mean
    @y_mean = v.mean
    @x_total = 0.0
    @y_total = 0.0
    @s_total = 0.0
    each2(v) {
      |x, y|
      @x_total += (x - @x_mean)*(x - @x_mean)
      @y_total += (y - @y_mean)*(y - @y_mean)
      @s_total += (x - @x_mean)*(y - @y_mean)
    }
    if sqrt( @x_total * @y_total ) != 0
      @s_total/sqrt( @x_total * @y_total )
    else
      0.0
    end
  end

  def mean
    @sum = 0.0
    0.upto(size - 1) do |i|
      @sum += self[i]
    end
    @sum/size
  end

end

