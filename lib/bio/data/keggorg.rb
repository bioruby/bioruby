# 
# bio/data/keggorg.rb - KEGG organism code module
# 
#   Copyright (C) 2001, 2002 KATAYAMA Toshiaki <k@bioruby.org> 
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
#  $Id: keggorg.rb,v 0.8 2002/06/19 05:03:00 k Exp $
#

module Bio

  # % genome2rb.rb /bio/db/kegg/genome/genome | sort
  #
  # genome2rb.rb:
  #
  #   require 'bio'
  #
  #   Bio::FlatFile.new(Bio::KEGG::GENOME,ARGF).each do |x|
  #     puts "    '#{x.entry_id}' => [ '#{x.name}', '#{x.definition}' ],"
  #   end
  #
  # genome           KEGG Genome Database
  # gn               Release 22.0+/06-04, Jun 02
  #                  Institute for Chemical Research, Kyoto University
  #                  91 entries
  #                  Last update:  02/06/04
  #                  <dbget> <fasta> <blast>
  #
  KEGGORG = {
    'aae' => [ 'A.aeolicus', 'Aquifex aeolicus VF5' ],
    'afu' => [ 'A.fulgidus', 'Archaeoglobus fulgidus VC-16' ],
    'ana' => [ 'Anabaena', 'Anabaena sp. PCC 7120 (Nostoc sp. PCC 7120)' ],
    'ape' => [ 'A.pernix', 'Aeropyrum pernix K1' ],
    'atc' => [ 'A.tumefaciens_C', 'Agrobacterium tumefaciens C58 (Cereon)' ],
    'ath' => [ 'A.thaliana', 'Arabidopsis thaliana' ],
    'atu' => [ 'A.tumefaciens', 'Agrobacterium tumefaciens C58 (U.Washington/Dupont)' ],
    'bbu' => [ 'B.burgdorferi', 'Borrelia burgdorferi B31' ],
    'bha' => [ 'B.halodurans', 'Bacillus halodurans C-125' ],
    'bme' => [ 'B.melitensis', 'Brucella melitensis 16M' ],
    'bsu' => [ 'B.subtilis', 'Bacillus subtilis 168' ],
    'buc' => [ 'Buchnera', 'Buchnera sp. APS' ],
    'cac' => [ 'C.acetobutylicum', 'Clostridium acetobutylicum ATCC 824' ],
    'ccr' => [ 'C.crescentus', 'Caulobacter crescentus CB15' ],
    'cel' => [ 'C.elegans', 'Caenorhabditis elegans' ],
    'cje' => [ 'C.jejuni', 'Campylobacter jejuni NCTC11168' ],
    'cmu' => [ 'C.muridarum', 'Chlamydia muridarum (Chlamydia trachomatis MoPn)' ],
    'cpa' => [ 'C.pneumoniae_AR39', 'Chlamydophila pneumoniae AR39' ],
    'cpe' => [ 'C.perfringens', 'Clostridium perfringens 13' ],
    'cpj' => [ 'C.pneumoniae_J138', 'Chlamydophila pneumoniae J138' ],
    'cpn' => [ 'C.pneumoniae', 'Chlamydophila pneumoniae CWL029' ],
    'ctr' => [ 'C.trachomatis', 'Chlamydia trachomatis serovar D' ],
    'ddi' => [ 'D.discoideum', 'Dictyostelium discoideum' ],
    'dme' => [ 'D.melanogaster', 'Drosophila melanogaster' ],
    'dra' => [ 'D.radiodurans', 'Deinococcus radiodurans R1' ],
    'dre' => [ 'D.rerio', 'Danio rerio' ],
    'ece' => [ 'E.coli_O157', 'Escherichia coli O157:H7 EDL933' ],
    'ecj' => [ 'E.coli_J', 'Escherichia coli K-12 W3110' ],
    'eco' => [ 'E.coli', 'Escherichia coli K-12 MG1655' ],
    'ecs' => [ 'E.coli_O157J', 'Escherichia coli O157:H7 Sakai' ],
    'fnu' => [ 'F.nucleatum', 'Fusobacterium nucleatum ATCC 25586' ],
    'hal' => [ 'Halobacterium', 'Halobacterium sp. NRC-1' ],
    'hin' => [ 'H.influenzae', 'Haemophilus influenzae Rd KW20' ],
    'hpj' => [ 'H.pylori_J99', 'Helicobacter pylori J99' ],
    'hpy' => [ 'H.pylori', 'Helicobacter pylori 26695' ],
    'hsa' => [ 'H.sapiens', 'Homo sapiens' ],
    'lin' => [ 'L.innocua', 'Listeria innocua CLIP 11262' ],
    'lla' => [ 'L.lactis', 'Lactococcus lactis subsp. lactis IL1403' ],
    'lmo' => [ 'L.monocytogenes', 'Listeria monocytogenes EGD-e' ],
    'mac' => [ 'M.acetivorans', 'Methanosarcina acetivorans C2A' ],
    'mge' => [ 'M.genitalium', 'Mycoplasma genitalium G-37' ],
    'mja' => [ 'M.jannaschii', 'Methanococcus jannaschii DSM2661' ],
    'mka' => [ 'M.kandleri', 'Methanopyrus kandleri AV19' ],
    'mle' => [ 'M.leprae', 'Mycobacterium leprae TN' ],
    'mlo' => [ 'M.loti', 'Mesorhizobium loti MAFF303099' ],
    'mma' => [ 'M.mazei', 'Methanosarcina mazei Goe1' ],
    'mmu' => [ 'M.musculus', 'Mus musculus' ],
    'mpn' => [ 'M.pneumoniae', 'Mycoplasma pneumoniae M129' ],
    'mpu' => [ 'M.pulmonis', 'Mycoplasma pulmonis UAB CTIP' ],
    'mtc' => [ 'M.tuberculosis_CDC1551', 'Mycobacterium tuberculosis CDC1551, clinical strain' ],
    'mth' => [ 'M.thermoautotrophicum', 'Methanobacterium thermoautotrophicum deltaH' ],
    'mtu' => [ 'M.tuberculosis', 'Mycobacterium tuberculosis H37Rv, laboratory strain' ],
    'nma' => [ 'N.meningitidis_A', 'Neisseria meningitidis Z2491 (serogroup A)' ],
    'nme' => [ 'N.meningitidis', 'Neisseria meningitidis MC58 (serogroup B)' ],
    'osa' => [ 'O.sativa', 'Oryza sativa' ],
    'pab' => [ 'P.abyssi', 'Pyrococcus abyssi GE5' ],
    'pae' => [ 'P.aeruginosa', 'Pseudomonas aeruginosa PA01' ],
    'pai' => [ 'P.aerophilum', 'Pyrobaculum aerophilum IM2' ],
    'pfa' => [ 'P.falciparum', 'Plasmodium falciparum 3D7' ],
    'pfu' => [ 'P.furiosus', 'Pyrococcus furiosus DSM 3638' ],
    'pho' => [ 'P.horikoshii', 'Pyrococcus horikoshii OT3' ],
    'pmu' => [ 'P.multocida', 'Pasteurella multocida PM70' ],
    'rco' => [ 'R.conorii', 'Rickettsia conorii Malish 7' ],
    'rno' => [ 'R.norvegicus', 'Rattus norvegicus' ],
    'rpr' => [ 'R.prowazekii', 'Rickettsia prowazekii Madrid E' ],
    'rso' => [ 'R.solanacearum', 'Ralstonia solanacearum GMI1000' ],
    'sau' => [ 'S.aureus_N315', 'Staphylococcus aureus N315, meticillin-resistant (MRSA)' ],
    'sav' => [ 'S.aureus_Mu50', 'Staphylococcus aureus Mu50, MRSA strain with vancomycin resistance (VRSA)' ],
    'sce' => [ 'S.cerevisiae', 'Saccharomyces cerevisiae S288C' ],
    'sme' => [ 'S.meliloti', 'Sinorhizobium meliloti 1021' ],
    'spm' => [ 'S.pyogenes_M18', 'Streptococcus pyogenes MGAS8232 (serotype M18)' ],
    'spn' => [ 'S.pneumoniae', 'Streptococcus pneumoniae TIGR4' ],
    'spo' => [ 'S.pombe', 'Schizosaccharomyces pombe' ],
    'spr' => [ 'S.pneumoniae_R6', 'Streptococcus pneumoniae R6' ],
    'spy' => [ 'S.pyogenes', 'Streptococcus pyogenes SF370 (serotype M1)' ],
    'sso' => [ 'S.solfataricus', 'Sulfolobus solfataricus' ],
    'stm' => [ 'S.typhimurium', 'Salmonella typhimurium LT2' ],
    'sto' => [ 'S.tokodaii', 'Sulfolobus tokodaii strain7' ],
    'sty' => [ 'S.typhi', 'Salmonella typhi' ],
    'syn' => [ 'Synechocystis', 'Synechocystis sp. PCC 6803' ],
    'tac' => [ 'T.acidophilum', 'Thermoplasma acidophilum' ],
    'tma' => [ 'T.maritima', 'Thermotoga maritima MSB8' ],
    'tpa' => [ 'T.pallidum', 'Treponema pallidum Nichols' ],
    'tte' => [ 'T.tengcongensis', 'Thermoanaerobacter tengcongensis MB4T' ],
    'tvo' => [ 'T.volcanium', 'Thermoplasma volcanium GSS1' ],
    'uur' => [ 'U.urealyticum', 'Ureaplasma urealyticum serovar 3' ],
    'vch' => [ 'V.cholerae', 'Vibrio cholerae El Tor N16961' ],
    'xac' => [ 'X.axonopodis', 'Xanthomonas axonopodis pv. citri 306' ],
    'xcc' => [ 'X.campestris', 'Xanthomonas campestris pv. campestris ATCC 339131' ],
    'xfa' => [ 'X.fastidiosa', 'Xylella fastidiosa 9a5c' ],
    'ype' => [ 'Y.pestis', 'Yersinia pestis CO92' ],
  }

end


