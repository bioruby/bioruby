#
# bio/util/color_scheme/taylor.rb - Taylor color codings for amino acids
#
# Copyright::  Copyright (C) 2005 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: taylor.rb,v 1.2 2005/12/13 14:58:07 trevor Exp $
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
  class Taylor < Simple

    #########
    protected
    #########

    @colors = {
      'A' => 'CCFF00',
      'C' => 'FFFF00',
      'D' => 'FF0000',
      'E' => 'FF0066',
      'F' => '00FF66',
      'G' => 'FF9900',
      'H' => '0066FF',
      'I' => '66FF00',
      'K' => '6600FF',
      'L' => '33FF00',
      'M' => '00FF00',
      'N' => 'CC00FF',
      'P' => 'FFCC00',
      'Q' => 'FF00CC',
      'R' => '0000FF',
      'S' => 'FF3300',
      'T' => 'FF6600',
      'U' => 'FFFFFF',
      'V' => '99FF00',
      'W' => '00CCFF',
      'Y' => '00FFCC',

      'B' => 'FFFFFF',
      'X' => 'FFFFFF',
      'Z' => 'FFFFFF',
    }
    @colors.default = 'FFFFFF'  # return white by default

  end
end
