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
#  $Id: extend.rb,v 1.2 2002/07/30 09:25:38 k Exp $
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
  def fill(fill_column = 80, indent = 0, separater = ' ', prefix = '', first_line_only = true)

    # size : allowed length of the actual text
    unless (size = fill_column - indent) > 0
      raise "[Error] indent > fill_column"
    end

    n = pos = 0
    str = []
    while n < self.length
      pos = self[n, size].rindex(separater)

      if self[n, size].length < size	# last line of the folded str
        pos = nil
      end

      if pos
        str << self[n, pos+separater.length]
        n += pos + separater.length
      else				# line too long or the last line
        str << self[n, size]
        n += size
      end
    end
    str = str.join("\n")

    str[0,0] = prefix + ' ' * (indent - prefix.length)
    if first_line_only
      head = ' ' * indent
    else
      head = prefix + ' ' * (indent - prefix.length)
    end
    str.gsub!("\n", "\n#{head}")

    return str.chomp
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

