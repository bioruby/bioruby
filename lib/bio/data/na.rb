#
# bio/data/na.rb - Nucleic Acids
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Library General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Library General Public License for more details.
#
#  $Id: na.rb,v 0.2 2001/06/21 05:49:27 katayama Exp $
#

module NucleicAcids

  NA = {

    # IUPAC code
    # * Faisst and Meyer (Nucleic Acids Res. 20:3-26, 1992)
    # * http://www.ncbi.nlm.nih.gov/collab/FT/

    'w'	=> '[at]',
    'r'	=> '[ag]',
    'm'	=> '[ac]',
    'k'	=> '[tg]',
    'y'	=> '[tc]',
    's'	=> '[gc]',

    'd'	=> '[atg]',
    'h'	=> '[atc]',
    'v'	=> '[agc]',
    'b'	=> '[tgc]',

    'n' => '[atgc]',

    'a'	=> 'a',
    't'	=> 't',
    'g'	=> 'g',
    'c'	=> 'c',
    'u'	=> 'u',

    'A'	=> 'adenine',
    'T'	=> 'thymine',
    'G'	=> 'guanine',
    'C'	=> 'cytosine',
    'U'	=> 'uracil',

  }

  def na(base)
    NA[base]
  end

end

