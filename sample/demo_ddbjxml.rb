#
# = sample/demo_ddbjxml.rb - demonstration of Bio::DDBJ::XML, DDBJ SOAP access
#
# Copyright::	Copyright (C) 2003, 2004
#		Toshiaki Katayama <k@bioruby.org>
# License::	The Ruby License
#
#
#
# == Description
#
# Demonstration of Bio::DDBJ::XML, DDBJ SOAP server access class.
#
# == Requirements
#
# Internet connection is needed.
#
# == Usage
#
# Simply run this script.
#
#  $ ruby demo_ddbjxml.rb
#
# == Notes
#
# It can not be run with Ruby 1.9 because SOAP4R (SOAP support for Ruby)
# currently does not support Ruby 1.9.
#
# == Development information
#
# The code was moved from lib/bio/io/ddbjxml.rb.
#

require 'bio'

#if __FILE__ == $0

  begin
    require 'pp'
    alias p pp
  rescue LoadError
  end

  puts ">>> Bio::DDBJ::XML::Blast"
  serv = Bio::DDBJ::XML::Blast.new
# serv.log = STDERR

  query = "MSSRIARALALVVTLLHLTRLALSTCPAACHCPLEAPKCAPGVGLVRDGCGCCKVCAKQL"

  puts "### searchSimple('blastp', 'SWISS', query)"
  puts serv.searchSimple('blastp', 'SWISS', query)

  puts "### searchParam('tblastn', 'ddbjvrl', query, '-m 8')"
  puts serv.searchParam('tblastn', 'ddbjvrl', query, '-m 8')


  puts ">>> Bio::DDBJ::XML::ClustalW"
  serv = Bio::DDBJ::XML::ClustalW.new

  query = <<END
> RABSTOUT   rabbit Guinness receptor
   LKMHLMGHLKMGLKMGLKGMHLMHLKHMHLMTYTYTTYRRWPLWMWLPDFGHAS
   ADSCVCAHGFAVCACFAHFDVCFGAVCFHAVCFAHVCFAAAVCFAVCAC
> MUSNOSE   mouse nose drying factor
    mhkmmhkgmkhmhgmhmhglhmkmhlkmgkhmgkmkytytytryrwtqtqwtwyt
    fdgfdsgafdagfdgfsagdfavdfdvgavfsvfgvdfsvdgvagvfdv
> HSHEAVEN    human Guinness receptor repeat
 mhkmmhkgmkhmhgmhmhg   lhmkmhlkmgkhmgkmk  ytytytryrwtqtqwtwyt
 fdgfdsgafdagfdgfsag   dfavdfdvgavfsvfgv  dfsvdgvagvfdv
 mhkmmhkgmkhmhgmhmhg   lhmkmhlkmgkhmgkmk  ytytytryrwtqtqwtwyt
 fdgfdsgafdagfdgfsag   dfavdfdvgavfsvfgv  dfsvdgvagvfdv
