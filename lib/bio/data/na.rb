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
#  $Id: na.rb,v 0.3 2001/09/26 18:46:02 katayama Exp $
#

module NucleicAcid

  NA_name = {

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

  NA_weight = {

    # Calculated by BioPerl's SeqStats.pm :-)

    'A' => 313.245,
    'T' => 304.225,
    'G' => 329.245,
    'C' => 289.215,
  }

end

