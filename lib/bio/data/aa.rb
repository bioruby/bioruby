#
# bio/data/aa.rb - Amino Acids
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
#  $Id: aa.rb,v 0.4 2001/10/17 14:43:11 katayama Exp $
#

module Bio

  AminoAcid = {

    # IUPAC code
    # * http://www.iupac.org/
    # * http://www.chem.qmw.ac.uk/iubmb/newsletter/1999/item3.html

    'A' => 'Ala',
    'C' => 'Cys',
    'D' => 'Asp',
    'E' => 'Glu',
    'F' => 'Phe',
    'G' => 'Gly',
    'H' => 'His',
    'I' => 'Ile',
    'K' => 'Lys',
    'L' => 'Leu',
    'M' => 'Met',
    'N' => 'Asn',
    'P' => 'Pro',
    'Q' => 'Gln',
    'R' => 'Arg',
    'S' => 'Ser',
    'T' => 'Thr',
    'V' => 'Val',
    'W' => 'Trp',
    'Y' => 'Tyr',
    'U' => 'Sec',

    'Ala' => 'alanine',
    'Cys' => 'cysteine',
    'Asp' => 'aspartic acid',
    'Glu' => 'glutamic acid',
    'Phe' => 'phenylalanine',
    'Gly' => 'glycine',
    'His' => 'histidine',
    'Ile' => 'isoleucine',
    'Lys' => 'lysine',
    'Leu' => 'leucine',
    'Met' => 'methionine',
    'Asn' => 'asparagine',
    'Pro' => 'proline',
    'Gln' => 'glutamine',
    'Arg' => 'arginine',
    'Ser' => 'serine',
    'Thr' => 'threonine',
    'Val' => 'valine',
    'Trp' => 'tryptophan',
    'Tyr' => 'tyrosine',
    'Sec' => 'selenocysteine',

  }

  AminoAcid_weight = {

    # AAindex FASG760101
    # * Molecular weight (Fasman, 1976)
    #   Fasman, G.D., ed.
    #   Handbook of Biochemistry and Molecular Biology", 3rd ed., Proteins -
    #   Volume 1, CRC Press, Cleveland (1976)

    'A' => 89.09,
    'C' => 121.15,
    'D' => 133.10,
    'E' => 147.13,
    'F' => 165.19,
    'G' => 75.07,
    'H' => 155.16,
    'I' => 131.17,
    'K' => 146.19,
    'L' => 131.17,
    'M' => 149.21,
    'N' => 132.12,
    'P' => 115.13,
    'Q' => 146.15,
    'R' => 174.20,
    'S' => 105.09,
    'T' => 119.12,
    'V' => 117.15,
    'W' => 204.24,
    'Y' => 181.19,
  }

end				# module Bio

