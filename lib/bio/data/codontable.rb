#
# bio/data/codontable.rb - Codon Table
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
#  $Id: codontable.rb,v 0.6 2001/11/13 02:20:34 katayama Exp $
#

module Bio

  #
  # Converted from
  #   http://www.ncbi.nlm.nih.gov/htbin-post/Taxonomy/wprintgc?mode=t#SG1
  #

  CodonTable = {

    # codon table 1  - Standard (Eukaryote)
    1 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 2  - Vertebrate Mitochondrial
    2 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => '*',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => '*',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },


    # codon table 3  - Yeast mitochondorial
    3 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'T', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'T', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'T', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'T', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 4  - Mold, Protozoan, Coelenterate Mitochondrial
    #                  and Mycoplasma/Spiroplasma
    4 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 5  - Invertebrate Mitochondrial
    5 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'S',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 6  - Ciliate Macronuclear and Dasycladacean
    6 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => 'Q', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => 'Q', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 9  - Echinoderm Mitochondrial
    9 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 10 - Euplotid Nuclear
    10 => {

      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'C',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 11 - Bacteria
    11 => {
      'ttt' => 'F', 'tct' => 'S', 'tat'	=> 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac'	=> 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa'	=> '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag'	=> '*', 'tgg' => 'W',
       	
      'ctt' => 'L', 'cct' => 'P', 'cat'	=> 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac'	=> 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa'	=> 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag'	=> 'Q', 'cgg' => 'R',
       	
      'att' => 'I', 'act' => 'T', 'aat'	=> 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac'	=> 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa'	=> 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag'	=> 'K', 'agg' => 'R',
       	
      'gtt' => 'V', 'gct' => 'A', 'gat'	=> 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac'	=> 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa'	=> 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag'	=> 'E', 'ggg' => 'G',
    },

    # codon table 12 - Alternative Yeast Nuclear
    12 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'S', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 13 - Ascidian Mitochondrial
    13 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'G',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'G',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 14 - Flatworm Mitochondrial
    14 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => 'Y', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 15 - Blepharisma Macronuclear 
    15 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => 'Q', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 16 - Chlorophycean Mitochondrial  
    16 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => 'L', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 21 - Trematode Mitochondrial  
    21 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'M', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 22 - Scenedesmus obliquus mitochondrial  
    22 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => 'L', 'tca' => '*', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => 'L', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

    # codon table 23 - Thraustochytrium Mitochondrial Code  
    23 => {
      'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
      'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
      'tta' => '*', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
      'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

      'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
      'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
      'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
      'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

      'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
      'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
      'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
      'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

      'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
      'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
      'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
      'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
    },

  }

end				# module Bio