END

  puts "### analyzeSimple(query)"
  puts serv.analyzeSimple(query)

  puts "### analyzeParam(query, '-align -matrix=blosum')"
  puts serv.analyzeParam(query, '-align -matrix=blosum')


  puts ">>> Bio::DDBJ::XML::DDBJ"
  serv = Bio::DDBJ::XML::DDBJ.new

  puts "### getFFEntry('AB000050')"
  puts serv.getFFEntry('AB000050')

  puts "### getXMLEntry('AB000050')"
  puts serv.getXMLEntry('AB000050')

  puts "### getFeatureInfo('AB000050', 'cds')"
  puts serv.getFeatureInfo('AB000050', 'cds')

  puts "### getAllFeatures('AB000050')"
  puts serv.getAllFeatures('AB000050')

  puts "### getRelatedFeatures('AL121903', '59000', '64000')"
  puts serv.getRelatedFeatures('AL121903', '59000', '64000')

  puts "### getRelatedFeaturesSeq('AL121903', '59000', '64000')"
  puts serv.getRelatedFeaturesSeq('AL121903', '59000', '64000')


  puts ">>> Bio::DDBJ::XML::Fasta"
  serv = Bio::DDBJ::XML::Fasta.new

  query = ">Test\nMSDGAVQPDG GQPAVRNERA TGSGNGSGGG GGGGSGGVGI"

  puts "### searchSimple('fasta34', 'PDB', query)"
  puts serv.searchSimple('fasta34', 'PDB', query)

  query = ">Test\nAGCTTTTCATTCTGACTGCAACGGGCAATATGTCTCTGTGTGGATTAAAAAAAGAGTGTCTGATAGCAGC"

  puts "### searchParam('fastx34_t', 'PDB', query, '-n')"
  puts serv.searchParam('fastx34_t', 'PDB', query, '-n')


  puts ">>> Bio::DDBJ::XML::GetEntry"
  serv = Bio::DDBJ::XML::GetEntry.new

  puts "### getDDBJEntry('AB000050')"
  puts serv.getDDBJEntry('AB000050')

  puts "### getPDBEntry('1AAR')"
  puts serv. getPDBEntry('1AAR')


  puts ">>> Bio::DDBJ::XML::Gib"
  serv = Bio::DDBJ::XML::Gib.new

  puts "### getOrganismList"
  puts serv.getOrganismList

  puts "### getChIDList"
  puts serv.getChIDList

  puts "### getOrganismNameFromChid('Sent_CT18:')"
  puts serv.getOrganismNameFromChid('Sent_CT18:')

  puts "### getChIDFromOrganismName('Aquifex aeolicus VF5')"
  puts serv.getChIDFromOrganismName('Aquifex aeolicus VF5')

  puts "### getAccession('Ecol_K12_MG1655:')"
  puts serv.getAccession('Ecol_K12_MG1655:')

  puts "### getPieceNumber('Mgen_G37:')"
  puts serv.getPieceNumber('Mgen_G37:')

  puts "### getDivision('Mgen_G37:')"
  puts serv.getDivision('Mgen_G37:')

  puts "### getType('Mgen_G37:')"
  puts serv.getType('Mgen_G37:')

  puts "### getCDS('Aaeo_VF5:ece1')"
  puts serv.getCDS('Aaeo_VF5:ece1')

  puts "### getFlatFile('Nost_PCC7120:pCC7120zeta')"
  puts serv.getFlatFile('Nost_PCC7120:pCC7120zeta')

  puts "### getFastaFile('Nost_PCC7120:pCC7120zeta')"
  puts serv.getFastaFile('Nost_PCC7120:pCC7120zeta', 'cdsaa')


  puts ">>> Bio::DDBJ::XML::Gtop"
  serv = Bio::DDBJ::XML::Gtop.new

  puts "### getOrganismList"
  puts serv.getOrganismList

  puts "### getMasterInfo"
  puts serv.getMasterInfo('thrA', 'ecol0')


#  puts ">>> Bio::DDBJ::XML::PML"
#  serv = Bio::DDBJ::XML::PML.new
#
#  puts "### getVariation('1')"
#  puts serv.getVariation('1')


  puts ">>> Bio::DDBJ::XML::SRS"
  serv = Bio::DDBJ::XML::SRS.new

  puts "### searchSimple('[pathway-des:sugar]')"
  puts serv.searchSimple('[pathway-des:sugar]')

  puts "### searchParam('[swissprot-des:cohesin]', '-f seq -sf fasta')"
  puts serv.searchParam('[swissprot-des:cohesin]', '-f seq -sf fasta')


  puts ">>> Bio::DDBJ::XML::TxSearch"
  serv = Bio::DDBJ::XML::TxSearch.new

  puts "### searchSimple('*coli')"
  puts serv.searchSimple('*coli')

  puts "### searchSimple('*tardigrada*')"
  puts serv.searchSimple('*tardigrada*')

  puts "### getTxId('Escherichia coli')"
  puts serv.getTxId('Escherichia coli')

  puts "### getTxName('562')"
  puts serv.getTxName('562')

  query = "Campylobacter coli\nEscherichia coli"
  rank = "family\ngenus"

  puts "### searchLineage(query, rank, 'Bacteria')"
  puts serv.searchLineage(query, rank, 'Bacteria')

#end
