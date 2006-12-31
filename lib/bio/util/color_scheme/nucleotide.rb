#
# bio/util/color_scheme/nucleotide.rb - Color codings for nucleotides
#
# Author::    Trevor Wennblom  <mailto:trevor@corevx.com>
# Copyright:: Copyright (c) 2005-2007 Midwinter Laboratories, LLC (http://midwinterlabs.com)
# License::   Distributes under the same terms as Ruby
#
#  $Id: nucleotide.rb,v 1.3 2006/12/31 19:47:35 trevor Exp $
#

require 'bio/util/color_scheme'

module Bio::ColorScheme
  class Nucleotide < Simple #:nodoc:

    #########
    protected
    #########

    @colors = {
      'A' => '64F73F',
      'C' => 'FFB340',
      'G' => 'EB413C',
      'T' => '3C88EE',
      'U' => '3C88EE',
    }
    @colors.default = 'FFFFFF'  # return white by default

  end
  NA = Nuc = Nucleotide
end
