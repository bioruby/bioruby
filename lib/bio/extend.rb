#
# bio/extend.rb - adds some features to the existing classes
#
#   Copyright (C) 2000-2002 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: extend.rb,v 1.1 2002/06/23 20:02:32 k Exp $
#

require 'bio/sequence'

class String

  def to_naseq
    Bio::Sequence::NA.new(self)
  end

  def to_aaseq
    Bio::Sequence::AA.new(self)
  end

  # folding both line end justified
  def fold(fill_column = 72, indent = 0)
    str = ''

    # size : allowed length of the actual text
    unless (size = fill_column - indent) > 0
      raise "[Error] indent > fill_column"
    end

    0.step(self.length - 1, size) do |n|
      str << ' ' * indent + self[n, size] + "\n"
    end

    return str
  end


  # folding with conscious about word boundaries with prefix string
  def fill(fill_column = 80, indent = 0, separater = ' ', prefix = '')
    str = ''

    # size : allowed length of the actual text
    unless (size = fill_column - indent) > 0
      raise "[Error] indent > fill_column"
    end

    head = prefix + ' ' * (indent - prefix.length)
    n = pos = 0

    while n < self.length
      pos = self[n, size].rindex(separater)

      if self[n, size].length < size	# last line of the folded str
        pos = nil
      end

      if pos
        str << head + self[n, pos+separater.length] + "\n"
        n += pos + separater.length
      else				# line too long or the last line
        str << head + self[n, size] + "\n"
        n += size
      end
    end

    return str
  end

end


class Array

  # from "Programming Ruby" by Thomas & Hunt
  def inject(n)
    each { |value| n = yield(n, value) }
    n
  end

  def sum
    inject(0) { |n, value| n + value }
  end

  def product
    inject(1) { |n, value| n * value }
  end

end

