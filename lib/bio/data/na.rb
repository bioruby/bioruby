#
# bio/data/na.rb - Nucleic Acids
#
#   Copyright (C) 2001 KATAYAMA Toshiaki <k@bioruby.org>
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
#  $Id: na.rb,v 0.6 2001/12/15 01:48:50 katayama Exp $
#

module Bio

  NucleicAcid = {

    # IUPAC code
    # * Faisst and Meyer (Nucleic Acids Res. 20:3-26, 1992)
    # * http://www.ncbi.nlm.nih.gov/collab/FT/

    'y'	=> '[tc]',	# pYrimidine
    'r'	=> '[ag]',	# puRine
    'w'	=> '[at]',	# Weak
    's'	=> '[gc]',	# Strong
    'k'	=> '[tg]',	# Keto
    'm'	=> '[ac]',	# aMino

    'b'	=> '[tgc]',	# not A
    'd'	=> '[atg]',	# not C
    'h'	=> '[atc]',	# not G
    'v'	=> '[agc]',	# not T

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

  NucleicAcid_weight = {

    # Calculated by BioPerl's SeqStats.pm :-)
    #  -- should be more accurate as BioPerl

    'A' => 313.245,
    'T' => 304.225,
    'G' => 329.245,
    'C' => 289.215,
  }

end

