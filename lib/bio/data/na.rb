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
#  $Id: na.rb,v 0.7 2001/12/19 02:17:48 katayama Exp $
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

    # Calculated by BioPerl's Bio::Tools::SeqStats.pm :-)

    'adenine'	=> 135.15,
    'thymine'	=> 126.13,
    'guanine'	=> 151.15,
    'cytosine'	=> 111.12,
    'uracil'	=> 112.10,

    'deoxyribose_phosphate'	=> 196.11,
    'ribose_phosphate'		=> 212.11,

    'water'	=> 18.015,

  }

end

