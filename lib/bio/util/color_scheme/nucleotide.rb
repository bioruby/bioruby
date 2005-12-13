#
# bio/util/color_scheme/nucleotide.rb - Color codings for nucleotides
#
# Copyright::  Copyright (C) 2005 Trevor Wennblom <trevor@corevx.com>
# License::    LGPL
#
#  $Id: nucleotide.rb,v 1.2 2005/12/13 14:58:07 trevor Exp $
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
  class Nucleotide < Simple

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
