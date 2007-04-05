#
# bio/util/color_scheme/turn.rb - Color codings for turn propensity
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: turn.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/util/color_scheme'

module Bio::ColorScheme
  class Turn < Score #:nodoc:

    #########
    protected
    #########

    def self.score_to_rgb_hex(score, min, max)
      percent = score_to_percent(score, min, max)
      rgb_percent_to_hex(percent, 1.0-percent, 1.0-percent)
    end

    @colors = {}
    @scores = {
      'A' => 0.66,
      'C' => 1.19,
      'D' => 1.46,
      'E' => 0.74,
      'F' => 0.6,
      'G' => 1.56,
      'H' => 0.95,
      'I' => 0.47,
      'K' => 1.01,
      'L' => 0.59,
      'M' => 0.6,
      'N' => 1.56,
      'P' => 1.52,
      'Q' => 0.98,
      'R' => 0.95,
      'S' => 1.43,
      'T' => 0.96,
      'U' => 0,
      'V' => 0.5,
      'W' => 0.96,
      'Y' => 1.14,

      'B' => 1.51,
      'X' => 1.0,
      'Z' => 0.86,
    }
    @min = 0.47
    @max = 1.56
    @scores.each { |k,s| @colors[k] = score_to_rgb_hex(s, @min, @max) }
    @colors.default = 'FFFFFF'  # return white by default

  end
end
