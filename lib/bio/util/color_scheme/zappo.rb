#
# bio/util/color_scheme/zappo.rb - Zappo color codings for amino acids
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: zappo.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/util/color_scheme'

module Bio::ColorScheme
  class Zappo < Simple #:nodoc:

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
