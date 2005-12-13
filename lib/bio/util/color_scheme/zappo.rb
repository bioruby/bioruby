#
# bio/util/color_scheme/zappo.rb - Zappo color codings for amino acids
#
# Copyright::  Copyright (C) 2005 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: zappo.rb,v 1.2 2005/12/13 14:58:07 trevor Exp $
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

require 'bio/util/color_scheme'

module Bio::ColorScheme
  class Zappo < Simple

    #########
    protected
    #########

    @colors = {
      'A' => 'FFAFAF',
      'C' => 'FFFF00',
      'D' => 'FF0000',
      'E' => 'FF0000',
      'F' => 'FFC800',
      'G' => 'FF00FF',
      'H' => 'FF0000',
      'I' => 'FFAFAF',
      'K' => '6464FF',
      'L' => 'FFAFAF',
      'M' => 'FFAFAF',
      'N' => '00FF00',
      'P' => 'FF00FF',
      'Q' => '00FF00',
      'R' => '6464FF',
      'S' => '00FF00',
      'T' => '00FF00',
      'U' => 'FFFFFF',
      'V' => 'FFAFAF',
      'W' => 'FFC800',
      'Y' => 'FFC800',

      'B' => 'FFFFFF',
      'X' => 'FFFFFF',
      'Z' => 'FFFFFF',
    }
    @colors.default = 'FFFFFF'  # return white by default

  end
end
