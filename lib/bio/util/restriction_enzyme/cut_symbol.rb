module Bio; end
class Bio::RestrictionEnzyme

#
# bio/util/restrction_enzyme/cut_symbol.rb - 
#
# Copyright::  Copyright (C) 2006 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: cut_symbol.rb,v 1.1 2006/02/01 07:34:11 trevor Exp $
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
#

=begin rdoc
bio/util/restrction_enzyme/cut_symbol.rb - 
=end
module CutSymbol

  require 'singleton'

  class CutSymbol__
    include Singleton
    attr_accessor :cut_symbol
    attr_accessor :escaped_cut_symbol
  end

  # NOTE verify this sometime
  def cut_symbol=(c)
    CutSymbol__.instance.cut_symbol = c
  end

  def cut_symbol
    CutSymbol__.instance.cut_symbol ||= '^'
  end

  def escaped_cut_symbol
    CutSymbol__.instance.escaped_cut_symbol ||= "\\#{cut_symbol}"  # \^
  end

  # Used to check if multiple cut symbols are next to each other
  def re_cut_symbol_adjacent
    %r"#{escaped_cut_symbol}{2}"
  end

  # A Regexp of the cut_symbol.  Convenience method.
  def re_cut_symbol
    %r"#{escaped_cut_symbol}"
  end

end
end
