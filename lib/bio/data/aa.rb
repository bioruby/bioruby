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
#  $Id: aa.rb,v 0.2 2001/06/21 05:48:10 katayama Exp $
#

module AminoAcids

  AA = {

    # IUPAC code
    # * http://www.iupac.org/
    # * http://www.chem.qmw.ac.uk/iubmb/newsletter/1999/item3.html

    'A'	=> 'Ala', 'C' => 'Cys', 'D' => 'Asp', 'E' => 'Glu',
    'F'	=> 'Phe', 'G' => 'Gly', 'H' => 'His', 'I' => 'Ile',
    'K'	=> 'Lys', 'L' => 'Leu', 'M' => 'Met', 'N' => 'Asn',
    'P'	=> 'Pro', 'Q' => 'Gln', 'R' => 'Arg', 'S' => 'Ser',
    'T'	=> 'Thr', 'V' => 'Val', 'W' => 'Trp', 'Y' => 'Tyr',
    'U'	=> 'Sec',

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

  def aa(code)
    AA[code]
  end

end

