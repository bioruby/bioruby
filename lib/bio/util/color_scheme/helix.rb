#
# bio/util/color_scheme/helix.rb - Color codings for helix propensity
#
# Copyright::  Copyright (C) 2005 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: helix.rb,v 1.2 2005/12/13 14:58:07 trevor Exp $
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
  class Helix < Score

    #########
    protected
    #########

    def self.score_to_rgb_hex(score, min, max)
      percent = score_to_percent(score, min, max)
      rgb_percent_to_hex(percent, 1.0-percent, percent)
    end

    @colors = {}
    @scores = {
      'A' => 1.42,
      'C' => 0.7,
      'D' => 1.01,
      'E' => 1.51,
      'F' => 1.13,
      'G' => 0.57,
      'H' => 1.0,
      'I' => 1.08,
      'K' => 1.16,
      'L' => 1.21,
      'M' => 1.45,
      'N' => 0.67,
      'P' => 0.57,
      'Q' => 1.11,
      'R' => 0.98,
      'S' => 0.77,
      'T' => 0.83,
      'U' => 0.0,
      'V' => 1.06,
      'W' => 1.08,
      'Y' => 0.69,

      'B' => 0.84,
      'X' => 1.0,
      'Z' => 1.31,
    }
    @min = 0.57
    @max = 1.51
    @scores.each { |k,s| @colors[k] = score_to_rgb_hex(s, @min, @max) }
    @colors.default = 'FFFFFF'  # return white by default

  end
end
