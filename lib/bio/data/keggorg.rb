# 
# bio/data/keggorg.rb - KEGG organism code module
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
#  $Id: keggorg.rb,v 0.4 2001/11/06 16:58:52 okuji Exp $
#

module Bio

  # % genome2tab.rb genome | cut -f 1-3 | sort
  #
  # genome           KEGG Genome Database
  #                  Release 00-11-15+/05-30, May 01
  #                  Institute for Chemical Research, Kyoto University
  #                  53 entries
  #                  Last update:  01/05/30
  #                  <dbget> 
  KEGGORG = {
    'aae' => [ 'A.aeolicus', 'Aquifex aeolicus VF5' ],
    'afu' => [ 'A.fulgidus', 'Archaeoglobus fulgidus VC-16' ],
    'ape' => [ 'A.pernix', 'Aeropyrum pernix K1' ],
    'bbu' => [ 'B.burgdorferi', 'Borrelia burgdorferi B31' ],
    'bha' => [ 'B.halodurans', 'Bacillus halodurans C-125' ],
    'bsu' => [ 'B.subtilis', 'Bacillus subtilis 168' ],
    'buc' => [ 'Buchnera', 'Buchnera sp. APS' ],
    'ccr' => [ 'C.crescentus', 'Caulobacter crescentus' ],
    'cel' => [ 'C.elegans', 'Caenorhabditis elegans' ],
    'cje' => [ 'C.jejuni', 'Campylobacter jejuni NCTC11168' ],
    'cmu' => [ 'C.muridarum', 'Chlamydia muridarum (Chlamydia trachomatis MoPn)' ],
    'cpa' => [ 'C.pneumoniae_AR39', 'Chlamydophila pneumoniae AR39' ],
    'cpj' => [ 'C.pneumoniae_J138', 'Chlamydophila pneumoniae J138' ],
    'cpn' => [ 'C.pneumoniae', 'Chlamydia pneumoniae CWL029' ],
    'ctr' => [ 'C.trachomatis', 'Chlamydia trachomatis serovar D' ],
    'dra' => [ 'D.radiodurans', 'Deinococcus radiodurans R1' ],
    'ece' => [ 'E.coli_O157', 'Escherichia coli O157:H7 EDL933' ],
    'eco' => [ 'E.coli', 'Escherichia coli K-12 MG1655' ],
    'ecs' => [ 'E.coli_O157J', 'Escherichia coli O157:H7 Sakai' ],
    'hal' => [ 'Halobacterium', 'Halobacterium sp. NRC-1' ],
    'hin' => [ 'H.influenzae', 'Haemophilus influenzae Rd KW20' ],
    'hpj' => [ 'H.pylori_J99', 'Helicobacter pylori J99' ],
    'hpy' => [ 'H.pylori', 'Helicobacter pylori 26695' ],
    'lla' => [ 'L.lactis', 'Lactococcus lactis subsp. lactis IL1403' ],
    'mge' => [ 'M.genitalium', 'Mycoplasma genitalium G-37' ],
    'mja' => [ 'M.jannaschii', 'Methanococcus jannaschii DSM2661' ],
    'mle' => [ 'M.leprae', 'Mycobacterium leprae' ],
    'mlo' => [ 'M.loti', 'Mesorhizobium loti MAFF303099' ],
    'mpn' => [ 'M.pneumoniae', 'Mycoplasma pneumoniae M129' ],
    'mpu' => [ 'M.pulmonis', 'Mycoplasma pulmonis UAB CTIP' ],
    'mtc' => [ 'M.tuberculosis_CDC1551', 'Mycobacterium tuberculosis CDC1551, clinical strain' ],
    'mth' => [ 'M.thermoautotrophicum', 'Methanobacterium thermoautotrophicum deltaH' ],
    'mtu' => [ 'M.tuberculosis', 'Mycobacterium tuberculosis H37Rv, latobatory strain' ],
    'nma' => [ 'N.meningitidis_A', 'Neisseria meningitidis Z2491 (serogroup A)' ],
    'nme' => [ 'N.meningitidis', 'Neisseria meningitidis MC58 (serogroup B)' ],
    'pab' => [ 'P.abyssi', 'Pyrococcus abyssi GE5' ],
    'pae' => [ 'P.aeruginosa', 'Pseudomonas aeruginosa PA01' ],
    'pho' => [ 'P.horikoshii', 'Pyrococcus horikoshii OT3' ],
    'pmu' => [ 'P.multocida', 'Pasteurella multocida PM70' ],
    'rpr' => [ 'R.prowazekii', 'Rickettsia prowazekii Madrid E' ],
    'sau' => [ 'S.aureus_N315', 'Staphylococcus aureus N315, meticillin-resistant (MRSA)' ],
    'sav' => [ 'S.aureus_Mu50', 'Staphylococcus aureus strain Mu50, MRSA strain with vancomycin resistance (VRSA)' ],
    'sce' => [ 'S.cerevisiae', 'Saccharomyces cerevisiae S288C' ],
    'spy' => [ 'S.pyogenes', 'Streptococcus pyogenes M1, class I strain' ],
    'sso' => [ 'S.solfataricus', 'Sulfolobus solfataricus' ],
    'syn' => [ 'Synechocystis', 'Synechocystis PCC6803' ],
    'tac' => [ 'T.acidophilum', 'Thermoplasma acidophilum' ],
    'tma' => [ 'T.maritima', 'Thermotoga maritima MSB8' ],
    'tpa' => [ 'T.pallidum', 'Treponema pallidum Nichols' ],
    'tvo' => [ 'T.volcanium', 'Thermoplasma volcanium' ],
    'uur' => [ 'U.urealyticum', 'Ureaplasma urealyticum serovar 3' ],
    'vch' => [ 'V.cholerae', 'Vibrio cholerae El Tor N16961' ],
    'xfa' => [ 'X.fastidiosa', 'Xylella fastidiosa 9a5c' ],
  }

end				# module Bio

