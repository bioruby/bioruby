#
# bio/data/codontable.rb - Codon Table
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

module CodonTable

  CT = [
    # codon table 0
    {},

    # codon table 1 - Eukaryote (e.g. : S. cerevisiae)
    {
      "ttt"=>"F", "tct"=>"S", "tat"=>"Y", "tgt"=>"C",
      "ttc"=>"F", "tcc"=>"S", "tac"=>"Y", "tgc"=>"C",
      "tta"=>"L", "tca"=>"S", "taa"=>"*", "tga"=>"*",
      "ttg"=>"L", "tcg"=>"S", "tag"=>"*", "tgg"=>"W",

      "ctt"=>"L", "cct"=>"P", "cat"=>"H", "cgt"=>"R",
      "ctc"=>"L", "ccc"=>"P", "cac"=>"H", "cgc"=>"R",
      "cta"=>"L", "cca"=>"P", "caa"=>"Q", "cga"=>"R",
      "ctg"=>"L", "ccg"=>"P", "cag"=>"Q", "cgg"=>"R",

      "att"=>"I", "act"=>"T", "aat"=>"N", "agt"=>"S",
      "atc"=>"I", "acc"=>"T", "aac"=>"N", "agc"=>"S",
      "ata"=>"I", "aca"=>"T", "aaa"=>"K", "aga"=>"R",
      "atg"=>"M", "acg"=>"T", "aag"=>"K", "agg"=>"R",

      "gtt"=>"V", "gct"=>"A", "gat"=>"D", "ggt"=>"G",
      "gtc"=>"V", "gcc"=>"A", "gac"=>"D", "ggc"=>"G",
      "gta"=>"V", "gca"=>"A", "gaa"=>"E", "gga"=>"G",
      "gtg"=>"V", "gcg"=>"A", "gag"=>"E", "ggg"=>"G",
    },

    # codon table 2
    {},

    # codon table 3 - Eukaryote mitochondoria (e.g. : S. cerevisiae)
    {},

    # codon table 4
    {},

    # codon table 5
    {},

    # codon table 6
    {},

    # codon table 7
    {},

    # codon table 8
    {},

    # codon table 9
    {},

    # codon table 10
    {},

    # codon table 11 - Bacteria (e.g. : E. coli)
    {
      "ttt"=>"F", "tct"=>"S", "tat"=>"Y", "tgt"=>"C",
      "ttc"=>"F", "tcc"=>"S", "tac"=>"Y", "tgc"=>"C",
      "tta"=>"L", "tca"=>"S", "taa"=>"*", "tga"=>"*",
      "ttg"=>"L", "tcg"=>"S", "tag"=>"*", "tgg"=>"W",

      "ctt"=>"L", "cct"=>"P", "cat"=>"H", "cgt"=>"R",
      "ctc"=>"L", "ccc"=>"P", "cac"=>"H", "cgc"=>"R",
      "cta"=>"L", "cca"=>"P", "caa"=>"Q", "cga"=>"R",
      "ctg"=>"L", "ccg"=>"P", "cag"=>"Q", "cgg"=>"R",

      "att"=>"I", "act"=>"T", "aat"=>"N", "agt"=>"S",
      "atc"=>"I", "acc"=>"T", "aac"=>"N", "agc"=>"S",
      "ata"=>"I", "aca"=>"T", "aaa"=>"K", "aga"=>"R",
      "atg"=>"M", "acg"=>"T", "aag"=>"K", "agg"=>"R",

      "gtt"=>"V", "gct"=>"A", "gat"=>"D", "ggt"=>"G",
      "gtc"=>"V", "gcc"=>"A", "gac"=>"D", "ggc"=>"G",
      "gta"=>"V", "gca"=>"A", "gaa"=>"E", "gga"=>"G",
      "gtg"=>"V", "gcg"=>"A", "gag"=>"E", "ggg"=>"G",
    },
  ]

  def ct(codon, table = 1)
    CT[table][codon]
  end

end

