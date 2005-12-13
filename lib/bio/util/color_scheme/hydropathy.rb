#
# bio/util/color_scheme/hydropathy.rb - Color codings for hydrophobicity
#
# Copyright::  Copyright (C) 2005 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: hydropathy.rb,v 1.2 2005/12/13 14:58:07 trevor Exp $
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

  # Hydropathy index
  # Kyte, J., and Doolittle, R.F., J. Mol. Biol.
  # 1157, 105-132, 1982

  class Hydropathy < Score

    #########
    protected
    #########

    def self.score_to_rgb_hex(score, min, max)
      percent = score_to_percent(score, min, max)
      rgb_percent_to_hex(percent, 0.0, 1.0-percent)
    end

    @colors = {}
    @scores = {
      'A' => 1.8,
      'C' => 2.5,
      'D' => -3.5,
      'E' => -3.5,
      'F' => 2.8,
      'G' => -0.4,
      'H' => -3.2,
      'I' => 4.5,
      'K' => -3.9,
      'L' => 3.8,
      'M' => 1.9,
      'N' => -3.5,
      'P' => -1.6,
      'Q' => -3.5,
      'R' => -4.5,
      'S' => -0.8,
      'T' => -0.7,
      'U' => 0.0,
      'V' => 4.2,
      'W' => -0.9,
      'Y' => -1.3,

      'B' => -3.5,
      'X' => -0.49,
      'Z' => -3.5,
    }
    @min = -3.9
    @max = 4.5
    @scores.each { |k,s| @colors[k] = score_to_rgb_hex(s, @min, @max) }
    @colors.default = 'FFFFFF'  # return white by default

  end
end
