#
# bio/util/color_scheme/taylor.rb - Taylor color codings for amino acids
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   The Ruby License
#
#  $Id: taylor.rb,v 1.4 2007/04/05 23:35:41 trevor Exp $
#

require 'bio/util/color_scheme'

module Bio::ColorScheme
  class Taylor < Simple #:nodoc:

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
