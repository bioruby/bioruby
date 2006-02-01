require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)

require 'bio/util/restriction_enzyme/cut_symbol'

module Bio; end
class Bio::RestrictionEnzyme

#
# bio/util/restriction_enzyme/string_formatting.rb - Useful functions for string manipulation
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: string_formatting.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
#
#
#--
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
#++
#
=begin rdoc
bio/util/restriction_enzyme/string_formatting.rb - Useful functions for string manipulation
=end
module StringFormatting
  include CutSymbol
  extend CutSymbol

  # Return the sequence with spacing for alignment.  Does not add whitespace
  # around cut symbols.
  #
  # Example:
  #   pattern = 'n^ng^arraxt^n'
  #   add_spacing( pattern )
  #
  # Returns:
  #   "n^n g^a r r a x t^n"
  #
  def add_spacing( seq, cs = cut_symbol )
    str = ''
    flag = false
    seq.each_byte do |c|
      c = c.chr
      if c == cs
        str += c
        flag = false
      elsif flag
        str += ' ' + c
      else
        str += c
        flag = true
      end
    end
    str
  end

  # Remove extraneous nucleic acid wildcards ('n' padding) from the
  # left and right sides
  def strip_padding( s )
    if s[0].chr == 'n'
      s =~ %r{(n+)(.+)}
      s = $2
    end
    if s[-1].chr == 'n'
      s =~ %r{(.+?)(n+)$}
      s = $1
    end
    s
  end

  # Remove extraneous nucleic acid wildcards ('n' padding) from the
  # left and right sides and remove cut symbols
  def strip_cuts_and_padding( s )
    strip_padding( s.tr(cut_symbol, '') )
  end

  # Return the 'n' padding on the left side of the strand
  def left_padding( s )
    s =~ %r{^n+}
    ret = $&
    ret ? ret : ''  # Don't pass nil values
  end

  # Return the 'n' padding on the right side of the strand
  def right_padding( s )
    s =~ %r{n+$}
    ret = $&
    ret ? ret : ''  # Don't pass nil values
  end


end

end
