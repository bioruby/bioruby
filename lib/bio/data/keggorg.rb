# 
# bio/data/keggorg.rb - KEGG organism code module
# 
#   Copyright (C) 2001, 2002  KATAYAMA Toshiaki <k@bioruby.org> 
#   Copyright (C) 2002  Masumi Itoh <m@bioruby.org> 
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
#  $Id: keggorg.rb,v 0.10 2002/07/29 04:59:53 m Exp $
#

module Bio
  KEGGORG = {
    'aae' => [ 'A.aeolicus', 'Aquifex aeolicus' ],
    'afu' => [ 'A.fulgidus', 'Archaeoglobus fulgidus' ],
    'ana' => [ 'Anabaena', 'Anabaena sp.' ],
    'ape' => [ 'A.pernix', 'Aeropyrum pernix' ],
    'atc' => [ 'A.tumefaciens_C', 'Agrobacterium tumefaciens C58 Cereon' ],
    'ath' => [ 'A.thaliana', 'Arabidopsis thaliana' ],
    'atu' => [ 'A.tumefaciens', 'Agrobacterium tumefaciens C58 UWash' ],
    'bas' => [ 'B.aphidicola_Sg', 'Buchnera aphidicola Sg' ],
    'bbu' => [ 'B.burgdorferi', 'Borrelia burgdorferi' ],
    'bha' => [ 'B.halodurans', 'Bacillus halodurans' ],
    'bme' => [ 'B.melitensis', 'Brucella melitensis' ],
    'bsu' => [ 'B.subtilis', 'Bacillus subtilis' ],
    'buc' => [ 'Buchnera', 'Buchnera sp.' ],
    'cac' => [ 'C.acetobutylicum', 'Clostridium acetobutylicum' ],
    'cal' => [ 'C.albicans', 'Candida albicans' ],
    'ccr' => [ 'C.crescentus', 'Caulobacter crescentus' ],
    'cel' => [ 'C.elegans', 'Caenorhabditis elegans' ],
    'cje' => [ 'C.jejuni', 'Campylobacter jejuni' ],
    'cmu' => [ 'C.muridarum', 'Chlamydia muridarum' ],
    'cpa' => [ 'C.pneumoniae_AR39', 'Chlamydophila pneumoniae AR39' ],
    'cpe' => [ 'C.perfringens', 'Clostridium perfringens' ],
    'cpj' => [ 'C.pneumoniae_J138', 'Chlamydophila pneumoniae J138' ],
    'cpn' => [ 'C.pneumoniae', 'Chlamydophila pneumoniae CWL029' ],
    'cte' => [ 'C.tepidum', 'Chlorobium tepidum' ],
    'ctr' => [ 'C.trachomatis', 'Chlamydia trachomatis' ],
    'ddi' => [ 'D.discoideum', 'Dictyostelium discoideum' ],
    'dme' => [ 'D.melanogaster', 'Drosophila melanogaster' ],
    'dra' => [ 'D.radiodurans', 'Deinococcus radiodurans' ],
    'dre' => [ 'D.rerio', 'Danio rerio' ],
    'ece' => [ 'E.coli_O157', 'Escherichia coli O157 EDL933' ],
    'ecj' => [ 'E.coli_J', 'Escherichia coli K-12 W3110' ],
    'eco' => [ 'E.coli', 'Escherichia coli K-12 MG1655' ],
    'ecs' => [ 'E.coli_O157J', 'Escherichia coli O157 Sakai' ],
    'fnu' => [ 'F.nucleatum', 'Fusobacterium nucleatum' ],
    'hal' => [ 'Halobacterium', 'Halobacterium sp.' ],
    'hin' => [ 'H.influenzae', 'Haemophilus influenzae' ],
    'hpj' => [ 'H.pylori_J99', 'Helicobacter pylori J99' ],
    'hpy' => [ 'H.pylori', 'Helicobacter pylori 26695' ],
    'hsa' => [ 'H.sapiens', 'Homo sapiens' ],
    'lin' => [ 'L.innocua', 'Listeria innocua' ],
    'lla' => [ 'L.lactis', 'Lactococcus lactis' ],
    'lmo' => [ 'L.monocytogenes', 'Listeria monocytogenes' ],
    'mac' => [ 'M.acetivorans', 'Methanosarcina acetivorans' ],
    'mge' => [ 'M.genitalium', 'Mycoplasma genitalium' ],
    'mja' => [ 'M.jannaschii', 'Methanococcus jannaschii' ],
    'mka' => [ 'M.kandleri', 'Methanopyrus kandleri' ],
    'mle' => [ 'M.leprae', 'Mycobacterium leprae' ],
    'mlo' => [ 'M.loti', 'Mesorhizobium loti' ],
    'mma' => [ 'M.mazei', 'Methanosarcina mazei' ],
    'mmu' => [ 'M.musculus', 'Mus musculus' ],
    'mpn' => [ 'M.pneumoniae', 'Mycoplasma pneumoniae' ],
    'mpu' => [ 'M.pulmonis', 'Mycoplasma pulmonis' ],
    'mtc' => [ 'M.tuberculosis_CDC1551', 'Mycobacterium tuberculosis CDC1551' ],
    'mth' => [ 'M.thermoautotrophicum', 'Methanobacterium thermoautotrophicum' ],
    'mtu' => [ 'M.tuberculosis', 'Mycobacterium tuberculosis H37Rv' ],
    'nma' => [ 'N.meningitidis_A', 'Neisseria meningitidis serogroup A' ],
    'nme' => [ 'N.meningitidis', 'Neisseria meningitidis serogroup B' ],
    'osa' => [ 'O.sativa', 'Oryza sativa' ],
    'pab' => [ 'P.abyssi', 'Pyrococcus abyssi' ],
    'pae' => [ 'P.aeruginosa', 'Pseudomonas aeruginosa' ],
    'pai' => [ 'P.aerophilum', 'Pyrobaculum aerophilum ' ],
    'pfa' => [ 'P.falciparum', 'Plasmodium falciparum' ],
    'pfu' => [ 'P.furiosus', 'Pyrococcus furiosus' ],
    'pho' => [ 'P.horikoshii', 'Pyrococcus horikoshii' ],
    'pmu' => [ 'P.multocida', 'Pasteurella multocida' ],
    'rco' => [ 'R.conorii', 'Rickettsia conorii' ],
    'rno' => [ 'R.norvegicus', 'Rattus norvegicus' ],
    'rpr' => [ 'R.prowazekii', 'Rickettsia prowazekii' ],
    'rso' => [ 'R.solanacearum', 'Ralstonia solanacearum' ],
    'sam' => [ 'S.aureus_MW2', 'Staphylococcus aureus MW2' ],
    'sau' => [ 'S.aureus_N315', 'Staphylococcus aureus N315' ],
    'sav' => [ 'S.aureus_Mu50', 'Staphylococcus aureus Mu50' ],
    'sce' => [ 'S.cerevisiae', 'Saccharomyces cerevisiae' ],
    'sco' => [ 'S.coelicolor', 'Streptomyces coelicolor' ],
    'sme' => [ 'S.meliloti', 'Sinorhizobium meliloti' ],
    'spg' => [ 'S.pyogenes_M3', 'Streptococcus pyogenes M3' ],
    'spm' => [ 'S.pyogenes_M18', 'Streptococcus pyogenes M18' ],
    'spn' => [ 'S.pneumoniae', 'Streptococcus pneumoniae TIGR4' ],
    'spo' => [ 'S.pombe', 'Schizosaccharomyces pombe' ],
    'spr' => [ 'S.pneumoniae_R6', 'Streptococcus pneumoniae R6' ],
    'spy' => [ 'S.pyogenes', 'Streptococcus pyogenes' ],
    'sso' => [ 'S.solfataricus', 'Sulfolobus solfataricus' ],
    'stm' => [ 'S.typhimurium', 'Salmonella typhimurium' ],
    'sto' => [ 'S.tokodaii', 'Sulfolobus tokodaii' ],
    'sty' => [ 'S.typhi', 'Salmonella typhi' ],
    'syn' => [ 'Synechocystis', 'Synechocystis sp.' ],
    'tac' => [ 'T.acidophilum', 'Thermoplasma acidophilum' ],
    'tma' => [ 'T.maritima', 'Thermotoga maritima' ],
    'tpa' => [ 'T.pallidum', 'Treponema pallidum' ],
    'tte' => [ 'T.tengcongensis', 'Thermoanaerobacter tengcongensis' ],
    'tvo' => [ 'T.volcanium', 'Thermoplasma volcanium' ],
    'uur' => [ 'U.urealyticum', 'Ureaplasma urealyticum' ],
    'vch' => [ 'V.cholerae', 'Vibrio cholerae' ],
    'xac' => [ 'X.axonopodis', 'Xanthomonas axonopodis' ],
    'xcc' => [ 'X.campestris', 'Xanthomonas campestris' ],
    'xfa' => [ 'X.fastidiosa', 'Xylella fastidiosa' ],
    'ype' => [ 'Y.pestis', 'Yersinia pestis' ],
    'zma' => [ 'Z.mays', 'Zea mays' ],
}
end