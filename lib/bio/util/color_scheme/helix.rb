#
# bio/util/color_scheme/helix.rb - Color codings for helix propensity
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: helix.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/util/color_scheme'

module Bio::ColorScheme
  class Helix < Score #:nodoc:

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
