#
# bio/matrix.rb - biological matrix class
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
#  $Id: matrix.rb,v 1.5 2001/11/14 09:11:51 shuichi Exp $
#

require 'matrix'

class Matrix

  def []=(i, j, k)
    @rows[i][j] = k
  end

  def promoter_search(seq, threshold)
    result = []
    row_size = self.row_size
    seq_size = seq.size
    if seq_size > row_size
      i = 0
      max_score = get_max
      for x in (0 .. seq_size - row_size)
        sum = 0
        for y in (0 .. row_size - 1)
          sum += get_weight_na(seq[x+y], y)
        end
        score = sum.to_f/max_score.to_f
        if score > threshold
          result[i] = [x, "%4.3f" % score]
	  i += 1
        end
      end
    end
    if result.size == 0
      result = nil
    end
    result
  end

  private

  def get_weight_na(na, col)
    case na.downcase
    when 'a'
      return self[col, 0]
    when 'c'
      return self[col, 1]
    when 'g'
      return self[col, 2]
    when 't'
      return self[col, 3]
    else
      return 0
    end
  end

  def get_max
    sum = 0
    for i in (0 .. self.row_size - 1)
      max = 0
      for j in (0 .. self.column_size - 1)
        tmp = self[i, j]
        if max < tmp
          max = tmp
        end
      end
      sum += max
    end
    sum
  end

end


class Vector

  # Correlation coefficient
  def cc(v)
    Vector.Raise ErrDimensionMismatch if size != v.size

    x_mean = self.mean
    y_mean = v.mean
    x_total = 0.0
    y_total = 0.0
    s_total = 0.0

    each2(v) do |x, y|
      x_total += (x - x_mean)*(x - x_mean)
      y_total += (y - y_mean)*(y - y_mean)
      s_total += (x - x_mean)*(y - y_mean)
    end

    sqrt = Math.sqrt(x_total * y_total)

    if sqrt != 0.0
      s_total/sqrt
    else
      0.0
    end
  end

  def mean
    sum = 0.0
    0.upto(size - 1) do |i|
      sum += self[i]
    end
    sum/size
  end

end


