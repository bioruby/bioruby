#
# bio/util/color_scheme/strand.rb - Color codings for strand propensity
#
# Copyright::  Copyright (C) 2005 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: strand.rb,v 1.3 2005/12/13 14:58:07 trevor Exp $
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
  class Strand < Score

    #########
    protected
    #########

    def self.score_to_rgb_hex(score, min, max)
      percent = score_to_percent(score, min, max)
      rgb_percent_to_hex(percent, percent, 1.0-percent)
    end

    @colors = {}
    @scores = {
      'A' => 0.83,
      'C' => 1.19,
      'D' => 0.54,
      'E' => 0.37,
      'F' => 1.38,
      'G' => 0.75,
      'H' => 0.87,
      'I' => 1.6,
      'K' => 0.74,
      'L' => 1.3,
      'M' => 1.05,
      'N' => 0.89,
      'P' => 0.55,
      'Q' => 1.1,
      'R' => 0.93,
      'S' => 0.75,
      'T' => 1.19,
      'U' => 0.0,
      'V' => 1.7,
      'W' => 1.37,
      'Y' => 1.47,

      'B' => 0.72,
      'X' => 1.0,
      'Z' => 0.74,
    }
    @min = 0.37
    @max = 1.7
    @scores.each { |k,s| @colors[k] = score_to_rgb_hex(s, @min, @max) }
    @colors.default = 'FFFFFF'  # return white by default

  end
end
